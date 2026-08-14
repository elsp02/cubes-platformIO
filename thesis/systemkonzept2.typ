#import "functions.typ": req, apa-table


= Konzeptentwicklung
- In diesem Kapitel wird beschrieben, welche Lösungen gewählt wurden und warum diese zur Berücksichtigung der Anforderungen geeignet sind
- Ob die Anforderungen tatsächlich erfüllt sind, wird erst nach der Realisierung in der Evaluation bewertet


== Ausgangspunkt und Konzeptziele
- Bezug zur Anforderungsanalyse
  - Die in kapitel x durchgeführte Anforderungsanalyde bildet dier Grundlage für die Entwicklung des Systemkonzepts
  - Ziel der Konzeptentwicklung ist es, Anforderungen zu erfüllen und in ein zusammenhängendes Systemkonzept zu überführen
  
- Konzeptentwicklung umfasst
    - physische Gestaltung der Würfel und ihrer Verbindungen
    - elektronische Erfassung und Energieübertragung
    - Kommunikation, Datenübertragung und digitale Rekonstruktion der Konstruktion
    - Aufgaben- und Interaktionsprinzip
    - Visualisierungs- und Feedbackgestaltung



== Nutzungsszenario
=== Ablauf der Bauufgabe
- Das Nutzungsszenario beschreibt den grundlegenden Ablauf einer angeleiteten Bauaufgabe aus Sicht der Lernenden
  - Zu Beginn wird Zielkonstruktion in learning app/application/computer ausgewählt und den Lernenden als Vorlage präsentiert
      - Auswahl erfolgt durch die Lehrkraft oder, sofern dies für die jeweilige Lernsituation vorgesehen ist, durch das Kind
  - Das Kind beginnt den Aufbau, indem es einen ersten Würfel mit der Baseplate verbindet.
  - Anschließend ergänzt es schrittweise weitere Würfel, bis die vorgegebene Zielkonstruktion entstanden ist
  - bereits ausgeführte Schritte können durch das Trennen und erneute Anordnen der Bausteine verändert werden
  - Nach jeder Veränderung erfasst und aktualisiert das System den aktuellen Zustand der Konstruktion 
  - vergleicht ihn mit der Zielvorgabe
    - Entspricht der erkannte Aufbau einem zulässigen Teil der Zielkonstruktion, kann das Kind mit dem nächsten Schritt fortfahren.
    - Wird eine Abweichung festgestellt, erhält es eine entsprechende Rückmeldung und kann den betroffenen Handlungsschritt korrigieren
  - Die Aufgabe endet, sobald der physische Aufbau vollständig mit der Zielkonstruktion übereinstimmt
  - die Aufgabe kann dann wiederholt oder eine neue Zielkonstruktion ausgewählt werden kann

- Bearbeitungsbedingungen:
  - Die Aufgabe wird ohne feste zeitliche Begrenzung im individuellen Arbeitstempo bearbeitet
  - Eine bestimmte Baureihenfolge wird nur dort vorausgesetzt, wo sie sich aus der räumlichen Struktur der Konstruktion ergibt

ABLAUFDIAGRAMM

Lehrkraft
  - begleitet Prozess
  - passt die verfügbare Aufgabenauswahl bei Bedarf an
  - gibt weiterführende Erklärungen, falls die vom System Hilfestellung/Feedback nicht ausreicht oder verstanden wird 
  -> Die automatische Rückmeldung soll die Lehrkraft insbesondere während selbstständiger Arbeitsphasen unterstützen, ersetzt jedoch nicht die individuelle pädagogische Begleitung.

=== Funktionsstruktur
- Aus dem beschriebenen Nutzungsszenario lassen sich die grundlegenden Funktionen ableiten, die das System zur Durchführung der Bauaufgabe bereitstellen muss
- Die in Abbildung x dargestellt Funktionsstruktur beschreibt diese Aufgaben zunächst unabhängig von ihrer späteren technischen Umsetzung

FUNKTIONSDIAGRAMM
whats app


Die einzelnen Funktionen lassen sich fünf Funktionsbereichen zuordnen: (TABELLE - vlt Funktionsbereichnamen ändern zu unterkapitelnamen)
- Physisches Teilsystem: Würfel, Gehäuse und Verbindungen
- Elektronisches Teilsystem: Identifikation der Bausteine, Erkennung der Verbindungen und relativen Rotationen, Bereitstellung der Energieversorgung
- Softwareseitiges Teilsystem: Übertragung der erfassten Strukturdaten, Erzeugung eines digitalen Strukturmodells, räumliche Rekonstruktion der physischen Ist-Konstruktion
- Aufgaben- und Interaktionssystem: Auswahl und Darstellung der Zielkonstruktion
- Visualisierungs- und Feedbacksystem: Vergleich von Ist- und Zielkonstruktion, Darstellung der erkannten Konstruktion, Erzeugung und Ausgabe der Rückmeldung


Die Funktionsstruktur verdeutlicht:
-  physische Handlung kann nicht unmittelbar durch die Lernanwendung interpretiert werden kann, sondern muss die Verbindung mechanisch hergestellt und elektronisch erkannt werden
- lokale Informationen müssen übertragen und in ein digitales Strukturmodell überführt werden
- Erst auf Grundlage dieses Modells kann die Lernanwendung einen Zielvergleich durchführen und ein inhaltliches Feedback erzeugen.


== Übergeordnete Systemarchitektur
-  Systemarchitektur ordnet die in Funktionsstruktur beschriebenen Funktionen den Bestandteilen des Gesamtsystems zu
- Das technische System besteht aus:
  - aktiven Bausteinen,
  - einer Baseplate,
  - einer digitalen computerbasierten Lernanwendung
- Lernende und Lehrkräfte sind externe Akteur:innen und keine technischen Systemkomponenten

=== Systemkomponenten und Zuständigkeiten
#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[Element][Einordnung][zentrale Zuständigkeit],

    [Lernende Person],  [Externe Akteur:in], [Zielkonstruktion auswählen, physische Ist-Konstruktion aufbauen, auf Rückmeldungen reagieren],

    [Lehrkraft], [Externe Akteur:in], [Aufgabenauswahl anpassen, Lernprozess begleiten, zusätzliche Unterstützung anbieten],

    [Bausteine], [Technische Komponente], [physische Konstruktion bilden, lokale Verbindungsinformationen bereitstellen, lokale Rückmeldungen ausgeben],

    [Baseplate], [Technische Komponente], [Ausgangspunkt und Energieversorgung bereitstellen, zwischen Bausteinsystem und Lernanwendung vermitteln],

    [Lernanwendung], [Technische Komponente], [Zielkonstruktion bereitstellen, Strukturdaten verarbeiten, Ist-Konstruktion visualisieren, Zielvergleich durchführen, Rückmeldungen erzeugen]
  ),
    caption: [Systemkomponenten und Zuständigkeiten],
) <Systemkomponenten>

