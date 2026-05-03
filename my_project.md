# My Project Brief

## Project Name
2D Truss Finite Element Analysis Solver

## What to Build
A Python-based Finite Element Analysis (FEA) solver that calculates the nodal displacements, reaction forces, and axial stresses for a 2D planar truss structure given node coordinates, element connectivity, material properties, and boundary conditions. It should visually plot the deformed truss with color-coded stresses (red for tension, blue for compression).

## Inputs
- Nodal coordinates (x,y)
- Element connectivity (node1, node2)
- Young's Modulus (E)
- Cross-sectional Area (A)
- Applied forces (Fx, Fy)
- Support conditions (pinned/roller)

## Outputs
- Array of Nodal displacements (dx, dy)
- Reaction forces at supports
- Axial stress in each element (MPa)
- High-quality matplotlib visualization of undeformed vs deformed truss
- Results saved to CSV

## Libraries
numpy, scipy, matplotlib, pandas

## GitHub Repo Name
fea-2d-truss-solver
