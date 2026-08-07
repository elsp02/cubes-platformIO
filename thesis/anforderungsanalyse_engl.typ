#show table.cell.where(y: 0): set text(weight: "bold")
#set page(numbering: "1")

= Anforderungsanalyse
ÜBERLEITUNG FEHLT
== Ziel und Vorgehen
Die Anforderungsanalyse überführt die Erkenntnisse des theorethischen Hintergrunds sowie der sich aus dem sonderpädagogischen Nutzungskontext erschlossenen Prinzipien für die Gestaltung geeigneter Lernangebote in konkrete Anforderungen an den zu entwickelnden? Prototyp. Ziel ist es im Sinne des konstruktionistischen Gedanken ein modulares, würfelbasiertes tangible User Interface in Form eines Lernspiels zu entwickeln, das für den Einsatz im sonderpädagogischen Förderbeich geeignet ist. 
Der Prototyp richtet sich dabei besonders an Schüler:innen mit Förderbedarf in den Schwerpunkten geistige Entwicklung, Lernen und ASS und soll ihnen ermöglichen mit Bausteinen selbstständig dreidimensionale Konstruktionsaufgaben bearbeiten zu können und direkt vom System rückmeldung bekommen, ob richtig oder falsch. (damit kein lehrer notwendig)

Die genauen Anforderungen werden aus drei Perspektiven abgeleitet:
  - den Lernvoraussetzungen der Zielgruppe und den daraus resultierenden pädagogischen Konsequenzen
  - den im theoretischen Hintergrund beschriebenen Eigenschaften und Gestaltungsprinzipien von Tangible User Interfaces
  - den technischen, wirtschaftlichen und zeitlichen Rahmenbedingungen der prototypischen Entwicklung
  
Aufgrund der bereits beschriebenen Heterogenität der Kinder innerhalb der Zielgruppe kann nicht von einheitlichen Lernvoraussetzungen in  Handlungs- und Lernfähigkeit ausgegangen werden, weshalb der Prototyp keine vollständige Barrierefreiheit für alle denkbaren Unterstützungsbedarfe gewährleisten kann. Er soll jedoch die gemeinsamen? (sagen dass geschaut welche alle haben) zu fördernden Entwicklungs- und Kompetenzbereiche abdecken und so gestaltet sein, dass Aufgaben, Schwierigkeitsgrad und Umfang der Rückmeldung möglichst an unterschiedliche Lernvoraussetzungen angepasst werden können.

Zur Priorisierung werden die Anforderungen in drei Kategorien eingeteilt:
- Muss-Anforderungen: Diese sind für den vorgesehenen Anwendungsfall und die grundlegende Funktionsfähigkeit zwingend erforderlich
- Soll-Anforderungen: Anforderungen dieser Kategorie besitzen zwar eine hohe Relevanz, können bei technischen oder zeitlichen Einschränkungen jedoch in begründeter Form reduziert werden.
- Kann-Anforderungen: Sie stellen mögliche Erweiterungen dar, die für den ersten Funktionsnachweis nicht erforderlich sind.

Im Folgenden werden Nutzungskontext, Anwendungsszenario und die für Konzeption und Entwicklung maßgeblichen Kernanforderungen aufgeführt. ?Der vollständige Anforderungskatalog mit weiteren Detailanforderungen und Prüfkriterien befindet sich in Anhang X.?

== Nutzungskontext und didaktisches Anwendungszenario
ÜBERLEITUNG FEHLT
=== Nutzungskontext
Die primäre Zielgruppe stellen Schülerinnen in den Förderschwerpunkten geistige Entwicklung, Lernen und ASS dar. Sie interagieren mit dem Lernspiel indem sie Bausteine greifen, räumlich anordnen und schließlich miteinander verbinden. Die Interaktion soll dabei ohne technische Vorkenntnisse und völlig selbstständig ohne zusätzliche Unterstützung einer Lehrkraft möglich sein, indem das System selbst? Hilfestellung und Feedback für die nutzende Person bereitstellt. Neben selbstgesteuertem Lernen soll das lernspiel diese Kompetenzbereiche fördern/ansprechen:
  - primar: räumliches denken, handlungsplanung und selbstgesteuertes lernen
  - sekundär: problemlösen, fehlerkontrolle, Selbstkorrektur
  - begleitend: feinmotorik, konzentration, auge hand koordination
