#import "functions.typ": req, apa-table


= Concept Development
This chapter presents the solutions selected for the proposed system and explains how they address the requirements established in the preceding requirements analysis. At this stage, the requirements serve as design criteria for developing and justifying the system concept. Whether they are actually fulfilled can only be determined after implementation and is therefore assessed in the evaluation chapter (Bezug).

== Design Basis and Concept Objective
The requirements analysis conducted in @requirements-analysis provides the foundation for the system concept. The objective of the concept development is to translate the individual pedagogical, interaction-related, functional, mechanical and technical requirements into a coherent overall system.

The concept development covers five closely related areas:
- The physical design of the building bricks and their connections (kapitel)
- The electronic detection of physical connections and the central distribution of power (kapitel)
- The communication and transfer of construction data and the digital reconstruction of the physical structure (kapitel)
- The design of the task and interaction (kapitel)
- The visualisation and feedback principles (kapitel)

Together, these areas define how physical construction activities are connected with digital processing and feedback.


== Usage Scenario
=== Construction Task Flow
The usage scenario describes the general sequence of a guided construction task from the learners perspective:

At the beginning, a target structure is selected from a predefined variety of tasks in the learning application and presented as a reference. It is selected either by the teacher or, where appropriate for the learning context, by the learner itself.
Afterwards, the learner begins connecting the first cube to the baseplate followed by adding further cubes until the specified target structure has been reconstructed. Already completed steps keep being able to be modified as cubes can be detached, repositioned and reconnected at any point during the task. 
Following each modification, the system detects the current physical configuration and updates its digital representation, which is then compared with the target and, depending on whether it is correct, may result in one of two outcomes:
If the current configuration constitutes a valid part of the target structure, the learner can continue with the next construction step. But if a deviation is detected, the system provides corresponding feedback so that the affected step can be reviewed and corrected.
The task is completed once the physical construction fully matches the target structure. It can then either be repeated or a new target structure is selected. 

The task is completed at the learner’s individual pace and does not impose a fixed time limit. Additionaly, a specific construction sequence is required only where it follows necessarily from the spatial dependencies of the target structure.

Throughout the process, the teacher retains responsibility for the pedagogical guidance of the learner and can adapt the available selection of tasks or provide additional explanations if the feedback or assistance offered by the system is insufficient or not understood. Automated feedback is therefore intended to support the teacher during periods of independent work and should not replace individual pedagogical guidance.

SCHREIBEN DASS DAS DIAGRAMM NUR EINE AUFGABE BESCHREIBT UND ES BEENDET IST SOBALD SIE FERTIG IST
#figure(
  image("figures/rechteck_hoch@3x.png", width: 90%),
  caption: [task flow, Ablaufdiagramm]
) <fig:task-flow>

=== Functional Structure
Based on the described usage scenario, the general functions that need to be provided in order to carry out the construction task are derived. The functional structure shown in Figure x initially describes these tasks independently of their subsequent technical implementation

FUNKTIONSDIAGRAMM
whats app

The individual system functions can be assigned to five functional areas (TABELLE?): 
+ Physical Design and Connection Subsystem:	provision of the physical building bricks, housings, mechanical connections
+ Electronic Detection and Power Subsystem:	identification of individual building bricks, detection of connections and relative rotations, provision of the central power supply
+ Data, Communication and Software Subsystem:	transmission of the detected structural data, generation of a digital structure model, spatial reconstruction of the physical construction
+ Task and Interaction Subsystem:	selection and presentation of the target structure, provision of the basic task workflow
+ Visualisation and Feedback Subsystem:	comparison of the detected and target structures, visualisation of the current construction, generation and output of feedback

The functional structure emphasises that a physical action cannot be interpreted directly by the learning application. Instead, the connection must first be established mehcannícally and detected electronically before its local connection data is transformed into a digital model of the overall structure. Only once this model is available, the learning application can compare the detected construction with the selected target structure and generate task related feedback. 


== Overall System Architecture
The System Architecture assigns the in the functional structure described systems functions to the components of the overall system. 
The technical system consists of
  - Several active bricks
  - One baseplate
  - One digital computer based learning application
Learners and pedagogical professionals are external actors and therefore not part of the technical system components

=== System Components and Responsibilities
Table @system-components provides an overview of components of the overall system and their primary responsibilities within the overall system

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
    [Provide the starting point and central power supply, mediate between the building-brick system and the learning application],

    [Learning application],
    [Technical component],
    [Provide the target structure, process structural data, visualise the current construction, compare it with the target structure, generate feedback],
)

#figure(
  image("figures/rechteck_lang@3x.png", width: 90%),
  caption: [DIAGRAMM: konzeptionelle Systemarchitektur mit User, Smart Cube System und Learning application]
)<fig:system-architecture>



