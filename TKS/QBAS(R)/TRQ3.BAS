DECLARE SUB ZERO (La!(), L!)
DECLARE SUB VOPROS (B!, A$(), L!, O$(), M!(), D!(), W!(), La!())
CLS : RANDOMIZE TIMER
'INPUT "Введите имя файла: ", h$
DIM A$(20, 15), M(20), D(20), O$(20, 15), W(20), O3(20), O2(20), K(500), C(200), La(55), La$(66), Qa$(44), Q$(55)
h$ = "ЦУМС.BAS"
OPEN h$ FOR INPUT AS #1
INPUT #1, L1$, L
FOR B = 1 TO L
INPUT #1, W(B), M(B)
FOR I = 1 TO M(B)
LINE INPUT #1, A$(B, I)
NEXT I
INPUT #1, D(B)

FOR V = 1 TO D(B) + 1
LINE INPUT #1, O$(B, V)
NEXT V
NEXT B
INPUT #1, j3, j4, j5
CLOSE
'-----------------------------------------------
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
CALL VOPROS(B, A$(), L!, O$(), M(), D(), W(), La())
CALL ZERO(La(), L)

PRINT : PRINT : PRINT
INPUT "Введите имя тестируемого: ", NAMA$
'INPUT "Введите название группы:  ", GR$
GR$ = "АС 22"
           FOR h = 1 TO L
               N = N + W(h)
           NEXT h
R = K% * 100 / N
IF R < j3 THEN OC = 2
IF R = j3 OR R > j3 AND R < j4 THEN OC = 3
IF R = j4 OR R > j4 AND R < j5 THEN OC = 4
IF R = j5 OR R > j5 THEN OC = 5
'#################################################################################
  FOR I = 1 TO L
      LOCATE 6 + I, 3
      PRINT La(I)
    NEXT I
'####################################################################################
            K = 0
'###################################################################################
999 REM
OPEN "SS.BAS" FOR APPEND AS #2
PRINT #2, NAMA$; ","; GR$; ","; OC; ","; R
notu$ = STR$(La(1))
IF notu$ = "0" THEN 50
 FOR ti = 1 TO NOVIK
     La$ = STR$(La(ti))
     notu$ = La$ + "," + notu$
     LOCATE 6 + ti, 45: PRINT notu$
 NEXT ti
PRINT #2, notv$
50 CLOSE
CLS
CHAIN "D:\QBAS(R)\ЗАПИСЬ.BAS"
END

SUB VOPROS (B, A$(), L, O$(), M(), D(), W(), La())
    FOR B = 1 TO L
        CLS
        FOR I = 1 TO M(B)
            PRINT A$(B, I)
        NEXT I
        PRINT STRING$(80, CHR$(196))
              D = D(B) + 1
                  FOR I = 1 TO D
                      PRINT I; "."; O$(B, I)
                  NEXT I
PRINT : PRINT : PRINT
PRINT "Введите правильный ответ"
      DO
        AD$ = INKEY$
      LOOP UNTIL AD$ = "1" OR AD$ = "2" OR AD$ = "3" OR AD$ = "4" OR AD$ = "5"
rtp = VAL(AD$)
    IF rtp <> 5 THEN La(B) = 0: NOVIK = NOVIK = 1: GOTO 7
    IF rtp = 5 THEN La(B) = B: K% = K% + W(B)
7  NEXT B

END SUB

SUB ZERO (La(), L)
    FOR I = 1 TO L
        IF La(I) = 0 THEN 44
        IF K > 0 THEN La(I - K) = La(I)
        GOTO 55
44 K = K + 1
55 NEXT I
          FOR I = 1 TO L - K
               LOCATE 6 + I, 34
               PRINT La(I)
          NEXT I

STOP
END SUB


