I. INTRODUCTION

//selbstgesteuertes lernen
Learners with special educational needs represent a heterogeneous group with different cognitive, perceptual and motor abilities. In particular, learners with support needs related to learning, cognitive development and autism spectrum conditions may experience difficulties with action planning, problem solving and the structuring of tasks. Educational approaches in special education therefore benefit from concrete, structured, and action-oriented learning opportunities that allow learners to interact physically with learning content [1]–[4].

Physical construction systems and other modular manipulatives provide opportunities for direct physical interaction and exploratory problem solving but those materials generally do not provide information about the learners current actions or construction state. Consequently, this means that teachers need to constantly observe and manually interpret children's constructions in order to identify errors and provide corrective feedback. 

But in classroom settings with several learners and their need of individual support, continous supervision of the teacher is not possible which can lead to delays in providing feedback. If errors remain unnoticed during a construction task, learners continue building on an incorrect intermediate state, leading to frustration and making subsequent corrections more difficult. In contrast to that, digital learning applications can provide automated feedback, but typically rely on screen-based interaction and therefore do not provide the same direct physical manipulation of learning materials.

To bring those two ?concepts? together, Tangible User Interfaces (TUIs) provide an approach for bridging physical and digital interaction by using physical objects gleichzeitig as representations and controls for digital information [5]. In tangible learning environments (TLE), learners can therefore manipulate real objects while their physical actions are simultaneously interpreted by a digital system. 


This concept is closely related to constructionist learning theory, in which Papert emphasises active learning through the construction of meaningful artefacts [6]. 
Combining tangible construction with digital interpretation could therefore preserve the benefits of physical interaction while automating parts of the feedback process and reducing the need for continuous teacher intervention.
//Such automated feedback is not intended to replace pedagogical support, but rather to complement it by providing immediate information about the current construction state.

Existing tangible building systems demonstrate different approaches for identifying physical objects and detecting their spatial relationships. 
However, these capabilities need to be integrated into an accessible learning system that addresses the specific requirements of special education and enables physical construction states to be automatically interpreted for the feedback process. To address this challenge, this paper presents the design and implementation of a modular mechatronic smart-brick system that automatically detects and digitally reconstructs physical constructions and compares them with predefined target structures to provide immediate feedback. (Such automated feedback is not intended to replace pedagogical support, but rather to complement it by providing immediate information about the current construction state)


/////
II. RELATED WORK 

Physical building-block systems that connect tangible constructions with digital information can broadly be divided into passive and active approaches.

In this context, passive bricks do not perform local computation. Instead, their identity, position and connectivity within a construction are determined by an external sensing system.

Camera-based systems such as DuploTrack enable the reconstruction of three-dimensional block assemblies, but require visual access to the construction and can therefore be affected by occlusion [X].

RFIBricks uses a radio-based recognition principle with modified UHF RFID tags. Each tag is separated into an antenna and a chip component, which are connected through conductive neodymium magnets. When two bricks are connected, the resulting tag configuration allows both the connected bricks and their relative orientation to be identified by the RFID reader. However, the required UHF RFID reader is comparatively expensive, and the connection principle restricts the supported geometry to vertical stacks [X].

NFCStack similarly identifies objects using lower-cost NFC technology, while the detectable geometry is likewise limited to stacked arrangements [X].

Therefore, passive systems keep the individual building elements technically simple, but transfer the recognition complexity to the surrounding infrastructure and may impose restrictions on construction geometry or interaction space.

//

Active systems, by contrast, integrate electronic processing and communication components into the individual modules. The bricks can therefore contribute directly to detecting and communicating the physical construction.

The i-Cube system, for example, detects neighboring cubes through inductive sensing by symmetrically arranged receivers. This principle determines both the connected faces and their relative orientation, enabling the reconstruction of three-dimensional configurations [X]. However, its sensing architecture requires multiple inductive components on each connection face, resulting in comparatively high hardware complexity.

