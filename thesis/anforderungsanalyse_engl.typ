#show table.cell.where(y: 0): set text(weight: "bold")
#set page(numbering: "1")

= Anforderungsanalyse
Überblick über inhalt des kapitels


== Ziel und Vorgehen
Die Anforderungsanalyse überführt die Erkenntnisse des theorethischen Hintergrunds sowie der sich aus dem sonderpädagogischen Nutzungskontext erschlossenen Prinzipien für die Gestaltung geeigneter Lernangebote in konkrete Anforderungen an den Prototyp. Ziel ist es im Sinne des konstruktionistischen Gedanken ein modulares, würfelbasiertes tangible User Interface in Form eines Lernspiels zu entwickeln, das für den Einsatz im sonderpädagogischen Förderbeich geeignet ist. Der Prototyp soll Schüler:innen ermöglichen, selbstständig dreidimensionale Konstruktionsaufgaben zu bearbeiten und dabei direkt vom System Rückmeldung zu erhalten, ob die von ihnen gebaute Konstruktion der Zielkonstruktion entspricht oder nicht.

Die genauen Anforderungen werden aus drei Perspektiven abgeleitet:
  - den Lernvoraussetzungen der Zielgruppe und den daraus resultierenden pädagogischen Konsequenzen
  - den im theoretischen Hintergrund beschriebenen Eigenschaften und Gestaltungsprinzipien von Tangible User Interfaces
  - den technischen, wirtschaftlichen und zeitlichen Rahmenbedingungen der prototypischen Entwicklung

Im Folgenden werden Nutzungskontext, Anwendungsszenario und die für Konzeption und Entwicklung maßgeblichen Kernanforderungen aufgeführt. ?Der vollständige Anforderungskatalog mit weiteren Detailanforderungen und Prüfkriterien befindet sich in Anhang X.?

== Nutzungskontext und didaktisches Anwendungszenario
Die primäre Zielgruppe stellen Schüler:innen in den Förderschwerpunkten geistige Entwicklung, Lernen und ASS dar. Eine weitere zentrale Personengruppe bilden Lehrkräfte und pädagogische Fachkräfte, die das Lernspiel in den Unterrichtsalltag einbinden und den Lernprozess begleiten. (Das System soll die Lehrkraft also nicht ersetzen, sondern insbesondere während selbstständiger Arbeitsphasen ergänzen.)
Indem das Lernspiel die Kinder selbstständig dreidimensionale Konstruktionsaufgaben bearbeiten lassen soll, sollen jene Kompetenzbereiche gefördert/angesprochen werden: 
  - Primar: räumliches Denken, Handlungsplanung und selbstgesteuertes Lernen
  - Sekundär: Problemlösen, Fehlerkontrolle, Selbstkorrektur
  - Begleitend: Feinmotorik, Konzentration, Auge-Hand-Koordination

Als Hauptanwendung ist eine räumliche Nachbauaufgabe vorgesehen, bei der die Schüler:innen aus mehreren dreidimensionalen Zielkonstruktionen eine ihrem individuellen Niveau entsprechende Aufgabe auswählen und diese mithilfe der Bausteine versuchen nachbilden. (Während eine solche Aufgabe grundsätzlich auch mit konventionellen Konstruktionsmaterialien wie xy durchgeführt werden kann, erweitert das System den Bauprozess um eine automatisierte Rückmeldung: Während des Bauens rekonstruiert das System fortlaufend die räumliche Gesamtkonfiguration und vergleicht sie mit der ausgewählten Zielstruktur. Dadurch wird unmittelbar angezeigt, ob die gebaute Konstruktion korrekt ist oder angepasst werden muss.)

Durch die Anzahl der Bausteine, die räumliche Anordnung und die erforderlichen Rotationen kann der Schwierigkeitsgrad variiert werden. So können einfache Aufgaben aus wenigen Bausteinen und überwiegend linearen Verbindungen bestehen, während anspruchsvollere Aufgaben mehrere Raumrichtungen, unterschiedliche Rotationen und verzweigte Konstruktionen umfassen können. Perspektivisch sind weitere Aufgabenformen wie das Ergänzen unvollständiger Konstruktionen, das Auffinden fehlerhafter Verbindungen oder das freie Konstruieren denkbar.

