# Frontend
This directory contains the three.js frontend of the learning application. It
connects to the Python backend over WebSocket, renders the detected construction next to the target tree, and shows live build feedback during the building task.

## Directory Structure
```text
frontend/
├── index.html               # dashboard: pick a target tree + level
├── live_build.html          # live build view (single tree)
├── build_reference.html     # live build view + target reference, side by side
├── style.css                # shared styling for all pages
├── assets/                   # exported GLB cube models (one per brick type)
├── img/                      # UI icons and the loader GIF
└── src/
    ├── ws_client.js           # WebSocket connection to the backend
    ├── layout.js               # cube position/rotation geometry
    ├── live_build.js            # entry module: live_build.html (+ build_reference.html)
    ├── build_reference_test.js  # TEMPORARY entry module: build_reference_test.html
    ├── target-tree/
    │   └── index.js              # collects target-tree JSON definitions
    ├── visualization/
    │   ├── core/                  # used everywhere: tree builder, scene environment
    │   ├── views/                  # live_view, reference_view, target_tree_view
    │   └── dashboard/               # tree_preview, tree_thumbnail
    ├── ui/                          # progress_bar, tree_selection, split_toggle
    └── animation/                    # loader_page, loader_live_build, end_dialog
```

## Compare
The frontend (`tree_builder.js` + `live_view.js`) interprets the `status` of a brick (node) as follows:

| Field | Meaning |
|:--|:--|
| `correct` | cube rendered with a green pulsing outline |
| `wrong` / `unexpected` | cube rendered with a red pulsing outline |
| `attachable`| no physical cube yet; rendered as a semi-transparent "ghost" |
| `blocked` | not rendered at all |

## Configuration
`ws_client.js` hard-codes the backend address at the top of the file:

| Constant | Meaning |
|:--|:--|
| `WEBSOCKET_URL` | address of `ws_server.py` (default `ws://localhost:8765`) |
| `RECONNECT_DELAY_MS` | delay before retrying a dropped connection |

## Running
```bash
npm install
npm run dev
```
Opens on `http://localhost:5173`. The backend (`ws_server.py`) must be
running and the baseplate connected for a build session to show live data
(see [backend/README.md](../backend/README.md#running)).