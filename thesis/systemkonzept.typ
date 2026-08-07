= Konzeptentwicklung
im kapitel beschreiben welche Lösung gewählt wurde und warum sie zur Erfüllung der anforderungen geeignet ist (bzw welche lösung aufgrund welcher anforderung gewählt wurde)

== Gesamtkonzept und Nutzungsszenario
- grundidee des würfelbasierten Lernsystems/ was umfasst das Gesamtsystem
- beteiligte Komponenten: Nutzer, Würfel, baseplate und Lernanwendung
-> welche Funktion übernehmen Würfel, Baseplate, Computer
  - diagramm: konzeptionelle Systemarchitektur mit User, Smart Cube System und Learning application 
- Welche Funktionen bleiben für zukünftige Erweiterungen

- Nutzungszenario: grundlegender Ablauf einer Bauaufgabe
  - Ablaufdiagramm der Bauaufgabe aus Sicht des Kindes
    - Eine Lehrkraft wählt eine Zielkonstruktion aus.
    - Das Kind beginnt mit dem Aufbau.
    - Ein Würfel wird verbunden.
    - Das System erkennt Identität, Verbindungsseite und Rotation.
    - Die Gesamtkonstruktion wird aktualisiert.
    - Der Aufbau wird mit der Zielstruktur verglichen.
    - Der Würfel und der Computer geben eine Rückmeldung.
    - Das Kind setzt den Aufbau fort oder korrigiert den Schritt.
    - Der erfolgreiche Abschluss wird angezeigt.

    - ein Kind wählt auf der Learning Application/Computer eine Zielkonstruktion aus
    - Kind beginnt mit dem Aufbau, indem es den ersten Baustein in ? der Baseplate setzt
    - Das System erkennt Identität und Rotation 
    - Die Gesamtkonstruktion wird aktualisiert 
    - der Aufbau wird mit der Zielstruktur verglichen
    3 sachen gleichzeitig
    - Die Gesamtkonstruktion der verbundenen Bausteine wird auf dem Bildschirm digitalisiert (+ die würfel die als nöchstes laut der Zielstruktur verbunden werden könnten)
    - Computer/Bildschirm gibt rückmeldung indem die verbundenen bausteine entweder grün oder rot erscheinen
    - die verbundenen Würfel leuchten grün oder rot auf
    - ---
    Je nach Fall 2 Möglichkeiten
    - Das kind setzt den aufbau mit dem nächsten würfel fort
    - das kind korrigiert seinen schritt und verbindet den falschen Würfel neu
    - der aktuelle fortschritt wird angezeigt
    wenn fertig und alles richtig
    - der erfolgreiche Abschluss wird angezeigt

== ??
Zerlege das System anschließend in seine wesentlichen Funktionen:
Zielkonstruktion bereitstellen → Verbindung herstellen → Baustein identifizieren → Verbindungsseite und Rotation erkennen → Daten übertragen → Gesamtkonstruktion rekonstruieren → mit Zielstruktur vergleichen → Rückmeldung ausgeben

Diese Funktionsstruktur bildet die Verbindung zwischen Anforderungsanalyse und technischer Lösung. Du kannst die Funktionen zusätzlich in vier Teilsysteme gliedern:
- Physisches Teilsystem: Würfel, Gehäuse und Verbindungen
- Elektronisches Teilsystem: Identifikation, Kontakte, Energie- und Datenübertragung
- Softwareseitiges Teilsystem: Rekonstruktion und Vergleich der Konstruktionen
- Interaktionssystem: Aufgabenanzeige, Feedback und Fehlerbehandlung

= Entwicklung und Auswahl von Lösungsprinzipien??
dieser Stelle untersuchst du mögliche Lösungen für die zentralen technischen Probleme. Du solltest nicht für jedes kleine Detail mehrere Varianten vergleichen, sondern vor allem für die Entscheidungen, die dein Gesamtsystem wesentlich prägen.??


== Aufgaben- und Interaktionskonzept
pädagogischen Anforderungen werden konkretisiert
- wie wird eine Zielkonstruktion dargestellt?
- wie genau passiert das bauen?
  - es wird immer mit dem ersten baustein gestartet der sich mit der baseplate verbindet
  - die bausteine müssen nicht in einer bestimmten reihenfolge angebracht werden sondern nur der zielkonstruktion gleichen
  - jeder einzelne schritt wird bewertet
- welche Schwierigkeitsstufen gibt es?
  - unterschiedliche Anzahl benötigter Würfel
  - lineare oder verzweigte Konstruktionen, Konstruktionen in zwei oder drei Raumrichtungen, gleiche oder unterschiedliche Rotationen
  - vollständige oder schrittweise Darstellung der Vorlage
  - Rückmeldung mit unterschiedlichem Unterstützungsumfang - da aufs feedback eingehen?
- kann eine falsch gesetzte Verbindung jederzeit korrigiert werden?
- Welche handlungsmöglichkeiten haben kinder, lehrkräfte und system?

