# Hardware Description
erklärung wie module physisch verbunden sind
## Microcontroller
- each cube contains an ATtiny1616
- Baseplate contains a gateway/controller (pico?) as an interface between the cubes and the hardware auf dem cubes visualiziert werden -> VERBESSERN!

## Pin Assignment
- upstream orienttion pins
- downstream child port pins
- feedback pins

**TABELLE**

| Pin | Function |
|-----|----------|
| PA1 | Upstream orientation 0 |
| PA3 | Upstream orientation 1 |
| PA4 | Upstream orientation 2 |
| PA5 | Upstream orientation 3 |
| PB0 | Child port 0 |
| PB1 | Child port 1 |
| PB4 | Debug LED |

## Electrical Principle
single wire, half duplex open drain pull up -> vlt hier nrz bla bla
