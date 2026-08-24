#import "functions.typ": req, apa-table

= Technical Realisation
The following chapter describes how the concept of the proposed learning system was implemented in the physical prototype. The focus is placed on the manufactured components, the electronic hardware, the implemented communication protocol, the embedded firmware and the learning application. 

== Mechanical and Electronic Realisation
The physical and electronic implementation of the building bricks and the baseplate is described here. The section focuses on the components and construction methods used in the prototype as well as on deviations that occurred during manufacturing.

=== Mechanical Implementation
The prototype comprises two physically implemented brick types: the _cube Brick_ and the _smashed Brick_. Both types use the standardised square connection interface defined in @geometry-brick but differ in their geometry and number of receiving faces. In contrast to the cube brick, the smashed brick has only half its height and provides a single receiving face opposite its docking face. Its four remaining lateral faces do not permit further connections.

The square connection faces have a side length of approximately 40 mm. The selected dimension represents a compromise between the one-handed grasping and positioning required by #req("C3") and the internal space required for the electrical contacts and electronic components. The ergonomic suitability of the implemented dimensions is assessed in the evaluation chapter.

Both brick types were modelled using Autodesk Inventor and manufactured using a 3D printer. Their housings implement the modular structure introduced in the concept chapter and consist of a black structural frame, colour-coded connection-side modules and a removable black cover. The side modules are inserted individually into the supporting frame and can be removed separately. This allows the electronic components to be mounted and tested before the complete brick is assembled. In addition, individual modules can also be replaced without manufacturing an entirely new housing.

#figure(
  image("figures/exploded@3x.png", width: 90%),
  caption: [Exploded views of the prototype housings: (a) cube brick and (b) smashed brick]
)<exploded-bricks>

The baseplate is implemented as the root element of the construction. Its housing contains the baseplate electronics and provides one receiving side for connecting the first brick.

=== Electronic Implementation
Both brick types are equipped with an ATtiny1616 microcontroller that serves as their local control unit. The mechanical interfaces contain spring-loaded pogo pins that establish the electrical connections while compensating for minor manufacturing tolerances and small movements between connected bricks. The recessed guiding structures surrounding the contacts additionally protect the electrical interface against accidental contact, incorrect alignment and short circuits. The electronic structures of the building bricks and the baseplate are summarised in Figures @brick-electronics-block and @baseplate-electronics-block.

The electrical implementation differs between the docking and receiving faces. On a receiving face, the data, supply and ground connections are implemented using spring-loaded contacts. The docking face contains the corresponding contact surfaces for the data connections, whereas the power connection uses a different construction consisting of a neodymium ring and a pogo pin mounted directly on the printed circuit board.

The four upstream data contacts of the docking face are located in the corners of the square connection area. Ground and power of this face are transmitted through rotationally symmetrical contacts. The ground contact is positioned at the centre of the interface, while the supply contact forms a concentric connection around it. Both electrical connections therefore remain unchanged when a brick is rotated in increments of 90°.
A receiving face provides a single downstream data contact in one defined corner as well as the power and ground contacts in the centre. Because of the limited installation space, the downstream data contact of one receiving face of the cube brick is placed in a different corner from the otherwise uniform arrangement. The resulting rotational offset is compensated for in the brick firmware, as described in @contact-offset.
The implemented contact arrangements are shown in @contact-arrangement-physical. 


#figure(
  image("figures/kontakt-arrangement.jpg", width: 70%),
  caption: [Implemented contact arrangements: receiving face (left) and docking face (right)]
)<contact-arrangement-physical>

Four side-view RGB LEDs are arranged around the printed circuit board to provide local feedback directly on each building brick. The ATtiny1616, the RGB LEDs and the electrical components of the docking face are mounted on a printed circuit board designed using KiCad. The PCB is attached to the inside of the docking face using screws, while the contacts of the receiving faces are connected to the main board through the brick’s internal wiring. The complete circuit diagram is provided in Appendix @appendix-circuit-diagram.

