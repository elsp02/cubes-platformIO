#import "functions.typ": apa-table

//= TUI
== Graphical vs Tangible User Interface
A @UI can be defined as the point of contact through which people communicate and interact with a technical system. The most common type of @UI is the @GUI, in which digital information is visually represented on a screen and manipulated through input devices such as a mouse, a keyboard, or a touchscreen @TangibleUserInterfacePast.

Shaer and Hornecker contrast this mode of interaction with people’s everyday experience of the physical environment @TangibleUserInterfacePast[p. 1]:

#align(center)[
#quote(block: true)[
  “We live in a complex world, filled with myriad objects, tools, toys and people. Our lives are spent in diverse interaction with this environment. Yet, for the most part, our computing takes place sitting in front of and staring at, a single glowing screen attached to an array of buttons and a mouse”
] <Shaer>]

The quotation highlights the separation between traditional computer interaction and people’s embodied experience of the physical world: In everyday life, objects can be grasped, combined and explored through several senses, whereas conventional @GUI, by contrast, translate these actions into interactions with visual representations on a two-dimensional display. Consequently, digital interaction frequently makes only limited use of people’s natural physical capabilities, potentially resulting in a reduced level of intuitiveness @TangibleUserInterfacePast.

The concept of Ishii and Ullmer’s Tangible Bits responds to this separation by coupling digital information with everyday physical and graspable objects and the surrounding environment. Its central aim is to bridge the divide between the digital domain of bits and the physical world of atoms, thereby making digital information directly accessible through physical manipulation. Tangible Bits consequently provided an important conceptual foundation for the development of @TUI @TangibleBits1997@TangibleBits2008.

Unlike a @GUI, a @TUI integrates computing into the physical environment. Interaction does not occur exclusively through graphical elements on a screen; instead, users manipulate real-world objects, commonly referred to as phicons, to interact with the digital system. These phicons do not merely serve as input devices but also fulfil a representational function @TangibleUserInterfacePast.

The fundamental principle of a @TUI is predicated on two closely related characteristics @TokenConstraint:

-  Phicons are used as representations of digital information and computational operations
-  The physical manipulation of these phicons is used to interact with the associated computational operation

Because different types of information or functions can be represented by separate physical elements, multiple phicons may remain available for simultaneous manipulation. They may also be operated in parallel or with both hands. This principle, known as _space multiplexing_, can improve interaction efficiency and facilitate collaborative use by groups, which is typically more restricted in conventional GUI-based interaction @TokenConstraint.

=== MVC and MCRpd Model
The difference between these styles of user interfaces becomes more obvious when comparing their underlying interaction models shown in @MVC_MCRpd_Model @EmergingFrameworks.

==== MVC model for GUI
Within the @MVC architecture, an interactive software system is divided into three functional components: The _model_ represents the underlying data and the current state of the system, the _view_ presents this information graphically, while the _control_ processes user input and translates it into changes to the model. Therefore, in the interaction model of a @GUI, there is a clear separation between the control devices, such as the mouse and keyboard and the digital representation displayed on the screen @EmergingFrameworks.

==== MCRpd model for TUI
The interaction model for a @TUI retains the @MVC _model_ and _control_ components but replaces the exclusively graphical _view_ with both a @rep_p and a @rep_d. It thereby accounts for the fact that, in a @TUI, digital information is not represented solely on a screen but is also given a tangible physical form. The structure of the physical components can be characterised by three central properties:

+ The physical representation is coupled with digital information
+ The physical representation incorporates mechanisms for interactive control
+ The physical state of the object contains information about the digital state of the system

Consequently, the physical representation performs a dual function: On the one hand, it represents digital information and system states and on the other, it serves as an interactive control element. Hence, the position, orientation or arrangement of a phicon for example can encode information about the corresponding digital state. At the same time, moving, rotating or connecting the object modifies that state. Thus, _representation_ and _control_ are connected not only conceptually, but also physically @EmergingFrameworks.

#figure(
  image("figures/MVC-MCRpd-Model.svg", width: 100%),
  caption: [a) Interaction model of GUI: MVC model; b) Interaction Model of TUI: MCRpd model @EmergingFrameworks],
) <MVC_MCRpd_Model>

