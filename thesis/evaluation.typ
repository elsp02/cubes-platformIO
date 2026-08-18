= Evaluation
ca 10 seiten

== Aim and Scope
- Ziel: Erfüllung der Anforderungen aus der Anforderungsanalyse prüfen
- Zielgruppentest umfasst Würfelgestaltung und Lernanwendung
- automatische elektronische Erkennung war nicht funktionsfähig
- technische Komponenten werden deshalb nur separat beziehungsweise analytisch bewertet (requirements based prototype assessment)
- keine Untersuchung der langfristigen Lernwirkung

== Methods of Evaluation
=== Target-Group Evaluation
A formative evaluation was conducted to investigate the accessibility of the physical building bricks and the usability of the learning application for the intended target group. At the time of the target-group evaluation, the electronic construction-detection system was not yet sufficiently reliable for use during the construction tasks. The evaluation therefore focused on the physical interaction with the building bricks and the use of the learning application, including the selection and visualisation of target structures and the learners ability to relate the digital representations to the physical bricks.

==== Participants and Setting
The evaluation was conducted with 10 students attending the sixth year of a special education school. The group was a mix of students with different educational support needs related to @GE, @LE and @ASD. The evaluation took place in the students’ regular school environment and lasted approximately two hours. 
The tasks were initially completed individually but during the later part of the session, several students also worked together in pairs. The construction acitvities were supervised by the researcher and the attending teachers, who provided assistance when necessary.

==== Materials and Tasks
For the construction tasks, eight physical prototype bricks were available, comprising four bricks of each of the two implemented brick types. The electronic components were not used during the session.
The learning application was presented on a touchscreen tablet and displayed a selection of unterschiedlich schweren target structures with varying levels of complexity from which the students could choose. 
After confirming their selection, the chosen target structure was displayed as an interactive three-dimensional model in full-screen mode.

#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 0.8em,
  [
    #figure(
      image("figures/quadrat@3x.png", width: 100%),
      caption: [Bild 1],
      supplement: [einfach],
      kind: "figure",
    )
  ],
  [
    #figure(
      image("figures/quadrat@3x.png", width: 100%),
      caption: [Bild 2],
      supplement: [mittel],
      kind: "figure",
    )
  ],
  [
    #figure(
      image("figures/quadrat@3x.png", width: 100%),
      caption: [Bild 3],
      supplement: [schwer],
      kind: "figure",
    )
  ],
)
==== Procedure
At the beginning of the evaluation, the students were introduced to the general purpose of the system and the reconstruction task. Each student was subsequently invited to select a target structure in the learning application and reproduce it using the physical bricks. Depending on their interest, the students could complete more than one task or work collaboratively in pairs.
During construction, the students could interact with the three-dimensional visualisation of the target structure and rotate it to inspect the construction from different viewing angles.
The students were encouraged to complete the tasks independently and without assistance from the supervising adults but if required support was provided gradually. Initially, verbal hints were given. If these were insufficient, the target visualisation was rotated to provide a more suitable viewing angle and the relevant brick was indicated on the screen. If further assistance was required, the appropriate physical brick was provided to the student. Only when these forms of support proved insufficient did a supervising adult demonstrate or perform the required connection.

=== Data Collection
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

FEHLT: wie habe ich die beobachtungen festgehalten: durch notizen während und unmittelbar nach der Durchführung

---deutsch
also wie die kinder die würfel greifen und verbinden können, ob es sich gut auseinander und verbinden lässt, ob sie verstehen welche seiten miteinander verbunden werden können und welche nicht (constraint), ob sie generell verstehen dass es sich bei den objekten um zusammensteckbare würfel handelt, ob das gleichgewicht zwischen stabilität (von den magneten) und leichtes verbinden stimmt) und die lernanwendung mit der funktion auswahl einer zielkonstruktion und darstellung der kompletten zielkonstruktion, damit man sieht was man bauen muss, getestet (es wurde deshalb wie verständlich die zielstruktur auswahl ist, ob die kinder anhand der visualisierten ziel construktion erkennen können was sie bauen müssen und ob die physischen würfel mit ihrem digitalen abbild verknüpft werden konnten, geprüft. und noch wie intuitiv und verständlich die lernanwendung ist, mit buttons und allem )

