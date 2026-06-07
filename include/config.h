// Define configuration constants for the project
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
//  Timing
// Timeout constants have wrong values -> need to be calculated
// ----------------------------------------------------------

#define BAUD_US             104
#define TURNAROUND_US       (BAUD_US * 3)  //delay time for cubes between transactions (always before transmitting something)
#define CHILD_TIMEOUT_US    15000          // timeout for own child incorrect communication/not answering (ACK_BUSY)
#define PARENT_TIMEOUT_US   15000          // timeout for parent incorrect communication/not sending bits (CMD_STATUS)
#define FRAME_TIMEOUT_US    15000      //timeout for own child incorrect communication/sending bits (DATA FRAME) 

// ----------------------------------------------------------
// Counts / Limits
// ----------------------------------------------------------
#define CHILD_COUNT              2     //amount of children of cube
#define CHILD_RETRIES            3     //amount of retries if polling one child didn´t work out
#define UPSTREAM_FAIL_LIMIT      3     //currently not in use

// ???????????
#define NODE_HEADER_LEN          3     //currently not in use
// notiz an mich: macht so nicht so viel sinn, weil letztes child in upstream reihe ja eigentliche alle payloads von allen anderen bekommt -> child payload lenght kann nicht einfach so mit max_length durch anzahl kinder berechnet werden 
#define MAX_PAYLOAD_LEN          128 // must be <256 for 1 byte LEN field, but should also be limited to avoid long transmission times and large buffers. For prototype_v3, we can set it to 128 as a reasonable limit for testing.
#define MAX_CHILD_PAYLOAD_LEN    128  //I don´t need this 

// ----------------------------------------------------------
//  Protocol bytes
// ----------------------------------------------------------

#define CMD_STATUS          0xAA
#define ACK_BUSY            0x55
#define DATA_BYTE           0x42
#define SYNC_BYTE           0xA5

// ----------------------------------------------------------
// Node data
// ----------------------------------------------------------

// not needed because already defined in .ini -> #define NODE_ID             0x10

#endif // CONFIG_H