The baseplate is also controlled by an ATtiny1616. It communicates with the computer through the microcontroller’s hardware USART interface and a connected USB-to-TTL UART adapter. The prototype is supplied with 5 V DC from the computer’s USB interface through this adapter. The baseplate transfers the supply voltage to the connected root brick, from which it is forwarded through the subsequent brick connections. Consequently, all accessible electrical contacts carry only 5 V DC. This remains below 15 V and does not present an electrical shock hazard under the intended dry-use conditions, thereby fulfilling #req("S4").

#figure(
  image("figures/blockdiagramm-brick.pdf", width: 95%),
  caption: [Electronic block diagram of a building brick],
  supplement: [Figure],
  kind: "figure",
)<brick-electronics-block>

#v(1em)

#figure(
  image("figures/blockdiagramm-baseplate.pdf", width: 95%),
  caption: [Electronic block diagram of the baseplate],
  supplement: [Figure],
  kind: "figure",
)<baseplate-electronics-block>



//////
== Communication Protocol <communication-protocol>
The communication concept introduced in @software-concept is implemented using two separate communication interfaces. Communication within the physical construction follows the parent–child hierarchy and uses a custom, software-controlled single-wire half-duplex protocol. Communication between the learning application and the baseplate is implemented using the hardware USART of the baseplate microcontroller and a USB-to-TTL UART adapter. The two interfaces are summarised in @communication-interface.

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
The communication between two directly connected modules is implemented as a bidirectional single-wire half-duplex interface. The same data line is used alternately by the parent and child brick and only one participant may transmit at a time.

The idle state of the line is logic high. However, the line is not actively driven high. Instead, the transmitting microcontroller either pulls the line to ground to transmit a logic low or releases it and activates its internal pull-up resistor to obtain a logic high. This open-drain-like behaviour reduces the risk of electrical contention because connected devices do not actively drive the line to opposing voltage levels.
Each byte is transmitted using a software-implemented UART-like format illustrated in @one-byte-timing.

#figure(
  image("figures/Single_wire_byte.svg", width: 90%),
  caption: [Timing of one byte on the single-wire interface]
)<one-byte-timing>

The logic-low start bit indicates the beginning of a byte. It is followed by eight data bits transmitted least significant bit first and a logic-high stop bit. No parity bit is used. A bit duration of 104 µs results in a transmission rate of approximately 9.6 kbit/s and a total transmission time of approximately 1.04 ms per byte.
After a participant has completed a transmission, the line is released before the other participant responds. A turnaround interval of 312 µs, corresponding to three bit periods, is used whenever the direction of transmission changes.
This communication type is used for construction detection and feedback-frame forwarding.


=== Common Frame Format
Construction and feedback data have different contents but are transmitted using the same variable-length binary frame format. This format, shown in @frame-format, is used for communication between the building bricks as well as between the baseplate and the learning application:

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

The SYNC synchronisation byte enables the receiver to identify the beginning of a frame. The length field given by LEN specifies the number of payload bytes that must subsequently be read. A frame with LEN = 0 contains an empty payload. Although the one-byte length field could theoretically represent up to 255 payload bytes, the prototype limits the payload to 128 bytes to restrict the required buffer size and transmission duration. 

The payload stored in the PAYLOAD field contains the information transmitted by the frame. Its structure depends on whether it contains the detected tree structure or the feedback message. Both payload formats are described in detail in @detection-payload and @feedback-payload.

To detect transmission errors, an XOR CHECKSUM is calculated from the length field and all payload bytes:
$
  C = L ⊕ P_0 ⊕ P_1 ⊕ dots.c ⊕ P_(L - 1)
$
For an empty payload, the checksum is equal to the length field. Upon reception, the checksum is recalculated and compared with the transmitted value. If the two values do not match, the frame is discarded.

