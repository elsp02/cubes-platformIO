#include <Arduino.h>
#include <tinyNeoPixel_Static.h>

constexpr uint8_t LED_DATA_PIN = PIN_PB5;
constexpr uint8_t LED_COUNT = 1;

uint8_t pixelBuffer[LED_COUNT * 3] = {0};

tinyNeoPixel led(
    LED_COUNT,
    LED_DATA_PIN,
    NEO_RGB + NEO_KHZ800,
    pixelBuffer
);

void setup()
{
    pinMode(LED_DATA_PIN, OUTPUT);
    digitalWrite(LED_DATA_PIN, LOW);

    // LED benötigt mindestens 200 µs LOW als Reset
    delay(10);
}

void loop()
{
    led.setPixelColor(0, 40, 0, 0);   // Rot
    led.show();
    delay(1000);

    //led.setPixelColor(0, 0, 40, 0);   // Grün
    //led.show();
    //delay(1000);
//
    //led.setPixelColor(0, 0, 0, 40);   // Blau
    //led.show();
    //delay(1000);
}