DIAGRAMM: konzeptionelle Systemarchitektur mit User, Smart Cube System und Learning application

== Begriffliche Abgrenzung der Verbindungsebenen
- Zur eindeutigen Beschreibung des Systems werden die mechanische, elektronische und logische Verbindungsebene begrifflich voneinander unterschieden. 
- Jeder Baustein besitzt eine Andockseite, über die er an die bestehende Konstruktion angeschlossen wird, sowie typabhängig eine oder mehrere Aufnahmeseiten für weitere Bausteine. 
- Auf der Andockseite befindet sich die elektronische Upstream-Schnittstelle, während jede Aufnahmeseite eine Downstream-Schnittstelle enthält. 
- Im digitalen Modell wird der bereits angeschlossene Baustein durch den Elternknoten und der neu hinzugefügte Baustein durch den Kindknoten repräsentiert. Eine Verbindung lässt sich somit auf den drei in folgender Tabelle dargestellten Ebenen beschreiben:

TABELLE
#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[Ebene][Begriff][Definition],

    [Mechanik],  [Verbindungsseite], [Oberbegriff für alle physischen Bausteinseiten, über die eine Verbindung möglich ist],

    [Mechanik], [Andockseite und Aufnahmeseite], [Verbindungsseiten der Bausteine],

    [Elektronik], [Upstream- und Downstream Interface], [elektrische Kontaktierungen auf den Verbindungsseiten],

    [Elektronik], [Upstream-Schnittstelle], [Gesamtheit der elektrischen Kontakte auf der Andockseite],

    [Elektronik], [Downstream-Schnittstelle], [Gesamtheit der elektrischen Kontakte auf einer Aufnahmeseite],

    [Datenmodell], [Elternbaustein], [Bereits am System angeschlossener Baustein],

    [Datenmodell], [Kindbaustein], [Baustein, der mit seiner Andockseite an eine Aufnahmeseite des Elternbausteins angeschlossen ist],

    [Datenmodell], [Elternknoten], [digitale Repräsentation des Elternbausteins],

    [Datenmodell], [Kindknoten], [digitale Repräsentation des Kindbausteins],

    [Datenmodell], [Eltern- und Kindknoten], [gerichtete Beziehung im digitalen Baum]
  ),
    caption: [requirements for detection],
) <Begriffssystem_verbindungsebene>

ODER
#figure(
  table(
    columns: 3,
    stroke: none,

    table.header[Ebene][Begriff][Definition],

    [Mechanik],  [Verbindungsseite], [Oberbegriff für alle physischen Bausteinseiten, über die eine Verbindung möglich ist],

    [Mechanik], [Andockseite und Aufnahmeseite], [Verbindungsseiten der Bausteine],

    [Elektronik], [Upstream- und Downstream Interface], [elektrische Kontaktierungen auf den Verbindungsseiten],

    [Datenmodell], [Eltern- und Kindknoten], [gerichtete Beziehung im digitalen Baum]
  ),
    caption: [requirements for detection],
) <Begriffssystem_verbindungsebene>

== geometrisches, mechanisches und ergonomisches Konzept
- Im Folgenden werden gemäß der Begriffsdefinition in Abschnitt X.3.3 die Bezeichnungen Andockseite und Aufnahmeseite verwendet.

Das Kapitel beschreibt:
- Grundformen und Abmessungen der Bausteine
- gerichtete Gestaltung der Verbindungsseiten
- mechanisches Verbindungsprinzip
- ergonomische Gestaltung
- Gehäuse- und Wartungskonzept
- mechanischen Aufbau der Baseplate

=== Grundform und Bausteintypen
- Aussehen: realer Würfel spiegelt digitalen Würfel wieder -> abstraktheit (TUI Anforderung bezug) + alltagsgegenstand (physische repräsentation bezug) => vlt das in interaktionskapitel

- Entsprechend der Anforderung G1 besitzen die Verbindungsseiten eines jeden Bausteins eine quadratische Grundfläche mit einheitlichen Abmessungen 
=> quadratische Verbindungsfläche ermöglicht rotationssymmetrisches contact arrangement (elektrische anforderungen) -> vier mechanisch mögliche Rotationen in 90-Grad-Schritten-> stellt eine einheitliche Verbindung unterschiedlicher Bausteintypen sicher + bildet mechanische Voraussetzung für die in C4 geforderte elektronische Rotationserkennung

- basierend auf der grundlage der quadratischen Verbindungsflächen werden zwei Bausteintypen vorgesehen (G3):
  - Würfelbaustein mit sechs quadratischen Verbindungsflächen (G2)
  - Smashed Baustein mit zwei gegenüberliegenden quatratischen Verbindungsseiten. die übrigen seiten stellen keine Verbindungsseiten dar

=> Durch Würfelbaustein können sowohl lineare als auch verzweigte zwei und dreidimensionale Strukturen entland der drei orthogonaler Raumachsen aufgebaut werden (C3). smashed würfel ermöglicht nur lineare Verbindungen entlang seiner lokalen z-Achse (siehe Abbildung Würfel)


Für die quadratischen Verbindungsflächen ist eine Seitenlänge von ungefähr 40 mm vorgesehen
-> Kompromiss zwischen Anforderung, dass Baustein mit einer Hand gegriffen und positioniert werden kann (C5) und ausreichend Bauraum für Kontakte und elektronische Komponenten. Ob die gewählte Größe tatsächlich ergonomisch geeignet ist, wird in Kapitel x evaluiert 

=== Gerichtete Gestaltung der Verbindungsseiten
Wie von den Anforderungen C1 und C2 gefordert, besitzt jeder Baustein genau eine Andockseite und mindestens eine Aufnahmeseite abhängig von Bausteintyp (Würfel fünf und Smashed Baustein eine). 
=> eine gültige mechanische verbindung entsteht ausschließlich zwischen einer Aufnahmeseite des Elternbausteins und Andockseite des Kindbausteins. 

Um due verschiedenen Aufnahmeseiten voneinander unterscheiden zu können (und so die zielrotation zu sehen), werden diese farblich differenziert

