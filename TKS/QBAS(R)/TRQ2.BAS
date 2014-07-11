CLS : RANDOMIZE TIMER
'INPUT "Ç¢•§®‚• ®¨Ô ‰†©´†: ", h$
DIM A$(20, 15), m(20), d(20), O$(20, 15), W(20), O3(20), O2(20), k(500), C(200), La(55), La$(66), Qa$(44), Q$(55)
h$ = "ñìåë.BAS"
OPEN h$ FOR INPUT AS #1
INPUT #1, L1$, L
FOR B = 1 TO L
INPUT #1, W(B), m(B)
FOR I = 1 TO m(B)
LINE INPUT #1, A$(B, I)
NEXT I
INPUT #1, d(B)

FOR V = 1 TO d(B) + 1
LINE INPUT #1, O$(B, V)
NEXT V
NEXT B
INPUT #1, j3, j4, j5
CLOSE
'ÇõÅéê ëãìóÄâçéÉé ÇéèêéëÄ#####################################################
z9 = L
FOR k = 0 TO L
C(I) = INT(z9 * RND(k) + 1)
777 FOR I = 1 TO k
IF I = k THEN 788
IF C(I) <> C(k) THEN 788
C(k) = INT(z9 * RND(k) + 1)
GOTO 777
788 NEXT I
NEXT k
FOR m98 = 1 TO L
PRINT C(m)
NEXT m98

'------------------------------------------------
FOR B = 1 TO L
CLS
FOR I = 1 TO m(B)
PRINT A$(C(B), I)
NEXT I
PRINT "-----------------------------------------------------------------------------"
d = d(B) + 1: z = d
FOR I = 1 TO d
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
620 PRINT : PRINT : PRINT "Ç¢•§®‚• ≠Æ¨•p Øp†¢®´Ï≠Æ£Æ Æ‚¢•‚†"
  DO
      AD$ = INKEY$
  LOOP UNTIL AD$ = "1" OR AD$ = "2" OR AD$ = "3" OR AD$ = "4" OR AD$ = "5"
 rtp = VAL(AD$)
IF rtp <> c5 THEN O3(B) = rtp: La(B) = C(B): NOVIK = NOVIK + 1
IF rtp = c5 THEN O2(B) = O2(B) + 1: k% = k% + W(B)

CLS
FOR Y = 1 TO 2000: NEXT Y
NEXT B
PRINT : PRINT : PRINT
INPUT "Ç¢•§®‚• ®¨Ô ‚•·‚®‡„•¨Æ£Æ: ", NAMA$
'INPUT "Ç¢•§®‚• ≠†ß¢†≠®• £‡„ØØÎ:  ", GR$
GR$ = "Äë 22"
           FOR h = 1 TO L
               N = N + W(h)
           NEXT h
R = k% * 100 / N
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
            k = 0
REM àáÅÄÇãÖçàÖ éí çìãÖâ
    FOR I = 1 TO L
        IF La(I) = 0 THEN 44
        IF k > 0 THEN La(I - k) = La(I)
        GOTO 55
44 k = k + 1
55 NEXT I
          FOR I = 1 TO L - k
              LOCATE 6 + I, 15
              PRINT La(I)
          NEXT I
'####################################################################################
GOTO 999
REM ëéêíàêéÇäÄ èé ÇéáêÄëíÄçàû
 FOR I = 1 TO L - 1
    k = I
21 IF La(k) > La(k + 1) THEN 22
GOTO 77
22 R = La(k + 1): La(k + 1) = La(k): La(k) = R
k = k - 1
IF k >= 1 THEN 21

LOCATE 6 + 1, 35: PRINT La(I)
77 NEXT I
5 FOR I = 1 TO L - k
    LOCATE 6 + I, 33
    PRINT La(I)
NEXT I

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
CHAIN "D:\QBAS(R)\áÄèàëú.BAS"
END

