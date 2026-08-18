

= Related work
The (following) chapter  will compare works with siminalr goals/die erkennung von konstruktionen mit bausteinen machen to further establish the academic state of the art. 

Physische Bausteinsysteme haben sich als vielversprechende Tangible User Interfaces (TUIs) etabliert, da sie durch ihre physische Beschaffenheit und haptische Rückmeldung eine intuitive Montage digitaler Informationen ermöglichen. Die Forschung in diesem Bereich lässt sich grundlegend in aktive und passive Systeme unterteilen

Prinzip aktiver Bausteine

    Stromversorgung: Aktive Bausteine sind „powered“, was bedeutet, dass sie entweder über Batterien verfügen oder über Kabel (Tethering) mit Strom versorgt werden müssen.
    Komponenten: Sie enthalten eingebettete elektronische Schaltungen, wie Mikroprozessoren (z. B. Neuron-Chips bei ActiveCube oder ATmega-Chips bei roBlocks) und Sensormodule.
    Kommunikation: Diese Steine können über elektrische Steckverbinder direkt miteinander kommunizieren, um ihre Topologie zu bestimmen.
    Vorteile: Sie ermöglichen eine sehr zuverlässige Erkennung von Stapelvorgängen und können durch die lokale Stromquelle komplexe Aktoren wie Motoren, Displays oder LEDs antreiben.

Prinzip passiver Bausteine

    Stromlosigkeit: Passive Bausteine sind unpowered und batterielos.
    Erkennung: Da sie keine interne Intelligenz besitzen, sind sie auf eine zentrale externe Plattform angewiesen, welche die Erkennung übernimmt. Dies kann über optische Marker und Kameras (DuploTrack), Glasfaserbündel (Lumino), kapazitive Durchleitung (CapStones) oder RFID-Sensing (RFIBricks) geschehen.
    Wartung: Da keine Batterien geladen oder getauscht werden müssen, gelten diese Systeme als wartungsfrei.

== passiv
computer vision tracking
- verwenden kamera um die position, orienierung oder identität der physischen bausteine zu bestimmen.
  - duplotrac nutzt so ein system: indem es durch eine rgb-d kamera die tiefendaten und farbinformationen der bausteine auswertet, kann es in echtzeit assistenz beim entwerfen und bauen von legoduplo modellen bereitstellen
  nachteile eines solchen prinzips: die sicht der kamera darf nicht eingeschränkt sein sondern muss immer das ganze konstrukt aufnehmen können -> fehleranfälligkeit bei verdeckungen der bauteile durch die hände des nutzers. auch nötige klaibierungseinstellungne der kamera 

  - eine infrarot kamera verwendet hingegegen xy. bei seinen lumino blöcken setzt er auf visuelle marker (fiducial) und ein licht leitendes glasfaserbündel das die visuellen marker auf eine tischüberfläche leitet und dort skaliert. Die interne infrarot kamera des tisches liest dann die zusammengesetzten masrker bilder aus. aufgrund des hohen lichtverlusts an den übergängen zwischen den glasfasern wird die stapelhöhe allerdings auf 5 lagen begrenzt 


Capstones nutzt ein anderes/kapazitives Erkennungsprinzip (: Das Konzept) und dient dazu, mobile Anwendungen auf kapazitiven Touchscreens durch haptische spielsteine zu erweitern. 
Indem die Kapazität des menschlichen Nutzers über ein System aus internen Drähten und Verbindungsstiften von der Oberseite eines Stapels bis zum Touchscreen "durchgeleitet" wird, kann die 3D Anordnung der Spielsteine auf herrkömmlichen Endgeräten erkannt werden. Nutzer können die Blöcke auf der Bildschirmfläche platzieren, verschieben und zu vertikalen Stapeln kombinieren. Da die Eigenkapazizät der internen Drähte bei zunehmender Länge jedoch den Schwellenwert des Sensors überschreiten wird die Stapelhöhe auf wenige 3-4 Lagen begrenzt. Außerdem müssen die Blöcke immer berührt werden um sichtbar zu sein, da die Sensoren aktueller Tablets allerdings auf spezifische Schwellen werte für die Berührungserkennung kalibriert sind.


