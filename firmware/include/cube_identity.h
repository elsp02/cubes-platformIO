// =====================================================================
// cube_identity.h
// - builds this brick's NODE_ID from its cube type and instance number
// - CUBE_TYPE_* and CUBE_INSTANCE are set as build flags in platformio.ini
// - not used for CUBE_TYPE_BASEPLATE -> has no NODE_ID
// =====================================================================

#ifndef CUBE_IDENTITIY_H
#define CUBE_IDENTITIY_H

#include <stdint.h>

//-------------------------------------------------------
// Cube type definition and instance generation
// NODE_ID: 
// Bits 7..5 = Cube-Type (for tree comparison)
// Bits 4..0 = Instance number
//-------------------------------------------------------
constexpr uint8_t TYPE_SHIFT   = 5; // bit offset of the type field
constexpr uint8_t INSTANCE_MASK = 0x1F; // mask for the 5-bit instance field

#if !defined(CUBE_TYPE_BASEPLATE)
    #if defined(CUBE_TYPE_NORMAL)
    constexpr uint8_t CUBE_TYPE = 0x00;

    #elif defined(CUBE_TYPE_SMASHED)
        constexpr uint8_t CUBE_TYPE = 0x01;

    #elif defined(CUBE_TYPE_PYRAMID)
        constexpr uint8_t CUBE_TYPE = 0x02;

    #else
        #error "No cube variant selected"
    #endif

    #ifndef CUBE_INSTANCE
        #error "No cube instance selected"
    #endif

    // creates NODE_ID = (CUBE_TYPE << TYPE_SHIFT) | (CUBE_INSTANCE & INSTANCE_MASK)
    constexpr uint8_t NODE_ID =
        static_cast<uint8_t>(
            (CUBE_TYPE << TYPE_SHIFT) |
            (CUBE_INSTANCE & INSTANCE_MASK)
        );
    #endif
#endif