== Conceptual definition of the levels of connection
To describe the system unambiguously, a distinction is made between the terminology used at the mechanical, electronic, and logical connection levels: Each building brick has one docking face through which it is connected to the existing construction and, depending on its type, one or more receiving faces to which further building bricks can be attached. The docking face contains the electronic upstream interface, whereas each receiving face contains a downstream interface. In the digital model, the building brick already connected to the system is represented by the parent node, while the newly added building brick is represented by the child node. A connection can therefore be described at the three levels presented in the following Table @terminology-connection:

#apa-table(
  columns: (1fr, 2fr, 2fr),

  table-label: <terminology-connection>,

  header: (
    [Level],
    [Term],
    [Definition],
  ),

  caption: [Terminology across the connection levels],

    [Mechanics], [Connection face], [General term for all physical building-brick faces through which a connection can be established],

    [Mechanics], [Docking face and Receiving face], [Connection faces of the building bricks],

    [Electronics], [Upstream and downstream interface], [Electrical contacts located on the connection faces],

    [Data model], [Parent and child nodes], [Directed relationship within the digital tree],

    [Data model], [Parent brick], [Building brick that is already connected to the system],

    [Data model], [Child brick], [Building brick whose docking face is connected to a receiving face of the parent brick],
  )

== Physical Design and Connection Subsystem <physical-concept>
- Im Folgenden werden gemäß der Begriffsdefinition in Abschnitt X.3.3 die Bezeichnungen Andockseite und Aufnahmeseite verwendet.

Das Kapitel beschreibt:
- Grundformen und Abmessungen der Bausteine
- gerichtete Gestaltung der Verbindungsseiten
- mechanisches Verbindungsprinzip
- ergonomische Gestaltung
- Gehäuse- und Wartungskonzept
- mechanischen Aufbau der Baseplate

=== Basic Geometry and Block Types <geometry-brick>
In accordance with requirement #req("G1"), the connection faces of all building bricks have a square geometry with standardised dimensions. This geometry permits a rotationally symmetrical contact arrangement and allows four mechanically valid orientations in increments of 90°. It therefore ensures compatibility between different brick types and provides the mechanical basis for the electronic detection of relative rotation required by #req("C4").
Based on the standardised connection geometry, two building-brick types are defined in accordance with #req("G3")
- The _cube brick_ wth six square connection faces, as specified by #req("G2")
- The _smashed brick_ with two opposing square connection faces, while its remaining faces cannot be used to establish connections

Whereas the cube brick supports linear as well as branched two- and three-dimensional constructions along its three mutually orthogonal spatial axes, the flat brick permits only linear connections along its local z-axis. Figure X illustrates the two brick types and an example of a physical construction.

For the square connection faces a side lenght of approximately 40mm is specified. The selected dimension represents a compromise between the one-handed grasping and positioning required by #req("C5") and the internal space needed for electrical contacts and electronic components. Whether the chosen size is in fact ergonomically suitable is assessed in Chapter (EVALUATION).

The consistent brick geometry also establishes a direct visual correspondence between the physical building bricks and conventional construction bricks such as ?LEGO or ?.
The implications of the physical–digital correspondence for interaction are discussed in Section ???.

#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [Würfeltypen (physisch)],
      supplement: [Figure],
      kind: "figure",
    ) <bild1>
  ],
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [Beispiel Konstruktion (physisch)],
      supplement: [Figure],
      kind: "figure",
    ) <bild2>
  ],
)

==== Directed Design of the Connection Faces
As required by requirement #req("C1") and #req("C2"), each building brick has exactly one _Docking face_ and at least one _Receiving face_ depending on the type. To identify the intended target connection and orientation between two bricks, the _Receiving faces_ are differentiated by colour. This directed design provides the physical basis for representing the resulting construction as a parent child structure. The corresponding digital structure model is described in @structure-model.

?A valid mechanical connection can only be established between a _Receiving face_ of the parent brick and the _Docking face_ of the child brick, wie es mechanisch umgesetzt wird, wird im nächsten kapitel beschrieben?

==== Mechanical Connection Principle
The mechanical connection principle was selected with regard to stability, unambiguous alignment, and the low operating force specified by #req("C6"). For the prototype a combination of a mechanical form fit mechanism and magnetic assistance is used: The docking face contains recessed guiding elements, while the receiving faces contain corresponding protruding elements. This is supplemented by magnets which are positioned on every interface type but with complementary polarities.

This guiding geometry determines which interface types can be connected and aligns their electrical contact areas. The magnets assist this approach and also stabilise the resulting connection without requiring the force associated with a conventional snap-fit mechanism. Together, these elements form a mechanical constraint as described in @token-constraint: Incompatible connections are impeded because the interface geometries do not fit or the equally polarised magnets repel one another. The available connection possibilities are therefore partly conveyed through the physical design itself.

