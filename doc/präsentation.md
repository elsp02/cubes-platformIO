## einführung
- für die Bachelorarbeit hatten wir eine kooperation mit der Förderschule 
    -> besucht und kinder begeisterte Lego bauer 
    -> dieses verhalten bemerkt: => VORFÜHRUNG WIRKLICH MT LEGO BAUSTEINEN
        - kinder haben eifrig gebaut auch mit anleitung von der lego app aber es hat sich immer mal wieder fehler eingeschlichen -> zu ende gebaut und erst dann fehlert gemerkt 
        - shit.... also musste das eigrif zusammengebaut kunstwerk wieder auseinandergebaut werden 
    -> dachte mir das muss doch besser gehen und dann ist das entstanden => VORFÜHRUNG WIRKLICH MIT PROBRICKS
       - kinder können bausteine zusammenbauen und - oh da hab ich wohl einen fehler gemacht - bekommen direktes feedback ob sie ihre basuene richtig zusammengebaut haben oder nicht 
    -> zusammenfassung was gebaut: ich habe also ein tangibles lernspiel bla bla bla gebaut (entweder titel ba oder von paper bzw ba einführungssatz)
    => wie das ganze funktioniert und aufgebaut ist erklär ich euch jetzt

## lerntheorethische grundlagen?? - vlt eher motivation? 
ja weil daraus ja die anforderungen oder?
- zielgruppe
- deren needs und verhalten?



## anforderungen

- am ende zsuammenfassung was es braucht

## lösung 
- to adress these requirements, modular smaart brick system that autmatically detects and digitally reconstructs physical constructions and compare them with predefined target strucutres to provide immediate feedback
- system aims to support learners with special needs in monitoring and correcting their construction process while reducing the need for continuos teacher intervention 

## state of the arts? 
passiv vs active
passiv:
    - kamera basiert
    - magnetisch
    - rfid
    nachteile (paper)
aktiv
    - 
vergleich  mit trade off 

## implementierung
systemarchitektur und bestandteile
(ablauf einer bauaufgabe)
physical design brick - animation:
    - 2 brick types - quadratische grundfläche
    - connection faces - docking und receiving face (farbe?) - deren "aufgabe"
    - machanisches connection principle - formschluss und magnete (magnete so aufleuchten lassen weil brick ja noch zusammengebaut) - wär eigentlich auch cool das erst zu nenen wenn man sieht wie sich zwei bausteine miteinander verbinden - vorteile: führung, verhindert falsches zusammenstecken -> The available connection possibilities are therefore partly conveyed through the physical design itself
    - housing - mit rahmen seiten und deckel - vorteile einfach assemble disassemble 

    - electronic

    - für das one wire eigenes kommunikationsprotokoll 

    Each mechanically defined connection is complemented by an electrical interface.
    - docking face
    - orientierungspin (dann wenn zwei miteinander verbunden zeigen welcher verbunden und der geliche dann auch für den datenaustausch )  Since electrical contacts are already required to distinguish the relative rotation at each connection, the same interfaces can also be used to transmit the resulting data. This avoids an additional wireless communication layer and creates a direct correspondence between the physical construction and its electronic connections.
    - vcc und power supply 

    receiving face 
    - pogo pins

    local electronic feedback output


    wie stromversorgung betonen?


    connection - erklärung prinzip orientierungserkennung und dann datenaustausch animation 


dann kommunikation zwischen baseplate und bricks (Data, Communication and Software Subsystem) plus zwei arten von kommunikation: einmal zur detection und einmal für feedback (aufgabe brick und baseplate firmware?)          
und dann overall kommunikation mit tree und so 
und dann zum pc (zwei abgetrennte systeme)
backend frontend kurz sagen was sie machen und aufgabentrennung 
backend
    - tree vergleich
    - info für frontend und baseplate
    - wie schaut comparison aus

visualization
pose calculation - nur nennen parent abhängig
wie schaut feedback aus
    - unterschiedliche bricks
    - 

bzw digital und local feedback 

user interface und task selection 


## was ist das coole an meinem system
- keine batterie drinnen
- one wire - nur ganz wenige kontakte
- für jedes niveau - sowohl ganz einfache als auch komplexe strukturen
- magnete - super einfach zwei baustein zu verbinden
- aufba würfel allgemein mit auch vcc als ring - wieder wenig kontakte 