anforderungen:
  - aufgabe muss durch aktives konstruieren und verändern eines physischen artefakts erfolgen - kinder bauen mit unterschiedlichen bausteinen eine dreidimensionale konstruktion nach, Interaktion durch Greifen, Drehen und Verbinden, (konstruktionismus, embodied cognition)
  - konstruktion muss während der bearbeitung sichtbar, überprüfbar und veränderbar bleiben, handlungsschritte müssen korrigierbar sein  - würfel können beliebig oft neu angeordnet und verbunden werden, rückmeldung bleibt auch über gesamten bauvorgang erhalten
  - ziel und aufbau der aufgabe müssen klar und überschaubar dargestellt werden - ?
  - individuelles arbeitstempo und wiederholbar - keine zeitliche begrenzung (kinder werden nicht gestresst) und wiederholbar so lange bis zielkonstruktion erreicht ist
  - schwierigkeitsgrad - schwierigkeitsstufen 
  - physische gestaltung der bausteine - eher bei mechanisches design baustein kapitel 

== Feedback und Visualisierungskonzept
 auf grundlage der feedbackanforderungen wird entschieden, welche info wo dargestellt wird 
- interaktionsfeedback
  - würfel "rasten" durch formschluss und magnete ein 
  - würfel erscheint auf bildschirm in visualisierung
  - led von baustein leuchtet grün/rot
  
- pädagogisches feedback: 
  - rot und grün würfel und computer
  - perspektivisch hilfefenster mit genauen angaben
  - feedback unterscheidung in 
    - ergebnisfeedback (richtig/falsch) - rot/grün
    - feedforward (nächster schritt anzeigen) - ghost bausteine
    - fortschrittsfeedback (anzeige des bereits erreichten) - fortschrittsbalken 

dimension: 
  - lokal: cube; global: bildschirm; 
  - verögert oder unmittelbar: sofort
  - kurz oder dauerhaft: dauerhaft -> sichtbar bis korrekt ist; kontinuierlich: led und bildschirm bleibt grün/rot bzw abhängig von schwierigkeitsstufe

Tabelle mit rückmeldungsfall und dann wie schaut das feedback am würfel und wie am computer aus
rückmeldefälle: verbindung technisch erkannt, baustein korrekt/falsch platziert, verbindung nicht eindeutig erkannt, fortschritt, nächster hinweise/cube
  
  anforderungen 
    - interaktions und pädagogisches feedback: genannt
    - feedback muss deutlich zu zugehörigem würfel sein: 
    - feedback in schritten
    - hilfestellung in schritten
    - feedback via unterschiedlichen ausgabemedien 
        medien: digital: visuell: led in würfel, auf bildschirm rot und grün
                instrinsisch: formschluss und magnete 

== geometrisches, mechanisches und ergonomisches Konzept
beschreiben der physikalischen Gestaltung
- Würfelform und abmessungen
  - anforderung: quatratische grundfläche
  - aus der grundfläche lassen sich 3 types designen: würfel, smashed cube und (pyramide)
  - eine definierte Andockseite (anforderung)
  - weitere aufnehmende Seiten (anforderung)
  -> 3dimensionales verbinden möglich (anforderung)
  - Design von  den verbindungsstellen mit 4 pins für rotationserkennung und 2 pins in mitte für stromversorgung 
  - rotation in 90grad schritten
  - mechanisches und magnetisches Verbindungssystem -> durch das mechanische design können die würfel auch nicht an den falschen seiten verbunden werden (kein kurzschluss)
  - magneten halten würfel zusammen sodass sie nicht auseinanderfallen aber auch nicht zu stark sonst kann man sie nicht auseinander bringen (anforderung)
  - Gehäuse mit den seiten und dem rahmen (anforderung zusammen und auseinanderbauen)

  - Abbildung: Würfel mit Seitenbezeichnungen, Andockseite, Koordinatenachsen und Rotationen
- Basisplatte beschreiben

  
== elektronisches Erkennungs- und versorgungskonzept/Erkennungs-, Daten- und Kommunikationskonzept
- Identifikation der Würfel 
  - jeder würfel hat einen typ und eine ID -> eindeutige identifikaiton (anforderung)
- Erkennung der Verbindungspartner und Seite 
  - nach dem p..? prinzip wird jede seite abgefragt, wenn sich ein würfel meldet, wird auf seine antwort gewartet und dann gesammelt an parent weitergeleitet -> baseplate wird alles gesammelt und ausgewertet (bzw nochmal schauen)
  - parent child prinzip -> abstraktes parent child diagramm
- rotationserkennung - durch die 4 pins (anforderung)
-> ableitung der gesamtkonstruktion aus den lokalen verbindungen (anforderung)
- digitale repräsentation der Konstruktion
- grundlegender Informationsfluss zwischen Würfeln, Basisplatte und Lernanwendung
  - vlt vereinfachter Datenfluss diagramm: Verbindung → Erkennung → Rekonstruktion → Zielvergleich → Feedback
- (Abbildung Gegenüberstellung einer physischen Konstruktion und ihres digitalen Verbindungsgraphen)- wie?
  
elektronisch
- funktionale elektronische Komponenten eines Würfels und der Baseplate
  -> (funktionales blockdiagramm)
- energieversorgung 
  - über basisplatte und die pins - wird an alle verbundenen würfel durchgegeben (anforderung)
- datenübertragung - über direkten kontakt mit pogo pins und einem one wire kommunikationsprotokoll

== Variantenvergleich
tabelle mit design und elektro kriterien und dann bewerten 
  Die Kriterien müssen aus deinem Anforderungskatalog stammen. Dadurch wirkt die Auswahl nachvollziehbar und nicht willkürlich.

== ausgewähltes Gesamtkonzept???

wo Systemarchitektur?
  