=== Parent–Child Communication
The communication within the physical construction follows a request–response procedure and is always initiated by the parent brick. Depending on the current process, the communication is used either to retrieve the detected construction or to transmit feedback towards the connected bricks.

The command and acknowledgement bytes used in the two processes are summarised in the following table @command-bytes.

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
To request the detected subtree of a connected child, the parent node sends CMD_STATUS through the corresponding downstream interface. After receiving this valid request, the child node changes the transmission direction and responds with ACK_BUSY. This confirms that the request has been received and that the child is beginning to collect the required information by subsequently querying its own receiving interfaces. Once the subordinate information has been collected, it returns a DATA_FRAME containing its own payload and the payload of its complete subtree. This procedure is recursively repeated at every occupied parent–child connection. @communication-diagram-detection illustrates one such communication transaction at byte level.

#figure(
  image("figures/Single_wire_parent_child_communication.svg", width: 95%),
  caption: [Byte-level timing diagram of the detection communication between a parent and child brick]
)<communication-diagram-detection>

===== Detection Payload <detection-payload>
The payload returned during this sequence represents the detected construction tree. Each brick contributes a three-byte node header, followed by the serialised representations of its subordinate bricks shown in @node-header-format-detection.

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

The three most significant bits of NODE_ID encode the brick type, whereas the five least significant bits encode the individual instance number. This allows the learning application to distinguish between the cube and smashed brick types while retaining an individual address for assigning local feedback.
ORIENTATION contains a value from 0 to 3, representing the four possible rotations of the brick relative to its parent. Within CHILD_MASK, bit \(i\) indicates whether a child was detected at receiving interface \(i\). The cube brick can use bits 0 to 4 for its five receiving interfaces, whereas the smashed brick only needs one bit assigned to its single receiving interface.
The node representations of the connected children follow the node header in ascending order of the receiving-interface indices. The precise procedure through which the firmware collects and combines these node representations is described in @firmware-brick.

The baseplate does not add a node header of its own. Instead, it transfers the payload beginning with the first brick connected to it. If no root brick is detected, the baseplate transmits a DATA_FRAME with an empty payload.


==== Feedback Communication
The feedback communication is also initiated by the parent node, but with another command message. CMD_FEEDBACK signals to the child node the upcoming transmission of a FEEDBACK_FRAME. After receiving the command, the child responds with ACK_BUSY, indicating that it is ready to receive the frame.
The parent then transmits the complete FEEDBACK_FRAME. After processing and forwarding the frame, the child reports the result using either ACK_FINISHED or ACK_FAILED. The internal processing and forwarding logic is described in @firmware-brick.

===== Feedback Payload <feedback-payload>
The feedback payload uses the common frame format but contains pairs of brick identifiers and LED states:
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
    [1 byte],
    [...]
  ),
  caption: [Feedback payload]
) <node-header-format>

LED_STATE can assume one of two values: LED_GREEN or LED_RED. If a brick’s NODE_ID is not included in the feedback payload, that brick switches off its @LED. An empty feedback payload can therefore be used to deactivate all local feedback simultaneously.

=== Communication between Learning Application and Baseplate
The connection between the learning application and the baseplate uses the ATtiny1616 hardware USART at 115200 bit/s with eight data bits, no parity and one stop bit. The learning application controls an interaction session using the following single-byte commands and responses:

#apa-table(
  columns: (1.3fr, 1fr, 2fr, 2.5fr),

  table-label: <application-baseplate-communication>,

  breakable: true,
  placement: none,

  header: (
    [Message],
    [Value],
    [Direction],
    [Meaning]
  ),

  caption: [Messages exchanged between the learning application and the baseplate],

    [PC_CMD_START],
    [0x53 (S)],
    [Application → baseplate],
    [Start cyclic construction detection],

    [DATA_FRAME],
    [Variable],
    [baseplate → Application],
    [Current serialised construction],

    [FEEDBACK_FRAME],
    [Variable],
    [Application → baseplate],
    [Feedback calculated by the application],

    [PC_RESP_FB_DONE],
    [0x44 (D)],
    [baseplate → Application],
    [Feedback successfully forwarded],

    [PC_RESP_FB_FAILED],
    [0x4E (N)],
    [baseplate → Application],
    [Invalid feedback frame or forwarding failure],

    [PC_CMD_STOP],
    [0x58 (X)],
    [Application → baseplate],
    [Stop detection and switch off local feedback]
)