TABELLEN UND TEXT INHALTLICH MEHR VERKNÜPFEN - NACH UND NACH JEDEN EINTRAG DER TABELLE ERKLÄREN UND GGF NOCH ETWAS ANREICHERN 
== Educational and interaction-related requirements
Entsprechend dem in Kapitel X erläuterten konstruktionistischen Lernverständnis muss die aktive Herstellung eines physischen Artefakts im Mittelpunkt der Lernaktivität stehen. [Aufg1] Die Lernenden müssen die entstehende Konstruktion während der Bearbeitung betrachten, überprüfen und unmittelbar verändern können [IA1]. Dadurch wird ermöglicht, dass ihre gedankliche Vorstellung in eine konkrete räumliche Struktur überführt wird, an der sich die Auswirkungen einzelner Handlungsschritte nachvollziehen lassen. The system must be operable without any technical/programming knowledge and without the need for recalibration [IA2]

Gleichzeitig müssen die Aufgaben die unterschiedlichen Lernvoraussetzungen? der Zielgruppe berücksichtigen und damit einen klaren und überschaubaren Handlungsrahmen bieten [IA3], ohne sämtliche Handlungsschritte vollständig vorzugeben. Abläufe und Teilziele müssen nachvollziehbar dargestellt werden und dabei ausreichend Zeit für die Bearbeitung [IA4] und Wiederholungsmöglichkeiten geben [IA5]. 

Außerdem müssen die in Kapitel x beschriebenen Gestaltungsfaktoren berücksichtigt werden. Durch die darin beschriebene für die Zielgruppe so wichtige strukturierte Offenheit ergibt sich, dass die Kinder unterschiedliche Lösungsversuche durchführen und fehlerhafte Handlungsschritte korrigieren können sollen [TUI1]. Aufgaben müssen so strukturiert sein, dass das Ziel verständlich bleibt und bei Bedarf schrittweise Unterstützung abgerufen werden kann. Der Faktor Reichtum und Komplexität verlangt darüber hinaus dass sich das Lernspiel an unterschiedliche Lernniveaus anpassen kann. Dies soll dadurch realisiert werden, dass Schwierigkeitsgrad und Umfang der Rückmeldung möglichst an unterschiedliche Lernvoraussetzungen angepasst werden können, um mit dem selben grundlegenden Interaktionsprinzip für unterschiedlich anspruchsvolle Aufgaben zu realisieren [TUI2]. Die Bausteine dürfen nur bis zu dem Grad abstrakt gestaltet werden, dass die Bedeutung der physischen Repräsentationen (vergleiche coupling) und die durch sie ermöglichten Handlungen noch eindeutig erkennbar sind [TUI3]. 

#figure(
  table(
    columns: 2,
    stroke: none,

    table.header[ID][Requirement],

    [Aufg1],  [Die Bearbeitung der Aufgabe muss durch das aktive Konstruieren und Verändern eines physischen Artefakts erfolgen.],

    [IA1],  [Die entstandene Konstruktion muss während der Bearbeitung sichtbar, überprüfbar und veränderbar bleiben],
  
    [IA2],  [The system must be operable without any technical/programming knowledge and without the need for recalibration],

    [IA3],  [Ziel und Aufbau der Aufgabe müssen klar und überschaubar dargestellt werden],

    [IA4],  [Die Aufgabe muss im individuellen Bearbeitungstempo durchgeführt werden können.],

    [IA5],  [Bereits ausgeführte Handlungsschritte müssen korrigiert und wiederholt werden können],

    [TUI1],  [Die Aufgabe soll einen strukturierten Handlungsrahmen bieten und innerhalb dieses Rahmens unterschiedliche Lösungsversuche ermöglichen],

    [TUI2],  [Der Schwierigkeitsgrad soll durch die Anzahl der Bausteine, die räumliche Anordnung und die erforderlichen Rotationen variiert werden können],
    
    [TUI3],  [Die physische Gestaltung der Bausteine und ihre digitale Funktion müssen konsistent aufeinander abgestimmt sein.],
  
    
  ),
    caption: [requirements for educational and interactional context],
) <requirement-educational>

== Requirements for feedback and assistance
Für die selbstständige Bearbeitung einer Konstruktionsaufgabe müssen die Lernenden erkennen können, ob ihre Handlung vom System erfasst wurde und welche Bedeutung ihr innerhalb der Lernaufgabe zukommt. Entsprechend der in Kapitel X vorgenommenen Unterscheidung muss das System deshalb sowohl Interaktionsfeedback als auch pädagogisches Feedback bereitstellen können [FB1]. Jede Rückmeldung muss dabei eindeutig der auslösenden Handlung beziehungsweise dem betroffenen Bereich der Konstruktion zugeordnet werden können, damit für die Lernenden erkennbar ist, worauf sie sich bezieht [FB2].

