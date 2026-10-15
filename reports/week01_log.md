# Week 1 laboratory log (October 12–18, 2026)

## Verified initial baseline
- Source-level RTL review: 4×4 default, signed int8 input, signed 32-bit incoming partial sum, A→right, B→down, PS+valid→diagonal.
- GitHub Actions run **38233445037** compiled with Icarus Verilog 12.0 and reproduced the valid-mask defect (`seen_valid = 1001`). This failed intentionally under a valid-coverage assertion. It **did not** test full numerical correctness.
- Source code issue: off-diagonal valid inputs tied low. Additional concern: partial-sum path has no local K-term accumulation.

## Week 1 generated assets
- `spec.md`: actual RTL behavior and identified unknowns.
- `reference/gemm_reference.py`, `tests/test_gemm.py`: 10 independent deterministic GEMM examples + invalid-shape guard.
- `ml/linear_autograd.py`: deterministic `y=3x+2` SGD/autograd experiment with NumPy comparison.
- `.github/workflows/week01-learning.yml`: cloud tests for the two Python tasks.

## Review after GitHub Actions runs

- **Validation date:** October 15, 2026
- **Branch tested:** `week01-diagnostics`
- **Workflow run:** https://github.com/ANIL-RONGALA/systolic-NN-accelerator-on-FPGA-with-metrics/actions/runs/38627698220
- **GEMM reference:** 11/11 tests passed.
- **PyTorch:** 2.5.1+cpu
- **PyTorch regression:** Passed.
- **Learned parameters:** w = 3.000241, b = 1.999147.
- **Final loss:** Approximately 0.00000024.
- **Known RTL defect:** Valid propagation failed for off-diagonal processing elements (`1001` observed in the earlier diagnostic).
- **RTL correctness:** Not yet established; correction scheduled for Week 2.

### Week 1 conclusion

Completed the architecture review, documented the RTL defect, implemented an independent GEMM reference with deterministic tests, and validated a reproducible PyTorch autograd training exercise.

The Python reference and ML baseline passed. Full systolic-array functionality remains a Week 2 objective.