Die gerichtete Gestaltung der Verbindungsseiten bildet die physische Grundlage für die spätere Abbildung der Konstruktion als Eltern-Kind-Struktur. Das digitale Strukturmodell wird in Abschnitt X.6 erläutert.

==== mechanisches Verbindungsprinzip
- Auswahl anhand anforderung Stabilität, eindeutige Ausrichtung und geringen Kraftaufwand (C6)
- Für Prototyp wird Kombi aus mechanischem Formschluss und magnetischer Unterstützung gewählt:
  - Formschluss: Andockseite: vertiefte Führungselemente, Aufnahmeseite: korrespondierende hervorstehende Führungselemente
  - magnetische Verbindung: die zwei unterschiedlichen Verbindungsseiten Typen erhalten sich gegenseitig anziehende Magnete (Polung)
- Vorteile:
  - geometrische Führungselemente bestimmen mechanisch, welche Seitentypen verbunden werden können und richten die Kontaktbereiche aus,
  - Magnete unterstützen die Annäherung und stabilisiern die hergestellte Verbindung

- mechanischer constraint: 
  - ungültige Verbindungen werden durch Form der Schnittstelle erschwert bzw verhindert (verbindungen passen nicht zusammen oder werden von magneten abgestoßen) 
  - verfügbare handlungsmöglichkeiten werden unmittelbar wahrnehmbar 

-> mechanisches und magnetisches Einrasten erzeugt intrinsisches haptisches Feedback: Lernende können unmittelbar wahrnehmen, dass zwei seiten miteinander verbunden wurden. feedback bestätigt zunächst aber nur physische verbindung (ob elektronisch erkannt, wird nicht ausgesagt) -> VERWEIS FEEDBACK UNTERKAPITEL

Zwischen Stabilität und Bedienkraft kann jedoch ein Zielkonflikt entstehen
- stärkere magnetische Verbindung erhöht Stabilität der Gesamtkonstruktion kann aber das Trennen und Korrigieren erschweren
-> Welche genaue Magnetkraft für die Zielgruppe geeignet ist, lässt sich nur durch entsprechende Nutzungstests bestimmen -> Untersuchung liegt außerhalb des Rahmens der Arbeit

=== Gehäuse und Wartbarkeit
- Gehäuse muss die elektronischen Komponenten und Magnete vollständig umschließen und das unbeabsichtigte Lösen kleiner Bestandteile verhindern (S2), aber trotzdem noch auseinanderbaubar sein ohne kaputt zu gehen (S3)

- Vorgesehener modularer Aufbau:
  - tragender Rahmen mit Andockseite
  - einsetzbare Seitenwände mit Aufnahmeseiten
  - abschließender Deckel, der

Vorteile des modularen Aufbaus :
-> dadurch lassen sich die elektrischen Komponenten in die Seitenwände zuerst einzeln montieren und dann anschließend zu einem Gesamtbaustein verbinden (S3)
-> da alle Seitenwände unabhängig von Bausteintyp und der Position im Baustein gleich aufgebaut sind, können sie überall verwendet und ausgetauscht werden  


=== Mechanisches Konzept der Baseplate
-  baseplate besteht aus einem geschlossenen Gehäuse für ihre technischen Komponenten
-  bildet Ausgangspunkt der physischen Konstruktion und benötigt daher mindestens eine Aufnahmeseite, die mechanisch der der Bausteine entspricht
- erster Baustein wird mit definierten Andockseite auf Baseplate gesetzt und dadurch räumlich sowie logisch als erstes Element der Konstruktion festgelegt

- Mehrere Anschlusspunkte könnten perspektivisch parallele Konstruktionen oder Aufgaben mit mehreren Ausgangspunkten ermöglichen -> würden jedoch eine Erweiterung des Strukturmodells und zusätzliche Regeln für den Vergleich mit der Zielkonstruktion erfordern  => sind daher nicht Bestandteil des grundlegenden Konzepts

=== Zusammenfassung
- mechanisches Konzept verbindet einheitliche Würfelgeometrie mit gerichteten Seitenstruktur, rotationssymmetrischen Kontakten sowie einer formschlüssigen und magnetisch unterstützten Verbindung
- physische Gestaltung begrenzt ungültige Verbindungen + unterstützt die Ausrichtung + bildet die Voraussetzung für die elektronische Erfassung der Konstruktion
ODER
Die mechanische Gestaltung legt fest, welche Seitentypen miteinander verbunden und welche vier relativen Rotationen eingenommen werden können. Im folgenden Abschnitt wird beschrieben, wie diese mechanisch definierten Zustände elektronisch erfasst und die angeschlossenen Bausteine zentral mit Energie versorgt werden.

-------

== Elektronisches Erkennungs- und Versorgungskonzept
- Das Kapitel verwendet die in X.3.3 definierten Begriffe:
  - Upstream-Schnittstelle auf der Andockseite,
  - Downstream-Schnittstelle auf jeder Aufnahmeseite.


- Damit die physische Konstruktion digital rekonstruiert werden kann, müssen diese Verbindungszustände elektronisch erfasst werden
=> das vorliegende kapitel beschreibt die dafür erforderliche elektonische Architektur
enthält:
- elektronische Systemarchitektur
- funktionalen Aufbau der Bausteine und Baseplate
- elektrische Schnittstellen und lokales Erkennungsprinzip
- zentrale Energieversorgung
- (lokale Feedbackausgabe)


=== elektronische Systemarchitektur
aktiv/passiv/? - related work abhängig

=== Funktionaler Aufbau 
==== der Bausteine
jeder baustein enthält konzeptionell folgende elektronische Funktionseinheiten:
- lokale Steuereinheit: stellt die Identität und den Typ des Bausteins bereit und verarbeitet die an den Schnittstellen anliegenden Signale
- Upstream Schnittstelle: stellt auf der Andockseite die elektrische Verbindung zum Elternbaustein her (DET1)
- Downstream-Schnittstellen: stellen auf den Aufnahmeseiten elektrische Verbindungen zu Kindbausteinen bereit (abhängig vom Baustein Typ) (DET2)
- Energieverteilung: versorgt die lokale Elektronik und leitet die Versorgung an nachfolgende Kindbausteine weiter
- lokale Feedbackausgabe: ermöglicht eine visuelle Rückmeldung direkt am Baustein

==== der Baseplate
- zentrale Steuereinheit: initiiert die Erfassung und vermittelt zwischen Bausteinsystem und Lernanwendung
- Downstream Schnittstelle: verbindet die Baseplate mit dem ersten Baustein
- zentrale Energieversorgung: versorgt die angeschlossene Konstruktion
- Anwendungsschnittstelle: ermöglicht den Datenaustausch mit der Lernanwendung