Das kapazitive erkennungsprinzip wird bei dem Protobricks system noch um einen farbsensor ergänzt: während kapazitive berührungssensoren in der basisplatte den menschlichen körper durch das leitfähige Filament der Steine hindurch registrieren und so die x- y und z position dieser erkennen können, bestimmt der Farbsensor um welche farbe und damit typ es sich bei dem gesetzten baustein handelt.  Die Erfassung von Informationen zur spezifischen Orientierung (Rotation) der einzelnen Würfel ist allerdings nicht möglich. Auch müssen die steine immer einzeln nacheinander platziert werden, da das System sonst nur eine Aktion erkennt.


Neben kamera und kapazitiv kann auch mit einer kontaktlose Funk- und Identifikationstechnik die baustein konstruktion erkannt werden. die bausteine sind bei diesem prinzip auc hpassiv, da sie batterielos arbeiten und die benötigte energie drahtlos vom rfid lesegerät beziehen.

xy nutzt ein solches funkbasiertes Erkennungsprinzip auf Basis von UHF-RFID Tags. Seine RFIBricks dienen dabei als interaktives System für die physische 3D-Modellierung, tangibles Programmieren oder haptisches Gaming. 
 Indem herkömmliche RFID-Tags in zwei Komponenten (Chip und Antenne) zerlegt und mit leitfähigen Neodym-Magneten versehen werden, entstehen batterielose Kontaktschalter, die ihre ID erst dann an das Lesegerät können, wenn sie physisch miteinander verbunden werden. Die relative Orientierung zweier Bausteine wird dadurch erkannt, dass sich auf den Oberflächen der Würfel vier solcher RFID Kontaktschalter, befinden die je nach Drehung eine spezifische ID-Kombination auslösen. Da sich diese Kontakte allerdings wegen der sonst zu höhen Komplexität und Dichte an Tags nur auf der Ober und Unterseite eines würfels befinden, können nur eindimensionale Konstruktionen gebaut werden. 

RFIMatch ist eng mit RFIBricks verwandt und nutzt ebenfalls modifizierte UHF-RFID-Tags mit Magneten, um eine batterielose Identifikation zu ermöglichen. Der wesentliche Unterschied besteht darin, dass RFIMatch auf eine kontaktlose und orientierungsunabhängige Erkennung setzt, anstatt auf physische Steckverbindungen und präzise Ausrichtung angewiesen zu sein.

Da sich die Technik der beidem Konzepte aber im Bereich der Ultra High freuqnz befindet, sind die notwendigen UHF-RFID-Lesegeräte  teuer, sperrig und stromintensiv (quelle nfcstack). 

Das Konzept NFCStack nutzt dagegen einen kostengünstigen MFRC522 NFC-Reader von etwa 10-20euro, um die Wartungskosten so gering wie möglich zu halten. Anstelle im UHF bereich basiert die erkennung auf einer Basisstation mit einem gemultiplexten NFC-Leser, dessen Signal über Antennenerweiterungen in den Blöcken (Übertragungsleitungen oder Relais-Spulen) bis an die Stapelspitze geleitet wird. Die Bausteine nutzen physische magnetverbinder oder induktionsspulen für die signalweiterleitung. genau so wie bei den RFIbricks kann so   eindeutige Identität jedes Blocks, seine Position im Stapel sowie seine Orientierung im System identifiziert werden, allerdings auch nur eindimensional stapelbar. 


Die begrenzte Sende-Bandbreite der RFID Technologie führt allerdings bei allen drei Konzepten dazu, dass das System bei einer zu hohen anzahl von gleichzeitigen aktiven tags an zuverlässigkeit verliert. 
Zudem ist die Stapelhöhe physikalisch limitiert, da die Signalstärke bei zunehmender Enterfnung zur Antenne abnimmt. 



== Aktiv
blöcke können auch aktiv sein
dabei beudeted aktiv dass und ID jedes bausteins zur erkennung
die informationen für die erkennung wandern dabei entwerde durch eine phxisische kette von bausteinen zum computer (active cube)
oder die bausteine senden ihre informationen direkt an computer und kommunizieren gar nichtoder nur teilweise miteinander (nutzen ihre nachbarschaft nur für aktivierung des kind cubes oder vcc weiterlietung)

