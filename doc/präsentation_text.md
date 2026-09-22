>proBricks Namen erklärung

## Folie 4 – Lernen durch physische Interaktion

Die gezeigte Situation war zunächst eine konkrete Beobachtung aus der Schule. Für die Entwicklung des Systems war aber natürlich entscheidend, welche Anforderungen sich daraus aus sonderpädagogischer und lernwissenschaftlicher Sicht ergeben.

In meiner Arbeit stehen insbesondere Lernende mit Unterstützungsbedarf in den Bereichen geistige Entwicklung, Lernen und Autismus-Spektrum Störung im Fokus. Dadurch entsteht schon zwischen diesen drei Bereichen eine sehr heterogene Zielgruppe. Gleichzeitig unterscheiden sich aber auch die Schülerinnen und Schüler innerhalb desselben Unterstützungsbedarfs teilweise stark hinsichtlich ihrer kognitiven, wahrnehmungsbezogenen und motorischen Voraussetzungen.

„Trotz dieser Heterogenität lassen sich einige gemeinsame Herausforderungen erkennen, die sowohl das Lernen als auch den Alltag beeinflussen können. Dazu gehören zum Beispiel Schwierigkeiten bei der Handlungsplanung und beim Problemlösen, bei der Strukturierung von Aufgaben und Lernprozessen sowie Unterschiede in Aufmerksamkeit und Gedächtnis und motorischen Koordination und Wahrnehmungsverarbeitung

Daraus lassen sich einige gemeinsame Gestaltungsprinzipien ableiten. Besonders relevant für meine Arbeit waren dabei eine **individuelle Anpassung statt standardisierter Anforderungen**, klare und überschaubare Aufgabenstrukturen, ausreichend Zeit und Wiederholungsmöglichkeiten sowie **spielerische und handlungsorientierte Aufgaben**. Gerade für selbstständiges Arbeiten ist außerdem zeitnahes und verständliches Feedback wichtig.“

## physisches Bauen

Vor allem physische Konstruktionsaufgaben sind dafür interessant, weil der Lernende nicht nur eine abstrakte Darstellung betrachtet, sondern räumliche Beziehungen tatsächlich selbst herstellt.“

Wenn beispielsweise eine räumliche Orientierung verstanden werden soll, wird ein Objekt (aktiv positioniert und gedreht und damit) manilpliert. Der Lernende bleibt damit nicht in einer rein rezeptiven Rolle, wie sie beispielsweise im klassischen Frontalunterricht stärker ausgeprägt ist, sondern setzt sich aktiv mit dem Lerngegenstand auseinander.“

Das entspricht auch der Grundidee des Constructionism – vereinfacht gesagt: *learning by making*. Lernen wird dabei dadurch unterstützt, dass der Lernende selbst ein sichtbares und veränderbares Artefakt erzeugt und sich während dieses Konstruktionsprozesses mit dem Problem auseinandersetzt.“

### Grenzen klassischer Baumaterialien

Genau hier entsteht allerdings auch die Grenze klassischer Baumaterialien.“

 „Die Konstruktion selbst kann nicht erkennen, ob der aktuelle Zustand der Aufgabe korrekt ist. Die notwendige Rückmeldung muss deshalb entweder vom Lernenden selbst oder von einer Lehrkraft kommen.“

 „Gerade während Phasen selbstständigen Arbeitens kann eine Lehrkraft aber nicht jeden einzelnen Handlungsschritt unmittelbar beobachten. Dadurch kann Feedback verzögert erfolgen und ein Fehler möglicherweise erst erkannt werden, nachdem bereits darauf weitergebaut wurde.“

## Digitale Technologien

Digitale Technologien wie Tablets bieten hier andere Möglichkeiten. Sie können Lerninhalte multimedial darstellen, Aufgaben an individuelle Bedürfnisse anpassen und automatisiertes Feedback bereitstellen.“

So etwas nennt man Graphical User Interface: hier findet die Interaktion meist auf einem zweidimensionalen Bildschirm statt und ist weitgehend auf Touch- oder Mauseingaben beschränkt. Ich sehe zum beispiel einen würfel auf einem Bildschirm und interagiere über Maus, Tastatur oder Touch um etwas auszuwählen. Eingabehandlung und die Darstellung digitaler Informationen sind voneinander getrennt,

Auch das ist natürlich aktive Interaktion, bietet aber nicht dieselbe haptische und räumlich differenzierte Erfahrung wie die Manipulation dreidimensionaler Objekte.“

Gerade die physische und motorische Interaktion mit dem Lerngegenstand wird dadurch deutlich reduziert.“


## TUI
Genau an dieser Stelle kommen Tangible User Interfaces ins Spiel.“

