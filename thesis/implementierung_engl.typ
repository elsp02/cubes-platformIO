#import "functions.typ": req, apa-table

= Technical Realisation
The following chapter describes how the concept of the proposed learning system was implemented in the physical prototype. The focus is placed on the manufactured components, the electronic hardware, the implemented communication protocol, the embedded firmware and the learning application. 

NOCH WAS DAZU?

== Mechanical and Electronic Realisation
??AUCH LEARNING APPLICATION ERKLÄREN??

The physical and electonic implementation of the building bricks and the baseplate is described here. The section focuses on the components and construction methods used in the prototype as well as on deviations that occurred during manufacturing.

=== Mechanical Implementation
The prototype comprises two physically implemented building-brick types: the _cube brick_ and the _smashed brick_. Both types use the standardised square connection interface defined in @geometry-brick, but differ in their geometry and number of receiving faces. In contrast to the cube brick, the smashed brick has only half its height and provides a single receiving face opposite its docking face. Its four remaining lateral faces do not permit further connections.

Both brick types were modelled using Autodesk Inventor and manufactured using a 3D printer. Their housings implement the modular structure introduced in the concept chapter and consist of a black structural frame, colour-coded connection-side modules and a removable black cover. The side modules are inserted individually into the supporting frame and can be removed separately. This allowes the electronic components to be mounted and tested before the complete brick is assembled. In addition, individual modules can also be replaced without manufacturing an entirely new housing.

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 1em,
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [explosionszeichnung cube],
      supplement: [Figure],
      kind: "figure",
    ) <bild1>
  ],
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [explosionszeichnung smashed],
      supplement: [Figure],
      kind: "figure",
    ) <bild2>
  ],
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [explosionszeichnung baseplate],
      supplement: [Figure],
      kind: "figure",
    ) <bild2>
  ],
)

The docking and receiving sides contain mechanical guiding structures that align connected bricks and restrict their relative orientation the four positions. The connection is additionally secured by 4 magnets on every docking and recieving face. 
Die 4 contacte der docking seite befinden sich in den ecken der quadratischen fläche und der downstream kontakt in einer definierten ecke davon. Due to platzmangel muss der downstream contact of one receiving face anders platziert werden. the resulting rotational offset is compensated in the firmware, described in (section ???)
 der kontakt für GND und Versorgun ist in der Mitte der fläche platziert


The baseplate is implemented as the root element of the construction. Its housing contains the baseplate electronics and provides one receiving sides for connecting the first brick.

=== Electronic Implementation
VERWEIS AUF SCHALTPLAN UND KICAD DESIGN IM ANHANG
Both brick types are equipped with an ATtiny1616 microcontroller that serves as their local control unit. The mechanical interfaces contain spring-loaded Pogo pins that establish the electrical connections while compensating for minor manufacturing tolerances and small movements between connected bricks. The recessed guiding structures surrounding the contacts additionally protect the electrical interface against accidental contact, incorrect alignment and short circuits.

The electrical implementation differs between the docking and receiving faces. On a receiving face, the data, supply and ground connections are implemented using spring-loaded contacts. The docking face contains the corresponding contact surfaces for the data connections, whereas the power connection uses a different construction consisting of a neodymium ring and a Pogo pin mounted directly on the printed circuit board. (ABBILDUNG)

The four upstream data contacts of the docking face are located in the corners of the square connection area. Ground and power of this face are transmitted through rotationally symmetrical contacts. The ground contact is positioned at the centre of the interface, while the supply contact forms a concentric connection around it. Both electrical connections therefore remain unchanged when a brick is rotated in increments of 90°.
A receiving face provides a single downstream data contact in one defined corner as well as the power and ground contact in the center. Because of the limited installation space, the downstream data contact of one receiving face of the cube brick is placed in a different corner from the otherwise uniform arrangement. The resulting rotational offset is compensated for in the building-brick firmware, as described in @contact-offset.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [aufnahmeseite pogo pins],
      supplement: [Figure],
      kind: "figure",
    ) <bild1>
  ],
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [docking seite pogo pins],
      supplement: [Figure],
      kind: "figure",
    ) <bild2>
  ],
)

Four @RGB side view @LED on each cube side provide local feedback directly on the building brick. The assignment of the resulting colours to the implemented feedback states is described in INTERACTION??