The mechanical and magnetic engagement also produces intrinsic haptic feedback, allowing learners to perceive immediately that two faces have been physically connected. However, this feedback only confirms the mechanical connection and does not indicate whether the connection has been detected electronically or not. The relationship between intrinsic feedback and system-generated feedback is discussed in @feedback-concept.

=== Housing and Maintainability
The housing must completely enclose the electronic components and magnets and prevent small parts from becoming detached unintentionally, as specified by #req("S2"). At the same time, it must remain possible to be disassembled without damaging it in order to support assembly, maintenance and component replacement in accordance with #req("S3").

For this purpose, a modular brick housing structure is proposed which consists of three separate parts:
- A supporting frame incorporating the docking face
- Interchangeable side-wall modules containing the receiving faces
- a final cover that closes the housing

This structure offers two main advantages: It allows the electronic components of the individual connection faces to be mounted separately before the modules are assembled into a complete building brick #req("S3"). And, as the receiving-side modules follow the same design regardless of their position or the brick type, they can be installed interchangeably and replaced individually when necessary.

=== Mechanical Concept of the Baseplate
The baseplate forms the starting point of every physical construction and consists of an enclosed housing for its technical components such as one receiving face, whose mechanical geometry corresponds to that of the building bricks. The first brick is placed on the baseplate using its defined docking face which establishes it spatially and logically as the first building brick of the construction.

Additional receiving faces could enable several constructions with multiple starting points but would require an extension of the digital structure model and additional rules for comparison with the target structure. Consequently, the basic concept is limited to a single connection point.

#figure(
  image("figures/rechteck_kurz@3x.png", width: 50%),
  caption: [Baseplate (physisch)]
)<baseplate>

=== Conclusion
The mechanical design determines which types of connection faces can be joined and which of the four relative rotational orientations can be assumed. The following section describes how these mechanically defined states are detected electronically and how the connected building bricks are supplied with power from a central source.


/////

== Electronic Detection and Power Subsystem
- Das Kapitel verwendet die in X.3.3 definierten Begriffe:
  - Upstream-Schnittstelle auf der Andockseite,
  - Downstream-Schnittstelle auf jeder Aufnahmeseite.


- Damit die physische Konstruktion digital rekonstruiert werden kann, müssen diese Verbindungszustände elektronisch erfasst werden
=> das vorliegende kapitel beschreibt die dafür erforderliche elektonische Architektur
enthält:
- elektronische Systemarchitektur
- funktionalen Aufbau der Bausteine und Baseplate
- elektrische Schnittstellen und lokales Erkennungsprinzip
- zentrale Energieversorgung
- (lokale Feedbackausgabe)


=== elektronische Systemarchitektur
aktiv/passiv/? - related work abhängig

=== Functional Structure <functional-structure>
The building bricks and the Baseplate share several fundamental electronic functions, including control, electrical interfacing, and power distribution. However, they perform these functions at different levels of the system. While each building brick processes information locally and forwards data and power within the physical construction, the baseplate acts as the central root and mediates between the building-brick system and the learning application. Figure @blockdiagram summarises the functional structures of the building bricks and the baseplate.

==== Functional Structure of the Building Bricks
Each building brick conceptually contains five electronic functional units:
+ A local control unit: It maintains the identity and type of the brick and processes the signals received through its electrical interfaces
+ The upstream interface: It establishes the electrical connection to the parent brick through the docking face
+ The downstream interface: It provides electrical connections to child bricks through the receiving face
+ Internal power distribution: It supplies the local electronics and forwards the incoming supply to the downstream interfaces
+ Local visual feedback output: It shows the system generated feedback

Depending on its type, a building brick provides either five downstream interfaces in the cube configuration or a single downstream interface in the smashed configuration.

==== Fuctional Structure of the Baseplate
The Baseplate contains four electronic functional units:
+ A central? control unit: It initiates the detection process and mediates between the physical cube system and the learning application
+ The downstream interface: It establishes the electrical connection to the first building brick
+ Central power supply: It provedes energy to the connected construction
+ Application interface: it enables the exhange of data with the learning application

As the baseplate constitutes the root of the construction, it does not contain an upstream interface. 

(EIGENTLICH IN SOFTWARE CONCEPT:
It forwards the serialised representation of the detected construction to the learning application. The spatial reconstruction and comparison with the target structure are performed by the learning application rather than the baseplate. Figure X summarises the functional structures of the building bricks and the baseplate.)


#figure(
  image("figures/rechteck_hoch@3x.png", width: 90%),
  caption: [Blockdiagramme brick und baseplate],
)<blockdiagram>

=== Electrical Interfaces and Local Detection Principle <electrical-interface>
BEZUG AUF BLOCKDIAGRAMM

