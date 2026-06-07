# Communication Prototypes

This repository contains firmware prototypes for the communication between modular blocks based on the **ATtiny1616**.

The system uses a **single-wire, half-duplex, software bit-banged UART-like protocol**.  

---

## Repository Structure
The repository is organized so that every important prototype state is stored in a separate Git branch.
The idea is that every branch represents a stable development step.

### Branch	Purpose
- prototype_v0:	First basic single-wire byte transmission test - needs to be published
- prototype_v1:	First bidirectional parent-child transaction   - needs to be published 
- prototype_v2:	Orientation detection and child polling and data communcation with predefined data frame
- prototype_v3:	Transmision of real data frame with individual node ID, orientation and child mask
  ...
- main:	final prototype

### Directory structure
```text
include/
  config.h           // timing, protocol constants, limits
  wire_bus.h         // wire_t and bus function declarations

src/
  wire_bus.cpp       // reusable single-wire UART driver

firware/
  main_cube.cpp       //individual code for cubes
  main_baseplate.cpp  //individual code for baseplate

comments/
  definition          // explanations, protocol notes, prototype definitions
  comments            //questions, next steps, ...