=== Conclusion
The distinctive characteristic of a @TUI lies in the close coupling between representation and action. Whereas a @GUI typically separates the visual representation of digital information on a screen from interaction through an input device, a @TUI uses physical artefacts both to represent digital content and to manipulate it @EmergingFrameworks. This coupling can support the constructivist and constructionist learning approaches discussed in @learning-theories by enabling learners to explore relationships through physical manipulation and to externalise their ideas in the form of tangible, directly modifiable artefacts @TangibleUserInterfacePast.



== Design Factors for TUI
The comprehensibility and usability of a @TUI depend fundamentally on how coherently its physical objects, their digital meanings and the actions available through them are coordinated.

=== Coupling Objects with Digital Information <coupling_objects>
Ullmer and Ishii provide an overview of various types of represented digital information, coupling methods and approaches to physical representation in order to describe the coupling between phicons and digital information @EmergingFrameworks.

==== Types of Represented Digital Information 
A phicon in a @TUI can represent different kinds of digital information. These include _static media_, such as images and three-dimensional models, _dynamic content_, such as video streams or computationally generated graphics and _digital attributes_, including colours or material properties. Within a TUI, a physical object does not necessarily correspond to a single digital file but can have different digital meanings. For example, a physical figure placed on an audio player may represent an entire audiobook, while another object may control playback. To the user, these objects represent a story or an action rather than the underlying files and computational processes. What matters most is therefore the meaning of an object and the actions associated with it  @EmergingFrameworks.

==== Methods of Coupling <coupling>
In addition to the different types of information represented, coupling methods serve to categorise how and when the relationship between a phicon and its digital representation is formed:

- In _static coupling_, the meaning of an object is defined in advance. The physical object is permanently associated with a specific digital geometry, property or function and this association cannot be altered during interaction.

- By contrast, a _dynamic coupling_ is established or modified during use. For instance, inserting a Phicon into a specific slot or performing an action within a graphical user interface can associate it with new digital content or alter its existing assignment.

- _Interactive coupling_ occurs when the meaning of an object changes depending on the other objects with which it is connected or combined.

_Static coupling_ therefore provides a stable and often more easily understandable meaning, whereas _dynamic_ and _interactive coupling_ enable the same physical objects to be used more flexibly. Regardless of which coupling method is used, it is essential that changes to the physical object are reflected immediately and transparently in the digital representation. If this correspondence is delayed, missing or inconsistent, the relationship between the physical and digital representations becomes difficult to understand @EmergingFrameworks.

==== Approaches to Physical Representation
Both the temporal precision of the coupling and the appearance of the physical object influence how clearly its digital meaning and possible interactions can be understood. Four approaches to physical representation are presented in @physical-representation-approaches. These approaches are not necessarily mutually exclusive and may be combined within a single system @EmergingFrameworks.

#apa-table(
  columns: (1fr, 2fr, 2fr),

  table-label: <physical-representation-approaches>,
  breakable: true,

  header: (
    [Approach],
    [Description],
    [Illustrative Example],
  ),

  caption: [Approaches to physical representation in a @TUI @EmergingFrameworks],

  [_Found objects_],
  [Existing objects augmented with technology and placed in a new digital context],
  [A sensor-equipped toy car moved across a table to control a digital vehicle],

  [_Engineering-driven_],
  [Physical form determined by electronic and mechanical requirements],
  [Appearance of a prototype determined by its electronic components],

  [_Design-driven_],
  [Physical form designed to communicate meaning and indicate possible interactions],
  [Tokens shaped like musical instruments to select the corresponding digital sounds],

  [_Work-practice-based_],
  [design based on existing physical artefacts from specific professional or application contexts],
  [Digitally tagged library cards retain the familiar process of assigning borrowed books to individual users],

)

==== Conclusion
The coupling between physical objects and digital information can differ in content, flexibility and physical representation. Selecting an appropriate approach therefore requires a careful consideration of the intended users and their abilities, as well as the specific application context. Regardless of the chosen approach, an effective TUI requires a clear and immediately perceptible relationship between the phicon and the associated digital meaning. The design of this coupling therefore directly influences the system’s comprehensibility, usability and flexibility.


=== The _Token and Constraint_ Framework <token-constraint>
Once digital information has been assigned to a phicon, it must be determined how this object can be physically arranged and how changes in its configuration can be translated into digital operations @TokenConstraint.