# Folie 4 - Learning through physical Interaction
- Die gezeigte Situation war zunächst eine konkrete Beobachtung aus der Schule. Für die Entwicklung des Systems war aber natürlich entscheidend, ob sich daraus auch Anforderungen aus dem sonderpädagogischen und lernwissenschaftlichen Kontext ableiten lassen

- In meiner Arbeit habe ich insbesondere Lernende mit Unterstützungsbedarf im Bereich geistige Entwicklung, Lernen und Autismus Spektrum Störung in den Fokus genommen. Aufrgrund der drei Bereiche und da auch jedes Kind innerhalb eines bereichs unterschiedlich ist, spiegelt das eine relativ heterogene gruppe wieder, die unterschiedliche kognitive, wahrnehmungsbezogene und motorische voraussetzungen hat?

- trotz dieser heterogenität lassen sich aber einige gemeinsame besonders relevante Entwicklungs- und Kompetenzbereiche, die die Schüler im unterricht entwickeln sollen:
    - Aktionsplanung
    - Problemlösen
    - Erkennen von Zusammenhängen
    - Motorik und Wahrnehmung
    - Selbstständigkeit und Selbstregulation

 daraus ableitbare Gestaltungsprinzipien für Lernangebote:
    - individuelle Anpassung statt standardisierter Anforderungen
    - klare und überschaubare Aufgabenstrukturen
    - Visualisierung von Abläufen und Handlungsabfolgen
    - Ausreichend bearbeitungszeit und möglichkeit zur wiederholung
    - spielerische und handlungsorientierte aufgaben
    - rechtzeitiges und verständliches feedback
    - frderung von selbstständigkeit (und selbstwirksamkeit)
    ODER
    - räumliches denken
    - handlungsplanung
    - zunehmend selbstständiges arbeiten
    - problemlösen
    - fehlererkennung und korrektur

-> noch mehr aufeinander abstimmen und nicht alles nennen

## warum physisches bauen
- gerade physische Konstruktionsaufgaben sind dafür interessant, weil der lernende nicht nur eine abstrakte Darstellung betrachtet, sondern räumliche beziehungen tatsächlich herstellt. wenn also beispielsweise eine räumliche orientierung verstanden werden soll, wird ein objekt aktiv positioniert
    -> genau das will? die lerntheorie des constructionismus 
        - vereinfacht gesagt: learning by making 
        => der lernende setzt sich mit einem problem auseinander, indem er selbst ein sichtbares und veränderbares Artefakt erzeugt und nicht wie beim frontalunterricht einfach nur passiv berieselt und zuhören muss

### grenzen
genau hier entsteht aber auch die grenze klassischer Baumaterialien:
    - die konstruktion selbst kann nicht erkennen, ob der aktuelle zustand der aufgabe korrekt ist
    -> damit muss feedback entweder vom Lernenden selbst oder vone iner Lehrkraft kommen
    - gerade in phasen des selbstständigen arbeitesn kann eine lehrkraft aber nicht permanent jeden einzelnen handlungsschritt beobachten -> führt zu zu späteren rückmeldung

## GUIs
- digitale technologien wie tablets ermöglichen es solch ein automatisiertes feedback zu geben und auch lerninhalte multimedial darzustellen und aufgaben auf individuelle bedürfnisse anzupassen
- aber beschränkt nur auf zweidimensionalen screen etc?

## TUI
- genau an dieser stelle kommen tangible user interfaces ins spiel:
    - bei klassischen GUI sind darstellung und interaktion weitgehend getrennt - ich sehe digitale infos auf bildschirm und itneragiere beispielsweise über maus tastatur oder touch
    - bei tui werden digitale infos dagegen mit greifbaren objekten gekoppelt
        - das physische objekt hat eine doppelfunktion: es repräsentiert infos und dient gleichzeitg als interaktionselement
        -> wenn ich jetzt also beispielsweise einen physischen brick drehe, ist dieser brick nicht einfach nur ein eingabegerät wie eine maus. sondern seine tatsächliche räumliche orientierung ist selbst teil der info und ich verändere damit den zustand des digitalen systems 

=> damit kann ich also die Vorteile des physischen Bauens erhalten, also greifen, anordnen, direkt verändern, und gleichzeitig digitale funktionen ergänzen

