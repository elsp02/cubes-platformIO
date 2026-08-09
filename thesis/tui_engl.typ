#set page(numbering: "1")
#set par(justify: true)

= TUI


== graphical vs tangible user interface
A user interface can be defined as the point of contact through which people communicate and interact with a technical system. The widely utilised form is the graphical user interface (GUI), in which digital information is visually represented on a screen and manipulated through input devices such as a mouse, keyboard, or touchscreen. (quelle)

Shaer and Hornecker (2019) contrast this mode of interaction with people’s everyday experience of the physical environment: (pookkottuvariam)

“We live in a complex world, filled with myriad objects, tools, toys, and people. Our lives are spent in diverse interaction with this environment. Yet, for the most part, our computing takes place sitting in front of, and staring at, a single glowing screen attached to an array of buttons and a mouse” (Shaer and Hornecker, 2010, cited in Pookkottuvariam).

The quotation highlights the separation between traditional computer interaction and people’s embodied experience of the physical world. In everyday life, objects can be grasped, combined and explored through several senses, whereas conventional GUIs, by contrast, translate these actions into interactions with visual representations on a two-dimensional display. Consequently, digital interaction frequently utilizes only a limited extent of people's innate physical capabilities, potentially resulting in a reduced level of intuitiveness.

The concept of Ishii and Ullmer’s Tangible Bits responds to this separation by coupling digital information with everyday physical and graspable objects and the surrounding environment. Its central aim is to bridge the divide between the digital domain of bits and the physical world of atoms, thereby making digital information directly accessible through physical manipulation (vgl. Ishii & Ullmer, [year], p. [X]). Tangible Bits consequently provided an important conceptual foundation for the development of Tangible User Interfaces (TUIs) (Tangible Bits).

=== (Tangible User Interfaces) - vlt weglassen
Different to a GUI, in a TUI, the computer becomes a natural extension of the physical environment. Interaction does not occur exclusively through graphical elements on a screen; instead, users manipulate real world objects, reffered to physical icons or phicons in order to interact with the digital system. These phicons do not merely serve as input devices but they also fulfil a representational function. (Pookkottuvariam).

The fundamental principle of a TUI is predicated on two closely related characteristics (token and constraints)

+ Physical objects (phicons) are used as representations of digital information and computational operations.
+ The physical manipulation of these objects is used to interact with the associated computational operations.

Because different types of information or functions can be represented by separate physical elements, multiple phicons may remain available for simultaneous manipulation. They may also be operated in parallel or with both hands. This principle, known as _space multiplexing_, can improve interaction efficiency and facilitate collaborative use by groups, which is typically more restricted in conventional GUI-based interaction.

=== MVC and MCRpd Model (emerging frameworks)
vlt auch unterkategire von "From Graphical to Tangible User Interfaces" kapitel

The difference between these styles of user interfaces becomes more obvious when comparing their undelying interaction models shown in the figure @MVC_MCRpd_Model.

==== MVC - model for GUI (emerging frameworks)
Within the Model–View–Controller (MVC) architecture, an interactive software system is divided into three functional components: The _model_ represents the underlying data and the current state of the system, the _view_ presents this information graphically, while the _control_ processes user input and translates it into changes to the model. Therefore, in the interaction model of GUIs, there is a clear separation between the control devices, such as the mouse and keyboard and the digital representation displayed on the screen.

==== MCRpd model for TUI
The interaction model for TUIs retains the MVC _model_ and _control_ components but replaces the exclusively graphical _view_ with both a physical representation (_rep-p_) and a digital representation (_rep-d_). It thereby accounts for the fact that, in a TUI, digital information is not represented solely on a screen but is also given a tangible physical form. The ?structure? of the physical components can be characterised by three central properties:

+ The physical representation is coupled with digital information
+ The physical representation incorporates mechanisms for interactive control
+ The physical state of the object contains information about the digital state of the system

Consequently, the physical representation performs a dual function: On the one hand, it represents digital information and system states, and on the other, it serves as an interactive control element. Hence, the position, orientation or arrangement of a phicon for example can encode information about the corresponding digital state. At the same time, moving, rotating or connecting the object modifies that state. Thus, representation and control are connected not only conceptually, but also physically.

