import numpy as np

def matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Performs standard matrix multiplication using NumPy.
    This is the golden reference model.
    """
    # Force data type to int8 for inputs
    A = A.astype(np.int8)
    B = B.astype(np.int8)

    # Accumulate in int32 to mimic hardware accumulation
    C = np.matmul(A, B, dtype=np.int32)
    return C

if __name__ == "__main__":
    # Quick sanity test
    A = np.array([[1, 2], [3, 4]], dtype=np.int8)
    B = np.array([[5, 6], [7, 8]], dtype=np.int8)
    print(matrix_multiply(A, B))
