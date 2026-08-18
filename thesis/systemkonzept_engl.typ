#import "functions.typ": req, apa-table


= Concept Development
The requirements analysis conducted in @requirements-analysis provides the foundation for the system concept. The objective of the concept development is to translate the individual pedagogical, interaction-related, functional, mechanical and technical requirements into a coherent overall system.

== Usage Scenario
The usage scenario describes the general sequence of a guided construction task from the learners perspective: At the beginning, a target structure is selected from a predefined variety of tasks in the learning application and presented as a reference. It is selected either by the teacher or, where appropriate for the learning context, by the learner itself.
Afterwards, the learner begins connecting the first cube to the Baseplate followed by adding further cubes until the specified target structure has been reconstructed. Already completed steps keep being able to be modified as cubes can be detached, repositioned and reconnected at any point during the task. 
Following each modification, the system detects the current physical configuration and updates its digital representation, which is then compared with the target and, depending on whether it is correct, result in one of two outcomes:
If the current configuration constitutes a valid part of the target structure, the learner can continue with the next construction step. But if a deviation is detected, the system provides corresponding feedback so that the affected step can be reviewed and corrected.
The task is completed once the physical construction fully matches the target structure. It can then either be repeated or a new target structure is selected. The activity diagram in @task-flow illustrates the sequence of a single construction task and therefore terminates once that task has been completed. 

#figure(
  image("figures/aktivitätsdiagramm.svg", width: 95%),
  caption: [Activity diagram of a single guided construction task]
) <task-flow>

#pagebreak()
The task is completed at the learner’s individual pace and does not impose a fixed time limit. Additionaly, a specific construction sequence is required only where it follows necessarily from the spatial dependencies of the target structure.

Throughout the process, the teacher retains responsibility for the pedagogical guidance of the learner and can adapt the available selection of tasks or provide additional explanations, if the feedback or assistance offered by the system is insufficient or not understood. Automated feedback is therefore intended to support the teacher during periods of independent work and should not replace individual pedagogical guidance.

== System Architecture
To support the usage scenario described above and address the associated detection and feedback requirements, the proposed architecture uses an active Brick system in which the building bricks participate directly in detecting the physical construction and providing local feedback. The Baseplate coordinates the physical Brick system and mediates communication with the learning application. The learning application forms the digital part of the system and supports the presentation and evaluation of the construction task.

 This high-level allocation of roles is translated into five functional subsystems, which structure the subsequent concept development:
-  Physical Design and Connection Subsystem: Provision of the physical building bricks, housings, mechanical connections
-  Electronic Connection and Power Subsystem: Identification of individual building bricks, detection of connections and relative rotations, provision of the power
-  Data, Communication and Software Subsystem:	transmission of the detected structural data, generation of a digital structure model, spatial reconstruction of the physical construction
-  Task and Interaction Subsystem:	Selection and presentation of the target structure, provision of the basic task workflow
-  Visualisation and Feedback Subsystem:	Comparison of the detected and target structure, visualisation of the current construction, generation and output of feedback
The architecture necessitates that a physical action cannot be interpreted directly by the learning application. Instead, the connection must first be established mechanically and detected electronically before its local connection data is transformed into a digital model of the overall structure. Only once this model is available, the learning application can compare the detected construction with the selected target structure and generate task related feedback. 

The design decisions underlying this architecture are developed and justified in the following subsystem sections.

==== System Components and Responsibilities
The functions identified in the preceding functional decomposition are assigned to the components of the overall system. The technical system consists of:
  - Several active bricks
  - One Baseplate
  - One digital computer based learning application
Learners and pedagogical professionals are external actors and therefore not part of the technical system components. @system-components provides an overview of the elements of the overall system and their primary responsibilities, whereas @system-architecture illustrates the principal interactions between them.

#apa-table(
  columns: (1fr, 2fr, 4fr),

  table-label: <system-components>,

  header: (
    [Element],
    [Classification],
    [Primary Responsibility],
  ),

  caption: [System Components and Responsibilities],

    [Learner],
    [External actor],
    [Select the target structure, assemble the current physical structure, respond to feedback],

    [Teacher],
    [External actor],
    [Adapts the selection of tasks, guides the learning process, provides additional support],

    [Building bricks],
    [Technical component],
    [Form the physical construction, provide local connection data, present local feedback],

    [Baseplate],
    [Technical component],
    [Provide the starting point and central power supply, mediate between the building-Brick system and the learning application],

    [Learning application],
    [Technical component],
    [Provide the target structure, process structural data, visualise the current construction, compare it with the target structure, generate feedback],
)

