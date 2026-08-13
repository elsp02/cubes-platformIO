#set page(numbering: "1")

= Anforderungsanalyse
== Ziel und Vorgehen
Die Anforderungsanalyse überführt die Erkenntnisse des theorethischen Hintergrunds sowie der sich aus dem sonderpädagogischen Nutzungskontext erschlossenen Prinzipien für die Gestaltung geeigneter Lernangebote in konkrete Anforderungen an den Prototyp. Ziel ist es im Sinne des konstruktionistischen Gedanken ein modulares, würfelbasiertes tangible User Interface in Form eines Lernspiels zu entwickeln, das für den Einsatz im sonderpädagogischen Förderbeich geeignet ist. 
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

FRAGE?? Szenario noch ausführlicher und detaillierter beschreiben??

Der Aufgabenumfang soll durch die Anzahl der Bausteine und die Komplexität der Zielstruktur angepasst werden können. So sollen einfache Aufgaben aus wenigen Bausteinen und überwiegend linearen Verbindungen bestehen, während anspruchsvollere Aufgaben mehrere Raumrichtungen, unterschiedliche Rotationen und verzweigte Konstruktionen umfassen können.
Perspektivisch sind weitere Aufgabenformen wie das Ergänzen unvollständiger Konstruktionen, das Auffinden fehlerhafter Verbindungen oder das freie Konstruieren denkbar.
bild

== pädagogische und interaktionstechnische Anforderungen
konstruktionismus

aus einleitung ( wie sollen aufgaben aufgebaut sein )
- aus unterschiedlichen Lernvoraussetzungen der Zielgruppe ergibt sich anforderung, dass aufgaben klar strukturiert und in ihrem Umfang begrenzt sein sollen. 
- Visualisierung von Abläufen und Handlungsschritten,
- ausreichend Zeit und Wiederholungsmöglichkeiten,
- unmittelbare und verständliche Rückmeldungen,


aus gestaltungsfaktoren für tui kinder
- Reichtum und Komplexität: unterschiedliche Niveaus der Kinder - Schwierigkeitsgrad soll durch unterschiedliche Anordnungen und Rotationen variiert werden können
  (ass Aufgaben, Schwierigkeitsgrad und Umfang der Rückmeldung möglichst an unterschiedliche Lernvoraussetzungen angepasst werden können.)
- struktuierte Offenheit in kapitel x bezug: hilfestellungen sollen abgestuft angeboten werden, ohne unmittelbar die vollständige Lösung vorzugeben


- abstraktheit: design der würfel so dass man die bedeutung erkennt (bezug zu ansätze physischer repräsentation - design motiviertes design)? - das vlt eher zu konzept (design driven ansatz)

- Bearbeitung soll durch konkrete körperliche Handlungen erfolgen. deshalb müssen Größe, Form und Verbindung der Bausteine so gestaltet werden, dass sie mit einer hand greifbar und verbindbar sind und auch bei eingeschränkter Feinmotorik möglichst sicher gehandhabt werden können (eher zu design?)

Entsprechend dem in Kapitel X erläuterten konstruktionistischen Lernverständnis muss die aktive Herstellung eines physischen Artefakts im Mittelpunkt der Lernaktivität stehen. Die Lernenden müssen die entstehende Konstruktion während der Bearbeitung betrachten, überprüfen und unmittelbar verändern können. Dadurch wird ermöglicht, dass ihre gedankliche Vorstellung in eine konkrete räumliche Struktur überführt wird, an der sich die Auswirkungen einzelner Handlungsschritte nachvollziehen lassen.

Gleichzeitig müssen die Aufgaben die unterschiedlichen Lernvoraussetzungen? der Zielgruppe berücksichtigen und damit einen klaren und überschaubaren Handlungsrahmen bieten, ohne sämtliche Handlungsschritte vollständig vorzugeben. Abläufe und Teilziele müssen nachvollziehbar dargestellt werden und dabei ausreichend Zeit für die Bearbeitung und Wiederholungsmöglichkeiten geben. 