One approach to structuring tangible interaction is the _Token and Constraint_ framework. The discrete physical objects that represent digital information are referred to as _tokens_ within this framework. They correspond to the physical representations previously introduced as _phicons_. However, the term _token_ is retained in this section to remain consistent with the framework’s original terminology. _Tokens_ are placed or manipulated within physical structures known as constraints. These constraints define where and how a token can be positioned or moved and are mapped to specific digital operations @TokenConstraint.

==== Phases of Interaction
The interaction within _Token and Constraint_ systems can involve two phases: _Associate_ and _Manipulate_. During the _Associate_ phase, a _token_ is placed within a constraint, thereby establishing a logical relationship between the information represented by the _token_ and the operation assigned to the constraint. This initially creates a discrete state, such as presence or absence, activation or deactivation, or selection and deselection. The same _token_ may be inserted into different constraints in order to associate its digital information with different predefined operations @TokenConstraint.

The _Manipulate_ phase starts once the _token_ has been physically engaged with the _constraint_. The _token_ can now be moved within the _constraint_'s mechanical boundaries to modify parameters of the associated operation. The absolute and relative positions of _tokens_, both in relation to the _constraint_ and to one another, can result in different digital interpretations. The meaning of an interaction therefore emerges from the interplay between the _token_, the _constraint_ and the overall physical configuration. Translating or rotating the _token_ may result, for example, in the continuous adjustment of a value, the navigation through a list, or the alteration of another variable of the digital system. However, not every _Token and Constraint_ system needs to support both phases of interaction, since in some systems, inserting and removing a _token_ may already constitute the complete interaction @TokenConstraint.

==== Physical Syntax and Interaction Guidance
Physical constraints influence not only the digital interpretation of an action but also its haptic and perceptual qualities, since the physical syntax renders some of the available interaction possibilities directly perceivable. In this context, syntax refers to the rules according to which individual phicons can be combined to form an input that can be meaningfully interpreted by the system. The geometry and mechanical configuration of the constraints function as a physical grammar by directly indicating which actions are possible and which are prevented. This supports the creation of physical configurations that are interpretable both by the user and by the underlying computational system. By reducing the range of possible manipulations, invalid states can be avoided and the available courses of action can be made easier to understand @TokenConstraint.

#figure(
  image("figures/token-constraint.svg", width: 100%),
  caption: [Interaction phases and physical syntax within the Token and Constraint framework],
) <token-constraint-syntax>

==== Styles of Mapping <mapping>
Mapping styles describe how the resulting physical configuration is translated into a computer-interpretable representation. Three principal styles can be distinguished: _spatial_, _relational_ and _constructive_ mapping.

In the _spatial mapping_, interpretation is based on the geometric position, distance, or orientation of phicons in the physical space. The pivotal factor, therefore, is the object's position within a spatial frame of reference.

In the context of _relational mapping_, the absolute position of a phicon is less significant than its relationship to other phicons or to a particular _constraint_. The digital interpretation may therefore depend on properties such as sequence, proximity, adjacency, or assignment.

In _constructive mapping_, the digital meaning of a given structure is derived from the manner in which several physical components are assembled into a larger structure. The interpretation is therefore not based on a single element, but rather on the resulting overall physical structure.

These mapping styles are not mutually exclusive and may be combined within a single @TUI. An assembled structure may for example be interpreted based on both the connections between its components and their spatial positions or orientations @TokenConstraint.

==== Conclusion
The _Token and Constraint_ framework demonstrates how physical actions can be translated into comprehensible digital operations. _Tokens_ enable direct manipulation, while constraints guide interaction and prevent invalid configurations. These characteristics can support constructivist and constructionist learning by enabling structured exploration and making the consequences of physical actions observable. However, their educational value ultimately depends on the design of the learning task.


== Feedback for TUI <feedback>
In a @TUI, feedback informs users whether an action has been detected, how it has been interpreted and how it has affected the state of the system. It thereby closes the perception-action loop between physical manipulation and digital processing and supports the independent use of the system. @bellotti2002making @wensveen2004interaction

=== Feedback Modalities <feedback-modalities>

As shown in @feedback-modalities-table, a system can communicate the consequences of an action through different output modalities. The physical properties of a @TUI already provide intrinsic feedback that arises directly from manipulating its objects. Additional system-generated feedback may be presented visually, auditorily, haptically, or through a coordinated combination of these modalities. @wensveen2004interaction