FRAGE: wann sagen, ob diese Kompetenzen wirklich abgedeckt sind und warum? in Evaluation/Fazit/auch Anforderungsanalyse?? ??(Ob und in welchem Umfang der Einsatz des Systems diese Kompetenzen tatsächlich fördert, wurde mit Schülerinnen einer Förderschule teilweise getestet und in kapitel Evaluation untersucht)

Eine weitere zentrale Personengruppe bilden Lehrkräfte und pädagogische Fachkräfte (bezug zu TUI Gestaltungsfaktoren), denn sie sollen das entwickelte lernspiel ohne große Vorbereitungszeit oder Bedienaufwand in den Unterrichtsalltag miteinbinden können. Außerdem begleiten sie den Lernprozess und geben weiterführende Erklärungen, falls die vom System Hilfestellung/Feedback nicht ausreicht oder verstanden wird. Das System soll die Lehrkraft daher nicht ersetzen, sondern insbesondere während selbstständiger Arbeitsphasen ergänzen.

=== Anwendungszenario
Als Hauptanwendung wird eine räumliche Nachbauaufgabe festgelegt. Dabei können sich die Schüler aus mehreren vorgegebenen dreidimensionalen Zielkonstruktionen eine für sie passende auswählen und mithilfe der Bausteine versuchen nachzubilden. Während des Bauens erfasst das System die verbundenen Bausteine sowie ihre Verbindungen und relativen Rotationen zueinander und rekonstruiert daraus die räumliche Gesamtkonfiguration, die anschließend mit der ausgewählten Zielstruktur verglichen wird.
Die gebaute Konstruktion als auch die Zielkonstruktion wird dann auf einem Bildschirm visualisiert und falsche Bausteine markiert, sodass Feedback.?Feedback? direkt Rückmeldung ob ein baustein richtig oder falsch verbunden worden ist und welche möglichen Verbindungen als nächstes kommen

?? SZENARIO NOCH AUSFÜHRLICHER UND DETAILLIERTER BESCHREIBEN??

Der Aufgabenumfang soll durch die Anzahl der Bausteine und die Komplexität der Zielstruktur angepasst werden können. So sollen einfache Aufgaben aus wenigen Bausteinen und überwiegend linearen Verbindungen bestehen, während anspruchsvollere Aufgaben mehrere Raumrichtungen, unterschiedliche Rotationen und verzweigte Konstruktionen umfassen können.
Perspektivisch sind weitere Aufgabenformen wie das Ergänzen unvollständiger Konstruktionen, das Auffinden fehlerhafter Verbindungen oder das freie Konstruieren denkbar.

== Educational and interaction-related requirements
Entsprechend dem in Kapitel X erläuterten konstruktionistischen Lernverständnis muss die aktive Herstellung eines physischen Artefakts im Mittelpunkt der Lernaktivität stehen. Die Lernenden müssen die entstehende Konstruktion während der Bearbeitung betrachten, überprüfen und unmittelbar verändern können. Dadurch wird ermöglicht, dass ihre gedankliche Vorstellung in eine konkrete räumliche Struktur überführt wird, an der sich die Auswirkungen einzelner Handlungsschritte nachvollziehen lassen.

Gleichzeitig müssen die Aufgaben die unterschiedlichen Lernvoraussetzungen? der Zielgruppe berücksichtigen und damit einen klaren und überschaubaren Handlungsrahmen bieten, ohne sämtliche Handlungsschritte vollständig vorzugeben. Abläufe und Teilziele müssen nachvollziehbar dargestellt werden und dabei ausreichend Zeit für die Bearbeitung und Wiederholungsmöglichkeiten geben. 