so ein prinzip verfolgt eblock von xy. 
  - eblock ist ein greifbares programmierwerkzeug bei dem kinder physische blöcke in einer sequenz anordnen müssen um einen pfad für eine spielfigur zu programmieren
  - sobald ein block aktiviert wurde sendet er seinen identitätscode per funkt an eine empfängerbox am computer
  - kommunikation zwischen bausteinen ist auf ein aktivierungssignal bregrenzt: mit hilfe eines infrarot signal aktiviert der parent brick dabei seinen child brick - der wiederum opens infrarot transmitter für den nächsten baustein nachdem er die id n den pc übertragen hat 
  - dadurch dass er sequenziell jede würfelseite aktiviert (= parent child logik weil fest definierte rollen für datenweitergabe zw bricks bzw aktivierung) und niht alle gleichzeitig aktiviert er nacheinander auch seine verbundenen würfel/senden die verbundenen bausteine nacheinander ihre id an pc -> der pc bestimmt dann anhand der ankunftszeit die reihenfolge der verbundenen blöcke und rekonstruiert die eindimensionale Struktur 
  
  - auch das digitale pädagogische Werkzeug, das die kognitive entwicklung unterstützen soll,  i block nutzt dieses round robin prinzip zur erkennung der nachbarschaftsbeziehungen 
    - die erkennung verfolgt dabei lokal über induktive sensoren nach dem fire-latch prinzip
    - erklärung fire lätch prinzip
    - da jede seiner quafratischen würfelflächen 4 symmetrisch angeordnete induktive emfpänger hat, löst der sender auf der gegenüberliegenden fläche des benachbarten würfels einen der 4 empfänger aus -> anders als e block weiß cube also zusaätzlich zu den verbundnen flächen auch wie relativ rotiert zueinander die würfel sind (relative orientierungsbestimmung)
    - jeder würfel sendet dann mithilfe seines eigenen Funkmoduls die gesammelten infos (über verbundene flächen und rotation) zum host PC 
    - damit ensure contacting facets of block stays attached werden 4 magnete auf jeder seitenfläche verwendet 
    (ermöglicht 3 dimensionale konstruktionen zu erfassen mit vollständigen orientierung und rotationserkennung) 

- magnete werden auch bei ro block verwendet, allerdings nicht nur zur ausrichtung und verbindung sondern als magnetische elektrische kontakte 
  - bei xy konzipierten bausteinen bilden die blöcke mithilfe dieser kontake ein ad hoc netzwerk und senden bzw broadcasten ihre daten über das gesamte Netzwerk. die kommunikation mit dem PC erfolgt über einen eigenen block, den sogenannten "comm block", der die gesammelten Netzwerkdaten per Funk an PC leitet
  - informationsasmmlung über die topology wird auch von diesem gesteuert, da er alle verbundenen blöcke über das ad hoc netzwerk abfragt und dadurch die konstruktion rekonstruiert (blöcke erstatten dann bericht über ihre topology)
  - zustätzlich zum "comm block" gibt es noch einen anderen speziellen block den power block der über die magnet kontakte die stromversorgung einmal durch alle bricks durchleitet. dadurch brauchen die bricks selber kein batteriemodul, wie das bei i block und e block der fall ist 

- nachteile des funk ist ?

ein gleiches versorgungsprinzip befindet sich auch in den activecubes, bei dem der base cube die energie liefert. 
- der elektrische kontakt zwischen den verbundenen bausteinen wird dabei drei konzentrische terminals in der mitte jeder wüürfelfläche für das netzwerk und gnd plus zusätzliche mechanische verbindungshaken für die stromversorgung hergestellt. Die active cubes bilden dabei ein kabelgebundenen rs-585 netzwerk und kommunizieren mittels LON technologie.
-> anders als bei den anderen bisher genannten konzepten, kommuniniziert also nicht jeder baustein oder gesammte gruppe drahtlos mit der empfangsstation, sondern die infos wandern durch die physische kette zum computer. 
- child würfel broadcastet automatisch seine cube if und face id (welche seite verbunden) an das netztwerk und gleichzeitig sendet der parent würfel seine cube id und face id der seite an die der neue würfle angesteckt wurde in den bus, der am basecube zusammenläuft. 
- die info über face id erhalten die blöcke über einen der verbindungshaken für die stromversorgung -> der vierte haken dient als spezielles eingangsterminal "input hook" für die flächenerkennung:
  - Lokalisierung der Fläche: der child cube erkennt an seinem eigenen Input-Haken, dass Spannung anliegt. Da jede Seite nur einen solchen Input-Haken hat, weiß der Würfel sofort, welche seiner sechs Seiten gerade verbunden wurde.
  - Broadcasting: Der Child-Würfel sendet (broadcastet) daraufhin automatisch seine eigene Cube-ID, seine Face-ID (die Seite, über die er verbunden wurde) sowie die Information über den detektierten Kontakt an das Netzwerk.
  .- Rückmeldung des Parents: Gleichzeitig sendet der Parent-Würfel ebenfalls seine Cube-ID und die ID der Fläche, an der der Kontakt zum Kind stattgefunden hat