In roBlocks, connected modules report their topology through an ad-hoc communication network, while magnetic connections simultaneously provide mechanical coupling and electrical contacts. Power can therefore be distributed through the connected structure rather than requiring a battery in every module [X]. Unlike i-Cube, however, the connection interface does not provide a mechanism for determining the relative rotational orientation of two connected blocks. In addition, communication with the external system requires a dedicated wireless communication module.

ActiveCube similarly detects connections between electronic modules and distributes power through the connected structure from a central power component [X]. To achieve connection identification, each cube has a unique identifier and each connection face is assigned a face identifier, allowing the system to determine which surfaces are connected. Additional sensor-equipped functional cubes can use gyroscopic sensing to determine three-dimensional orientation and relative angles. This provides richer spatial information, but requires additional sensing electronics compared with connection-based topology detection alone.

Active approaches therefore provide richer information about the physical construction and reduce dependence on external tracking infrastructure. Their integrated electronics and local power availability additionally enable output to be provided directly by the physical modules. Integrated LEDs or other output elements can communicate state information without requiring the learner to continuously shift attention to an external display [X]. However, the main disadvantage of active systems is that the integrated electronics increase the complexity and cost of the individual modules.

The choice between passive and active bricks therefore represents a trade-off between brick-level simplicity and the recognition and interaction capabilities of the overall system.

For use in special education, however, technical detection capability alone is insufficient. A classroom-oriented system should enable accessible physical interaction, require little preparation before use, remain manageable in terms of maintenance, tolerate repeated handling, and provide clear and timely feedback that supports learners without requiring continuous teacher supervision. Existing tangible building systems demonstrate several of the technical principles required to achieve these goals, but were developed for different interaction contexts and do not specifically address this combination of classroom usability, accessibility, and automated feedback for special education. These considerations motivate the application-specific design requirements presented in the following section.


//// Design rationale
//// selbstgesteuertes lernen
The design rationale was derived from the learning prerequisites of the target group, principles of tangible interaction, and the practical and technical constraints of classroom use. The following key requirements guided the development of the system:

\subsection{Functional Requirements}

\begin{itemize}
    \item \textbf{Spatial construction:} The system should support modular three-dimensional constructions with different connection directions and relative orientations.

    \item \textbf{Automatic observability:} The physical construction should be automatically interpretable to enable its digital reconstruction and comparison with a predefined target structure.
\end{itemize}

\subsection{Interaction Requirements}

\begin{itemize}
    \item \textbf{Accessible interaction:} Physical interaction should be intuitive and require limited fine-motor precision, allowing learners to manipulate the bricks without technical knowledge.

    \item \textbf{Reliable manipulation:} Connections should be easy to establish and separate while providing sufficient stability and clear physical alignment during construction.

    \item \textbf{Immediate feedback:} Feedback should be provided promptly, be easy to understand, and be clearly attributable to the corresponding action or affected brick.
\end{itemize}

\subsection{Classroom Use Requirements}

\begin{itemize}
    \item \textbf{Low-effort operation:} The system should require minimal preparation and maintenance to enable straightforward integration into classroom activities.

    \item \textbf{Safety and robustness:} The system should withstand repeated physical handling while minimizing mechanical and electrical risks during use.
\end{itemize}

These requirements form the basis for the mechanical, electronic, and software design decisions described in the following section.
////
//// A. Overall System Architecture
The developed system combines active smart bricks, a baseplate, and a browser-based learning application in a closed physical-digital interaction loop. The building process starts when the learner selects a target construction in the learning application. Once the activity is started, the application triggers the detection process through the baseplate and the learner can begin to assemble the smart bricks. (system detects the built structure and wandelt es in eine real time viusalisation um und builds digital representation. gives then feedback etc. und endet mit fertig -> kompletter ablauf einmal erklären)
//The system continuously detects the evolving physical construction, generates a corresponding digital representation, and provides feedback on the current construction state.