Außerdem müssen die in Kapitel x beschriebenen Gestaltungsfaktoren berücksichtigt werden. Durch die darin beschriebene für die Zielgruppe so wichtige strukturierte Offenheit ergibt sich, dass die Kinder unterschiedliche Lösungsversuche durchführen und fehlerhafte Handlungsschritte korrigieren können sollen. Aufgaben müssen so strukturiert sein, dass das Ziel verständlich bleibt und bei Bedarf schrittweise Unterstützung abgerufen werden kann. Der Faktor Reichtum und Komplexität verlangt darüber hinaus dass sich das Lernspiel an unterschiedliche Lernniveaus anpassen kann. Dies soll dadurch realisiert werden, dass Schwierigkeitsgrad und Umfang der Rückmeldung möglichst an unterschiedliche Lernvoraussetzungen angepasst werden können, um mit dem selben grundlegenden Interaktionsprinzip für unterschiedlich anspruchsvolle Aufgaben zu realisieren. Die Bausteine dürfen nur bis zu dem Grad abstrakt gestaltet werden, dass die Bedeutung der physischen Repräsentationen (vergleiche coupling) und die durch sie ermöglichten Handlungen noch eindeutig erkennbar sind. 

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
Welche Informationen das System erfassen und verarbeiten muss, um die physische dreidimensionale Konstruktion digital zu rekonstruieren, wird von den funktionalen Anforderungen beschrieben: Im Lernspiel werden die Bausteine zu räumlichen Strukturen zusammengesetzt, deren Aufbau sowohl durch die Verbindungen als auch durch die relativen Rotationen der Bausteine bestimmt wird.
Für die digitale Erfassung und vor allem das gezielte Feedback muss deshalb jeder Baustein eindeutig identifizierbar sein. Zusätzlich muss erkannt werden, welche Bausteine miteinander verbunden sind, über welche Seiten die Verbindung besteht und wie sie zueinander ausgerichtet sind. Erst aus der Gesamtheit dieser Beziehungen kann die räumliche Konstruktion digital rekonstruiert und mit der Zielkonstruktion verglichen werden. Nicht eindeutig erkennbare beziehungsweise widersprüchliche Konfigurationen sollten als Fehlerzustände erkannt werden, um die Nutzenden nicht zu verwirren. 

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

Die maximale Reaktionszeit von einer Sekunde, die für Erfassung von Veränderungen an der Konstruktion festgelegt wurde, stellt zunächst einen Zielwert dar. Sie soll sicherstellen, dass eine Handlung und die daraus folgende Rückmeldung als zusammengehörig wahrgenommen werden.

FAZIT?? BEI JEDEM ANFORDERUNGSUNTERKAPITEL??

== Requirements for feedback and assistance
VLT NOCH MEHR AUF DIMENSIONEN EINGEHEN

Für die selbstständige Bearbeitung einer Konstruktionsaufgabe müssen die Lernenden erkennen können, ob ihre Handlung vom System erfasst wurde und welche Bedeutung ihr innerhalb der Lernaufgabe zukommt. Entsprechend der in Kapitel X vorgenommenen Unterscheidung muss das System deshalb sowohl Interaktionsfeedback als auch pädagogisches Feedback bereitstellen können. Jede Rückmeldung muss dabei eindeutig der auslösenden Handlung beziehungsweise dem betroffenen Bereich der Konstruktion zugeordnet werden können, damit für die Lernenden erkennbar ist, worauf sie sich bezieht.

Während das Interaktionsfeedback darüber informiert, ob eine physische Handlung technisch erkannt wurde, kann das pädagogische Feedback drei verschiedene Funktionen erfüllen: Durch ein Ergebnisfeedback wird angezeigt, ob ein Baustein beziehungsweise ein Handlungsschritt mit der Zielkonstruktion übereinstimmt, fortschrittsfeedback macht sichtbar, welche Teile der Aufgabe bereits erfolgreich bearbeitet wurden und feedforward kann darüber hinaus einen Hinweis auf einen möglichen nächsten Handlungsschritt geben. Ziel soll es sein, alle drei Feedbackfunktionen im Prototyp zu realiseren. Das Ergebnisfeedback soll dabei einem abgestuften Rückmeldekonzept folgen, sodass die ganze Lösung nicht unmittelbar sondern in Schritten vorgegeben wird.
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