The distinctive characteristic of a TUI therefore lies in the close coupling between representation and action. In contradistinction to a GUI, where the input action and the visual representation of digital information are typically separated, a TUI integrates both functions within the same physical object (Pookkottuvariam, p. 82).

#figure(
  image("figures/MVC-MCRpd-Model.svg", width: 100%),
  caption: [a) interaction model of GUI: MVC model; b) interaction Model of TUI: MCRpd model],
) <MVC_MCRpd_Model>

=== Conclusion - hier oder ganz am ende?
Unlike a GUI, in which representation and input are commonly distributed between the screen and a separate input device, a TUI partially unites representation of digital content and control for interacting with that content within the same physical artifact.
This integration enables TUIs to provide a suitable technological basis for the constructivist and constructionist learning approaches discussed in Section X. They enable learners to explore relationships through active manipulation and to externalise their ideas by constructing tangible, directly modifiable artefacts.


== Coupling objects with digital information (emerging framework)
?? in diesem kapitel überschriten ändern bzw schauen wie man inhalt logisch gliedert

But how does digital information become linked to physical objects? And what format can this link be presented? Ullmer and Ishii answer these questions by providing an overview of the various types of digital bindings,coupling methods and approaches to physical representation (see Ullmer & Ishii 2001, pp. 7–9).

=== Types of digital Bindings
Physical objects can be associated with different types of digital information. These include static media, such as images and three-dimensional models; dynamic content, such as video streams or computationally generated graphics; and digital attributes, including colours or material properties. Physical objects may also represent computational operations or data structures such as lists and trees and can also be linked to remote devices, locations, or people (cf. Ullmer & Ishii, 2001, pp. 7–8).
BEISPIEL!!

Within a TUI, a physical object does not necessarily correspond to a single digital file but can have different digital meanings. For example, it can represent individual pieces of content or a collection of media, or it can trigger a function or control another technical device. What matters most to users is the meaning of the object and the possible actions associated with it, rather than how the underlying data is processed.

=== Methods of coupling
In addition to the different types of information represented, coupling methods serve to categorise how and when the relationship between a physical object and its digital representation is formed:

+ In _static coupling_, the meaning of an object is defined in advance. The physical object is permanently associated with a specific digital geometry, property or function, and this association cannot be altered during interaction.

+ By contrast, a _dynamic coupling_ is established or modified during use. For instance, inserting a Phicon into a specific slot or performing an action within a graphical user interface can associate it with new digital content or alter its existing assignment.

+ _Interactive coupling_ occurs when the meaning of an object changes depending on the other objects with which it is connected or combined (p. 8).

_Static bindings_ therefore provide a stable and often more easily understandable meaning, whereas _dynamic_ and _interactive bindings_ enable the same physical objects to be used more flexibly. Regardless of which coupling method is used, it is esssential for the system that changes to the physical object are reflected immediately transparently in the digital representation. If this correspondence is delayed, missing or inconsistent, the relationship between the physical and digital representations becomes difficult to understand.

=== Approaches to physical representation
Not only the temporal precision of coupling influences how clearly its digital meaning and potential interactions can be understood but also the appearance of it. There are four approaches to choose from:

Beispiele für jedes einfügen- JAAA

The _found objects_ approach involves taking everyday objects and augmenting them with technology before placing them within a new digital context. This gives a familiar object an additional representational or control function.

When the physical form is primarily determined by electronic and mechanical requirements, the design can be described as _engineering-driven_. While this approach often facilitates technical implementation, it can result in comprehensibility, ergonomics and aesthetic quality being overlooked.

In contrast to this is the _design-driven_ approach, where aesthetic qualities and symbolic expressiveness are emphasised more. The physical form communicates the meaning of the associated digital content and provides users with cues about possible forms of interaction.

The last approach is based on established _work practices_. Here, the design draws on existing physical artefacts from specific professional or application contexts, building upon familiar procedures, conventions and meanings.

=== Conclusion

The coupling between physical objects and digital information can differ in content, flexibility, and physical representation. Selecting an appropriate approach therefore requires a careful consideration of the intended users and their abilities, as well as the specific application context. Regardless of the chosen approach, an effective TUI requires a clear and immediately perceptible relationship between the physical object and the associated digital meaning. The design of this coupling therefore directly influences the system’s comprehensibility, usability, and flexibility.