The ATtiny1616, the four @RGB @LED and the electrical elements of the docking face are mounted on a printed circuit board designed using _KiCad_. The PCB is attached to the inside of the docking face using screws. The receiving face contacts are connected to the main board through the internal cable wiring of the brick.

The baseplate is also controlled by an ATtiny1616 and communicates with the computer through the microcontroller’s hardware USART interface and a connected USB-to-TTL UART adapter. The prototype is supplied with 5 V from the computer’s USB interface through this adapter. The baseplate transfers the supply voltage to the connected root brick, from which it is forwarded through the subsequent brick connections.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [blockdiagramm brick],
      supplement: [Figure],
      kind: "figure",
    ) <bild1>
  ],
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [blockdiagram baseplate],
      supplement: [Figure],
      kind: "figure",
    ) <bild2>
  ],
)

=== Conclusion?

//////
== Communication Protocol <communication-protocol>
The communication concept introduced in @software-concept is implemented using two separat communication interfaces: The communication within the physical construction and its parent child communication is based of a ?selbst erstelltes? software-controlled single-wire protocol whereas the communicaiton between the learning application and the baseplate uses the hardware USART of the baseplate microcontroller
TABELLE

#apa-table(
  columns: (2fr, 2fr, 1fr),

  table-label: <communication-interface>,

  header: (
    [Communication Interface],
    [Physical Implementation],
    [Transmission Rate]
  ),

  caption: [Implemented communication interfaces],

    [Learning application–baseplate],
    [Hardware USART through a USB-to-TTL UART adapter],
    [115200 bit/s],

    [Baseplate–brick and brick–brick],
    [Software-controlled single-wire half-duplex connection],
    [approximately 9.6 kbit/s],
  )

=== Single-Wire Communication Between the Building Bricks
The communication between two directly connected modules is implemented as a bidirectional single-wire half-duplex interface. The same data line is used alternately by the parent and child brick, and only one participant may transmit at a time.

The idle state of the line is logic high. However, the line is not actively driven high. Instead, the transmitting microcontroller either pulls the line to ground to transmit a logic low or releases it and activates its internal pull-up resistor to obtain a logic high. This open-drain-like behaviour reduces the risk of electrical contention because connected devices do not actively drive the line to opposing voltage levels.
Each byte is transmitted using a software-implemented UART-like format:(FIGURE):
#figure(
  image("figures/rechteck_lang@3x.png", width: 90%),
  caption: [Timing of one byte on the single-wire interface]
)<one-byte-timing>

The logic-low start bit indicates the beginning of a byte. It is followed by eight data bits transmitted least significant bit first and a logic-high stop bit. No parity bit is used. A bit duration of 104 µs results in a transmission rate of approximately 9.6 kbit/s and a total transmission time of approximately 1.04 ms per byte.
After a participant has completed a transmission, the line is released before the other participant responds. A turnaround interval of 312 µs, corresponding to three bit periods, is used whenever the direction of transmission changes.
This Communication type is used for construction detection and feedbackframe forwarding.


=== Common Frame Format
Construction and feedback data have different contents but are transmitted using the same variable-length binary frame format. This format is used for communication between the building bricks as well as between the baseplate and the learning application:

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1fr),
    align: center,
    stroke: 0.6pt,
    inset: 8pt,

    table.header(
      [*SYNC*],
      [*LEN*],
      [*PAYLOAD*],
      [*CHECKSUM*]
    ),

    [1 byte],
    [1 byte],
    [0-128 bytes],
    [1 byte],
  ),
  caption: [Implemented binary frame format]
) <frame-format>

vlt die Infos auch in Figure einfügen
#apa-table(
  columns: (1fr, 1fr, 2fr),

  table-label: <frame-format-table>,

  header: (
    [Field],
    [Size],
    [Implemented meaning]
  ),

  caption: [Fields of the implemented binary frame format],

    [SYNC],
    [1 byte],
    [Start marker 0xA5],

    [LEN],
    [1 byte],
    [Number of bytes contained in the payload],

    [Payload],
    [0-128 bytes],
    [Detection or feedback data],

    [Checksum],
    [1 byte],
    [XOR checksum over LEN and all payload bytes]
  )

