// feedback funktionen für bricks
/// nur für bricks

#include <stdint.h> // defines fixed-width integer types and limits in C

// ----------------------------------------------------------
// brick checks if own ID is integrated in payload
// ----------------------------------------------------------

bool feedback_contains_own_id(const uint8_t *payload, uint8_t len);

