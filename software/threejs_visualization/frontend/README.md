>html und wichitge datein nochmal erklären, in directory fehlt assets und img ordner
# Frontend
This directory contains the three.js frontend of the learning application. It
connects to the Python backend over WebSocket, renders the detected construction next to the target tree, and shows live build feedback during the building task.

## Directory Structure
```text
frontend/
├── index.html, live_build.html, build_reference.html   # dashboard, live build view
├── style.css                                       # shared styling
└── src/
    ├── ws_client.js             # WebSocket connection to the backend
    ├── layout.js                # cube position/rotation geometry
    ├── progress_bar.js          # build-progress bar
    ├── live_build.js             # entry module: live_build.html
    ├── target-tree/index.js     # collects target-tree JSON definitions
    ├── visualization/           # tree_builder + scene_environment
    └── animation/               # UI interactions
```

## Data flow
```text
ws_client.js (WebSocket) --> live_build.js --> live_view.js (+ tree_builder.js, layout.js)
                                            --> reference_view.js (build_reference.html only)
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