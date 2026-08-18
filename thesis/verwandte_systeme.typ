
= Related work
Physical building brick systems have become a promising form of @TUI because their materia properties and haptic feedback allow users to manipulate digital information through familiar physical actions. Existing approaches can broadly be divided into systems employing passive bricks and systems that use active bricks @RFIBrick@NFCStack. 

In this context, passive bricks do not perform local computation. Instead, their identity position and connectivity within a construction is determined by an external sensing system @Lumino.
Active brick, by contrast, contain embedded electronic components and actively participate in the detection process@roBlock@ActiveCube.

The following sections review concepts based on these two approaches to establish the relevant state of the art.

== Passive Brick Systems
Passive bricks can be detected using different sensing principles, including computer vision, capacitive sensing and @RFID. 

*Computer-vision-based* systems use one or more cameras to determine the structure constructed from the physical bricks. _duplotrack_ employs such an approach: By analysing the depth data and colour information of the bricks using an RGB-D camera, it can provide real-time assistance during the construction process of _LEGO DUPLO_ models.
A general limitation of such a camera based detection is that the relevant parts of the construction must remain visible. Bricks that are temporarily occluded by others bricks or the user´s hands therefore result in incomplete or incorrect detection. Moreover, the camera usually has to be positioned and calibrated according to the dimensions and lighting conditions of the interaction area @DuploTrack.

A infrared camera is hingegen used by Baudisch et al. (2010). For his _Lumino_ bricks, he relies on visual markers and a light-conducting fibre-optic bundle that transfers its fiducial marker to the surface of an interactive table. The table’s internal infrared camera then captures the resulting composite marker image and uses it to reconstruct the stack. But, due to the high light loss at the junctions between the optical fibres, the stacking height is limited to 5 layers @Lumino.

///capacitive detection
_CapStones_ uses *capacitive sensing* to extend applications on conventional touchscreens with graspable physical objects. The @3D arrangement of the game pieces can be detected on conventional devices by 'channelling' the user’s capacitance through a system of internal wires and connecting pins from the top of a stack to the touchscreen. Users can place the blocks on the screen, move them around and combine them into vertical stacks. However, as the capacitance of the internal wires exceeds the sensor’s threshold when they are extended, the maximum stack height is limited to three to four layers. Furthermore, the blocks must always be touched to be visible, as current tablet sensors are calibrated to specific touch detection thresholds @Capstones.


In the _ProtoBricks_ system, capacitive detection is supplemented by a colour sensor. While capacitive touch sensors integrated into the base plate detect user’s body through the conductive blocks and determine their spatial placement, the colour sensor detects the colour and thus the type of the brick that has been placed. 
However, it is not possible to capture information regarding precise rotation of the individual bricks. Furthermore, the bricks must be placed one at a time, otherwise, the system will only recognise a single action @Protobricks.

//RFID
Besides camera-based and capacitive sensing, physical brick constructions can also be detected using *@RFID*. In such systems, the bricks are considered as passive since they operate without batteries and obtain the required energy wirelessly from an @RFID reader.

The author uses such a radio-based recognition principle with modified @UHF @RFID tags for his _RFIBricks_ system. Each tag is separated into an antenna and a chip component, which are connected through conductive neodymium magnets. The resulting circuit functions as a contact switch: the tag becomes readable only when the corresponding physical connection between two blocks is established. 
The relative orientation of two building blocks is detected by the four @RFID contact switches located on the surfaces of the cubes, each of which triggers a specific ID combination depending on the rotation. 
However, to avoid excessive complexity and density of tags, these contacts are only located on the top and bottom surfaces. The resulting constructions are therefore limited to one-dimensional stacks @RFIBrick.

_RFIMatch_ is closely related to _RFIBricks_ and similarly combines modified UHF RFID tags with magnetic elements. In contrast to _RFIBricks_, _RFIMatch_ is designed to detect associations without requiring precisely aligned physical contacts. Its sensing mechanism is therefore less dependent on the exact orientation and alignment of the interacting objects @RFIMatch.

Since both approaches operate in the @UHF frequency range, the required readers can be comparatively expensive, large and power-intensive @NFCStack. 
To overcome this issue, the _NFCStack_ concept uses a lower cost MFRC522 @NFC reader. A multiplexed reader in the base station transmits its signal through antenna extensions integrated into the bricks. Depending on the brick design, this signal is relayed through transmission lines or inductively coupled coils towards the top of the stack.
As with _RFIbricks_, it is possible to identify the individual blocks and determine their position and orientation within a stack. But its physical connectivity is also restricted to vertical stacking and therefore supports only one-dimensional constructions @NFCStack.

All three @RFID concepts share two limitations: The limited transmission bandwidth of the technology means that, in all three concepts, the system becomes less reliable when there are too many active tags operating simultaneously. Furthermore, the achievable stack height is limited because the available signal strength decreases with increasing distance from the reader and with every additional coupling interface @RFIBrick@RFIMatch@NFCStack.

== Active Brick Systems
Unlike passive systems, active bricks integrate electronic processing and communication components into the indicidual bricks. The bricks can therefore contribute directly to detecting the construction. To achieve this, the resulting topology information can be either transferred thorugh the physical chain of bricks, or transmitter wirelessly by the individual bricks.


