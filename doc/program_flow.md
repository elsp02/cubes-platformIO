# Elena Cubes – Programmablauf

Zum Rendern in VS Code: Datei öffnen → `Ctrl+Shift+V`.  
Empfohlene Extension: **Mermaid Chart** (von Mermaid Chart, Inc. – offizielle Extension).

---

## 1. Kommunikationsprotokoll

```mermaid 
sequenceDiagram
    participant BP as Baseplate (Root)
    participant A  as Cube A
    participant B  as Cube B (Kind von A)

    Note over BP,B: Polling-Zyklus (wiederholt sich)

    BP->>A: CMD_STATUS (0xAA)
    Note over BP: TURNAROUND_US warten

    Note over A: Orientierung erkennen (einmalig)<br/>oder bekannte Leitung direkt verwenden
    A->>BP: ACK_BUSY (0x55)

    rect rgb(220, 235, 255)
        Note over A,B: Cube A pollt seine Kinder
        A->>B: CMD_STATUS (0xAA)
        Note over A: TURNAROUND_US warten
        B->>A: ACK_BUSY (0x55)
        B->>A: SYNC | LEN | payload_B | CHK
        Note right of B: payload_B = [NODE_ID_B, ori_B, child_mask_B]
    end

    Note over A: Gesamt-Payload aufbauen:<br/>[NODE_ID_A, ori_A, child_mask_A, ...payload_B...]
    Note over A: TURNAROUND_US warten
    A->>BP: SYNC | LEN | payload_A | CHK

    rect rgb(210, 245, 210)
        Note over BP: parse_node() – Baum deserialisieren
        Note over BP: print_tree()  – Ausgabe via Serial
    end
```

---

## 2. Frame-Format

```
SYNC (0xA5) | LEN (1B) | PAYLOAD (LEN Bytes) | CHK (1B)

CHK = XOR(LEN, payload[0], ..., payload[LEN-1])

Payload-Struktur (preorder-serialisierter Baum):
  [NODE_ID] [orientation] [child_mask] [payload Kind 0] [payload Kind 1] ...
   1 Byte     1 Byte        1 Byte       rekursiv

  child_mask: Bit i = 1 --> Kind an Port i vorhanden
```

---

## 3. Cube-Firmware – Hauptschleife

```mermaid
flowchart TD
    START([Start]) --> SETUP[setup: release_all_lines / Serial.begin]
    SETUP --> LOOP([loop])

    LOOP --> ORI_KNOWN{orientation_known?}

    ORI_KNOWN -- nein --> SCAN[scan_upstream: suche LOW auf 4 Leitungen]
    SCAN --> LOW{LOW gefunden?}
    LOW -- nein --> SCAN
    LOW -- ja --> RXDF[rx_byte_data_frame: empfange Byte]
    RXDF -- Fehler --> SCAN
    RXDF -- OK --> ISCMD{b == CMD_STATUS?}
    ISCMD -- nein --> REL1[release all lines] --> SCAN
    ISCMD -- ja --> SETORI[active_upstream = w / orientation_known = true]
    SETORI --> NULLCHK

    ORI_KNOWN -- ja --> RXUP[rx_byte auf active_upstream mit PARENT_TIMEOUT]
    RXUP -- Timeout --> RET1[return] --> LOOP
    RXUP -- OK --> ISCMD2{b == CMD_STATUS?}
    ISCMD2 -- nein --> RET2[return] --> LOOP
    ISCMD2 -- ja --> NULLCHK{active_upstream == nullptr?}

    NULLCHK -- ja --> RST[orientation_known = false / return] --> LOOP
    NULLCHK -- nein --> TURN1[delay TURNAROUND_US]

    TURN1 --> TXACK[tx_byte: ACK_BUSY]
    TXACK --> INITP[payload = NODE_ID / orientation / 0x00 - len=3 / child_mask=0]

    INITP --> IINIT[i = 0]
    IINIT --> ICOND{i < CHILD_COUNT?}
    ICOND -- nein --> WRITEMASK

    ICOND -- ja --> POLLINIT[child_received = false / attempt = 0]
    POLLINIT --> POLL[poll_child i: tx CMD_STATUS - delay - rx ACK_BUSY - rx_frame]
    POLL -- Erfolg --> CROK[child_received = true]
    POLL -- Fehler --> MOREATTEMPTS{attempt < CHILD_RETRIES?}
    MOREATTEMPTS -- ja --> ATTINC[attempt++] --> POLL
    MOREATTEMPTS -- nein --> CHKRCV

    CROK --> CHKRCV{child_received?}
    CHKRCV -- nein --> IINC
    CHKRCV -- ja --> FIT{payload_len + child_len kleiner MAX?}
    FIT -- nein --> IINC
    FIT -- ja --> APPEND[child_mask Bit setzen / child_payload anhaengen]
    APPEND --> IINC[i++] --> ICOND

    WRITEMASK[payload 2 = child_mask] --> TURN2[delay TURNAROUND_US]
    TURN2 --> TXFRAME[tx_frame: SYNC+LEN+payload+CHK an upstream]
    TXFRAME --> RELUP[wire_release upstream]
    RELUP --> RELALL[release_all_lines]
    RELALL --> DBG[Serial debug output]
    DBG --> LOOP
```