Bei einem Tangible User Interface gibt es ein reales physisches Objekt, das mit digitaler Information gekoppelt ist.

Dieses Objekt hat zwei Funktionen gleichzeitig:
Es repräsentiert einen Zustand oder eine Information.
Durch seine Manipulation veränderst du diesen Zustand.

Wenn ich also beispielsweise einen Brick drehe, ist dieser Brick nicht einfach nur ein Eingabegerät wie eine Maus. Seine tatsächliche räumliche Orientierung ist selbst die Information – und indem ich ihn drehe, verändere ich gleichzeitig den digitalen Zustand des Systems.“

=> Damit lassen sich die Vorteile des physischen Bauens – also Greifen, räumliches Anordnen und direktes Verändern – mit den Möglichkeiten digitaler Systeme wie automatischer Erkennung, Visualisierung und Feedback verbinden.“

Und Übergang:

(Aus genau dieser Kombination ergeben sich dann die konkreten Designanforderungen an das System.“)

# Folie 5 - Designanforderungen
Aus diesen pädagogischen Überlegungen, den Prinzipien Tangible User Interfaces und den praktischen Randbedingungen für den Einsatz im Schulalltag habe ich anschließend diese 7 Anforderungen an das System abgeleitet 

### 1. Funktionale Anforderungen

Auf funktionaler Ebene muss das System zunächst **räumliches Bauen** ermöglichen. Das bedeutet nicht nur einfaches Stapeln, sondern ich wollte dreidimensionale Strukturen mit unterschiedlichen Verbindungsrichtungen und relativen Orientierungen bauen können

Gleichzeitig muss die physische Konstruktion **automatisch erfassbar** sein. Das System muss also erkennen können, wie die Bricks miteinander verbunden und orientiert sind, damit daraus eine digitale Rekonstruktion erzeugt und diese anschließend mit einer Zielstruktur verglichen werden kann.“

### 2. Anforderungen an die Interaktion

Außerdem ist eine **zugängliche Interaktion** für die Schülerinnen wichtig. Das Verbinden und Manipulieren der Bricks sollte möglichst intuitiv sein (und kein technisches vorwissen erfordern). Da es passieren kann dass schüler - feinmotorik ->  wenig feinmotorische Präzision und es fehlt noch was

Gleichzeitig müssen die Verbindungen aber **zuverlässig manipulierbar** sein: Sie sollen sich einfach herstellen und wieder lösen lassen, dabei aber stabil bleiben dass sie nicht auseinanderfallen beim zusammenstecken

Die dritte Anforderung ergibt sich direkt aus dem Problem, das ich am Anfang gezeigt habe: Das System soll **unmittelbares Feedback** geben. Dieses Feedback muss nicht nur schnell, sondern auch verständlich und eindeutig der entsprechenden Handlung beziehungsweise dem betroffenen Brick zuordenbar sein. 

### 3. Anforderungen an den Schulalltag

Zusätzlich reicht es natürlich nicht, wenn ein System technisch funktioniert. Es muss auch im Schulalltag praktikabel sein.“

Deshalb sollte der **Vorbereitungs- und Wartungsaufwand möglichst gering** sein. Ein System, das vor jeder Verwendung aufwendig kalibriert werden muss oder bei dem regelmäßig viele einzelne Komponenten geladen werden müssen, wäre für den vorgesehenen Einsatz wenig geeignet.

Und  naütrlich ganz wichtig: **Sicherheit und Robustheit** müssen berücksichtigt werden. Die Bricks werden wiederholt gegriffen, verbunden und getrennt. Mechanische und elektrische Risiken müssen deshalb möglichst gering gehalten werden.“ 

Diese sieben Anforderungen bilden damit die Leitlinie für die weitere Entwicklung. (Die mechanischen, elektronischen und softwareseitigen Entscheidungen, die ich gleich zeige, lassen sich jeweils auf eine oder mehrere dieser Anforderungen zurückführen)


# Folie 6 - bestehende Systeme
Für die automatische Erkennung physischer Konstruktionen gibt es grundsätzlich zwei Ansätze: passive und aktive Brick-Systeme.

## passiv
Bei passiven Systemen befinden sich in den Bricks selbst keine aktiven Verarbeitungs- oder Kommunikationskomponenten. Die Konstruktion wird stattdessen durch ein externes Erkennungssystem erfasst. (Dies kann auf unterschiedlicher Weise passieren, zum beispiel mithilfe von kameras, rfid chips oder kapazitiven methoden)

