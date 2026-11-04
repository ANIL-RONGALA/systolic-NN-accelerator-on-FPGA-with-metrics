
import numpy as np
from golden_matmul import matrix_multiply


def check_matrix(expected, observed):
    if np.array_equal(expected, observed):
        print("PASS: Matrix results match")
        return True

    print("FAIL: Matrix mismatch")

    for i in range(expected.shape[0]):
        for j in range(expected.shape[1]):
            if expected[i, j] != observed[i, j]:
                print(
                    f"C[{i},{j}]: "
                    f"expected {expected[i,j]}, "
                    f"got {observed[i,j]}"
                )

    return False


A = np.array([[1, 2], [3, 4]], dtype=np.int8)
B = np.array([[5, 6], [7, 8]], dtype=np.int8)

expected = matrix_multiply(A, B)

# Test 1: Deliberately incorrect matrix
wrong = np.array([[19, 22], [43, 48]])
assert not check_matrix(expected, wrong)

# Test 2: Correct matrix
correct = np.array([[19, 22], [43, 50]])
assert check_matrix(expected, correct)

print("PASS: Both scoreboard self-tests completed")