Each mechanically defined connection is complemented by an electrical interface. The upstream and downstream interfaces contain both the same contacts for the power supply and the shared reference potential but differ in the arrangement and function of their signal contacts. The docking face of each building brick contains four upstream orientation contacts corresponding to the four mechanically possible rotations and arranged at the corners of the docking face. Each receiving face contains just one downstream child contact for detecting and communicating with an attached child brick. It is positioned so that it connects to exactly one of these four upstream orientation contacts in each permissible orientation. This arrangement allows the four relative rotations to be distinguished unambiguously #req("DET3"). The power and ground contacts are rotationally symmetrical so that the power connection remains functional in every permissible orientation. 


(The recessed interface regions and the mechanical guiding elements additionally protect these electrical interfaces. They reduce the risk of incorrect contacting and unintended short circuits by aligning the connecting faces before contact is established.) -> VLT AUCH IMPLEMENTIERUNG

//vlt auch erst in Implementierung einfügen 
#grid(
  columns: (1fr, 1fr),
  column-gutter: 1em,
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [Andockseite kontaktanordnung],
      supplement: [Figure],
      kind: "figure",
    ) <docking-face-contact-arrangement>
  ],
  [
    #figure(
      image("figures/rechteck_kurz@3x.png", width: 90%),
      caption: [Aufnahmeseite kontaktanordnung)],
      supplement: [Figure],
      kind: "figure",
    ) <receiving-face-contact-arrangement>
  ],
)

==== Detection of the Connection Face and Relative Rotation
A valid electrical connection is established between the downstream child contact of a parent brick and one of the four upstream contacts of the newly attached child brick. Which upstream contact is reached by the parent block’s downstream contact depends on the orientation of the child brick and therefore encodes its relative rotation, as required by #req("DET3"). Once the connection has been established, the same signal path is used for communication between the parent and child bricks. Because each receiving face has a separate downstream interface, the local control unit can query the faces individually to determine whether a child brick is connected to a particular receiving face or not and if so establish the communication with that child. 

(The identity and type of the connected brick are subsequently determined from the information transmitted by its local control unit. The corresponding communication and data representation are described in @structure-model.)

The detected connection face and rotation initially describe only the position and orientation of a brick relative to its immediate parent. Its global position and orientation within the complete construction are calculated later by the learning application based on all locally detected relationships (KAPITEL).

=== Centralised Power Supply
In accordance with #req("EL1"), the building bricks operate without individual batteries or rechargeable cells. Instead, power is supplied centrally by the baseplate and transmitted through the electrical contacts to the connected bricks. Each brick uses the incoming supply for its own electronics and forwards it to its available downstream interfaces so that subsequent child bricks can also be powered.
This centralised approach reduces maintenance because individual batteries do not need to be charged or replaced. It also decreases the space required within each building brick and prevents differing states of charge within the same construction.

POWER SUPPLY EIGENTLICH VOM COMPUTER??

=== Local Electronic Feedback Output
To have feedback directly assigened to the physical bricks and not exlusively through the learning application, each building brick contains a simple visual feedback. 
The meaning, presentation, and coordination of local and global feedback are specified in Section ????.

=== Conclusion
The electrical concept is based on active bricks, each of which has its own local control unit, an upstream interface and downstream interfaces with which it can communicate and detect its relative rotation.
the baseplate forms the electronic starting point by supplying the power and connecting the physical brick construction with the learning application.  
The electrical subsystem therefore provides the physical interfaces and signals neccesary for the digital recontruction of the physical construction

(How this local electrical information is retrieved and processed by the learning application is described by the following data, communications and software concept)

///////
== Data, Communication and Software Subsystem <software-concept>
Das Kapitel legt fest, wie diese bereitgestellten elektrischen Informationen über die Würfelstruktur übertragen, zu einer serialisierten Beschreibung der Gesamtkonstruktion zusammengeführt und anschließend in der Lernanwendung verarbeitet werden.

terminologie kindknoten

enthält:
- übergeordneten Datenfluss
- Struktur und Datenmodell
- Erfassungs- und Kommunikationskonzept
- Verarbeitung in der Lernanwendung
- Feedbackrückkanal

=== übergeordneter Datenfluss
- Der Verarbeitungsablauf beginnt in der Lernanwendung:
  - Das Kind wählt eine Zielkonstruktion aus
  - Die Zielkonstruktion wird für den späteren Vergleich gespeichert
  - Die Lernanwendung sendet ein Startsignal an die Baseplate

- Die Baseplate:
  - startet den zyklischen Erfassungsprozess
  - fragt den ersten angeschlossenen Baustein ab
  - Die Bausteine ermitteln ihre lokalen Verbindungsinformationen und führen diese rekursiv zu einer serialisierten Beschreibung der vollständigen Baumstruktur zusammen
  - empfängt die serialisierte Baumdarstellung
  - leitet diese inhaltlich unverändert an die Lernanwendung weiter

