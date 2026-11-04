
import numpy as np
from golden_matmul import matrix_multiply

A = np.array([[1, 2], [3, 4]], dtype=np.int8)
B = np.array([[5, 6], [7, 8]], dtype=np.int8)

expected = matrix_multiply(A, B)

# Temporary sample to test the checker.
# NOT real RTL output yet.
observed = np.array([[19, 22], [43, 48]])

if np.array_equal(expected, observed):
    print("PASS: Matrix results match")
else:
    print("FAIL: Matrix mismatch")
    for i in range(expected.shape[0]):
        for j in range(expected.shape[1]):
            if expected[i, j] != observed[i, j]:
                print(
                    f"C[{i},{j}]: "
                    f"expected {expected[i,j]}, "
                    f"got {observed[i,j]}"
                )
    raise SystemExit(1)
