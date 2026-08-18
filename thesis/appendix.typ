#import "functions.typ": apa-table

= Detailed Requirement Assessment <appendix-requirements>
The following table provides the complete requirement-by-requirement assessment of the prototype. The classifications refer to its state at the time of evaluation and consolidate evidence from the target-group evaluation, physical inspection and demonstration, and implementation analysis.

#apa-table(
  columns: (0.8fr, 4fr, 1.7fr),
  breakable: true,

  table-label: <overall-requirement-fulfilment>,

  header: (
    [ID],
    [Evidence],
    [Assessment],
  ),

  caption: [Detailed assessment of requirement fulfilment],

  [TASK1],
  [Active construction with physical bricks was demonstrated],
  [Fulfilled],

  [IA1],
  [Constructions remained visible, inspectable and modifiable],
  [Fulfilled],

  [IA2],
  [Basic use was understood, but confirmation frequently required assistance],
  [Partially fulfilled],

  [IA3],
  [Root, brick type and orientation were not always understood],
  [Partially fulfilled],

  [IA4],
  [Tasks imposed no time limit and permitted individual pacing],
  [Fulfilled],

  [IA5],
  [Connections could be corrected, repeated and repositioned],
  [Fulfilled],

  [TUI1],
  [Target-based framework allowed experimentation and different construction sequences],
  [Fulfilled],

  [TUI2],
  [Targets varied in brick count, arrangement and orientation],
  [Fulfilled],

  [TUI3],
  [General physical–digital correspondence was understood, but some cues remained ambiguous],
  [Partially fulfilled],

  [FB1],
  [Visual and local feedback processing exists but was not tested end to end],
  [Implemented but not verified],

  [FB2],
  [Feedback states are assigned to affected bricks and positions but were not user-tested],
  [Implemented but not verified],

  [FB3],
  [No progressive increase of feedback after unsuccessful correction],
  [Not fulfilled],

  [FB4],
  [Level selection does not alter assistance or task behaviour],
  [Not fulfilled],

  [IA6],
  [Haptic and visual levels exist, but coordinated feedback remains primarily visual],
  [Partially fulfilled],

  [G1],
  [Cube and smashed brick were implemented as distinct geometries],
  [Fulfilled],

  [C1],
  [Three-dimensional and branching arrangements were demonstrated],
  [Fulfilled],

  [C2],
  [Connections in different relative orientations were demonstrated],
  [Fulfilled],

  [C3],
  [One-handed grasping, positioning and connection were observed],
  [Fulfilled],

  [C4],
  [Connections were easy to operate but unstable in longer horizontal arrangements],
  [Partially fulfilled],

  [DET1],
  [Type and instance are encoded in the node identifier],
  [Implemented but not verified],

  [DET2],
  [Child mask and port order encode connection relationships],
  [Implemented but not verified],

  [DET3],
  [Four upstream contacts encode relative orientation],
  [Implemented but not verified],

  [DET4],
  [Recursive actual–target comparison is implemented in the backend],
  [Implemented but not verified],

  [DET5],
  [Reliable electronic operation with multiple bricks was not demonstrated],
  [Not evaluated],

  [DET6],
  [Invalid frames and payloads are rejected; ambiguous physical states were not tested],
  [Partially fulfilled],

  [DET7],
  [A 550 ms cycle delay already exceeds the specified 400 ms maximum],
  [Not fulfilled],

  [EL1],
  [Bricks contain no individual batteries and use a central supply],
  [Fulfilled],

  [EL2],
  [Eight bricks were produced instead of the required ten],
  [Not fulfilled],

  [EL3],
  [Recursive operation supports extension, but no expansion test was conducted],
  [Partially fulfilled],

  [S1],
  [Ordinary use caused no damage, but no standardised durability test was conducted],
  [Partially fulfilled],

  [S2],
  [The intact housing encloses components, but protection under impact is limited],
  [Partially fulfilled],

  [S3],
  [Assembly and disassembly were demonstrated without damage],
  [Fulfilled],

  [S4],
  [The interface reduces short-circuit risk, but overvoltage protection was not verified],
  [Partially fulfilled],

  [EC1],
  [Material cost was approximately EUR 5 instead of the EUR 3 target],
  [Not fulfilled],
)

#pagebreak()
#set page(flipped: true)

= Circuit Diagram <appendix-circuit-diagram>

#align(center, image(
  "Schaltplan.pdf",
  width: 100%,
  height: 13.5cm,
  fit: "contain",
))
