#import "functions.typ": req, apa-table

// G2 is no longer used

= Evaluation
The aim of the evaluation is to determine to what extent the developed prototype fulfils the requirements established in @requirements-analysis.
Since the requirements concern different aspects, different evaluation methods were applied. These comprise a formative target-group evaluation and an analytical technical evaluation.
@evaluation-methods provides an overview of the applied evaluation methods and the requirements addressed by each method. 
Some requirements are associated with more than one method because individual aspects could be examined separately even when the complete integrated function could not be verified.
At the time of the evaluation, the electronic construction-detection system was not sufficiently reliable. The complete detection and feedback process could therefore not be evaluated as an integrated system.
The evaluation did not investigate long-term use or learning outcomes.

#apa-table(
  columns: (1.5fr, 3.5fr, 2fr),

  table-label: <evaluation-methods>,

  header: (
    [Evaluation method],
    [Assessment procedure],
    [Requirements addressed],
  ),

  caption: [Overview of the applied evaluation methods and corresponding requirements],

[Target-group evaluation],
[Observation of brick handling, usability, visual comprehension and assistance needs],
[TASK1; IA1–IA5; TUI1–TUI3; C1–C4],

[Physical inspection and demonstration],
[Inspection, dimensional checks, component count and manual demonstration of connections and assembly],
[G1; C1–C4; EL1–EL2; S1–S3],

[Implementation analysis],
[Traceability analysis of contact design, communication protocol, firmware and application components],
[DET1–DET7; FB1–FB4; IA6; EL3; S4],

[Cost analysis],
[Bill-of-materials calculation],
[EC1],

[Integrated-system test],
[Not conducted due to insufficient electronic reliability],
[DET1–DET7; FB1–FB2; IA6],
)
==== Assessment Criteria
Based on the available evidence, each requirement is classified as fulfilled, partially fulfilled, implemented but not verified, not fulfilled or not evaluated. A requirement is classified as fulfilled only if its relevant functionality or property could be demonstrated through the applied evaluation method. Requirements that were represented in the design or implementation but could not be tested in operation were classified as implemented but not verified.


== Target-Group Evaluation Methodology
The target-group component was conducted as a formative qualitative evaluation to investigate the accessibility of the physical building bricks and the usability of the learning application for the intended target group. At the time of the target-group evaluation, the electronic construction-detection system was not yet sufficiently reliable for use during the construction tasks. The evaluation therefore focused on physical interaction with the building bricks and the use of the learning application, including the selection and visualisation of target structures and the learners’ ability to relate the digital representations to the physical bricks.

==== Participants and Setting
The evaluation was conducted with 10 students attending the sixth year of a special education school. The group was a mix of students with different educational support needs related to @GE, @LE and @ASD. The evaluation took place in the students’ regular school environment and lasted approximately two hours. 
The tasks were initially completed individually, but during the later part of the session, several students also worked together in pairs. The construction activities were supervised by the researcher and the attending teachers, who provided assistance when necessary.

==== Materials and Tasks
For the construction tasks, eight physical prototype bricks were available, comprising four bricks of each of the two implemented brick types. The electronic components were not used during the session.
The learning application was presented on a touchscreen tablet and displayed a selection of target structures with varying levels of difficulty and complexity from which the students could choose.
After confirming their selection, the chosen target structure was displayed as an interactive three-dimensional model in full-screen mode.


#figure(
  image("figures/level@3x.png", width: 90%),
  caption: [Examples of target structures used in the target-group evaluation: (a) low, (b) medium and (c) high structural complexity]
)<evaluation-target-structures>

==== Procedure
At the beginning of the evaluation, the students were introduced to the general purpose of the system and the reconstruction task. Each student was subsequently invited to select a target structure in the learning application and reproduce it using the physical bricks. Depending on their interest, the students could complete more than one task or work collaboratively in pairs, as shown in @learners.
During construction, the students could interact with the three-dimensional visualisation of the target structure and rotate it to inspect the construction from different viewing angles.
The students were encouraged to complete the tasks independently and without assistance from the supervising adults, but support was provided gradually if required. Initially, verbal hints were given. If these were insufficient, the target visualisation was rotated to provide a more suitable viewing angle and the relevant brick was indicated on the screen. If further assistance was required, the appropriate physical brick was provided to the student. Only when these forms of support proved insufficient did a supervising adult demonstrate or perform the required connection.

#figure(
  image("figures/learners@3x.png", width: 60%),
  caption: [Learners during the construction process]
)<learners>

==== Data Collection
Data were collected through qualitative observation of the students’ interaction with the physical bricks and the learning application. The evaluation did not aim to measure learning outcomes. Instead, it examined the comprehensibility and usability of the interaction concept during the session.

Regarding the physical bricks, the observation focused on:
- whether the students recognised the objects as building bricks intended to be connected
- whether they understood which faces could be connected and how the two brick types differed
- whether they could grasp, position, connect and disconnect the bricks
- whether the magnetic connections provided sufficient stability while remaining easy to separate
- whether the students could use the bricks to construct three-dimensional arrangements

