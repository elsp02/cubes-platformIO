// =====================================================================
// led_test.cpp
// - standalone test firmware for the Würth RGB LED on PB5 (single
//   addressable NeoPixel-type LED)
// - cycles through R/G/B one at a time to check the actual color order,
//   since the schematic's wiring is currently suspected to be wrong
//   (see hardware.md)
// - build_src_filter of env:led_test in platformio.ini
// =====================================================================

#include <Arduino.h>
#include <tinyNeoPixel_Static.h>

constexpr uint8_t LED_DATA_PIN = PIN_PB5;
constexpr uint8_t LED_COUNT = 1;

uint8_t pixelBuffer[LED_COUNT * 3] = {0}; // raw GRB byte buffer used by tinyNeoPixel

tinyNeoPixel led(
    LED_COUNT,
    LED_DATA_PIN,
    NEO_RGB + NEO_KHZ800,
    pixelBuffer
);

// setup
// - drives the data line low before the first frame, as required by the LED's reset timing
void setup()
{
    pinMode(LED_DATA_PIN, OUTPUT);
    digitalWrite(LED_DATA_PIN, LOW);

    // LED needs at least 200 us LOW as reset; 10 ms is a safe margin
    delay(10);
}

// loop
// - shows one color for 1 s at a time; uncomment the other two blocks
//   below to check them as well
void loop()
{
    led.setPixelColor(0, 40, 0, 0);   // Rot
    led.show();
    delay(1000);

    led.setPixelColor(0, 0, 40, 0);   // Grün
    led.show();
    delay(1000);

    led.setPixelColor(0, 0, 0, 40);   // Blau
    led.show();
    delay(1000);
}