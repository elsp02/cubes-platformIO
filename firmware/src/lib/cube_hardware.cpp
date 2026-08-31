#include "cube_hardware.h"

#include "config.h"
#include "cube_identity.h"

static const wire_t upstream[] = {
    { &PORTA, PIN1_bm, 1 },     // PA1 — orientation 0
    { &PORTA, PIN2_bm, 2 },     // PA2 — orientation 1
    { &PORTA, PIN6_bm, 6 },     // PA6 — orientation 2
    { &PORTA, PIN7_bm, 7 },     // PA7 — orientation 3
};

#if defined(CUBE_TYPE_NORMAL)

static const wire_t child_0 = { &PORTC, PIN3_bm, 3 };  // PCB Port Out1
static const wire_t child_1 = { &PORTA, PIN3_bm, 3 };  // PCB Port Out2
static const wire_t child_2 = { &PORTA, PIN4_bm, 4 };  // PCB Port Out3
static const wire_t child_3 = { &PORTA, PIN5_bm, 5 };  // PCB Port Out4
static const wire_t child_4 = { &PORTB, PIN1_bm, 1 };  // PCB Port Out5

static const wire_t *children[CHILD_COUNT] = {
    &child_0,
    &child_1,
    &child_2,
    &child_3,
    &child_4,
};

#elif defined(CUBE_TYPE_SMASHED)
static const wire_t child_0 = { &PORTC, PIN3_bm, 3 }; //PCB Port Out1

const wire_t *const children[] = {
    &child_0
};

#elif defined(CUBE_TYPE_PYRAMID)
static const wire_t child_0 = { &PORTC, PIN3_bm, 3 }; //PCB Port Out1
static const wire_t child_1 = { &PORTB, PIN1_bm, 1 }; //PCB Port Out2

const wire_t *const children[] = {
    &child_0,
    &child_1,
};

#endif

//ACHTUNG: CHILD_COUNT zu child_count umschreiben bzw hier anders definieren
//wird das grad benutzt?
const uint8_t child_count =
    sizeof(children) / sizeof(children[0]);




