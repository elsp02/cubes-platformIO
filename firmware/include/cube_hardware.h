// =====================================================================
// cube_hardware.h
// - declares the upstream (orientation) and child (downstream) wire
//   ports for the currently selected brick type
// - actual port/pin assignment and port counts are defined in
//   cube_hardware.cpp, selected via the CUBE_TYPE_* build flag
// =====================================================================
#include "wire_bus.h"

#include <stdint.h>

extern const wire_t upstream[];        // orientation-detection ports (docking face)
extern const int upstream_count;       // number of entries in upstream[]

extern const wire_t *const children[]; // downstream child ports (receiving face(s))
extern const uint8_t child_count;      // number of entries in children[]

void release_all_lines(void); // releases every upstream and child line (idle/HIGH)