# Folie 5 - from learning needs to design requirements
## überleitung

es konnten deshalb folgende anforderungen abgeleitet werden

## anforderungen
siehe paper

# Folie 6 - state of the art/ why exisitng smart bricks were not enough 
- 




---------------------------------

# Folie 7 - Overall System Architecture
## Überleitung
- aus diesen Anforderungen und den Grenzen bestehender Systeme ergibt sich die grundlegende Architektur von proBricks

- das technische System besteht aus drei Komponenten:
    - den (aktiven) smart bricks
    - einer Baseplate 
    - einer computer basierten/computer basierten Learning Application (frontend, backend??)
-> Die Schüler und Lehrer sind externe akteure (nicht teil des technischen Systems)

## Ablauf 
zeigen anhand von architektur diagramm
### Learning Application - start
- der Bauprozess beginnt in der Learning Application -> dort wird zunächst eine dreidimensionale Zielstruktur (vom lernenden/lehrer) ausgewählt, die der Lernende anschließend mit dem physischen Bricks nachbauen soll
- sobald die Aufgabe gestartet wird, 
    - gibt die Anwendung der Baseplate das Signal, mit der (kontinuierlichen) Erkennung der Konstruktion zu beginnen
    - und es kann mit dem Bauen begonnen werden
- das system erkennt dann kontinuierlich die aktuelle struktur und rekonstruiert und visualisiert sie darauf basierend digital und gibt feedback

### Lernende
- basierend auf dieser Visualisierung und dem Feedback vom System fügt der Lernende immer wieder neue bricks hinzu, entfernt sie wieder oder verändert ihre Position und Orientierung
    -> er interagiert beim bauen also hauptsächlich mit den physischen bricks
    
### Smart bricks
- diese sind die aktiven Bauelemente (aktiv mehr betonen? oder woanders?)
    -> sie bilden sowohl die physische Struktur 
    -> enthalten aber auch gleichzeitig eigene Elektronik und können dadurch ihre lokalen Verbindungen erfassen, miteinander kommunizieren und auch direkt feedback ausgeben

### baseplate
- die Baseplate übernimmt eine zentrale Rolle des elektronischen/technischen Systems:
    1. erstens bildet sie den festen Ausgangspunkt jeder Konstruktion und damit logisch die "root" der physischen Konstruktion/des späteren Construction Trees
    2. zweitens stellt sie die zentrale Stromversorgung bereit, indem die Energie über die Baseplate zu den bricks weitergeleitet wird
    3. drittens bildet sie die Kommunikationsschnittstelle zwischen dem physischen Brick System und der Learning Application

        -> ausgehend von der baseplate werden also die verbundenen bricks abgefragt und ihre lokalen Verbindungsinfos gesammelt
        -> (das ergebnis ist eine Beschreibung der aktuell aufgebauten Struktur)
        -> die dann über die Baseplate an die Learning application (backend?) übertragen wird

### Learning Application - backend und frontend vlt noch genauer erklären und unterscheiden
- das backend der Learning application? verarbeitet diese infos und rekonstruiert daraus in real time die physische Konstruktion digital und vergleicht es mit der ausgewählten Zielstruktur
    -> so wird der aktuelle Bauzustand dann als dreidimensionales Modell dargestellt
    -> und aus dem Vergleich live Feedback erzeugt
        - einerseits direkt in der learning application/anwendung
        - andererseits/zusätzlich auch noch in den bri?cks in form von ?LEDs?

## Kreislauf
 damit entsteht ein geschlossener physical digital interaction loop:
    - der lernende platziert/verbindet einen brick
    - das system erkennt die veränderte Konstruktion
    - die anwendung/learning application rekonstruiert und bewertet sie
    - das ergebnis wird als feedback zurückgegeben
    - und der lernende kann dann darauf reagieren und beginnen die konstruktion wieder erneut zu verändern
    -> beendet wird der Bauprozess wiederum von der Learning Application, wenn entweder die physische Konstruktion der zielversion gleicht oder der prozess abgebrochen wird 