#figure(
  image("figures/systemarchitektur-komponenten.svg", width: 95%),
  caption: [High-level architecture of the proposed Brick-based learning system]
)<system-architecture>


== Conceptual Definition of the Levels of Connection <topology>
Within the proposed TUI, each building Brick functions as a phicon: it represents an element of the construction, while its physical manipulation simultaneously provides input to the digital system. To describe how these phicons are connected unambiguously, a distinction is made between the mechanical, electronic and logical connection levels.: Each building Brick has one docking face through which it is connected to the existing construction and, depending on its type, one or more receiving faces to which further building bricks can be attached. The docking face contains the electronic upstream interface, whereas each receiving face contains a downstream interface. In the digital model, the building Brick already connected to the system is represented by the parent node, while the newly added building Brick is represented by the child node. A connection can therefore be described at the three levels presented in the following @terminology-connection:

#apa-table(
  columns: (1fr, 2fr, 2fr),

  table-label: <terminology-connection>,

  header: (
    [Level],
    [Term],
    [Definition],
  ),

  caption: [Terminology across the connection levels],

    [Mechanics], [Connection face], [General term for all physical building-Brick faces through which a connection can be established],

    [Mechanics], [Docking face and Receiving face], [Connection faces of the building bricks],

    [Electronics], [Upstream and downstream interface], [Electrical contacts located on the connection faces],

    [Data model], [Parent and child nodes], [Directed relationship within the digital tree],

    [In general], [Parent Brick], [Building Brick that is already connected to the system],

    [In general], [Child Brick], [Building Brick whose docking face is connected to a receiving face of the parent Brick],
  )

== Physical Design and Connection Subsystem <physical-concept>
Physical interaction with the system begins with the building blocks and their connections. Their design shapes how learners experience the construction process while also determining how reliably the resulting physical arrangement can be interpreted by the technical system. This chapter therefore describes the physical design that forms the tangible foundation of the system. In accordance with the terminology defined in @topology, the terms docking face and receiving face are used throughout the following sections.

=== Basic Geometry and Block Types <geometry-Brick>
In accordance with requirement #req("C4"), the connection faces must allow two connected bricks to assume a discrete and unambiguously interpretable relative orientation. Existing systems such as _i-Cube_, _RFIBricks_ and _NFCStack_ similarly employ fourfold rotational symmetry to distinguish the orientation of connected bricks @iCube @RFIBrick @NFCStack. Based on this principle, a standardised square geometry is selected for all connection faces. This geometry permits a rotationally symmetrical contact arrangement and provides four mechanically valid orientations in increments of 90°.
This geometry permits a rotationally symmetrical contact arrangement and allows four mechanically valid orientations in increments of 90°.
Based on the standardised connection geometry, two building-Brick types are defined in accordance with #req("G3")
- The cube Brick wth six square connection faces, as specified by (G1)
- The smashed Brick with two opposing square connection faces, while its remaining faces cannot be used to establish connections

Whereas the cube Brick supports linear as well as branched two- and three-dimensional constructions along its three mutually orthogonal spatial axes, the flat Brick permits only linear connections along its local z-axis. @Brick-type illustrate the two Brick types.

#figure(
  image("figures/bricks-physisch.jpg", width: 50%),
      caption: [Image of the two brick types in comparison, left: cube brick; right: smashed brick],
)<Brick-type>

==== Directed Design of the Connection Faces
To limit the complexity of manufacturing and connection detection, two functionally distinct types of connection faces are defined. The docking face connects a Brick to the existing construction, whereas the receiving faces allow additional bricks to be attached through their respective docking faces. To enable three-dimensional constructions as required by #req("C3"), the cube Brick must provide connection possibilities along all three of its local spatial axes. As one of its six connection faces serves as the docking face, the remaining five are designed as receiving faces. Because the smashed Brick has only two opposing connection faces it can have only one receiving face. Consequently, a valid connection can only be established between a receiving face of the parent Brick and the docking face of the child Brick.

To identify the intended target connection and orientation between two bricks, the _Receiving faces_ are differentiated by colour. This directed design provides the physical basis for representing the resulting construction as a parent child structure. The corresponding digital structure model is described in @structure-model.

==== Mechanical Connection Principle
The mechanical connection principle was selected with regard to stability, unambiguous alignment and the low operating force specified by #req("C6"). For the prototype a combination of a mechanical form fit mechanism and magnetic assistance is used: The docking face contains recessed guiding elements, while the receiving faces contain corresponding protruding elements. Magnets with complementary polarities draw compatible faces together and stabilise the resulting connection without requiring the force associated with a conventional snap-fit mechanism.