- Der Host-PC empfängt diese Informationen und sieht: „Ich bin Würfel B und wurde an meiner Oberseite verbunden.“ Gleichzeitig sendet Würfel A: „Ich bin Würfel A und an meiner rechten Seite ist gerade jemand angedockt.“. Er aktualisiert daraufhin in Echtzeit den sogenannten Connection-Status Tree (CS-tree) – eine digitale Baumstruktur, die die gesamte physische Konstruktion im Speicher des Computers abbildet -> base cube als brücke der gesammelte info der struktur an host pc leitet 
- durch diesen aufbau kann es zur intuitiven 3d modellierung für anwendungen wie  Flugsimulationen, die Suche nach 3D-Modellen oder kognitive Beurteilungen eingesetzt wird


dadurch dass bausteine strom haben, können sie auch andere module wie sensoren, licht etc ansteuern:
  - active cube: verschiedene funktionswürfel mit verschiedenen komponenten wie gyrosensoren, vibratoren oder led matrizen 
 - i-cube: leds zur beleitung jeder facette, vibrationslautsprecher für lokale audioausgabe
 - roblock: system bietet spezoelle aktorblöcke. die getriebemotoren, piezoelektrische lautsprecher oder leds enthalten
 - e block: jeder block besitzt led modul auf pberseite für statusrückmeldung
 - active cube: verschiedene funktionswürfel mit verschiedenen komponenten wie gyrosensoren, vibratiren oder led matrizen 


== comparison
Allgemeiner Vergleich: Aktiv vs. Passiv

    Aktive Bausteine (mit Mikroprozessoren/Batterien):
        Vorteile: Sie ermöglichen eine sehr zuverlässige Erkennung von Stapelvorgängen und Verbindungen. Durch eine lokale Stromquelle können sie komplexe Interaktionen mit integrierten Sensoren, Aktoren oder Displays (z. B. LEDs, Motoren) unterstützen/: Aktive Bausteine bieten durch lokale Energie reichhaltigere multimodale Interaktionen (Licht, Sound, Bewegung),.
        Nachteile: Sie erfordern einen hohen Wartungsaufwand für das Laden oder den Austausch von Batterien. Zudem führen sie zu hohen Hardwarekosten, was die Skalierbarkeit bei großen Stückzahlen einschränkt. Physische Kabelverbindungen können zudem die Bewegungsfreiheit der Nutzer einschränken.
    Passive Bausteine (Vision, Kapazitiv, RFID/NFC):
        Vorteile: Sie sind wartungsfrei und batterielos, was sie ideal für den Einsatz in großen Mengen macht. Die Systeme sind oft einfacher und kostengünstiger in der Bereitstellung.
        Nachteile: Sie bieten oft nur einen begrenzten ID-Raum oder eine eingeschränkte Stapelhöhe. Kamerabasierte Systeme leiden unter Verdeckungsproblemen (Okklusion) durch die Hände der Nutzer und sind oft auf teure externe Hardware wie Spezialdisplays angewiesen.


nachteile und vorteile aktiv und passiv
aktiv
  - jeder cube benpötigt stromversorgung, wenn eigenes batterimodul dann teuer und muss immer wieder laden -> zentrale stromversorgung wie bei active cube und roblock über einen zentralen power cube als lösung
  - vorteil dadurch dass die bausteine schlau sind können sie mithelfen bei der topologie erkennung 
  - um jedoch vollständige orientierung mit flache und rotation kann es dazu führen dass die bausteine ganz schln komplex werden aufgrund dass weitere module oder kontakte notwendig sind oder bus?
  - theorethisch unendlich viele bausteine - wird nur von stromvergorgung begrenzt
  - dadurch dass bausteine strom haben, können sie auch andere module wie sensoren, licht etc ansteuern

