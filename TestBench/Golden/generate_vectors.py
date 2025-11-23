# This script generates random matrices A and B, computes their product C using the golden_matmul library,
import numpy as np
from golden_matmul import matrix_multiply
import os
import argparse

def write_matrix_to_file(matrix: np.ndarray, filename: str):
    with open(filename, "w") as f:
        for row in matrix:
            f.write(" ".join(str(x) for x in row) + "\n")

def main():
    parser = argparse.ArgumentParser(description="Generate random test vectors for matrix multiplication.")
    parser.add_argument("--M", type=int, default=64, help="Number of rows in A")
    parser.add_argument("--K", type=int, default=64, help="Number of columns in A / rows in B")
    parser.add_argument("--N", type=int, default=64, help="Number of columns in B")
    parser.add_argument("--outdir", type=str, default="vectors", help="Directory to store output files")
    args = parser.parse_args()

    # Create output directory if it doesn’t exist
    os.makedirs(args.outdir, exist_ok=True)

    # Generate random int8 matrices
    A = np.random.randint(-128, 128, size=(args.M, args.K), dtype=np.int8)
    B = np.random.randint(-128, 128, size=(args.K, args.N), dtype=np.int8)

    # Compute golden result
    C = matrix_multiply(A, B)

    # Write to files
    write_matrix_to_file(A, os.path.join(args.outdir, "A.txt"))
    write_matrix_to_file(B, os.path.join(args.outdir, "B.txt"))
    write_matrix_to_file(C, os.path.join(args.outdir, "C.txt"))

    print(f"Generated vectors in '{args.outdir}/':")
    print(f"  A.txt [{args.M} x {args.K}]")
    print(f"  B.txt [{args.K} x {args.N}]")
    print(f"  C.txt [{args.M} x {args.N}]")

if __name__ == "__main__":
    main()