=== Requirements-Based Assessment/Assessment of the Remaining Requirements
==== Inspection and Software-Based Assessment
==== Assessment Criteria
nur bewertungsstufen definieren -> anforderung kann 
- fulfilled
- partially fulfilled
- implemented but not verified
- conceptually addressed
- not fulfilled
- not evaluated

== Results
=== Results of the Target-Group Evaluation
==== Physical Interaction with the Building Bricks
Die Kinder konnten die bricks ohne probleme greifen auch mit einer hand. nach einer kurzen erklärung welche seiten miteinander verbunden werden können, hat das auch gut geklappt. der constraint mechanismus mit dem formschluss sowie die magnethilfe dass die bricks quasi "von allein" sich verbunden haben war dabei sehr hilfreich. die magnete und der formschluss haben jedoch nicht ausgereicht um mehr als drei bausteine horizontal miteinander zu verbinden weil dann die verbindung sich gelöst hat und die construction auseinander gefallen ist. es wurden auch ungültige seitenverbindungen ausprobiert (andockseite auf andockseite), weil wegen des neodymmagneten in der mitte sich die seiten auch ein wenig angezogen haben. die beiden baustein typen wurden beidermaßen gut verstanden. auch wurde verstanden welcher physische brick zum digitalen target brick gehört und aufgrund des aussehens der bausteine ein bisschen wie bekannte klemmbausteine wurde sofort verstanden dass die bausteine zum zusammenbauen sind.  

Hier behandelst du ausschließlich die physische Handhabung:
- Erkannten die Kinder, dass die Bausteine verbunden werden können? 

- Konnten sie die Bausteine greifen und positionieren?
- War eine einhändige Bedienung möglich?
- Konnten die Magnete ohne zu viel Kraft verbunden und getrennt werden?
- Waren die Verbindungen stabil genug?
- Wurden Andock- und Aufnahmeseiten unterschieden?
- Wurden ungültige Seitenkombinationen ausprobiert?
- Konnten dreidimensionale und verzweigte Strukturen gebaut werden?
- Gab es Unterschiede zwischen den beiden Bausteintypen?
- Kam es zu unbeabsichtigtem Lösen, Verrutschen oder falscher Ausrichtung?
Hier kannst du auf C1–C4, TASK1, IA1, IA5 und TUI3 Bezug nehmen.

// Beobachtete Ergebnisse mit requirements aufzählen

==== Learning application and visual comprehension
die kinder konnten selbständig durch die auswahl konstruktionen durchgehen und haben auch verstanden dass die sich in ihrer komplexität unterscheiden. relativ häufig wurde hilfe beim bestätigen der ausgewählten konstruktion benötigt weil der digitale button nicht responisv genug war und zu klein. die kinder haben auch verstanden dass man die ansicht drehen und zoomen kann und haben das auch regelmäßig verwendet wenn sie nicht weiter wussten. die preview darstellung wurde aber meistens nicht genutzt bzw nur kurz angeschaut und hat nicht zur auswahlhilfe beigetragen. Touchbedienung war verständlich weil sie im unterricht auch höufig mit touchscreen laptops arbeiten. 

auch wurde verstanden welcher physische brick zum digitalen target brick gehört und aufgrund des aussehens der bausteine ein bisschen wie bekannte klemmbausteine wurde sofort verstanden dass die bausteine zum zusammenbauen sind. manche kinder hatten schwierigkeiten die beiden bausteintypen auf der target visualisierung korrekt zu unterscheiden und den passenden typ auszuwählen. einfachere zielstrukturen waren auch verständlicher als komplexe. aufgrund dass nicht dargestellt worden ist welcher brick der root brick ist war es auch schwer diesen zu identifizieren was notwendig war um die konstruktion richtig zu bauen. am meisten fehler bzw schwierigkeiten gab es die würfel korrekt zu drehen um richtig orientiert auf den parent baustein zu setzen. zusammenarbeit war vor allem zwischen lernenden die es schlechter konnten und denen die es besser konnten, dabei hat vor allem die besser könnende person die "lehrerrolle" eingenommen und hat tips gegeben. manche kinder haben die aufgabe auch sofort verstanden und andere zunächst eine Demonstration benötigten,