## aktiv
„Bei aktiven Bricks befindet sich dagegen Elektronik direkt in jedem Baustein. Die einzelnen Bricks können dadurch selbst Informationen über ihre lokalen Verbindungen erfassen und an das Gesamtsystem weitergeben.“

### trade off
die Wahl zwischen passiven und aktiven Bausteinen stellt daher einen Kompromiss zwischen Einfachheit auf Baustein-Ebene und den
Erfassungs- und Interaktionsmöglichkeiten auf System-Ebene dar. 

Da es mir schien als ob ich mit passiven systemen nicht meine anforderunen erreichen werde, entschied ich mich für aktive bausteine. 

Drei bestehende Systeme waren für die Entwicklung besonders relevant, weil sie jeweils einzelne Prinzipien zeigen, die ich für proBricks aufgegriffen habe.

- i-Cube zeigt, dass sich mithilfe symmetrisch angeordneter induktiver Empfänger direkt an den Bausteinflächen sowohl die verbundene Fläche als auch die relative Rotation zwischen zwei Bricks erfassen lassen.

- roBlocks zeigt, dass sowohl die Kommunikation als auch die Energieversorgung über die verbundene Bausteinstruktur selbst erfolgen können. Dadurch sind keine einzelnen Batterien in jedem Brick notwendig und die Struktur bildet gleichzeitig das Kommunikationsnetzwerk.

- ActiveCube zeigt schließlich, wie sich aus lokalen Verbindungsmeldungen einzelner Bricks eine globale Baumstruktur der gesamten Konstruktion aufbauen lässt. Die einzelnen Bricks melden dabei ihre Identität und die jeweils verbundenen Flächen, und der Host setzt diese Informationen zur Gesamttopologie zusammen.

„Keines dieser Systeme kombiniert diese Prinzipien allerdings genau in der Form, die sich aus meinen Anforderungen aus Nutzbarkeit im Klassenzimmer, dredimensionalem Bauen, Barrierefreiheit und automatisiertem Feedback für die Sonderpädagogik ergeben

Und so entstand deshalb probricks, eine aktive brick architektur, die die phyische Konstruktion selbst erfassbar macht und dabei mit möglichst wenig externer Infrastruktur und entsprechend geringem Wartungsaufwand auskommt


# Folie 7 - Systemarchitektur??
„Das technische System besteht aus drei zentralen Komponenten: den aktiven Smart Bricks, einer Baseplate und einer computerbasierten Learning Application (aus backend und frontend). Lernende und Lehrkräfte interagieren mit dem System, sind aber als externe akteure nicht teil des technischen Systems

Der Bauprozess beginnt in der Learning Application. Dort wird zunächst eine dreidimensionale Zielstruktur ausgewählt, die anschließend mit den physischen Bricks nachgebaut werden soll.

Sobald die Aufgabe gestartet wird, gibt die Learning Application der Baseplate das Signal mit der kontinuierlichen Erfassung der Konstruktion zu starten und es kann mit dem Bauen begonnen werden. 

### Smart bricks
- sind die aktiven Bauelemente (aktiv mehr betonen? oder woanders?)
    -> sie bilden sowohl die physische Struktur 
    -> enthalten aber auch gleichzeitig eigene Elektronik und können dadurch Verbindungen erfassen, miteinander kommunizieren und auch direkt feedback ausgeben.

### baseplate
- die Baseplate übernimmt eine zentrale Rolle des elektronischen/technischen Systems:
    1. erstens bildet sie den festen Ausgangspunkt jeder Konstruktion
    3. bildet sie die Kommunikationsschnittstelle zwischen dem physischen Brick System und der Learning Application

### Learning application
„Die erkannte Konstruktion wird also anschließend an die Learning application weitergeleitet. Dort wird sie mit der Zielstruktur verglichen und digital rekonstruiert

so wird der aktuelle Bauzustand dann als dreidimensionales Modell dargestellt
    -> und aus dem Vergleich live Feedback erzeugt für die bricks und die learning application zum ausgeben
        (- einerseits direkt in der learning application/anwendung
        - andererseits/zusätzlich auch noch in den bricks)

Auf Grundlage dessen kann der Lernende seine Konstruktion entsprechend verändern. also falsche bricks anders verbinden oder neue bricks hinzufügen“

Dadurch entsteht ein kontinuierlicher physisch-digitaler Kreislauf aus Bauen, Erkennen, Vergleichen, Feedback und Anpassen

# folie 8 - Ein blickk ins innere


# folie 9 - eine schnittstelle - mehrere Funktionen
für was sind die ganzen Pogo Pins denn jetzt aber eigentlich?

## lokale räumliche beziehung zw. 2 bricks 
Wenn sich ein Child-Brick mit seiner Docking Face an eine Receiving Face eines Parent-Bricks anschließt, treffen zwei unterschiedliche elektrische Schnittstellen aufeinander.