## architekturentscheidung - weglassen wenn zu viel (S.34 in BA)
eine wichtige architekturentscheidung möchte ich hier auch nochmal kurz benennen/betonen:
    - denn getrennt?
        - baseplate und auch bricks müssen selbst nicht wissen, welche Zielstruktur gerade gebaut wird, sie erfassen ausschließlich den tatsächlichen ohysischen Zustand der Konstruktion
        - erst die Learning Application, die auch den Bauprozess ?steuert?, interpretiert diese Struktur im Kontext der aktuellen Aufgabe und entscheidet, ob etwas richtig oder falsch ist

# Folie 8 - inside a smart brick/ anatomy of a smart brick
## Überleitung
- ? wie ist jetzt aber so ein smart brick aufgebaut?
- ? ein brick ist ein aktives meachtronisches modul. das bedeutet, dass es nicht nur ein mechanisches bauelement ist, sondern selbst elektronik enthält und aktiv an der Erkennung der Konstruktion teilnimmt? - <span style="color: red;">passt nicht so richtig, vlt noch was anderes überlegen</span>

## physisch
>animation: brick huscht von der seite rein
- und tada da ist er auch schon 
- um die komplexität von Herstellung und Verbindungserkennung gering zu halten, besteht ein brick aus quadratischen Verbindungsseiten mit/und 2 funktional unterschiedlichen interface typen (= gerichtete Gestaltung) 
    - jeder brick besitzt eine "docking face", über die er selbst mit seinem "Parent" brick und damit der bestehenden Konstruktion verbunden wird
    - und ein oder mehrere "receiving faces", an die wiederum weitere child bricks angeschlossen werden können
    >animation: drehen?
    -> dadurch können mit diesem brick nicht nur lineare, sondern auch verzweigte dreidimensionale Konstruktionen aufgebaut werden 
    >animation (dreidimensionale bauten bzw würfel dafür einfliegen lassen oder so sichtbar und wieder unsichtbar machen?)

- es gibt auch noch einen zweiten brick typ, den smashed brick, der nur halb so groß wie der cube brick ist und nur über eine verfügbare reciving face verfügt 
    >animation: zusammenquetschen bzw so murphen
    -> deshalb kann man mit ihm auch nur lineare Konstruktionen bauen
    -> aber er ist trotzdem ganz cool, weil er die geometrische Vielfalt der möglichen Konstruktionen erweitert

### mechanisch
- mechanisch werden die bricks durch eine Kombination aus Magneten und geometrischer Führung verbunden:
    - die Magnete ziehen die beiden Seiten zusammen und stabilisieren die Verbindung
    >animation: magnete leuchten lassen
    - die Führungselemente (docking face: nuppel, recieiving face: mulden?) sorgen gleichzeitig dafür, dass die bricks eindeutig ausgerichtet sind 
    >animation: keine ahnung
-> hat zwei Vorteile:
    - zum einen ist weniger Feinmotorik und Kraft erforderlich, weil die bricks nicht exakt von Hand positioniert werden müssen
    - zum anderen werden dadruch auch die bricks und deren elektrische Kontakte automatisch richtig zueinander ausgerichtet (kurzschluss)
=> eine gültige Verbindung entsteht deshalb immer nur zwischen der Receiving Face eines parent bricks und der docking face eines child bricks
    >animation: keine ahnung

## housing?
- um jetzt ins innere des bricks und der ganzen elektronik zu schauen, bauen wir ihn mal auseinander /bevor wir ins innere schauen können, müssen wir den brick auseinanderbauen 
>animation: explosions view
- das auseinanderbauen hier in der visualisierung gleicht dem in der realität 
    - deckel abnehmen (ein receiving face geklebt) (nach oben)
    - übrige receiving faces rausschieben (hier schon pogo pins nennen?) (nach oben, pins aufleuchten lassen?)
    - schrauben rausdrehen um platine zu entfernen (bleibt als einziges stehen)
    - rahmen mit docking face (vlt nach unten wegschieben)
    - ?magnete?
- vorteile: außeinander bauen, nur stecken nicht viel schrauben/kleben

## elektronik (blockdiagramm?)
platine inklusive vcc konstruktion
- MCU
- PCB
- Pogo Pins - jede mechanische verbindung is complemented by an electrical interface using recessed spring loaded low resistance contacts which are arranged rotationally symmetriylly to support connections in multiple orientations
- lokale Feedback LEDs
- Stromversorgungs konstruktion - 5V (kein damage)
baseplate?
anordnung pogo pins? symmetrisch rotational? erklärung konstruktion vcc mit ringmagnet




