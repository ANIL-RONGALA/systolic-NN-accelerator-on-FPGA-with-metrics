# systolic-NN-accelerator-on-FPGA-with-metrics
Design and verify hardware for matrix multiplication (core NN primitive).

Compare RTL results against a Python golden model.

Scale from a single Processing Element (PE) to systolic arrays.

Synthesize on FPGA (Quartus/Vivado) and extract performance metrics.

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
