#include <Arduino.h>
#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"
#include "tree_parser.h"

void test_parser()
{ 

uint8_t ordered_payload[] ={
    0xA1, 0x00, 0b00000011,   // Node 0xA1: children at port 0 and port 1

    0xB2, 0x01, 0b0000010,   // Node 0xB2: child at port 2
    0xD4, 0x03, 0b00000000,   // Node 0xD4: no children

    0xC3, 0x02, 0b00000001,   // Node 0xC3: child at port 0
    0xE5, 0x01, 0b00000000    // Node 0xE5: no children
};

uint8_t ordered_payload_len = sizeof(ordered_payload);

//----------------------------------------
  
    uint8_t payload_read_index = 0;
    
    node_count = 0;

    int8_t root_node_storage_index = parse_node(ordered_payload, ordered_payload_len, &payload_read_index);

    // failed safety checks 
    if (root_node_storage_index < 0){
        Serial.println("parser error");
        return;
    }

    //check if the final payload_read_index is the same as payload_len to see if parser consumed all bytes from ordered_payload
    if (payload_read_index != ordered_payload_len){

        print_tree(root_node_storage_index,0);
        Serial.println("unused payload bytes left");
        return;
    }

    Serial.println("tree parsed sucessfully");

    //prints deserialized tree
    print_tree(root_node_storage_index,0); 
}

void setup()
{
    Serial.begin(9600);
    delay(1000);

    Serial.println("parser test startet");

    
}

void loop()
{
    test_parser();
    delay(1000);
}