The sequence diagram in @communication-diagram-learning-application represents the following communication principle: After receiving PC_CMD_START, the baseplate begins the detection process and transmits the detected construction to the learning application using the DATA_FRAME format defined above.
After receiving the DATA_FRAME, the learning application answers with the FEEDBACK_FRAME calculated from the target comparison. The baseplate forwards this frame through the physical construction and responds with PC_RESP_FB_DONE if all detected bricks confirmed the feedback. If the received frame is invalid or at least one brick fails to confirm the feedback transmission, it responds with PC_RESP_FB_FAILED.

When the baseplate receives a PC_CMD_STOP from the learning application, it forwards an empty FEEDBACK_FRAME so that all local LEDs are switched off. It then terminates the cyclic detection by returning to its idle state.

=== Validation and Error Handling
Several validation mechanisms were implemented to prevent incomplete or corrupted transmissions from being interpreted as valid construction data:

- Each received byte is checked for a valid start and stop bit.
- The SYNC byte allows the receiver to locate the beginning of a frame.
- The received length is checked against the maximum payload size of 128 bytes.
- Timeouts terminate the reception of incomplete bytes or frames.
- The XOR checksum detects changes to the payload or length field.
- On the computer interface, incomplete or invalid frames are discarded and reception resumes by searching for the next valid SYNC byte.

The baseplate waits up to two seconds for the first byte of the application’s feedback response and allows a maximum interval of 100 ms between bytes within that frame. Detection cycles are currently separated by a delay of 550 ms, in addition to the time required for communication within the connected construction. These values describe the implemented prototype and are not general protocol requirements.


#figure(
  image("figures/gesamt-kommunikationssequenz.pdf", width: 90%),
  caption: [Communication sequence between the learning application, baseplate and connected bricks],
)<communication-diagram-learning-application>


/////
== Firmware of Bricks and Baseplate <firmware>
To communicate changes in the physical construction to the learning application and return the resulting feedback to the relevant bricks, the distributed electronic components must coordinate their behaviour. The firmware of the bricks and the baseplate, explained in this section, implements this coordination by controlling construction detection, data transmission and feedback processing.


=== Brick Firmware <firmware-brick>
The brick firmware is responsible for collecting its local subtree and controlling the feedback output. The implemented control flow is shown in @brick-state-machine. Part (a) presents the main processing sequence, while Part (b) details the initial detection of the upstream communication line and the brick’s relative orientation.

As shown in @brick-state-machine (b), the firmware initially releases all communication lines and configures the @LED outputs. It then monitors the four upstream contacts of the docking face. The contact through which the first valid request is received determines both the communication line used for subsequent exchanges with the parent and the relative orientation of the brick.
This orientation detection is determined just once after the microcontroller has started. Disconnecting the brick interrupts its centrally supplied power, causing the firmware to restart when the brick is connected again. The orientation is therefore detected again after every new physical connection.
 
#figure(
  image("figures/zustandsdiagram-brick.pdf", width: 100%),
  caption: [State machine of the brick firmware: (a) main processing sequence and (b) initial communication-line and orientation detection]
)<brick-state-machine>

