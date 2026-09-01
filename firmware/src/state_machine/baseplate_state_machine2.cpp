#include <Arduino.h>
#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"
#include "serial_writing.h"
#include "poll_child.h"
#include "pc_communication.h"
#include "feedback.h"
#include "cube_hardware.h"

#define HEARTBEAT_INTERVAL_CYCLE 50 // after 50 cycles payload is sent again even if it hasn´t changed
static uint16_t cycles_since_last_send = 0;
static bool last_child_present[MAX_CHILD_COUNT] = {false}; //error: expression must have a constant value

static uint8_t pc_reply_retry_count = 0; //retry counts if pc replied with bullshit/error after baseplate sends feedback

static uint8_t child_payload[MAX_CHILD_COUNT][MAX_CHILD_PAYLOAD_LEN];   // child_payload[child_index][payload_index] = byte received from child
static uint8_t child_payload_len[MAX_CHILD_COUNT] = {0};                // length of the payload received from child[i]
static bool child_done[MAX_CHILD_COUNT] = {false};                      // child[i] answered with a valid frame this cycle

static uint8_t payload[MAX_PAYLOAD_LEN];
static uint8_t payload_len = 0;

static uint8_t fb_payload[MAX_PAYLOAD_LEN];   // filled by GET_INFO_FROM_PC, consumed by RELAY_FEEDBACK
static uint8_t fb_payload_len = 0;
//////////////////////////////////////////////

//---------------------------------------------------
// DETECTION
//--------------------------------------------------
void handle_detection(void){

    for (uint8_t i = 0; i < child_count; i++) {
            child_done[i] = false;   // fresh detection cycle
        }

        bool child_acked[MAX_CHILD_COUNT] = {false}; // child answered ACK_BUSY at least once this cycle -> port is occupied even if its frame failed

        for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) { //retry loop
            bool retry_needed = false; //true if any child still has attempts left after this round

            for (uint8_t i = 0; i < child_count; i++) {  //child loop, iterates through children

                if (child_done[i]) {
                    continue;
                }

                // presence-aware retry budget: a port counts as occupied if it had a child last cycle OR already ACKed this cycle
                // Occupied ports keep the full retries, empty ports get a single attempt.
                // -> attempt_budget specifies the maximum number of attempts a the port is allowed in this detection cycle
                uint8_t attempt_budget = (last_child_present[i] || child_acked[i]) ? CHILD_RETRIES : 1;

                if (attempt >= attempt_budget) {
                    continue;
                }

                bool acked = false;

                if (poll_child(
                        children[i],           //with wire/pin of child[i]
                        child_payload[i],     //and receive and store the payload in child_payloads[i]
                        MAX_CHILD_PAYLOAD_LEN, //with max length of MAX_CHILD_PAYLOAD_LEN to avoid overflow
                        &child_payload_len[i], //and stores the received payload length from child[i]
                        &acked
                )){
                    SER_PRINTLN("CV");
                    child_done[i] = true; //mark child as done -> no more polling of this child in next attempts
                } else {
                    if (acked) {
                        child_acked[i] = true; // present but frame failed -> full retry budget from now on
                        retry_needed = true;
                    } else if (attempt + 1 < attempt_budget) { //if child was present in the previous detection loop - then also retry
                        retry_needed = true;
                    }
                }
            }

            if (!retry_needed) {
                break;
            }
    }

    // for the feedback state to know at which port to send the feedback frame
    for (uint8_t child = 0; child < child_count; child++) {
        last_child_present[child] = child_done[child] || child_acked[child];
    }    
}

// ----------------------------------------------------------
// PAYLOAD BUILDING : concatenate this cycle's child payloads into payload[]
// ----------------------------------------------------------
void build_payload(uint8_t *payload, uint8_t &payload_len)
{
    payload_len = 0;

    //in a loop add children payloads to the final payload
    for (uint8_t child = 0; child < child_count; child++) {
        if (!child_done[child]) {  //if child[i] didn´t respond, skip it
            continue;
        }

        // Check whether this child payload still fits. If not, do not include it.
        if ((uint16_t)payload_len + child_payload_len[child] > MAX_PAYLOAD_LEN) {
            continue;
        }

        //copy child payload into final payload
        for (uint8_t j = 0; j < child_payload_len[child]; j++) {
            payload[payload_len++] = child_payload[child][j];  //copies stored payload into final payload and increases payload_len for next byte
        }
    }

    release_all_lines();
    _delay_us(3 * BYTE_US);
}