Die Rückmeldung soll sowohl lokal an den physischen Bausteinen als auch global über die verbundene visuelle Darstellung angegeben werden können und muss unmittelbar, vollständig und konsistent erfolgen. Mehrere Ausgabemöglichkeiten können die Zugänglichkeit verbessern, müssen wenn verwendet, jedoch aufeinander abgestimmt sein. Eine gleichzeitige Häufung von Licht-, Ton- und Bewegungssignalen ist zu vermeiden, da sie von der Aufgabe ablenken oder zu einer Reizüberlastung führen kann.

== Geometrical and ergonomic requirements
Die Bausteine bilden das zentrale Element der Lernspiels: sie stellen die physische Repräsentation der digitalen Informationen dar und dienen gleichzeitig als Bedienelemente. Ihre geometrische und mechanische Gestaltung beeinflusst deshalb sowohl die möglichen Konstruktionen als auch die Verständlichkeit und Zugänglichkeit der Interaktion. Wie schon in den pädagogischen Anforderungen beschrieben, müssen Form und Verbindungsstellen deshalb die vorgesehene Handhabung unmittelbar erkennen lassen und verdeutlichen, wo und wie die Bausteine miteinander verbunden werden können.

Für den Prototyp muss außerdem eine quadratische Grundfläche angestrebt werden. Jeder Baustein muss eine definierte Andockseite besitzen, über die er mit einem anderen Baustein verbunden werden kann. Die übrigen Seiten dienen als aufnehmende Verbindungsseiten, an die weitere Bausteine mit ihrer jeweiligen Andockseite angeschlossen werden können.
Dies ermöglicht verzweigte dreidimensionale Konstruktionen entlang klar definierter Richtungen und reduziert gleichzeitig den Herstellungs- und Erkennungsaufwand. Außerdem ermöglicht die quadratische Fläche die Rotation des bausteins in 90 Grad Schritten. Andere Grundflächenformen würden zusätzliche Verbindungsregeln und Gehäusevarianten erfordern, ohne für den grundlegenden Funktionsnachweis notwendig zu sein.  

Um die Konstruktion zusammenzuhalten, muss die Verbindung zwischen den Bausteinen ausreichend stabil sein, allerdings nur so stark, dass sie noch mit geringem kraftaufwand lösen lässt und ohne feinmotorisch anspruchsvolle, exakte Positionierung hergestellt werden kann. Zudem muss ein Baustein mit einer Hand sicher gegriffen und positioniert werden können. Ein Baustein sollte sich außerdem möglichst unkompliziert zusammen- und wieder auseinanderbauen lassen, ohne dabei kaputtzugehen.

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
Die technische Realisierung soll möglichst einfach, modular und wartungsarm beziehungsweise mit vertretbarem Aufwand autauschbar sein. Eine separate Stromversorgung in jedem Baustein würde Gewicht, Kosten und vor allem Wartungsaufwand erhöhen, weshalb die Energieversorgung zentral bereitgestellt werden muss und über die Verbindungen von Baustein zu Baustein weitergeleitet werden soll.

Für den grundlegenden Funktionsnachweis sollte eine Anzahl von mindestens zehn Bausteinen erreicht werden, da sie völlig ausreicht um bereits mehrteilige und räumlich verzweigte Konstruktionen zu ermöglichen. Perspektivisch soll das System aber ohne Veränderung des grundlegenden Funktionsprinzips um weitere Bausteine erweiterbar sein.

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
Der Prototyp stellt kein zertifiziertes Spielzeug dar, weshalb er ausschließlich unter Aufsicht eingesetzt werden darf. Mögliche Risiken müssen dennoch bereits konstruktiv reduziert werden und elektronische komponenten und potenziell lösbare kleinteile durch gehäuse vor direktem zugriff geschützt sein.

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

Die Kosten pro Baustein sollen nach Möglichkeit zwischen einem und drei Euro liegen. Da die Gesamtkosten zusätzlich von einer Basisstation, der Steuerelektronik und möglichen Ausgabegeräten abhängen, dient dieser Kostenbereich aber lediglich als Orientierungswert und kann aufgrund der geringen Stückzahl und des prototypischen Herstellungsverfahrens auch höher ausfallen.
    