==== Detection Process
When the state machine enters the detection state, it queries the available downstream interfaces in ascending order. Depending on the brick type, this means querying five interfaces or, for the smashed brick, only one. Communication with an individual child is handled by a dedicated child-polling function. A successful response provides the serialised payload of the child’s complete subtree. This subtree payload is stored temporarily until all configured downstream interfaces have been processed. If a child does not return a valid payload within the available attempts, its subtree is omitted from the current detection result. Successfully received child-subtree payloads are appended in ascending interface order to the brick’s own node payload according to the format specified in @detection-payload. For each included child, the corresponding bit in CHILD_MASK is set to one. The resulting complete payload therefore consists of the current brick’s own node payload followed by the payloads of its successfully detected child subtrees. It is then transmitted to the parent using the frame and message sequence defined in @communication-protocol.

Because every child performs the same processing before returning its result, the complete construction is acquired recursively without requiring an individual brick to store a global representation of the structure.

==== Correction of the Contact Offset <contact-offset>
As described in the mechanical realisation, the downstream data contact of one receiving face of the cube brick could not be placed in the same relative corner as the other downstream contacts. This causes the orientation reported by a child connected to this interface to contain an offset of one quarter turn. The brick firmware compensates for this deviation before it incorporates the child payload into the parent payload by incrementing the orientation value modulo four:

$
o_"corrected" = (o_"detected" + 1) mod 4
$

The learning application therefore does not require an additional interface specific correction because it consequently receives orientation values with a consistent interpretation for all receiving interfaces.

==== Feedback Processing <feedback-processing>
When the brick enters the feedback state, it receives and validates the FEEDBACK_FRAME according to @feedback-payload. It searches the payload for its own NODE_ID and, if it is included, applies the corresponding state to the local LED output. If the NODE_ID is not part of the frame, the LEDs are switched off.

The same FEEDBACK_FRAME is subsequently forwarded to the interfaces marked as occupied during the preceding detection cycle. Using the messages defined in @communication-protocol, the brick then reports to its parent whether the frame was successfully processed and forwarded.


=== Baseplate Firmware <firmware-baseplate>
The behaviour of the brick firmware is coordinated by the baseplate firmware, which initiates the detection and feedback processes. In addition to controlling the communication session, the baseplate mediates between the learning application and the physical brick structure.
It does not parse the construction, calculate spatial positions or evaluate the task. These operations are performed by the learning application described in the following @software-application.

#figure(
  image("figures/zustandsdiagram-baseplate.pdf", width: 80%),
  caption: [State machine of the baseplate firmware],
  placement: auto
)<baseplate-state-machine>

The implemented control flow is shown in @baseplate-state-machine. After initialisation, the baseplate releases its downstream communication line, configures its hardware USART and enters the idle state. It remains in this state until the learning application starts a new communication session. During an active session, the baseplate repeatedly initiates the detection of the connected construction by querying the brick attached to its single receiving interface. Since this is the first brick of the construction, its response already contains the serialised payload of the complete root subtree. If no valid root payload is received, the current construction is represented by an empty payload. Otherwise, the received subtree payload is forwarded without structural modification to the learning application.

==== Payload Transmission Control
To avoid transmitting identical construction data during every cycle, specific conditions determine when the baseplate sends data to the learning application.

The first payload after the beginning of a session is always transmitted, irrespective of a potentially retained result from a preceding session. For every subsequent payload transmission, the baseplate compares the current detection payload with the payload transmitted most recently. A new DATA_FRAME is transmitted only when the current payload differs from the preceding one. If the construction remains unchanged, the baseplate sends the unchanged payload only after 50 detection cycles as a heartbeat. This confirms that the communication link and the detection process remain active without continuously transmitting identical frames.

The current implementation inserts a delay of 550 ms between consecutive detection cycles. The complete interval between two results additionally depends on the number and arrangement of connected bricks as well as on possible retransmission attempts.

==== Feedback Forwarding and Session Termination
After transmitting a DATA_FRAME, the baseplate waits for the corresponding FEEDBACK_FRAME from the learning application. It then forwards the frame to the root brick using the same procedure as the feedback processing of the building bricks described in @feedback-processing. Afterwards, the baseplate reports to the learning application whether the frame was confirmed by the connected construction. The baseplate neither interprets the individual feedback entries nor controls the LEDs of the bricks directly. Its role is limited to receiving the frame from the learning application and initiating its distribution through the physical construction.