- Da die baseplate den Ausgangspunkt der Konstruktion darstellt, benötigt sie keine Upstream-Schnittstelle. 
- Sie leitet die erfasste serialisierte Konstruktion an die Lernanwendung weiter.
-> Die räumliche Rekonstruktion und der Zielvergleich erfolgen nicht in der Baseplate, sondern in der Lernanwendung.

BLOCKDIAGRAMME

=== elektrische Schnittstellen und lokales Erkennungsprinzip
- Jede mechanisch definierte Verbindungsstelle wird durch einen elektrischen Kontakt ergänzt. Upstream und Downstream Schnittstelle eines Bausteins unterscheiden sich dabei hinsichtlich ihrer Signalkontakte:
  - Upstream Schnittstelle: Die Andockseite besitzt vier Upstream-Orientierungs bzw Datenkontakte, die den vier möglichen Rotationen entsprechen
  - Downstream Schnittstelle: Jede Aufnahmeseite besitzt einen Downstream-Child Kontakt zur Erkennung und Kommunikation mit einem Kindbaustein
  - Beide Seitentypen verfügen zusätzlich über Kontakte für die Energieversorgung und das gemeinsame Bezugspotenzial

Die Anordnung der vier Upstream-Datenkontakte an den Ecken der Verbindungsseite und des korrespondierenden Downstream-Datenkontakts ermöglicht vier eindeutig unterscheidbare Rotationen. Die Versorgungs- und Massekontakte sind außerdem rotationssymmetrisch ausgeführt, sodass sie in jeder zulässigen Orientierung funktional verbunden bleibe

==== Erkennen der Verbindungsseite und Rotation
- Eine gültige elektrische Verbindung entsteht stets zwischen dem Downstream-Kontakt des Elternbausteins und einem der vier Upstream-Kontakte des neu angeschlossenen Kindbausteins 
- Einer der vier Upstream Kontakte des Kindbausteins wird dabei abhängig von seiner Ausrichtung vom Downstream Datenkontakt des Elternbausteins kontaktiert und definiert dadurch die relative Rotation der Bausteine zueinander (DET3). Der kontaktierte Signalpfad wird dann anschließend für die Datenübertragung mit dem Elternbaustein verwendet
- da jede Aufnahmeseite des Bausteins eine eigene Downstream Schnittstelle besitzt, kann nach diesem Prinzip Seite für Seite abgefragt werden, ob ein untergeordneter Würfel an der jeweiligen verbunden ist und in diesem Fall die Kommunikation mit dem Kindbaustein ermöglicht werden.

- (Welcher konkrete Baustein angeschlossen ist, wird anschließend anhand seiner übermittelten Identität bestimmt (siehe kapitel 6))

-> erfasste Rotation und Verbindungsseite beschreibt zunächst ausschließlich die Ausrichtung des Bausteins relativ zu seinem unmittelbar übergeordneten Element (parent). Die Berechnung seiner globalen Position und Orientierung innerhalb der Gesamtkonstruktion erfolgt später in der Lernanwendung auf Grundlage aller lokalen Verbindungen

=== Kontaktierung
- Art der Kontakte
  - Pogo Pins -> können kleine Abweichungen aus dem Herstellungsprozess und geringfügige Bewegungen zwischen den Würfeln ausgleichen
  - Vertiefungen und Führungselemente dienen auch schutz der elektrischen schnittstelle (schutz vor fehlkontaktierung und kurzschluss)


=== zentrale Energieversorgung
- Entsprechend den technischen Anforderungen werden die Bausteine ohne eigene Batterien oder Akkus betrieben -> Energieversorgung erfolgt zentral über die Baseplate und wird über die elektrischen Kontakte der Verbindungen an die angeschlossenen Kindbausteine weitergegeben (EL1)
- Jeder Baustein verwendet die eingehende Versorgung für seine eigene Elektronik + führt sie zu verfügbaren downstream schnittstellen weiter sodass auch nachfolgende Bausteine versorgt werden

Vorteile
- reduziert den Wartungsaufwand, weil keine Batterien in den einzelnen Bausteinen geladen oder ausgetauscht werden müssen
- verringert den benötigten Bauraum und vermeidet unterschiedliche Ladezustände innerhalb der Konstruktion

=== lokale elektronische Feedbackausgabe
- Jeder aktive Baustein enthält eine einfache visuelle Feedbackausgabe (FB?) -> Dadurch kann eine Rückmeldung unmittelbar dem betroffenen physischen Baustein zugeordnet werden. 
- Die lokale Steuereinheit muss hierzu mindestens einen elektronisch kontrollierbaren Ausgabezustand bereitstellen

=== Zusammenfassung
Das elektronische Konzept basiert auf aktiven Bausteinen mit eigener lokaler Steuereinheit. Jeder Baustein verfügt über eine Upstream-Schnittstelle an seiner definierten Andockseite und mehrere seitenspezifische Downstream-Schnittstellen. Über die elektrische Kontaktanordnung können bestehende Verbindungen, die verwendeten Seiten und vier relative Rotationen erfasst werden.
Die Baseplate bildet den elektronischen Ausgangspunkt des Systems. Sie stellt die zentrale Energieversorgung bereit und verbindet die physische Würfelstruktur mit der digitalen Lernanwendung. Durch die Weiterleitung der Energie über die Bausteinverbindungen können die einzelnen Module ohne eigene Batterien oder Akkus betrieben werden.
Das elektronische Konzept stellt damit die physikalischen Schnittstellen und Signale bereit, die für die digitale Rekonstruktion der Konstruktion erforderlich sind.

ODER

Das elektronische Konzept stellt die Schnittstellen zur Identifikation sowie zur Erfassung von Verbindungsseite und relativer Rotation bereit. Wie diese lokalen Informationen abgefragt, zu einer serialisierten Baumstruktur zusammengeführt und von der Lernanwendung verarbeitet werden, wird im folgenden Daten-, Kommunikations- und Softwarekonzept beschrieben.

----------
== Daten-, Kommunikations- und Softwarekonzept 
Das Kapitel legt fest, wie diese bereitgestellten elektrischen Informationen über die Würfelstruktur übertragen, zu einer serialisierten Beschreibung der Gesamtkonstruktion zusammengeführt und anschließend in der Lernanwendung verarbeitet werden.

