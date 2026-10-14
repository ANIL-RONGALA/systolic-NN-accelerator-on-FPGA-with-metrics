"""Independent integer GEMM oracle; intentionally not modeling fixed-width RTL overflow."""
import numpy as np

def gemm_reference(a, b):
    a = np.asarray(a, dtype=np.int64)
    b = np.asarray(b, dtype=np.int64)
    if a.ndim != 2 or b.ndim != 2 or a.shape[1] != b.shape[0]:
        raise ValueError('GEMM requires 2-D compatible matrices')
    m,k = a.shape
    n = b.shape[1]
    c = np.zeros((m,n), dtype=np.int64)
    for i in range(m):
        for j in range(n):
            for t in range(k):
                c[i,j] += a[i,t] * b[t,j]
    return c