Regarding the learning application, the observation focused on:
- whether the students understood the construction task presented by the application
- whether they could relate the digital representations to the corresponding physical bricks
- whether they could select and confirm a target structure
- whether buttons and other interactive elements were recognised and operated correctly
- whether they could manipulate the three-dimensional model
- what type and level of assistance they required during these interactions

The observations were recorded in notes during and immediately after the session.


== Results
The following sections focus on the findings that are most relevant to the central interaction concept and to the technical feasibility of the prototype. Requirements that produced similar or directly observable results are not discussed individually in the text in order to avoid repetition. A compact summary is provided at the end of the results, while the complete requirement-by-requirement assessment is included in Appendix @appendix-requirements.

=== Target-Group Evaluation
==== Physical Interaction with the Building Bricks

The students immediately recognised the objects as building bricks and were able to grasp, position and connect themwith one hand. The form-fit elements guided the connection, while the magnets assisted alignment and reduced the required precision. The construction activity therefore fulfilled the central physical interaction described by #req("TASK1"), #req("IA1") and #req("C3"). 

After a brief explanation, the students generally understood which faces could be connected. Nevertheless, docking-face-to-docking-face combinations were attempted because the central magnets still produced a slight attraction even though the form-fit elements prevented complete engagement. The overall purpose of both brick types and their correspondence with the digital models were understood, but the connection rules were not entirely self-explanatory. The physical aspect of #req("TUI3") was therefore only partially fulfilled.

The bricks enabled three-dimensional arrangements and different relative orientations, providing evidence for #req("C1") and #req("C2"). Their stability was sufficient for smaller constructions, but horizontal sequences of more than three bricks separated under their own load. Requirement #req("C4") was consequently only partially fulfilled: the connections required little force to create and release but did not support every tested arrangement reliably.

==== Learning Application and Visual Comprehension

The students were generally able to browse the available target structures independently and recognised differences in complexity. But the previews were usually viewed only briefly and did not contribute substantially to the selection. Confirming a target frequently required assistance because the corresponding button was comparatively small and did not respond reliably. Although the remaining touch interaction was understood, these difficulties and the limited scope of the tested application mean that #req("IA2") was only partially fulfilled.

The students understood that the full-screen model could be rotated and zoomed and regularly used these functions when the arrangement was unclear. However, some had difficulty distinguishing the two digital brick types, identifying the root brick and determining the orientation of a child relative to its parent. Simple target structures were easier to interpret than complex ones, and some students required an initial demonstration before continuing independently.  
The clarity of the task required by #req("IA3") and the consistency of the physical–digital mapping required by #req("TUI3") were therefore only partially achieved.
//Eher schreiben obwhol es zuerst nicht ganz klat war trotzdem beide requirements erfüllt weil es nicht schlimm ist wenn zuerst die bedeutung kurz erklärt werden muss 

The available targets varied in the number, arrangement and orientation of their bricks, thereby implementing the basic variation of difficulty required by #req("TUI2"). Students were free to select targets, try different construction steps and correct unsuccessful attempts. During pair work, students who had already understood the task also provided hints to their partners. These observations support the structured openness described by #req("TUI1"), although the extent of independent use differed between participants.

=== Analytical Prototype Assessment
==== Construction Detection and Data Processing

The implementation analysis showed that the data format and firmware contain the information required for unique brick identification, connection-face assignment and relative orientation. The node identifier combines brick type and instance, occupied receiving faces are represented through a child mask and one of four upstream contacts determines the relative rotation. The mechanisms required by #req("DET1"), #req("DET2") and #req("DET3") are therefore implemented, but their operation could not be verified in the integrated electronic system.

The recursive communication and tree representation are designed to support constructions containing multiple bricks. Since reliable simultaneous detection was not demonstrated, #req("DET5") remains not evaluated. Frame-length checks, checksums, timeouts and parser validation provide error handling for invalid communication data, partially fulfilling #req("DET6"); ambiguous physical contact states were not examined.

The response-time requirement was not met. The firmware inserts a delay of 550 ms between detection cycles, while #req("DET7") specifies a maximum of 400 ms for detecting a change. Communication, retries and subsequent processing add further time, so #req("DET7") is classified as not fulfilled even without an end-to-end measurement.

==== Target Comparison and Feedback

The backend implements recursive comparison of actual and target trees by brick type, receiving face, orientation and structural path. It derives evaluated node states and generates both a frontend representation and identifier-specific LED data. This provides an implementation of #req("DET4"), #req("FB1") and #req("FB2"), but the complete path from a detected physical construction to coordinated visual and local feedback was not verified. These requirements are therefore classified as implemented but not verified.

Graduated support is not yet operational. Although the comparison distinguishes several error states and the interface includes level options, the selected level does not change the task presentation, feedback or assistance. Requirements #req("FB3") and #req("FB4") are consequently not fulfilled. The prototype combines intrinsic haptic feedback with visual output in the application and on the bricks, but coordinated system-generated feedback was not tested and remains primarily visual. Requirement #req("IA6") is therefore only partially fulfilled.