The synchronisation byte enables the receiver to identify the beginning of a frame. The length field specifies the number of payload bytes that must subsequently be read. A frame with LEN = 0 contains an empty payload. I Although the one-byte length field could theoretically represent up to 255 payload bytes, the prototype limits the payload to 128 bytes to restrict the required buffer size and transmission duration. 


The payload contains the information transmitted by the frame. Its structure depends wether it contains the detected tree structure or the feedback message. Both payload formats are described in detail in @detection-payload and @feedback-payload.

To detect transmission errors, an XOR checksum is calculated from the length field and all payload bytes:
$
  C = L ⊕ P_0 ⊕ P_1 ⊕ dots.c ⊕ P_(L - 1)
$
beim Empfang wird die Prüfsumme erneut berechnet und mit dem übertragenen Wert verglichen. Stimmen beide Werte nicht überein, wird der Frame verworfen.

=== Parent Child Communication
The communication within the physical construction follows a _request–response_ procedure and is always initiated by the parent brick. Depending on the current process, the communication is used either to retrieve the detected construction or to transmit feedback towards the connected bricks.

The command and acknowledgment bytes used in the two processes, are summarised in the following table @command-bytes

#apa-table(
  columns: (1fr, 1fr, 1fr, 2fr),

  table-label: <command-bytes>,

  header: (
    [Message],
    [Value],
    [Direction],
    [Meaning]
  ),

  caption: [Command and acknowledgement bytes of the parent–child protocol],

    [CMD_STATUS],
    [0xAA],
    [Parent → child],
    [Request the detected subtree],

    [ACK_BUSY],
    [0x55],
    [Child → parent],
    [Request received and being processed],

    [CMD_FEEDBACK],
    [0xCC],
    [Parent → child],
    [Announce the transmission of a feedback frame],

    [ACK_FINISHED],
    [0x66],
    [Child → parent],
    [Feedback successfully processed and forwarded],

    [ACK_FAILED],
    [0x77],
    [Child → parent],
    [Feedback frame invalid or forwarding failed]
  )

==== Detection Communication
To request the detected subtree of a connected child, the parent (node) sends _CMD_STATUS_ through the corresponding downstream interface. After receiving this valid request, the child (node) changes the transmission direction and responds with _ACK_BUSY_ . This confirms that the request haas been received and the child is going to begin collecting the required information with subsequently querying its own receiving interfaces. Once the subordinate information has been collected, it returns a _DATA_FRAME_ containing its own Payload and the Payload of its complete subtree. This procedure is applied recursively throughout the connected construction. FIGURE

#figure(
  image("figures/rechteck_hoch@3x.png", width: 90%),
  caption: [COMMUNICATION SEQUENCE DIAGRAM Recursive communication sequence for detecting the connected building-brick structure]
)<communication-diagram-detection>

BYTE EBENE??
#figure(
  image("figures/rechteck_hoch@3x.png", width: 90%),
  caption: [SINGLE WIRE PARENT CHILD COMMUNICATION]
)<communication-diagram-detection>

===== Detection Payload <detection-payload>
The payload returned during this sequence represents the detected construction tree. Each brick contributes a three-byte node header, followed by the serialised representations of its subordinate bricks:

#figure(
  table(
    columns: (1fr, 1fr, 1fr, 1.5fr),
    align: center,
    stroke: 0.6pt,
    inset: 8pt,

    table.header(
      [*NODE_ID*],
      [*ORIENTATION*],
      [*CHILD_MASK*],
      [*CHILD_NODE_PAYLOAD*]
    ),

    [1 byte],
    [1 byte],
    [1 byte],
    [variable]
  ),
  caption: [Detection payload]
) <node-header-format-detection>

vlt die Infos auch in Figure einfügen
#apa-table(
  columns: (1fr, 1fr, 2fr),

  table-label: <detection-format-table>,

  header: (
    [Field],
    [Size],
    [Implemented meaning]
  ),

  caption: [Structure of a serialised building-brick node],

    [NODE_ID],
    [1 byte],
    [Brick type and individual instance number],

    [ORIENTATION],
    [1 byte],
    [Relative rotation represented by a value from 0 to 3],

    [CHILD_MASK],
    [1 byte],
    [Bit mask of occupied receiving interfaces],

    [Child-node Payload],
    [variable],
    [Subtree payloads of the subordinate bricks]
  )