When the learning application terminates the session, the baseplate forwards an empty feedback frame to the root brick and since no brick NODE_IDs are contained in this payload, all local feedback outputs are switched off. The baseplate then ends cyclic detection and returns to the idle state shown in @baseplate-state-machine.



///
== Software Architecture and Backend Processing <software-application>
In the current prototype, the learning application is executed on a host computer and consists of a Python-based backend and a browser-based frontend implemented in JavaScript. Both components run on the same computer. The backend processes the data exchanged with the baseplate, while the frontend provides the selected target structure and presents the evaluated construction to the user. This section describes the implemented software architecture and backend processing. The three-dimensional visualisation and user-facing presentation of feedback are addressed separately in @user-interface-visualisation-feedback.

 === Implemented Software Architecture
The backend acts as an intermediary between the browser frontend and the baseplate. It communicates with the frontend through a WebSocket connection using JSON objects, while PySerial is used to exchange the binary frames defined in @communication-protocol with the baseplate.

A construction session begins when the frontend transmits the selected target structure to the backend. For each construction received from the baseplate, the backend reconstructs the detected tree, compares it with the selected target and generates a feedback frame for the physical bricks as well as an evaluated tree for the frontend.

Serial communication is handled by a dedicated worker thread, whereas the WebSocket server operates asynchronously. The two interfaces exchange different data representations: compact binary frames are used for communication with the baseplate, while JSON objects are exchanged with the frontend.
Since the prototype uses a single serial interface connected to one baseplate, only one browser-based construction session can be active at a time.

 === Deserialisation and Internal Tree Models
The backend receives the detected construction in the payload format defined in @detection-payload. A recursive parser converts this linear byte sequence into an object-based tree representation. Starting with the root node, the parser reads each node header and uses the transmitted CHILD_MASK to identify and recursively reconstruct its subordinate nodes in ascending port order. Each child node is thereby assigned to the receiving port through which it is connected to its parent. Each detected brick is consequently represented by a CubeNode containing:
    - The complete node identifier
    - The relative orientation
    - The receiving port through which it is connected to its parent
    - The child mask
    - The subordinate nodes

After reconstruction, the parser verifies that the complete payload has been consumed. Incomplete node data or remaining bytes cause the payload to be rejected as invalid.

The target construction uses a separate but structurally equivalent tree representation. It is stored as a JSON object and converted by the backend into a TargetNode. Each target node contains the required brick type and orientation, while its child nodes are assigned to the expected receiving ports. Since physical bricks of the same type are interchangeable within the task, the target structure does not contain individual brick identifiers. Both representations nevertheless share the same hierarchical organisation and can therefore be compared recursively.

// Consider combining these two sections
=== Target Comparison and Feedback Data Generation <comparison-feedback-generation>
Once the detected payload has been reconstructed, the comparison begins at the root nodes of the detected and target structures and proceeds recursively through the receiving ports of each brick.

For every position occurring in either structure, the algorithm compares the presence, type, relative orientation and structural placement of the corresponding brick. The individual node identifier is not used to determine whether a brick is correctly positioned but is retained to address the physical brick when generating local feedback.

The comparison then creates an evaluated tree that combines actual and expected information. Each position is assigned to one of five internal states, as summarised in @comparison-states.

#apa-table(
  columns: (1fr, 4fr),

  table-label: <comparison-states>,

  header: (
    [State],
    [Assignment by the comparison algorithm],
  ),

  caption: [Internal states of the evaluated construction tree],

  [CORRECT],
  [A brick is present with the required type, orientation and connection],

  [WRONG],
  [A brick is present but differs from the target],

  [ATTACHABLE],
  [A target brick is missing, but its parent has already been placed correctly],

  [BLOCKED],
  [A target brick is missing and cannot yet be placed because its parent is missing or incorrect],

  [UNEXPECTED],
  [A brick is present where the target does not contain a brick],
)

