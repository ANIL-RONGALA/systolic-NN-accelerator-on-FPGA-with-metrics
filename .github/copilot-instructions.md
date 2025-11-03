## What this repo is

This repository contains a small systolic matrix-multiply NN accelerator implemented in Verilog
with a Python golden model and test-vector generation. Key folders:

- `RTL/` — Verilog sources: `top.v`, `pe.v`, `pe_array.v`, `controller.v`, `memory.v`.
- `Golden/` — Python golden model and vector generator (`generate_vectors.py`, `golden_matmul.py`).
- `TestBench/` — SystemVerilog testbenches (`tb_*.sv`) and a `run.do` ModelSim/Questa script (currently a placeholder).
- `Quartus_Projects/` — FPGA project files and synthesis artifacts.

## Big-picture architecture notes for edits

- The top-level module (`RTL/top.v`, module `matmul_top`) wires: memories -> `controller` -> `pe_array`.
  - `controller` produces `pe_in_valid`, `pe_a`, `pe_b`, `clear_acc` and `done` signals consumed by the PE array.
  - Memories are parameterized with depths computed from M*K and K*N; updating matrix sizes affects address widths.
- `pe.v` implements a signed multiply-accumulate with a synchronous `clear` and `in_valid` handshake. Use this when changing accumulation semantics.
- `pe_array.v` instantiates a configurable grid of PEs. To change array dimensions, update `PE_ROWS`/`PE_COLS` parameters and ensure `controller` address generation matches.

## Concrete examples to copy/paste

- Generate test vectors (from repo root):
  - python Golden/generate_vectors.py --M 8 --K 8 --N 8 --outdir Golden/Vctors
    Note: the repo currently has a directory named `Golden/Vctors` (typo). The generator's default `--outdir` is `vectors` — pass the explicit `--outdir` to place files where you want.
- Golden model usage: `Golden/golden_matmul.py` implements matrix_multiply(A, B) using numpy. Use it to validate RTL outputs.

## Developer workflows and hints (discoverable in repo)

- Simulation: testbenches live in `TestBench/` and are SystemVerilog (`.sv`). `TestBench/run.do` is the ModelSim/Questa script spot — it may be empty; update it with simulation commands or run your simulator directly with `vsim`/`vsim -do run.do`.
- FPGA flow: `Quartus_Projects/` contains `.qpf`/`.qsf` files for Quartus. Open that project in Quartus (or import into your toolchain) to synthesize and produce reports.
- Parameter changes: the RTL uses module parameters for `M`, `K`, `N`, `IN_WIDTH`, and `ACC_WIDTH`. Change sizes in `top.v` (and match golden/vector generator args) to keep sizes consistent.

## Project-specific patterns and gotchas

- Filename conventions: modules are lower_snake (e.g., `pe_array`, `mem_dp`) but testbenches are `tb_*`. Look for these prefixes when adding tests or modules.
- Dual-port memories follow `mem_dp` instantiation patterns in `top.v`. Address widths are sliced using `$clog2(depth)-1:0` — be careful when changing depths.
- Signed arithmetic: `pe.v` uses `$signed()` and signed port declarations. Preserve signedness when wiring or converting to fixed-point.

## When in doubt: quick checklist for changes

1. Update parameter values in `RTL/top.v` and re-run `Golden/generate_vectors.py` with matching `--M/--K/--N`.
2. Run the golden model (`golden_matmul.py`) to produce expected `C.txt` and compare to RTL outputs from the testbench.
3. If changing PE behavior, update `RTL/pe.v` and corresponding tests in `TestBench/tb_*.sv`.
4. For synthesis changes, open `Quartus_Projects/` and inspect `project.qsf`/`project.qpf`.

## Where to add further docs

- If you add a ModelSim script, update `TestBench/run.do` and document the invocation in `README.md`.
- Fix or document the `Golden/Vctors` vs `Golden/vectors` naming so vector generation is deterministic.

If any of the above assumptions are incorrect or you want a different level of detail (run commands, exact ModelSim flow, or CI hooks), tell me which area and I'll expand the file.
