# Modular Mechatronic Smart-Brick System for Tangible Learning in Special Education

Repository accompanying the Bachelor thesis:

**Design and Development of a Tangible Learning System for Special Education**

Elena Spitzer  
University of Applied Sciences Augsburg  
Faculty of Electrical Engineering  
Creative Engineering  
2026  

## Overview
This repository contains the prototype developed as part of the Bachelor thesis and investigates a modular, brick-based tangible learning game that combines the haptic and spatial qualities of physical construction materials with digital task presentation, construction detection and feedback. Learners select a three-dimensional target structure in a browser-based application and reproduce it using electronically connected building bricks. The system was designed to create opportunities for spatial thinking, action planning, problem-solving and increasingly independent learning while allowing task complexity and assistance to be adapted to individual needs. 

The system consists of three main components:

- **Active building bricks** that form the physical construction
- **A baseplate** that serves as the root of the construction
- **A learning application** that reconstructs the detected construction digitally

## Repository Structure
> **TODO**: Replace it with actual repository structure (alles was in eckige klammer muss ausgetauscht werden)

```text
.
├── README.md
│
├── docs/
│   ├── architecture.md
│   ├── communication-protocol.md
│   ├── feedback.md
│   ├── hardware.md
│   ├── timing-definitions.md
│
├── figures/
│
├── firmware/
│   ├── include/
│   │   └── include/
│   └── src/
│        ├── lib/
│        ├── firmware_baseplate/
│        ├── firmware_cube/
│        └── state_machine/
│
├── [SOFTWARE_DIRECTORY]/
│   ├── [BACKEND_DIRECTORY]/
│   └── [FRONTEND_DIRECTORY]/
│
├── hardware/
│   ├── pcb_files/
│   ├── [CAD_FILES]
│   └── [OTHER_HARDWARE_FILES]
│
└── [OTHER_RELEVANT_DIRECTORIES]
```

|Directory | Description |
|:--|:--|
| `docs/` | Technical documentation of the developed system |
| `firmware` | Embedded firmware for the building bricks and the baseplate |
| `[BACKEND_DIRECTORY]` | Python backend for communication and construction processing |
| `[FRONTEND_DIRECTORY]` | Browser-based learning application and 3D visualisation |
| `hardware` | Electronic and mechanical design files
| `[OTHER]` | TODO if required | 

## Documentation
Detailed technical documentation is provided separately: 
- [System Architecuture](docs/system_architecture.md): Overall system structure, component responsibilities, software architecture and data processing
- [Communication Protocol](docs/communication_protocol.md): Communication interfaces, message formats, communication sequences (and error and timeout handling)
- [Hardware](docs/hardware.md): Mechanical and electronic implementation of the building bricks and baseplate

Addtional information regarding the feedback output and visualisation is provided in [Feedback and Visualisation](docs/feedback.md).

(Furthermore, the bachelor thesis includes the complete design rationale, theoretical background, requirement analysis, implementation details and evaluation.)


## Requirements
to operate the complete physical prototype, the following hard- and software is required:

### Prototype Hardware
>**TODO**: adjust link to correct one

The building bricks and baseplate both include an ATtiny1616 and are custom developed components. Their mechanical and electronic design files are included in this repository in the [hardware](hardware/) and explained in [Hardware](docs/hardware.md)

### Additional Hardware
- 2× USB-to-TTL UART adapter (CH340/CH340G-based)
  - one modified with a TX/RX diode, used as UPDI programmer (jtag2updi)
  - one unmodified, used for host–baseplate UART communication and 5V supply
- host computer
- USB connection for 5V power supply