The _NODE_IDs_ three most significant bits encode the brick type, whereas the five least significant bits encode the individual instance number. This allows the learning application to distinguish between the cube and smashed brick types while retaining an individual address for assigning local feedback.
_ORIENTATION_ contains a value from 0 to 3, representing the four possible rotations of the brick relative to its parent. Within _CHILD_MASK_, bit \(i\) indicates whether a child was detected at receiving interface \(i\). The cube brick can use bits 0 to 4 for its five receiving interfaces whereas the smashed brick only needs one bit assigned to its single receiving interface. 
The node representations of the connected children follow the node header in ascending order of the receiving-interface indices. The precise procedure through which the firmware collects and combines these node representations is described in Section //@firmware-brick.

The baseplate does not add a node header of its own. Instead, it transfers the payload beginning with the first brick connected to it. If no root brick is detected, the baseplate transmits a DATA_FRAME with an empty payload.e.


==== Feedback Communication
The feedback communication is also initialised by the parent node but with another command message. The _CMD_FEEDBACK_ singalises the child node the upcoming transmission of a _FEEEDBACK_FRAME_. After receiving the command, the child responds with _ACK_BUSY_, indicating that it is ready to receive the frame.
The parent then transmits the complete FEEDBACK_FRAME. After processing and forwarding the frame, the child reports the result using either ACK_FINISHED or ACK_FAILED. The internal processing and forwarding logic is described in @firmware-brick.

===== Feedback Payload <feedback-payload>
The Feedback Payload uses the common frame format but contains pairs of brick identifiers and LED states:
#figure(
  table(
    columns: (1fr, 1fr, 1fr,1fr, 1fr),
    align: center,
    stroke: 0.6pt,
    inset: 8pt,

    table.header(
      [*NODE_ID*],
      [*LED_STATE*],
      [*NODE_ID*],
      [*LED_STATE*],
      [*...*]
    ),

    [1 byte],
    [1 byte],
    [1 byte],
    [1byte],
    [...]
  ),
  caption: [feedback payload]
) <node-header-format>

_LED_STATE_ can assume one of two values: _LED_GREEN_ or _LED_RED_. If a brick’s _NODE_ID_ is not included in the feedback payload, that brick switches off its @LED. An empty feedback payload can therefore be used to deactivate all local feedback simultaneously.

=== Communication between Learning Application and Baseplate
The connection between the learning application and the baseplate uses the ATtiny1616 hardware USART at 115200 bit/s with eight data bits, no parity and one stop bit. The learning application controls an interaction session using the following single-byte commands and responses:

#apa-table(
  columns: (1.3fr, 1fr, 2fr, 2.5fr),

  table-label: <application-baseplate-communication>,

  header: (
    [Message],
    [Value],
    [Direction],
    [Meaning]
  ),

  caption: [Messages exchanged between the learning application and the baseplate],

    [PC_CMD_START],
    [0x53 (S)],
    [Application→ Baseplate],
    [Start cyclic construction detection],

    [DATA_FRAME],
    [Variable],
    [Baseplate → Application],
    [Current serialised construction],

    [FEEDBACK_FRAME],
    [Variable],
    [Application → Baseplate],
    [Feedback calculated by the application],

    [PC_RESP_DONE],
    [0x44 (D)],
    [Baseplate → Application],
    [Feedback successfully forwarded],

    [PC_RESP_FB_FAILED],
    [0x4E (N)],
    [Baseplate → Application],
    [Invalid feedback frame or forwarding failure],

    [PC_CMD_STOP],
    [0x58 (X)],
    [Application → Baseplate],
    [Stop detection and switch off local feedback]
)

After receiving _PC_CMD_START_, the baseplate begins the detection process and transmits the detected construction to the learning application using the DATA_FRAME format defined above.

After receiving the DATA_FRAME, the learning application answers with the FEEDBACK_FRAME calculated from the target comparison. The baseplate forwards this frame through the physical construction and responds with PC_RESP_DONE if all detected bricks confirmed the feedback. If the received frame is invalid or at least one brick fails to confirm the feedback transmission, it responds with PC_RESP_FB_FAILED.

When the basplate receives a _PC_CMD_STOP_ from the learning application, it forwards an empty FEEDBACK_FRAME so that all local @LED are switched off. It then terminates the cyclic detection by returning to its idle state.

#figure(
  image("figures/rechteck_hoch@3x.png", width: 90%),
  caption: [KOMMUNIKATIONSSEQUENZDIAGRAMM Cube baseplate learning application]
)<communication-diagram-learning-application>