---

## 4. Baseplate-Firmware – Hauptschleife

```mermaid
flowchart TD
    START([Start]) --> SETUP[setup: release_all_lines / LED init / Serial.begin]
    SETUP --> LOOP([loop])

    LOOP --> INITP[ordered_payload = NODE_ID / 0x00 / 0x00 - len=3 / child_mask=0]

    INITP --> IINIT[i = 0]
    IINIT --> ICOND{i < CHILD_COUNT?}
    ICOND -- nein --> WRITEMASK

    ICOND -- ja --> POLLINIT[child_received = false / attempt = 0]
    POLLINIT --> POLL[poll_child i: tx CMD_STATUS - delay - rx ACK_BUSY - rx_frame]
    POLL -- Erfolg --> CROK[child_received = true]
    POLL -- Fehler --> MOREATTEMPTS{attempt < CHILD_RETRIES?}
    MOREATTEMPTS -- ja --> ATTINC[attempt++] --> POLL
    MOREATTEMPTS -- nein --> CHKRCV

    CROK --> CHKRCV{child_received?}
    CHKRCV -- nein --> IINC
    CHKRCV -- ja --> FIT{ordered_payload_len + child_len kleiner MAX?}
    FIT -- nein --> IINC
    FIT -- ja --> APPEND[child_mask Bit setzen / child_payload anhaengen]
    APPEND --> IINC[i++] --> ICOND

    WRITEMASK[ordered_payload 2 = child_mask] --> FINISH[delay TURNAROUND_US / release_all_lines]

    FINISH --> PARSE[parse_node: rekursive Baumdeserialisierung]
    PARSE --> PERR{Rueckgabe kleiner 0?}
    PERR -- ja --> ERR1[Serial: parser error / return] --> LOOP
    PERR -- nein --> IDXCHK{payload_read_index == payload_len?}
    IDXCHK -- nein --> ERR2[Serial: unused bytes / return] --> LOOP
    IDXCHK -- ja --> PRINT[print_tree: Baumstruktur via Serial ausgeben]
    PRINT --> LOOP
```

---

## 5. Wire-Bus – Byte-Uebertragung

```mermaid
sequenceDiagram
    participant TX as Sender
    participant BUS as Leitung (open-drain + Pull-up)
    participant RX as Empfaenger

    Note over BUS: Idle = HIGH

    TX->>BUS: Start-Bit LOW (104 us)
    Note over RX: Fallende Flanke erkannt

    loop 8 Datenbits LSB zuerst
        TX->>BUS: Bit i: LOW=0 oder HIGH=1 (104 us)
        Note over RX: Abtastung in Bitmitte
    end

    TX->>BUS: Stop-Bit HIGH (104 us)
    Note over RX: Byte gueltig
```