Außerdem müssen die in Kapitel x beschriebenen Gestaltungsfaktoren berücksichtigt werden. Durch die darin beschriebene für die Zielgruppe so wichtige strukturierte Offenheit ergibt sich, dass die Kinder unterschiedliche Lösungsversuche durchführen und fehlerhafte Handlungsschritte korrigieren können sollen. Aufgaben müssen so strukturiert sein, dass das Ziel verständlich bleibt und bei Bedarf schrittweise Unterstützung abgerufen werden kann. Der Faktor Reichtum und Komplexität verlangt darüber hinaus dass sich das Lernspiel an unterschiedliche Lernniveaus anpassen kann. Dies soll dadurch realisiert werden, dass Schwierigkeitsgrad und Umfang der Rückmeldung möglichst an unterschiedliche Lernvoraussetzungen angepasst werden können, um mit dem selben grundlegenden Interaktionsprinzip für unterschiedlich anspruchsvolle Aufgaben zu realisieren. Die Bausteine dürfen nur bis zu dem Grad abstrakt gestaltet werden, dass die Bedeutung der physischen Repräsentationen (vergleiche coupling) und die durch sie ermöglichten Handlungen noch eindeutig erkennbar sind. 

== Anforderung an das Feedback
- pädagogisch und interaktionsfeedback (bezug zu feedback theorethischer hintergrund)

  pädagogisches feedback feedback unterscheidung mit ergebnisfeedback (richtig/falsch), der möglichkeit von feedforward (nächster schritt anzeigen), fortschrittsfeedback (anzeige des bereits erreichten)
  
- feedback: unmittelbar und vollständige rückmeldung notwendig, konsistent und bei bedarf wiederholbar
  feedbackform: intrinsisch und digital - über mehrere ebenen (aber nicht reizüberflutend)
  wie viel feedback: hilfestellungen sollen abgestuft angeboten werden je nach bedarf (siehe gestaltungsfaktoren tui) 

Für die selbstständige Bearbeitung einer Konstruktionsaufgabe müssen die Lernenden erkennen können, ob ihre Handlung vom System erfasst wurde und welche Bedeutung ihr innerhalb der Lernaufgabe zukommt. Entsprechend der in Kapitel X vorgenommenen Unterscheidung muss das System deshalb sowohl Interaktionsfeedback als auch pädagogisches Feedback bereitstellen können.

vlt auch zu konzept

Während das Interaktionsfeedback darüber informiert, ob eine physische Handlung technisch erkannt wurde, kann das pädagogische Feedback drei verschiedene Funktionen erfüllen: Durch ein Ergebnisfeedback wird angezeigt, ob ein Baustein beziehungsweise ein Handlungsschritt mit der Zielkonstruktion übereinstimmt, fortschrittsfeedback macht sichtbar, welche Teile der Aufgabe bereits erfolgreich bearbeitet wurden und feedforward kann darüber hinaus einen Hinweis auf einen möglichen nächsten Handlungsschritt geben. Ziel soll es sein, alle drei Feedbackfunktionen im Prototyp zu realiseren. Das Ergebnisfeedback soll dabei einem abgestuften Rückmeldekonzept folgen, sodass die ganze Lösung nicht unmittelbar sondern in Schritten vorgegeben wird.

Die Rückmeldung soll sowohl lokal an den physischen Bausteinen als auch global über die verbundene visuelle Darstellung angegeben werden können und muss unmittelbar, vollständig und konsistent erfolgen. Mehrere Ausgabemöglichkeiten können die Zugänglichkeit verbessern, müssen wenn verwendet, jedoch aufeinander abgestimmt sein. Eine gleichzeitige Häufung von Licht-, Ton- und Bewegungssignalen ist zu vermeiden, da sie von der Aufgabe ablenken oder zu einer Reizüberlastung führen kann.

== Funktionale Anforderung an die Erkennung
- digitale bedeutung ensteht n icht durch baustein sondern durch verbindung und räumliche beziehung zueinander (bezug zu mapping)
- jeder baustein muss eindeutig identifizierbar sein (damit system für feedback weiß)
- es muss erkannt werden, welche baustein emiteinader verbunden sind, über welche seiten die verbindung besteht und in welcher rotation sie zueinander ausgerichtet sind
- aus diesen infos muss röumliche Gesamtstruktur abgeleitet werden und mit einer zielstruktur verflichen werden 
- nicht eindeutig erkennbare/widersprüchliche Konfigurationen müssen als fehlerzustände erkannt werden 
- veränderungen der konstruktion sollen so erkannt und rückgemeldet werden, dass sie noch auf oyhsische manipulation bezogen werden können (1 sec)

