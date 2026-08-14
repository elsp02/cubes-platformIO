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

== Physical Design and Connection Subsystem
- Im Folgenden werden gemäß der Begriffsdefinition in Abschnitt X.3.3 die Bezeichnungen Andockseite und Aufnahmeseite verwendet.

Das Kapitel beschreibt:
- Grundformen und Abmessungen der Bausteine
- gerichtete Gestaltung der Verbindungsseiten
- mechanisches Verbindungsprinzip
- ergonomische Gestaltung
- Gehäuse- und Wartungskonzept
- mechanischen Aufbau der Baseplate

=== Basic Geometry and Block Types
In accordance with requirement #req("G1"), the connection faces of all building bricks have a square geometry with standardised dimensions. This geometry permits a rotationally symmetrical contact arrangement and allows four mechanically valid orientations in increments of 90°. It therefore ensures compatibility between different brick types and provides the mechanical basis for the electronic detection of relative rotation required by #req("C4").
Based on the standardised connection geometry, two building-brick types are defined in accordance with #req("G3")
- The _cube brick_ wth six square connection faces, as specified by #req("G2")
- The _smashed brick_ with two opposing square connection faces, while its remaining faces cannot be used to establish connections

Whereas the cube brick supports linear as well as branched two- and three-dimensional constructions along its three mutually orthogonal spatial axes, the flat brick permits only linear connections along its local z-axis. Figure X illustrates the two brick types and an example of a physical construction.

For the square connection faces a side lenght of approximately 40mm is specified. The selected dimension represents a compromise between the one-handed grasping and positioning required by #req("C5") and the internal space needed for electrical contacts and electronic components. Whether the chosen size is in fact ergonomically suitable is assessed in Chapter (EVALUATION).

The consistent brick geometry also establishes a direct visual correspondence between the physical building bricks and conventional construction bricks such as ?LEGO or ?.
The implications of the physical–digital correspondence for interaction are discussed in Section ??? @bild1.

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
+ A central control unit: It initiates the detection process and mediates between the physical cube system and the learning application
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
The model reflects also the directed interface structure introduced in @electrical-interface: The defined docking face connects each brick to its parent, while its receiving faces allow one or more child bricks to be attached. Consequently, each brick can have no more than one parent but may have several children. As required by #req("C3"), both linear and branching three-dimensional constructions can therefore be represented by the model. 

However, knowledge of the docking face and relative rotation alone is insufficient to characterise a building brick within the overall construction. Table @node-infos summarises the information contained in each node that is required for this purpose:


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


ABBILDUNG: Gegenüberstellung einer physischen Konstruktion und des daraus abgeleiteten digitalen Baumes

==== Mapping Styles
- das gewählte Strukturmodell verbindet mehrere der in Kapitel X beschriebenen Mapping Styles:
  - relationales mapping: digitale Interpretation liegt auf den Beziehungen zwischen den bausteinen - 
  - konstruktives mapping: digitale Bedeutung und räumliche Information entsteht nicht aus einem einzelnen Baustein, sondern aus der Verbindung mehrerer Elemente zu einer Gesamtstruktur

==== methods of coupling
- statische Kopplung: Zuordnung eines physischen Bausteintyps zu seinem digitalen Modell ist vorab festgelegt -> die zwei unterschiedlichen Bausteintypen werden immer durch ihr entsprechendes digitales Würfelmodell (das dem physischen baustein vom aussehen gleicht) repräsentiert 
- interaktive Kopplung: Die Bedeutung der Konstruktion entsteht aus der Verbindung der Würfel untereinander (Position, Rolle im Baum und Bewertung hängen von der jeweiligen Konfiguration ab)


////
Ich würde die Überschrift vollständig entfernen und nur einen kurzen Rückbezug am Ende von „Logical Structure and Data Model“ einfügen:
By deriving the digital interpretation from the parent–child relationships and the resulting overall construction, the structure model applies the relational and constructive mapping principles introduced in Section X.