- Die Lernanwendung:
  - deserialisiert die empfangene Baumdarstellung
  - stellt das digitale Strukturmodell wieder her
  - berechnet Position und Orientierung der Bausteine
  - vergleicht die Ist-Konstruktion mit der Zielkonstruktion
  - erzeugt die Feedbackzustände
  - visualisiert die erkannte Konstruktion und die globale Rückmeldung
  - sendet bausteinspezifische Feedbacknachricht an die Baseplate

- Die Baseplate leitet die Feedbacknachricht an die Bausteine weiter
- Anschließend beginnt der nächste Erfassungszyklus
- Der Vorgang wiederholt sich, bis die Aufgabe abgeschlossen oder beendet wird
- Beim Beenden sendet die Lernanwendung ein Stoppsignal an die Baseplate, die noch eine letzte vordefinierte Schluss-feedbacknachricht an die Bausteine rausschickt
- baseplate wartet wieder auf ein Startsignal
- lernanwendung wartet auf eine ausgewählte Zielkonstruktion


=> zwei voneinander abgetrennte Systeme:
- baseplate und cubes 
  - Basisstation und aktive Bausteine,
  - erfasst und überträgt die physische Konstruktion,
  - ist unabhängig von der ausgewählten Zielkonstruktion
- lernanwendung:
  - Computer
  - interagiert mit den Lernenden
  - verwaltet die Zielkonstruktion
  - interpretiert die erfassten Daten
  - führt den Zielvergleich durch
  - erzeugt Visualisierung und Rückmeldung

#figure(
  image("figures/rechteck_hoch@3x.png", width: 90%),
  caption: [Sequenzdiagramm]
)<sequence-diagram-overall-flow>

=== Logical Structure and Data Model <structure-model>
The physical construction is conceptually represented as a directed tree: The baseplate forms the root of the tree, each connected building brick is represented by a node and each physical connection constitutes a directed edge between a parent and a child node.
The model reflects also the directed interface structure introduced in @electrical-interface: The defined docking face connects each brick to its parent, while its receiving faces allow one or more child bricks to be attached. Consequently, each brick can have no more than one parent but may have several children. As required by #req("C3"), both linear and branching three-dimensional constructions can therefore be represented by the model. By deriving the digital interpretation from the parent–child relationships and the resulting overall construction, the structure model applies the relational and constructive mapping principles introduced in @mapping.

To identify and interpret each building brick within this tree, however, the parent–child relationship alone is insufficient. Table @node-infos summarises the additional information contained in each node for this purpose:


#apa-table(
  columns: (1fr, 3fr),

  table-label: <node-infos>,

  header: (
    [Information],
    [Meaning],
  ),

  caption: [Node Information],

    [Identity],
    [Unique assignment of the node to a physical building brick],

    [Brick type],
    [Geometric and functional properties of the building brick],

    [Relative rotation],
    [Orientation of the building brick in relation to its parent],

    [Occupied connection faces],
    [Assignment of child nodes to the corresponding receiving faces],

    [Child nodes],
    [Node information of the directly connected child bricks and their subordinate structures],

  )

The identity is used to recognise an individual physical building brick and subsequently assign local feedback to it, whereas the brick type is required to interpret its geometry and compare it with the corresponding element of the target structure. Lastly, the relative rotation and occupied connection faces describe the local spatial relationship between the node and its parent and children.

=== Detection and Communication Concept
Communication within the physical construction follows the parent child relationships of the structure model: A parent requests information from a directly connected child, which responds with its own node information and the serialised descriptions of all subordinate structures connected to it. This communication takes place through the upstream interface of the child and the corresponding downstream interface of the parent described in @functional-structure. It follows a request response principle since the parent initiates the exchange, and the child responds to the request. When the child subsequently queries its own receiving faces, it assumes the role of a parent in relation to the bricks connected below it.

Since only one signal path is available between a parent’s downstream child contact and the contacted upstream contact of its child, the line must be used alternately for both transmission directions. The communication concept consequently employs a bidirectional single-wire half-duplex protocol. The exact message format, timing parameters, and concrete protocol implementation are described in the realisation chapter (BEZUG).

==== Sequential Interface Query and Recursive Detectionn
During each detection cycle, the downstream interfaces of a building brick are examined sequentially in a predefined order, following the _round robin principle_. This ensures that every available receiving face is checked regularly. If no child is detected at an interface, the control unit continues with the next available interface. But if a child brick is detected, its complete subordinate structure is acquired before the parent continues with the next downstream interface.

The overall construction is therefore detected using a _depth first search_. Starting from the baseplate as the root, the system follows a detected branch to its outermost building brick before processing the next downstream interface of the preceding brick. Once all downstream interfaces of a brick have been queried, the brick combines its own node information with the collected representations of its child nodes. The resulting description of the complete subtree is then returned to the parent.