== Physical Configuration and Digital Interpretation in TUIs
Once digital information has been assigned to phicons, it must be determined how these objects can be physically arranged and how changes in their configuration can be translated into digital operations. One approach to describing this relationship is the Token-and-Constraint Framework.

=== The token and Constraint Framework (token and constraints)
One approach to structuring tangible interaction is the token-and-Constraint framework, where physical objects (sagen dass sie hier token heißen ich sie aber phicons nenne weil so vorher genannt) are connected to physical structures that organise and restrict how these phicons can be used.
These so called _Constraints_ define mechanically where and in what manner phicons can be placed or moved and constitute physical regions or structures to which specific digital operations are assigned.

==== Phases of Interaction
The Interaction within Token-and-Constraint systems can involve two phases: _Associate_ and _Manipulate_

During the _Associate_ phase a phicon is placed within a constraint, thereby establishing a logical relationship between the information represented by the phicon and the operation assigned to the constraint. This initially creates a discrete state, such as presence or absence, activation or deactivation, or selection and deselection. The same phicon may be inserted into different constraints in order to associate its digital information with different predefined operations.

The _Manipulate_ phase starts once the phicon has been physically engaged with the constraint. The phicon can now be moved within the constraint's mechanical boundaries to modify parameters of the associated operation. The absolute and relative positions of phicons, both in relation to the constraint and to one another, can result in different digital interpretations. The meaning of an interaction therefore emerges from the interplay between the phicon, the constraint, and the overall physical configuration. Translating or rotating of the phicon may result for example in the continuous adjustment of a value, the navigation through a list, or the alteration of another variable of the digital system. However, not every phicon-and-constraint system needs to support both phases of interaction since in some systems, inserting and removing a phicon may already constitute the complete interaction.

=== Interaction Qualities
Physical constraints influence not only the digital interpretation of an action but also its haptic and perceptual qualities:
Mechanical (sind alle physical constraints mechanical constraints??) constraints are known to generate immediate haptic feedback and can physically guide the movement of the user's hand. This makes it possible to perform certain actions without continuously directing visual attention towards a graphical display like with a GUI. Furthermore, the physical syntax renders some of the available interaction possibilities directly perceivable. In this context, syntax refers to the rules according to which individual phicons can be combined to form an input that can be meaningfully interpreted by the system. The configuration and mechanical configuration of the constraints function as a physical grammar by directly indicating which actions are possible and which are prevented. This supports the creation of physical configurations that are interpretable both by the user and by the underlying computational system. By reducing the range of possible manipulations, invalid states can be avoided and the available courses of action can be made easier to understand.

=== Styles of mapping
ÜBERLEITUNG

mapping styles describe how the resulting physical configuration is translated into a computer-interpretable representation. Three principal styles can be distinguished: spatial, relational and constructive mapping.

In spatial mapping, interpretation is based on the geometric position, distance, or orientation of phicons in physical space. The pivotal factor, therefore, is the object's position within a spatial frame of reference.

In the context of relational mapping, the absolute position of a phicon is less significant than its relationship to other phicons or to a particular constraint. The digital interpretation may therefore depend on properties such as sequence, proximity, adjacency, or assignment. Relational mapping is one of the most frequently employed mapping styles in token-and-constraint systems.

In constructive mapping, the digital meaning of a given structure is derived from the manner in which several physical components are assembled into a larger structure. The interpretation is therefore not based on a single element, but rather on the resulting overall physical structure.

But these mapping styles are not mutually exclusive since a tangible interface may interpret both the relationships between objects and their spatial position or orientation.

FAZIT

= Feedback and Visualization
== Feedback und Visualisierung
bei TUI informiert Feedback den Nutzenden darüber, ob eine handlung erkannt wurde, wie sie interpretiert wurde und welchen Zustand das System angenommen hat. Sie schließt damit den Wahrnehmungs- und Handlungskreislauf zwischen physischer Manipulation und digitaler Verarbeitung. 

Bei lernorientierten Tangible User Interfaces sind zwei Ebenen des Feedbacks voneinander zu unterscheiden: 
+ Interaktionsfeedback zeigt, ob und wie eine physische Handlung technisch erfasst und verarbeitet wurde. 
+ Pädagogisches Feedback bewertet daraufhin die Handlung oder das erzielte Ergebnis im Hinblick auf die jeweilige Lernaufgabe. 

