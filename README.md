# 2D Truss Finite Element Analysis Solver

A Python-based Finite Element Analysis (FEA) solver that calculates nodal displacements, reaction forces, and axial stresses for 2D planar truss structures.

## Features
- Global stiffness matrix assembly using coordinate transformation.
- Supports pinned and roller boundary conditions.
- Calculation of axial stresses and reaction forces.
- High-quality visualization of undeformed vs deformed structures.
- Stress-based color coding (Red for Tension, Blue for Compression).
- Results exported to CSV format.

## Installation

```bash
pip install -r requirements.txt
```

## Usage

Run the main solver:

```bash
python main.py
```

## Example
The current `main.py` solves a simple 3-bar triangular truss with a 10kN downward load applied at the top node.

### Sample Output
```
Success! FEA Completed.
Max Displacement: 1.5000e-03 m
Max Stress: 26.67 MPa
Results saved to results_nodes.csv and results_elements.csv
Saved visualization to truss_plot.png
```

## Mathematical Background
The solver uses the Direct Stiffness Method:
1. Local stiffness matrix: $k_{local} = \frac{AE}{L} \begin{bmatrix} 1 & -1 \\ -1 & 1 \end{bmatrix}$
2. Transformation matrix $T$ for 2D rotation.
3. Global assembly: $K = \sum T^T k_{local} T$
4. Solution: $U = K^{-1} F$

## License
MIT