??Während das Interaktionsfeedback darüber informiert, ob eine physische Handlung technisch erkannt wurde, kann das pädagogische Feedback drei verschiedene Funktionen erfüllen: Durch ein Ergebnisfeedback wird angezeigt, ob ein Baustein beziehungsweise ein Handlungsschritt mit der Zielkonstruktion übereinstimmt, fortschrittsfeedback macht sichtbar, welche Teile der Aufgabe bereits erfolgreich bearbeitet wurden und feedforward kann darüber hinaus einen Hinweis auf einen möglichen nächsten Handlungsschritt geben. Ziel soll es sein, alle drei Feedbackfunktionen im Prototyp zu realiseren. Das Ergebnisfeedback soll dabei einem abgestuften Rückmeldekonzept folgen, sodass die ganze Lösung nicht unmittelbar sondern in Schritten vorgegeben wird [FB4].
#figure(
  table(
    columns: 2,
    stroke: none,

    table.header[ID][Requirement],

    [FB1],  [Interaction and educational feedback must be ensured],

    [FB2],  [Feedback must be clearly linked to the action that triggered it or the area concerned],

    [FB3],  [Feedback should be provided on a tiered basis, je nachdem ob der fehler schon mit weniger feedback ausgebessert werden kann],

    [FB4],  [Assistance should be provided on a tiered basis, depending on the learners level],
    
    [IA6],  [Feedback can be provided via several ausgabemedien],
    
  ),
    caption: [requirements for feedback and assistance],
) <requirement-feedback>

Die Rückmeldung soll sowohl lokal an den physischen Bausteinen als auch global über die verbundene visuelle Darstellung angegeben werden können und muss unmittelbar, vollständig und konsistent erfolgen. Mehrere Ausgabemöglichkeiten können die Zugänglichkeit verbessern, müssen wenn verwendet, jedoch aufeinander abgestimmt sein [IA6]. Eine gleichzeitige Häufung von Licht-, Ton- und Bewegungssignalen ist zu vermeiden, da sie von der Aufgabe ablenken oder zu einer Reizüberlastung führen kann.

== Geometrical and ergonomic requirements
Die Bausteine bilden das zentrale Element der Lernspiels: sie stellen die physische Repräsentation der digitalen Informationen dar und dienen gleichzeitig als Bedienelemente. Ihre geometrische und mechanische Gestaltung beeinflusst deshalb sowohl die möglichen Konstruktionen als auch die Verständlichkeit und Zugänglichkeit der Interaktion. Wie schon in den pädagogischen Anforderungen beschrieben, müssen Form und Verbindungsstellen deshalb die vorgesehene Handhabung unmittelbar erkennen lassen und verdeutlichen, wo und wie die Bausteine miteinander verbunden werden können.

Für den Prototyp muss außerdem eine quadratische Grundfläche angestrebt werden. Jeder Baustein muss eine definierte Andockseite besitzen, über die er mit einem anderen Baustein verbunden werden kann. Die übrigen Seiten dienen als aufnehmende Verbindungsseiten, an die weitere Bausteine mit ihrer jeweiligen Andockseite angeschlossen werden können.
Dies ermöglicht verzweigte dreidimensionale Konstruktionen entlang klar definierter Richtungen und reduziert gleichzeitig den Herstellungs- und Erkennungsaufwand. Außerdem ermöglicht die quadratische Fläche die Rotation des bausteins in 90 Grad Schritten. Andere Grundflächenformen würden zusätzliche Verbindungsregeln und Gehäusevarianten erfordern, ohne für den grundlegenden Funktionsnachweis notwendig zu sein.  

Um die Konstruktion zusammenzuhalten, muss die Verbindung zwischen den Bausteinen ausreichend stabil sein, allerdings nur so stark, dass sie noch mit geringem kraftaufwand lösen lässt und ohne feinmotorisch anspruchsvolle, exakte Positionierung hergestellt werden kann. Zudem muss ein Baustein mit einer Hand sicher gegriffen und positioniert werden können. 

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [],  [The body of the cube must be based on a square base],

    [],  [One cube type must be a cube shaped cube with six sides/faces],

    [], [Other cube types could also be implemented in other geometric shapes],

    [],  [Each cube must have at least one defined docking side where to connect with other cubes (Docking side = the side via which the building block can connect to another building block)],

    [],  [Other cubes must be able to connect with the cube via its remaining sides],

    [],  [The cubes must be able to be  arranged or stacked in three dimensions],

    [],  [The cubes must be able to be positioned relative to one another in different orientations],

    [],  [The cubes must be graspable and connected with one hand],

    [],  [Cube connections must be strong enough to hold the structure together and easy enough to disconnect with minimal effort],

    
  ),
    caption: [requirements for design],
) <requirement-design>

