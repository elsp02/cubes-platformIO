== Educational and interaction-related requirements

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [],  [Die Bearbeitung der Aufgabe muss durch das aktive Konstruieren und Verändern eines physischen Artefakts erfolgen.],

    [],  [Die entstandene Konstruktion muss während der Bearbeitung sichtbar, überprüfbar und veränderbar bleiben],

    [],  [Ziel und Aufbau der Aufgabe müssen klar und überschaubar dargestellt werden],

    [],  [Die Aufgabe muss im individuellen Bearbeitungstempo durchgeführt werden können.],

    [],  [Bereits ausgeführte Handlungsschritte müssen korrigiert und wiederholt werden können],

    [],  [Die Aufgabe soll einen strukturierten Handlungsrahmen bieten und innerhalb dieses Rahmens unterschiedliche Lösungsversuche ermöglichen],

    [],  [Der Schwierigkeitsgrad soll durch die Anzahl der Bausteine, die räumliche Anordnung und die erforderlichen Rotationen variiert werden können],
    
    [],  [Die physische Gestaltung der Bausteine und ihre digitale Funktion müssen konsistent aufeinander abgestimmt sein.],
    
  ),
    caption: [requirements for educational and interactional context],
) <requirement-educational>

== Functional requirements for detection

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [],  [the system must be able to uniquely detect each cube],

    [],  [the system must be able to detect which cubes are connected with each other and on what side the connection occurs],

    [],  [the system must be able to detect the relative rotation of a two cubes in relation each other],

    [],  [The system must be able to deduce the relative position of the components within the overall structure from the local connections],

    [],  [the system must be able to compare the detected cube structure with a target structure],

    [],  [The system must continue to operate reliably even when multiple cubes are connected simultaneously],

    [], [must-have?], [Configurations that cannot be clearly identified or are contradictory must be reported as technical faults],

    [],  [Connections and changes to the structure must be detected reliably and within a short time (of 1sec??)],
  ),
    caption: [requirements for detection],
) <requirement-detection>

== Requirements for feedback and assistance

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [],  [Interaction and educational feedback must be ensured],

    [],  [Feedback must be clearly linked to the action that triggered it or the area concerned],

    [],  [Feedback should be provided on a tiered basis, je nachdem ob der fehler schon mit weniger feedback ausgebessert werden kann],

    [],  [Assistance should be provided on a tiered basis, depending on the learners level],

    [],  [Feedback soll über mehr alls nur richtig oder falsch hinaus gehen],
    
    [], [can], [Feedback can be provided via several ausgabemedien],
    
  ),
    caption: [requirements for feedback],
) <requirement-feedback>

== Geometrical and ergonomic requirements

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [],  [The body of the cube must be based on a square base],

    [],  [One cube type must be a cube shaped cube with six sides/faces],

    [], [can/could], [Other cube types could also be implemented in other geometric shapes],

    [],  [Each cube must have at least one defined docking side where to connect with other cubes (Docking side = the side via which the building block can connect to another building block)],

    [],  [Other cubes must be able to connect with the cube via its remaining sides],

    [],  [The cubes must be able to be  arranged or stacked in three dimensions],

    [],  [The cubes must be able to be positioned relative to one another in different orientations],

    [],  [The cubes must be graspable and connected with one hand],

    [],  [Cube connections must be strong enough to hold the structure together and easy enough to disconnect with minimal effort],

    [],  [the cubes should be assembled and disassembled easily without being distroyed]
    
  ),
    caption: [requirements for design],
) <requirement-design>

== Electrical/technical requirements

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [],  [The technical implementation should be as simple, modular and low-maintenance as possible?? nicht gescheit definiert??],

    [],  [The cubes must be operated without their own battery or individual rechargeable battery],

    [],  [The the cubes should be powered centrally],

    [],  [10 cubes - vlt nur im text nennen],

    [],  [the system should be extendable without changing any basic operating principles],

    [],  [The system must be operable without any technical/programming knowledge and without the need for recalibration ??vlt allgemeiner],
  ),
    caption: [requirements for technical],
) <requirement-technical>

== Safety and economic requirements

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [],  [The cubes must be able to withstand repeated gripping, connecting and disconnecting],

    [],  [Electronic components and small parts that could come loose must be protected from direct access by the cube housing],
  
    [],  [The total cost of materials for the system should not exceed 100 euros],
  ),
    caption: [requirements for economic],
) <requirement-economic>
