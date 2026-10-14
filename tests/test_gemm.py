import numpy as np
import pytest
from reference.gemm_reference import gemm_reference

CASES = [
 ([[3]], [[4]]),
 ([[-3]], [[4]]),
 ([[0,0],[0,0]], [[3,4],[5,6]]),
 ([[1,2],[3,4]], [[1,0],[0,1]]),
 ([[1,2],[3,4]], [[5,6],[7,8]]),
 ([[1,2,3]], [[4,5],[6,7],[8,9]]),
 ([[1],[2],[3]], [[4,5]]),
 ([[127,127]], [[127],[127]]),
 ([[-128,-128]], [[127],[127]]),
 ([[-1,2],[3,-4]], [[5,-6],[-7,8]]),
]

@pytest.mark.parametrize('a,b',CASES)
def test_reference(a,b):
    actual = gemm_reference(a,b)
    expected = np.asarray(a,dtype=np.int64) @ np.asarray(b,dtype=np.int64)
    np.testing.assert_array_equal(actual,expected)

def test_invalid_dimensions():
    with pytest.raises(ValueError):
        gemm_reference([[1,2]],[[3,4,5],[2,3,4],[6,7,8]])
