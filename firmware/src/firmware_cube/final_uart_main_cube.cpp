// benötigte header files: 
// config.h -> für die ganzen constanten konfigurationen
// cube_hardware.h -> für upstream ports, child ports je nach type und child_count (noch richtig machen)
// cube_identity.h -> für brick types (in environment uart_cube bestimmt)
// feedback_cube.h -> für prüfen ob eigene ID in feedback payload integriert ist
// feedback.h -> für feedback weiter an bricks senden
// poll_child.h -> für child polling
// serial_writing.h -> für debug end (entscheiden ob ich das benutze)
// wire_bus.h -> für bus definitionen

//-----------------------------------------------
// Erklärung
//-----------------------------------------------

#include <Arduino.h>
#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>
#include <stdbool.h>

#include "config.h"
#include "wire_bus.h"
#include "serial_writing.h"
#include "poll_child.h"
#include "feedback.h"
