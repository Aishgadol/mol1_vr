# Molecule1: 3D & VR Molecular Simulation Tool

**Course**: Project in Computer Graphics  
**Project Supervisor**: Dr. Roi Poranne

## Project Overview

**Molecule1** is an interactive molecular simulator built in Godot, featuring both a first-person 3D mode and a VR mode for an immersive, hands-on approach to molecular visualization. The simulator offers full freedom to explore, manipulate, and merge molecular structures in a dynamic 3D environment, providing insight into molecular geometry and bond structures from every angle.

## Features and Functionality

### Interactive Control and Freedom of Movement

- **3D Mode (First-Person)**: Raycasting allows users to grab, position, and rotate molecular structures freely within the 3D space. You can move molecules closer, push them further, or spin them to any orientation, enabling comprehensive inspection of bond angles and molecular geometry.
- **VR Mode**: Equipped with dual controllers, VR mode provides spatially intuitive interactions. Users can physically reach out, grab, and manipulate molecules, enhancing the perception of depth and structure in a virtual environment. This mode leverages VR’s immersive qualities, making it ideal for understanding 3D relationships and bond connectivity.
- **Dynamic Bonding**: Bringing molecules close enough triggers automatic bonding based on proximity, allowing users to experiment with molecular interactions and connect structures naturally.

### User Interface and Menu Navigation

- **Main Menu**: Features a background animation of the 3D simulation “playground,” along with options for toggling background music, starting the simulator (via a scripted camera transition to the starting position), and quitting the application.
- **Pause Menu**: Offers options to resume, manage molecules, or return to the main menu with a smooth camera transition. The molecule management submenu allows for:
  - **Loading Z-Matrix Files**: Supports `.txt` and `.zmat` formats.
  - **Spawning and Editing**: Instantly load or modify molecular structures within the simulation.
  - **Saving Molecules**: Export molecules back to Z-matrix format for future use or analysis.

### Technical Implementation

- **Data Processing Pipeline**: Molecule1 reads molecular data in Z-matrix format, which is handled through a file-based system. The Godot entity manager generates an input file, which is then processed by an embedded Python script to parse atom coordinates and connectivity data. Output is returned to the same file path for Godot to retrieve, parse, and render within the simulation.
- **Visual Representation**: Atoms are color-coded by element type for easy identification, while bonds are displayed as connections between atoms. Bonds differentiation between single, double, or triple bonds will be added in later iterations.

### Future Improvements

While this initial implementation focuses on establishing the core interactive and visualization features, future iterations may include:
- **Optimized Data Handling**: Improving the data pipeline to support real-time updates and enhanced file management.
- **Expanded VR Features**: Adding finer controls for VR manipulation, such as pressure-sensitive grabbing or distance-based bonding adjustments.
- **Advanced Molecule Management**: Extending the molecule management menu to include options for creating custom molecules directly within the simulator.
