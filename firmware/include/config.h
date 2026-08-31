// Definition of Configuration constants for the project
// included: child counts and limits, timing definitions, protocol bytes, pc communication, feedback constants, debug constants, led konfiguration
/// sowohl für baseplate als auch für bricks
//// sollte passen alles 

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
// defined in .ini #define CHILD_COUNT              2     //amount of children of cube
#define CHILD_RETRIES            3     //amount of retries if polling one child didn´t work out
#define UPSTREAM_FAIL_LIMIT      3     //currently not in use
#define CUBES_AMOUNT             3
#define MAX_CHILD_COUNT          5     //for final timeout calculations,  when every type has a different amount of children 
#ifndef CHILD_COUNT 
    #define CHILD_COUNT              2
#endif

// ----------------------------------------------------------
//  Timing
// ----------------------------------------------------------

#define BAUD_US             104UL //Unsigned Long suffix with fix 32bit witdh - um überlaufen zu verhindern (keine minus zahlen)
#define BYTE_US             (10 * BAUD_US)
#define TURNAROUND_US       (BAUD_US * 3)  //delay time for cubes between transactions (always before transmitting something)
#define CHILD_TIMEOUT_US    (12 * BAUD_US)  // allowed waiting time for ACK_BUSY after sending CMD_STATUS including margin for receiver processing
#define CMD_ACK_TIME        (2 * BYTE_US + TURNAROUND_US)

#define FAILED_ATTEMPT_US   (CHILD_RETRIES * (BYTE_US + TURNAROUND_US + 2* CHILD_TIMEOUT_US)) // for one failed child polling process
#define DATA_FRAME_TIME     (3 * (BYTE_US +INTER_FRAME_TIMEOUT_US) + (CUBES_AMOUNT+1) * (3 * (BYTE_US + INTER_FRAME_TIMEOUT_US))) // time for one child data frame transmission (when child has sent ack previously)

//cubes_amount +1 since baseplate is with its current child polling principle also a cube, and + 5 for margin
#define FRAME_TIMEOUT_US    (((CUBES_AMOUNT+6) * MAX_CHILD_COUNT * (((CHILD_RETRIES-1) * FAILED_ATTEMPT_US) + CMD_ACK_TIME + DATA_FRAME_TIME + TURNAROUND_US)) + 10* BAUD_US)      // allowed waiting time for receiving DATA_FRAME (start of SYNC) after child sent ACK, finished recursive polling and starts sending DATA_FRAME
//frame timeout currently differs between baseplate and cubes since baseplate has just 1 child - needs to be the same for every component?

#define INTER_FRAME_TIMEOUT_US (10 * BAUD_US)    // allowed waiting time for next byte in DATA_FRAME after SYNC when child already startet sending DATA_FRAME
#define PARENT_TIMEOUT_US   CHILD_TIMEOUT_US          // timeout for parent incorrect communication/not sending bits (CMD_STATUS, CMD_FEEDBACK)
//--------------------------------------------

// needs to be calculated
#define MAX_PAYLOAD_LEN          128 // must be <256 for 1 byte LEN field, but should also be limited to avoid long transmission times and large buffers. For prototype_v3, we can set it to 128 as a reasonable limit for testing.
#define MAX_CHILD_PAYLOAD_LEN    128  
#define MAX_NODES                MAX_CHILD_COUNT * CUBES_AMOUNT//= child_count * amount of cubes +1(baseplate node)

// ----------------------------------------------------------
//  Protocol bytes
// ----------------------------------------------------------

#define CMD_STATUS          0xAA
#define ACK_BUSY            0x55
#define DATA_BYTE           0x42
#define SYNC_BYTE           0xA5

#define CMD_FEEDBACK        0xCC
#define ACK_FINISHED        0x66
#define ACK_FAILED          0x77

//-----------------------------------------------------------
// PC Communication
//------------------------------------------------------------
// ASCII on purpose so the link can be tested by hand in a serial monitor)
#define PC_CMD_START        0x53 // 'S' PC -> baseplate: start detection
#define PC_CMD_STOP         0x58 // 'X' PC -> baseplate: stop sequence (all LEDs off), back to idle
#define PC_RESP_DONE        0x44 // 'D' baseplate -> PC: feedback frame relayed, every cube confirmed
#define PC_RESP_FB_FAILED   0x4E // 'N' baseplate -> PC: bad frame from PC or a cube failed to confirm

#define PC_REPLY_TIMEOUT_MS      2000UL // how long the baseplate waits for the PC reply (first byte)
#define PC_FRAME_BYTE_TIMEOUT_MS 100UL  // max gap between bytes inside the PC feedback frame

//-----------------------------------------------------------
// FEEDBACK SYSTEM
//-----------------------------------------------------------
// for feedback frame
#define FB_ITEM_LEN         2 // every cube feedback is [NODE_ID LED_STATE]
#define FB_MAX_PAYLOAD_LEN  (CUBES_AMOUNT * FB_ITEM_LEN)

// One feedback hop (parent -> one child, excluding the child's own
// downstream relaying):
//   CMD_FEEDBACK + ACK_BUSY + ACK_FINISHED  = 3 bytes
//   feedback frame SYNC + LEN + payload + checksum = FB_MAX_PAYLOAD_LEN + 3 bytes
//   plus ACK_BUSY wait and the turnarounds between direction changes
#define FB_HOP_US (((FB_MAX_PAYLOAD_LEN + 6) * BYTE_US) + (3 * TURNAROUND_US) + CHILD_TIMEOUT_US)

// Worst case until ACK_FINISHED arrives: every cube below this port
// relays the frame sequentially, one hop per cube. Factor 2 = safety margin for loop overhead and deaf windows (log flushing). (ca 88 ms. für 3 cubes)
#define FEEDBACK_FINISHED_TIMEOUT_US (2 * CUBES_AMOUNT * FB_HOP_US)


// for predefined tree comparing and feedback sequence in baseplate_feedback2 file (baseplate environment)
#define CUBE_A_ID  0x10
#define CUBE_B_ID  0x11
#define CUBE_C_ID  0x12
//-----------------------------------------------------------
// DEBUGGING SYSTEM (only embedded in main_baseplate_feedback2.cpp)
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

//-----------------------------------------------------------
// LED KONFIGURATION 
//-----------------------------------------------------------
#define GREEN_LED_PIN            PIN5_bm
#define RED_LED_PIN              PIN4_bm

// in feedback frame - which LED to turn on
#define LED_GREEN           0x01
#define LED_RED             0x02

#endif // CONFIG_H