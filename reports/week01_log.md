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
- Date / git SHA: TBD
- Python, NumPy, PyTorch, pytest versions: check CI output
- GEMM tests: TBD
- PyTorch model run: TBD
- Recreated environment: TBD (requirements pinned in CI after first successful run)
- Known RTL error: uncorrected; fix and full scoreboard scheduled for Week 2
- First command next week: rerun validated tests and add cycle-accurate data/valid scoreboard