Die Receiving Face des Parents besitzt einen einzelnen Kommunikationskontakt. Auf der Docking Face des Child-Bricks befinden sich dagegen vier Orientierungskontakte, die den vier möglichen Rotationen in 90-Grad-Schritten entsprechen.

Je nachdem, wie der Child-Brick gedreht angebracht wird, trifft der einzelne Kontakt des Parents auf genau einen dieser vier Kontakte.

Der Child-Brick kann dadurch erkennen, welcher seiner Orientierungskontakte aktiv ist und daraus seine relative Rotation zum Parent bestimmen.

Der Parent kennt gleichzeitig die verwendete Receiving Face, weil er seine Schnittstellen nacheinander gezielt abfragt. **Aus Receiving Face und relativer Rotation lässt sich damit die lokale räumliche Beziehung zwischen zwei Bricks eindeutig beschreiben.**

Dieser Kontakt wird aber nicht nur zur Orientierungserkennung verwendet, denn sobald die Verbindung hergestellt ist, wird derselbe elektrische Signalpfad anschließend auch für die Datenkommunikation zwischen Parent und Child genutzt.

**Dadurch benötige ich weder einen zusätzlichen Orientierungssensor noch eine separate Datenleitung**

## weitere Kommunikation
Da zwischen Parent und Child nur diese eine Signalleitung zur Verfügung steht, muss sie abwechselnd für beide Übertragungsrichtungen verwendet werden. Die Kommunikation ist deshalb als bidirektionale Single-Wire-Half-Duplex-Kommunikation umgesetzt.

Die Kommunikation folgt dabei einem Request-Response-Prinzip und wird jeweils vom Parent initiiert -> vlt eher FOLIE 10

## Stromversorgung
ein weiterer großer Vorteil des Designs:
„Über dieselbe physische Face to tace Schnittstelle werden außerdem 5 Volt und Ground übertragen.“

„Die Baseplate speist die Konstruktion zentral, und die Versorgung wird anschließend von Brick zu Brick weitergegeben. Dadurch benötigt kein einzelner Brick eine eigene Batterie.

## Conclusio
eine einzige brick to brick schnittstelle übernimmt damit mechanische verbindung, stromversorgung, verbindungserkennung, rotationserkennung und datenkommunikation 
-> reduces the need for additional sensing components and avoids external sensing
infrastructure

---
lokale räumliche Beziehung zw 2 bricks
    - orientierungsbestimmung
    - belegte Receiving faces 
-> nur eine ? nötig

- kommunikation als bidirektionale Single-Wire-Half-Duplex Kommunikation


# folie 10 - von lokaler Verbindung zur Gesamtstruktur 
mit dieser schnittstelle kann ich aber zunächst nur die Beziehung zwischen zwei direkt miteinander verbundenen bricks bestimmen. Für die digitale Rekonstruktion brauche ich aber natürlich die Struktur der gesamten Konstruktion.

„Ausgangspunkt jedes Erkennungszyklus ist die Baseplate als Wurzel der Konstruktion. Sie fragt zunächst den ersten angeschlossenen Brick ab.“

„Dieser Brick kennt seine lokale Beziehung zur Baseplate und überprüft anschließend seine Receiving Faces nacheinander in einer fest definierten Reihenfolge.“

„Wird an einer dieser Seiten ein Child-Brick gefunden, antwortet dieser nicht einfach sofort nur mit seinen eigenen Daten. Stattdessen wird er selbst zum parent und fragt zunächst wiederum seine eigenen Receiving Faces nach weiteren angeschlossenen child Bricks ab

„Findet er dort erneut einen Brick, setzt sich dieser Vorgang rekursiv fort.“

„Dadurch wird ein Zweig der Konstruktion zunächst bis zum äußersten Brick verfolgt, bevor zum nächsten freien Receiving Face des vorherigen Parents zurückgekehrt wird.“

„Die Erkennung entspricht damit einem Depth-First Search, also einer Tiefensuche.“

„Erst wenn ein Brick seinen vollständigen untergeordneten Teilbaum erfasst hat, gibt er diese Information an seinen Parent zurück.

## serialisierung
„Damit dieser Teilbaum über die einzelne Kommunikationsleitung übertragen werden kann, muss er in eine lineare Datenstruktur überführt werden.“

„Jeder Brick erzeugt dafür eine Node-Beschreibung mit vier wesentlichen Informationen:
seinem Identifier, der Brick-Typ und individuelle Instanz enthält,
seiner relativen Orientierung zum Parent,
einer Child Mask, die angibt, welche Receiving Faces belegt sind,
und den Payloads seiner Children.“

