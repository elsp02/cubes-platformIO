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
- Baseplate contains a gateway/controller (pico?) as an interface between the cubes and the hardware auf dem cubes visualiziert werden + die spannungsquelle fürs system -> VERBESSERN!
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

## technische anforderungen ans design
- keine externe hardware (kalibirierung nötig oder so die es lehrern erschwert system sofort zu nutzen) bzw wo man perfekte umgebungsbedingungen braucht
- Die Bausteine sollen ohne eigene Batterie oder individuellen Akku betrieben werden.
- Die Energieversorgung der Bausteine soll zentral, beispielsweise über eine Basisstation oder ein extern erzeugtes Feld, erfolgen.
- Die Bausteine sollen möglichst einfach aufgebaut sein, um Kosten, Fehleranfälligkeit und Baugröße gering zu halten.
- Die Bausteine sollen dreidimensional angeordnet bzw. gestapelt werden können + bei der Verbindung in unterschiedlichen Rotationen zueinander positioniert werden können.

### Power Distribution Concept

The power supply is distributed centrally from the baseplate (noch genauer definieren) through the connected cube structure.

Each cube receives power from its parent through the docking side and forwards the supply voltage to its child sides.

The same principle is used for ground connection.

Inside the cube, `VCC` and `GND` are distributed to:

- the microcontroller
- the local electronics (feedback led)
- the output contacts for the child sides

grund dafür: die bausteine sollten möglichst einfach aufgebaut sein und so dass man an ihnen nicht rum arbeiten muss/sie nicht öfnen muss, also auch nicht batterie austauschen. das ganze system soll so gebaut sein, dass mans herausräumt und sofort benutzen kann (fachbegriff? x- ready?)

### cube block diagram

### cube aussehen verbindungen (angelehnt an bedürfnisse und anforderungen vpn special need kindern) geometrie
anforderungen: 
- Es dürfen sich keine gefährlichen Kleinteile lösen und das Innenleben der Bausteine sollte nicht leicht zugänglich sein
- Bausteine sollen auch in den Mund genommen werden können ohne dass dabei eine Gefahr ausgeht
- !!Die Bausteine sollen so gestaltet sein, dass sie leicht mit einer Hand greifbar und einfach miteinander verbindbar sind.
- ! Das Verbinden der Bausteine soll mit geringem Kraftaufwand möglich sein.
- ! Die Verbindungspunkte sollen die Nutzung durch Personen mit eingeschränkter Feinmotorik unterstützen.


steckprinzip und anordnung der stecker
4 orientierungsverbindungen (child seite) bzw data pin (parent seite) in den ecken, 1 gnd verbindung in der mitte und ein vcc kreisverbinder ausenrum -> symmetrische anordnung notwenig weil baustein verschiedene orientierungs connect möglichkeiten haben soll (freiheitsgrad?)

wie verbinden sich die blöcke (formschluss, mechanisch, magnetisch)
- child seite hat erhebungen und parent seiten vertiefungen, damit sich die bausteine auch mechanisch verbinden können (art lego prinzip)
- plus so ist sichergestellt dass man nicht in kontakt mit den stellen treten kann, weil die seite die erhebungen hat angesteckt wird sobald sie strom bekommt und durch die vertiefungen kann man nicht einfach reinlangen oder mit der zunge berühren die kontakte die dann ja strom haben, sobald der cube verbunden ist. 
- physische verbindung geschieht über federbelastete niederohmige pogo pin stecker

- das stecken wird auch nochmal mit magneten erleichtert -> easier attachment for people with physical dissabilities und schon leichte vorgabe wie der cube positioniert sein muss damit er sich verbinden kann 

geometrie und größe und material
- aufgrund der anordnung der stecler und dem steckprinzip muss der cube eine symmetrische/quaderförmige grundfläche haben 
- sind x *x cm groß, sodass sie  leicht mit einer Hand greifbar und einfach miteinander verbindbar
- material 3d druck ppa

physische representation der steine/abstrakheit
- die bausteine schauen physisch als auch visualiziert gleich aus

### baseplate aussehen
die baseplate besteht quasi aus einer parent seite (also vertiefungen). das grundprinzip ist, dass es eine main parent andockmöglichkeitsplatte gibt, an dem sich ein cube verbinden kann. (zukunft: an diese parent platte kann man dann noch andere parent platten anstecken, sodass man dann auf der ersten ebene nicht nur einen cube hat sondern mehrere. wobei man die eigentlich nicht braucht, weil man ja die cubes auch einfach an den ersten cube anstecken kann) 

die baseplate enthält auch die Spannungsquelle, die in der main parent baseplate platte integriert ist

## visualization interface aussehen?
??
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