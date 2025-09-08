import numpy as np

def matrix_multiply(A, B):
    """ Matrix multiplication operation defined """

    A = A.astype(np.int8) 
    B = B.astype(np.int8)

    C = np.matmul(A, B, dtype=np.int32)
    return C