Each smart brick is designed as an active, tangible construction element that can be grasped, connected and rearranged. The embedded electronics allow the system to identify the module and its relative orientation and additionally communicate with the neighboring attached modules. The baseplate forms the root of the physical construction and supplies the connected bricks with power (+ provides the communication interface between the brick network and the digital system.)

Starting from the baseplate, the physical construction is acquired through local parent-child relations between adjacent bricks. Each brick has one upstream connection/docking face to its parent and multiple downstream connections/receiving faces to potential children - das vlt verallgemeinern weil erst in den nächsten kapiteln genannt. This hierarchical organization avoids ambiguous connection loops while enabling branched three-dimensional constructions. Rather than requiring a global sensing system, each brick only needs information about its own identity and its directly connected neighbors. These local data are recursively aggregated into a representation of the complete construction and transmitted through the baseplate to the learning application.


The learning application then reconstructs and visualises the detected construction in real time and compares it with the selected target structure. Based on this comparison, live feedback is provided, allowing the learner to determine whether the construction is correct so far or individual bricks have been placed incorrectly. Detection and feedback are repeated throughout the activity, allowing changes to the construction to be captured and evaluated as the learner modifies it. Finally, the interaction cycle is terminated by the learning application when either the physical construction matches the target construction or the building process is aborted.

Keeping the task-specific interpretation within the learning application separates the acquisition of the physical topology from its educational evaluation. The bricks and baseplate detect the physical construction independently of the selected task, while the learning application interprets the resulting structure with respect to the currently selected target.



//// B. Mechatronic Brick Design
//// functinal requirements = 1
//// interaction requirements = 2 - immediate feedback vlt bei learning application; automatic observability vlt bei ?
//// classroom use requirements = 3

The smart bricks were designed as active modules in which mechanical and electrical functions are closely integrated into the physical brick-to-brick connection. To limit the complexity of manufacturing and connection detection, a standardized square connection geometry with two functionally distinct interface types was defined. Each brick has one docking face, which provides the upstream connection to its parent and thus to the existing construction, and one or more receiving faces, to which additional bricks can be attached through their respective docking faces. This concept enables branched *three-dimensional constructions (1)* with different connection directions and relative orientations. Based on these specifications, two brick types with different geometries and connection possibilities were implemented, as shown in Fig. X.

To *support accessible and reliable physical manipulation*, the bricks are connected through a combination of magnetic attraction and mechanical guidance. The docking face contains recessed connection features, while the receiving faces provide corresponding protrusions. Magnets assist during placement and maintain the connection, while the complementary geometry guides adjacent bricks into a defined alignment and ensures correct positioning of the electrical contacts. This *reduces the fine-motor precision required to establish a connection (2)* while providing sufficient stability during construction.


Each mechanical connection is complemented by an electrical interface using recessed spring-loaded, low-resistance contacts. The mechanically interlocking geometry ensures correct alignment of the electrical terminals and prevents unintended contact between incompatible terminals. Together with the low operating voltage of 5 V DC, *this minimizes electrical hazards and the risk of short circuits, supporting safe physical interaction for children during intended use (3)*. Beyond power distribution, each receiving face provides a downstream signal contact, while four orientation-dependent contacts are integrated into the upstream docking interface. Their use for orientation detection, topology acquisition, and communication is described in Section IV-C. 

FIG

The electronics are enclosed within the brick housing. Each brick contains a custom PCB based on an ATtiny1616 microcontroller and integrated *feedback LEDs (1)*. *To minimize maintenance during classroom use (3)*, individual batteries were avoided; instead, the baseplate provides a centralized 5 V supply that is distributed through the connected brick structure.

Thus, a single physical brick-to-brick interface simultaneously establishes the mechanical relation between adjacent bricks, distributes electrical power, and provides the electrical basis for communication, topology detection, and relative orientation detection. Integrating these functions directly into the physical connection reduces the need for additional sensing components and avoids external sensing infrastructure.