# Folie 9 - One interface-multiple functions 
>animation baseplate - brick
für was sind die ganzen pogo pins/kontakte jetzt? (komminikation, datenaustausch)
- wenn sich jetzt also der erste brick mit der baseplate (egal kann auch brick und brick sein) verbindet passiert folgendes/wenn jetzt also der erste brick mit der baseplate verbunden wird, passiert folgendes/macht man folgendes/wird folgendes kommuniziert:
oder
- wenn sich jetzt ein brick mit seiner docking face an eine receiving face eines parent bricks verbindet, passiert folgendes:
    - das receiving face besitzt genau einen downstream child contact/pogo pin/Kommunikationskontakt
    - das docking face des child bricks besitzt dagegen vier upstream orientation contacts/pogo pins/Signalkontakte, die an den vier Ecken angeordnet sind
    - je nachdem wie der child brick jetzt also gedreht ist, trifft der einzelne downstream child contact/pogo pin/Kommunikationskontakt vom parent brick auf genau einen dieser vier Kontakte (90 grad ?)
        -> by detecting which contact is active, dadurch kann der child seine relative rotational orientation zum parent brick identifizieren
        -> und der parent erkennen, an welchen seiner receiving faces ein child verbunden ist 
        => so kann die lokale räumliche Beziehung zwischen zwei bricks bestimmt werden 
    - dieser established signalpfad (also downstream und usptream pins) wird aber nicht nur zur Orientierungserkennung verwendet, denn sobald die Verbindung erkannt wurde, wird genau derselbe elektrische kontakt anschließend für für die Kommunikation zwischen parent und child verwendet 
        -> ich benötige also keinen zusätzlichen Orientierungssensor und auch keinen separaten Datenkontakt
        -> bidirektionales single wire half duplex interface <span style="color: red;">hier oder woanders?</span>

### kommunikation zwischen zwei bricks
- da zwischen parent und child also nur diese eine signalleitung verfügbar ist, muss sie für beide Übertragungsrichtungen verwendet werden 
    -> die kommunikation ist deshalb als bidirektionale Single wire half duplex Kommunikation umgesetzt 
        -> kein normales protokoll sondern ein eigenes bit banging protocoll 
        (warum kein normales - attiny nur updi one wire möglich, wenn normales uart dann viel mehr kontakte, warum nicht one wire data protokoll übernommen - erklärung?)
        (- open drain like behavior: remains released high in its idle state and is actively pulled low only during transmission/kommunikation)
(- Kommunikation wird immer vom parent initiiert - request response prinzip)



### vcc übertragung
>animation baseplate - brick kontakte hervorheben
nicht nur daten werden ausgetauscht sondern auch vcc und ground kontakt - übertragen stromversorgung über baseplate von brick zu brick 
    -> stromversorgung: dadurch benötigt kein brick eine eigene batterie -> späterer betrieb 
<span style="color: red;">hier oder woanders?</span>

## conclusion
eine einzige brick to brick schnittstelle übernimmt damit mechanische verbindung, stromversorgung, verbindungserkennung, rotationserkennung und datenkommunikation -> thus a single brick to brick interface establishes... (s.4 von paper)


# folie 10 - from local connections to the complete structure
## Überleitung
- mit dieser schnittstelle kann ich aber zunächst nur die Beziehung zwischen zwei direkt miteinander verbundenen bricks bestimmen
- für die Rekonstruktion? benötige ich aber die Struktur der gesamten Konstruktion, wie funktioniert das also:

- beginnend bei der baseplate wird die struktur rekurisv durch eine depth first spezifische lokale parent child Kommunikation ermittelt:
    - während jedes erkennungszyklus, ermittelt jeder brick seine lokale beziehung zu seinem übergeordneten brick und fragt dann nacheinander an seinen receiving faces nach verbundenen untergeordnetetn bausteinen ab
    ODER
    - die baseplate frägt zunächst den ersten brick ab, der seine lokale beziehung zu dieser ermittelt und dann nacheinander an seinen receiving faces nach verbundenen untergeordneten bausteinen abfrägt
    - wenn an dem brick ein baustein verbunden ist, frägt dieser weiderum seine eigenen receiving faces ab und so weiter 
    - das wird dann rekursiv fortgesetzt bis zum letzten/äußersten? baustein 
    -> damit entspricht die detection einem depth first search -  ein zweig wird zunächst bis zum äußersten brick verfolgt bevir der nächste zweig/reicieving face untersucht wird

    -> ein child antwortet also nicht sofort nur mit seinen eigenen Daten sondern frägt zunächst wiederum seine children ab und sammelt so die informationen seines kompletten untergeordnetetn teilbaums - parent fragt seinen child brick nach seinem aktuellen subtree in form eines data frames/ wenn ein child seinen subtree vollständig gesammelt hat, gibt er das an seinen parent zurück

