// Define configuration constants for the project
#ifndef CONFIG_H
#define CONFIG_H

#include <Arduino.h>
#include <avr/io.h>
#include <stdint.h>
#include <stdbool.h>

#ifndef F_CPU
#define F_CPU 20000000UL
#endif

// ----------------------------------------------------------
//  Timing
// ----------------------------------------------------------

#define BAUD_US             104
#define TURNAROUND_US       (BAUD_US * 3)
#define CHILD_TIMEOUT_US    15000
#define PARENT_TIMEOUT_US   15000

// ----------------------------------------------------------
// Counts / Limits
// ----------------------------------------------------------
#define CHILD_COUNT              2
#define CHILD_RETRIES            3
#define UPSTREAM_FAIL_LIMIT      3

// ----------------------------------------------------------
//  Protocol bytes
// ----------------------------------------------------------

#define CMD_STATUS          0xAA
#define ACK_BUSY            0x55
#define DATA_BYTE           0x42

#endif // CONFIG_H