Welche Informationen das System erfassen und verarbeiten muss, um die physische dreidimensionale Konstruktion digital zu rekonstruieren, wird von den funktionalen Anforderungen beschrieben: Im Lernspiel werden die Bausteine zu räumlichen Strukturen zusammengesetzt, deren Aufbau sowohl durch die Verbindungen als auch durch die relativen Rotationen der Bausteine bestimmt wird.
Für die digitale Erfassung und vor allem das gezielte Feedback muss deshalb jeder Baustein eindeutig identifizierbar sein. Zusätzlich muss erkannt werden, welche Bausteine miteinander verbunden sind, über welche Seiten die Verbindung besteht und wie sie zueinander ausgerichtet sind. Erst aus der Gesamtheit dieser Beziehungen kann die räumliche Konstruktion digital rekonstruiert und mit der Zielkonstruktion verglichen werden. Nicht eindeutig erkennbare beziehungsweise widersprüchliche Konfigurationen sollten als Fehlerzustände erkannt werden, um die Nutzenden nicht zu verwirren. 

TABELLE

Die maximale Reaktionszeit von einer Sekunde, die für Erfassung von Veränderungen an der Konstruktion festgelegt wurde, stellt zunächst einen Zielwert dar. Sie soll sicherstellen, dass eine Handlung und die daraus folgende Rückmeldung als zusammengehörig wahrgenommen werden.

FAZIT mit diesen Infos sollte sich eine digitale Rekonstruktion realisieren 
  
== geoemtrische und ergonomische Anforderungen
Die Bausteine bilden das zentrale Element der Lernspiels: sie stellen die physische Repräsentation der digitalen Informationen dar und dienen gleichzeitig als Bedienelemente. Ihre geometrische und mechanische Gestaltung beeinflusst deshalb sowohl die möglichen Konstruktionen als auch die Verständlichkeit und Zugänglichkeit der Interaktion. Wie schon in den pädagogischen Anforderungen beschrieben, müssen Form und Verbindungsstellen deshalb die vorgesehene Handhabung unmittelbar erkennen lassen und verdeutlichen, wo und wie die Bausteine miteinander verbunden werden können.

das eigemtlich schon konzept 
Für den Prototyp muss außerdem eine quadratische Grundfläche angestrebt werden. Diese ermöglicht räumliche Konstruktionen entlang klar definierter Richtungen und reduziert gleichzeitig den Herstellungs- und Erkennungsaufwand. Außerdem ermöglicht sie die Rotation des bausteins in 90 Grad Schritten. Andere Grundflächenformen würden zusätzliche Verbindungsregeln und Gehäusevarianten erfordern, ohne für den grundlegenden Funktionsnachweis notwendig zu sein. 

TABELLE

Um die Konstruktion zusammenzuhalten, muss die Verbindung zwischen den Bausteinen ausreichend stabil sein, allerdings nur so stark, dass sie noch mit geringem kraftaufwand lösen lässt und ohne feinmotorisch anspruchsvolle, exakte Positionierung hergestellt werden kann. Zudem muss ein Baustein mit einer Hand sicher gegriffen und positioniert werden können. Ein Baustein sollte sich außerdem möglichst unkompliziert zusammen- und wieder auseinanderbauen lassen, ohne dabei kaputtzugehen.

- Prototyp mit quadratischer grundfläche (würfel muss, andere körper kann) - einheitliche grundfläche soll herstellung erleichtern und dreidimensionale konstruktion ermöglichen
- (bausteine müssen zu dreidimensionalen Konstruktion zusammengesetzt werden können)
- jeder Baustein muss mindestens eine definierte andockseite verfügen, über die eine verbindung mit anderem baustein hergestellt werden kann. an weitere seiten sollen bausteine mechanisch anschließbar sein (später: an alle seiten andocken und verbinden)
- bausteine müssen in unterschiedlichen Rotationen zueinander verbunden werden können - 90 grad scgrutte (vier rotationen) (bezug zu erkennung)
- Baustein emüssen mit einer hand sicher gegriffen und positioniert werden (schon in pädagogsixsche anforderungen gesagt)
- Verbindungen müssen gleichzeitig stabil sein um konstruktion zusammenzuhalten und aber auch mit geringem kraftaufwand löslich sein (magnete kann - wsl eher dann konzept)
- man muss würfel gut zusammenbauen und wieder auseinanderbauen können, am besten modular sodass möglichst viele teile zu allen cubes passen