Die übrigen Inhalte lassen sich passender verteilen:
Die visuelle Übereinstimmung zwischen physischem Baustein und digitalem Modell gehört zu „Basic Geometry and Block Types“ oder zum späteren Interaktionskonzept.
Die konfigurationsabhängige Bedeutung der Bausteine kann kurz im „Task and Interaction Concept“ aufgegriffen werden.
Die Unterscheidung zwischen statischer und interaktiver Kopplung muss nicht erneut ausführlich erklärt werden, wenn sie im theoretischen Hintergrund bereits behandelt wurde.
So bleibt der theoretische Rückbezug erhalten, ohne den technischen Argumentationsfluss des Kapitels zu unterbrechen.
//// 

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

- Number of building blocks: Tasks with fewer blocks provide a simpler starting point, whereas a larger number enables more extensive constructions
- Spatial extent: Structures may extend along one, two, or all three spatial axes.
- Structural complexity: Tasks may involve linear constructions or branching structures with several child blocks
- Relative rotation: Blocks may use consistent orientations or different rotations in increments of 90°
- Block types: A task may require only one block type or a combination of different types.
- Presentation of the target: The complete target structure may be displayed from the beginning or revealed incrementally
- Level of support: Feedback may be limited to an evaluation of the current result or supplemented with guidance concerning possible subsequent actions

These characteristics can be combined to create tasks of varying complexity without changing the fundamental interaction principle. 

=== Conclusion
???
The specific presentation and gradation of the corresponding feedback and assistance are defined in the following visualisation and feedback concept

== Visualisierungs- und Feedbackkonzept <feedback-concept>
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

=== Visualisierung der Zielkonstruktion
- Zu Beginn der Bauaufgabe wählt das Kind in der Lernanwenung eine Zielkonstruktion aus, die während der Bearbeitung als visuelle Referenz verfügbar bleibt
- abhängig vom gewählten Schwierigkeitsgrad kann die Zielkonstruktion vollständig oder schrittweise dargestellt werden [TUI2, FB4]
  - Vollständige Darstellung ermöglicht den Lernenden, den Aufbau eigenständig zu analysieren und eine eigene Vorgehensweise zu planen
  - schrittweise Darstellung kann  den jeweils nächsten Teil der Konstruktion hervorheben und dadurch zusätzliche Orientierung bieten
-Die Zielkonstruktion und die erkannte Ist-Konstruktion müssen visuell eindeutig voneinander unterscheidbar sein -> darstellung entweder in getrennten Ansichten oder räumlich klar voneinander abgegrenzt

FRAGE: in der aktuellen Darstellung wird die Visualisierung der Zielkonstruktion während des Bauens nicht dargestellt. Ziel ist es aber genau diese beschriebene Visualiserung bis zum zeitpunkt wo ich das projekt abgeben muss noch zu realisieren. Wie soll ich das also schreiben? 

=== Visualisierung der erkannten Ist-Konstruktion
- Nach jedem Erfassungsvorgang wird die von Lernanwendung rekonstruierte Ist-Konstruktion dreidimensional dargestellt 
-> jeder erkannte Baustein wird entsprechen seines Typs, seiner berechneten Position und Orientierung so wie sein vom feedback abhängigen Aussehens in die Szene eingefügt
- indem die digitale Darstellung den Lernenden zeigt, welche Konstruktion das System aus ihren Handlungen abgeleitet hat, wird die Anforderung des Interaktionsfeedbacks erfüllt #req("FB1"):
  beispiel: Erscheint ein hinzugefügter Baustein an der tatsächlich positionierten Position, ist erkennbar, dass seine Verbindung technisch verarbeitet wurde. Fehlt ein Baustein oder wird er anders dargestellt als physisch angeordnet, weist dies auf ein mögliches Erkennungsproblem hin