== Functional requirements for detection
Welche Informationen das System erfassen und verarbeiten muss, um die physische dreidimensionale Konstruktion digital zu rekonstruieren, wird von den funktionalen Anforderungen beschrieben: Im Lernspiel werden die Bausteine zu räumlichen Strukturen zusammengesetzt, deren Aufbau sowohl durch die Verbindungen als auch durch die relativen Rotationen der Bausteine bestimmt wird.
Für die digitale Erfassung und vor allem das gezielte Feedback muss deshalb jeder Baustein eindeutig identifizierbar sein [DET1]. Zusätzlich muss erkannt werden, welche Bausteine miteinander verbunden sind , über welche Seiten die Verbindung besteht [DET2] und wie sie zueinander ausgerichtet sind [DET3]. Erst aus der Gesamtheit dieser Beziehungen kann die räumliche Konstruktion digital rekonstruiert und mit der Zielkonstruktion verglichen werden [DET4]. Dies soll auch gewährleistet sein, wenn mehrere Bausteine gleichzeitig miteinander verbunden werden [DET5]. Nicht eindeutig erkennbare beziehungsweise widersprüchliche Konfigurationen sollten als Fehlerzustände erkannt werden, um die Nutzenden nicht zu verwirren [DET6]. 

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [DET1],  [the system must be able to uniquely detect each cube],

    [DET2],  [the system must be able to detect which cubes are connected with each other and on what side the connection occurs],

    [DET3],  [the system must be able to detect the relative rotation of a two cubes in relation each other],

    [DET4],  [the system must be able to compare the detected cube structure with a target structure],

    [DET5],  [The system should continue to operate reliably even when multiple cubes are connected simultaneously],

    [DET6],  [Configurations that cannot be clearly identified or are contradictory should be reported as technical faults],

    [DET7],  [Connections and changes to the structure must be detected reliably and within a short time (of 1sec??)],
  ),
    caption: [requirements for detection],
) <requirement-detection>

Die maximale Reaktionszeit von einer Sekunde, die für Erfassung von Veränderungen an der Konstruktion festgelegt wurde, stellt zunächst einen Zielwert dar [DET7]. Sie soll sicherstellen, dass eine Handlung und die daraus folgende Rückmeldung als zusammengehörig wahrgenommen werden.


== Electrical/technical requirements
Die technische Realisierung soll möglichst einfach, modular und wartungsarm beziehungsweise mit vertretbarem Aufwand autauschbar sein. ?The cubes must be operated without their own battery or individual rechargeable battery [EL1].?

Für den grundlegenden Funktionsnachweis sollte eine Anzahl von mindestens zehn Bausteinen erreicht werden, da sie völlig ausreicht um bereits mehrteilige und räumlich verzweigte Konstruktionen zu ermöglichen [EL2]. Perspektivisch soll das System aber ohne Veränderung des grundlegenden Funktionsprinzips um weitere Bausteine erweiterbar sein [EL3].

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [EL1],  [The cubes must be operated without their own battery or individual rechargeable battery],

    [EL2],  [10 cubes],

    [EL3],  [the system should be extendable without changing any basic operating principles],

  ),
    caption: [requirements for technical],
) <requirement-technical>

== Safety and economic requirements
Der Prototyp stellt kein zertifiziertes Spielzeug dar, weshalb er ausschließlich unter Aufsicht eingesetzt werden darf. Mögliche Risiken müssen dennoch bereits konstruktiv reduziert werden und elektronische komponenten und potenziell lösbare kleinteile durch gehäuse vor direktem zugriff geschützt sein [S1].
[S2]??
Ein Baustein sollte sich außerdem möglichst unkompliziert zusammen- und wieder auseinanderbauen lassen, ohne dabei kaputtzugehen. [S3]

#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[ID][Priority][Requirement],

    [S1],  [The cubes must be able to withstand repeated gripping, connecting and disconnecting],

    [S2],  [Electronic components and small parts that could come loose must be protected from direct access by the cube housing],

    [S3],  [the cubes should be assembled and disassembled easily without being distroyed],
  
    [EC1],  [The total cost of materials for the system should not exceed 100 euros],
    
  ),
    caption: [requirements for economic],
) <requirement-economic>

Die Kosten pro Baustein sollen nach Möglichkeit zwischen einem und drei Euro liegen. Da die Gesamtkosten zusätzlich von einer Basisstation, der Steuerelektronik und möglichen Ausgabegeräten abhängen.? [EC1] 