//// C. Topology Detection and Communication
The construction is detected recursively through local parent-child communication, starting from the baseplate as the root and initializator of the physical structure. During each detection cycle, each brick determines its local relation to its parent and sequentially queries its receiving faces for connected child bricks using the electrical interfaces described in Section IV-B.

If a child responds, the parent identifies the occupied connection face from the interface currently being queried, while the child determines its relative rotational orientation through its docking interface. Together, the connection face and relative orientation define the local spatial relation between the two bricks.

Relative orientation is detected through the electrical contact arrangement of the connection. Each receiving face provides a single communication contact, while the docking face contains four orientation-dependent contacts corresponding to rotations around the connection axis in 90° increments. Depending on the rotational alignment of the two bricks, one of these four contacts connects to the communication contact of the parent's receiving face. By detecting which docking contact is active, the child determines its orientation relative to the parent. The same established signal path is subsequently used for data communication with the parent, eliminating the need for a separate orientation sensor.

Communication over this signal path is therefore implemented as a bidirectional single-wire half-duplex interface. To avoid electrical contention, the line exhibits open-drain-like behavior: it remains released in its idle state and is actively pulled low only during transmission.


Once a construction activity has been started by the learning application, the baseplate repeatedly initiates detection cycles by querying the connected root brick. Each brick sequentially polls its downstream interfaces in a predefined order. If a child responds, it first determines its relative orientation and recursively applies the same detection procedure to its own children before responding to its parent. Only after its complete subordinate structure has been detected does the child return its result to the parent. This recursive process results in a depth-first traversal, with each branch being followed to its outermost brick before detection continues at the next downstream interface.

The payload returned by each brick contains its identifier, relative orientation, a bit mask indicating the occupied downstream interfaces, and the recursively appended payloads received from its children:

NODE_ID | ORIENTATION | CHILD_MASK | CHILD_PAYLOADS

For transmission, each data frame consists of a start marker, a payload length field, the payload itself, and a checksum for basic error detection. Received child frames are not embedded as complete frames within the parent payload. Instead, only their payloads are appended in the predefined interface order to the parent's own node information, resulting in a preorder serialization of the corresponding subtree.
The parent then generates a new frame containing its complete aggregated subtree payload and transmits this frame to its own parent.
As this process is recursively repeated toward the baseplate, no individual brick requires knowledge of the complete construction; the global topology emerges from the aggregation of local connection information.

The baseplate ultimately receives the serialized representation of the complete construction and forwards it to the learning application for reconstruction and evaluation. The same communication infrastructure is subsequently used in the reverse direction to relay the generated feedback to the physical bricks.

//// D. Digital Reconstruction and Learning Interface/Feedback
The serialized topology received from the baseplate is deserialized by the learning application into a hierarchical tree representation containing the structural and spatial information of the detected construction. Based on this information, the spatial pose of each brick is reconstructed recursively from its relation to its parent. 
The connection face determines the relative position of the child, while the detected orientation determines its rotation.
Applying these transformations recursively yields a three-dimensional digital representation of the current physical construction, which is visualized in the browser-based learning application.

For each construction task, the detected tree is then compared with the predefined target tree which results in an evaluated tree. This forms the basis for two complementary forms of feedback: physical feedback at the bricks and digital feedback within the learning application.

For physical feedback, the evaluation results are converted into brick-specific feedback data and transmitted from the learning application to the baseplate. From there, the feedback message is recursively relayed through the same parent-child communication structure used for topology detection. (Each brick extracts the feedback associated with its identifier and forwards the same data message to its connected children.) Depending on its/the bricks evaluation state, the integrated LEDs indicate a correct placement in green or an incorrect placement in red.

Digital feedback is linked to the visual representations of the bricks in the learning application and can provide more differentiated information about the overall construction state. The visualization distinguishes between correctly placed bricks, incorrectly placed or unexpected bricks, permissible next positions and positions that are not yet accessible because preceding bricks are missing.
BILD
Depending on the required levle of support, the digital representation also enables the amount of assistance to extend beyond the binary physical feedback: The application can provide outcome feedback on the current construction, progress feedback on advancement toward the target and also feedforward information indicating permissible subsequent actions or positions \cite{shute2008focus, hattie2007power}.