This procedure is applied recursively until the baseplate receives a serialised representation of the entire construction from the first connected building brick. It allows every brick to process only its local connections while the complete structure emerges through the aggregation of the individual subtrees.

==== Serialisation of the Tree Structure
For the serialisation of the detected tree a _pre-ordre traversal_ is used. This means that the information of the current parent node is placed before the serialised representations of its child nodes. The child nodes are then appended according to the predefined order of the parent’s downstream interfaces. Together with the information about occupied receiving faces, this consistent ordering enables the learning application to assign each deserialised child node to the correct connection face.


The sequence in which requests propagate through the physical construction must be distinguished from the order of the data within the resulting representation: Detection requests travel from the baseplate towards the outer nodes of the construction but the collected subtree data subsequently return in the opposite direction towards the baseplate. Within each serialised subtree, however, the parent node is placed before its child nodes in accordance with the _pre-order traversal_. 
Figure @physical-digital-tree can illustrate this distinction using a physical example tree/brick construction and its resulting serialisation order.

#figure(
  image("figures/rechteck_lang@3x.png", width: 90%),
  caption: [ABBILDUNG PHYSISCHER BAUM UND WIE DIE NACHRICHT DANN AUSSCHAUT]
)<physical-digital-tree>


=== Processing in the Learning Application
The serialised description of the detected construction is then transmitted to the learning application by the baseplate. The learning application then deserialises the data so that the individual nodes and their parent child relationships are restored as a digital tree. The predefined ordering of the downstream interfaces and the transmitted connection face information allow the child nodes to be reassigned to their corresponding receiving faces, as required by #req("DET2").

Starting from the baseplate, the learning application then calculates the global position and orientation of every building brick. For each connection, a local transformation is defined based on three elements:
+ The receiving face used for the connection
+ The types of the two connected building bricks
+ The detected relative rotation

The global pose of a child brick is therefore derived from the global pose of its parent and the local transformation associated with their connection. By recursively applying this procedure to all nodes, the complete construction can be placed within a shared coordinate system.

The resulting spatial model forms then the basis for the three dimensional visualisation and the comparison with the selected target structure in accordance with #req("DET4").

==== Comparison with the Target Structure
As already mentioned, the comparison is primarily based on the brick types and their spatial relationships rather than on the individual identities of them. Building bricks of the same type can therefore be exchanged without changing the semantic correctness of the construction. The comparison determines whether the detected current structure

- Corresponds to a permissible partial structure of the target
- Completely matches the target structure, or
- Contains a connection, brick type, orientation, or position that deviates from the target

The individual identity of each brick remains relevant for the local feedback. 

=== Feedback Channel
Based on the comparison with the target, the learning application calculates a feedback status for the overall structure as well as for the individual building bricks. The reconstructed digital construction and the global feedback are displayed directly in the learning application.

For local feedback, the relevant physical bricks are addressed through their identities. The learning application combines the brick-specific feedback states into a feedback frame and sends it to the baseplate, which forwards the feedback information through all the connected bricks. Each brick then checks if its identity is part of the feedback frame and if so activates its local visual output. 

The pedagogical meaning and visual presentation of the individual feedback states are defined separately in @feedback-concept.

=== Conclusion
????????????

== Task and Interaction Subsystem <task-concept>
The task and interaction concept specifies how learners complete the reconstruction task and which actions are available to them during this process. It furthermore defines the rules according to which a physical construction is evaluated while preserving sufficient flexibility for learners to explore, revise, and correct their chosen construction process.

=== Physical–Digital Coupling
The interaction concept combines the static and interactive forms of coupling introduced in @coupling. At the representational level, each physical brick type is statically linked to a corresponding digital model. The cube brick and the smashed brick are therefore always represented by digital models that reflect their respective physical geometry and appearance. The meaning of an individual brick within a construction, however, is determined interactively. Its position and orientation, its role within the parent child structure and its evaluation in relation to the target structure depend on the current physical configuration. Whenever bricks are connected, detached, rotated, or repositioned, these properties are recalculated by the learning application. The digital meaning of the construction therefore emerges from the relationships between the physical bricks rather than from the individual elements in isolation.

=== Task Logic
The construction task is governed by a set of structural and procedural rules.

Following each detected change, the current construction is compared with the selected target structure. A partial construction is considered valid if its building brick type and connections form part of the target structure. The comparison therefore considers the type, the connection face used and the spatial position and the orientation of each brick. Building bricks of the same type are interchangeable within the construction task.

The individual identity of a brick is not relevant to the correctness of the solution but is required only for technical identification and for assigning local feedback to the corresponding physical brick.

