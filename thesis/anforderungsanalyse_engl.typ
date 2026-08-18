#import "functions.typ": apa-table, req, req-target

= Requirements Analysis <requirements-analysis>
The requirements analysis translates the findings from the theoretical background and the design principles derived from the special educational context into concrete requirements for the prototype. Following a constructionist approach, the objective is to develop a modular, cube-based @TUI in the form of a learning game suitable for use in special education. The prototype is intended to enable students to complete three-dimensional construction tasks independently while receiving immediate feedback on whether their construction corresponds to the target structure or not.

The requirements are derived from three perspectives:
- The learning prerequisites of the target group and the resulting educational implications
- The characteristics and design principles of tangible user interfaces discussed in the theoretical background
- The technical, financial and time constraints of prototype development

The following sections describe the context of use, the application scenario and the core requirements guiding the system’s design and development.

== Context of Use and Didactic Application Scenario
The primary target group consists of students with special educational needs related to @GE, @LE and @ASD. Teachers and other educational professionals represent a further key stakeholder group, as they integrate the learning game into classroom activities and support the learning process.

By enabling students to complete three-dimensional construction tasks independently, the learning game is intended to address the following competencies:
- Primary: spatial thinking, action planning and self-directed learning
- Secondary: problem-solving, error detection and self-correction
- Additional: fine motor skills, concentration and hand–eye coordination

The primary application scenario is a spatial reconstruction task, where students select a three-dimensional target structure appropriate to their individual level and attempt to recreate it using the available bricks. Although this type of task can also be carried out using conventional construction materials, the proposed system extends the building process through automated feedback and can indicate whether the construction is correct or needs to be modified. 

The level of difficulty can be varied through the number of bricks, their spatial arrangement and the required rotations. Simple tasks may consist of a small number of bricks connected primarily in a linear arrangement, whereas more challenging tasks may involve multiple spatial directions, different orientations and branching structures. Future task types could include completing unfinished structures, identifying incorrect connections, or constructing freely without a predefined target.

== Pedagogical and Interaction-related Requirements
In accordance with the constructionist understanding of learning described in Chapter @constructionism as well as the _Embodied Cognition_ theory of @embodied-cognition the active creation of a physical artefact must form the core of the learning activity #req("TASK1"). Learners must be able to observe, inspect and directly modify the emerging construction throughout the task #req("IA1"). This enables them to translate their mental representation into a concrete spatial structure through which the effects of individual actions become observable. To support independent use, the system must also be operable without technical or programming knowledge and without requiring recalibration #req("IA2").

At the same time, the tasks must accommodate the diverse learning prerequisites of the target group explained in @implications-learning and thus provide a clear and manageable framework for action #req("IA3"), without describing every individual action. Processes and sub-goals must be presented in a way that is easy to follow, whilst allowing sufficient time for completion #req("IA4") and opportunities for repetition #req("IA5").

The design factors described in @tui-children must also be considered. The principle of _structured openness_ requires tasks to provide a clear framework while allowing learners to explore different approaches and solution attempts #req("TUI1"). Tasks must be structured in such a way that the objective remains clear and step-by-step guidance can be accessed where necessary. The factors of _richness_, _complexity_ and _adaptability_ further require the learning game to accommodate different levels of ability. This can be achieved by adapting the level of difficulty and scope of the feedback to different learning requirements as far as possible, so that the same basic principle of interaction can be applied to tasks of varying difficulty levels #req("TUI2"). Finally, the bricks must provide sufficiently clear physical cues for learners to understand their meaning and possible uses. Their physical design and digital functions must therefore be consistently aligned #req("TUI3").

