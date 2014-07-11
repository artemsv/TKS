KEY ON
KEY(10) ON
KEY 10, "åÖçû"
ON KEY(10) GOSUB Vixid:

'ON ERROR GOTO 1000
S$ = SPACE$(80): V$ = CHR$(179): n$ = STRING$(80, CHR$(196))
CLS
DIM NAME$(30), GR$(70), OCENKA$(50), BALL$(55), PRAV$(500), DUB$(500)
      OPEN "ñìåë.BAS" FOR INPUT AS #1
            INPUT #1, L1$, L
      CLOSE

KEY ON
FOR E = 1 TO 4
     KEY E, " îéêåÄ"
     KEY(E) ON
NEXT
ON KEY(1) GOSUB 10
'ON KEY(2) GOSUB 20
'ON KEY(3) GOSUB 30
'ON KEY(4) GOSUB 40
SLEEP
END
10 REM FORMA 1
PRINT TAB(4); "àíéÉà éèêéëÄ èé ÉêìèèÖ:"; GR$(3)
PRINT TAB(10); "íÖåÄ:"; ""; L1$
PRINT n$
PRINT CHR$(252), "î.à.é.", "éñÖçäÄ", "ÅÄããõ"
PRINT n$
    OPEN "SS.BAS " FOR INPUT AS #1
          DO WHILE NOT EOF(1)
          M = M + 1
          INPUT #1, NAME$(M), GR$(M), OCENKA$(M), BALL$(M)
          LINE INPUT #1, DUB$(M)
        LOCATE M + 5, 1: PRINT M
        LOCATE M + 5, 12: PRINT NAME$(M)
        LOCATE M + 5, 31: PRINT OCENKA$(M)
        LOCATE M + 5, 43: PRINT BALL$(M)
        IF M > 16 THEN EXIT DO
LOOP
    CLOSE
KEY 6, "ÑÄãúòÖ"
      DO
      LOOP UNTIL INKEY$ = CHR$(27)
CLS
PRINT TAB(4); "àíéÉà éèêéëÄ èé ÉêìèèÖ:"; GR$
PRINT TAB(10); "íÖåÄ:"; ""; L1$
PRINT n$
PRINT CHR$(252), "î.à.é.", "éñÖçäÄ", "ÅÄããõ"
PRINT n$
    M = 0
    OPEN "SS.BAS" FOR INPUT AS #1
         DO WHILE NOT EOF(1)
                  n = n + 1
               INPUT #1, NAME$(n), GR$(n), OCENKA$(n), BALL$(n)
                LINE INPUT DUB$(n)
         LOOP
    CLOSE
               FOR I = 1 TO n - M
                M = M + 1
               LOCATE Z + 5, 1: PRINT M
               LOCATE Z + 5, 12: PRINT NAME$(M)
               LOCATE Z + 5, 31: PRINT OCENKA$(M)
               LOCATE Z + 5, 43: PRINT BALL$(M)
               NEXT




END
CHISTKA:
FOR I = 1 TO 20
    LOCATE 6 + I, 1
    PRINT S$:
NEXT
RETURN
STOP
1000 RESUME NEXT

Vixid:
KEY OFF
RUN "D:\QBAS(R)\åÖçû.BAS"