=== Validation and Error Handling
Several validation mechanisms were implemented to prevent incomplete or corrupted transmissions from being interpreted as valid construction data:

- Each received byte is checked for a valid start and stop bit.
- The SYNC byte allows the receiver to locate the beginning of a frame.
- The received length is checked against the maximum payload size of 128 bytes.
- Timeouts terminate the reception of incomplete bytes or frames.
- The XOR checksum detects changes to the payload or length field.
- On the computer interface, incomplete or invalid frames are discarded and reception resumes by searching for the next valid SYNC byte.

The baseplate waits up to two seconds for the first byte of the application’s feedback response and allows a maximum interval of 100 ms between bytes within that frame. Detection cycles are currently separated by a delay of 550 ms, in addition to the time required for communication within the connected construction. These values describe the implemented prototype and are not general protocol requirements.

=== Conclusion?


/////
== Firmware of Bricks and Baseplate <firmware>
ÜBERLEITUNG
The firmware is implemented in C++ using PlatformIO and compiled for the ATtiny1616 microcontrollers with an internal clock frequency of 20MHz. Separate firmware variants control the building bricks and the baseplate, while shared modules provide the functions required for single-wire communication, child-brick detection and feedback transmission.

=== Brick Firmware <firmware-brick>
The brick firmware is responsible for collecting its local and untergeordnete tree structure and controlling the feedback output. Its implemented control flow is shown in figure @brick-state-machine

#figure(
  image("figures/rechteck_hoch@3x.png", width: 90%),
  caption: [State machine of the brick firmware]
)<brick-state-machine>

After initialisation, all communication lines are released and the @LED outputs are configured. The firmware then monitors the four upstream contacts of the docking face. The index of the contact through which the first valid request is received determines the relative rotation of the brick. The corresponding communication line and orientation value are stored and used for all subsequent communication with the parent.
This orientation detection is determined just once after the microcontroller has started. Disconnecting the brick interrupts its centrally supplied power, causing the firmware to restart when the brick is connected again. The orientation is therefore detected again after every new physical connection. 

==== Detection Process
When the brick/state machine enters the detection state, it queries the available downstream interfaces in ascending order. Depending on the brick type this means querying five or for the smashed brick only one interface. The communication with an individual child is handled by a dedicated child-polling function. A sucessful response provides the serialised payload of the child´s complete subtree. This subtree payload is stored temporarily until all configured downstream interfaces have been processed. If a child does not return a valid payload within the available attempts, its subtree is omitted from the current detection result. Successfully received child-subtree payloads are appended in ascending interface order to the brick’s own node payload according to the format specified in @detection-payload. For each included child, the corresponding bit in CHILD_MASK is set to one. The resulting complete payload therefore consists of the current bricks own node payload followed by the payloads of its successfully detected child subtrees. It is then transmitted to the parent using the frame and message sequence defined in @communication-protocol. 

Because every child performs the same processing before returning its result, the complete construction is acquired recursively without requiring an individual brick to store a global representation of the structure.

==== Correction of the Contact Offset <contact-offset>
As described in the mechanical realisation, the downstream data contact of one receiving face of the cube brick could not be placed in the same relative corner as the other downstream contacts. This causes the orientation reported by a child connected to this interface to contain an offset of one quarter turn. The bricks firmware compensates this deviation before it incorpoates the child payload into the parent payload with an incremented modulo four:

$
o_"corrected" = (o_"detected" + 1) mod 4
$

The learning application therefore does not require an additional interface specific correction because it consequently receives orientation values with a consistent interpretation for all receiving interfaces.

==== Feedack Processing <feedback-processing>
When the brick/state machine enters the feedback state, the cube receives and validates the FEEDBACK_FRAME according to @feedback-payload. It searches the payload for its own NODE_ID and if it is enthalten it applies the corresponding state to the local @LED output. If the NODE_ID is not a part of the frame, the @LED are switched off. 

The same FEEDBACK_FRAME is subsequently forwarded to the interfaces marked as occpudied during the preceding detection cycle. With the in @communication-protocol defined messages, the brick then reports to its parent whether the frame was successfully processed and forwarded or not.