== elektrische/technische anforderungen
- technische realisierung soll möglichst einfach, modular und wartungsarm sein -> bausteine ohne batterie oder individuellen akku betrieben und zentrale energieversorgung. system soll mit möglichst geringem energiebedarf auskommen
- mindestens 8 bausteine für grundlegenden funktionsnachweis. erweiterung auf 27 für 3x3x3 anordnung (kann). muss aber ohne veränderung des grundlegenen funktionsprinzips um weitere bausteine erweiterbar sein
- system soll ohne programmierkenntnisse bedient werden unf ohne neukalibrierung (vlt verallgemeinern)
- Die Komponenten sollen überschaubar organisiert, transportierbar und bei Bedarf mit vertretbarem Aufwand austauschbar sein.???

Die technische Realisierung soll möglichst einfach, modular und wartungsarm beziehungsweise mit vertretbarem Aufwand autauschbar sein. Eine separate Stromversorgung in jedem Baustein würde Gewicht, Kosten und vor allem Wartungsaufwand erhöhen, weshalb die Energieversorgung zentral bereitgestellt werden muss und über die Verbindungen von Baustein zu Baustein weitergeleitet werden soll.

Für den grundlegenden Funktionsnachweis sollte eine Anzahl von mindestens zehn Bausteinen erreicht werden, da sie völlig ausreicht um bereits mehrteilige und räumlich verzweigte Konstruktionen zu ermöglichen. Perspektivisch soll das System aber ohne Veränderung des grundlegenden Funktionsprinzips um weitere Bausteine erweiterbar sein.


== wirtschaftliche und sichrheitsbezogene Anforderungen
- muss für woederholtes greifen uund trennen und verbinden ausreochend robust 
- elektrinische komponenten und potenziell lösbare kleinteile müssen durch gehäuse vor direktem zugriff geschützt sein
- achtung: kein zertifiziertes spielzeug

- materialkosten für prototyp nicht 100 euro überschreiten (zielwert) - kosten pro baustein 1-3 euro. die einhaltung dieser zeilwerte muss im weiteren entwicklungsprozess mit dr erforderlichen sensorik, verbindungselementen und zentralen steuereinheit abgewogen -> kosten deshalb zielwert 

Die Kosten pro Baustein sollen nach Möglichkeit zwischen einem und drei Euro liegen. Da die Gesamtkosten zusätzlich von einer Basisstation, der Steuerelektronik und möglichen Ausgabegeräten abhängen, dient dieser Kostenbereich aber lediglich als Orientierungswert und kann aufgrund der geringen Stückzahl und des prototypischen Herstellungsverfahrens auch höher ausfallen.

Der Prototyp stellt kein zertifiziertes Spielzeug dar, weshalb er ausschließlich unter Aufsicht eingesetzt werden darf. Mögliche Risiken müssen dennoch bereits konstruktiv reduziert werden und elektrinische komponenten und potenziell lösbare kleinteile durch gehäuse vor direktem zugriff geschützt sein.

== Priorisierung? 
manche anforderungen stehen im konflikt -> priorisierung


Bezüge: 
- methoden der koppling: wie und wann ist verbindung von objekt und info (stat, dynam, interaktiv) - implementierung statisch weil festgelegt dass dieser phicon diesen würfel wiederspiegelt
- art der Verbindung - was repräsentiert phicon (oder ansatz physischer repräsentation) - würfel repräsentiert würfel - anforderung design driven ansatz
- wie objekt gestaltet (design, engineering, ... driven)- anforderung design driven ansatz 
- token und constraint (die nubbel und löcher als constraint) - bei implementierung sagen
- style of mapping - mischmasch implementierung 
- feedback 
  form: intrinsisch mit formschluss
  visuell: led in würfel, auf bildschirm rot und grün
  
  interaktionsfeedback: led leuchtet (grün rot), würfel erscheint auf bidlschirm- anforderung und implementierung
  pädagogisches feedback (anforderung und implementierung): rot/grün led und bildschirm, vlt hilfefenster mit erklärung kann (multimodal kann) + feedback unterscheidung mit ergebnisfeedback (richtig/falsch), der möglichkeit von feedforward (nächster schritt anzeigen), fortschrittsfeedback (anzeige des bereits erreichten)
  dimension: lokal: cube; global: bildschirm; unmittelbar - sofort, dauerhaft: sichtbar bis korrekt ist; kontinuierlich: led und bildschirm bleibt grün/rot bzw abhängig von schwierigkeitsstufe
  belottis 5 fragen

  == Tabelle mit Anforderungen (Anforderungskatalog)