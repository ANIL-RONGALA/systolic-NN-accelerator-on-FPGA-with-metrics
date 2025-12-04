# 🧮 Systolic Neural-Network Accelerator on FPGA (with Metrics)
---
A hardware-accelerated matrix-multiplication engine for neural networks, implemented in SystemVerilog, verified with a Python golden model, and synthesised on FPGA with performance metrics.

## 📘 1. Project Overview
---
This project presents the design, implementation, and evaluation of a scalable systolic-array neural-network accelerator. Key features:

A 4×4 Processing-Element (PE) array as the base unit

Tile-based matrix multiplication enabling 64×64 matrix support

Verification via a Python golden model and SystemVerilog testbench

FPGA synthesis (Quartus/Vivado) and extraction of performance metrics (resource usage, frequency, throughput)

Modular architecture supporting expansion to larger arrays or other NN primitives

This work is ideal for digital-design, computer-architecture and AI-hardware research, and is fully reproducible with RTL + testbench + golden model.

## 🧰 2. Repository Contents
---
```
systolic-NN-accelerator-on-FPGA-with-metrics/
│
├── golden/                  # Python golden model + test-vector generator  
│   ├── golden_matmul.py  
│   ├── generate_vectors.py  
│   └── vectors/             # input/output matrices  
│       ├── A.txt  
│       ├── B.txt  
│       └── C.txt  
│
├── rtl/                     # RTL implementation in Verilog/SystemVerilog  
│   ├── pe.v  
│   ├── pe_array.v  
│   ├── controller.v  
│   ├── memory.v  
│   └── top.v  
│
├── tb/                      # Testbenches in SystemVerilog  
│   ├── tb_pe.sv  
│   ├── tb_array.sv  
│   ├── tb_top.sv  
│   └── run.do                # ModelSim simulation script  
│
```
<!--
├── quartus_project/         # FPGA synthesis project (Quartus/Vivado)  
│   ├── project.qpf  
│   ├── project.qsf  
│   └── reports/              # synthesis & timing reports  
│
├── docs/                    # Documentation  
│   ├── design_doc.pdf  
│   ├── block_diagram.png  
│   └── final_paper.pdf  
│
-->
```
├── LICENSE                  # MIT License  
└── README.md                # This file  
```
## 🔍 3. Key Design Features
---
Processing Element (PE): Performs multiply-accumulate (MAC) operations; forms the building block of the systolic array.

Systolic Array (4×4): Enables spatial and temporal reuse of data, reducing memory bandwidth and increasing throughput.

Tile-Based Matrix Multiplication: Supports larger matrices (e.g., 64×64) by tiling through the 4×4 array.

Python Golden Model: Verifies functional correctness of the design by comparing RTL outputs to high-level model results.

FPGA Metrics Collection: Resource usage (LUTs/FFs/BRAM), maximum frequency, throughput (MACs/sec) and power estimates are reported.

Modular and Scalable Architecture: Easier to scale to larger arrays (8×8, 16×16) for future work.

## 🧪 4. How to Build and Simulate
---
Simulation (Golden + RTL)

Run golden_matmul.py to generate input-output vectors.

Launch ModelSim/Questa with tb_top.sv and run.do.

Compare RTL output C.txt results with golden model.

Synthesis (FPGA)

Open the quartus_project (or equivalent Vivado) folder.

Assign FPGA device and compile.

Examine reports/ for resource usage, critical path, and timing.

Run post-place-and-route simulation or hardware test if board available.

## 📊 5. Metrics & Results
---
Functional parity verified between golden model and RTL for tile sizes up to 64×64.

Example reporting:

LUTs: ~X, FFs: ~Y, BRAM: ~Z (for 4×4 array)

Maximum frequency: ~F MHz

Throughput: ~T GMAC/s

(Refer to reports/ for full details.)

## 📂 6. How to Reproduce or Extend
---
Fork or clone this repository.

Modify the PE or array dimensions (e.g., change to 8×8).

Update generate_vectors.py for new matrix sizes.

Add new testbenches or extend existing ones for new functionality (e.g., activation functions).

Re-synthesise and collect new metrics.

You may integrate this accelerator into a larger SoC or pipeline for inference tasks.

## 🚀 7. Future Scope & Research Extensions
---
Extend array size (8×8, 16×16, 32×32) for larger NN workloads.

Integrate activation functions (ReLU, Sigmoid, Quantization) within PEs.

Add support for sparse matrix formats or mixed-precision (INT8, FP16) for efficiency.

Implement dynamic reconfiguration: switch tile sizes at runtime.

Incorporate AI/ML workloads: convolutional layers, transformer accelerators.

Design full SoC with on-chip memory, DMA engine, external interface (PCIe, AXI).

Port to ASIC for research on power/area optimization, enabling PhD-level publications.

## 📝 8. License
---
This project is released under the MIT License — see LICENSE file for details.

🔧 Acknowledgments

This work builds on standard systolic-array architecture concepts from literature, and extends them with a reproducible FPGA/RTL/C verification stack.

Note:
A portion of documentation formatting and organization was enhanced using AI tools for clarity. The architecture, logic design, RTL implementation, verification, and metric collection are original.
