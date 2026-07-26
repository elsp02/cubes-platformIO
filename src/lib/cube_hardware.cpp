#include "cube_hardware.h"
#include "config.h"

#if defined(CUBE_TYPE_NORMALE)

static const wire_t child_0 = { &PORTB, PIN0_bm, 0 };  // PB0 — child port 0
static const wire_t child_1 = { &PORTB, PIN1_bm, 1 };  // PB1 — child port 1
static const wire_t child_2 = { &PORTC, PIN0_bm, 1 };  // PC0 — child port 2
static const wire_t child_3 = { &PORTC, PIN1_bm, 1 };  // PC1 — child port 3
static const wire_t child_4 = { &PORTC, PIN2_bm, 1 };  // PC2 — child port 4

static const wire_t *children[CHILD_COUNT] = {
    &child_0,
    &child_1,
    &child_2,
    &child_3,
    &child_4,
};

#elif defined(CUBE_TYPE_SMASHED)
static const wire_t child_0 = { &PORTA, PIN6_bm, 0 };

const wire_t *const children[] = {
    &child_0
};

#elif defined(CUBE_TYPE_PYRAMID)
static const wire_t child_0 = { &PORTC, PIN0_bm, 0 };
static const wire_t child_1 = { &PORTC, PIN1_bm, 1 };

const wire_t *const children[] = {
    &child_0,
    &child_1,
};

#endif

//ACHTUNG: CHILD_COUNT zu child_count umschreiben bzw hier anders definieren
const uint8_t child_count =
    sizeof(children) / sizeof(children[0]);