- data frame das an parent zurückgegeben wird enthält:
    - Identifier mit brick typ und individueller instanz
    - orientation - relative orientierung zum parent
    - child mask - eine bitmaske die beschreibt, welche receiving interfaces/ seiner seiten belegt sind
    - child payloads - die rekursiv drangehängten payloads von den children

dadurch wird die physikalische struktur zunächst auf einen tree und anschließend auf eine lineare datendarstellung abgebildet
-> die children werden dabei immer in einer definierten Reihenfolge angehängt
    -> dadurch kann die learning application später anhand der child mask un dieser festen reihenfolge rekonstruieren, welches child zu welchem receiving face gehört <span style="color: red;">entweder hier oder dann in backend</span>


- der parent ergänzt seine eigenen informationen und die payloads der children die an den anderen seiten verbunden sind und gibt anschliesend seinen vollständigen subtree wiederum an den eigenen parent weiter
    -> dieser prozess wiederholt sich (rekursiv?) bis zur baseplate
    -> die baseplate erhält damit am ende eine linearisierte Darstellung der vollständigen konstruktion, obwohl jeder einzelne brick nur seine lokale Umgebung kennt 




 brick = node, tree

# folie 12 - from detected tree to digital reconstruction
(- die baseplate leitet die serialisierte Konstruktion anschließend über UART? an die Learning Application (backend) weiter
- die learning application besteht in meiner implementierung aus zwei Teilen: einem pyhton basierten backen dund einem browserbasiertem java script frontend)

## backend
- die baseplate leitet die serialisierte Konstruktion anschließend über UART? an das backend der Learning Application weiter
- dort werden die daten mithilfe eines parsers wieder deserialisiert (mithilfe parser) damit die ursprünglichen parent child beziehungen wieder als digiten tree wiederhergestellt
    -> da die child payloads in einer fest definierten port/face reihenfolge übertragen und angehängt wurden, kann jedes child anhand der child mask wieder eindeutig einem receiving face seines parents zugeordnet werden 
    -> aus der linearen Nachricht entsteht damit wieder ein detected tree, der die tatsächliche physische konstruktion wiederspiegelt/repräsentiert

### comparison
- parallel dazu kennt das backend auch die vom nutzer ausgewählte target struktur, auch diese wird intern als tree dargestellt
    -> da beide strukturen also hierarhcisch gleich aufgebaut sind, kann das backend sie rekursiv miteinander vergleichen
- das comparete ergebnis ist nicht einfach nur ein globales richtig oder falsch, sondern ein dritter tree  der evaluated tree
    - jede relevante position? erhält dabei einen zustand:
        - correct: brick typ, orientierung und verbindung passt
        - wrong: brick ist vorhandern, aber er weicht von der Zielstruktur ab
        - unexpected: dort wo ein brick physisch verbunden ist, ist eigentlich überhaupt kein brick vorgesehen
        - attachable: beschreibt eine noch freie position, an der als nächster schritt gültig weitergebaut werden kann
        - blocked: eine zielposition existiert zwar, aber sie ist noch nicht erreichbar, weil beispielsweise ihr parent noch fehlt

-> und aus diesem evaluated tree entstehen anschließend zwei unterschiedliche outputs:
    - für die physische konstruktion erzeugt das backend aus den tatsächlich vorhanden bricks (correct, wwong) ein brick spezifisches feedback frame, das über die baseplate zurück zu den bricks geleitet wird - nach dem selben prinzip wie detection - und steurt die lokalen LEDs
    - für das frontend wird derselbe evaluated tree über eine websocket verbindung übertragen - diese darstellung enthält zusätzlich zu den tatsaächlich erkannten bricks (correct, wrong) auch noch die restlichen zustände (also unbelegte zielpositionen und ihre jeweiligen zustände)
    ODER
    - direktes physisches feedback an den bricks - evaluation results are converted into brick specific feedback data and transmitted back to the baseplate and the bricks
    - digitales feedback im frontend der learning application
     - digital feedback is linked to the visual representations of the bricks in the frontend and provides more differentiated information about the overall construction state