enthält:
- übergeordneten Datenfluss
- Struktur und Datenmodell
- Erfassungs- und Kommunikationskonzept
- Verarbeitung in der Lernanwendung
- Feedbackrückkanal

=== übergeordnetet Datenfluss
- Der Verarbeitungsablauf beginnt in der Lernanwendung:
  - Das Kind wählt eine Zielkonstruktion aus
  - Die Zielkonstruktion wird für den späteren Vergleich gespeichert
  - Die Lernanwendung sendet ein Startsignal an die Baseplate

- Die Baseplate:
  - startet den zyklischen Erfassungsprozess
  - fragt den ersten angeschlossenen Baustein ab
  - Die Bausteine ermitteln ihre lokalen Verbindungsinformationen und führen diese rekursiv zu einer serialisierten Beschreibung der vollständigen Baumstruktur zusammen
  - empfängt die serialisierte Baumdarstellung
  - leitet diese inhaltlich unverändert an die Lernanwendung weiter

- Die Lernanwendung:
  - deserialisiert die empfangene Baumdarstellung
  - stellt das digitale Strukturmodell wieder her
  - berechnet Position und Orientierung der Bausteine
  - vergleicht die Ist-Konstruktion mit der Zielkonstruktion
  - erzeugt die Feedbackzustände
  - visualisiert die erkannte Konstruktion und die globale Rückmeldung
  - sendet bausteinspezifische Feedbacknachricht an die Baseplate

- Die Baseplate leitet die Feedbacknachricht an die Bausteine weiter
- Anschließend beginnt der nächste Erfassungszyklus
- Der Vorgang wiederholt sich, bis die Aufgabe abgeschlossen oder beendet wird
- Beim Beenden sendet die Lernanwendung ein Stoppsignal an die Baseplate, die noch eine letzte vordefinierte Schluss-feedbacknachricht an die Bausteine rausschickt
- baseplate wartet wieder auf ein Startsignal
- lernanwendung wartet auf eine ausgewählte Zielkonstruktion


=> zwei voneinander abgetrennte Systeme:
- baseplate und cubes 
  - Basisstation und aktive Bausteine,
  - erfasst und überträgt die physische Konstruktion,
  - ist unabhängig von der ausgewählten Zielkonstruktion
- lernanwendung:
  - Computer
  - interagiert mit den Lernenden
  - verwaltet die Zielkonstruktion
  - interpretiert die erfassten Daten
  - führt den Zielvergleich durch
  - erzeugt Visualisierung und Rückmeldung

SEQUENZDIAGRAMM

=== logisches Struktur- und Datenmodell
- die physische Konstruktion wird konzeptionell als gerichtete Baumstruktur modelliert:
  - Baseplate bildet Root des Baums
  - jeder angeschlossene Baustein ist ein Node
  - jede physische Verbindung ist eine gerichtete Kante zwischen Eltern- und Kindknoten

- Das Modell folgt der in Kapitel X.4 beschriebenen Seitenstruktur:
  -  definierte Andockseite eines Bausteins stellt die Verbindung zu seinem übergeordneten Elternbaustein her
  -  Die Aufnahmeseiten ermöglichen die Verbindung mit untergeordneten Kindbausteinen
  ->  Jeder Baustein besitzt dadurch höchstens ein übergeordnetes Element/Elternbaustein, kann jedoch mehrere untergeordnete Kindbausteine aufnehmen, sodass auch verzweigte und dreidimensionale Konstruktionen möglich sind #req("C3")

Ein Node enthält die für ?seine Einordnung? erforderlichen Informationen:

#figure(
  table(
    columns: 2,
    stroke: none,

    table.header[Information][Bedeutung],

[Identität],	[eindeutige Zuordnung des physischen Bausteins],

[Bausteintyp],	[geometrische und funktionale Eigenschaften des Bausteins],

[Relative Rotation],	[Orientierung gegenüber dem Elternbaustein],

[belegte Verbindungsseiten],	[Zuordnung der Kindknoten zu den Aufnahmeseite],

[Kindknoten],	[Nodeinformationen aller unmittelbar und mittelbar angeschlossenen untergeordneten Kindbausteine],
  ), 
    caption: [Informationen eines Nodes],
) <node_infos>

- Identität dient dazu, einen physischen Baustein wiederzuerkennen und ihm später ein lokales Feedback zuzuordnen
- Bausteintyp wird für  geometrische Interpretation und  Vergleich mit der Zielstruktur benötigt
-> Strukturmodell enthält nur lokale Eltern-Kind Beziehungen, globale Positionen und Orientierungen werden nicht von den Bausteinen übertragen => räumliche Gesamtkonstruktion wird in der Lernanwendung aus der Verkettung dieser lokalen Nodeinformationen berechnet

ABBILDUNG: Gegenüberstellung einer physischen Konstruktion und des daraus abgeleiteten digitalen Baumes

==== Mapping Styles
- das gewählte Strukturmodell verbindet mehrere der in Kapitel X beschriebenen Mapping Styles:
  - relationales mapping: digitale Interpretation liegt auf den Beziehungen zwischen den bausteinen - 
  - konstruktives mapping: digitale Bedeutung und räumliche Information entsteht nicht aus einem einzelnen Baustein, sondern aus der Verbindung mehrerer Elemente zu einer Gesamtstruktur

==== methods of coupling
- statische Kopplung: Zuordnung eines physischen Bausteintyps zu seinem digitalen Modell ist vorab festgelegt -> die zwei unterschiedlichen Bausteintypen werden immer durch ihr entsprechendes digitales Würfelmodell (das dem physischen baustein vom aussehen gleicht) repräsentiert 
- interaktive Kopplung: Die Bedeutung der Konstruktion entsteht aus der Verbindung der Würfel untereinander (Position, Rolle im Baum und Bewertung hängen von der jeweiligen Konfiguration ab)

=== Erfassungs- und Kommunikationskonzept
- Kommunikation innerhalb der Konstruktion folgt Eltern-Kind-Beziehungen des Strukturmodells: 
  - übergeordnetes Element fordert die Infos eines unmittelbar verbundenen Bausteins an -> antwortet mit seinen Nodeinfos und den Daten seiner untergeordneten Teilstrukturen (Kindknoten)
- lokale Kommunikatiopn zwischen zwei verbundenen Bausteinen erfolgt kontaktgebunden über die in Kapitel X beschriebenen Upstream (Kindbaustein) und Downstream (Elternbaustein) Schnittstellen mit Hilfe des Request-Response Verfahrens:
  - Elternbaustein innitiert Kommunikation und Kindbaustein antwortet auf Anfrage
  - Kindbaustein wird dann selbst zu Elternbaustein wenn es seine Aufnahmeseiten nach verbundenen Bausteinen abfrägt
