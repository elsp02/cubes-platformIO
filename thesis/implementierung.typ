= Technische Realisierung
Die technische Realisierung beschreibt, wie das zuvor entwickelte Konzept tatsächlich umgesetzt wurde. Hier dürfen konkrete Bauteile, Softwaremodule, Protokolle und Implementierungsentscheidungen genannt werden.

== Mechanische und elektronische Realisierung
=== mechanischer Aufbau
- Aufbau und Herstellung der Bausteine
- Ausgestaltung der Andock- und Aufnahmeseiten
- konkrete Kontakt- und Magnetanordnung 
- vier Rotationen
    - auch Ausnahme dass ein Kontakt auf einer Aufnahmeseite anders als alle anderen positioniert wurden - Rotationsbestimmung im Code anpassen
- grundlegender Aufbau der Baseplate


ABBILDUNGEN: gehäuse, seiten und deckel extra und zusammengebaut, vlt explosionszeichnung
aufbau einer andock und einer aufnahmeseite reales abbild und daneben zeichnung

=== elektronischer Aufbau
  - verwendete elektronische Bauteile
      - ATtiny1616 als Steuereinheit
      - Pogo Pins als Upstream- und Downstream-Schnittstellen
      - LED Ansteuerung
      - Attiny1616
  - Blockdiagramm der zwei Komponenten
  - zentrale Energieversorgung
    - zentrale 5V Energieversorgung via USB Anschluss von UPDI Adapter zu PC 
  - Schnittstelle zur Lernanwendung/PC
  (- auch perspektive mit esp32 und ipad nennen?)

Abbildungen:
  - CAD-Darstellung oder Explosionszeichnung,
  - Fotos des gefertigten Würfels und der Basisplatte,

=== Kontaktierung
- Art der Kontakte
  - Pogo Pins -> können kleine Abweichungen aus dem Herstellungsprozess und geringfügige Bewegungen zwischen den Würfeln ausgleichen
  - Vertiefungen und Führungselemente dienen auch schutz der elektrischen schnittstelle (schutz vor fehlkontaktierung und kurzschluss)

  - feedback mit led 


== Kommunikationsprotokoll 
welche Nachrichten werden wie übertragen?

- zwei Kommunikationsebenen
  - Lernanwendung - Baseplate
  - Elternbaustein (baseplate) - Kindbaustein = Parent-Child Kommunikation
- Parent Child Kommunikation
  - Request-Response-Prinzip 
  - Half-Duplex-Kommunikation
  - grundlegender Aufbau der Nachrichten
    - Aufbau eines Bytes beziehungsweise Nachrichtenrahmens
    - Bit timing
- Baseplate lernanwendung kommmunikation
  - Nachrichtenbefehle
- Übertragung des serialisierten Baums
- Übertragung des Feedbackframes
- grundlegende Fehlerbehandlung durch Timeouts, Wiederholungsversuche und Filterung kurzzeitiger Kontaktstörungen

Abbildungen und Tabelle:
  - Single-Wire-Parent-Child-Diagramm,
  - Bit-Timing-Diagramm,
  - Byte- beziehungsweise Nachrichtenformat,
  - Kommunikationssequenzdiagramm,
  - Tabelle der Kommandos und Antworten wie CMD_START, ACK und ACK_BUSY.


== Firmware von Würfel und Baseplate
 wie reagieren Würfel und Basisplatte auf diese Nachrichten?
=== Würfel Firmware
- Erkennung von Verbindungsseite und Rotation
- rekursive Abfrage der Kindbausteine
- Depth-First Search und Preorder-Reihenfolge
- Bildung und Rückgabe des serialisierten Teilbaums
- Empfang und Ausgabe des Feedbacks
STATE MACHINE BAustein

=== Baseplate Firmware
- Vermittlerrolle zwischen Lernanwendung und Würfeln
- Start des Erkennungsprozesses
- Weiterleitung des serialisierten Baums
- Empfang und Weiterleitung des Feedbackframes
STATE MACHINE Baseplate

gemeinsames SEQUENZDIAGRAMM

== Softwarearchitektur und Lernanwendung 
 wie werden empfangene Daten verarbeitet und dargestellt?
=== Architektur und Datenverarbeitung
- grobe Client-Server-Struktur
- Verantwortlichkeiten der wichtigsten Komponenten
- Empfang und Deserialisierung des Baums
- Berechnung der Positionen und Orientierungen
  - bild mit achsen und seitennamen des bausteins
- Vergleich von Ziel- und Ist-Konstruktion
- Berechnung und Übertragung des Feedbacks
- lokale und globale Feedbackausgabe

ARCHTITEKTURDIAGRAMM
  - Vier-Schichten-Systemarchitekturdiagramm mit Client, Server, serieller Kommunikationsschicht und Hardware

=== Benutzeroberfläche, Visualisierung und Feedback
- Auswahl und Darstellung einer Zielkonstruktion
- visuelle Kennzeichnung korrekter und fehlerhafter Bausteine
  - Abstimmung zwischen globaler Rückmeldung in der Anwendung und lokalem Feedback an den Würfeln
  - feedback mit led 