„Die Child-Payloads werden dabei immer in einer fest definierten Reihenfolge der Receiving Faces angehängt.“

„Dadurch entsteht eine Preorder-Serialisierung: Zuerst stehen die Informationen des aktuellen Parent-Nodes, danach folgen nacheinander die vollständigen serialisierten Teilbäume seiner Children.“

„Der Parent ergänzt also seine eigenen Informationen um die bereits vollständig gesammelten Child-Payloads und gibt anschließend seinen gesamten Subtree wiederum an seinen eigenen Parent weiter.“

„Dieser Prozess wiederholt sich rekursiv bis zur Baseplate.“

„Die Baseplate erhält damit am Ende eine linearisierte Darstellung der vollständigen Konstruktion, obwohl jeder einzelne Brick selbst nur seine lokale Umgebung kennt.“


# folie 11 - probricks name
„Die globale Topologie entsteht also ausschließlich durch das Zusammenführen lokaler Verbindungsinformationen. Jeder Brick kennt nur seine unmittelbare Umgebung, gemeinsam kann das System aber seine gesamte physische Struktur bestimmen.“

„Und genau daher kommt übrigens auch der Name proBricks. Er ist an den Begriff der Propriozeption angelehnt – also die Fähigkeit, den eigenen Zustand beziehungsweise die eigene räumliche Konfiguration wahrzunehmen.“

„Übertragen auf proBricks bedeutet das: Die Konstruktion wird nicht von einer externen Kamera beobachtet, sondern gewinnt die Information über ihre eigene Struktur aus den Verbindungen zwischen den Bricks selbst.“

(proBricks
proprioception + bricks

darunter klein:

Erfassung der eigenen physischen Struktur aus lokalen Verbindungen)

# folie 12 - von erkanntem Baum zur digitalen Rekonstruktion

Nachdem die Baseplate die vollständige Konstruktion als serialisierte Datenstruktur erhalten hat, wird diese an die Learning Application weitergeleitet.“

Die Learning Application besteht in meiner Implementierung aus einem Python-basierten Backend und einem browserbasierten JavaScript-Frontend.

die baseplate leitet die serialisierten Konstruktionsdaten über UART? an das backend der Learning Application weiter. 

AUS SERIALISIERTEM TREE MIT XXX WIRD DETECTED TREE :::
Dort werden die empfangenen Daten zunächst wieder deserialisiert. Ein rekursiver Parser liest die einzelnen Nodes aus und stellt daraus die ursprünglichen Parent-Child-Beziehungen wieder her.

Da die Child-Payloads zuvor in einer fest definierten Reihenfolge übertragen wurden, kann das Backend mithilfe der Child Mask wieder eindeutig bestimmen, welches Child an welchem Receiving Face seines Parents angeschlossen ist.

Aus der linearen Nachricht entsteht damit wieder ein Detected Tree, der die tatsächlich erkannte physische Konstruktion beschreibt.

### Vergleich
Parallel dazu kennt das Backend die zuvor ausgewählte Zielstruktur, die ebenfalls als hierarchischer Tree dargestellt wird. Beide Trees können deshalb rekursiv miteinander verglichen werden.

Dabei werden für jede Position unter anderem der Brick-Typ, das verwendete Receiving Face und die relative Orientierung betrachtet. Die individuelle Brick-ID ist für die Bewertung nicht relevant, da Bricks desselben Typs innerhalb einer Aufgabe austauschbar sind.“

Das Ergebnis dieses Vergleichs ist der sogenannte Evaluated Tree. Dabei erhält jede relevante Position einen von fünf Zuständen.

- **Correct** bedeutet, dass Brick-Typ, Verbindung und Orientierung der Zielstruktur entsprechen.

- **Wrong** bedeutet, dass an dieser Position zwar ein Brick vorhanden ist, dieser aber von der erwarteten Struktur abweicht – beispielsweise durch einen falschen Typ oder eine falsche Orientierung.

- **Unexpected** beschreibt dagegen einen Brick, der vorhanden ist, obwohl an dieser Stelle überhaupt kein Brick vorgesehen ist.

Zusätzlich gibt es zwei Zustände für noch unbelegte Zielpositionen: 
- **Attachable** bedeutet, dass an dieser Position aktuell gültig weitergebaut werden kann. 
- **Blocked** bedeutet, dass die Position zwar zur Zielstruktur gehört, momentan aber noch nicht erreichbar ist – beispielsweise weil der notwendige Parent noch fehlt.

### Output Repräsentation
Aus diesem gemeinsamen Evaluated Tree werden anschließend zwei unterschiedliche Output-Repräsentationen erzeugt:.