This multimodal feedback does not imply presenting as many signals as possible simultaneously, since excessive or unnecessarily complex information may increase processing demands and impede the interpretation of the feedback. @shute2008focus Instead, different modalities should offer alternative ways of accessing the same or complementary information, which can then be combined when a perceptual channel cannot be used, or can only be used to a limited extent. @iso9241-110-2020 @w3c2024wcag

Regardless of its modality, feedback can also be characterised along several dimensions concerning its location, temporal relationship to the action, dynamics and duration. @wensveen2004interaction

- Local or global: presented directly at the manipulated object or through a separate display
- Discrete or continuous: confirming an individual event or continuously indicating a state
- Immediate or delayed: responding directly to an action or providing a later summary
- Persistent or transient: remaining available until a correction is made or disappearing after a short period

#apa-table(
  columns: (1.2fr, 2fr, 2.2fr),

  table-label: <feedback-modalities-table>,

  header: (
    [Feedback Form],
    [Function],
    [Examples],
  ),

  caption: [Feedback modalities in tangible user interfaces],

  [_Intrinsic_],
  [Provides information arising directly from the physical action],
  [Mechanical resistance, form fit, or snapping into place],

  [_Visual_],
  [Communicates states, errors and changes visually],
  [LEDs, displays, projections, or animations],
  
  [_Auditory_],
  [Attracts attention and communicates information auditorily],
  [Sounds, signals, or spoken information],

  [_Haptic_],
  [Makes system responses physically perceptible],
  [Vibration, movement, or force feedback],

  [_Multimodal_],
  [Provides complementary or alternative access through different perceptual channels],
  [Coordinated combinations of visual, auditory, or haptic signals],
)

The distinction presented in @feedback-modalities-table is based on the differentiation between inherent and additionally generated information proposed by Wensveen et al @wensveen2004interaction.

=== Feedback in Learning-Oriented TUIs <feedback-tui>
In learning-oriented @TUI, two levels of feedback should be distinguished:

- _Interaction feedback_ communicates whether and how a physical action has been technically detected and processed @bellotti2002making,
- _Pedagogical feedback_ evaluates the action or its outcome in relation to the learning task @hattie2007power @shute2008focus.

A system may therefore detect an action correctly while evaluating it as incorrect in relation to the task. Conversely, a failure to detect an action must not be presented as an error made by the learner. Reliable interaction feedback is therefore a prerequisite for meaningful pedagogical feedback @bellotti2002making @iso9241-110-2020.

==== Interaction Feedback

_Interaction feedback_ makes the technical response of the system comprehensible. It should indicate whether a physical action has been detected and interpreted correctly. If an action cannot be processed, the system should distinguish a technical recognition problem from an incorrect solution to the learning task. Otherwise, learners may incorrectly attribute system failures to their own actions and become uncertain about how to proceed @bellotti2002making @iso9241-110-2020.

==== Pedagogical Feedback

While _interaction feedback_ primarily confirms whether an action has been technically processed, _pedagogical feedback_ concerns the meaning of that action within the learning process. It supports learners in assessing their current progress, recognising deviations from the intended outcome and adapting their subsequent actions @butler1995feedback @hattie2007power.

_Pedagogical feedback_ can fulfil different functions:

- Outcome feedback indicates whether a result is correct or incorrect.
- Process feedback provides information about the approach taken or a possible cause of error
- Feedforward offers guidance for the next step
- Progress feedback indicates what has already been achieved in relation to the intended goal

Additionally, as it would restrict independent planning and problem-solving, the system should not prescribe every step, but provide graduated feedback in which support increases according to the learner’s needs. This preserves opportunities for independent error analysis while preventing learners from becoming unable to continue because the feedback is insufficient or incomprehensible @shute2008focus @hattie2007power.

=== Conclusion
Effective feedback in a learning-oriented @TUI must make both the technical processing and the pedagogical meaning of an action comprehensible. By combining accessible feedback modalities with graduated support, the system can help learners recognise deviations and adapt their actions to work independently without prescribing the complete solution.


== Child-Appropriate TUIs in the Field of Special Education <tui-children>
Whether a @TUI is perceived as accessible, exploratory and supportive of learning depends
not only on its general design and feedback, but also on its adaptation to the specific needs of children. A literature review of TUIs for children’s creative learning highlights the factors of abstractness, openness, richness and complexity, as well as a smooth experience. Since these factors were also not specifically formulated for students with a special educational focus, they are discussed below with consideration of the heterogeneous learning abilities and conditions for action within the defined target group @TangibleInteraction.