=== Baseplate Firmware <firmware-baseplate>
The behaviour of the building-brick firmware is coordinated by the baseplate firmware, which initiates the detection and feedback processes. In addition to controlling the communication session, the baseplate mediates between the learning application and the physical building-brick structure.
It does not parse the construction, calculate spatial positions or evaluate the task. These operations are performed by the learning application described in the following @software-application.

The implemented control flow of the baseplate is shown in Figure @baseplate-state-machine.
#figure(
  image("figures/rechteck_hoch@3x.png", width: 90%),
  caption: [State machine of the baseplate firmware]
)<baseplate-state-machine>

After initialisation, the baseplate releases its downstream communication line, configures its hardware USART and enters the idle state. It remains in this state until the learning application starts a new communication session. During an active session, the baseplate repeatedly initiates the detection of the connected construction by querying the brick attached to its single receiving interface. Since this is the first brick of the construction its response already contains the serialised payload of the complete root subtree. If no valid root payload is received, the current construction is represneted by an empty payload. Otherwise, the received subtree payload is forwarded without structural modification to the learning application.

==== Payload Transmission Control
To avoid transmitting identical construction data during every cycle gibt es bestimmte bedingungen wann die baseplate es zur lwarning application schickt und wann nicht. 

The first payload after the beginning of a session is always transmitted, irrespective of a potentially retained result from a preceding session. For every other payload transmission the baseplate compares the current detection payload with the payload transmitted most recently. A new DATA_FRAME is only transmitted when the current payload differs from the preceding one. If the construction remains unchanged, the baseplate sends the unchanged payload erst after 50 detection cycles as a heartbeat. This confirms that the communication link and the detection process remain active without continuously transmitting identical frames. 

The current implementation inserts a delay of 550 ms between consecutive detection cycles. The complete interval between two results additionally depends on the number and arrangement of connected bricks as well as on possible retransmission attempts.

==== Feedback Forwarding and Session Termination
After tranmitting a DATA_FRAME, the baseplate waits for the corresponding FEEDBACK_FRAME from the learning application.It then forwards the frame to the root brick using the same procedure as the feedback processing of the building bricks described in @feedback-processing. Afterwards, the baseplate reports to the learning application whether the frame was confirmed by the connected construction or not. The baseplate does not interpret the individual feedback entries and nor control the @LED of the bricks directly. Its role is limited to receiving the frame from the learning application and initiating its distribution through the physical construction.

When the learning application terminates the session, the baseplate forwards an empty feedback frame to the root brick and since no brick NODE_IDs are contained in this payload, all local feedback outputs are switched off. The baseplate then ends cyclic detection and returns to the idle state shown in @baseplate-state-machine.

=== Conclusion?

== Software Architecture and Backend Processing <software-application>
The learning application consists of a Python based backend and a browser based frontend implemented in JavaScript. The backend processes the data exchanged with the baseplate, while the frontend provides the selected target structure and presents the visualised results to the user. In the following chapters the implemented software architecture as well as the backend processing are described. (The implementation of the three-dimensional visualisation as well as the user-facing presentation of feedback are described separately in @user-interface-visualisation-feedback.)

 === Implemented Software Architecture
  The backend connects the two communication interfaces of the learning application: Communication with the baseplate is implemented using PySerial, while a WebSocket connection is used to exchange data with the browser frontend. (The serial interface transfers the compact binary frames described in @communication-protocol, whereas the WebSocket interface exchanges JSON objects.)

 At the begging of a construction session, the target structure selected in the frontend is transfered to the backend. The backend receives and deserialises the detected construction data and compares the resulting tree witht the selected target. The comparison derives two outputs: The binary FEEDBACK_FRAME for the physical bricks that is returned to the baseplate through the serial interface. And an evaluated tree which is transferred to the frontend as a JSON object. This evaluated tree contains the structural information and feedback states required for the subsequent visualisation.

 The Serial communication and WebSocket are processed independently since they use different interfaces and data formats. Since the backend maintains a single serial connection to one baseplate, the current implementation supports only one active construction session at a time.


 aufbau mit frontend und backend
 - learning application consists of a python based backend and a browserr based frontend implemented in Javascript

 - backend aufgabe: 
    - connects the serial communication with the baseplate to the frontend and performs the application logic associated with the construction task
    - deserialising the detected construction, managing the selected target structure, comparing both structures and generating the data required for local and global feedback - soll ich das nennen?

 - frontend aufgabe:
    - provides the target structure to the backend and receives the evaluated construction through a WebSocket connection
    - berechnet die position der bricks und visualisiert es
    - Its presentation-related functions are discussed in @user-interface-visualisation-feedback.
 - backend communication with baseplate: Pyserial
 - frontend - backend communication: Websocket connection

 - process erklärung
  - beginning: frontend transfers the selected target structure to backend
  - backend: 
    - receives and deserialises detected construction data
    - compares resulting tree with selected target 
    - derives two outputs from comparison
      - a binary feedback frame that is returned to the baseplate and forwarded to the physical bricks -> baseplate wie wird das geschickt? (serial interface exchanges compact byte frames with the baseplate)
      - evaluated tree for frontend -> latter is transfered to browser as JSON object and contains construction data and feedback states required for its subsequent visual representation 
  - Serial communication and WebSocket communication are processed indepentently becuase they use different data formats and interfaces
  - current implementation supports one active construction session at a time which means for the user just one?

  #figure(
  image("figures/rechteck_lang@3x.png", width: 90%),
  caption: [Implemented software architecture of the learning application]
)<software-architecture>

