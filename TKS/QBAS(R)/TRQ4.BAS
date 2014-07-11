DECLARE SUB SORTM (L!(), L!, NOVIK!)
DECLARE SUB ZERO (B!, A$(), L!, O$(), M!(), D!(), W!(), L!())
CLS : RANDOMIZE TIMER
'INPUT "Введите имя файла: ", h$
DIM A$(20, 15), M(20), D(20), O$(20, 15), W(20), O3(20), O2(20), K(500), C(200), L(55), La$(66), Qa$(44), Q$(55)
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
'ВЫБОР СЛУЧАЙНОГО ВОПРОСА#####################################################
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
STOP
'------------------------------------------------
FOR B = 1 TO L
CLS
FOR I = 1 TO M(B)
PRINT A$(C(B), I)
NEXT I
PRINT "-----------------------------------------------------------------------------"
D = D(B) + 1: z = D
FOR I = 1 TO D
ng(I) = INT(z * RND(I)) + 1
610 FOR j = 1 TO I
IF j = I THEN 600
IF ng(j) <> ng(I) THEN 600
ng(I) = INT(z * RND(I) + 1)
GOTO 610
600 NEXT j
IF ng(I) = z THEN c5 = I
PRINT I; ". "; O$(C(B), ng(I))
NEXT I
620 PRINT : PRINT : PRINT "Введите номеp пpавильного ответа"
  DO
      AD$ = INKEY$
  LOOP UNTIL AD$ = "1" OR AD$ = "2" OR AD$ = "3" OR AD$ = "4" OR AD$ = "5"
 rtp = VAL(AD$)
IF rtp <> c5 THEN O3(B) = rtp: L(B) = C(B): NOVIK = NOVIK + 1
IF rtp = c5 THEN O2(B) = O2(B) + 1: K% = K% + W(B)

CLS
FOR Y = 1 TO 2000: NEXT Y
NEXT B
'CALL ZERO(B, A$(), L, O$(), M(), D(), W(), L())
'CALL SORTM(L(), L, NOVIK)
PRINT : PRINT : PRINT
INPUT "Введите имя тестируемого: ", NAMA$
'INPUT "Введите название группы:  ", GR$
GOSUB 2000
GOTO otp:
2000 REM
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
otp:
OPEN "SS.BAS" FOR APPEND AS #2
PRINT #2, NAMA$; ","; GR$; ","; OC; ","; R
notu$ = STR$(L(1))
IF notu$ = "0" THEN 50
 FOR ti = 1 TO NOVIK
     La$ = STR$(L(ti))
     notu$ = La$ + "," + notu$
 NEXT ti
PRINT #2, notv$
50 CLOSE
CLS
CHAIN "D:\QBAS(R)\ЗАПИСЬ.BAS"
END

SUB SORT (L(), L, NOVIK)
          FOR I = 1 TO L - 1
              K = I
67 IF L(K) > L(K + 1) THEN SWAP L(K), L(K + 1): K = K - 1: IF K >= 1 THEN 67
          NEXT I
                FOR I = 1 TO NOVIK
                    LOCATE 6 + I, 37
                    PRINT L(I)
                NEXT I
                STOP
END SUB

SUB SORTM (L(), L, NOVIK)
    FOR K = L - 1 TO 2 STEP -1
        FOR I = 1 TO K
            IF L(I) > L(I + 1) THEN SWAP L(I), L(I + 1)
        NEXT I
    NEXT K
           FOR I = 1 TO NOVIK
               LOCATE 6 + I, 40
               PRINT L(I)
           NEXT I
STOP
END SUB

SUB ZERO (B, A$(), L, O$(), M(), D(), W(), L())
         FOR I = 1 TO L
             IF L(I) = 0 THEN 44
             IF K > 0 THEN L(I - K) = L(I)
             GOTO 55
            
44 K = K + 1
55 NEXT I
       FOR I = 1 TO L - K
           LOCATE 6 + I, 34
           PRINT L(I)
       NEXT I




END SUB