- Da die Darstellung die physische Konstruktion möglichst konsistent abbilden muss #req("TUI3"), orientieren sich die digitalen Bausteinmodelle an der Form und dem Aussehen der realen Bausteine
- die zwei unterschiedlichen Bausteintypen Würfelbaustein und smashed Bausein werden durch entsprechende digitale Modelle repräsentiert, wodurch die Zuordnung zwischen physischem Gegenstand und digitaler Darstellung nachvollziehbar bleibt

- Um die dreidimensionale Szene aus unterschiedlichen Perspektiven betrachten zu können, unterstützt die Ansicht Dreh- und Skalierfunktion. So können insbesondere bei verzweigten Konstruktionen die räumlichen Beziehungen besser wahrgenommen werden
- Die Darstellung soll jedoch zu Beginn automatisch so ausgerichtet werden, dass die Vorderansicht (+y richtung) der gesamten Konstruktion dargestellt wird

=== Verbindung von Visualisierung und Feedback
- Die Darstellung der Ist-Konstruktion wird um die aus dem Zeilvergleich abgeleiteten Feedbackinformationen für die Bausteine ergänzt
-Während die Kopplung zwischen Bausteintyp und digitaler Geometrie statisch festgelegt ist, werden die dargestellten Feedbackzustände während der Nutzung dynamisch zugewiesen

Für die Visualisierung werden insbesondere folgende Zustände der Bausteine benötigt:
- korrekt erkannter und platzierter Baustein
- technisch erkannter, aber inhaltlich abweichender Baustein
- noch nicht besetzte, aber zulässige Position
- noch nicht zugängliche beziehungsweise blockierte Position

Um die unterschiedlichen Zustände für die lernenden sichtbar zu machen, werden unterschiedliche farbige Hervorhebungen für die Bausteine verwendet
  - Korrekte und abweichende Bausteine werden durch unterschiedlich Umrandungen oder Herborhebungen in den Farben grün oder rot gekennzeichnet
  - Mögliche nächste Positionen lassen sich als transparente Platzhalter beziehungsweise sogenannte Ghost Cubes darstellen
  - Noch nicht zugängliche Positionen werden nicht angezeigt, damit keine Handlungsmöglichkeiten suggeriert werden, die zu diesem Zeitpunkt noch nicht möglich sind

so kann die Rückmeldung eindeutig dem jeweils betroffenen Baustein zugeordnet werden #req("FB2")

=== Feedbackebenen
Neben dem visualisierten digitalen Feedback in der Lernanwendung wird außerdem an jedem baustein lokal mit hilfe einer lichtanzeige das digitale Feedback wieder aufgegriffen

- Das System kombiniert also drei Feedbackebenen:
  - intrinsisches physisches Feedback: entsteht durch die mechanische Führung und magnetische Unterstützung der Verbindung -> Beim Verbinden können die Lernenden unmittelbar wahrnehmen, dass zwei Bausteine mechanisch miteinander verbunden wurden -> feedback bestätigt jedoch weder elektronische Erkennung noch inhatliche Korrektheit der Platzierung
  - lokales digitales Feedback: wird direkt an den betreffenden Bausteinen ausgegeben. Durch ein grünes oder rotes Licht wird angezeigt, ob der verbundene Baustein korrekt platziert wurde oder überprüft werden muss
  - globales digitales Feedback: wird in der Lernanwendung ausgegeben. kann neben dem Zustand einzelner Bausteine auch die gesamte Konstruktion, den Aufgabenfortschritt und mögliche nächste Handlungsschritte darstellen -> ermöglicht damit ausführlichere Rückmeldungen, als sie durch die begrenzten Ausgabemöglichkeiten eines einzelnen Bausteins möglich wären
-> dadurch erfolgt das Feedback zwar nicht multidimensional #req("IA6"), aber auf mehreren Ebenen

