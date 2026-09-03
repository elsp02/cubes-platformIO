// =====================================================================
// config.h
// - all configuration constants for the project: counts/limits, timing,
//   protocol bytes, PC communication, feedback, debug, LEDs
// - shared by both baseplate and cube (brick) firmware and also backend/learning application
//
// - not included: brick type / brick id / child count -> defined in platformio.ini,
// =====================================================================

#ifndef CONFIG_H
#define CONFIG_H

#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>

#ifndef F_CPU
#define F_CPU 20000000UL    // better to define in .ini file: build_flags = -DF_CPU=20000000UL/board_build.f_cpu = 20000000L
#endif

// ----------------------------------------------------------
// Counts / Limits
// ----------------------------------------------------------
#define CHILD_RETRIES            3     //amount of retries if polling one child didn´t work out
#define CUBES_AMOUNT             3     // amount of bricks in the system
#define MAX_CHILD_COUNT          5     // max children independent of brick type - used for timeout calculations

// ----------------------------------------------------------
//  Timing
// - all UART bit-banging timing, derived from one base bit time (BAUD_US)
// - real value calculations based on cubes_amount = 3
// ----------------------------------------------------------

#define BAUD_US             104UL           // time for 1 bit (~9600 baud); UL = 32-bit unsigned, avoids overflow in macros below (= 104 us)
#define BYTE_US             (10 * BAUD_US)  // time for 1 byte: start + 8 data + stop bit (= 1040 us / 1.04 ms)
#define TURNAROUND_US       (BAUD_US * 3)   // delay between transactions, before a cube transmits (= 312 us)
#define CHILD_TIMEOUT_US    (12 * BAUD_US)  // allowed waiting time for ACK_BUSY after sending CMD_STATUS including margin for receiver processing (= 1248 us)
#define CMD_ACK_TIME        (2 * BYTE_US + TURNAROUND_US) // time budget for a CMD + ACK exchange (= 2392 us)

#define FAILED_ATTEMPT_US   (CHILD_RETRIES * (BYTE_US + TURNAROUND_US + 2* CHILD_TIMEOUT_US)) // time for one failed child polling process attempt (=11544 us/ 11.54)
#define DATA_FRAME_TIME     (3 * (BYTE_US +INTER_FRAME_TIMEOUT_US) + (CUBES_AMOUNT+1) * (3 * (BYTE_US + INTER_FRAME_TIMEOUT_US))) // time for one child DATA_FRAME transmission (after child has sent ack previously) (= 31200 us / 31.2 ms)


#define FRAME_TIMEOUT_US    (((CUBES_AMOUNT+6) * MAX_CHILD_COUNT * (((CHILD_RETRIES-1) * FAILED_ATTEMPT_US) + CMD_ACK_TIME + DATA_FRAME_TIME + TURNAROUND_US)) + 10* BAUD_US) // allowed waiting time for receiving DATA_FRAME (start of SYNC) after child sent ACK, finished recursive polling and starts sending DATA_FRAME (= 2 565 680 us / ~2.566 s)
//frame timeout currently differs between baseplate and cubes since baseplate has just 1 child - needs to be the same for every component?

#define INTER_FRAME_TIMEOUT_US (10 * BAUD_US)    // allowed waiting time for next byte in DATA_FRAME after SYNC when child already startet sending DATA_FRAME (= 1040 us)
#define PARENT_TIMEOUT_US   CHILD_TIMEOUT_US          // timeout for a parent not responding (CMD_STATUS, CMD_FEEDBACK) (= 1248 us)
//--------------------------------------------

#define MAX_PAYLOAD_LEN          128 // must be <256 for 1 byte LEN field, but should also be limited to avoid long transmission times and large buffers. For prototype_v3, we can set it to 128 as a reasonable limit for testing.
#define MAX_CHILD_PAYLOAD_LEN    128  // max bytes in one child data frame; TODO: derive from actual max payload instead of hardcoding
// ----------------------------------------------------------
//  Protocol bytes 
// - byte protocol used between bricks, and between brick and baseplate
// ----------------------------------------------------------

#define CMD_STATUS          0xAA // parent -> child: report your status
#define ACK_BUSY            0x55 // child -> parent: received, processing
#define DATA_BYTE           0x42 // marks a data byte inside a frame
#define SYNC_BYTE           0xA5 // marks the start of a data frame

#define CMD_FEEDBACK        0xCC // parent -> child: here is feedback to relay/display
#define ACK_FINISHED        0x66 // child -> parent: feedback handled successfully
#define ACK_FAILED          0x77 // child -> parent: feedback handling failed