#apa-table(
  columns: (0.7fr, 5fr),

  table-label: <requirement-educational>,

  header: (
    [ID],
    [Requirement],
  ),

  caption: [Educational and interaction related requirements],

  req-target("TASK1"),
  [The task must be completed through the active construction and modification of a physical artefact],

  req-target("IA1"),
  [The resulting construction must remain visible, inspectable and modifiable throughout the task],

  req-target("IA2"),
  [The system must be usable without technical or programming knowledge and without requiring recalibration],

  req-target("IA3"),
  [The objective and structure of the task must be presented clearly and comprehensibly],

  req-target("IA4"),
  [Learners must be able to complete the task at their own pace],

  req-target("IA5"),
  [Previously completed action steps must be correctable and repeatable],

  req-target("TUI1"),
  [The task should provide a structured framework while allowing different approaches and solution attempts within that framework],

  req-target("TUI2"),
  [The level of difficulty should be adaptable by varying the number of bricks, their spatial arrangement and the required rotations],

  req-target("TUI3"),
  [The physical design of the bricks and their digital functions must be consistently aligned],
)


== Requirements for Feedback and Assistance
To complete a construction task independently, learners must be able to determine whether their actions have been detected by the system and how those actions are evaluated within the learning task. In accordance with the distinction introduced in @feedback-tui, the system must therefore provide both interaction feedback and pedagogical feedback #req("FB1"). Each feedback signal must be clearly attributable to the action that triggered it or to the affected part of the construction, allowing learners to understand what it refers to #req("FB2"). In this context, feedback and assistance should be available in graduated levels according to the learner’s individual support needs #req("FB3"), #req("FB4").
As discussed in relation to multimodal accessibility in @tui-children, providing feedback through multiple output modalities can improve accessibility which is therefore diserable #req("IA6"). But, when multiple modalities are used, their signals must be coordinated and consistent in order to avoid distraction.

#apa-table(
  columns: (0.7fr, 5fr),

  table-label: <requirement-feedback>,

  header: (
    [ID],
    [Requirement],
  ),

  caption: [Requirements for feedback and assistance],

  req-target("FB1"),  [Interaction and educational feedback must be ensured],

  req-target("FB2"),  [Feedback must be clearly linked to the action that triggered it or the area concerned],

  req-target("FB3"),  [Feedback should be provided on a tiered basis, je nachdem ob der fehler schon mit weniger feedback ausgebessert werden kann],

  req-target("FB4"),  [Assistance should be provided on a tiered basis, depending on the learners level],

  req-target("IA6"), [Feedback should be provided through multiple output modalities],
)

== Geometrical and Ergonomic Requirements
The building blocks form the central element of the learning game: They serve as physical representations of digital information while simultaneously functioning as controls for interacting with the system (phicons). Their geometric and mechanical design therefore influences both the range of possible constructions and the comprehensibility and accessibility of the interaction. As already established by the educational requirements, the shape and connection mechanisms must clearly indicate how and where the blocks can be connected #req("TUI3").
To enable three-dimensional constructions, all faces of a block must provide connection capabilities #req("C3"). These connections must also allow two connected cubes to be positioned in different orientations relative to one another #req("C4"). Building on this structural flexibility, further variety could be introduced through additional block types with different geometric shapes #req("G3").
In order to hold the structure together, the connection between the building blocks must be stable enough to be undone with minimal effort, while also being strong enough to be created without requiring precise positioning that demands fine motor skills #req("C6"). In addition, each block must be capable of being securely grasped, positioned and connected using one hand #req("C5").
#apa-table(
  columns: (0.7fr, 5fr),

  table-label: <requirement-design>,

  header: (
    [ID],
    [Requirement],
  ),

  caption: [Physical design requirements],
    req-target("G3"), [Different cube types could be implemented in different geometric shapes],

    req-target("C3"),  [The cubes must be able to be arranged or stacked in three dimensions],

    req-target("C4"),  [The cubes must be able to be positioned relative to one another in different orientations],

    req-target("C5"),  [The cubes must be graspable and connected with one hand],

    req-target("C6"),  [Cube connections must be strong enough to hold the structure together and easy enough to disconnect with minimal effort],

  )

   
