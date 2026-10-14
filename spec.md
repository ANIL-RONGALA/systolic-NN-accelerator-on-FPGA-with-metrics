# Week 1 architecture specification v0.1 — observed RTL

**Baseline**: `main` branch (unchanged); diagnostics branch `week01-diagnostics`.

## Existing design
- Modules: `systolic_pe`, `systolic_array`, `systolic_controller`, `systolic_top`.
- Default parameters: `ROWS=4`, `COLS=4`, `K=4`, `DATA_W=8`, `ACC_W=32`.
- PE input operands are signed 8-bit by default, partial-sum input/output signed 32-bit.
- Registers sample on rising `clk`; asynchronous active-low `rst_n` clears the four PE outputs.
- `a_out <= a_in` moves A one register to the right; `b_out <= b_in` moves B one register down.
- `valid_out <= valid_in` and `ps_out <= ps_in + a_in*b_in` when valid (else `ps_out <= ps_in`). Partial sum and valid are routed diagonally.
- **No local accumulation**: `ps_out` is calculated from *incoming* `ps_in`, not old `ps_out`.
- PE propagation is one register delay per hop. Full top-level start/busy/done cycle contract has not yet been validated.

## Known failure (GitHub Actions run 38233445037)
The 2×2 test's `seen_valid` OR mask was `4'b1001`: only PE(0,0) and PE(1,1) became valid. The remaining boundary `v_bus` inputs are tied to zero and valid is routed diagonally from PE(i,j) to PE(i+1,j+1). This is a reproduced failing valid-coverage regression, **not** complete GEMM verification.

## Functional constraints / unresolved issues
- Python oracle: `C[i,j] = sum_k A[i,k] * B[k,j]`; independent of the streaming protocol.
- The RTL's diagonal partial sums are not currently known to implement correct K-term GEMM accumulation per output.
- `systolic_top` captures the *first* valid value for each PE; correct final-result timing remains unverified.
- Before performance measurements, resolve numerical mismatch, valid rules, output alignment, and repeat transactions.
- No unverified FPGA utilization, 64×64 tiling, or silicon speed claims should be used.

## Five edge conditions to track
1. **Zero** operands — output zeros; test both values and valid signaling.
2. **Negative** operands — signed multiplication / sign extension.
3. **Overflow** — document `ACC_W` truncation semantics and use full-precision Python reference for mismatch analysis.
4. **Mid-operation reset** — asynchronous PE register clearing; top-level transaction recovery unknown.
5. **Rectangular workloads** — oracle supports M×K times K×N, hardware parameter support not yet verified.

## Reproducibility
- Known failing RTL regression: `TestBench/tb_week01_valid_diag.sv` via `.github/workflows/week01-diagnostics.yml`.
- Week 1 reference and autograd regression: `.github/workflows/week01-learning.yml`.
- Separate **documented known failure** from **passing independent reference tests**.

## Open research log
- Need complete cycle waveform and exact output-valid timing for a corrected design.
- Design/scoreboard changes belong in Week 2, once baseline Week 1 artifacts are complete.
