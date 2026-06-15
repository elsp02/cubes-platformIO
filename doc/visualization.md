# Visualization
(noch zu machen)

## Data Pipeline

Serialized payload
→ Parsed tree
→ Coordinate/orientation interpreter
→ JSON structure
→ Three.js or MeshCat visualization

## Coordinate Interpreter

The absolute position of a cube is calculated recursively from the parent position, parent rotation, child port direction, and local orientation.