Ein System kann eine Handlung also technisch korrekt erkennen und sie trotzdem als inhaltlich falsch bewerten. Umgekehrt darf eine fehlerhafte oder ausbleibende technische Erkennung aber nicht als Fehler der lernenden Person dargestellt werden. Das Interaktionsfeedback bildet daher die Voraussetzung für verlässliches pädagogisches Feedback.  

=== Formen und Modalitäten von Feedback
Die physische Beschaffenheit einer TUI erzeugt zunächst ein intrinsisches Feedback, das unmittelbar aus der Manipulation der Gegenstände hervorgeht. Zusätzlich dazu kann eine digitale Rückmeldung erzeugt werden. Die Folgen einer Handlung können vom System also durch unterschiedliche Ausgabemodalitäten vermitteln, was die untenstehende tabelle aufzeigt. Eine Möglichkeit stellt das multimodale Feedback dar. Dies definiert nicht, möglichst viele Signale gleichzeitig auszugeben und dadurch womöglich eine Reizüberlastung zu verursachen. Unterschiedliche Modalitäten sollen vielmehr alternative Zugänge ermöglichen, die gezielt und widerspruchsfrei miteinander kombiniert werden, falls ein Wahrnehmungskanal von einem Nutzenden nicht oder nur eingeschränkt genutzt werden kann.

Unabhängig von der Modalität lässt sich Feedback außerdem anhand mehrerer Dimensionen beschreiben:
+ lokal oder global: direkt am Objekt oder auf einer separaten Anzeige,
+ diskret oder kontinuierlich: Bestätigung eines Ereignisses oder fortlaufende Anzeige eines Zustands,
+ unmittelbar oder verzögert: direkte Reaktion oder spätere zusammenfassende Rückmeldung,
+ dauerhaft oder flüchtig: sichtbar, bis eine Korrektur erfolgt, oder nur kurz angezeigt.

Feedbackformen
+ intrinsisch: Formschluss, Widerstand oder Einrasten vermitteln unmittelbar Informationen über die Handlung
+ visuell: LEDs, Displays, Projektionen oder Animationen zeigen Zustände, Fehler und Veränderungen
+ auditiv: Töne oder Sprache können Aufmerksamkeit erzeugen und Informationen ohne Blickkontakt vermitteln
+ haptisch/mechanisch: Vibration, Bewegung oder Force-Feedback machen Systemreaktionen körperlich wahrnehmbar
+ multimodal: Mehrere aufeinander abgestimmte Modalitäten vermitteln dieselbe oder ergänzende Informationen über verschiedene Wahrnehmungskanäle

FAZIT

==== Qualitätskriterien verständlichen Feedbacks
Die Wirksamkeit von Feedback hängt nicht allein von seiner technischen Form ab, sondern insbesondere davon, wie verständlich und handlungsrelevant es für die Nutzenden ist. Verständliches Feedback sollte deshalb folgende Kriterien erfüllen:

+ Zeitnähe: Die Rückmeldung sollte in einem erkennbaren zeitlichen Zusammenhang mit der auslösenden Handlung stehen. Erfolgt sie zu spät, ist ihre Ursache möglicherweise nicht mehr eindeutig zuzuordnen.
+ Eindeutigkeit: Es muss erkennbar sein, auf welche Handlung oder welches Objekt sich die Rückmeldung bezieht.
+ Konsistenz: Gleiche Zustände und Ereignisse sollten durch gleichartige Signale dargestellt werden. Farbe, Ton oder Symbol dürfen ihre Bedeutung nicht ohne nachvollziehbaren Grund verändern.
+ Wahrnehmbarkeit: Das Feedback muss ausreichend deutlich sein, ohne andere relevante Informationen zu überlagern.
+ Angemessenheit: Intensität und Umfang der Rückmeldung sollten der Bedeutung des Ereignisses entsprechen. Eine gewöhnliche Bestätigung benötigt beispielsweise kein ebenso auffälliges Signal wie eine kritische Fehlermeldung.
+ Handlungsorientierung: Das Feedback sollte nicht nur einen Zustand anzeigen, sondern gegebenenfalls auch erkennen lassen, wie die Interaktion fortgesetzt oder korrigiert werden kann.
+ Zugänglichkeit: Wichtige Informationen sollten über geeignete beziehungsweise alternative Wahrnehmungskanäle zugänglich sein.