Together, the guiding elements and magnets implement a mechanical constraint as described in @token-constraint. They align the electrical contact areas and impede invalid connections because incompatible interface geometries do not fit and equally polarised magnets repel one another. The available connection possibilities are therefore partly conveyed through the physical design itself.

=== Housing and Maintainability
The housing must completely enclose the electronic components and magnets and prevent small parts from becoming detached unintentionally, as specified by #req("S2"). At the same time, it must remain possible to be disassembled without damaging it in order to support assembly, maintenance and component replacement #req("S3").

For this purpose, a modular Brick housing structure is proposed which consists of three separate parts:
- A supporting frame incorporating the docking face
- Interchangeable side-wall modules containing the receiving faces
- A final cover that closes the housing

This structure offers two main advantages: It allows the electronic components of the individual connection faces to be mounted separately before the modules are assembled into a complete building Brick #req("S3"). And, as the receiving-side modules follow the same design regardless of their position or the Brick type, they can be installed interchangeably and replaced individually when necessary.

=== Mechanical Concept of the Baseplate
The Baseplate forms the starting point of every physical construction and consists of an enclosed housing for its technical components such as one receiving face, whose mechanical geometry corresponds to that of the building bricks. The first Brick is placed on the Baseplate using its defined docking face which establishes it spatially and logically as the first building Brick of the construction.

Additional receiving faces could enable several constructions with multiple starting points but would require an extension of the digital structure model and additional rules for comparison with the target structure. Consequently, the basic concept is limited to a single connection point.

#figure(
  image("figures/baseplate.jpg", width: 50%),
  caption: [Image of the baseplate with its single receiving face]
)<Baseplate>


== Electronic Detection and Power Subsystem
Once the building bricks are physically connected, their arrangement must be made accessible to the technical system. The electronic design determines how reliably changes in the construction can be detected while keeping the active Brick system operational. This section therefore describes the electronic foundation for sensing and supplying the physical construction.
In accordance with the terminology defined in @topology, the term upstream interface refers to the electronic interface on the docking face, whereas downstream interface refers to the electronic interface located on each receiving face.



=== Selection of the Electronic System Architecture <electronic-system-architecture>
The selected electronic architecture results from the information that must be obtained directly from the physical construction: Each Brick must be identifiable, while its connected face and relative rotation must be detected locally in order to reconstruct branching three-dimensional structures #req("DET1") #req("DET2") #req("DET3"). In addition, feedback must enable learners to identify which part of the construction requires attention and must therefore be clearly linked to the to the affected physical Brick #req("FB2").

Passive bricks would reduce the electronic complexity of the individual components, but their state would have to be determined entirely by external sensing infrastructure. Camera-based approaches depend on an unobstructed view of the construction and may require calibration to the interaction area, making them susceptible to occlusion by other bricks or the learner’s hands @DuploTrack. The reviewed capacitive and optical approaches are tied to a sensing surface and limited to a detectable stack height @Capstones @Lumino. The construction systems based on @RFID likewise support only vertical stacks and a limited stacking number. In addition, the UHF readers employed by systems such as _RFIBricks_ can be comparatively expensive, large and power-intensive @RFIBrick @NFCStack which makes him unbrauchbar für den schulischen gebrauch and conflict particularly with calibration-free use #req("IA2")

An active architecture addresses these limitations by moving the acquisition of connection information to the individual bricks. Local electronics allow each Brick to provide its identity, evaluate the state of its own interfaces and control a local feedback output. The information required for reconstructing the construction can therefore be obtained at the physical connection itself rather than inferred entirely through external sensing. This direct acquisition of connection data and the ability to address individual physical bricks provide the basis for selecting active bricks @iCube @ActiveCube.

Communication between the active bricks is established through their physical connections rather than through a separate wireless network. The Problem of wireless transmission of an identifier, as used by _E-Block_, is that it would not by itself indicate which faces are connected or how neighbouring bricks are oriented @EBlock. Since electrical contacts are already required to distinguish the relative rotation at each connection, the same interfaces can also be used to transmit the resulting data. This avoids an additional wireless communication layer and creates a direct correspondence between the physical construction and its electronic connections. The resulting system is thus based on active, contact-connected bricks, drawing on principles found in _i-Cube_, _roBlocks_ and _ActiveCube_ @iCube @roBlock @ActiveCube.


