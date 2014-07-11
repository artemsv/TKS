CLS
DIM A(12)
DATA 25, 6,2,1,5,12,13,7,9,8,23,0

FOR I = 1 TO 12
   READ A(I)
NEXT I

FOR K = 1 TO 12
     FOR I = K + 1 TO 12
        IF A(K) < A(I) THEN 10
        M = A(K): A(K) = A(I): A(I) = M
10 NEXT I
NEXT K

FOR I = 1 TO 12
   PRINT A(I);
NEXT

