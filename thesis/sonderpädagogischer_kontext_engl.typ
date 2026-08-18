#import "functions.typ": apa-table

= Special Education Context
Students with special educational needs in the areas of @GE (_German: Förderschwerpunkt Geistige Entwicklung, GE_), @LE (_German: Förderschwerpunkt Lernen, LE_) and @ASD may face a common range of challenges in the learning process. These may include difficulties with fundamental prerequisites for learning, such as perseverance, memory and motivation, as well as with learning how to learn. Learners may experience difficulties reflecting on their own learning, evaluating their learning processes and transferring acquired knowledge and skills to everyday situations. Challenges related to independent thinking, action planning and problem-solving may also be relevant, as these abilities enable learners to structure sequences of actions and cope with emerging problems independently @Geistige_entwicklung @lernen @autismus.

Against the background of these challenges, the following areas of development and competence are particularly relevant @Geistige_entwicklung @lernen @autismus @InklusiveBildungKinder:
-  Action planning
-  Problem-solving
-  Recognition of relationships
-  Attention and memory
-  Motor skills and perception
-  Independence and self-regulation

Special educational provision therefore aims to support students in developing these competencies, enabling them to act with increasing independence and self-determination in both educational and everyday contexts and to participate more fully in society. These competencies extend beyond the possession of knowledge and include the ability to make decisions, plan and carry out actions, evaluate their outcomes and seek appropriate support when required @Geistige_entwicklung @InklusiveBildungKinder @Sprache.

== Implications for Learning and Teaching <implications-learning>
As shown in @development_areas, the different difficulties and needs, and consequently the heterogeneity of learner groups resulting from the three areas considered, @GE, @LE and @ASD, make it difficult to select educational opportunities that are equally suitable for all learners @Sprache.

#apa-table(
  columns: (1fr, 2fr, 2fr),

  table-label: <development_areas>,

  header: (
    [Area],
    [Description],
    [Support Approach],
  ),

  caption: [Relevant developmental areas in special education and corresponding support approaches @Geistige_entwicklung @lernen @autismus],

    [@GE],
    [Varying levels of cognitive development, motor skills and perception],
    [Concrete, action-oriented approaches, individual support and sufficient processing time],

    [@LE],
    [Difficulties with academic learning such as learning strategies and the transfer of acquired knowledge],
    [Clear subtasks, repetition and comprehensible feedback],

    [@ASD],
    [Individually varying characteristics in perception, communication and interaction],
    [Clear structures, visualised processes and individually adapted levels of sensory stimulation],
)


In the area of learning, for example, the acquisition of basic academic skills and their transfer to other situations represents a central educational objective @lernen, whereas students in the area of intellectual development may require a more development-oriented form of support that addresses fundamental cognitive competencies such as cognition, perception and motor skills @Geistige_entwicklung. At the same time, students within each of the three areas do not form a homogeneous group and therefore require individually adapted support. This is particularly evident in autism spectrum disorder, as each child presents a unique combination of characteristics. The disorder may occur in conjunction with severe cognitive impairments, but also with high cognitive abilities @autismus.
This heterogeneity therefore requires an inclusive educational approach that builds on the individual prerequisites of each child and provides appropriately adapted learning opportunities and support measures.

Despite these differences, several common principles for the design of suitable learning opportunities can be derived across the three areas @Geistige_entwicklung @lernen @autismus:
- Individual adaptation rather than standardised requirements
- Clear and manageable task structures
- Visualisation of processes and sequences of actions
- Sufficient processing time and opportunities for repetition
- Playful and action-oriented tasks
- Timely and comprehensible feedback
- Promotion of independence and self-efficacy

One way of addressing different learning prerequisites is to make learning content accessible through different perceptual and action-based approaches. In this context, the interaction between motor and perceptual experience plays a particularly important role, since learners can develop sensorimotor integration processes and support learning at an elementary level through active engagement and the conscious perception of their own movements and environment @Geistige_entwicklung.

A suitable framework for such action-oriented experiences is provided by playful and constructive forms of learning, as they offer opportunities to develop and strengthen sensory, motor and cognitive abilities within concrete contexts of action. At the same time, they enable exploratory experimentation in which errors are accepted as part of the learning process @TangibleUserInterface.

In addition to designing appropriate learning approaches, the promotion of self-directed learning represents another important educational objective intended to strengthen students’ independence @BecomingSelfRegulatedLearner. However, the ability to complete a task independently requires learners to recognise the effects of their actions and adapt their subsequent approach accordingly. Timely and comprehensible feedback is therefore essential, because otherwise there is a risk that incorrect procedures are continued unnoticed or uncertainty arises regarding how to proceed with the task. In heterogeneous or inclusive classrooms, however, a teacher cannot continuously observe every action of every student and provide immediate feedback. Particularly during phases of independent practice, a delay may therefore occur between an action and the corresponding feedback. For learners who depend on clear confirmation or correction in order to continue a task, this can make independent task completion more difficult @FeedbackSelfRegulatedLearning.

== Existing Learning Materials 
Construction materials such as building blocks are generally well suited to action-oriented and self-directed forms of learning because they combine concrete actions with the exploration of spatial and logical relationships. Through active construction, experimentation and problem-solving, children can engage with learning content in a playful manner. At the same time, the result remains visible as a physical artefact and can be directly examined and modified. However, construction materials are generally unable to independently detect or evaluate the resulting construction. The feedback required for self-directed learning must therefore be provided either by the learners themselves or by a teacher @zuckermanExtendingTangibleInterfaces2005.

At the same time, digital technologies such as tablets make it possible to present learning content through multimedia, adapt tasks to individual needs and provide automated feedback. However, spatial content is often represented only on a two-dimensional screen, while interaction is largely limited to mouse or touch input. Although these forms of input also enable active interaction, they do not provide the same haptic and spatially differentiated experience as the manipulation of three-dimensional objects. This reduces the physical and motor interaction with learning objects, which is highly relevant for successful learning, to a minimum @TangibleUserInterfacePast.

== Objectives and Scope
In this context, the objective of this thesis is to develop a modular, brick-based learning game that combines the haptic and spatial properties of conventional construction materials with the possibilities of digital detection, visualisation and feedback. Within a guided construction task, children can use the bricks to build a three-dimensional structure and receive immediate feedback on whether their construction corresponds to the target structure or contains errors. Feedback is provided both directly through the bricks and through an additional visualisation on a display. Power is supplied centrally by the baseplate and distributed through all connected bricks.

The physical manipulation of the bricks combines visual, haptic and motor experiences, while the digital representation provides additional information about the detected state of the construction. Through immediate feedback, the learning game is intended to enable learners to independently monitor and correct individual action steps. In this way, it aims to support self-directed learning, action planning, spatial and relational thinking and problem-solving.

The thesis is limited to the development and validation of a functional prototype. The size and complexity of supported structures are constrained by the available bricks and the system architecture. Product maturity, large-scale manufacturing and a dedicated tablet application for mobile devices are outside the scope of this work and remain subjects for future development.

#figure(
  image("figures/bricks.png", width: 30%),
  caption: [Final prototype of the brick-based learning game]
)<probrick>
=== Structure
To that end, the theoretical foundations of learning and tangible user interfaces are first examined, followed by a review of existing brick-based @TUI systems. Based on the resulting pedagogical and technical insights, the requirements for the learning system are derived and translated into a coherent system concept. The subsequent technical realisation describes the mechanical and electronic implementation of the bricks and baseplate as well as the embedded firmware and software of the learning application. Finally, the developed prototype is evaluated with regard to the previously defined requirements and the results, limitations and opportunities for future development are discussed.




