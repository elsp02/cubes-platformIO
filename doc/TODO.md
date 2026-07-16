# page content
ToDos and next steps, Improvements

IMPROVEMENT:

QUESTIONS
- what does the time frame of the program look like? When will the main loop be repeated?
- what if one connection (node) is defective? (e.g. orientation detection is not working) -> does everything freeze up then?


ich darf nicht 1 child 3 mal pollen und dann das andere danach sondern muss 1 child pollen dann warten dann das andere pollen dann wieder das erste pollen etc 

NEXT STEPS 
donnerstag
- three js cubes aussehen
- communication zwischen attiny baseplate und pc (attiny sendet data frame oder detection failed oder feedback failed)
    - info frames 
- threejs appearance
    - auf website infofenster mit error_mask von aktuellem baustein - art serieller monitor


- ID in EEPROM
- Payload len and max node calculation
- esp
    - zuerst über usb und dann wifi?
    - code änderungen (nur server und tree comparison, frontend sollte gleich bleiben)
- automatisches reconnecten von client mit server falls server abstürzt/disconnected war (aktuell neuladen der website)
- feedback led grün nur an bis neueer cube dazu kommt
- CRC
- definieren dass bei unterstem cube die kinder an x und -x seite keine kinder auf ihrer seite die global nach unten schaut haben können

WUNSCH ERWEITERUNGEN
- verschiedene bausteine
- selber bauen (ohne target_tree)
- KI generierte target trees
- zeit druck
- partner mode
- broadcast
- datenbase mit eigenen constructionen
- bestenliste


## Open claude suggested improvements

### Tier 2 — remaining timing & robustness items
- #9 — Shrink deaf windows: log_flush() still runs unconditionally every cycle; production timeout values should also be validated against SERIAL_WRITING builds where logging compiles away. (Partially mitigated: the calculated feedback timeout includes a 2× margin for exactly this.)
- #10 — Pin-change-interrupt ACK/presence on the upstream lines, so a child can answer even mid-busy and silence truly means "absent". The big architectural step; everything done so far works without it.
- #11 — Optional protocol upgrades: 1-Wire-style presence pulse, per-frame ACK/NACK for checksum errors, hardware detect contact (only if a PCB revision happens anyway).

### Tier 3 — RAM & scalability (all open)
- #12 — In-place payload building: poll_child still fills the 256-byte child_payload[2][128] intermediate array instead of writing directly into the final payload buffer; the MAX_CHILD_PAYLOAD_LEN vs MAX_PAYLOAD_LEN inconsistency also still exists.
- #13 — Per-cube NODE_ID: all cubes flashed from env:cube still get 0x12; EEPROM/USERROW-based IDs or per-cube envs still to do.
#14 — feedback_index policy: still advances even when feedback failed or no child exists, still uses the magic 4 instead of an array-length constant, and still cycles on every heartbeat.
- #15 — feedback_contains_own_id contract: the bounds bug is fixed, but the semantic confusion remains (comments/log letters/return value disagree; "ID absent" is treated ambiguously; result still unused by the caller in handle_feedback).

### Tier 4 — cleanup (all open)
- #16 — Deduplicate send_feedback_to_child (still two near-identical copies in baseplate and cube) and the duplicated payload-build loop.
- #17 — Dead code: wait_for_cmd_status(), UPSTREAM_FAIL_LIMIT, DATA_BYTE, MAX_NODES, commented-out log_line blocks, parser.cpp in the baseplate build.
- #18 — Polish: stale "Prototype v2" banner, static int upstream_count → constexpr uint8_t, #if not → #if !, unnamed _delay_us(3 * BYTE_US), optional CRC-8 instead of XOR.