Für die **physischen Bricks** erzeugt das Backend brick-spezifische Feedbackdaten für die tatsächlich vorhandenen Bausteine. Diese werden über die Baseplate zurück an die Konstruktion übertragen und später für das lokale LED-Feedback verwendet.

Für das **Frontend** wird der Evaluated Tree dagegen als JSON übertragen. Diese Repräsentation enthält sowohl die tatsächlich erkannten Bricks als auch noch unbelegte Zielpositionen und deren jeweiligen Bewertungszustand.

### Übergang
Das Frontend enthält jetzt also eine logisch ausgewertete Tree Struktur
-> Damit ist die Konstruktion zwar logisch vollständig beschrieben und bewertet, allerdings enthält dieser Tree noch keine absoluten XYZ-Koordinaten

## Frontend
Die eigentliche räumliche Rekonstruktion findet deshalb im Frontend statt.“

### Transformation
„Der erste Brick an der Baseplate bildet dabei den Ursprung der Darstellung. Für jede weitere Parent-Child-Verbindung wird anschließend eine lokale Transformation bestimmt.“

Diese setzt sich aus einer Translation und einer Rotation zusammen. Die **Translation**, also wohin der Child-Brick relativ zu seinem Parent gesetzt wird, ergibt sich aus dem Receiving Face, an dem er angeschlossen ist, sowie aus der Geometrie beziehungsweise dem Brick-Typ der beiden beteiligten Bricks. Ein Cube-Brick sitzt dadurch beispielsweise weiter von seinem Parent entfernt als ein halbhoher Smashed-Brick.

Die **Rotation** setzt sich wiederum aus zwei Anteilen zusammen: Zum einen muss der Child-Brick überhaupt erst so gedreht werden, dass er zu dem jeweiligen Receiving Face passt – das ist durch die Geometrie fest vorgegeben. Zum anderen kommt die tatsächlich erkannte relative Orientierung der beiden Bricks zueinander hinzu, also die zusätzliche Verdrehung um 0, 90, 180 oder 270 Grad.


„Diese lokale Transformation wird anschließend mit der bereits bekannten globalen Pose des Parent-Bricks kombiniert. Dadurch erhält das Child seine eigene globale Position und Orientierung.“

„Dieser Vorgang wird rekursiv für alle weiteren Children wiederholt.

### Conslusio
Auf diese Weise kann also aus den ursprünglich rein lokalen Verbindungsinformationen so Schritt für Schritt die vollständige dreidimensionale Rekonstruktion der physischen Konstruktion dargstellt werden.

# Folie 13 - Feedback
Wie wird jetzt aber nicht nur die Konstruktion visulaisiert sondern auch feedback an den Lernenden zurückgegeben?

Dafür verwendet proBricks zwei Feedbackkanäle: physisches Feedback direkt an den Bricks und digitales Feedback in der Learning Application.

## digitales Feedback
beim digitalen feedback im browser zeigt schon die Visualisierung selbst dem Lernenden, dass eine physische Veränderung vom System erkannt wurde.
Zusätzlich werden die Bricks entsprechend ihrer Bewertung dargestellt: korrekt platzierte Bricks werden grün hervorgehoben, falsche oder unerwartete Bricks rot.

Die digitale Darstellung kann darüber hinaus aber noch zusätzliche Informationen geben. Positionen mit dem Status ATTACHABLE, an denen aktuell sinnvoll weitergebaut werden kann, werden als transparente Ghost Bricks dargestellt.“

Positionen mit dem Status BLOCKED, die innerhalb der Zielstruktur zwar existieren, momentan aber noch nicht erreichbar sind, werden dagegen zunächst ausgeblendet.

Zusätzlich zeigt ein Fortschrittsbalken, wie weit die Zielkonstruktion bereits korrekt aufgebaut wurde.

## physisches Feedback
Für das physische Feedback erzeugt das Backend aus dem Evaluated Tree ein brick-spezifisches Feedback-Frame.“

Dieses enthält die IDs der angesprochenen Bricks und den jeweils zugehörigen LED-Zustand. Das Frame wird über die Baseplate in die Konstruktion zurückgesendet und – nach einem ähnlichen Prinzip wie bei der Strukturerkennung – rekursiv durch die verbundenen Bricks weitergeleitet.

Jeder Brick überprüft dabei, ob seine eigene ID im Feedback enthalten ist. Ist der Brick korrekt platziert, leuchtet seine LED grün; bei einer fehlerhaften Platzierung rot. Ist keine Rückmeldung für den Brick vorgesehen, bleibt die LED ausgeschaltet.