The prototype was programmed using the jtag2updi-compatible programmer.
Setup instructions are available in the
[jtag2updi documentation](https://github.com/SpenceKonde/AVR-Guidance/blob/master/UPDI/jtag2updi.md).

### Software
- [PlatformIO](https://platformio.org/)
- [megaTinyCore](https://github.com/SpenceKonde/megaTinyCore) for ATtiny1616 support
- Python 3.14
- modern web browser

**Python dependencies**:  
- `pyserial` (UART communication, e.g. [handshake_test.py](software/uart_test/handshake_test.py), [binary_serial_reader.py](software/threejs_visualization/backend/binary_serial_reader.py))
- `websockets` (backend WebSocket server, [ws_server.py](software/threejs_visualization/backend/ws_server.py))

Python dependencies can be installed via:  
```bash
pip install -r software/threejs_visualization/backend/requirements_backend.txt
```

**Frontend dependencies** (in [software/threejs_visualization/frontend/package.json](software/threejs_visualization/frontend/package.json)):  
- `three` (^0.185.1)  
- `vite` (^8.1.2) — dev server / bundler

Install with:  
```bash
cd software/threejs_visualization/frontend
npm install
```

## Getting Started
### 1. Clone the Repository
git `clone https://github.com/elsp02/cubes-platformIO.git`  
cd cubes-platformIO

### 2. Flash the Brick and Baseplate Firmware
for flashing use the modified USB-to-TTL UART adapter

#### Brick Firmware
the brick firmware is located in: [firmware/src/state_machine]  
Compile the firmware and upload the ATtiny1616 using PlatformIO:  
```bash
pio run -e [uart_cube_state_machine]
```

```bash
pio run -e [uart_cube_state_machine] -t upload
```
---
#### Baseplate Firmware
the baseplate firmware is located in: [firmware/src/state_machine]

Compile the firmware and upload the ATtiny1616 using PlatformIO: 
```bash
pio run -e [uart_baseplate_state_machine]
```

```bash
pio run -e [uart_baseplate_state_machine] -t upload
```
---
#### Debugging
 to run the baseplate standalone without a PC connection, cycling the predefined feedback patterns instead of PC-supplied data, flash the `[baseplate_state_machine_debug]` environment instead:
 ```bash
 pio run -e [baseplate_state_machine_debug]
 ```

### 3. Connect the Prototype
1. Connect the baseplate to the host computer using the unmodified USB-to-TTL UART adapter
2. ensure that the system is supplied with 5V
3. Do not connect bricks to the baseplate yet
For details about the physical and electronic interfaces, see the [Hardware Documentation](docs/hardware.md)

### 4. Start the Backend
> **TODO**: ordner tools zu software
Navigate to the backend directory:  
```bash
cd software/threejs_visualization/backend
```
Start the backend:
```bash
python ws_server.py
```

### 5. Start the Frontend
Navigate to the frontend directory:
```bash
cd software/threejs_visualization/frontend
```
Start the frontend and open it in a web browser:
```bash
npm run dev
```

## Usage
A typical construction task follows this sequence:
1. Start the backend and frontend
2. Select a target construction in the learning application
3. Inspect and confirm the selected three-dimensional target
4. Connect the first brick to the baseplate.
5. Continue the building process by trying to reproduce the target structure 
5. The system processes the current construction and updates the digital representation.
6. Rearrange a brick if it is detected and visualised as incorrect
7. Continue modifying the construction until the task is completed
8. End the current session or return to the target selection

The visualised feedback during the construction task inlcuding pyhsical and digital feedback and feedback states is explained in detail in the[Feedback Documentation](docs/feedback.md).

## Prototype Status
>**TODO**: when final prototype is finished, a revision of this subsection is needed

//baseplate flashed currently with uart_baseplate_sate_machine env of commit 89c1055ab03e6bade8f2c494344d17d41a6eff1b
//cube flashed currently with uart_cube env of commit 89c1055ab03e6bade8f2c494344d17d41a6eff1b (ungetestet) and b65bacb49b7ec45e51fe05621d1cff7b89f50d17
This repository contains the proof-of-concept prototype developed for the Bachelor thesis. It is not a production-ready or certified educational product.

At the time of the thesis evaluation:

- the physical interaction concept and learning application had been evaluated with the intended target group;
- eight physical prototype bricks had been manufactured;
- the electronic construction-detection and feedback functionality had been implemented but was not sufficiently reliable for an integrated target-group evaluation;
- differentiated assistance levels were not yet functionally implemented.

The repository should therefore be understood as documentation of the implemented research prototype rather than a finished learning product.

Further information about the evaluation, requirement fulfilment and limitations is provided in the Bachelor thesis.

## Version
>**TODO**: adjust tag and commit 
The version associated with the submitted Bachelor thesis is:

Tag:    [TODO: e.g. v1.0-thesis]  
Commit: [TODO: FINAL_COMMIT_HASH]  

Later commits may contain modifications that are not described in the submitted thesis.