If a brick is connected to a receiving port that is not occupied in the target structure, the algorithm searches the remaining unoccupied ports of the same parent for an expected brick of the same type. If such a position exists, the brick is classified as WRONG and the expected port is stored in the comparison result. Otherwise, the brick and its subordinate structure are classified as UNEXPECTED. The comparison also considers the validity of the complete structural path. If a parent brick is missing or incorrect, its subordinate bricks cannot yet occupy valid positions within the target structure and are therefore marked as WRONG. Conversely, an unoccupied target position is classified as ATTACHABLE only if its parent path is correct.

In addition to these general internal states, each evaluated node also contains an error mask. Its individual bits indicate whether the deviation relates to the brick type, orientation, receiving port, parent path or the presence of an unexpected element. This additional separation allows the same comparison result to support different forms and levels of feedback.

When the comparison is complete, two output representations are generated from the evaluated tree: For the physical construction, a brick-specific feedback data set for all physically present nodes is generated and converted into the feedback frame defined in @feedback-payload. For the frontend, the evaluated tree is converted into a JSON-compatible representation. This representation contains both detected bricks and currently unoccupied target positions, together with their assigned states and expected properties.




///
== Frontend, Visualisation and Feedback <user-interface-visualisation-feedback>
The backend transfers the evaluated tree to the frontend as a JSON object. Based on the structural and feedback information contained in this representation, the frontend calculates the spatial poses of the individual bricks and generates the user-facing visualisation described in the following section.

=== Calculation of Spatial Poses <calculation-poses>
The evaluated tree received from the backend contains no absolute spatial coordinates. Instead, the frontend calculates the position and orientation of each brick from its type, receiving port, relative orientation and parent–child relationship. The same calculation is used for target structures and evaluated constructions.

For the calculation, the implementation uses a local coordinate system for every brick: The z-axis represents the vertical axis of the brick, and the docking face is oriented towards its local negative z-direction. For the cube brick, receiving ports \(0\) to \(4\) correspond to the directions \(-x\), \(-y\), \(+z\), \(+x\) and \(+y\). The smashed brick provides only one receiving port in its local \(+z\)-direction.

For every connection, the local position of a child brick is determined by the direction and distance assigned to the receiving port of its parent:

$
bold(p)_("local") = bold(d)_(t, p) times l_(t, p)
$

where $t$ denotes the type of the parent brick, $p$ the receiving port, $bold(d)_(t, p)$ its direction vector and $l_(t, p)$ the distance between the model origins. The distance $l_(t, p)$ depends on the geometry of the parent brick and the selected receiving port. The reduced height of the smashed brick is therefore considered when positioning a child connected to its upper receiving face.

The local orientation of a child is represented using a quaternion that consists of an attachment rotation and an additional twist rotation:

$
q_("local") =
q_("attachment")(t, p)
times
q_("twist")(o).
$

The attachment quaternion $q_("attachment")(t, p)$ aligns the docking face of the child with the selected receiving face of the parent. The twist quaternion $q_("twist")(o)$ represents the detected relative rotation $o$. The four transmitted orientation values are mapped to rotations of $90 degree$, $0 degree$, $-90 degree$ and $-180 degree$ around the local $z$-axis. This assignment aligns the orientation of the digital models with the orientation convention used by the connection-detection system.

The first brick connected to the baseplate forms the root of the displayed construction and therefore has no parent brick. Because of this, its local position is set to the origin of the scene and its local orientation is derived solely from its transmitted relative rotation value. For every other subordinate brick, the local transformation is combined with the transformation of its parent:
$
T_("global", c)
=
T_("global", p)
times
T_("local", c).
$


This calculation is applied recursively throughout the tree. Local connection information is therefore sufficient to derive the global position and orientation of every brick, and the backend does not need to transmit absolute coordinates.

