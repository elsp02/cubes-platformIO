// ============================================================
// Prototype v3_2 - parser 
// descent recursive parser (=deserialization) for a preorder serialized n-ary tree
// ATtiny1616
//
// PlatformIO structure:
//   include/config.h
//   include/wire_bus.h
//   src/wire_bus.cpp
//   src/main.cpp
// ============================================================

#include <Arduino.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"

//in wire_bus.h
struct Node {
    uint8_t node_id;
    uint8_t orientation;
    uint8_t child_mask;
    int8_t children[CHILD_COUNT];   // -1 = no child at this port
};

Node nodes[MAX_NODES];              //fixed-size global array
uint8_t node_count = 0;             // tells how many node slots of array are already used


// ------------------------------------------------------------
//children nodes of node 1:
//nodes[0].children[0] = 1   // Node 1 has Node 2 at port 0
//nodes[0].children[1] = 2   // Node 1 has Node 3 at port 1
//nodes[0].children[2] = -1  // no child at port 2

//nodes[2].children[1] = 3   // Node 3 (child of node 1 at port 0) has Node 4 at port 1

//visualized structure:
//Node 1
//├── port 0: Node 2
//├── port 1: Node 3
//│   └── port 1: Node 4
//└── port 2: -1/None (no child at port2)
// ------------------------------------------------------------
int8_t parse_node(const uint8_t *ordered_payload, uint8_t ordered_payload_len, uint8_t *index)
{
    // Basic safety: are there at least 3 unread bytes left? (valid node needs at least 3 bytes -> id, ori, child_mask)
    if (*index + 3 > ordered_payload_len) {
        return -1;
    }

    // Basic safety: still enough node slots in array left?
    if (node_count >= MAX_NODES) {
        return -1;
    }

    // Create new node in global node array
    int8_t current_index = node_count;    // stores array index where current node will be placed
    Node *node = &nodes[node_count];      //creates a pointer named node that points to the current free slot [current_count] in the nodes[] array.
    node_count++;

    // Read current node header and increment index to 1 
    node->node_id = ordered_payload[(*index)++];
    node->orientation = ordered_payload[(*index)++];
    node->child_mask = ordered_payload[(*index)++];

    // Initialize all child ports as empty
    for (uint8_t i = 0; i < CHILD_COUNT; i++) {
        node->children[i] = -1;
    }

    // Recursively parse child subtrees
    for (uint8_t port = 0; port < CHILD_COUNT; port++) {  //loops through all possible child ports
        if (node->child_mask & (1 << port)) {   //if childmask is 1 at this bit (bitmask) -> child is attached at this port/side -> Node; otherwise -1
            int8_t child_index = parse_node(ordered_payload, ordered_payload_len, index);  //recursive call

            node->children[port] = child_index;  //stores the parsed child index in the correct port slot
        }
    }

    return current_index;
}