Physical and digital feedback therefore serve complementary purposes: While the LEDs provide immediate and locally attributable information,  the learning application provides a more comprehensive representation of the construction state and additional guidance when required. Together, the two feedback channels are intended to support independent error correction while allowing the level of digital guidance to be adapted to the learner.
//selbstgesteuertes Lernen

//// erklären warum diese architektur gewählt wurde
Beispielsweise:

Central power distribution
→ keine Batterien in einzelnen Bricks
→ geringerer Wartungsaufwand.

Local parent-child communication
→ keine globale Sensorik erforderlich
→ modulare Skalierung.

Four orientation contacts
→ Orientierung wird ohne IMU oder zusätzliche Sensorik bestimmt.

Single-wire half-duplex communication
→ geringe Kontaktzahl.

Tree representation
→ physische Struktur kann rekursiv erfasst werden.

Das sind wissenschaftlich interessantere Aussagen als eine reine Komponentenbeschreibung.

////technische idee mit der physischen verbindung die mehrere funktionen übernimmt
Ich würde besonders hervorheben, dass die physische Verbindung selbst gleichzeitig mehrere Funktionen übernimmt:

mechanical connection
electrical power transfer
communication
orientation encoding
topology detection.

Das ist eine ziemlich schöne mechatronische Integration.

In der Bachelorarbeit ist das über verschiedene Kapitel verteilt. Im Paper kannst du daraus einen klaren Design Contribution machen:

The connection interface simultaneously establishes the mechanical relation, distributes power, provides the communication channel, and encodes the relative orientation between adjacent modules. 


//evaluation
evaluation mit lehrkräften konzept vorgestellt 
interview focused on the principle and concept 

A semi-structured expert evaluation with teachers of a special-needs school was conducted to assess the developed prototype from a special-education and classroom-use perspective. It was structured around a demonstration of the prototype and its intended interaction cycle and focused on the interaction and classroom-use requirements defined in Section III.
Particular attention was given to its suitability for heterogeneous support needs and its practical applicability in classroom settings. The expert was additionally asked to assess whether automatic construction detection and immediate brick-specific feedback could support more independent error correction and reduce the need for continuous teacher intervention.



//results
vlt hier erst selbstgesteuertes lernen 

//Discussion
The expert evaluation indicates that the developed system is generally suitable for the intended special-education context. The tangible reconstruction task preserves the direct and action-oriented character of physical learning materials, while task difficulty can be adapted through the complexity of the target construction. According to the expert, this makes the concept applicable to learners with varying support needs and addresses the requirement for accessible interaction.

Automatic interpretation of the construction state and immediate feedback were considered particularly relevant for supporting more independent error correction. The combination of local brick-specific and digital feedback allows errors to be communicated promptly and attributed to the affected part of the construction. Different levels of assistance can further adapt the feedback to individual support needs. This supports more self-directed activity and can reduce the need for continuous teacher intervention. Automated feedback should, however, complement rather than replace pedagogical support.

The evaluation also highlighted the importance of considering physical and digital interaction as a combined system. Clear representation of brick types, orientations, and construction starting points was considered important for enabling learners to interact with the system more independently.

Regarding the physical system, the combination of mechanically guided and magnetic connections was considered appropriate for accessible and reliable manipulation. The integrated electrical interface additionally enables automatic observation of the construction without requiring external tracking infrastructure, thereby addressing the functional requirement of automatic observability.

The evaluation remains formative and does not demonstrate effects on learning outcomes or teacher workload. The potential of automatic detection and immediate feedback to support independent error correction and reduce continuous teacher intervention therefore requires subsequent validation during realistic classroom use.








//// conclusion
Such automated feedback is not intended to replace pedagogical support, but rather to complement it by providing immediate information about the current construction state.

//vorherige latex version