## frontend
- das frontend erhält jetzt also eine logisch ausgewertete Tree struktur
-> dieser tree enthält aber noch keine absoluten XYZ Koordinaten der bricks - beschreibt weiterhin nur Parent child beziheungen, receiving ports, brick typen, relative orientierungen

### wie werden daraus also globale Positionen für die einzelnen bricks?
lokale transformation - parent abhängig?

### rekursive transformation
-  der erste brick der mit der baseplate verbunden ist wird immer im ursprung des KS platziert
- für jede anschließende parent child verbindung kann dann eine lokale Transformation bestimmt werden -> hängt ab von
    - an welchem receiving face des parents das child hängt - Koordinatensystem
    - was für ein brick typ es ist
    - welche relative rotation der child brick hat
    -> die lokale transformation wird dann mit der globalen pose des parents kombiniert -> daraus position und orientierung des child bricks wird erhalten
-> dasselbe verfahren wird rekursiv für alle weiteren children ausgeführt

### visualisierung
- auf diese weise können aus den rein lokalen connection informationen die positionen berechnen und das frontend anschließend schließlich die gesamte Konstruktion dreidimenisonal darstellen (bild tree und digitale konstruktion)


# folie 13 - feedback
wie wird das ergebnis des konstruktions vergleich wieder an den Lernenden zurückgegeben

## digitales feedback
- in der digitalen Rekonstruktion werden die bricks je nach status unterschiedlich dargestellt
    - korrekt platziert: grün hervorheben
    - fehlerhafte oder unerwartete bricks: rot markiert
    - zusätzlich werden mögliche nächste Positionen als transparente Ghost Bricks dargestellt
    - Positionen von der zielstruktur die aufgrund der parent child struktur noch gar nicht erreichbar sind, werden dagegen nicht angezeigt 
- außerdem noch fortschrittsbalken 

## physisches feedback
- es wird ja noch ein feedback frame über die baseplate an die bricks gesendet
- dieses feedback frame enthält die IDs und die LED States der angesprochenen bricks 
    -> rekurisve weiterleitung über baseplate an alle bricks so wie bei detection erkennung 
    -> ein brick schaut ob seine ID enthalten ist und schaltet die LED je nach state entweder auf grün (korrekt platziert) oder rot
    -> wenn id nicht enthalten ist, wird LED ausgeschaltet
-> dadurch kann das feedback direkt an dem brick ausgegeben werden, auf den es sich bezieht

-> der entscheidende Vorteil ist hier die räumliche Zuordenbarkeit. der lernende muss nicht erst auf de, Display herausfinden, welcher teil der Konstruktion falsch ist, sondern erhält Rückmeldung direkt am betroffenen physischen objekt

## unterschied - tabelle
- mit dem physischen feedback lassen sich aber nur relativ einfache zustände darstellen
- das digitale feedback kann dagegen mehr kontext liefern - gesamter fortschritt, räumliche Situation und mögliche nächste Schritte  

### erweiterungen digitales feedback
- gestufter support (je nach level mehr oder weniger support)
- feedback auf anderer ebene (auditiv)
-> was steffie gesagt hat 
=> vlt in ausblick 

## Kreislauf schließen
>entweder nochmal Show oder nur sprachlich wiedergeben

- damit schließt sich der physical digital interaction loop: der lernende verändert die physische konstruktion, das sstem erkennt und rekonstruiert diese änderung, bewertet sie relativ zur Zielstruktur und gibt das ergebnis sofort weider zurück
    - der lernende kann daraufhin direlt reagieren und seine konstruktion korrigieren

# Folie 14 Evaluation


# fazit
individuelle Anpassung statt standardisierter Anforderungen!!
die requirements wieder aufgreifen?

baseplate
probrick name
5v - kein damage (elektrische hazards) 
stromversorgung: von pc über adapter zu baseplate 
vertiefung - kommt man nicht so leicht ran 
thus a single brick to brick interface establishes... (s.4 von paper)

## backup folien
- idle high erklärung
- message format
- deserialization - parser