- das geht bei passiv einfacher weil da nur ein hauptmodul die ganze logik übernimmt
- aber vom hauptmodul hängt es dann auch ab wieviele info man bekommt 
  - Kamera alle aber zusätzlicher aufwand wegen kalibrierung
  - nfc/rfid reader teuer, bzw nur begrenzte reichweite und dadurch anzahl der bausteine
  - magnete komplex und ungenau
  - das geht bei kamera theoretisch einfacher weil da nur das hauptmodukl die gannze logik übernimmt
  - keine zusätzlich verbaute technik die irgendwie rückmeldung (led) geben kann weil die bausteine keine energie haben
  - nachteil stapelhöhe ist begrenzt 

was ist aber das problem das bleibt und mein konzept dann löst 


= Related Work

This chapter reviews block-based tangible user interfaces (TUIs) that pursue goals similar to those of the system developed in this work, particularly the automatic detection of physical constructions assembled from building blocks. Physical building-block systems have become a promising form of TUI because their material properties and haptic feedback allow users to manipulate digital information through familiar physical actions. Existing approaches can broadly be divided into systems employing passive blocks and systems employing active blocks.

In this context, passive blocks do not perform local computation and do not require an individual power supply. Instead, their identity, position, orientation, or connectivity is determined by an external sensing system. Depending on the implementation, this detection may rely on computer vision, optical fibres, capacitive sensing, or RFID technology. Although passive RFID tags contain electronic components, they are classified as passive because they have no battery and obtain the required energy from an external reader.

Active blocks, by contrast, contain embedded electronic components, such as microcontrollers, sensors, or communication modules, and actively participate in the detection process. They may be powered by individual batteries or receive power through electrical connections between adjacent blocks. Active blocks can communicate directly with a host computer or exchange information with neighbouring blocks before forwarding the resulting topology data to a central system.

== Passive block systems

=== Computer-vision-based detection

Computer-vision-based systems use one or more cameras to determine the identity, position, or orientation of physical blocks. DuploTrack employs such an approach to provide real-time assistance during the design and construction of LEGO Duplo models. An RGB-D camera captures both colour and depth information, from which the system reconstructs the arrangement of the blocks [citation].

A general limitation of camera-based detection is that the relevant parts of the construction must remain visible. Blocks may be temporarily occluded by other blocks or by the user’s hands, potentially resulting in incomplete or incorrect detection. Moreover, the camera usually has to be positioned and calibrated according to the dimensions and lighting conditions of the interaction area.

Lumino addresses the detection of vertically stacked blocks using optical markers and light-conducting fibre bundles. Each block contains a fibre bundle that transfers its fiducial marker to the surface of an interactive table. An infrared camera integrated into the table captures the resulting composite marker image and uses it to reconstruct the stack [citation]. Because light is lost at the transitions between adjacent fibre bundles, however, the maximum stack height is limited to approximately five layers [citation].

Thus, both DuploTrack and Lumino rely on optical sensing, but they differ in how the visual information is made accessible to the camera. Whereas DuploTrack observes the construction externally, Lumino transfers information through the individual blocks to a camera beneath the interaction surface. The latter approach enables the detection of stacked blocks but requires specially constructed optical blocks and an instrumented table.

=== Capacitive detection

CapStones uses capacitive sensing to extend applications on conventional touchscreens with graspable physical objects. Conductive wires and contact pins inside the blocks transfer the capacitance of the user’s body from the top of a stack to the touchscreen. This allows users to place and move blocks on the display and combine them into vertical structures whose configurations can be interpreted by the application [citation].

The approach does not require batteries or active electronic components within the blocks. However, the blocks generally have to be touched by the user to remain detectable. Furthermore, the intrinsic capacitance of the conductive paths increases with the height of the stack. Once it exceeds the threshold supported by the touchscreen, reliable detection is no longer possible. Consequently, the reported stack height is limited to approximately three or four layers [citation].

ProtoBricks combines capacitive detection with colour sensing. Capacitive sensors integrated into the base detect the user’s body through the conductive material of the blocks and thereby determine their spatial placement. A colour sensor additionally identifies the colour and, consequently, the type of the currently placed block [citation]. This combination provides more information than capacitive sensing alone. Nevertheless, the system cannot determine the precise rotation of individual blocks. In addition, the blocks have to be placed sequentially because simultaneous changes may be interpreted as a single interaction [citation].