Hier geht es um die Bedienung, nicht primär um das räumliche Verständnis:
- Konnten die Kinder selbstständig eine Zielkonstruktion auswählen?
- Wurde die Auswahlübersicht verstanden?
- Wurde der Bestätigungsbutton gefunden und zuverlässig ausgelöst?
- Wie häufig war bei der Auswahl Hilfe nötig?
- Konnten die Kinder die 3D-Ansicht selbstständig drehen?
- War die Touchbedienung verständlich?
- Welche Buttons oder Interaktionen bereiteten Schwierigkeiten?
- Wurde die Vollbilddarstellung sinnvoll genutzt?

Deine Beobachtung, dass der Bestätigungsbutton zu klein war oder nicht sofort reagierte, gehört genau hierher.
Beispiel:
Most students were able to select a target structure independently. However, confirming the selection occasionally required assistance because the corresponding button was comparatively small and did not always respond immediately to touch input.

Anforderung IA2 IA3 TUI3

// Beobachtete Ergebnisse mit requirements aufzählen

=== Results of the Requirements-Based Assessment
==== Physical and Mechanical Requirements
==== Detection and Data Processing
==== Target Comparison and Feedback
==== Technical, Safety and Economic Requirements

== Overall Requirement Fulfilment
tabelle

== Discussion
=== Interpretation of the Results
=== Limitations

///
/// 
Methodology: Was wurde wie, mit wem und nach welchen Kriterien geprüft?
Results: Was wurde dabei beobachtet beziehungsweise festgestellt?
Discussion: Was bedeuten diese Ergebnisse?

== Notizen
- kinder haben den anderen kindern geholfen - space multiplexing, automatisch zur gruppenarbeit gefördert
- viel ausprobiert, keine angst vor fehlern 

aus dem grsrpäch mit lehrerin
- lernanwendung multimodal - auch feedback hören und nicht nur sehen, hilfetext der auch vorgelesen werden kann
- bausteine farben noch mehr conträr
- viele bilder wenig text in der learning application

The system-generated feedback is primarily visual and therefore does not constitute fully multidimensional feedback in the sense of IA6. It is nevertheless distributed across several complementary levels. 

- elektronik (bedeutet die erfassung der aktuellen construction, die visualisierung dieser und das daraus resultierende abgleich mit der ziel konstruktion sowie das feedback) wurde nicht verwendet 
  -> deshalb wurden nur die physischen würfel (also wie die kinder die würfel greifen und verbinden können, ob es sich gut auseinander und verbinden lässt, ob sie verstehen welche seiten miteinander verbunden werden können und welche nicht (constraint), ob sie generell verstehen dass es sich bei den objekten um zusammensteckbare würfel handelt, ob das gleichgewicht zwischen stabilität (von den magneten) und leichtes verbinden stimmt) und die lernanwendung mit der funktion auswahl einer zielkonstruktion und darstellung der kompletten zielkonstruktion, damit man sieht was man bauen muss, getestet (es wurde deshalb wie verständlich die zielstruktur auswahl ist, ob die kinder anhand der visualisierten ziel construktion erkennen können was sie bauen müssen und ob die physischen würfel mit ihrem digitalen abbild verknüpft werden konnten, geprüft )

- manche kinder haben auch sofort verstanden dass sie die zielkonstruktion mit dne bausteinen nachbauen müssen und bei manchen hat man es zuerst ein paar mal vorgemacht und die bausteine verbunden und dann sie es aber selber machen lassen 

== ausblick
steffis anmelrungen zum user interface 