The construction sequence is not prescribed in full. Different sequences may lead to the same valid result, thereby providing the openness required by #req("TUI1"). However, the directed parent child structure imposes a necessary dependency: a child brick can only be attached after its parent is present in the physical construction.

The task is completed once the detected current construction fully corresponds to the target structure in terms of the brick types, connections, positions, and orientations.

=== Available Actions and Error Correction
Within the defined task objective, learners can explore different construction paths and revise previously completed steps. Connected bricks can therefore be detached from the construction, rotated, attached to a different receiving face or replaced by another brick of the correct type.

As required in #req("IA5"), errors are explicitely permitted and incorrect actions neither terminate the task nor result in other penalties. Since the physical construction remains visible, inspectable, and directly modifiable throughout the task, the interaction provides also structured openness required by #req("TUI1").

=== Adaptation of Task Difficulty
According to #req("TUI2"), The difficulty of the construction tasks must be adaptable to different learning prerequisites and can be varied through the following characteristics:

- Number of building bricks: Tasks with fewer bricks provide a simpler starting point, whereas a larger number enables more extensive constructions
- Spatial extent: Structures may extend along one, two, or all three spatial axes.
- Structural complexity: Tasks may involve linear constructions or branching structures with several child bricks
- Relative rotation: Blocks may use consistent orientations or different rotations in increments of 90°
- Block types: A task may require only one brick type or a combination of different types.
- Presentation of the target: The complete target structure may be displayed from the beginning or revealed incrementally
- Level of support: Feedback may be limited to an evaluation of the current result or supplemented with guidance concerning possible subsequent actions

These characteristics can be combined to create tasks of varying complexity without changing the fundamental interaction principle. 

=== Conclusion
???
The specific presentation and gradation of the corresponding feedback and assistance are defined in the following visualisation and feedback concept

== Visualisation and Feedback Subsystem <feedback-concept>
ÜBERLEITUNG

enthält:
- Visualisierung der Ziel- und ist- Konstruktion
- Verbindung von Visualisierung und Feedback
- Feedbackebenen und -Arten

- Das in Kapitel X.6 beschriebene digitale Strukturmodell bildet Grundlage für die Darstellung und Bewertung der physischen Konstruktion
- Lernanwendung soll Lernenden sichtbar machen, welchen Aufbau das System erkannt hat und darauf aufbauend die ergebnisse des Vergleichs zwischen Ist- und Zielkonstruktion als Feedback darstellen
- Visualisierung und Feedback erfüllen unterschiedliche, aber eng miteinander verbundene Funktionen:
  - Visualisierung: repräsentiert erkannten Systemzustand = interaktionsfeedback
  - Feedback: bewertet Zustand im Hinblick auf Bauaufgabe = pädagogisches Feedback
  => Lernenden können zuerst nachvollziehen, ob und wie ihre handlung vom System erkannt wurde und anschließend erkennen, ob eine Korrektur erforderlich ist

=== Visualization of the Target Structure
At the beginning of a construction task, a target structure is selected in the learning application. This structure remains available as a visual reference throughout the construction process and can be presented either completely or imcrementally. 
A complete representation enables lerners to analyse the target independently and plan their own construction process. An incremental representation provides additional guidance by presenting or highlighting only the currently relevant part of the target structure. As required by #req("TUI2") and #req("FB4"), different levels of difficulty and support can therefore have different target structure visualisations. 

=== Visualisierung der erkannten Ist-Konstruktion
Following each detection cycle, the current structure reconstructed by the learning application is represented as a three-dimensional model. Each detected building brick is thereby inserted into the scene according to its type, calculated position and orientation. Its digital representation is based on the geometry and appearance of the physical bricks to preserve a comprehensible relationship between the physical and digital representations in accordance with #req("TUI3"). The target and the detected current structure must remain visually distinguishable to prevent learners from confusing the reference with their own construction. They should therefore be displayed in separate views or be clearly separated spatially within the application.

The scene is embedded in a three-dimensional view to support rotation and zooming, allowing the construction to be inspected from different perspectives. This is particularly relevant for branching structures in which individual bricks or spatial relationships may be obscured from a single viewpoint. When the visualisation is initially displayed, the camera is automatically aligned with the defined front view of the construction along the positive y-axis.

=== Integration of Visualisation and Feedback
The representation of the current structure is supplemented with its brick specific feedback derived from the comparison with the target. While the relationship between a physical brick type and its digital geometry remains statically defined (see @coupling), the feedback state assigned to a brick changes dynamically according to its current position within the construction.

This feedback visualisation distinguishes four relevant state:
+ A detected brick that is correctly positioned
+ A detected brick that deviates from the target structure
+ An unoccupied position that constitutes a permissible next construction step
+ A target position that is not yet accessible because its required parent brick is missing