==== Abstractness
The factor of _Abstractness_ describes how concrete or ambiguous the meaning of a phicon is designed to be. While abstract and not fully predetermined representations can promote imagination and divergent thinking, an overly abstract design can lead to confusion, particularly among children without the required prior knowledge or additional explanation. The choice of physical representation and the manner in which it is coupled with digital information, explained in @coupling_objects, therefore directly influence how comprehensible the meaning of the phicon is perceived to be  @TangibleInteraction.

For students within the selected special educational focus, a balance between abstraction and clarity is therefore required. Phicons should provide sufficient indications of their function and possible use, but at the same time, the design should not be unnecessarily simplified or infantilising, so that it still provides sufficient depth for exploration @Geistige_entwicklung @lernen @autismus.

==== Openness
_Openness_ defines the scope that a TUI provides for individual actions, solution strategies and interpretations and is indirectly influenced by the number and restrictiveness of its physical _constraints_ (@token-constraint).
While excessive instruction can restrict creativity, insufficient support or scaffolding often leads to frustration @TangibleInteraction.

For students with a special educational focus on @GE, @LE and @ASD _structured Openness_ is particularly relevant. Clear intermediate goals can prevent children from becoming overwhelmed. When these are supplemented by step-by-step support that is adapted to the individual learner’s current level and can be reduced as confidence increases, a comprehensible framework for action is created without providing excessive instruction @Geistige_entwicklung @lernen @autismus.

==== Richness and Complexity
While _Richness_ refers to the variety of possible content, actions and combinations within a system, _Complexity_ describes the demands that arise from this variety. A design that is too simple does not provide sufficient inspiration, whereas overly complex interfaces can overwhelm children. The system should support children in overcoming difficulties independently without removing the challenge entirely @TangibleInteraction.

Due to the different learning conditions associated with the considered support needs, the complexity of the @TUI should not be reduced uniformly but should instead be individually adaptable. Different levels of difficulty can be designed to introduce new content and possibilities for action gradually. The objective should therefore not be to create the simplest possible design, but to provide an appropriate level of challenge for each child @Geistige_entwicklung @lernen @autismus.

==== Smooth Experience
Faulty hardware or software can severely impair the learning experience. Unreliable systems make children feel uncertain and discourage them from learning from mistakes or taking risks, particularly when it is not clearly recognisable whether an error was caused by the system or by their own actions @TangibleInteraction.

For students with special educational needs, this can considerably reduce both motivation and confidence in acting independently. The feedback described in @feedback should therefore be reliable, immediate and clearly attributable. Multimodal feedback can provide access through different perceptual channels, but its intensity and quantity must remain limited or adaptable in order to prevent unnecessary sensory overload @Geistige_entwicklung @lernen @autismus.

The factors discussed above originate from the literature review on @TUI for children’s creative learning. Based on the learning needs of students within the considered areas of special educational support, two additional factors are proposed: _Adaptability_ and _Multimodal Accessibility_.

==== Adaptability
 _Adaptability_ describes the extent to which a TUI can be adjusted to learners’ individual abilities and needs. Task difficulty, pace and level of support should be configurable without changing the fundamental interaction concept. Such adaptations can provide sufficient guidance while allowing learners to work as independently as possible @Geistige_entwicklung @lernen @autismus.

==== Multimodal Accessibility
_Multimodal Accessibility_ requires relevant information and feedback to be available through more than one perceptual channel. Information should therefore not be communicated exclusively through text, colour, or sound, as each of these may create barriers for individual learners. Combining these modes, however, can provide alternative means of access. The number and intensity of stimuli should remain adaptable to avoid sensory overload @InklusiveBildungKinder.

==== Teachers
For use in schools, the requirements of teachers must also be considered and teachers should be included as stakeholders in the TUI design process. Nevertheless, the system should be usable without programming knowledge or time-consuming calibration. Tasks must be easy to select and understand, the components must be transportable and the system must be capable of being set up with minimal preparation time @TangibleInteraction.

==== Conclusion
The design factors show that there is no universally child-appropriate TUI. Its suitability depends on how well the interaction design responds to individual abilities, support needs and sensory preferences. The central design challenge is therefore to provide sufficient structure and accessibility without unnecessarily restricting independent exploration.

