"""
2D Truss Finite Element Analysis Solver
Calculates displacements, reactions, and stresses in a planar truss.
"""

import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from scipy.linalg import solve
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')

def run_fea(nodes, elements, materials, loads, supports, scale_factor=500):
    """
    Performs 2D Truss FEA.
    
    Args:
        nodes: np.array of coordinates [[x,y], ...]
        elements: list of [[n1, n2], E, A]
        materials: list of [E, A] if common to all (optional)
        loads: list of [node_idx, fx, fy]
        supports: list of [node_idx, dof_x_fixed, dof_y_fixed]
        scale_factor: visualization scale
    """
    num_nodes = len(nodes)
    num_elements = len(elements)
    dof = 2 * num_nodes
    
    # 1. Assembly
    K = np.zeros((dof, dof))
    element_results = []
    
    for i, elem in enumerate(elements):
        n1, n2 = elem[0]
        E = elem[1]
        A = elem[2]
        
        p1, p2 = nodes[n1], nodes[n2]
        L = np.linalg.norm(p2 - p1)
        
        if L < 1e-9:
            raise ValueError(f"Element {i} has near-zero length.")
            
        c = (p2[0] - p1[0]) / L
        s = (p2[1] - p1[1]) / L
        
        # Element stiffness matrix
        k_local = (E * A / L) * np.array([
            [c*c, c*s, -c*c, -c*s],
            [c*s, s*s, -c*s, -s*s],
            [-c*c, -c*s, c*c, c*s],
            [-c*s, -s*s, c*s, s*s]
        ])
        
        # Map to global
        idx = [2*n1, 2*n1+1, 2*n2, 2*n2+1]
        for row in range(4):
            for col in range(4):
                K[idx[row], idx[col]] += k_local[row, col]
                
        element_results.append({'L': L, 'c': c, 's': s, 'idx': idx, 'E': E, 'A': A, 'nodes': [n1, n2]})

    # 2. Boundary Conditions
    F = np.zeros(dof)
    for node_idx, fx, fy in loads:
        F[2*node_idx] += fx
        F[2*node_idx + 1] += fy
        
    fixed_dofs = []
    for node_idx, fix_x, fix_y in supports:
        if fix_x: fixed_dofs.append(2*node_idx)
        if fix_y: fixed_dofs.append(2*node_idx + 1)
        
    free_dofs = [i for i in range(dof) if i not in fixed_dofs]
    
    if len(free_dofs) == 0:
        raise ValueError("Structure is fully constrained. No degrees of freedom to solve.")

    # 3. Solve
    try:
        K_free = K[np.ix_(free_dofs, free_dofs)]
        F_free = F[free_dofs]
        U_free = solve(K_free, F_free)
    except np.linalg.LinAlgError:
        raise ValueError("Stiffness matrix is singular. Structure may be unstable or under-constrained.")
        
    U = np.zeros(dof)
    U[free_dofs] = U_free
    
    # 4. Post-processing
    Reactions = K @ U - F
    
    stresses = []
    for i in range(num_elements):
        res = element_results[i]
        u_elem = U[res['idx']]
        # Strain epsilon = du / L
        # du = (u2_local - u1_local) = (u2_global - u1_global) dot [c, s]
        delta_L = (res['c'] * (u_elem[2] - u_elem[0]) + 
                   res['s'] * (u_elem[3] - u_elem[1]))
        stress = res['E'] * delta_L / res['L']
        stresses.append(stress)
        
    # 5. Export
    node_data = {
        'Node': range(num_nodes),
        'X': nodes[:,0], 'Y': nodes[:,1],
        'dx': U[::2], 'dy': U[1::2],
        'Rx': Reactions[::2], 'Ry': Reactions[1::2]
    }
    pd.DataFrame(node_data).to_csv('results_nodes.csv', index=False)
    
    elem_data = {
        'Element': range(num_elements),
        'Node1': [e[0][0] for e in elements],
        'Node2': [e[0][1] for e in elements],
        'Stress_MPa': np.array(stresses) / 1e6
    }
    pd.DataFrame(elem_data).to_csv('results_elements.csv', index=False)
    
    # 6. Plotting
    plt.figure(figsize=(12, 7))
    deformed_nodes = nodes + U.reshape(-1, 2) * scale_factor
    
    for i in range(num_elements):
        n1, n2 = elements[i][0]
        # Undeformed
        plt.plot([nodes[n1,0], nodes[n2,0]], [nodes[n1,1], nodes[n2,1]], 'k--', alpha=0.2)
        
        # Deformed
        stress = stresses[i]
        color = 'red' if stress > 1e-3 else ('blue' if stress < -1e-3 else 'green')
        plt.plot([deformed_nodes[n1,0], deformed_nodes[n2,0]], 
                 [deformed_nodes[n1,1], deformed_nodes[n2,1]], 
                 color=color, linewidth=2, label='Deformed' if i == 0 else "")
        
    plt.title(f"2D Truss FEA: Displacement (Scale {scale_factor}x)\nRed=Tension, Blue=Compression, Green=Zero Stress")
    plt.xlabel("X (m)")
    plt.ylabel("Y (m)")
    plt.grid(True, linestyle=':', alpha=0.6)
    plt.axis('equal')
    plt.savefig('truss_plot.png')
    logging.info("Results saved to CSV files and visualization saved to truss_plot.png")
    
    return U, Reactions, stresses

def main():
    # Example: Simple Bridge Truss
    # Nodes: bottom chord (0, 4, 8), top chord (2, 6)
    nodes = np.array([
        [0.0, 0.0], [4.0, 0.0], [8.0, 0.0], # Bottom
        [2.0, 3.0], [6.0, 3.0]              # Top
    ])
    
    E, A = 210e9, 0.005 # Steel, 50cm^2
    
    # Elements: [[n1, n2], E, A]
    elements = [
        [[0, 1], E, A], [[1, 2], E, A], # Bottom chord
        [[3, 4], E, A],                 # Top chord
        [[0, 3], E, A], [[1, 3], E, A], # Diagonals/Verticals
        [[1, 4], E, A], [[2, 4], E, A]
    ]
    
    # Loads: [node, fx, fy]
    loads = [
        [1, 0, -200000], # 200kN down at center node
    ]
    
    # Supports: [node, fix_x, fix_y]
    supports = [
        [0, True, True],  # Pinned at left
        [2, False, True]  # Roller at right
    ]
    
    try:
        U, R, S = run_fea(nodes, elements, None, loads, supports)
        print("\nSuccess! FEA Completed.")
        print(f"Max Displacement: {np.max(np.abs(U)):.4e} m")
        print(f"Max Stress: {np.max(np.abs(S))/1e6:.2f} MPa")
    except Exception as e:
        logging.error(f"Solver failed: {e}")

if __name__ == "__main__":
    main()
