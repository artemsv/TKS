DECLARE SUB SORT (L!(), L!, NOVIK!)
DECLARE SUB ZERO (L!(), L!, NOVIK!)
RANDOMIZE TIMER
VAR$ = STR$(INT(10 * RND(1) + 1))
CLS
KEY(1) OFF
KEY(2) OFF
KEY(3) OFF
KEY 1, ""
KEY 2, ""
KEY 3, ""
KEY ON
KEY 2, "éíÇÖí" + CHR$(13)
KEY 1, "åÖçû" + CHR$(13)
KEY(1) ON
KEY(2) ON
ON KEY(1) GOSUB MENU:
ON KEY(2) GOSUB OTVET:
SLEEP
'KEY 1, ""
KEY 2, ""
'KEY OFF
CLS
OTVET:
TIMER ON: CLS : RANDOMIZE TIMER
'INPUT "Ç¢•§®‚• ®¨Ô ‰†©´†: ", h$
DIM a$(20, 15), m(20), d(20), o$(20, 15), w(20), o3(20), o2(20), K(500), c(200)
'h$ = "d:\qbasic\cs.bas"
OPEN "ñìåë.BAS" FOR INPUT AS #1
INPUT #1, L1$, L
FOR b = 1 TO L
INPUT #1, w(b), m(b)
FOR I = 1 TO m(b)
LINE INPUT #1, a$(b, I)
NEXT I
INPUT #1, d(b)
FOR V = 1 TO d(b) + 1
LINE INPUT #1, o$(b, V)
NEXT V
NEXT b
INPUT #1, j3, j4, j5
CLOSE
'-----------------------------------------------
z9 = L
FOR K = 0 TO L
c(I) = INT(z9 * RND(K) + 1)
777 FOR I = 1 TO K
IF I = K THEN 788
IF c(I) <> c(K) THEN 788
c(K) = INT(z9 * RND(K) + 1)
GOTO 777
788 NEXT I
NEXT K
FOR m98 = 1 TO L
PRINT c(m)
NEXT m98

'------------------------------------------------
FOR b = 1 TO L
CLS
FOR I = 1 TO m(c(b))
PRINT a$(c(b), I)
NEXT I
PRINT "-----------------------------------------------------------------------------"
d = d(b) + 1: z = d
FOR I = 1 TO d
ng(I) = INT(z * RND(I)) + 1
610 FOR j = 1 TO I
IF j = I THEN 600
IF ng(j) <> ng(I) THEN 600
ng(I) = INT(z * RND(I) + 1)
GOTO 610
600 NEXT j
IF ng(I) = z THEN c5 = I
PRINT I; ". "; o$(c(b), ng(I))
NEXT I
620 PRINT : PRINT : PRINT "Ç¢•§®‚• ≠Æ¨•p Øp†¢®´Ï≠Æ£Æ Æ‚¢•‚†"
      DO
        AD$ = INKEY$
2 LOOP UNTIL AD$ = "1" OR AD$ = "2" OR AD$ = "3" OR AD$ = "4" OR AD$ = "5"
      rtp = VAL(AD$)

IF rtp <> c5 THEN o3(b) = rtp:  L(b) = c(b): NOVIK = NOVIK + 1
IF rtp = c5 THEN o2(b) = o2(b) + 1: K% = K% + w(b): PRAV% = PRAV% + 1: PRAV$ = STR$(PRAV%)
CLS
NEXT b
CALL ZERO(L(), L, NOVIK)
CALL SORT(L(), L, NOVIK)
CLS
650 PRINT "                          Ñ†‚† ÆØpÆ·†: "; DATE$
PRINT "                           Çp•¨Ô ÆØ‡Æ·†:"; TIME$
PRINT
PRINT
INPUT "Ç¢•§®‚• ®¨Ô ‚•·‚®‡„•¨Æ£Æ: ", nama$
GOSUB 2000
GOTO otp:
2000 FOR h = 1 TO L
n = n + w(h)
NEXT h
R = K% * 100 / n
IF R < j3 THEN oc = 2
IF R = j3 OR R > j3 AND R < j4 THEN oc = 3
IF R = j4 OR R > j4 AND R < j5 THEN oc = 4
IF R = j5 OR R > j5 THEN oc = 5
otp:
INPUT "BBEÑàíÖ àåü îÄâãÄ éíóÖíÄ", OCH$
'OPEN OCH$ FOR APPEND AS #2
gr$ = "AS 22"
OPEN "SS.BAS" FOR APPEND AS #2
PRINT #2, nama$; ","; VAR$; ","; oc; ","; R; ","; PRAV$
notv$ = STR$(L(1))
IF notv$ = "0" THEN 50
FOR ti = 2 TO NOVIK
La$ = STR$(L(ti))
notv$ = notv$ + "," + La$
NEXT ti
IF notu$ = "0" THEN notu$ = ""
PRINT #2, notv$
50 CLOSE
RUN "D:\QBAS(R)\áÄèàëú.BAS"
MENU:
RUN "D:\QBAS(R)\åÖçû.BAS"
END

SUB SORT (L(), L, NOVIK)
    FOR K = NOVIK - 1 TO 2 STEP -1
           FOR I = 1 TO K
           IF L(I) > L(I + 1) THEN SWAP L(I), L(I + 1)
           NEXT I
    NEXT K

          FOR I = 1 TO NOVIK
              LOCATE 6 + I, 27
              PRINT L(I)
          NEXT I
END SUB

SUB ZERO (L(), L, NOVIK)
          LOCATE 12, 12
          PRINT NOVIK
          FOR I = 1 TO L
             LOCATE 6 + I, 23
             PRINT L(I)
          NEXT
          FOR I = 1 TO L
              IF L(I) = 0 THEN 44
              IF K > 0 THEN L(I - K) = L(I)
              GOTO 55
44 K = K + 1
55 NEXT I
            FOR I = 1 TO L - K
                LOCATE 6 + I, 25
                PRINT L(I)
            NEXT I

END SUB