„Der wesentliche Vorteil dabei ist die räumliche Zuordenbarkeit: Die Rückmeldung erscheint direkt an dem physischen Objekt, auf das sie sich bezieht. Der Lernende muss also nicht erst auf einem Bildschirm herausfinden, welcher Teil der Konstruktion betroffen ist.

## feedbacktypen
### phyisisch
Bei den physischen LEDs liegen Interaktions (also dass das system etwas erkannt hat)- und Ergebnisfeedback (feedback zum ergebnis der handlung) sehr nah zusammen: Das Aufleuchten bestätigt einerseits, dass der Brick erkannt wurde, und die Farbe bewertet gleichzeitig seine Platzierung.

### digital
„Diese verschiedenen Darstellungsformen erfüllen dabei unterschiedliche Funktionen.“

„Die Darstellung eines neu erkannten Bricks ist zunächst Interaktionsfeedback: Sie bestätigt dem Lernenden, dass seine physische Handlung vom System erkannt wurde.“

„Die farbliche Bewertung als korrekt oder falsch ist dagegen Ergebnisfeedback, da sie die ausgeführte Handlung beziehungsweise den aktuellen Zustand bewertet.“

„Die Ghost Bricks gehen noch einen Schritt weiter: Sie zeigen eine mögliche nächste Handlung und bilden damit Feedforward.“

„Der Fortschrittsbalken zeigt schließlich den Gesamtfortschritt der Aufgabe und stellt damit Fortschrittsfeedback dar.“

### unterschied
„Die beiden Kanäle haben damit bewusst unterschiedliche Stärken.“

„Das physische Feedback ist vor allem lokal, unmittelbar und einfach. Die Rückmeldung befindet sich direkt am betroffenen Objekt und muss nicht erst einer Stelle in der Konstruktion zugeordnet werden.“

„Das digitale Feedback kann dagegen deutlich differenzierter sein und mehr Kontext liefern. Neben der reinen Bewertung kann es den Gesamtfortschritt darstellen und sogar Hinweise auf mögliche nächste Schritte geben.“

„Beide Kanäle ergänzen sich damit: Die Bricks liefern eine schnelle und räumlich eindeutig zuordenbare Rückmeldung, während die digitale Anwendung zusätzliche Informationen und Unterstützung bereitstellen kann.“

# folei 14 - interaktionskreislauf
damit entsteht ein geschlossener physical digital interaction loop:
    - der lernende platziert/verbindet einen brick
    - das system erkennt die veränderte Konstruktion
    - die anwendung/learning application rekonstruiert und bewertet sie
    - das ergebnis wird als feedback zurückgegeben
    - und der lernende kann dann darauf reagieren und beginnen die konstruktion wieder erneut zu verändern
    -> gestartet und beendet wird der Bauprozess von der Learning Application, wenn entweder die physische Konstruktion der zielversion gleicht oder der prozess abgebrochen wird 

# folie 15 - evaluation
Es fand eine Evaluation als formative qualitative Evaluation mit mehreren Schülerinnen und Schülern einer Förderschule im 6. Besuchsjahr aufgebaut und fand über ungefähr zwei Stunden im normalen Schulumfeld statt.

Ziel war dabei vor allem zu untersuchen, ob die grundlegende Interaktion mit den Bricks und der Learning Application für die Zielgruppe verständlich und zugänglich ist.

Die Schülerinnen und Schüler konnten unterschiedliche Zielstrukturen auswählen, diese in der Anwendung betrachten und anschließend mit den physischen Bricks nachbauen. Beobachtet wurde dabei unter anderem, wie sie mit den Bricks umgehen, wie gut sie die digitale Darstellung auf die physische Konstruktion übertragen können und wie sie mit unterschiedlich komplexen Aufgaben zurechtkommen.

Denn eine wichtige Einschränkung war, dass die elektronische Konstruktionserkennung zu diesem Zeitpunkt noch nicht zuverlässig genug war. Deshalb konnten der vollständige Detection- und Feedback-Loop und insbesondere das automatische Feedback nicht mit den Kindern evaluiert werden.“

## Ergebnise
Grundidee der Reconstruction Task verstanden
Aktive Beteiligung und Neugier
Leichtes und verständliches Zusammenbauen
Eigenständiges Ausprobieren
unterschiedliche Schwierigkeitsgrade nutzbar
spontane gegenseitige Unterstützung

teilweise Hilfestellung bei Orientierung, Brick-Typ und Startpunkt notwendig
Verbesserungen im Frontend Interface nötig
nicht Wurf sicher :)


