# Indexed Addressing Tests

Test        | Feature
------------|--------------------
idx1        | EA = 16-bit address
idx1        | ,R+
idx5        | ,R++
idx1        | ,-R
idx5        | ,--R
idx1        | ,R + 8-bit offset
idx6        | ,R + 16-bit offset - Failing now because of bad encoding (?)
idx1        | ,R
--          | DP - Needs psh/pul first
idx2        | ,R + A
idx2        | ,R + B
idx4        | ,R + D
idx4        | indirect
idx1        | X
idx1        | Y
idx3        | U
idx3        | S
idx7        | PC - Failing because of bad encoding (?)