//-----------------------------------------------------------
// PC Communication
// - byte protocol between baseplate and the controlling PC
//------------------------------------------------------------
// ASCII on purpose so the link can be tested by hand in a serial monitor)
#define PC_CMD_START        0x53 // 'S' PC -> baseplate: start detection
#define PC_CMD_STOP         0x58 // 'X' PC -> baseplate: stop sequence (all LEDs off), back to idle
#define PC_RESP_DONE        0x44 // 'D' baseplate -> PC: feedback frame relayed, every cube confirmed
#define PC_RESP_FB_FAILED   0x4E // 'N' baseplate -> PC: bad frame from PC or a cube failed to confirm

#define PC_REPLY_TIMEOUT_MS      2000UL // how long the baseplate waits for the PC to reply (first byte) (2000us)
#define PC_FRAME_BYTE_TIMEOUT_MS 100UL  // max gap between bytes within the PC feedback frame (100us)

//-----------------------------------------------------------
// FEEDBACK SYSTEM
//-----------------------------------------------------------
// for feedback frame
#define FB_ITEM_LEN         2 // every cube feedback is [NODE_ID, LED_STATE]
#define FB_MAX_PAYLOAD_LEN  (CUBES_AMOUNT * FB_ITEM_LEN) // total feedback payload for all cubes
#define MAX_PC_REPLY_RETRIES 2 // retries if the PC reply after feedback is invalid

// One feedback hop (parent -> one child, excluding the child's own downstream relaying):
//   CMD_FEEDBACK + ACK_BUSY + ACK_FINISHED  = 3 bytes
//   feedback frame SYNC + LEN + payload + checksum = FB_MAX_PAYLOAD_LEN + 3 bytes
//   plus ACK_BUSY wait and the turnarounds between direction changes
#define FB_HOP_US (((FB_MAX_PAYLOAD_LEN + 6) * BYTE_US) + (3 * TURNAROUND_US) + CHILD_TIMEOUT_US) // (= 14664 us / 14.664 ms)

// Worst case until ACK_FINISHED arrives: every cube below this port relays the frame sequentially, one hop per cube.
// Factor 2 = safety margin for loop overhead and deaf windows (log flushing).
#define FEEDBACK_FINISHED_TIMEOUT_US (2 * CUBES_AMOUNT * FB_HOP_US) // (= 87984 us / ~88 ms for 3 cubes)

//-----------------------------------------------------------
// DEBUGGING SYSTEM (only embedded in uart_baseplate_state_machine_debug env)
// - switches for where SER_PRINT/SER_PRINTLN output goes
//-----------------------------------------------------------
#define SERIAL_WRITING 1
#define SERIAL_DEBUG   0
#define SERIAL_DEBUG_END 0

//for debugging feedback
#define LOG_BUF_SIZE        192 // one ASCII character uses one byte -> because of appenln: letter + \r \n = letter+3 (im durchschnitt 2 zeichen pro text) :: 192/5 =

// for debugging or serial communication
#if SERIAL_WRITING
    #define SER_PRINT(x)  
    #define SER_PRINTLN(x) 
    #define SER_PRINTLN2(x, y)
#elif SERIAL_DEBUG
    #define SER_PRINT(x)    Serial.print(x)
    #define SER_PRINTLN(x)  Serial.println(x)
    #define SER_PRINTLN2(x, y) Serial.println(x, y)
#elif SERIAL_DEBUG_END
    #define SER_PRINT(x)    log_append(x)
    #define SER_PRINTLN(x)  log_appendln(x)
    #define SER_PRINTLN2(x, y) log_appendln(x, y)
#else
    #define SER_PRINT(x)
    #define SER_PRINTLN(x)
    #define SER_PRINTLN2(x, y)
#endif

// for predefined tree comparing and feedback sequence in baseplate_state_machine_debug environment
#define CUBE_A_ID  0x10
#define CUBE_B_ID  0x11
#define CUBE_C_ID  0x12

//-----------------------------------------------------------
// LED CONFIGURATION 
// - pin mapping and feedback-frame LED codes
//-----------------------------------------------------------
#define GREEN_LED_PIN            PIN5_bm // pin bitmask for the green LED
#define RED_LED_PIN              PIN4_bm // pin bitmask for the red LED

// contained in FEEDBACK_FRAME - which LED to turn on
#define LED_GREEN           0x01
#define LED_RED             0x02

#endif // CONFIG_H