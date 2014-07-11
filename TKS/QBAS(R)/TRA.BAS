CLS
RANDOMIZE TIMER
INPUT "Введите имя файла: ", h$
INPUT "Введите имя файла отчета: ", ot$
DIM A$(20, 15), M(20), D(20), O$(20, 15), W(20), o3(20), o2(20), K(500), C(200)
'h$ = "d:\qbasic\cs.bas"
'ot$ = "otch.bas"
OPEN h$ FOR INPUT AS #1
INPUT #1, L1$, L
FOR b = 1 TO L
INPUT #1, W(b), M(b)
FOR I = 1 TO M(b)
LINE INPUT #1, A$(b, I)
NEXT I
INPUT #1, D(b)
FOR V = 1 TO D(b) + 1
LINE INPUT #1, O$(b, V)
NEXT V
NEXT b
INPUT #1, J3, J4, J5
CLOSE
z9 = L
FOR K = 0 TO L
C(I) = INT(z9 * RND(K) + 1)
777 FOR I = 1 TO K
IF I = K THEN 788
IF C(I) <> C(K) THEN 788
C(K) = INT(z9 * RND(K) + 1)
GOTO 777
788 NEXT I
NEXT K
FOR m98 = 1 TO L
PRINT C(M)
NEXT m98
Y = 65
INPUT "Сколько вопросов будет в варианте ", e
I = 1: K = 1: Z = 1
501 IF Z > e THEN 502
PRINT K
K = K + 1: Z = Z + 1: GOTO 501
502 VAR$ = "VAR" + CHR$(Y) + ".bas"
PRINT VAR$
OPEN VAR$ FOR OUTPUT AS #3
PRINT #3, L1$, ",", e
FOR b = qw TO e: e = e + qw
qw = qw + 1
PRINT #3, W(C(b)), ",", M(C(b)), ",", C(b)
FOR BR = 1 TO M(C(b))
PRINT #3, A$(C(b), BR)
NEXT BR
PRINT #3, D(C(b))
FOR VG = 1 TO D(C(b)) + 1
PRINT #3, O$(C(b), VG)
NEXT VG
PRINT #3, J3, ",", J4, ",", J5
NEXT b
CLOSE #3: Y = Y + 1: Z = 1
IF K > L THEN END
GOTO 501
END