- Da die Kommunikation zwischen zwei Bausteinen nur über eine Signalleitung (Upstream orientation kontakt und downstream child kontakt) erfolgt, wird diese zeitlich abwechselnd für beide Übertragungsrichtungen genutzt = selbst definiertes bidirektionale single-wire half-duplex kommunikationsprotokoll 

==== Abfrage und rekursive Erfassung der Konstruktion
- Downstream Schnittstellen der jeweiligen Aufnahmeseiten eines Bausteins werden bei der Erfassung/Detection von Kindbausteinen nach dem Round-Robin-Prinzip/ sequenziell in definierter Reihenfolge zyklisch nacheinander berücksichtigt, wodurch jede vorhandene Aufnahmeseite regelmäßig überprüft wird
- wird an einer Schnittstelle kein Kindbaustein erkannt, wird mit nächsten verfügbaren Schnittstelle fortgefahren
- wird ein Kindbaustein erkannt, wird zuerst dessen Teilkonstruktion erfasst bevor mit der Abfrage der nächsten Downstream-Schnittstelle weitergemacht wird 

- Erfassung der Gesamtkonstruktion anhand einer Depth-First-Search: 
  - ausgehend von Baseplate als root wird ein erkannter Konstruktionszweig bis zu seinem letzten Baustein verfolgt bevor die nächste am Baustein vorhandene Downstream Schnittstelle verarbeitet wird
  - Wenn alle Downstream Schnittstellen abgefragt sind, fasst Baustein seine eigenen Node Infos mit den gesammelten Infos seiner Kindknoten zusammen
  -> daraus resultiert Beschreibung des vollständigen Teilbaums, das an den Elternknoten/Bausteins zurückgegeben wird
  => Vorgang wird rekusiv fortgesetzt, bis Baseplate die serialisierte Beschreibung der gesamten Konstruktion von ihrem Kindbaustein erhält

==== Serialisierung der Baumstruktur
- für serialisierte Beschreibung des erkannten Baums wird ein Preorder Traversal verwendet, denn zuerst werden die Daten des aktuellen Elternknotens und anschließend die serialisierten Daten seiner Kindknoten in der festgelegten Reihenfolge der Downstream Schnittstellen angefügt (-> festgelegte Reihenfolge ermöglicht es der Lernanwendung, die Kindknoten wieder den richtigen Seiten zuzuordnen)
BEISPIEL BAUSMSTRUKTUR UND PREORDER REIHENFOLGE?
- Unterschied Ablauf Erfassung und Anordnung der übertragenen Daten:
  - Anfragen breiten sich von Baseplate bis zu äußeren Knoten aus
  - erfasste Teilbaumdaten werden in umgekehrter Richtung zur Baseplate zurückgegeben, innerhalb der serialisierten Darstellund steht jedoch Elternknoten vor seinen Kindknoten

=== Verarbeitung in der Lernanwendung
- serialisierte Beschreibung der erkannten Konstruktion wird von baseplate zur Lernanwendung übertragen und dort deserliasiert, sodass die einzelnen Knoten und ihre Eltern-Kind-Beziehungen wieder als digitales Baummodell vorliegen -> festgelegte Reihenfolge der Abfrage der Downstream Schnittstellen/Aufnahmeseiten ermöglicht es der Lernanwendung dabei, die untergeordneten Knoten wieder ihren richtigen Anschlusseiten zuzuordnen #req("DET2").

- ausgehend von baseplate berechnet Lernanwendung anschließend die globale Position und Orientierung jedes Bausteins.
  - für jede Verbindung ist lokale Transformation definiert, die sich aus verwendeten Verbindungsseite, dem Typ der zwei miteinander verbundenen Bausteine und der erkannten relativen Rotation ergibt
  -> globale Lage eines Kindbausteins wird also aus der globalen Lage seines Elternbausteins und lokalen Verbindungstransformation abgeleitet
  - durch die rekursive Anwendung dieses prinzips kann gesamte Konstruktion in ein gemeinsames Koordinatensystem eingeordnet werden


- rekonstruierte Modell bildet Grundlage für die dreidimensionale Visualisierung und den Vergleich mit der zuvor ausgewählten Zielstruktur (DET4)

==== Abgleich mit der Zielstruktur
- Für den Zielvergleich ist grundsätzlich der Bausteintyp und nicht die individuelle Identität entscheidend.
- Bausteine desselben Typs können daher untereinander ausgetauscht werden.
- Der Vergleich bestimmt, ob die Ist-Konstruktion:
  - mit einem zulässigen Teil der Zielkonstruktion übereinstimmt,
  - vollständig mit der Zielkonstruktion übereinstimmt oder
  - eine davon abweichende Verbindung enthält.
- Die Identität bleibt erforderlich, um Rückmeldungen einem bestimmten physischen Baustein zuzuordnen.


=== Feedbackrückkanal 
- Aus dem Zielvergleich berechnet die Lernanwendung einen Feedbackzustand für die Gesamtkonstruktion und für die einzelne Bausteine
  - digitales Konstruktion und globales/digitales Feedback werden unmittelbar in der Lernanwendung dargestellt
  - für lokales Feedback an den Bausteinen werden diese über ihre Identität addressiert

=== Zusammenfassung

== Aufgaben- und Interaktionskonzept
Das Aufgaben- und Interaktionskonzept konkretisiert, wie die Lernenden die Nachbauaufgabe bearbeiten und welche Handlungsmöglichkeiten ihnen zur Verfügung stehen
=== Aufgabenlogik
- Die Ist-Konstruktion wird nach jeder erkannten Veränderung mit der Zielkonstruktion verglichen.
- Eine Teilkonstruktion gilt als zulässig, wenn ihre Bausteine und Verbindungen Bestandteil der Zielkonstruktion sind.
- Für die Bewertung sind deshalb bausteintyp, Verbindungsseite, räumliche Position und Orientierung relevant
-> individuelle Identität eines Bausteins ist dabei nur für seine technische Erkennung und die Zuordnung des lokalen Feedbacks erforderlich, Bausteine desselben Typs sind also für die Lösung grundsätzlich austauschbar.

- Die Baureihenfolge ist nicht vollständig vorgegeben, es führen also mehrere Baureihenfolgen? zum selben Zielergebnis #req("TUI1") -> ein untergeordneter Baustein kann jedoch erst angebracht werden, wenn sein übergeordneter Baustein bereits vorhanden ist