//Figure @software-architecture should show the browser frontend, the WebSocket interface, the backend components for deserialisation, comparison and feedback generation, the serial interface and the baseplate.

 === Deserialisation and Internal Tree Models/Tree reconstruction and target comparison
 - backend recieves the detected construction as the payload defined in @detection-payload
 - recursive parser converts this linear byte sequence into an object based tree represenation
  - starting with first root node, it evlauates each node header and uses the transmitted child mask to identify and recursively reconstruct the subordinate nodes in ascending port oder -> each child node is thereby assigned to the recieving port thourgh which it is connected to its parent
  - each detected brick is represented internally by a node containing its identifier, orientation, parent port (ist diese representation struktur nach dem parser oder davor? )
    CubeNode structure stores following information for every detected brick:
    - its complete node identifier,
    - its relative orientation,
    - the receiving interface through which it is connected to its parent,
    - its child mask,
    - its subordinate nodes.
- after reconstruction, the parser verifies that the complete payload has been consumed
- Incomplete node data or remaining bytes cause the payload to be rejected as invalid

- target construction uses a separate but strucutrally equivalent tree representation (JSON File). 
  - Its nodes contain the required brick type and orientation, while the child nodes are assigned to their expected receiving ports
  - Unlike the detected structure, the target tree does not contain individual brick identifiers because bricks of the same type are interchangeable within the task

-> Both representations nevertheless share the same hierarchical organisation, allowing them to be compared recursively.


VLT BEISPIEL EINER SOLCHEN DESERIALIZED NODE/SERIALISED NODE? und TARGET REPRESENTATION

//vlt die zwei kapitel zusammennehmen
=== Comparison and Generetation of Feedback Data
- once the construction is geparsed und als node dargestellt the comparison starts at the root node of the detected and target structure and proceeds recursively through the receiving ports of each parent
- for every expected position, the implementation examines the 
  - presence of a physical brick, 
  - its type, its relative 
  - orientation 
  - its position within the parent–child structure.
  -> The individual identifier of a brick is not used to determine whether the construction is correct; it is retained solely to address the corresponding physical brick when generating local feedback.

- comparison reproduces an evaluated tree that combines infirmation form detected and target structure. each entry is assigned of one of five internal states
  - correct
  - wrong
  - attachable
  - blocked

- in addition to the general wrong state, an error masks records wheter a deviation relates to the 
  - brick type
  - orientation
  - receiving port
  - parent path
  - presence of an unexpected element
-> separation allows the same comparison result to support different forms and levels of feedback without executing the structural comparison again.

- If the path leading to a brick is already incorrect, its subordinate structure is also marked as invalid-> Conversely, an unoccupied target position is classified as ATTACHABLE only if its parent path is correct; subordinate positions that cannot yet be reached meaningfully remain BLOCKED.

- two outputs are dervied from the evaluated tree
  - generates brick specific feedback data set for all physically present nodes and converts it into the feedback frame defined in @feedback-payload
    (Physically present bricks with the state CORRECT receive a green LED state. Bricks classified as WRONG or UNEXPECTED receive a red LED state. ATTACHABLE/BLOCKED Missing target positions do not correspond to physical bricks and therefore do not produce local LED entries)
  - generates a JOSN compatible representation of the evaluated tree for the frontend -> This representation contains both detected bricks and currently unoccupied target positions, together with their assigned states and expected properties. 
  -> The manner in which these results are presented locally and globally is described in @user-interface-visualisation-feedback.

