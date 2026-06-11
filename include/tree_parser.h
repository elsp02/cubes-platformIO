#ifndef TREE_PARSER_H
#define TREE_PARSER_H

#include <Arduino.h>
#include <stdint.h>
#include "config.h"

//
struct Node {
    uint8_t node_id;
    uint8_t orientation;
    uint8_t child_mask;
    int8_t children[CHILD_COUNT];   // -1 = no child at this port
};

// Global parser storage, defined in parser.cpp
extern Node deserialized_nodes_array[MAX_NODES];
extern uint8_t node_count;

int8_t parse_node(
    const uint8_t *ordered_payload,
    uint8_t ordered_payload_len,
    uint8_t *payload_read_index  
);

void print_tree(
    int8_t current_node_storage_index,
    uint8_t depth
);

#endif