=== Centralised Power Supply
In accordance with #req("EL1"), the building bricks must operate without individual batteries or rechargeable cells to reduce maintenance and decrease the necessary space within each Brick. 
The active-Brick systems of Watanabe et al. (2004) and Schweikardt and Gross (2006) address this requirement through a dedicated central power component @ActiveCube@roBlock. 
Following these approaches, the Baseplate, which already forms the fixed starting point of the proposed construction, is also used as its central power-distribution point. It supplies the connected bricks through their electrical interfaces, while each Brick uses the incoming power for its own electronics and forwards it through its downstream interfaces to subsequent child bricks.

=== Functional Structure <functional-structure>
The building bricks and the Baseplate share several fundamental electronic functions, including control, electrical interfacing and power distribution. However, these functions are distributed differently between the decentralised bricks and the central Baseplate. @blockdiagram-concept presents the resulting functional structure and the interfaces between the two component types.

#figure(
  image("figures/concept-blockdiagramm.svg", width: 90%),
  caption: [Functional structure of a) Brick and  b) Baseplate],
  placement: auto,
)<blockdiagram-concept>

Each building Brick acts as a local node within the physical construction, with its control unit maintaining the brick’s identity and type while processing the signals received through its electrical interfaces. The upstream interface connects the Brick to its parent, whereas a type dependent number of downstream interfaces enables child bricks to be attached. Power received from the parent supplies the local electronics and is subsequently forwarded through the downstream interfaces. In addition, an integrated visual output allows feedback to be presented directly on the affected Brick.

In contrast to the distributed functions of the individual bricks, the Baseplate assumes the central role within the electronic subsystem. Through its single downstream interface, it connects to the first Brick, initiates the detection process and supplies the resulting construction with power. At the same time, its application interface mediates communication between the physical Brick system and the learning application. Since the Baseplate forms the root of the construction, it does not require an upstream interface. 

=== Electrical Interfaces and Local Detection Principle <electrical-interface>
Each mechanically defined connection is complemented by an electrical interface. Both interface types contain contacts for the power supply and the shared ground potential, but they differ in the arrangement and function of their signal contacts.
The principle used for determining relative rotation is adapted from _i-Cube_, which distinguishes four orientations through a symmetrical fourfold sensor arrangement @iCube. The proposed system transfers this principle to its directed electrical contact arrangement.
Accordingly, the docking face of each Brick contains four upstream orientation contacts positioned at its corners, with each contact representing one of the four mechanically permissible rotations. Each receiving face, by contrast, contains a single downstream child contact. Its position ensures that it connects to exactly one of the four upstream orientation contacts when two bricks are joined. Unlike _i-Cube_, the proposed arrangement therefore assigns different contact functions to the docking and receiving faces rather than providing the same transmitter-and-receiver arrangement on every face. The power-supply and ground contacts are arranged rotationally symmetrically so that they remain connected in all four permissible orientations. @contact-arrangement illustrate the resulting contact arrangements.

In support of #req("S4"), the recessed interface regions and mechanical guiding elements align and protect the electrical contacts, thereby reducing the risk of incorrect contacting and accidental short circuits.


#figure(
  image("figures/contact-arrangement@3x.png", width: 80%),
  caption: [Contact arrangement of a) upstream interface and  b) downstream interface],
)<contact-arrangement>

==== Detection of the Connection Face and Relative Rotation
When a child Brick is attached, the downstream contact on the receiving face of the parent connects to one of the four upstream orientation contacts on the child’s docking face. Because each receiving face has a separate downstream interface, the parent can query its interfaces individually and thereby determine through which of its faces the child is connected #req("DET2"). At the same time, the upstream contact activated on the child identifies which of the four relative rotations has been assumed #req("DET3").
The combination of the queried downstream interface and the contacted upstream orientation contact therefore defines the local spatial relationship between the two bricks. Once the connection has been detected, the same signal path is used for communication between the parent and child.

This information describes only the position and orientation of the child relative to its immediate parent. The electronic subsystem does not determine the global pose of an individual Brick within the complete construction. Instead, the learning application derives the global positions and orientations by combining all locally detected parent–child relationships, as described in @processing-learning-application.

=== Local Electronic Feedback Output
The active-Brick systems reviewed in the related work demonstrate how integrated visual outputs can communicate system states directly through physical bricks @EBlock @iCube @roBlock @ActiveCube. Drawing on this principle, each building Brick in the proposed system contains a simple visual feedback output, allowing feedback to be assigned directly to the affected physical Brick rather than being presented exclusively through the learning application.
The meaning, presentation and coordination of local and global feedback are specified in @types-feedback.

