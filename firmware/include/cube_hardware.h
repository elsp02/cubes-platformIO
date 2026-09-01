// brick child ports und anzahl je nach brick type 
//// nicht vorhanden in code_improved

//#include "config.h"
#include "wire_bus.h"

#include <stdint.h>

extern const wire_t const upstream[];
extern const int upstream_count;

// Child-Ports des ausgewählten Cube-Typs
extern const wire_t *const children[];

// Anzahl der Child-Ports
extern const uint8_t child_count;

void release_all_lines(void);