Gerade bei unterschiedlichen sensorischen, kognitiven und kommunikativen Voraussetzungen sind anpassbare und redundante Rückmeldungen relevant.

=== Belottis 5 fragen zur Gestaltung von Feedback (token and constraints)
vlt vorverschieben
Für sensorbasierte und greifbare Interaktionssysteme entwickelten Bellotti et al. fünf Fragen, anhand derer sich die Verständlichkeit einer Interaktion systematisch untersuchen lässt. Wechselspiel zwischen Sytsem und Nutzende
Das Modell betrachtet dabei, ob einob Nutzende die Aufmerksamkeit, Interpretation und Reaktion des Systems nachvollziehen können (vgl. Bellotti et al., 2002).
TABELLE
+ Address	Wie erkennt das System, dass eine Handlung an das System gerichtet ist?
+ Attention	Woran erkennen die Nutzenden, dass das System aufmerksam ist und die Eingabe registriert?
+ Action	Wie erkennt das System, auf welches Objekt und welche Operation sich die Handlung bezieht?
+ Alignment	Woran erkennen die Nutzenden, dass das System ihre Absicht korrekt verstanden und ausgeführt hat?
+ Accident	Wie können Fehlinterpretationen, unbeabsichtigte Handlungen und technische Fehler erkannt und korrigiert werden?
-> Die fünf Fragen verdeutlichen, dass eine technisch erfolgreiche Erkennung allein nicht ausreicht. Die Interpretation des Systems muss für die Nutzenden nachvollziehbar sein, und Missverständnisse müssen ohne unverhältnismäßigen Aufwand korrigiert werden können.

=== Pädagogisches Feedback
 Während Interaktionsfeedback in erster Linie bestätigt, ob eine Handlung technisch erfasst wurde, bezieht sich pädagogisches Feedback auf die Bedeutung dieser Handlung innerhalb eines Lernprozesses. Es soll Lernende dabei unterstützen, den aktuellen Bearbeitungsstand einzuschätzen und Abweichungen von einem angestrebten Ergebnis zu erkennen, damit die Lernenden ihr weiteres Vorgehen anpassen können.

Sinnvolle Unterscheidung:
+ Ergebnisfeedback: richtig oder falsch,
+ Prozessfeedback: Hinweis auf die Vorgehensweise oder Fehlerursache,
+ Feedforward: Orientierung für den nächsten Schritt,
+ Fortschrittsfeedback: Anzeige des bereits Erreichten.

Für selbstgesteuertes Lernen ist eine reine Rückmeldung in Form von „richtig“ oder „falsch“ häufig nicht ausreichend, denn sie zeigt zwar, ob eine Abweichung vorliegt, unterstützt jedoch nur begrenzt dabei, deren Ursache zu erkennen um eine Lösung für den Fehler zu entwickeln. Gleichzeitig darf das System nicht jeden Handlungsschritt vollständig vorgeben, weil sonst die eigene Planung und Problemlösung reduziert werden.
Eine geeignete Möglichkeit stellt deshalb abgestuftes Feedback dar, bei der die Unterstützung schittweise erweitert wird: Zunächst wird lediglich angezeigt, dass Fehler vorliegt. Wenn dies nicht ausreicht, kann kenntlich gemacht werden, auf welchen Teil der Handlung oder Konstruktion sich diese Abweichung bezieht. Bei weiterem Unterstützungsbedarf wird ein allgemeiner Lösungshinweis angeboten. Und erst wenn ein allgemeiner Lösungshinweis auch nicht ausreicht, folgt eine konkrete Hilfestellung.
Auf diese Weise wird sichergestellt, dass die Möglichkeit zur selbstständigen Fehleranalyse erhalten bleibt, während zugleich verhindert wird, dass Lernende aufgrund einer unverständlichen Rückmeldung nicht weiterarbeiten können.

==== Perspektive der Zielgruppe vlt eher nach potenzialen TUI für Kinder?