// ----------------------------------------------------------
// SEND PAYLOAD: send the built payload frame to the PC
// ----------------------------------------------------------
void send_payload_to_pc(const uint8_t *payload, uint8_t payload_len)
{
    uint8_t checksum = calc_checksum(payload_len, payload);

    Serial.write(SYNC_BYTE);
    Serial.write(payload_len);
    Serial.write(payload, payload_len);
    Serial.write(checksum);
}

/////////////////////////////////////////////////////////////////
//---------------------------------------------------
// FEEDBACK
//--------------------------------------------------

// outcome of relay_feedback_to_children() — a domain-level result, distinct
// from the PC_RESP_* wire bytes; SEND_RESULT_TO_PC is where that translation happens
enum received_feedback_t : uint8_t {
    FB_DONE, //baseplate receives ACK_FINISHED from first brick 
    FB_FAILED   //baseplate receives ACK_FAILED from first brick 
};

// relay one feedback frame to every port that had a child this cycle,
// with the same retry pattern as the detection polling.
// Returns DONE if every present child confirmed, FAILED otherwise.
static received_feedback_t relay_feedback_to_children(
    const uint8_t *fb_payload,
    uint8_t fb_payload_len
)
{
    bool feedback_done[MAX_CHILD_COUNT] = { false };
    bool all_done = true;

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) {
        bool retry_needed = false;
        all_done = true;

        for (uint8_t child = 0; child < child_count; child++) {

            if (!last_child_present[child]) {
                continue;   // no cube on this port
            }

            if (feedback_done[child]) {
                continue;   // already confirmed
            }

            if (send_feedback_to_child(children[child], fb_payload, fb_payload_len)) {
                feedback_done[child] = true;
            } else {
                all_done = false;
                retry_needed = true;
            }
        }

        if (!retry_needed) {
            break;
        }
    }

    return all_done ? FB_DONE : FB_FAILED;
}

//---------------------------------------------------
// START END SEQUENCE
//--------------------------------------------------

// stop sequence: every cube turns its LED off when its ID is missing
// from the feedback payload, so an EMPTY frame switches all LEDs off
static void run_stop_sequence(void)
{
    static const uint8_t empty_payload[1] = { 0 };  // never read at len 0

    relay_feedback_to_children(empty_payload, 0);
    //detection_running = false;
}

//---------------------------------------------------
//PC COMMUNICATION
//--------------------------------------------------
static bool pc_start_signal_received(){
    bool start_received = false; //vlt hier nur return true/false?

    while(
        Serial.available() > 0 &&
    !start_received
    ){
        uint8_t received_byte= (uint8_t)Serial.read(); //warum uint8_t
    if (received_byte == PC_CMD_START) {
            start_received = true;
        }
    }

    if (start_received) {
        while (Serial.available() > 0) {   // start fresh: drop stray bytes
            Serial.read();
        }
    }

    return start_received; //vlt hier nur return true/false?
}


// state definition
enum class State : uint8_t {
    IDLE,
    DETECTION_INIT,
    DETECTING,
    BUILD_PAYLOAD,
    SEND_PAYLOAD_TO_PC, //vereinen in 1 case
    SEND_RESULT_TO_PC,
    GET_INFO_FROM_PC,
    RELAY_FEEDBACK,
    WAIT_NEXT_CYCLE, //delay am ende von einem cycle
    STOPPING
};

enum class PcResult : uint8_t {
    DONE,
    FAILED
};

static PcResult pending_pc_result = PcResult::DONE;
static State current_state = State::IDLE;
//-----------------------------------

void setup()
{
    release_all_lines();

    Serial.begin(115200);
}