==== Further Prototype Constraints

Direct inspection confirmed the implementation of two geometrically distinct brick types, a central power supply without individual batteries and a housing that can be assembled and disassembled. However, only eight of the ten bricks required by #req("EL2") were produced, and the material cost of approximately EUR 5 per brick exceeded the EUR 3 target specified by #req("EC1"). Both requirements are therefore not fulfilled.

No damage occurred during ordinary construction activities, but no standardised durability test was conducted. One brick broke after being thrown forcefully onto the floor, demonstrating limited impact resistance beyond the intended handling conditions. All accessible electrical contacts carry only the 5 V DC USB supply. Since this remains below 15 V and does not present an electrical shock hazard under the intended dry-use conditions, the corresponding safety requirement #req("S4") is fulfilled @gordon2018shock.

== Overall Requirement Fulfilment
Of the 34 requirements, 13 were fulfilled, nine were partially fulfilled, six were implemented but could not be verified, five were not fulfilled and one could not be evaluated. @requirement-summary summarises these results. The complete evidence for each requirement is documented in Appendix @appendix-requirements.

#apa-table(
  columns: (1.8fr, 0.7fr, 4fr),

  table-label: <requirement-summary>,

  header: (
    [Assessment],
    [Number],
    [Requirements],
  ),

  caption: [Summary of requirement fulfilment],

  [Fulfilled],
  [13],
  [TASK1; IA1; IA4--IA5; TUI1--TUI2; G1; C1--C3; EL1; S3--S4],

  [Partially fulfilled],
  [9],
  [IA2--IA3; TUI3; IA6; C4; DET6; EL3; S1--S2],

  [Implemented but not verified],
  [6],
  [FB1--FB2; DET1--DET4],

  [Not fulfilled],
  [5],
  [FB3--FB4; DET7; EL2; EC1],

  [Not evaluated],
  [1],
  [DET5],
)

== Discussion
=== Interpretation of the Results
The objective of this work was to develop a tangible learning game that enriches classroom activities for children in special education and supports teachers in providing action-oriented learning opportunities. The reconstruction tasks were designed primarily to address spatial thinking combined with action planning and self-directed learning, while the physical interaction additionally engages fine motor skills, concentration and hand--eye coordination.

The evaluation indicates that the prototype successfully translates this objective into an accessible and motivating form of interaction. The students understood the central idea of reproducing a digital target with physical bricks and engaged willingly with the construction activity. They selected structures, manipulated the three-dimensional representation and built tangible results. It is particularly encouraging that the learning concept remained comprehensible and engaging even without automatic detection and feedback. This suggests that the central value of the system is not created by technology alone, but by the coherent combination of a meaningful task, a digital reference and an actively constructed physical artefact. The proposed system therefore supports the constructionist principle of _learning by making_ discussed in @constructionism.

Instead of receiving a completed solution, the learners were able to externalise their understanding in a construction that remained visible and could be changed throughout the building process. The observed willingness to try different approaches additionally supports the view that the prototype creates a suitable basis for exploratory learning. At the same time, bodily action is meaningfully connected to the subject matter, thereby reflecting the principles of _embodied cognition_ and _embodied interaction_ described in @embodied-cognition.

The prototype also responds convincingly to the design principles for child-appropriate TUIs presented in @tui-children. The target structure provides a clear framework, while the construction process leaves room for different sequences and individual strategies. Structures of varying complexity allowed students with different support needs to participate within the same interaction concept. This balance between guidance and openness is particularly relevant for the heterogeneous learning prerequisites described in @implications-learning. Moreover, the physical availability of several bricks supported spontaneous cooperation: students exchanged suggestions and more confident learners assisted their peers. The system can therefore encourage not only individual construction but also socially shared learning without requiring a separate collaborative mode.

Although differentiated assistance, multimodal output and the complete feedback process remain to be implemented reliably, the prototype already establishes the conceptual and technical foundation for these extensions. The evaluation therefore does not merely show that individual components are usable; it demonstrates that the overall learning idea is understandable, appropriate and especially engaging for the intended target group and context. The prototype can already enrich teacher-guided activities and offers a promising path towards more independent practice once automatic feedback is fully operational. While the present study does not establish measurable learning gains, it provides strong formative evidence that the system is worth developing further as an educational @TUI for special education.

=== Limitations
The evaluation was formative and limited to ten students from one class during a single two-hour session. Its qualitative observations provide insight into the accessibility of the interaction concept, but they do not support generalisation to the full heterogeneous target group. Moreover, no learning outcomes or longer-term changes in independent task performance were measured.

The children tested the physical bricks and the target visualisation, but not the integrated electronic detection and feedback process. Consequently, the comprehensibility of automatic and graduated feedback, its multimodal accessibility and its contribution to independent error correction remain unverified. The results therefore support the underlying learning concept, but not yet the effectiveness of the complete system or its adaptability to different levels of support need.


