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
#include "tree_parser.h"

//---------------------------------------------------------------


Node deserialized_nodes_array[MAX_NODES];              //fixed-size global array
uint8_t node_count = 0;             // tells how many node slots of array are already used

// parser = descent recursive parser (=deserialization) for the preorder serialized n-ary tree payload
    // ------------------------------------------------------------
    // deserialized output of parser
    //children nodes of node 1:
    //nodes[0] = Node 0xXX
    //  nodes[0].children[0] = 1   // Child at port 0 is stored in nodes[1]
    //  nodes[0].children[1] = 2   // 
    //  nodes[0].children[2] = -1  // no child at port 2

    //nodes[1].children[1] = 3   //child at port 1 is stored in nodes[3]

    //visualized structure:
    //nodes[0] Node 0xXX
    //├── port 0: nodes[1]
    //├── port 1: nodes[3]
    //│   └── port 1: nodes[4]
    //└── port 2: -1/None (no child at port2)
    // ------------------------------------------------------------
   
    //Indices
    // payload_read_index = point to the current position inside the serialized paylaod array and moves forward through the serialized byte stream  
    // node_count = how many nodes have been already stored in the deserialized node array + points to the next free node slot
    // current_node_storage_index = tells where the specific node is stored in nodes[] -> gives node in nodes[] an index e.g nodes[0]
    // child_index = current_node_storage_index
    // after Node 1 header:
        // index = 3        // next unread byte is byte 3 in serialized oayload array
        // node_count = 1   // one node has been created in nodes[]
        // current_index = 0 // current node is nodes[0]

int8_t parse_node(const uint8_t *ordered_payload, uint8_t ordered_payload_len, uint8_t *payload_read_index)
{
    // Basic safety: are there at least 3 unread bytes left? (valid node needs at least 3 bytes -> id, ori, child_mask)
    if (*payload_read_index + 3 > ordered_payload_len) {
        return -1;
    }

    // Basic safety: still enough node slots in array left?
    if (node_count >= MAX_NODES) {
        return -1;
    }

    // Create new node in global node array (which stores the deserialized payload array)
    int8_t current_node_storage_index = node_count;    // stores array index where current node will be placed
    Node *current_node = &deserialized_nodes_array[node_count];      //creates a pointer named node that points to the current free slot [current_count] in the nodes[] array.
    node_count++;

    // Read current node header and increment index to 1 
    current_node->node_id = ordered_payload[(*payload_read_index)++];
    current_node->orientation = ordered_payload[(*payload_read_index)++];
    current_node->child_mask = ordered_payload[(*payload_read_index)++];

    // Initialize all child ports as empty
    for (uint8_t i = 0; i < CHILD_COUNT; i++) {
        current_node->children[i] = -1;
    }

    // Recursively parse child subtrees
    for (uint8_t port = 0; port < CHILD_COUNT; port++) {  //loops through all possible child ports
        if (current_node->child_mask & (1 << port)) {   //if childmask is 1 at this bit (bitmask) -> child is attached at this port/side -> Node; otherwise -1
            int8_t child_index = parse_node(ordered_payload, ordered_payload_len, payload_read_index);  //recursive call, in child_index = returned current_index -> tells in which node[x] child node is stored 

            //check if a child fails to parse even though the child_mask said there should be a child
            if (child_index < 0) {
            return -1;
            }
            current_node->children[port] = child_index;  //stores the parsed child index in the correct port slot -> node->children[0] = child_index (index of node[x] where childs nod eis stored);
        }
    }

    return current_node_storage_index;
}
//----------------------------------------------------------
// Print Tree
//----------------------------------------------------------
void print_tree(int8_t current_node_storage_index, uint8_t depth)
{
    if (current_node_storage_index < 0) {
        return;
    }

    Node *node = &deserialized_nodes_array[current_node_storage_index];

    // Indentation depending on depth
    for (uint8_t i = 0; i < depth; i++) {
        Serial.print("  ");
    }

    Serial.print("Node ");
    Serial.print(node->node_id);

    Serial.print("  orientation=");
    Serial.print(node->orientation);

    Serial.print("  child_mask=0b");
    Serial.println(node->child_mask, BIN);

    for (uint8_t port = 0; port < CHILD_COUNT; port++) {
        int8_t child_index = node->children[port];

        for (uint8_t i = 0; i < depth + 1; i++) {
            Serial.print("  ");
        }

        Serial.print("port ");
        Serial.print(port);
        Serial.print(": ");

        if (child_index < 0) {
            Serial.println("None");
        } else {
            Serial.println();
            print_tree(child_index, depth + 2); //recursive call for printing
        }
    }
}