== Potentials of TUIs for children (with dissorders) (liang)
Research attributes various potentials to TUIs for children’s learning. However, since these findings often originate from studies involving children without specifically identified special educational support needs, they cannot be transferred without qualification to students in the areas of intellectual development, learning, and autism. The following potentials are therefore considered in an extended manner that takes into account the target-group-specific conditions and ?the shared learning objectives defined in the introduction.?

=== Supporting Novices through Scaffolding and Accessibility
Kompetenzbereich
By representing complex technical details in a simplified manner through phicons, tangible user interfaces can translate abstract and complex technical processes into directly perceivable actions and thereby lower the knowledge threshold required for interaction. The use of familiar objects and physically comprehensible actions, such as grasping or matching, can facilitate access to complex content, particularly for novices, and reduce cognitive load.

?This can be especially relevant for students who require support with memory, concept formation, or the structuring of actions?. However, for children with the considered support needs, the meaning of an object and the actions it enables must be clearly recognisable, as physical properties may otherwise create expectations that do not correspond to the object’s digital function. Clearly distinguishable objects and structured, manageable interaction possibilities are therefore required. Possible motor, visual, auditory, or communicative impairments must also be considered, and information should be accessible through alternative perceptual channels. But, this multimodality does not mean presenting as many stimuli as possible simultaneously, but rather providing equivalent and individually adaptable forms of access.

=== Playful Exploration and Error-Tolerant Learning
Kompetenzbereich
In accordance with the principles of constructionism (bezug), familiar objects not only facilitate initial access but can also create a protected environment in which children are able to experiment without fear of risk or failure. When actions can easily be reversed and errors do not result in lasting negative consequences, autonomous and exploratory experimentation becomes possible. Different solution strategies can then be tested through trial and error. This may also lead to approaches that extend beyond predefined instructions and encourage the development of independent solutions.

However, a large number of simultaneously available options can make orientation more difficult and lead to cognitive overload for students in the selected special educational focus areas. Structured exploration is therefore appropriate, in which clear intermediate goals, limited choices, and gradual assistance provide a comprehensible framework for action. Errors should not remain unnoticed but should be communicated immediately and unambiguously without fully prescribing the subsequent course of action, as this could otherwise lead to confusion and frustration. Sufficient processing time, repeatable action sequences, and individually adaptable support enable learners to complete tasks at their own pace.

=== Promoting Initiative and Motivation
Kompetenzbereich
Exploratory activity creates opportunities for learners to develop personal ideas and creative solution strategies. As explicitly emphasised in constructionism, children shift from being recipients of information to becoming active creators and can thereby express their individual ideas, preferences, and emotional states. The immediate relationship between their own actions and a perceptible effect can support experiences of autonomy and competence.

For learners with different support needs, however, the available choices must remain comprehensible, manageable, and adapted to their individual abilities. Achievable intermediate goals and visible learning progress can help to reduce uncertainty and repeated experiences of failure.

=== Supporting Cognitive Development and Spatial Learning
Kompetenzbereich
To enable children to concentrate on experimenting with new elements, the possible range of actions can be restricted through a token-and-constraint system. As described previously, such systems make part of the interaction rules perceptible through their physical form and arrangement. Consequently, not all possible action sequences need to be remembered and processed mentally, which can reduce the cognitive demands placed on the learner.
The manipulation of tangible objects also combines visual perception with haptic and motor experiences and thereby relates to the theory of embodied cognition (bezug). Actions such as grasping, rotating, and spatially arranging objects can help learners physically comprehend positions, orientations, and relationships. This may support spatial awareness and the ability to form mental spatial representations.

For learners with the considered support needs, these characteristics can particularly support the recognition of relationships and the development of problem-solving abilities. However, the number and complexity of spatial relationships should be adapted to the individual learner’s current level and expanded gradually.

=== Promoting Communication and Collaboration
Kompetenzbereich
The possibility of space multiplexing described in (bezug) can also benefit children. The simultaneous and shared manipulation of objects in physical space can naturally encourage cooperation and mutual inspiration. Ideas that are difficult to express verbally can be demonstrated, explained, and discussed through the constructions that have been created. Due to the physical nature of the interaction, TUIs can therefore provide a shared point of reference for learning in groups.

This may be particularly relevant for learners who use augmentative and alternative communication or whose receptive and expressive language abilities differ. In addition to spoken language, gestures, pointing, and other communication aids can be incorporated into the interaction.


