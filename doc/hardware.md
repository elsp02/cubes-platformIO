# Hardware Description
erklärung wie module physisch verbunden sind -> alles physischen und elektrischen Aufbau erklärt.
## ToDos
- [ ] block diagramm cube
- [ ] alles was nach der datensammlung passiert - visualisierung, verbindung zu ipad etc

---

## Hardware Overview

The system consists of a baseplate and multiple cube modules. Each cube as well as the baseplate contains a microcontroller and provides electrical interfaces for communication and power distribution. 

---

## Microcontroller
### Cube
Each cube contains an ATtiny1616 microcontroller, which is responsible for: 
???

- each cube contains an ATtiny1616
- Baseplate contains a gateway/controller (pico?) as an interface between the cubes and the hardware auf dem cubes visualiziert werden -> VERBESSERN!
### Baseplate
---

## Pin Assignment
each cube uses four upstream orientation/data lines/GPIOs (befindet sich an der upstream seite) and (5) n-1 downstream child data lines/GPIOs (jeweils ein pin auf jeder downstream seite) as well as one GPIO for the feedback LED 
&rarr; erklärung was es mit orientation data lines und child data lines aufsich hat?
(for simplicity, the current prototype implements just two downstream child ports)

| Pin | Function | Description |
|-----|----------|-------------|
| PA1 | Upstream orientation 0 | Parent communication line for orientation 0 |
| PA3 | Upstream orientation 1 | Parent communication line for orientation 1 |
| PA4 | Upstream orientation 2 | Parent communication line for orientation 2 |
| PA5 | Upstream orientation 3 | Parent communication line for orientation 3 |
| PB0 | Downstream child port 0 | Data line to child port 0 |
| PB1 | Downstream child port 1 | Data line to child port 1 |
| PB4 | Debug LED | Status/debug output |

## Mechanical Cube Interface?

### Orientation Detection Hardware
?? vlt contact connected to gpio
To detect the the cubes relative orientation/rotation four upstream orientation orientation/data lines/GPIOs are used. 
- Die entsprechenden Seiten des Parent-Bausteins besitzen einen Kontakt für die Datenweiterleitung, über die er mit dem child an der jeweiligen Seite kommunizieren kann
- je nach Rotation liegt dieses “Kommunikationssignal” bei einem der 4 Kontakte des Baustein (child) an (die anderen 3 Kontakte haben keine verbindung zum parent).

Therefore, the cube can determine its relative rotation by detecting on which of the four upstream GPIO pins the parent/polling signal appears.

The four possible orientation states are:

PA1 → orientation 0
PA3 → orientation 1
PA4 → orientation 2
PA5 → orientation 3

After the active orientation contact has been detected, this same contact is used as the upstream communication line to the parent.



### Child Connection Interfaces 
each downstream face/side contains a downstream child data line/GPIO/ contains a data contact connected to a GPIO pin of the microcontroller.

Through these downstream data contacts, a cube can communicate with possible child cubes

In the current prototype:???
PB0 → child port 0 
PB1 → child port 1
(for simplicity, the current prototype implements just two downstream child ports)

The firmware uses the child data lines to determine which child sides are occupied. The result is represented in the communication protocol as a `CHILD_MASK`.

**oder**
### Upstream Orientation Lines

Each cube has four possible upstream lines. These lines are used both for orientation detection and for communication with the parent.

The upstream orientation mapping is:

```text
PA1 = orientation 0
PA3 = orientation 1
PA4 = orientation 2
PA5 = orientation 3
```

The cube scans these pins while idle. When a low signal is detected, this is interpreted as the start bit of a possible incoming `CMD_STATUS` command.

If the received byte is valid, the detected pin becomes the active upstream line.

```text
active_upstream = detected upstream pin
orientation     = detected pin index
```

After this detection, all communication between the cube and its parent takes place through the detected upstream pin.

---

### Downstream Child Ports

The downstream ports are used by a cube when it acts as a parent for its own children.

Current prototype assignment:

```text
PB0 = child port 0
PB1 = child port 1
```

### baseplate?
acts just as a parent &rarr; no upstream orientation lines, just child ports

### Power Distribution Concept

The power supply is distributed centrally from the baseplate (noch genauer definieren) through the connected cube structure.

Each cube receives power from its parent through the docking side and forwards the supply voltage to its child sides.

The same principle is used for ground connection.

Inside the cube, `VCC` and `GND` are distributed to:

- the microcontroller
- the local electronics (feedback led)
- the output contacts for the child sides


### cube block diagram
---

## Electrical Principle
 All lines are single-wire, open-drain-emulated UART/NRZ by switching each pin between output-low and input-with-pullup. The communication is half duplex, meaning that only one device may transmit at a time.

The line has two logical states:

- HIGH = idle / released
- LOW  = actively pulled low

The line is therefore not actively driven high. Instead, similar to an open drain interface, the microcontroller releases the line and a pull-up resistor brings it to the high state.

### Open Drain like Operation
The open-drain-like behavior is implemented by switching the GPIO mode:

Transmit LOW:
    GPIO configured as output
    output level = LOW

Transmit / idle HIGH:
    GPIO configured as input
    pull-up enabled

This approach reduces the risk of electrical conflicts, because no device actively drives the line high.

## circuit design 