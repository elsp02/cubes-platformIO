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

//auslagern in wire_bus.cpp
static void release_all_lines(void){
    for (uint8_t line = 0; line < CHILD_COUNT; line ++){
        wire_release(children[line]);
    }
}

//auslagern in feedback - zusammen mit cube handle feedback
// relay one feedback frame to every port that had a child this cycle,
// with the same retry pattern as the detection polling.
// Returns true if every present child confirmed.
static bool relay_feedback_to_children(
    const uint8_t *fb_payload,
    uint8_t fb_payload_len
)
{
    bool feedback_done[CHILD_COUNT] = { false };
    bool all_done = true;

    for (uint8_t attempt = 0; attempt < CHILD_RETRIES; attempt++) {
        bool retry_needed = false;
        all_done = true;

        for (uint8_t child = 0; child < CHILD_COUNT; child++) {

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

    return all_done;
}

// stop sequence: every cube turns its LED off when its ID is missing
// from the feedback payload, so an EMPTY frame switches all LEDs off
static void run_stop_sequence(void)
{
    static const uint8_t empty_payload[1] = { 0 };  // never read at len 0

    relay_feedback_to_children(empty_payload, 0);
    detection_running = false;
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
    WAIT_NEXT_CYCLE,
    STOPPING
};

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
                cycles_since_last_send = HEARTBEAT_INTERVAL_CYCLE; //damit sicher dasd erste payload an den pc geschickt wird
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
            current_state = State:: WAIT_NEXT_CYCLE;
        }
        break;
    }

    //SEND_PAYLOAD_TO_PC STATE - send built payload to pc
    case State:: SEND_PAYLOAD_TO_PC:{
        send_payload_to_pc(payload, payload_len); //wie kann ich das von build_payload als parameter mitgeben?

        current_state = State:: GET_INFO_FROM_PC;
        break;
    }

    //GET_INFO_FROM_PC STATE - after the payload frame was sent
    case State:: GET_INFO_FROM_PC:
    {
        //wait for the PC reply: feedback frame, stop, or timeout
        uint8_t fb_payload[MAX_PAYLOAD_LEN];   // MAX_PAYLOAD_LEN, not FB_MAX_PAYLOAD_LEN:
                                               // an unexpected extra cube makes the payload longer
        uint8_t fb_payload_len = 0;
        pc_reply_t pc_reply = read_pc_reply(fb_payload, &fb_payload_len);

        switch(pc_reply){
            case PC_REPLY_STOP:
                current_state = State::STOPPING;
                break;
            
            case PC_REPLY_FRAME:
             //pc_reply_retry_count = 0; ??
                 current_state = State:: RELAY_FEEDBACK;
                 break;
            
            case (PC_REPLY_BAD || PC_REPLY_TIMEOUT): //???
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
    }

    //RELAY_FEEDBACK STATE - pass on feedback to cubes for led on/off
    case State:: RELAY_FEEDBACK:
    

}





}

