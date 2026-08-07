== Educational and interaction-related requirements

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [], [must-have], [Die Bearbeitung der Aufgabe muss durch das aktive Konstruieren und Verändern eines physischen Artefakts erfolgen.],

    [], [must-have], [Die entstandene Konstruktion muss während der Bearbeitung sichtbar, überprüfbar und veränderbar bleiben],

    [], [must-have], [Ziel und Aufbau der Aufgabe müssen klar und überschaubar dargestellt werden],

    [], [must-have], [Die Aufgabe muss im individuellen Bearbeitungstempo durchgeführt werden können.],

    [], [must-have], [Bereits ausgeführte Handlungsschritte müssen korrigiert und wiederholt werden können],

    [], [should], [Die Aufgabe soll einen strukturierten Handlungsrahmen bieten und innerhalb dieses Rahmens unterschiedliche Lösungsversuche ermöglichen],

    [], [should], [Der Schwierigkeitsgrad soll durch die Anzahl der Bausteine, die räumliche Anordnung und die erforderlichen Rotationen variiert werden können],
    
    [], [must-have], [Die physische Gestaltung der Bausteine und ihre digitale Funktion müssen konsistent aufeinander abgestimmt sein.],
    
  ),
    caption: [requirements for educational and interactional context],
) <requirement-educational>

== Functional requirements for detection

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [], [must-have], [the system must be able to uniquely detect each cube],

    [], [must-have], [the system must be able to detect which cubes are connected with each other and on what side the connection occurs],

    [], [must-have], [the system must be able to detect the relative rotation of a two cubes in relation each other],

    [], [must-have], [The system must be able to deduce the relative position of the components within the overall structure from the local connections],

    [], [must-have], [the system must be able to compare the detected cube structure with a target structure],

    [], [must-have], [The system must continue to operate reliably even when multiple cubes are connected simultaneously],

    [], [must-have?], [Configurations that cannot be clearly identified or are contradictory must be reported as technical faults],

    [], [must-have], [Connections and changes to the structure must be detected reliably and within a short time (of 1sec??)],
  ),
    caption: [requirements for detection],
) <requirement-detection>

== Requirements for feedback and assistance

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [], [must-have], [Interaction and educational feedback must be ensured],

    [], [must-have], [Feedback must be clearly linked to the action that triggered it or the area concerned],

    [], [should], [Feedback should be provided on a tiered basis, je nachdem ob der fehler schon mit weniger feedback ausgebessert werden kann],

    [], [should], [Assistance should be provided on a tiered basis, depending on the learners level],

    [], [should], [Feedback soll über mehr alls nur richtig oder falsch hinaus gehen],
    
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

    [], [must-have], [The body of the cube must be based on a square base],

    [], [must-have], [One cube type must be a cube shaped cube with six sides/faces],

    [], [can/could], [Other cube types could also be implemented in other geometric shapes],

    [], [must-have], [Each cube must have at least one defined docking side where to connect with other cubes (Docking side = the side via which the building block can connect to another building block)],

    [], [must-have], [Other cubes must be able to connect with the cube via its remaining sides],

    [], [must-have], [The cubes must be able to be  arranged or stacked in three dimensions],

    [], [must-have], [The cubes must be able to be positioned relative to one another in different orientations],

    [], [must-have], [The cubes must be graspable and connected with one hand],

    [], [must-have], [Cube connections must be strong enough to hold the structure together and easy enough to disconnect with minimal effort],

    [], [should], [the cubes should be assembled and disassembled easily without being distroyed]
    
  ),
    caption: [requirements for design],
) <requirement-design>

== Electrical/technical requirements

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [], [should], [The technical implementation should be as simple, modular and low-maintenance as possible?? nicht gescheit definiert??],

    [], [must-have], [The cubes must be operated without their own battery or individual rechargeable battery],

    [], [should], [The the cubes should be powered centrally],

    [], [should], [10 cubes - vlt nur im text nennen],

    [], [should], [the system should be extendable without changing any basic operating principles],

    [], [must-have], [The system must be operable without any technical/programming knowledge and without the need for recalibration ??vlt allgemeiner],
  ),
    caption: [requirements for technical],
) <requirement-technical>

== Safety and economic requirements

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [], [must-have], [The cubes must be able to withstand repeated gripping, connecting and disconnecting],

    [], [must-have], [Electronic components and small parts that could come loose must be protected from direct access by the cube housing],
  
    [], [should], [The total cost of materials for the system should not exceed 100 euros],
  ),
    caption: [requirements for economic],
) <requirement-economic>