///////
== Data, Communication and Software Subsystem <software-concept>
The locally detected connection information must be combined into a coherent representation before the physical construction can be interpreted by the learning application. This transformation links the active Brick system with the digital processing of the construction task. The following section presents the communication and software concept underlying this proces and uses the terms parent node and child node to describe the directed relationships between connected bricks within the digital tree.

=== Overall Data Flow
Figure @sequence-diagram-overall-flow summarises the data flow between the learning application, the baseplate, and the active Brick system. After a target structure has been selected and stored by the learning application, the application sends a start signal to the baseplate. The baseplate then initiates recurring detection cycles in which the bricks recursively acquire their local connections and combine them into a serialised representation of the complete construction tree. This representation is forwarded unchanged to the learning application, where it is deserialised, spatially reconstructed, compared with the target structure, and translated into visual and Brick-specific feedback. The feedback message is returned through the baseplate to the affected bricks before the next detection cycle begins.
When the task is completed or terminated, the learning application sends a stop signal. The baseplate then terminates the detection process and waits for a new start signal.

This data flow separates physical acquisition from task-related interpretation. The baseplate and Brick system detect and transmit the physical construction without knowledge of the selected target, whereas the learning application manages the task, interprets the detected structure, and generates the corresponding feedback. 

#figure(
  image("figures/architektur-sequenzdiagramm.svg", width: 95%),
  caption: [Overall Data Flow During a Construction Task]
) <sequence-diagram-overall-flow>

=== Logical Structure and Data Model <structure-model>
The physical construction is conceptually represented as a directed tree: The Baseplate forms the root of the tree, each connected building Brick is represented by a node and each physical connection constitutes a directed edge between a parent and a child node.
The model reflects also the directed interface structure introduced in @electrical-interface: The defined docking face connects each Brick to its parent, while its receiving faces allow one or more child bricks to be attached. Consequently, each Brick can have no more than one parent but may have several children. As required by #req("C3"), both linear and branching three-dimensional constructions can therefore be represented by the model. By deriving the digital interpretation from the parent–child relationships and the resulting overall construction, the structure model applies the relational and constructive mapping principles introduced in @mapping.

To identify and interpret each building Brick within this tree, however, the parent–child relationship alone is insufficient. @node-infos summarises the additional information contained in each node for this purpose:


#apa-table(
  columns: (1fr, 3fr),

  table-label: <node-infos>,

  header: (
    [Information],
    [Meaning],
  ),

  caption: [Node Information],

    [Identity],
    [Unique assignment of the node to a physical building Brick],

    [Brick type],
    [Geometric and functional properties of the building Brick],

    [Relative rotation],
    [Orientation of the building Brick in relation to its parent],

    [Occupied connection faces],
    [Assignment of child nodes to the corresponding receiving faces],

    [Child nodes],
    [Node information of the directly connected child bricks and their subordinate structures],

  )

In accordance with #req("DET1"), the identity uniquely associates each node with an individual physical building Brick and subsequently allows local feedback to be assigned to that Brick. The Brick type is required to interpret its geometry and compare it with the corresponding element of the target structure. Finally, the relative rotation and occupied connection faces describe the local spatial relationship between the node and its parent and children.

=== Detection and Communication Concept
Communication within the physical construction follows the parent–child relationships represented by the logical structure model in @structure-model. Similar to the Comm-Block component of _roBlocks_, the Baseplate acts as the central coordinator and initiator of each detection cycle @roBlock. It starts the acquisition of the construction by querying the first connected Brick, after which communication proceeds recursively through the subordinate branches.
Communication between two connected bricks follows a request–response principle. The parent Brick requests information from a directly connected child Brick, which responds with its own node information and the serialised representations of its subordinate structures. This communication takes place through the upstream interface of the child Brick and the corresponding downstream interface of the parent Brick described in @electrical-interface. When the child Brick subsequently queries its own receiving faces, it assumes the role of a parent Brick in relation to the bricks connected below it.

Since only one signal path is available between the downstream child contact of the parent Brick and the contacted upstream orientation contact of the child Brick, the line must be used alternately for both transmission directions. The communication concept consequently employs a bidirectional single-wire half-duplex protocol. The exact message format, timing parameters and protocol implementation are described in the realisation section @communication-protocol.

==== Sequential Interface Query and Recursive Detectionn
During each detection cycle, the downstream interfaces of a building Brick are examined sequentially in a predefined order, following the round-robin query principle used in _i-Cube_ @iCube. This ensures that every available receiving face is checked regularly. If no child Brick is detected at an interface, the Brick continues with its next downstream interface. If a child Brick is detected, its complete subordinate structure is acquired before the parent Brick proceeds to the next interface.
The overall construction is therefore detected using a depth-first search. Starting from the Baseplate as the root, the system follows a detected branch to its outermost Brick before processing the next downstream interface of the preceding parent Brick. Once all downstream interfaces of a Brick have been queried, the Brick combines its own node information with the collected representations of its child nodes. The resulting representation of the complete subtree is then returned to the parent Brick.

