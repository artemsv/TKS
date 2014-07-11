CLS
LOCATE 13, 29
PRINT "…„€Š’Ž ’…‘’Ž‚"
SLEEP 1
CLS
DIM A$(20, 15), M(20), D(20), O$(20, 15), W(20), o3(20), o2(20), k(500), c(200)
LOCATE 15, 25: INPUT "¢¢¥¤¨â¥ ¨¬ï ä ©« ", h$
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
LOCATE 12, 23: PRINT "Œ…ž …„€Š’ˆŽ‚€ˆŸ"
PRINT : PRINT TAB(24); "1.Ž‚ŽŽ‘Ž… ˆ‡Œ……ˆ…"
PRINT TAB(23); "2.ˆ‡Œ……ˆ…‚ŽŽ‘€ ŽŒ… N"
PRINT TAB(23); "3.ˆ‡Œ……ˆ… Œ…‘’€ ‚›‚Ž„€ ‚ŽŽ‘€ € Š€"
PRINT TAB(23); "4.„Ž€‚‹…ˆ… ‚ŽŽ‘Ž‚"
PRINT TAB(23); "5.ˆ‡Œ……ˆ… ‚…‘€ ‚ŽŽ‘€"
PRINT TAB(23); "6.ˆ‡Œ……ˆ… Šˆ’…ˆŸ Ž–…Šˆ"
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
100 CLS : PRINT TAB(12); "‚€˜ ‚ŽŽ‘:"
 FOR B = 1 TO L
   FOR I = 1 TO 15
   PRINT A$(B, I)
   NEXT I
   PRINT "“„…’… Œ…Ÿ’œ ’…Š‘’ ‚ŽŽ‘€?"
   GOSUB YESNO:
3  SELECT CASE YES$
          CASE "Y"
                  CLS
                  FOR I = 1 TO M(B)
                        LOCATE 5, 12
                        LINE INPUT "‚‚…„ˆ’… ‘‚Ž‰ ‚€ˆ€’ ‚ŽŽ‘€", A$(B, I)
                        IF A$(B, I) = "~" THEN 12
                  NEXT I
          CASE "N"
                  GOTO 12
     REM     CASE ELSE
                    GOTO 3
12 END SELECT
  CLS
  LOCATE 3, 8: PRINT "‘ˆ‘ŽŠ Ž’‚…’Ž‚"
  FOR V = 1 TO D(B) + 1
    PRINT V; ".  "; O$(B, V)
    NEXT V
  LOCATE 13, 2: PRINT "“„…’… Œ…Ÿ’œ …€‚ˆ‹œ›… ‚ŽŽ‘›?"
  GOSUB YESNO:
  SELECT CASE YES$
         CASE "Y"
                   FOR V = 1 TO D(B)
                   LOCATE 15, 45: PRINT "‚‚…„ˆ’…"; V; "-© …€‚ˆ‹œ›‰ ‚ŽŽ‘:"
                   INPUT O$(B, V)
                   NEXT V
                   LOCATE 22, 35: INPUT "‚‚…„ˆ’… €‚ˆ‹œ›‰ ‚ŽŽ‘:", O$(B, V)
                   PRINT "’Ž ŽŠŽ—€’…‹œ›‰ ‚€ˆ€’?"
                   GOSUB YESNO:
                   IF YES$ = "Y" OR YES$ = "y" THEN
                   END IF
                   IF YES$ = "N" OR YES$ = "n" THEN
                   END IF
                   

END SELECT
YESNO:
       INPUT "…‘‹ˆ „€, ’Ž €†Œˆ’… Y,…‘‹ˆ …’ ,’Ž N", YES$
        CLS
RETURN

