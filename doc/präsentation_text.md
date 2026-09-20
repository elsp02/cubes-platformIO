>proBricks Namen erklärung

## Folie 4 – Lernen durch physische Interaktion

Die gezeigte Situation war zunächst eine konkrete Beobachtung aus der Schule. Für die Entwicklung des Systems war aber natürlich entscheidend, welche Anforderungen sich daraus aus sonderpädagogischer und lernwissenschaftlicher Sicht ergeben.

In meiner Arbeit stehen insbesondere Lernende mit Unterstützungsbedarf in den Bereichen geistige Entwicklung, Lernen und Autismus-Spektrum im Fokus. Dadurch entsteht schon zwischen diesen drei Bereichen eine sehr heterogene Zielgruppe. Gleichzeitig unterscheiden sich aber auch die Schülerinnen und Schüler innerhalb desselben Unterstützungsbedarfs teilweise stark hinsichtlich ihrer kognitiven, wahrnehmungsbezogenen und motorischen Voraussetzungen.

Trotz dieser Heterogenität lassen sich gemeinsame Herausforderungen im Schul und auch normalen Alltag ableiten:
Handlungsplanung & Problemlösen
Strukturierung von Aufgaben und Lernprozessen
Unterschiedliche Wahrnehmungs- und motorische Voraussetzungen


lassen sich einige gemeinsame Gestaltungsprinzipien ableiten. Besonders relevant für meine Arbeit waren dabei eine **individuelle Anpassung statt standardisierter Anforderungen**, klare und überschaubare Aufgabenstrukturen, ausreichend Zeit und Wiederholungsmöglichkeiten sowie **spielerische und handlungsorientierte Aufgaben**. Gerade für selbstständiges Arbeiten ist außerdem zeitnahes und verständliches Feedback wichtig.“

## physisches Bauen

Gerade physische Konstruktionsaufgaben sind dafür interessant, weil der Lernende nicht nur eine abstrakte Darstellung betrachtet, sondern räumliche Beziehungen tatsächlich selbst herstellt.“

Wenn beispielsweise eine räumliche Orientierung verstanden werden soll, wird ein Objekt aktiv positioniert und gedreht. Der Lernende bleibt damit nicht in einer rein rezeptiven Rolle, wie sie beispielsweise im klassischen Frontalunterricht stärker ausgeprägt ist, sondern setzt sich aktiv mit dem Lerngegenstand auseinander.“

Das entspricht auch der Grundidee des Constructionism – vereinfacht gesagt: *learning by making*. Lernen wird dabei dadurch unterstützt, dass der Lernende selbst ein sichtbares und veränderbares Artefakt erzeugt und sich während dieses Konstruktionsprozesses mit dem Problem auseinandersetzt.“

### Grenzen klassischer Baumaterialien

Genau hier entsteht allerdings auch die Grenze klassischer Baumaterialien.“

 „Die Konstruktion selbst kann nicht erkennen, ob der aktuelle Zustand der Aufgabe korrekt ist. Die notwendige Rückmeldung muss deshalb entweder vom Lernenden selbst oder von einer Lehrkraft kommen.“

 „Gerade während Phasen selbstständigen Arbeitens kann eine Lehrkraft aber nicht jeden einzelnen Handlungsschritt unmittelbar beobachten. Dadurch kann Feedback verzögert erfolgen und ein Fehler möglicherweise erst erkannt werden, nachdem bereits darauf weitergebaut wurde.“

## Digitale Technologien

Digitale Technologien wie Tablets bieten hier andere Möglichkeiten. Sie können Lerninhalte multimedial darstellen, Aufgaben an individuelle Bedürfnisse anpassen und automatisiertes Feedback bereitstellen.“

Gleichzeitig findet die Interaktion aber meist auf einem zweidimensionalen Bildschirm statt und ist weitgehend auf Touch- oder Mauseingaben beschränkt.“

Auch das ist natürlich aktive Interaktion, bietet aber nicht dieselbe haptische und räumlich differenzierte Erfahrung wie die Manipulation dreidimensionaler Objekte.“

Gerade die physische und motorische Interaktion mit dem Lerngegenstand wird dadurch deutlich reduziert.“


## TUI
Genau an dieser Stelle kommen Tangible User Interfaces ins Spiel.“

Bei einem klassischen Graphical User Interface sind Darstellung und Interaktion weitgehend getrennt: Ich sehe digitale Informationen auf einem Bildschirm und interagiere beispielsweise über Maus, Tastatur oder Touch.“

Bei einem Tangible User Interface werden digitale Informationen dagegen mit greifbaren physischen Objekten gekoppelt.“

Das physische Objekt hat dabei eine Doppelfunktion: Es repräsentiert Information und dient gleichzeitig als Interaktionselement.

Wenn ich also beispielsweise einen Brick drehe, ist dieser Brick nicht einfach nur ein Eingabegerät wie eine Maus. Seine tatsächliche räumliche Orientierung ist selbst Teil der Information – und indem ich ihn drehe, verändere ich gleichzeitig den digitalen Zustand des Systems.“

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

# Folie 7 - Systemarchitektur