void loop()
{
    
    switch (current_state){

        //IDLE STATE - waiting for PC_CMD_START Signal from PC
        case State:: IDLE:
        {
            if (pc_start_signal_received()){
                cycles_since_last_send = HEARTBEAT_INTERVAL_CYCLE; //damit sicher dass erste payload an den pc geschickt wird
            current_state = State:: DETECTION_INIT;
            }
            break;
        }
    

    //DETECTION_INIT STATE - if no stop signal from pc arrived, prepare Detection sequence
        case State:: DETECTION_INIT:
        {
            if (stop_received()){  //besser state info from pc und dann case stop received?
                current_state = State:: STOPPING;
            }
            else{
                //log_reset();
                //reset_detection_buffers(); warum?????

                release_all_lines();
                _delay_us(TURNAROUND_US);

                current_state = State:: DETECTING;
            }
            break;
        }

    //DETECTING STATE - poll children for tree information
        case State:: DETECTING:
        {
            handle_detection(); //genau so wie in cube_uart.cpp
            //ich muss den payload irgendwie global machen oder übergeben richtig?
            current_state = State:: BUILD_PAYLOAD;
            pc_reply_retry_count = 0; //is this location correct?

            break;
        }
    
    //BUILD_PAYLOAD STATE - accumulates received information from cubes to one payload 
    case State:: BUILD_PAYLOAD:
    {
        build_payload(payload, payload_len); //noch machen

        bool changed = payload_changed(payload, payload_len);

        cycles_since_last_send ++;

        if (changed || cycles_since_last_send >= HEARTBEAT_INTERVAL_CYCLE){
            current_state = State:: SEND_PAYLOAD_TO_PC; //geht das auch mit SEND_INFO_TO_PC und case feedback?
        } 
        else{
            //ccycle_wait_started_ms = millis()??????????
            current_state = State:: WAIT_NEXT_CYCLE; // waits 550ms and then restarts with state DETECTION_INIT
        }
        break;
    }

    //SEND_PAYLOAD_TO_PC STATE - send built payload to pc
    case State:: SEND_PAYLOAD_TO_PC:{
        send_payload_to_pc(payload, payload_len); 
        //remember_sent_payload??

        current_state = State:: GET_INFO_FROM_PC;
        break;
    }

    //GET_INFO_FROM_PC STATE - after the payload frame was sent
    case State:: GET_INFO_FROM_PC:
    {
        //wait for the PC reply: feedback frame, stop, or timeout
        pc_reply_t pc_reply = read_pc_reply(fb_payload, &fb_payload_len);

        switch(pc_reply){
            case PC_REPLY_STOP:
                remember_sent_payload(payload, payload_len);
                cycles_since_last_send = 0;
                current_state = State::STOPPING;
                break;
            
            case PC_REPLY_FRAME:
                 //pending_pc_result = PcResult::DONE;
                 current_state = State:: RELAY_FEEDBACK;
                 break;
            
            case PC_REPLY_TIMEOUT: //either pc sends PC_REPLY_TIMEOUT or PC_REPLY_BAD message
            case PC_REPLY_BAD:
                while (Serial.available() > 0) {   // drop any stray bytes from the bad/partial frame before retrying
                    Serial.read();
                }

                if (
                    pc_reply_retry_count <
                    MAX_PC_REPLY_RETRIES
                ) {
                    pc_reply_retry_count++;

                    current_state =
                            State::SEND_PAYLOAD_TO_PC;
                } else {
                    pending_pc_result =
                        PcResult::FAILED;

                    current_state =
                            State::SEND_RESULT_TO_PC;//?????? was mach ich da
                }
                break;
        }
        break;
    }

    //RELAY_FEEDBACK STATE - pass on feedback to cubes for led on/off oder switch 
    case State:: RELAY_FEEDBACK:
    {
        received_feedback_t received_feedback = relay_feedback_to_children(fb_payload, fb_payload_len);

        switch(received_feedback){
            case FB_DONE:
                pending_pc_result = PcResult:: DONE;
                current_state =
                    State:: SEND_RESULT_TO_PC;
                break;

            // later: vlt noch nur 1x retry -> wenn dann auch gefailed: dann SEND_INFO_TO_PC (variable number retries )
            case FB_FAILED:
                pending_pc_result = PcResult:: FAILED;
                current_state =
                    State:: SEND_RESULT_TO_PC;
                break;
        }
        break;
    }

    case State:: SEND_RESULT_TO_PC:
    {
        Serial.write(pending_pc_result == PcResult::DONE ? PC_RESP_DONE : PC_RESP_FB_FAILED);

        remember_sent_payload(payload, payload_len);
        cycles_since_last_send = 0;

        current_state = State:: WAIT_NEXT_CYCLE;
        break;
    }

   // case State:: WAIT_NEXT_CYCLE:
    case State:: WAIT_NEXT_CYCLE:
    {
        delay(550);   // pacing between detection cycles
        current_state = State:: DETECTION_INIT;
        break;
    } 

    case State:: STOPPING:
    {
        run_stop_sequence();

        current_state = State:: IDLE;
        break;
    }

}
}

// stray bytes at pc_cmd_start and pc_reply_bad
//