### positiv
„Was ich an der Evaluation besonders spannend fand, war, dass die Kinder die Grundidee sehr schnell verstanden und sich wirklich auf die Aufgabe eingelassen haben. Sie haben unterschiedliche Strukturen ausgewählt, verschiedene Lösungswege ausprobiert und ihre Konstruktionen immer wieder verändert. 

Auch leichtes zusammenbauen durch magnete geflutscht - feinmotorik

„Besonders interessant war, dass das Konzept bereits funktioniert hat, obwohl die automatische Detection und das Feedback zum damaligen Zeitpunkt noch nicht eingesetzt werden konnten. Das zeigt für mich, dass der eigentliche Wert nicht allein in der Technik liegt, sondern in der Kombination aus einer verständlichen Aufgabe, einer digitalen Vorlage und einem selbst aufgebauten physischen Ergebnis.“

„Außerdem konnten über unterschiedlich komplexe Zielstrukturen Kinder mit verschiedenen Voraussetzungen innerhalb desselben Spielprinzips arbeiten. Und etwas, das gar nicht explizit vorgesehen war, ist spontan entstanden: Die Kinder tauschten sich über ihre Lösungen aus und unterstützten sich gegenseitig. Teilweise halfen sicherere Schülerinnen und Schüler den anderen beim Weiterbauen.

### negativ
„Die Evaluation zeigte aber auch konkrete Schwachstellen. Teilweise war Unterstützung bei Startpunkt, Brick-Typ und Orientierung nötig.
Das Frontend kann auch noch inklusiver und informationsreicher gestaltet werden. -> next steps
Außerdem ist die mechanische Robustheit für stärkere Stoß- oder Wurfbelastungen noch nicht ausreichend.“

## Evaluation Designanforderungen
„Wenn ich zum Abschluss noch einmal auf die sieben zentralen Designanforderungen zurückblicke, zeigt sich dass das entwickelte Konzept alle sieben grundsätzlich adressiert.“

„Funktional ermöglicht das System dreidimensionale Konstruktionen mit anpassbarer Aufgabenkomplexität und kann den aktuellen Konstruktionszustand automatisch erfassen, ohne dafür eine externe Kamera oder andere Tracking-Infrastruktur zu benötigen.“

„Bei der Interaktion wurden insbesondere die mechanisch geführten und magnetischen Verbindungen positiv bewertet. Sie erleichtern das Positionieren und sorgen gleichzeitig für eine ausreichend eindeutige Verbindung. Das lokale und digitale Feedback ermöglicht außerdem, Fehler unmittelbar und dem betroffenen Teil der Konstruktion zugeordnet zurückzumelden.“

„Für den Schuleinsatz reduziert vor allem die zentrale Stromversorgung und die integrierte Erkennung in den Bricks den Betriebsaufwand. Geschlossene Elektronik, versenkte Kontakte und die 5-Volt-Versorgung adressieren gleichzeitig Sicherheit und bereits gute aber dennoch verbesserungswürdige Robustheit.“

ABER
(„Diese Bewertung zeigt allerdings zunächst, dass das Design für den vorgesehenen Kontext geeignet erscheint. Sie belegt noch nicht, dass dadurch tatsächlich Lernleistungen verbessert oder Lehrkräfte messbar entlastet werden.“)

# folie 16 - was zeigt der prototyp


# folie 17 - mögliche nächste Schritte
Evaluation des vollständigen Systems
Differenzierte Hilfestellung
Multimodales Feedback
Lernmöglichkeiten erweitern
System für den Schuleinsatz vereinfachen

„Als nächster Schritt sollte das vollständige System noch einmal mit den Schülerinnen und Schülern evaluiert werden. Dabei wäre besonders interessant zu untersuchen, ob das automatische Feedback tatsächlich dabei hilft, Fehler früher und selbstständiger zu erkennen und zu korrigieren.

Darauf aufbauend möchte ich die Unterstützung stärker differenzieren. Das System könnte zunächst nur darauf hinweisen, dass etwas nicht stimmt, und erst bei Bedarf konkretere Hilfestellungen geben.

Zusätzlich sollte das Feedback multimodaler und zugänglicher werden, zum Beispiel durch gesprochene Hinweise, eine Vorlesefunktion oder eine stärker bildbasierte Darstellung.

Außerdem lässt sich das System um weitere Lern- und Kollaborationsformen erweitern – also beispielsweise Fehler finden, Konstruktionen ergänzen oder Aufgaben, bei denen ein Kind baut und ein anderes die Konstruktion nachbaut.

Und schließlich könnte das technische Setup für den Schuleinsatz noch vereinfacht werden, indem der separate Computer durch ein ESP32-basiertes Gateway ersetzt und die Anwendung direkt drahtlos mit einem Tablet verbunden wird.“