==== Three-Dimensional Visualisation
The resulting construction is then displayed using corresponding GLB models of the two brick types placed within a Three.js scene. Using OrbitControls, the scene can be rotated and enlarged through mouse or touch input, allowing the construction to be inspected from different perspectives.


#figure(
  image("figures/bricks-and-visualization.jpg", width: 40%),
  caption: [Correspondence between a physical brick construction and its reconstructed three-dimensional model]
)<visualisation-construction>

=== Digital and Local Feedback
The three-dimensional representation of the evaluated construction is augmented with visual cues derived from the comparison states described in @software-application. These cues are complemented by local feedback from the LEDs integrated into the physical bricks. Table @implemented-feedback-presentation summarises how each state is represented across both feedback levels, while @visual-brick-feedback illustrates the digital representation of the states CORRECT, WRONG and ATTACHABLE.

#apa-table(
  columns: (1.2fr, 2.4fr, 2.2fr),

  table-label: <implemented-feedback-presentation>,

  header: (
    [Evaluation state],
    [Representation in the frontend],
    [Feedback on the physical brick],
  ),

  caption: [Implemented presentation of the evaluation states],

  [Correct],
  [Green pulsing outline],
  [Green LED light],

  [Wrong or unexpected],
  [Red pulsing outline],
  [Red LED light],

  [Attachable],
  [Semi-transparent ghost brick],
  [No physical output],

  [Blocked],
  [Not displayed],
  [No physical output],
)

#figure(
  image("figures/digital-feedback@3x.png", width: 90%),
  caption: [Implemented visual feedback for the states (a) CORRECT, (b) WRONG and (c) ATTACHABLE],
)<visual-brick-feedback>

Physically present bricks retain the appearance of their corresponding digital models, while coloured outlines indicate the evaluation result. Green represents a correctly positioned brick, whereas red indicates an incorrect or unexpected brick. A currently attachable target brick is displayed semi-transparently as a visual indication of an available next construction step. Target bricks that cannot yet be reached because their preceding construction path is incomplete are not displayed.

The global feedback in the frontend is coordinated with the local LED feedback of the physical bricks. A brick shown with a green or red outline is illuminated in the corresponding colour. Missing target bricks have no physical counterpart and are therefore represented exclusively in the frontend.

To indicate both the current construction progress and the completion of the task, a progress bar additionally shows the proportion of the target construction that has already been completed correctly.

=== User Interface and Task Selection
The visualisation process is not limited to displaying the detected bricks and their feedback states during the construction task. It begins on the dashboard, where the learner selects the target structure that defines the subsequent task.

The dashboard presents the available target constructions as selectable cards. Each card contains a three-dimensional preview generated from the corresponding target-tree data. Selecting a card opens an enlarged preview window in which the construction can be rotated and inspected from different viewing angles. The learner can then either cancel the selection and return to the dashboard or confirm the selected construction.

The preview window additionally contains two level options from which the learner can choose. Although the selected level is transferred together with the target structure, it does not currently affect the task behaviour. It is intended to support a future differentiation of task difficulty.

After the target structure has been confirmed, the live construction view is opened and the selected target is transferred to the backend. During the task, this view displays the evaluated construction using the spatial reconstruction and feedback representations described in the preceding sections. The progress bar is placed at the top of the interface and indicates the proportion of the target construction that has already been completed correctly.

The construction session can be terminated using the button in the upper area of the live view. The frontend then returns to the dashboard, where another target construction can be selected. The complete interaction sequence is illustrated in  @target-selection-window, @preview-window and @construction-session-view.

#figure(
  image("figures/target-selection.png", width: 80%),
  caption: [Target-selection dashboard of the learning application],
)<target-selection-window>

#figure(
  image("figures/preview2.png", width: 80%),
  caption: [Preview of a selected target structure],
)<preview-window>

#figure(
  image("figures/bauen2.png", width: 80%),
  caption: [Construction session view with brick-specific feedback and overall status information],
)<construction-session-view>