Both systems demonstrate that capacitive sensing can enable passive blocks to interact with touch-sensitive surfaces. Their detection capabilities, however, depend on the conductive connection to the user and are constrained by the sensitivity and calibration of the underlying capacitive sensors.

=== RFID-based detection

Physical block constructions can also be detected using radio-frequency identification. In such systems, passive RFID tags receive their operating energy wirelessly from an external reader and return a stored identifier. This eliminates the need for batteries inside the blocks while allowing individual components to be distinguished.

RFIBricks uses modified ultra-high-frequency RFID tags to detect physical connections between blocks. Each tag is separated into an antenna and a chip component, which are connected through conductive neodymium magnets. The resulting circuit functions as a contact switch: the tag becomes readable only when the corresponding physical connection between two blocks is established [citation]. Four such switches are arranged on the relevant block surfaces. Different combinations of activated tag identifiers allow the system to determine the relative orientation of connected blocks. Because the number and density of required tags would otherwise become difficult to manage, the contacts are restricted to the upper and lower surfaces. The resulting constructions are therefore limited to one-dimensional stacks [citation].

RFIMatch is closely related to RFIBricks and similarly combines modified UHF RFID tags with magnetic elements. In contrast to RFIBricks, RFIMatch is designed to detect associations without requiring precisely aligned physical contacts. Its sensing mechanism is therefore less dependent on the exact orientation and alignment of the interacting objects [citation].

Both approaches operate in the UHF frequency range. The required UHF readers can be comparatively expensive, large, and power-intensive, particularly in relation to readers designed for shorter-range RFID or NFC applications [citation]. NFCStack therefore employs a lower-cost NFC reader based on the MFRC522. A multiplexed reader in the base station transmits its signal through antenna extensions integrated into the blocks. Depending on the block design, this signal is relayed through transmission lines or inductively coupled coils [citation]. Magnetic connectors or inductive coupling between neighbouring blocks continue the signal path towards the top of the stack.

This design allows NFCStack to identify the individual blocks and determine their position and orientation within a stack. Similar to RFIBricks, however, its physical connectivity is restricted to vertical stacking and therefore supports only one-dimensional constructions [citation].

RFIBricks, RFIMatch, and NFCStack all provide battery-free identification. Their scalability is nevertheless constrained by the properties of the radio-frequency communication channel. If many tags respond within the same reading area, collisions and limited communication bandwidth may reduce detection reliability. Furthermore, the achievable stack height is limited because the available signal strength decreases with increasing distance from the reader and with every additional coupling interface [citation].

== Active block systems

Unlike passive systems, active block systems integrate electronic processing and communication components into the individual blocks. The blocks can therefore contribute directly to detecting the construction. The resulting topology information may be transferred through the physical chain of blocks, as in ActiveCube, or transmitted wirelessly by the individual blocks, as in eBlock and i-Cube.

=== Sequential wireless identification

eBlock is a tangible programming tool in which children arrange physical blocks into a sequence to specify the path of a virtual character. When activated, each block transmits its identifier wirelessly to a receiver connected to the host computer [citation]. Communication between neighbouring blocks is limited to the sequential activation process. A parent block uses an infrared signal to activate an adjacent child block. After sending its identifier to the computer, the child enables its own infrared transmitter and activates the next block in the sequence.

Because the connected blocks transmit their identifiers one after another, the host computer can infer their order from the arrival times of the messages and reconstruct the one-dimensional structure. This reduces the amount of direct communication required between neighbouring blocks. However, it also limits the representable topology to a sequential arrangement.

A related sequential principle is used by i-Cube, a tangible educational system designed to support cognitive development [citation]. Neighbouring blocks are detected locally using inductive sensors and a fire-and-latch protocol. Each square face contains four symmetrically arranged inductive receivers. The transmitter on the opposing face of a neighbouring block activates one of these receivers, allowing the system to determine both the connected faces and the relative rotation between the two blocks.

Each i-Cube then transmits the collected connection and orientation information to the host computer using its own radio module. Magnets arranged on the block faces maintain the physical connections. In contrast to eBlock, this design supports three-dimensional constructions and provides information about both connectivity and relative block orientation.

===Networked blocks with shared power

roBlocks also uses magnets, but employs them as both mechanical connectors and electrical contacts. Once connected, the blocks form an ad hoc communication network through which they exchange and broadcast their data [citation]. A dedicated communication block collects the network information and forwards it wirelessly to the host computer. The communication block also initiates topology discovery by querying the connected blocks and collecting their reports about local connections.