- Lokales und globales Feedback müssen jedoch inhaltlich übereinstimmen -> wird Baustein lokal als korrekt gekennzeichnet, muss er auch in der digitalen Konstruktion denselben Zustand besitzen

=== Arten des Feedbacks
- Auf Grundlage des theoretischen Hintergrunds wird zwischen Interaktionsfeedback und päfagogischem Feedback unterschieden (kapitel) #req("FB1")

- Interaktionsfeedback
  - zeigt, ob und wie die physische Handlung technisch erfasst wurde, indem der in kapitel x beschriebene erkannte Ist-Zustand der Konstruktion visualisiert wird 

- pädagogisches Feedback 
  - bewertet den erkanten Zustand im Hinblick auf die Zielkonstruktion und kann dabei drei Funktionen erfüllen
  - Ergebnisfeedback zeigt, ob ein Baustein beziehungsweise eine Verbindung korrekt ist.
  - Fortschrittsfeedback macht durch einen Fortschrittsanzeige sichtbar, weiviel der Zielkonstruktion bereits erreicht wurde.
  - Feedforward weist auf eine mögliche nächste Handlung oder Position hin.
-> Für  Prototyp bilden das Ergebnisfeedback und Fortschrittsfeedback die grundlegende Rückmeldung. Feedforward ergänzt diese abhängig vom vorgesehenen Unterstützungsumfang

TABELLE WO EINBINDEN
#figure(
  table(
    columns: 4,
    stroke: none,

    table.header[Rückmeldungsfall][lokales Feedback][Visualisierung in der Lernanwendung][Art des Feedback],

[Verbindung erkannt und korrekt],	[positive Lichtrückmeldung am betroffenen Baustein], [Baustein wird farblich als korrekt hervorgehoben], [Ergebnisfeedback],

[Verbindung erkannt, aber inhaltlich abweichend],	[negative Lichtrückmeldung am betroffenen Baustein], [Baustein beziehungsweise betroffener Bereich wird farblich als abweichend hervorgehoben], [Ergebnisfeedback],

[zulässige nächste Position],	[keine lokale Ausgabe], [optionale Darstellung als transparenter Ghost Cube], [Feedforward],

[Teilfortschritt erreicht],	[keine lokale Ausgabe], [Fortschrittsanzeige wird aktualisiert], [Fortschrittsfeedback],

[Zielkonstruktion vollständig], [keine lokale Ausgabe],	[erfolgreicher Abschluss wird angezeigt], [Ergebnisfeedback],
  ), 
    caption: [Feedbackfälle?],
) <rückmeldungsfälle>

==== abgestufte Unterstützung
- Das Interaktionsfeedback soll zeitnah nach der auslösenden handlung erfolgen #req("DET7"), damit die Systemreaktion einfeutig der Verbindung zugeordnet werden kann. - Auch das Ergebnisfeedback soll zeitnah anzeigen, ob die erkannte Verbindung mit der Zielkonstruktion übereinstimmt.
- Weiterführende Hilfestellungen werden dagegen wie in den Anforderungen #req("FB3") und #req("FB4") gefordert abhängig vom Unterstützungsbedarf abgestuft angeboten:
  - zunächst wird lediglich eine Abweichung am Baustein durch die farbliche Hervorhebung angezeigt
  (- anschließend kann weitere Hilfe in Form einer Erklärung bereitgestellt werden)  
  - bei weiterem Unterstützungsbedarf können zusätzlich die zulässigen nächsten Bausteine/Ghost Cubes dargestellt werden = Feedforward
  - auch die Visualisierung der Zielkonstruktion kann je nach Unterstützungsbedarf nach den in Kapitel (Visualisierung der Zielkonstruktion) unterschiedlichen Darstellungsweisen abgebildet werden

-> Damit bleibt die Möglichkeit zur eigenständigen Fehleranalyse erhalten, während bei Bedarf zusätzliche Orientierung angeboten werden kann

=== Zusammenfassung






  