TUIs can therefore support concrete and accessible learning activities, structured exploration, personal initiative, spatial and cognitive processes, as well as communication and collaboration. They are particularly relevant for learning with children because they support learning through embodied interaction and physical movement, which can contribute to children’s thinking and understanding (Pookkottuvariam, p. 2). However, these potentials can only be realised when children’s individual motor, sensory, cognitive, and communicative needs are systematically considered throughout the design process.


== Design Factors for Child appropriate TUIs (dissorder) (liang)
Whether a TUI is perceived as accessible, exploratory, and supportive of learning depends, as previously mentioned, to a considerable extent on its specific design. A literature review of TUIs for children’s creative learning highlights the factors of abstractness, openness, richness and complexity, as well as a smooth experience. Since these factors were also not specifically formulated for students with a special educational focus, they are discussed below with consideration of the heterogeneous learning abilities and conditions for action within the defined target group.

=== Abstractness
The factor of abstractness describes how concrete or ambiguous the meaning of a phicon is designed to be. While abstract and not fully predetermined representations can promote imagination and divergent thinking, an overly abstract design can lead to confusion, particularly among children without the required prior knowledge or additional explanation. The choice of physical representation and the manner in which it is coupled with digital information therefore directly influence how comprehensible the meaning of the phicon is perceived to be (bezug zu coupling objects).

For students within the selected special educational focus, a balance between abstraction and clarity is therefore required. Phicons should provide sufficient indications of their function and possible use, but at the same time, the design should not be unnecessarily simplified or infantilising, so that it still provides sufficient depth for exploration.

=== Openess
Openness defines the scope that a TUI provides for individual actions, solution strategies, and interpretations. While excessive instruction can restrict creativity, insufficient support or scaffolding often leads to frustration.

For students with a special educational focus on intellectual development, learning and Autism, structured openness is particularly relevant. Clear intermediate goals can prevent children from becoming overwhelmed. When these are supplemented by step-by-step support that is adapted to the individual learner’s current level and can be reduced as confidence increases, a comprehensible framework for action is created without providing excessive instruction.

=== Richness and complexity
While richness refers to the variety of possible content, actions, and combinations within a system, complexity describes the demands that arise from this variety. A design that is too simple does not provide sufficient inspiration, whereas overly complex interfaces can overwhelm children. The system should support children in overcoming difficulties independently without removing the challenge entirely.

Due to the different learning conditions associated with the considered support needs, the complexity of the TUI should not be reduced uniformly but should instead be individually adaptable. Different levels of difficulty can be designed to introduce new content and possibilities for action gradually. The objective should therefore not be to create the simplest possible design, but to provide an appropriate level of challenge for each child.

=== Smooth Experience 
BEZUG BELLOTTI 5 FRAGEN

Faulty hardware or software can severely impair the learning experience. Unreliable systems make children feel uncertain and discourage them from learning from mistakes or taking risks, particularly when it is not clearly recognisable whether an error was caused by the system or by their own actions. 

For students with special educational needs, this can considerably reduce both motivation and confidence in acting independently. Feedback should therefore be reliable, immediate, and clearly attributable. Multimodal feedback can provide access through different perceptual channels, but its intensity and quantity must remain limited or adaptable in order to prevent unnecessary sensory overload.

For use in schools, the requirements of teachers must also be considered, and teachers should be included as stakeholders in the TUI design process. Nevertheless, the system should be usable without programming knowledge or time-consuming calibration. Tasks must be easy to select and understand, the components must be transportable, and the system must be capable of being set up with minimal preparation time.
Einbezug sonderpädagogischer und gegebenenfalls therapeutischer Fachkräfte in Auswahl, Anpassung und Evaluation

Zusätzlich würde ich für deine Zielgruppe zwei Faktoren ergänzen:
Individualisierbarkeit: Schwierigkeit, Tempo, Hilfen und Rückmeldungen müssen anpassbar sein.
Multimodale Zugänglichkeit: Informationen dürfen nicht ausschließlich über Text, Farbe oder Ton vermittelt werden.

FAZIT
FIGURE/TABELLE die die potenziale und gestaltungsfaktoren und vlt auch kompetenzen vereint

