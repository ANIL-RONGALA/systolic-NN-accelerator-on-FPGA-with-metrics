# systolic-NN-accelerator-on-FPGA-with-metrics
Designing and implementing a scalable systolic-array neural-network accelerator (4×4 PE array, tile-based mat-mul) in SystemVerilog; verified with a Python golden model and SystemVerilog testbench — achieving functional parity and demonstrate tiling to 64×64 matrices.

nn_accelerator/
│
├── golden/                  # Python golden model + test vectors
│   ├── golden_matmul.py
│   ├── generate_vectors.py
│   ├── vectors/
│   │   ├── A.txt
│   │   ├── B.txt
│   │   └── C.txt
│
├── rtl/                     # Verilog RTL
│   ├── pe.v
│   ├── pe_array.v
│   ├── controller.v
│   ├── memory.v
│   └── top.v
│
├── tb/                      # SystemVerilog testbenches
│   ├── tb_pe.sv
│   ├── tb_array.sv
│   ├── tb_top.sv
│   └── run.do               # ModelSim script
│
├── quartus_project/         # FPGA synthesis files
│   ├── project.qpf
│   ├── project.qsf
│   └── reports/
│
├── docs/                    # Documentation + diagrams
│   ├── design_doc.pdf
│   ├── block_diagram.png
│   └── final_paper.pdf
│
└── README.md