== Functional Requirements for Detection
The functional requirements define which information the system must detect and process in order to reconstruct the physical three-dimensional structure digitally: Each building block must be uniquely identifiable to enable reliable construction detection and targeted feedback #req("DET1"). In addition, the system must also determine which blocks are connected, through which faces they are connected #req("DET2") and how they are oriented relative to one another #req("DET3"). Only by combining these relationships the system can reconstruct the complete spatial configuration. 
To provide feedback on the constructed configuration, the system must compare the detected construction with the target structure #req("DET4").
The detection functionality should remain reliable when multiple blocks are connected simultaneously within a larger construction #req("DET5"). To prevent the system from providing misleading information to users, ambiguous or contradictory configurations should be recognised as error states #req("DET6").

#apa-table(
  columns: (0.7fr, 5fr),

  table-label: <requirement-detection>,

  header: (
    [ID],
    [Requirement],
  ),

  caption: [Requirements for the construction detection],

    req-target("DET1"),  [The system must be able to uniquely detect each cube],

    req-target("DET2"),  [The system must be able to detect which cubes are connected with each other and on what side the connection occurs],

    req-target("DET3"),  [The system must be able to detect the relative rotation of a two cubes in relation each other],

    req-target("DET4"),  [The system must be able to compare the detected cube structure with a target structure],

    req-target("DET5"),  [The system should continue to operate reliably even when multiple cubes are connected simultaneously],

    req-target("DET6"),  [Configurations that cannot be clearly identified or are contradictory should be reported as technical faults],

    req-target("DET7"),  [Connections and changes to the structure must be detected reliably and within a short time of max. 400ms],
  )

The maximum response time of 400 ms @Time,
 which has been specified for detecting changes to the design, is initially a target value #req("DET7"). It is intended to ensure that an action and the resulting feedback are perceived as belonging together.


== Electrical and Technical Requirements
The technical implementation should be as simple, modular and low-maintenance as possible, with individual components remaining replaceable at reasonable effort. To reduce maintenance requirements and avoid the need to charge multiple devices separately and thereby make the system suitable for use in schools, the building blocks must operate without individual batteries or rechargeable power sources #req("EL1").
 For the initial proof of concept, the prototype should include at least ten building blocks, as this number is sufficient to demonstrate multi-part and spatially branching constructions #req("EL2"). In the future, the system should be expandable with additional blocks without requiring changes to its fundamental operating principle #req("EL3").

#apa-table(
  columns: (0.7fr, 5fr),

  table-label: <requirement-technical>,

  header: (
    [ID],
    [Requirement],
  ),

  caption: [Electrical and technical requirements],

    req-target("EL1"),  [The cubes must be operated without their own battery or individual rechargeable battery],

    req-target("EL2"),  [The system must consist of at least 10 cubes],

    req-target("EL3"),  [The system should be extendable without changing any basic operating principles],

  )

== Safety and Economic Requirements
The prototype is not a certified toy and may therefore only be used under supervision. Nevertheless, potential risks must already be reduced through the physical design and electronic components. This includes protection against overvoltage and short circuits #req("S4"), while potentially detachable small parts must be enclosed and protected against direct access #req("S2"). The building blocks must also withstand repeated grasping, connecting and disconnecting #req("S1"). In addition, each block should be easy to assemble and disassemble without damaging its components #req("S3").
The cost per building block should preferably remain between one and three euros. However, the total system cost cannot yet be determined precisely, as it also depends on the base station, control electronics and potential output devices #req("EC1").

#apa-table(
  columns: (0.7fr, 5fr),

  table-label: <requirement-economic>,

  header: (
    [ID],
    [Requirement],
  ),

  caption: [Safety and economic requirements],

    req-target("S1"),  [The cubes must be able to withstand repeated gripping, connecting and disconnecting],

    req-target("S2"),  [Electronic components and small parts that could come loose must be protected from direct access by the cube housing],

    req-target("S3"),  [The cubes should be assembled and disassembled easily without being distroyed],

    req-target("S4"), [The design of the cubes must include protection against overvoltage and short circuits],
  
    req-target("EC1"),  [The total cost of a brick should not exceed 3 euros],
    
  )