=== Calculation of Spatial Poses <calculation-poses>

- calculation passiert lokal? -> not necessary to calculate global coordinates for the comparison. Spatial positions and rotations are calculated separately for the subsequent three-dimensional visualisation.
- calculation passiert im frontend?
- calculation für detected construction and target construction

- implementation uses a local coordinate system for every brick:
  - z axis represents the vertical axis
  - docking face of a brick is oriented towards its local negative z direction
  - For the cube brick, receiving ports \(0\) to \(4\) correspond to the directions \(-x\), \(-y\), \(+z\), \(+x\) and \(+y\). 
  - The smashed brick provides only one receiving port in its local \(+z\)-direction. 
  ->  @brick-coordinate-system  and @smashed-coordinate-system should illustrate this assignment together with the orientation values detected at the docking interface.


#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [cube render bild mit koordinatensystem],
      supplement: [Figure],
      kind: "figure",
    ) <brick-coordinate-system>
  ],
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [Local coordinate system and receiving-port assignment of the implemented brick types],
      supplement: [Figure],
      kind: "figure",
    ) <smashed-coordinate-system>
  ],
)

For every connection, the local position of a child brick is determined by the direction and distance assigned to the receiving port of its parent:

$
bold(p)_("local") = bold(d)_(t, p) times l_(t, p)
$

where $t$ denotes the type of the parent brick, $p$ the receiving port, $bold(d)_(t, p)$ its direction vector and $l_(t, p)$ the distance between the model origins. The distance $l_(t, p)$ depends on the geometry of the parent brick and the selected receiving port. The reduced height of the smashed brick is therefore considered when positioning a child connected to its upper receiving face.

The local orientation of a child is represented using a quaternion which consists an attachment rotation and an additional twist rotation: 

$
q_("local") =
q_("attachment")(t, p)
times
q_("twist")(o).
$

- The attachment quaternion $q_("attachment")(t, p)$ aligns the docking face of the child with the selected receiving face of the parent
- The twist quaternion $q_("twist"))(o)$ represents the detected relative rotation $o$.
The four orientation values are mapped to rotations of
$90 degree$, $0 degree$, $-90 degree$ and $-180 degree$
around the local $z$-axis. -> assignments aligns the orientation of the digital models with the orientation convention used by the connection-detection system

- the first brcik connected to the baseplate forms root of the displayed construction
- since it has no parent brick, its local positon is set to the origin of the scene and its local orientation is derived solely from its transmitted relative rotation

for all subordinate bricks, the local position and orientation are accumulated recursively along the parent child structure. every child object is inserted into the scene graph as a subordinate object of its parent. 

The global transformation of a child brick $c$ follows from the global transformation of its parent brick $p$ with the local transformation of the child:

$
T_("global", c)
=
T_("global", p)
times
T_("local", c).
$

this recursive composition converts the locally detected connection information into global positions and orientations without requiring the backend to transmit absolute coordinates 

sagen dass nur aus lokalen informationen der bausteine ausreichen umd die gloablen positionen zu berechnen - oder das vlt am ende in conclusion zusammen mit dem fact dass lokale informationen ausreichen um global die konstruktion zu bewerten/vergleichen
The same tree-building implementation is used for the target

// wo soll das hin?:
The generated construction is placed within a Three.js scene containing a perspective camera, ambient and directional lighting and a shadow-receiving ground plane. The camera position is adapted to the bounding box of the construction when the first result of a session is displayed. Orbit controls allow the visualisation to be rotated and enlarged using either mouse or touch input

=== Conclusion


=== Benutzeroberfläche, Visualisierung und Feedback 
<user-interface-visualisation-feedback>

die positionsberechnung und error mask ist grundlage für visualsierung

- Auswahl und Darstellung einer Zielkonstruktion
- visuelle Kennzeichnung korrekter und fehlerhafter Bausteine
  - Abstimmung zwischen globaler Rückmeldung in der Anwendung und lokalem Feedback an den Würfeln
  - feedback mit led 

  anforderungen
  - rot grün
  550ms