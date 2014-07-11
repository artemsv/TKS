CLS
INPUT "Введите имя файла: ", h$
DIM a$(20, 15), m(20), d(20), o$(20, 15), w(20)
OPEN h$ FOR OUTPUT AS #1
WHILE NOT EOF(1)
LINE INPUT #1, l1$
INPUT #1, l
FOR b = 1 TO l
INPUT #1, w(b), m(b)
FOR i = 1 TO m(b): LINE INPUT #1, a$(b, i): NEXT i
INPUT #1, d(b)
FOR v = 1 TO d(b) + 1
LINE INPUT #1, o$(b, v)
NEXT v
NEXT b
INPUT #1, j3, j4, j5
INPUT #1, dum$
inck n%
WEND
CLOSE
CLS
PRINT l1$, l
FOR b = 1 TO l
PRINT m(b), w(b)
FOR k = 1 TO m(b)
PRINT a$(b, k)
NEXT k
FOR k = 1 TO d(b) + 1
PRINT o$(b, k)
NEXT k
NEXT b
PRINT j3, j4, j5
END



