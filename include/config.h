// Definition of Configuration constants for the project

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
#ifndef CHILD_COUNT 
#define CHILD_COUNT              2
#endif

// ----------------------------------------------------------
//  Timing
// Timeout constants have wrong values -> need to be calculated
// ----------------------------------------------------------

#define BAUD_US             104
#define BYTE_US             (10 * BAUD_US)
#define TURNAROUND_US       (BAUD_US * 3)  //delay time for cubes between transactions (always before transmitting something)
#define CHILD_TIMEOUT_US    (6 * BAUD_US)  // allowed waiting time for ACK_BUSY after sending CMD_STATUS 
#define CMD_ACK_TIME        (2 * BYTE_US + TURNAROUND_US)

#define FAILED_ATTEMPT_US   (CHILD_RETRIES * (BYTE_US + TURNAROUND_US + 2* CHILD_TIMEOUT_US))
#define DATA_FRAME_TIME     (3 * (BYTE_US +INTER_FRAME_TIMEOUT_US) + (CUBES_AMOUNT+1) * (3 * (BYTE_US + INTER_FRAME_TIMEOUT_US)))
//cubes_amount +1 since baseplate is with its current child polling principle also a cube
#define FRAME_TIMEOUT_US    (CUBES_AMOUNT+6) * CHILD_COUNT * (((CHILD_RETRIES-1) * FAILED_ATTEMPT_US) + CMD_ACK_TIME + DATA_FRAME_TIME + TURNAROUND_US) + 10* BAUD_US      // allowed Waiting time for receiving DATA_FRAME (start of SYNC) after child finishes recursive polling
//frame timeout currently 0,65 sec
#define INTER_FRAME_TIMEOUT_US (5 * BAUD_US)    // allowed waiting time for next byte in DATA_FRAME after SYNC when child already startet sending DATA_FRAME
#define PARENT_TIMEOUT_US   CHILD_TIMEOUT_US          // timeout for parent incorrect communication/not sending bits (CMD_STATUS)
//--------------------------------------------

// needs to be calculated
#define MAX_PAYLOAD_LEN          128 // must be <256 for 1 byte LEN field, but should also be limited to avoid long transmission times and large buffers. For prototype_v3, we can set it to 128 as a reasonable limit for testing.
#define MAX_CHILD_PAYLOAD_LEN    128  
#define MAX_NODES                CHILD_COUNT * CUBES_AMOUNT//= child_count * amount of cubes +1(baseplate node)

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

#define LED_GREEN           0x01
#define LED_RED             0x02

#define CUBE_A_ID  0x10
#define CUBE_B_ID  0x11
#define CUBE_C_ID  0x12


//-----------------------------------------------------------
// FEEDBACK SYSTEM
//-----------------------------------------------------------
#define FEEDBACK_FINISHED_TIMEOUT_US 500000UL//calculaten

#define SERIAL_WRITING 0
#define SERIAL_DEBUG   0
#define SERIAL_DEBUG_END 1
#define LOG_BUF_SIZE 192 //ausrechnen 

#define GREEN_LED_PIN            PIN5_bm
#define RED_LED_PIN              PIN4_bm
#define LOG_BUF_SIZE        192 // one ASCII character uses one byte -> because of appenln: letter + \r \n = letter+3 (im durchschnitt 2 zeichen pro text) :: 192/5 = 
#if SERIAL_WRITING 
    #define SER_PRINT(x)    
    #define SER_PRINTLN(x)  
    #define SER_PRINTLN2(x,y)
#endif

#if SERIAL_DEBUG
    #define SER_PRINT(x)    Serial.print(x)
    #define SER_PRINTLN(x)  Serial.println(x)
    #define SER_PRINTLN2(x, y) Serial.println(x,y )
#endif

#if SERIAL_DEBUG_END
    #define SER_PRINT(x)    log_append(x)
    #define SER_PRINTLN(x)  log_appendln(x)
    #define SER_PRINTLN2(x, y) log_appendln(x,y )
#endif
// ----------------------------------------------------------
// Node data
// ----------------------------------------------------------

// not needed because already defined in .ini -> #define NODE_ID 0x10

#endif // CONFIG_H