A separate power block supplies electrical energy to the network through the magnetic contacts. Consequently, the individual blocks contain embedded processing and communication components but do not require separate batteries. This distinguishes the system from active approaches in which every block has to be charged or equipped with a replaceable battery.

===Wired topology detection

ActiveCube similarly distributes power from a dedicated base cube. Adjacent blocks are connected through electrical terminals and additional mechanical hooks arranged on their faces. The blocks form a wired RS-485-based network and communicate using LON technology [citation]. Unlike systems in which every block communicates wirelessly with the host, ActiveCube transfers connection information through the physical network towards the base cube.

When a new block is attached, both participating cubes report the connection. The child cube transmits its cube identifier and the identifier of the connected face, while the parent cube reports its own identifier and the corresponding face. A dedicated input terminal on each face enables the child cube to determine which of its six faces has received power and has therefore been connected.

The host computer combines these messages to update a connection-status tree that represents the topology of the physical construction. The base cube acts as the bridge between the block network and the host. This architecture allows ActiveCube to reconstruct three-dimensional configurations in real time and has been applied to tasks such as three-dimensional modelling, model retrieval, flight simulation, and cognitive assessment [citation].

=== Integrated sensors and actuators

In addition to contributing to topology detection, active blocks can support local output and additional sensing. ActiveCube includes functional cubes containing components such as gyroscopic sensors, vibration actuators, and LED matrices. i-Cube provides illuminated faces and local audio output through vibration speakers. roBlocks includes specialised actuator blocks equipped with geared motors, piezoelectric speakers, or LEDs, whereas eBlock uses an LED on the upper surface of each block to communicate its current status [citations].

These components enable active systems to provide visual, auditory, or mechanical feedback directly at the point of interaction. Such local feedback is difficult to implement using entirely passive blocks because passive components generally cannot drive sensors, displays, motors, or other actuators without an external supply of energy.

== Comparison of active and passive systems

Active and passive block systems present different advantages and limitations. Active blocks can detect local connections and communicate block identifiers directly, enabling detailed and potentially reliable reconstruction of complex three-dimensional structures. Their local energy supply also supports integrated sensors, lights, sound, vibration, and movement. This permits richer multimodal interaction and allows feedback to be presented directly through the physical construction.

These capabilities increase the hardware complexity of each block. Systems based on individual batteries require charging or periodic battery replacement. Even when power is distributed through the construction, the blocks require microcontrollers, communication circuitry, and electrical contacts. These components increase manufacturing costs and may reduce scalability when a large number of blocks is required.

Passive blocks have a simpler internal construction and generally require less block-level maintenance because they do not contain batteries. They are therefore potentially suitable for applications involving large numbers of physical components. However, the simplicity of the blocks shifts the technical complexity to the surrounding infrastructure, such as cameras, interactive tables, capacitive displays, or RFID readers. The complete system is therefore not necessarily simpler or less expensive.

The limitations of passive approaches depend strongly on the selected sensing principle. Camera-based systems are susceptible to occlusion and may require calibration. Optical and capacitive systems are often restricted in their maximum stack height because of signal loss or increasing capacitance. RFID-based approaches can identify battery-free objects but may be affected by limited reading range, tag collisions, and attenuation through multiple layers. Furthermore, several passive systems support only vertical or otherwise one-dimensional constructions.

The selection between active and passive blocks therefore involves a trade-off between block-level complexity and the capabilities of the overall sensing system. Active blocks provide local processing, detailed topology information, and richer feedback, whereas passive blocks reduce the need for per-block power supplies and electronic maintenance. The suitability of either approach ultimately depends on the required construction space, number of blocks, recognition accuracy, interaction modalities, and acceptable hardware complexity.

Vor der Übernahme solltest du noch vier Angaben anhand der Originalpaper prüfen:

- Ob das System tatsächlich **i-Cube**, **iBlock** oder anders heißt.
- Ob der verwendete Begriff genau **fire-and-latch** lautet.
- ActiveCube verwendet deinen Notizen zufolge **RS-485**, nicht „RS-585“.
- Aussagen wie „reliable“, konkrete Stapelhöhen und technische Einschränkungen benötigen jeweils einen direkten Beleg aus dem betreffenden Paper.