- Die Aufgabe ist abgeschlossen, sobald die Ist-Konstruktion vollständig mit der Zielkonstruktion übereinstimmt

=== Handlungsmöglichkeiten und Korrektur
- Die Lernenden sollen innerhalb des vorgegebenen Aufgabenziels unterschiedliche Aufbauwege erproben können -> bereits verbundene Bausteine können deshalb:
  - wieder getrennt
  - gedreht
  - an einer anderen Aufnahmeseite angebracht
  - durch einen anderen Baustein des erforderlichen Typs ersetzt werden

-> Fehlerhafte Handlungsschritte führen nicht zum Abbruch oder Neustart der gesamten Aufgabe #req("IA5")

-Da die physische Konstruktion während der Bearbeitung sichtbar, überprüfbar und unmittelbar veränderbar bleibt,  entsteht eine strukturierte Offenheit #req("TUI1")

=== Anpassung des Schwierigkeitsgrades
- Der Schwierigkeitsgrad soll an unterschiedliche Lernvoraussetzungen angepasst werden können #req("TUI2").

- Eine Anpassung ist insbesondere über folgende Merkmale möglich:
  - Anzahl der Bausteine: wenige Bausteine für einfache, mehr Bausteine für umfangreichere Aufgaben
  - räumliche Ausdehnung: Konstruktionen in einer, zwei oder drei Raumrichtungen,
  - Struktur: lineare oder verzweigte Konstruktionen
  - Rotation: gleiche Ausrichtungen oder unterschiedliche Rotationen in 90-Grad-Schritten
  - Bausteintypen: Verwendung eines einzigen oder mehrerer unterschiedlicher Typen
  - Darstellung der Vorlage: vollständige oder schrittweise Darstellung der Zielkonstruktion
  - Unterstützungsumfang: Rückmeldung zum Ergebnis oder zusätzliche Hinweise auf mögliche nächste Schritte

== Visualisierungs- und Feedbackkonzept
ÜBERLEITUNG

enthält:
- Visualisierung der Ziel- und ist- Konstruktion
- Verbindung von Visualisierung und Feedback
- Feedbackebenen und -Arten

- Das in Kapitel X.6 beschriebene digitale Strukturmodell bildet Grundlage für die Darstellung und Bewertung der physischen Konstruktion
- Lernanwendung soll Lernenden sichtbar machen, welchen Aufbau das System erkannt hat und darauf aufbauend die ergebnisse des Vergleichs zwischen Ist- und Zielkonstruktion als Feedback darstellen
- Visualisierung und Feedback erfüllen unterschiedliche, aber eng miteinander verbundene Funktionen:
  - Visualisierung: repräsentiert erkannten Systemzustand = interaktionsfeedback
  - Feedback: bewertet Zustand im Hinblick auf Bauaufgabe = pädagogisches Feedback
  => Lernenden können zuerst nachvollziehen, ob und wie ihre handlung vom System erkannt wurde und anschließend erkennen, ob eine Korrektur erforderlich ist

=== Visualisierung der Zielkonstruktion
- Zu Beginn der Bauaufgabe wählt das Kind in der Lernanwenung eine Zielkonstruktion aus, die während der Bearbeitung als visuelle Referenz verfügbar bleibt
- abhängig vom gewählten Schwierigkeitsgrad kann die Zielkonstruktion vollständig oder schrittweise dargestellt werden [TUI2, FB4]
  - Vollständige Darstellung ermöglicht den Lernenden, den Aufbau eigenständig zu analysieren und eine eigene Vorgehensweise zu planen
  - schrittweise Darstellung kann  den jeweils nächsten Teil der Konstruktion hervorheben und dadurch zusätzliche Orientierung bieten
-Die Zielkonstruktion und die erkannte Ist-Konstruktion müssen visuell eindeutig voneinander unterscheidbar sein -> darstellung entweder in getrennten Ansichten oder räumlich klar voneinander abgegrenzt

FRAGE: in der aktuellen Darstellung wird die Visualisierung der Zielkonstruktion während des Bauens nicht dargestellt. Ziel ist es aber genau diese beschriebene Visualiserung bis zum zeitpunkt wo ich das projekt abgeben muss noch zu realisieren. Wie soll ich das also schreiben? 

=== Visualisierung der erkannten Ist-Konstruktion
- Nach jedem Erfassungsvorgang wird die von Lernanwendung rekonstruierte Ist-Konstruktion dreidimensional dargestellt 
-> jeder erkannte Baustein wird entsprechen seines Typs, seiner berechneten Position und Orientierung so wie sein vom feedback abhängigen Aussehens in die Szene eingefügt
- indem die digitale Darstellung den Lernenden zeigt, welche Konstruktion das System aus ihren Handlungen abgeleitet hat, wird die Anforderung des Interaktionsfeedbacks erfüllt #req("FB1"):
  beispiel: Erscheint ein hinzugefügter Baustein an der tatsächlich positionierten Position, ist erkennbar, dass seine Verbindung technisch verarbeitet wurde. Fehlt ein Baustein oder wird er anders dargestellt als physisch angeordnet, weist dies auf ein mögliches Erkennungsproblem hin

- Da die Darstellung die physische Konstruktion möglichst konsistent abbilden muss #req("TUI3"), orientieren sich die digitalen Bausteinmodelle an der Form und dem Aussehen der realen Bausteine
- die zwei unterschiedlichen Bausteintypen Würfelbaustein und smashed Bausein werden durch entsprechende digitale Modelle repräsentiert, wodurch die Zuordnung zwischen physischem Gegenstand und digitaler Darstellung nachvollziehbar bleibt

- Um die dreidimensionale Szene aus unterschiedlichen Perspektiven betrachten zu können, unterstützt die Ansicht Dreh- und Skalierfunktion. So können insbesondere bei verzweigten Konstruktionen die räumlichen Beziehungen besser wahrgenommen werden
- Die Darstellung soll jedoch zu Beginn automatisch so ausgerichtet werden, dass die Vorderansicht (+y richtung) der gesamten Konstruktion dargestellt wird

=== Verbindung von Visualisierung und Feedback
- Die Darstellung der Ist-Konstruktion wird um die aus dem Zeilvergleich abgeleiteten Feedbackinformationen für die Bausteine ergänzt
-Während die Kopplung zwischen Bausteintyp und digitaler Geometrie statisch festgelegt ist, werden die dargestellten Feedbackzustände während der Nutzung dynamisch zugewiesen

