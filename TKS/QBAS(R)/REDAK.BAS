CLS
LOCATE 13, 29
PRINT " "
SLEEP 1
CLS
DIM A$(20, 15), M(20), D(20), O$(20, 15), W(20), o3(20), o2(20), k(500), c(200)
LOCATE 15, 25: INPUT "ขขฅคจโฅ จฌ๏ ไ ฉซ ", h$
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
INPUT #1, J3, J4, J5
CLOSE
CLS
LOCATE 12, 23: PRINT " "
PRINT : PRINT TAB(24); "1. "
PRINT TAB(23); "2.  N"
PRINT TAB(23); "3.     "
PRINT TAB(23); "4. "
PRINT TAB(23); "5.  "
PRINT TAB(23); "6.  "
DO UNTIL Z$ = "1" OR Z$ = "2" OR Z$ = "3" OR Z$ = "4" OR Z$ = "5" OR Z$ = "6"
Z$ = INKEY$
LOOP
IF Z$ = "1" THEN 100
'IF Z$ = "2" THEN 200
'IF Z$ = "3" THEN 300
'IF Z$ = "4" THEN 400
'IF Z$ = "5" THEN 500
'IF Z$ = "6" THEN 600
'##############################################################################
100 CLS : PRINT TAB(12); " :"
 FOR B = 1 TO L
   FOR I = 1 TO 15
   PRINT A$(B, I)
   NEXT I
   PRINT "   ?"
   GOSUB YESNO:
3  SELECT CASE YES$
          CASE "Y"
                  CLS
                  FOR I = 1 TO M(B)
                        LOCATE 5, 12
                        LINE INPUT "   ", A$(B, I)
                        IF A$(B, I) = "~" THEN 12
                  NEXT I
          CASE "N"
                  GOTO 12
     REM     CASE ELSE
                    GOTO 3
12 END SELECT
  CLS
  LOCATE 3, 8: PRINT " "
  FOR V = 1 TO D(B) + 1
    PRINT V; ".  "; O$(B, V)
    NEXT V
  LOCATE 13, 2: PRINT "   ?"
  GOSUB YESNO:
  SELECT CASE YES$
         CASE "Y"
                   FOR V = 1 TO D(B)
                   LOCATE 15, 45: PRINT ""; V; "-ฉ  :"
                   INPUT O$(B, V)
                   NEXT V
                   LOCATE 22, 35: INPUT "  :", O$(B, V)
                   PRINT "  ?"
                   GOSUB YESNO:
                   IF YES$ = "Y" OR YES$ = "y" THEN
                   END IF
                   IF YES$ = "N" OR YES$ = "n" THEN
                   END IF
                   

END SELECT
YESNO:
       INPUT " ,   Y,  , N", YES$
        CLS
RETURN