Such a principle is followed by E-Block, introduced by Wang et al. (2013). _E-Block_ is a tangible programming tool in which children arrange physical bricks into a sequence to specify the path of a virtal character. When activated, each brick transmits its identifier wirelessly to a receiver connected to the host computer. The communication between neughbouring blocks is limited to a sequential activation process which follow a parent child logic: A parent brick uses an infrared signal to activate an adjacent child brick. The child then transmits it identifier to the computer and enables its own infrared transmitter to activate the next brick in the sequence. Because the connected bricks transmit their identifiers one after another, the host computer can infer their order from the arrival times of the messages and reconstruct the one-dimensional structure. This limits the representable topology to a sequential arrangement @EBlock.


The _i-Cube_, a digital educational tool designed to support cognitive development, uses a related sequential round-robin principle to identify neighbouring relationships. Neighbouring bricks are detected locally using inductive sensors and a fire-and-latch protocol. In this protocol, the transmitter on each face of every  brick in the system is sequentially activated to capture the complete structure. To detect the relative orientation, each face contains four symmetrically arranged inductive receivers instead of one. When a transmitter on an opposing face of a neighbouring brick is activated, one of these receivers is triggered. This enables the system to identify the connected faces and the rotation angle between the two bricks. This approach allows three-dimensional constructions to be detected, including the local orientation of individual bricks. Four magnets arranged on each brick face ensure that the contacting faces remain physically attached @iCube.

The concept of roBlocks also uses magnets, employing them as both mechanical connectors and electrical contacts. Once connected, the bricks form an ad hoc communication network through which they exchange and broadcast data. A dedicated communication brick called _Comm-Block_ collects network information and forwards it wirelessly to the host computer. This special brick also initiates topology discovery by querying the connected bricks and collecting reports on their local connections. In addition to the Base brick, a Power brick supplies electrical energy to the network via the magnetic contacts. Consequently, the individual bricks do not require separate batteries. This distinguishes the system from previously discussed active-brick approaches, where every brick must be charged or equipped with a replaceable battery @roBlock. 


A comparable central power-supply principle is also used in _ActiveCube_, where the Base  brick provides the required energy. The electrical connection between adjacent bricks is established through three concentric terminals located at the centre of each  brick face, which are used for the communication network and Ground, as well as additional mechanical connection hooks that provide the power supply. The ActiveCubes form a wired RS-485 network and communicate using LON technology.
When a new brick is attached, both participating cubes report the connection with their  brick identifier as well as their connected  brick face to the  brick base. The bricks obtain the information about the connected face through one of the connection hooks used for the power supply. The child detects the voltage applied to this input hook and can immediately determine which of its six faces is connected. 
The host computer combines the different @ID messages to update the connection-status tree that represents the topology of the physical three dimensional construction @ActiveCube.

 @related-work illustrates the brick-face interfaces of _i-Cube_, roBlocks, and ActiveCube, which illustrate different approaches to mechanical connection, electrical contacting and local connection detection.

#figure(
  image("figures/related-work@3x.png", width: 95%),
  caption: [Interface of a) _i-Cube_, b) _roBlocks_ and c) _ActiveCube_ @iCube@roBlock@ActiveCube]
)<related-work>


=== Integrated Sensors and Actuators
In addition to contributing the topology detection, active bricks can also support local output and addional sensing:
_ActiveCube_ includes functional cubes containing components such as gyroscopic sensors, vibration actuators and @LED matrices @ActiveCube. _i-Cube_ provides illuminated faces and local audio output through vibration speakers @iCube. _roBlocks_ includes specialised actuator blocks equipped with geared motors, piezoelectric speakers, or @LED, whereas _E-Block_ uses an @LED on the upper surface of each brick to communicate its current status @roBlock@EBlock.

== Comparison of Active and Passive Brick Systems
Active and passive brick systems present different advantages and limitations. 
Passive blocks operate without individual batteries and do not perform local computation. This reduces maintenance at the brick level and makes them particularly suitable for systems involving large numbers of physical components. Their comparatively simple internal construction may also reduce the cost of producing individual blocks.
However, passive blocks depend on external sensing infrastructure. Camera-based systems like _DuploTrack_ are susceptible to occlusion when blocks are covered by other objects or by the users’ hands. They may also require calibration and specialised camera or display hardware. Capacitive, optical and @RFID based approaches can be limited by signal attenuation, reading range, or the maximum detectable stack height.

Active blocks contain embedded electronic components, such as microcontrollers, communication modules and, depending on the system, individual batteries.
Because they participate directly in the recognition process, they generally enable reliable detection of stacking operations and connections between neighbouring blocks. Depending on the system, this can include the detection of three-dimensional constructions and the local orientation of individual bricks, as demonstrated by _i-Cube_. Their local electronics and power supply can additionally support integrated sensors, actuators and displays which can provide rich multimodal interactions. But these capabilities increase both the complexity and the cost of each brick.
The required processors, sensors and communication modules increase manufacturing costs and can limit scalability when large numbers of blocks are needed. In systems such as _E-Block_ that depend on physical cables or wired connections, the users’ freedom of movement may be restricted.
Battery-powered systems like _E-Block_ and _i-Cube_ require regular charging or battery replacement, resulting in additional maintenance effort. Watanabe et al.’s _ActiveCube_ (2004) and Schweikardt and Gross’s _roBlocks_ (2006) reduce battery maintenance by distributing power through electrical contacts between connected blocks, although this still requires more complex brick hardware.

The choice between passive and active blocks therefore represents a trade-off between brick-level simplicity and the recognition and interaction capabilities of the overall system.