To make the different states visible to the learners, different coloured highlights are used for the building bricks. Correct and deviating bricks are distinguished through contrasting visual highlights, such as green and red outlines. Permissible next positions can be represented as transparent placeholders or _ghost cubes_. Not displayed are positions that are not yet accessible, as their presentation could suggest an action that cannot yet be performed within the directed parent child structure. By attaching each visual state directly to the affected brick or position, the feedback can be clearly associated with the relevant part of the construction in accordance with #req("FB2").

#grid(
  columns: (1fr, 1fr, 1fr, 1fr, 1fr),
  column-gutter: 1em,
  [
    #figure(
      image("figures/quadrat@3x.png", width: 90%),
      caption: [physischer brick],
      supplement: [Figure],
      kind: "figure",
    ) <physical-brick>
  ],
  [
    #figure(
      image("figures/quadrat@3x.png", width: 90%),
      caption: [digitaler brick)],
      supplement: [Figure],
      kind: "figure",
    ) <digital-brick>
  ],
  [
    #figure(
      image("figures/quadrat@3x.png", width: 90%),
      caption: [correcter brick)],
      supplement: [Figure],
      kind: "figure",
    ) <digital-correct-brick>
  ],
  [
    #figure(
      image("figures/quadrat@3x.png", width: 90%),
      caption: [correcter brick)],
      supplement: [Figure],
      kind: "figure",
    ) <digital-incorrect-brick>
  ],
  [
    #figure(
      image("figures/quadrat@3x.png", width: 90%),
      caption: [correcter brick)],
      supplement: [Figure],
      kind: "figure",
    ) <digital-ghost-brick>
  ],
)

=== Feedback Levels
The concept combines three levels of feedback and draws on the different feedback modalities introduced in @feedback-modalities. Intrinsic physical feedback results from the mechanical guiding elements and magnetic assistance. When connecting two bricks, learners can physically perceive that the two faces have engaged. But this confirms only the mechanical connection and does not indicate whether the connection has been detected electronically or whether the brick is correct in relation to the target structure. It is therefore supplemented by digital feedback. Its local from is presented directly on the affected physical brick at which a green or red light indicates whether the connected brick has been placed correctly or needs to be reviewed. The global digital feedback is presented through the learning application. In addition to the state of individual bricks, it can represent the complete construction, the progress made towards the target and possible subsequent actions. It therefore supports more detailed information than can be communicated through the limited output capabilities of an individual brick.

The local and global outputs must remain semantically consistent: if a brick is marked as correct locally, the corresponding digital brick must display the same state in the learning application.


=== Types of Feedback
Based on the distinction established in the theoretical background in @feedback-tui, the concept differentiates between interaction feedback and pedagogical feedback, as required by #req("FB1").

By showing which digital structure the system has derived from the physical construction, the visualisation the interaction feedback is provided: The learner can infer that its connection has been detected and processed, if an added brick appears at the position and orientation in which it was physically placed. If the brick is absent or appears differently from the physical arrangement, this indicates a possible detection or reconstruction problem.

The pedagogical feedback evaluates the detected state in relation to the target structure and can fulfil three functions:
- Outcome feedback indicates whether a brick or connection is correct
- Progress feedback shows how much of the target structure has already been completed
- Feedforward indicates a permissible subsequent action or position

Outcome and progress feedback constitute the basic feedback provided by the prototype while feedforward can supplement these forms depending on the configured level of support. Table @feedback-cases summarises the principal feedback cases and their presentation at the local and global levels

#apa-table(
  columns: (2fr, 2fr, 2fr, 2fr),

  table-label: <feedback-cases>,

  header: (
    [Feedback case],
    [Local feedback],
    [Visualisation in the learning application],
    [Type of feedback],
  ),
    [Physical change detected],
    [No separate local output],
    [The detected current construction is updated to show the recognised brick, position, and orientation],
    [Interaction feedback],
    [Connection detected and correct],
    [Positive light signal on the affected brick],
    [The brick is visually highlighted as correct],
    [Outcome feedback],

    [Connection detected but inconsistent with the target],
    [Negative light signal on the affected brick],
    [The brick or affected area is visually highlighted as deviating],
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

According to #req("FB3") as well as #req("FB4"), more extensive assistance is provided incrementally according to the learner’s support needs. To allow the learner to inspect the physical and digital construction and attempt an independent correction only the affected brick is initially marked as deviating. If further support is required, the learning application may provide an additional explanation. At a higher level of assistance, permissible next positions can be displayed as ghost cubes to provide feedforward. 
As already mentioned can the representation of the target structure also be adapted to the required level of support. It may remain fully visible to facilitate independent planning or be presented incrementally to direct attention towards the next relevant part. 

This graduated approach preserves opportunities for independent error analysis while providing additional orientation when required.

=== Conclusion??
auf @feedback-children kapitel eingehen 

== Concept Summary




  