This procedure is applied recursively until the Baseplate receives a serialised representation of the entire construction from the first connected Brick. Each Brick therefore processes only its local connections, while the representation of the complete structure emerges through the aggregation of the individual subtrees.

==== Serialisation of the Tree Structure
A pre-order traversal is used to serialise the detected tree. The information of the current parent node is placed before the serialised representations of its child nodes. The child nodes are appended according to the predefined order in which the downstream interfaces of the corresponding parent Brick are queried. Together with the information about occupied receiving faces, this consistent ordering enables the learning application to assign each deserialised child node to the correct connection face.

The sequence in which requests propagate through the physical construction must be distinguished from the ordering of the data within the resulting representation. Detection requests travel from the Baseplate towards the outer bricks, whereas the collected subtree data return in the opposite direction. Within each serialised subtree, however, the parent node precedes its child nodes in accordance with the pre-order traversal.
//????
 @physical-digital-tree illustrates this distinction using an example physical construction and its corresponding tree model. die resultierende serialisierte order wird dargestellt durch die alphabetische Reihenfolge der würdel and the resulting serialisation order (zur vereinfachung wurde die relative rotation nicht dargestellt).


#figure(
  image("figures/tree@3x.png", width: 70%),
  caption: [Physical Construction and corresponding digital tree]
)<physical-digital-tree>


=== Processing in the Learning Application <processing-learning-application>
The Baseplate transmits the serialised description of the detected construction to the learning application. The application deserialises the data and restores the individual nodes and their parent–child relationships as a digital tree. The predefined order of the downstream interfaces, together with the occupied connection-face information contained in each node, enables the child nodes to be assigned to the corresponding receiving faces in accordance with #req("DET2").
Using the Baseplate as the origin of a shared coordinate system, the learning application subsequently calculates the global position and orientation of each building Brick. For every parent–child connection, a local transformation is derived from three elements:
-  The receiving face used for the connection
-  The types of the two connected building bricks
-  The detected relative rotation

The global pose of a child Brick is obtained by combining the global pose of its parent with this local transformation. By applying this procedure recursively to all nodes, the complete physical construction can be reconstructed within the shared coordinate system. The resulting spatial model forms the basis for the three-dimensional visualisation and the subsequent comparison with the selected target structure.

==== Comparison with the Target Structure
In accordance with #req("DET4"), the learning application compares the reconstructed current structure with the selected target structure. As already mentioned, structural correctness is determined by the Brick types and their spatial relationships rather than by their individual identities. Bricks of the same type can therefore be exchanged without affecting the correctness of the construction.
The comparison determines whether the current structure:
- Corresponds to a permissible partial structure of the target
- Completely matches the target structure, or
- Contains a connection, Brick type, orientation, or position that deviates from the target

=== Feedback Channel
Based on the comparison with the target, the learning application calculates a feedback status for the overall structure as well as for the individual building bricks. The reconstructed digital construction and the global feedback are displayed directly in the learning application.

For local feedback, the relevant physical bricks are addressed through their identities. The learning application combines the Brick-specific feedback states into a feedback frame and sends it to the Baseplate, which forwards the feedback information through all the connected bricks. Each Brick then checks if its identity is part of the feedback frame and if so activates its local visual output. 
The pedagogical meaning and visual presentation of the individual feedback states are defined separately in @feedback-concept.

///
== Task and Interaction Subsystem <task-concept>
Once the physical construction has been reconstructed digitally, it must be embedded in a task structure that determines how learners can interact with it and how their progress is interpreted. The task and interaction subsystem therefore defines how the reconstruction task combines clear evaluation criteria with sufficient flexibility for learners to explore, revise and correct their construction process.

=== Physical Digital Coupling
The interaction concept combines the static and interactive forms of coupling introduced in @coupling. At the representational level, each physical Brick type is statically linked to a corresponding digital model shown in @coupling-bricks. The cube Brick and the smashed Brick are therefore always represented by digital models that reflect their respective physical geometry and appearance. The meaning of an individual Brick within a construction, however, is determined interactively. Its position and orientation, its role within the parent child structure and its evaluation in relation to the target structure depend on the current physical configuration. Whenever bricks are connected, detached, rotated, or repositioned, these properties are recalculated by the learning application. The digital meaning of the construction therefore emerges from the relationships between the physical bricks rather than from the individual elements in isolation.
//TUI3