Für die Visualisierung werden insbesondere folgende Zustände der Bausteine benötigt:
- korrekt erkannter und platzierter Baustein
- technisch erkannter, aber inhaltlich abweichender Baustein
- noch nicht besetzte, aber zulässige Position
- noch nicht zugängliche beziehungsweise blockierte Position

Um die unterschiedlichen Zustände für die lernenden sichtbar zu machen, werden unterschiedliche farbige Hervorhebungen für die Bausteine verwendet
  - Korrekte und abweichende Bausteine werden durch unterschiedlich Umrandungen oder Herborhebungen in den Farben grün oder rot gekennzeichnet
  - Mögliche nächste Positionen lassen sich als transparente Platzhalter beziehungsweise sogenannte Ghost Cubes darstellen
  - Noch nicht zugängliche Positionen werden nicht angezeigt, damit keine Handlungsmöglichkeiten suggeriert werden, die zu diesem Zeitpunkt noch nicht möglich sind

so kann die Rückmeldung eindeutig dem jeweils betroffenen Baustein zugeordnet werden #req("FB2")

=== Feedbackebenen
Neben dem visualisierten digitalen Feedback in der Lernanwendung wird außerdem an jedem baustein lokal mit hilfe einer lichtanzeige das digitale Feedback wieder aufgegriffen

- Das System kombiniert also drei Feedbackebenen:
  - intrinsisches physisches Feedback: entsteht durch die mechanische Führung und magnetische Unterstützung der Verbindung -> Beim Verbinden können die Lernenden unmittelbar wahrnehmen, dass zwei Bausteine mechanisch miteinander verbunden wurden -> feedback bestätigt jedoch weder elektronische Erkennung noch inhatliche Korrektheit der Platzierung
  - lokales digitales Feedback: wird direkt an den betreffenden Bausteinen ausgegeben. Durch ein grünes oder rotes Licht wird angezeigt, ob der verbundene Baustein korrekt platziert wurde oder überprüft werden muss
  - globales digitales Feedback: wird in der Lernanwendung ausgegeben. kann neben dem Zustand einzelner Bausteine auch die gesamte Konstruktion, den Aufgabenfortschritt und mögliche nächste Handlungsschritte darstellen -> ermöglicht damit ausführlichere Rückmeldungen, als sie durch die begrenzten Ausgabemöglichkeiten eines einzelnen Bausteins möglich wären
-> dadurch erfolgt das Feedback zwar nicht multidimensional #req("IA6"), aber auf mehreren Ebenen

- Lokales und globales Feedback müssen jedoch inhaltlich übereinstimmen -> wird Baustein lokal als korrekt gekennzeichnet, muss er auch in der digitalen Konstruktion denselben Zustand besitzen

=== Arten des Feedbacks
- Auf Grundlage des theoretischen Hintergrunds wird zwischen Interaktionsfeedback und päfagogischem Feedback unterschieden (kapitel) #req("FB1")

- Interaktionsfeedback
  - zeigt, ob und wie die physische Handlung technisch erfasst wurde, indem der in kapitel x beschriebene erkannte Ist-Zustand der Konstruktion visualisiert wird 

- pädagogisches Feedback 
  - bewertet den erkanten Zustand im Hinblick auf die Zielkonstruktion und kann dabei drei Funktionen erfüllen
  - Ergebnisfeedback zeigt, ob ein Baustein beziehungsweise eine Verbindung korrekt ist.
  - Fortschrittsfeedback macht durch einen Fortschrittsanzeige sichtbar, weiviel der Zielkonstruktion bereits erreicht wurde.
  - Feedforward weist auf eine mögliche nächste Handlung oder Position hin.
-> Für  Prototyp bilden das Ergebnisfeedback und Fortschrittsfeedback die grundlegende Rückmeldung. Feedforward ergänzt diese abhängig vom vorgesehenen Unterstützungsumfang

TABELLE WO EINBINDEN
#figure(
  table(
    columns: 4,
    stroke: none,

    table.header[Rückmeldungsfall][lokales Feedback][Visualisierung in der Lernanwendung][Art des Feedback],

[Verbindung erkannt und korrekt],	[positive Lichtrückmeldung am betroffenen Baustein], [Baustein wird farblich als korrekt hervorgehoben], [Ergebnisfeedback],

[Verbindung erkannt, aber inhaltlich abweichend],	[negative Lichtrückmeldung am betroffenen Baustein], [Baustein beziehungsweise betroffener Bereich wird farblich als abweichend hervorgehoben], [Ergebnisfeedback],

[zulässige nächste Position],	[keine lokale Ausgabe], [optionale Darstellung als transparenter Ghost Cube], [Feedforward],

[Teilfortschritt erreicht],	[keine lokale Ausgabe], [Fortschrittsanzeige wird aktualisiert], [Fortschrittsfeedback],

[Zielkonstruktion vollständig], [keine lokale Ausgabe],	[erfolgreicher Abschluss wird angezeigt], [Ergebnisfeedback],
  ), 
    caption: [Feedbackfälle?],
) <rückmeldungsfälle>

==== abgestufte Unterstützung
- Das Interaktionsfeedback soll zeitnah nach der auslösenden handlung erfolgen #req("DET7"), damit die Systemreaktion einfeutig der Verbindung zugeordnet werden kann. - Auch das Ergebnisfeedback soll zeitnah anzeigen, ob die erkannte Verbindung mit der Zielkonstruktion übereinstimmt.
- Weiterführende Hilfestellungen werden dagegen wie in den Anforderungen #req("FB3") und #req("FB4") gefordert abhängig vom Unterstützungsbedarf abgestuft angeboten:
  - zunächst wird lediglich eine Abweichung am Baustein durch die farbliche Hervorhebung angezeigt
  (- anschließend kann weitere Hilfe in Form einer Erklärung bereitgestellt werden)  
  - bei weiterem Unterstützungsbedarf können zusätzlich die zulässigen nächsten Bausteine/Ghost Cubes dargestellt werden = Feedforward
  - auch die Visualisierung der Zielkonstruktion kann je nach Unterstützungsbedarf nach den in Kapitel (Visualisierung der Zielkonstruktion) unterschiedlichen Darstellungsweisen abgebildet werden

-> Damit bleibt die Möglichkeit zur eigenständigen Fehleranalyse erhalten, während bei Bedarf zusätzliche Orientierung angeboten werden kann


=== Zusammenfassung






  
