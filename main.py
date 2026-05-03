import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from scipy.linalg import solve

def solve_truss():
    # 1. Inputs
    # Nodal coordinates (x, y)
    nodes = np.array([
        [0.0, 0.0],   # Node 0
        [4.0, 0.0],   # Node 1
        [2.0, 3.0]    # Node 2
    ])
    
    # Element connectivity (node1, node2)
    # Young's Modulus E (Pa), Area A (m^2)
    # For simplicity, we assume E and A are same for all elements
    E = 200e9  # 200 GPa
    A = 0.01   # 0.01 m^2
    
    elements = [
        [0, 1], # Element 0
        [1, 2], # Element 1
        [2, 0]  # Element 2
    ]
    
    num_nodes = len(nodes)
    num_elements = len(elements)
    dof = 2 * num_nodes
    
    # 2. Global Stiffness Matrix Assembly
    K = np.zeros((dof, dof))
    
    element_stresses = []
    element_info = []
    
    for i, (n1, n2) in enumerate(elements):
        x1, y1 = nodes[n1]
        x2, y2 = nodes[n2]
        L = np.sqrt((x2 - x1)**2 + (y2 - y1)**2)
        c = (x2 - x1) / L
        s = (y2 - y1) / L
        
        # Local stiffness matrix
        k_local = (E * A / L) * np.array([
            [c*c, c*s, -c*c, -c*s],
            [c*s, s*s, -c*s, -s*s],
            [-c*c, -c*s, c*c, c*s],
            [-c*s, -s*s, c*s, s*s]
        ])
        
        # Assembly into global matrix
        idx = [2*n1, 2*n1+1, 2*n2, 2*n2+1]
        for row in range(4):
            for col in range(4):
                K[idx[row], idx[col]] += k_local[row, col]
        
        element_info.append({'L': L, 'c': c, 's': s, 'idx': idx})

    # 3. Boundary Conditions and Loads
    # Loads: node, direction (0=x, 1=y), value (N)
    loads = np.zeros(dof)
    loads[2*2 + 1] = -100000  # -100kN at node 2 in Y direction
    
    # Supports: node, direction (0=x, 1=y)
    # Node 0: fixed (x and y)
    # Node 1: roller (fixed y)
    fixed_dofs = [2*0, 2*0 + 1, 2*1 + 1]
    
    # 4. Solve for Displacements
    free_dofs = [i for i in range(dof) if i not in fixed_dofs]
    
    K_free = K[np.ix_(free_dofs, free_dofs)]
    F_free = loads[free_dofs]
    
    U_free = solve(K_free, F_free)
    
    U = np.zeros(dof)
    U[free_dofs] = U_free
    
    # 5. Reactions and Stresses
    Reactions = K @ U - loads
    
    for i in range(num_elements):
        info = element_info[i]
        n1, n2 = elements[i]
        idx = info['idx']
        u_elem = U[idx]
        
        # Change in length
        delta_L = (info['c'] * (u_elem[2] - u_elem[0]) + 
                   info['s'] * (u_elem[3] - u_elem[1]))
        stress = E * delta_L / info['L']
        element_stresses.append(stress)

    # 6. Outputs and Saving
    print("Nodal Displacements (m):")
    for i in range(num_nodes):
        print(f"Node {i}: dx={U[2*i]:.6e}, dy={U[2*i+1]:.6e}")
        
    print("\nElement Stresses (MPa):")
    for i in range(num_elements):
        print(f"Element {i}: {element_stresses[i]/1e6:.2f} MPa")

    # Save to CSV
    results_df = pd.DataFrame({
        'Node': range(num_nodes),
        'dx': U[::2],
        'dy': U[1::2],
        'Rx': Reactions[::2],
        'Ry': Reactions[1::2]
    })
    results_df.to_csv('results_nodes.csv', index=False)
    
    stress_df = pd.DataFrame({
        'Element': range(num_elements),
        'Stress_MPa': np.array(element_stresses) / 1e6
    })
    stress_df.to_csv('results_stresses.csv', index=False)

    # 7. Visualization
    plt.figure(figsize=(10, 6))
    
    # Scale factor for displacement visibility
    scale = 500
    deformed_nodes = nodes + U.reshape(-1, 2) * scale
    
    for i in range(num_elements):
        n1, n2 = elements[i]
        # Undeformed
        plt.plot([nodes[n1,0], nodes[n2,0]], [nodes[n1,1], nodes[n2,1]], 'k--', alpha=0.3)
        
        # Deformed with color coding
        stress = element_stresses[i]
        color = 'red' if stress > 0 else 'blue'
        plt.plot([deformed_nodes[n1,0], deformed_nodes[n2,0]], 
                 [deformed_nodes[n1,1], deformed_nodes[n2,1]], 
                 color=color, linewidth=2)
        
    plt.title(f"2D Truss Deformation (Scale: {scale}x)\nRed: Tension, Blue: Compression")
    plt.xlabel("X (m)")
    plt.ylabel("Y (m)")
    plt.grid(True)
    plt.axis('equal')
    plt.savefig('truss_plot.png')
    print("\nSaved visualization to truss_plot.png")

if __name__ == "__main__":
    solve_truss()