#figure(
  image("figures/coupling@3x.png", width: 70%),
  caption: [Comparison of the physical vs the digital building blocks],
  placement: auto
)<coupling-bricks>


=== Task Logic
The construction task is governed by a set of structural and procedural rules.

Following each detected change, the current construction is compared with the selected target structure. A partial construction is considered valid if its building Brick type and connections form part of the target structure. The comparison therefore considers the type, the connection face used and the spatial position and the orientation of each Brick. Building bricks of the same type are interchangeable within the construction task.

The individual identity of a Brick is not relevant to the correctness of the solution but is required only for technical identification and for assigning local feedback to the corresponding physical Brick.

The construction sequence is not prescribed in full. Different sequences may lead to the same valid result, thereby providing the openness required by #req("TUI1"). However, the directed parent child structure imposes a necessary dependency: a child Brick can only be attached after its parent is present in the physical construction.

The task is completed once the detected current construction fully corresponds to the target structure in terms of the Brick types, connections, positions and orientations.

=== Available Actions and Error Correction
Within the defined task objective, learners can explore different construction paths and revise previously completed steps. Connected bricks can therefore be detached from the construction, rotated, attached to a different receiving face or replaced by another Brick of the correct type. As required in #req("IA5"), errors are explicitely permitted and incorrect actions neither terminate the task nor result in other penalties. Since the physical construction remains visible, inspectable and directly modifiable throughout the task, the interaction provides also structured openness required by #req("TUI1").

=== Adaptation of Task Difficulty
According to #req("TUI2"), the difficulty of the construction tasks must be adaptable to different learning prerequisites and can be varied through the following characteristics:

- Number of building bricks: Tasks with fewer bricks provide a simpler starting point, whereas a larger number enables more extensive constructions
- Spatial extent: Structures may extend along one, two, or all three spatial axes.
- Structural complexity: Tasks may involve linear constructions or branching structures with several child bricks
- Relative rotation: Blocks may use consistent orientations or different rotations in increments of 90°
- Block types: A task may require only one Brick type or a combination of different types.
- Presentation of the target: The complete target structure may be displayed from the beginning or revealed incrementally
- Level of support: Feedback may be limited to an evaluation of the current result or supplemented with guidance concerning possible subsequent actions

These characteristics can be combined to create tasks of varying complexity without changing the fundamental interaction principle. 

== Visualisation and Feedback Subsystem <feedback-concept>
The evaluation produced by the task and interaction subsystem must be made perceptible to learners so that they can relate the system response to their physical actions. The following sections translate the detected construction and the results of its comparison with the target into coordinated outputs on the physical bricks and within the learning application.

=== Visualization of the Target Construction
At the beginning of a construction task, a target structure is selected in the learning application. This structure remains available as a visual reference throughout the construction process and can be presented either completely or imcrementally. 
A complete representation enables lerners to analyse the target independently and plan their own construction process. An incremental representation provides additional guidance by presenting or highlighting only the currently relevant part of the target structure. As required by #req("TUI2") and #req("FB4"), different levels of difficulty and support can therefore have different target structure visualizations. 

=== Visualization of the the Current Construction
Following each detection cycle, the learning application represents the reconstructed current structure as a three-dimensional model. Each detected building Brick is positioned within the scene according to its type, calculated position, and orientation. Its digital representation reflects the geometry and appearance of the corresponding physical Brick to maintain a comprehensible relationship between the physical and digital representations as required in#req("TUI3").


The current structure is presented in an interactive three-dimensional view that supports rotation and zooming, allowing the construction to be inspected from different perspectives. The visualisation remains available throughout the task, while the physical construction remains directly accessible and can be modified at any time. Together, these properties are intended to keep the resulting construction visible, inspectable, and modifiable throughout the task #req("IA1"). This is particularly relevant for branching structures in which individual bricks or spatial relationships may be obscured from a single viewpoint. When the visualisation is initially displayed, the camera is automatically aligned with the defined front view of the construction along the positive y-axis.
The target structure and the detected current structure must remain visually distinguishable to prevent learners from confusing the reference with their own construction. They are therefore displayed in separate views or clearly separated spatially within the application.

=== Integration of Visualisation and Feedback
The representation of the current structure is supplemented with its Brick specific feedback derived from the comparison with the target. While the relationship between a physical Brick type and its digital geometry remains statically defined, the feedback state assigned to a Brick changes dynamically according to its current position within the construction  (see @coupling).
This feedback visualisation distinguishes four relevant state:
-  A detected Brick that is correctly positioned
-  A detected Brick that deviates from the target structure
-  An unoccupied position that constitutes a permissible next construction step
-  A target position that is not yet accessible because its required parent Brick is missing

