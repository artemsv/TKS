DECLARE SUB GENERAL (B, A$(), O$(), D(), M())
CLS
LOCATE 13, 29
PRINT " "
SLEEP 1
CLS
DIM A$(20, 15), M(20), D(20), O$(20, 15), W(20), o3(20), o2(20), k(500), c(200)
LOCATE 15, 25: ' INPUT "ขขฅคจโฅ จฌ๏ ไ ฉซ ", h$
OPEN "COK101.BAS" FOR INPUT AS #1
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
ON Z GOTO 100

'##############################################################################
100 REM      
    CLS : PRINT L
    FOR B = 1 TO L
    PRINT TAB(25); " "
    CALL GENERAL(B, A$(), O$(), D(), M())
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
    NEXT B

  

SUB GENERAL (B, A$(), O$(), D(), M())
      FOR I = I TO M(B)
        LOCATE 12 + B, 12
        PRINT A$(B, I)
      NEXT I
     LOCATE 23, 2
     PRINT "  ?"
     GOSUB YESNO:
     IF Z% = 1 THEN 1
     IF Z$ = 2 THEN 2
     STOP: 'ON Z% GOTO 1, 2

2 REM
LOCATE 23, 2
PRINT "  ?"
GOSUB YESNO:
IF Z% = 1 THEN 3
IF Z% = 2 THEN 4
'ON Z% GOTO 3, 4

4 REM  
  CLS : X = 1: Y = 1
  GOSUB VOPROS:
  LOCATE 22, 3: PRINT "    ?"
  GOSUB YESNO:
  IF Z% = 1 THEN 5
  IF Z% = 2 THEN 6
  'ON Z% GOTO 5, 6

6 REM    :CLS
  FOR V = 1 TO D(B) + 1
   LOCATE 15, 14: PRINT O$(B, V)
  NEXT V
  LOCATE 20, 12: PRINT "   ?"
  GOSUB YESNO:
  IF Z% = 1 THEN 7
  IF Z% = 2 THEN 8
  'ON Z% GOTO 7, 8

8 REM:CLS
  LOCATE 21, 3: PRINT "   ?"
  GOSUB YESNO:
  IF Z% = 1 THEN 9
  IF Z% = 2 THEN 10
  'ON Z% GOTO 9, 10

10 REM   :CLS
   LOCATE 23, 5: PRINT "   ?"
   GOSUB YESNO:
   IF Z% = 1 THEN 11
   IF Z% = 2 THEN 12
   'ON Z% GOTO 11, 12

12 REM       :CLS
   LOCATE 21, 7: PRINT "  ?"
   GOSUB YESNO:
   IF Z% = 1 THEN 13
   IF Z% = 2 THEN 500
   'ON Z% GOTO 13, 500

1 REM   :GOSUB VOPROS:
   LOCATE 18, 14: PRINT "   ?"
    FOR I = 1 TO 15
      LINE INPUT A$(B, I)
      IF A$(B, I) = "~" THEN EXIT FOR
    NEXT I
   M(B) = I - 1
   GOSUB VARIANT:
   IF X% = 1 THEN 15
   IF X% = 2 THEN 1
   'ON Z% GOTO 15, 1
15 REM
   CLS
   GOSUB VOPROS:
   GOTO 2

3 REM  
     LOCATE 23, 7: PRINT "      "
     KEY(11) ON
     KEY(12) ON
     KEY(13) ON
     KEY(14) ON
25 'ON KEY(11) GOSUB 20
   'ON KEY(12) GOSUB 21
   'ON KEY(13) GOSUB 22
   'ON KEY(14) GOSUB 23

20 REM UP  
   Y = Y - 1
   IF Y < 1 THEN Y = 20
      FOR I = 1 TO M(B)
         LOCATE Y, X: PRINT "A$(B,I)"
         Y = Y + 1
      NEXT I
   Y = Y - M(B)
   GOSUB VARIANT:
   IF X% = 1 THEN 30
   IF X% = 2 THEN 25
   'ON X% GOTO 30, 25
RETURN

21 REM LEFT
   X = X + 1
   IF X < 1 THEN X = 80
      FOR I = 1 TO M(B)
         LOCATE Y, X
         PRINT A$(B, I)
      NEXT I
   GOSUB VARIANT:
   IF X% = 1 THEN 30
   IF X% = 2 THEN 25
   'ON X% GOTO 30, 25

22 REM  RIGHT
   X = X + 1
   IF X > 80 THEN X = 1
       FOR I = 1 TO M(B)
          LOCATE Y, X
          PRINT A$(B, I)
       NEXT I
   GOSUB VARIANT:
   IF X% = 1 THEN 30
   IF X% = 2 THEN 25
   'ON X% GOTO 30, 25

23 REM DOWN
   Y = Y + 1
   IF Y > 24 THEN Y = 1
       FOR I = 1 TO M(B)
          LOCATE Y, X
          PRINT A$(B, I)
          Y = Y + 1
       NEXT I
       Y = Y - M(B)
       GOSUB VARIANT:
       IF X% = 1 THEN 30
       IF X% = 2 THEN 25
       'ON X% GOTO 30, 25
30 RETURN

5 REM  ..
   LOCATE 22, 4
   INPUT "  ", D(B)
   GOSUB VARIANT:
   IF X% = 1 THEN 6
   IF X% = 2 THEN 5
   'ON X% GOTO 6, 5
7 REM   



    
9 REM      
    
    


11 REM  





13 REM  

















YESNO:
     LOCATE 25, 3
     PRINT " ,  1, , 2"
     DO UNTIL Z$ = "1" OR Z$ = "2"
        Z$ = INKEY$
     LOOP
RETURN

VOPROS:  
      CLS
      FOR I = 1 TO M(B)
         LOCATE Y, X
         PRINT A$(B, I)
      NEXT I
RETURN
    
VARIANT:  
       LOCATE 24, 5
       PRINT "  ?"
       DO UNTIL X$ = "1" OR X$ = "2"
       X$ = INKEY$
       LOOP
RETURN
    
    
    
    
500     END SUB

