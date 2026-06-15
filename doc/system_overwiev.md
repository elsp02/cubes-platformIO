# System Overview
## System Purpose
The system detects the physical arrangement of connected cube modules and reconstructs it as a digital tree structure.
## Main components
- Cube modules
- Baseplate
- optional gateway (interface between two systems)/controller for visualization
- device for vizualization -> besser schreiben
## Functional principle

## Data flow
Baseplate -> Cubes/Cube Network -> Baseplate -> Tree Parser?? -> Coordinate Interpreter -> JSON -> Vizualization
## (final target architecture)
### Systemarchitektur Diagramm
= Modell, das die Ansichten, die Struktur und das Verhalten des Systems konzeptionell definiert &rarr; Darstellung und Beschreibung, wie das System im Allgemeinen funktioniert und mit anderen Systemkomponenten kommuniziert. 
Verbesserung!!!!!!!
```mermaid
flowchart LR
    A[Cube Modules] --> B[Baseplate]
    B --> C[Gateway Controller]
    C --> D[WLAN]
    D --> E[iPad Browser]
    E --> F[Three.js / MeshCat Visualization]