To make the different states visible to the learners, different coloured highlights are used for the building bricks. Correct and deviating bricks are distinguished through contrasting visual highlights, such as green and red outlines. Permissible next positions can be represented as transparent placeholders or _ghost cubes_. Not displayed are positions that are not yet accessible, as their presentation could suggest an action that cannot yet be performed within the directed parent child structure. By attaching each visual state directly to the affected Brick or position, the feedback can be clearly associated with the relevant part of the construction in accordance with #req("FB2").

=== Feedback Levels
The concept combines three levels of feedback and draws on the different feedback modalities introduced in @feedback-modalities. Intrinsic physical feedback results from the mechanical guiding elements and magnetic assistance. When connecting two bricks, learners can physically perceive that the two faces have engaged. But this confirms only the mechanical connection and does not indicate whether the connection has been detected electronically or whether the Brick is correct in relation to the target structure. It is therefore supplemented by digital feedback. Its local from is presented directly on the affected physical Brick at which a green or red light indicates whether the connected Brick has been placed correctly or needs to be reviewed. The global digital feedback is presented through the learning application. In addition to the state of individual bricks, it can represent the complete construction, the progress made towards the target and possible subsequent actions. It therefore supports more detailed information than can be communicated through the limited output capabilities of an individual Brick.

The local and global outputs must remain semantically consistent: if a Brick is marked as correct locally, the corresponding digital Brick must display the same state in the learning application.


=== Types of Feedback <types-feedback>
Based on the distinction established in the theoretical background in @feedback-tui, the concept differentiates between interaction feedback and pedagogical feedback, as required by #req("FB1").

By showing which digital structure the system has derived from the physical construction, the visualisation the interaction feedback is provided: The learner can infer that its connection has been detected and processed, if an added Brick appears at the position and orientation in which it was physically placed. If the Brick is absent or appears differently from the physical arrangement, this indicates a possible detection or reconstruction problem.

The pedagogical feedback evaluates the detected state in relation to the target structure and can fulfil three functions:
- Outcome feedback indicates whether a Brick or connection is correct
- Progress feedback shows how much of the target structure has already been completed
- Feedforward indicates a permissible subsequent action or position

Outcome and progress feedback constitute the basic feedback provided by the prototype while feedforward can supplement these forms depending on the configured level of support. Table @feedback-cases summarises the principal feedback cases and their presentation at the local and global levels

#apa-table(
  columns: (2fr, 2fr, 2fr, 2fr),

  table-label: <feedback-cases>,

  caption: [Feedback cases and their presentation],
  header: (
    [Feedback case],
    [Local feedback],
    [Visualisation in the learning application],
    [Type of feedback],
  ),
    [Physical change detected],
    [No separate local output],
    [The detected current construction is updated to show the recognised Brick, position and orientation],
    [Interaction feedback],
    [Connection detected and correct],
    [Positive light signal on the affected Brick],
    [The Brick is visually highlighted as correct],
    [Outcome feedback],

    [Connection detected but inconsistent with the target],
    [Negative light signal on the affected Brick],
    [The Brick or affected area is visually highlighted as deviating],
    [Outcome feedback],

    [Permissible next position],
    [No local output],
    [Optional representation as a transparent ghost cube],
    [Feedforward],

    [Partial progress achieved],
    [No local output],
    [The progress indicator is updated],
    [Progress feedback],

    [Target structure completed],
    [No local output],
    [Successful completion of the task is displayed],
    [Outcome feedback],
  )

==== Graduated Support
Different types of feedback should be provided at different points in time: Interaction feedback should be provided promptly after the action that triggered it, as required by #req("DET7"), so that learners can associate the system response with the corresponding physical connection. Outcome feedback should likewise indicate promptly whether the detected construction step corresponds to the target structure.

According to #req("FB3") as well as #req("FB4"), more extensive assistance is provided incrementally according to the learner’s support needs. To allow the learner to inspect the physical and digital construction and attempt an independent correction only the affected Brick is initially marked as deviating. If further support is required, the learning application may provide an additional explanation. At a higher level of assistance, permissible next positions can be displayed as ghost cubes to provide feedforward. 
As already mentioned can the representation of the target structure also be adapted to the required level of support. It may remain fully visible to facilitate independent planning or be presented incrementally to direct attention towards the next relevant part. 

This graduated approach preserves opportunities for independent error analysis while providing additional orientation when required.

== Concept Summary




  
