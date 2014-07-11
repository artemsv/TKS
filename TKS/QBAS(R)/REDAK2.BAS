DECLARE SUB GENERAL (B, A$(), O$(), D(), M(), Y(), X(), Y1(), X1())
KEY ON
KEY 2, ""
KEY 1, "…"
KEY(1) ON
ON KEY(1) GOSUB MEHU:
SLEEP
CLS
LOCATE 13, 29
PRINT "…„€’ ’…‘’‚"
SLEEP 1
CLS
DIM A$(20, 15), M(20), D(20), O$(20, 15), W(20), o3(20), o2(20)
DIM k(500), c(200)
REM $STATIC
DIM Y(25), X(25), Y1(25), X1(25)
LOCATE 15, 25: ' INPUT "ΆΆ¥¤¨β¥ ¨¬ο δ ©« ", h$
OPEN "VAR1.BAS" FOR INPUT AS #1
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
LOCATE 12, 23: PRINT "… …„€’‚€"
PRINT : PRINT TAB(24); "1.‚‘… ‡………"
PRINT TAB(23); "2.‡………‚‘€ … N"
PRINT TAB(23); "3.‡……… …‘’€ ‚›‚„€ ‚‘€ € €"
PRINT TAB(23); "4.„€‚‹…… ‚‘‚"
PRINT TAB(23); "5.‡……… ‚…‘€ ‚‘€"
PRINT TAB(23); "6.‡……… ’……‚ –…"
DO UNTIL Z$ = "1" OR Z$ = "2" OR Z$ = "3" OR Z$ = "4" OR Z$ = "5" OR Z$ = "6"
Z$ = INKEY$
LOOP
ON Z GOTO 100

'##############################################################################
100 REM ‚‘… ‡………
    CLS : PRINT L
    FOR B = 1 TO L
    PRINT TAB(25); "‚€ ‚‘"


    CALL GENERAL(B, A$(), O$(), D(), M(), Y(), X(), Y1(), X1())
    NEXT B

MEHU:
         RUN "D:\QBAS(R)\….BAS"

SUB GENERAL (B, A$(), O$(), D(), M(), Y(), X(), Y1(), X1())
             KEY 1, "…"
             KEY OFF
             REM $STATIC
             DIM YES AS STRING * 3
             YES$ = "0"
             P$ = SPACE$(80): N$ = STRING$(25, "#")
             Y(B) = 5: X(B) = 5
             GOSUB VOPROS:
             LOCATE 1, 25
             PRINT "‚‘ …"; B;

           
             LOCATE 12, 12, 0, 1, 1: PRINT "“„…’… …’?"; : SLEEP
             GOSUB YESNO:

SELECT CASE YES$
       CASE " 1"
           CLS : GOSUB VOPROS:
           DO
               LOCATE 20, 3: PRINT "‚‚…„’… ‘‚‰ ‚‘,…‘‹ ‡€—‹ ‚‚„’,€†’… ~";
               SLEEP 2
               LOCATE 20, 3: PRINT P$;
               
               LOCATE (Y(B) + 2), (X(B))
                      FOR I = 1 TO 15
                          LOCATE (Y(B) + I + 2), (X(B)), 1
                          LINE INPUT A$(B, I)
                          IF A$(B, I) = "~" THEN EXIT FOR
                      
                          Y(B) = Y(B): X(B) = X(B)
                          NEXT I
                          M(B) = I - 1
                          CLS : GOSUB VOPROS:
                          GOSUB VARIANT: : SLEEP
                LOOP WHILE INKEY$ = "2"
                
              
          CASE "2"
END SELECT
'###################################################################################
'####################################################################################
                              
      REM „‚ƒ€’ ‚‘
          CLS : GOSUB VOPROS:
          LOCATE 24, 3: PRINT SPACE$(25);
          LOCATE 24, 3: PRINT "“„… „‚ƒ€’?"; : SLEEP
          GOSUB YESNO:
DO UNTIL YES$ = "1"
         CLS : PRINT "‚‚…• 3,‚‡ 4,‚‹…‚ 5,‚€‚ 6"
               PRINT "‚‹…› ‹€‚€ „‚ƒ€‰’… ‚‘";
               SLEEP 3
               CLS : GOSUB VOPROS:
               DO
                  S$ = INKEY$
                  IF S$ = "3" OR S$ = "4" OR S$ = "5" OR S$ = "6" THEN EXIT DO

               LOOP
      S = VAL(S$)
      SELECT CASE S

             CASE 3
                  CLS : GOSUB VOPROS:
                     FOR I = 1 TO M(B)
                       Y(B) = Y(B) - 1
                       IF Y(B) = 1 THEN Y(B) = 20
                     NEXT I
                  CLS : GOSUB VOPROS:
             CASE 4
                   CLS : GOSUB VOPROS:
                         FOR I = 1 TO M(B)
                            Y(B) = Y(B) + 1
                            IF Y(B) > 20 THEN Y(B) = 1
                         NEXT I
                   CLS : GOSUB VOPROS:
             CASE 5
                   CLS : GOSUB VOPROS:
                         FOR I = 1 TO M(B)
                             X(B) = X(B) - 1
                             IF X(B) < 1 THEN X(B) = 70
                         NEXT I
                   CLS : GOSUB VOPROS:
             CASE 6
                   CLS : GOSUB VOPROS:
                         FOR I = 1 TO M(B)
                             X(B) = X(B) + 1
                             IF X(B) > 70 THEN X(B) = 1
                         NEXT I
                   CLS : GOSUB VOPROS:
             CASE ELSE
                   U = 1
    END SELECT
     LOCATE 23, 3: PRINT "„‚ƒ€’ „€‹…?"
     GOSUB YESNO:
     LOCATE 23, 3: PRINT P$
LOOP
'##############################################################################
'#############################################################################
REM €’€ ‘ ’‚…’€
    CLS : GOSUB VOPROS: : PRINT N$
         ' LOCATE Y(B, I) + 3, X(B, I)
                 FOR V = 1 TO D(B)
                     Y1(B) = CSRLIN: X1(B) = POS(0)
                     PRINT V, "."; O$(B, V)
                     LOCATE Y1(B) + 1, X1(B)
                 NEXT V
          LOCATE 23, 4: PRINT "‚€‘ “‘’€‚€’ ’ ’‚…’›?"
          GOSUB YESNO:
SELECT CASE YES$
       CASE IS >= " 2"
            LOCATE 23, 4: PRINT P$
            LOCATE 23, 4: PRINT "‚› •’’… ‡…’ …€‚‹›… ’‚…’›?"
            GOSUB YESNO:
       SELECT CASE YES$
              CASE IS <= "1"
                   CLS : GOSUB VOPROS: : PRINT N$
                   INPUT "‘‹ “„…’ …€‚‹›• ’‚…’‚?", D(B)
               DO
                   CLS : GOSUB VOPROS: : PRINT N$
                         FOR V = 1 TO D(B)
                             LOCATE Y1(B), X1(B)
                             LINE INPUT "‚‚…„’… ‚‘"; O$(B, V)
                         NEXT V
                   CLS : GOSUB VOPROS: : PRINT P$
                         FOR V = 1 TO D(B)
                             LOCATE Y1(B), X1(B)
                             PRINT V, ".", O$(B, V)
                         NEXT V
                   LOCATE 23, 3: PRINT "γ,  β¥―¥ΰμ ‚ ¬ ­ΰ Ά¨βμαο?"
                   GOSUB YESNO:
               LOOP WHILE YES$ = "2"
              CASE ELSE
                   LOCATE 23, 3: PRINT P$
                   LOCATE 23, 3: PRINT "A,Άλ ε®β¨β¥ ―®¬¥­οβμ ―ΰ Ά¨«μ­λ© ®βΆ¥β?"
                   GOSUB YESNO:
                   DO
                     LOCATE 23, 3: PRINT P$
                     LOCATE 19, 3: PRINT "‚‚…„’… ‘‚‰ ‚€€’ €‚‹ƒ ’‚…’€"
                     LOCATE 21, 3: LINE INPUT O$(B, V)
                     LOCATE 23, 3: PRINT "β® ®ª®­η β¥«μ­λ© Ά ΰ¨ ­β?"
                     GOSUB YESNO:
                   LOOP WHILE YES$ = "2"
              END SELECT
       CASE ELSE
END SELECT

YESNO:
     LOCATE 25, 3
     PRINT "…‘‹ „€,’ €†’… 1,…‘‹ …’,’ 2"
     DO WHILE YES$ = "1" OR YES$ = "2"
        YES$ = INKEY$
     LOOP
     LOCATE 25, 3: PRINT P$
RETURN

VOPROS:
      CLS
      FOR I = 1 TO M(B)
         LOCATE Y(B), X(B)
         PRINT A$(B, I)
      NEXT I
RETURN
    
VARIANT:
       LOCATE 24, 5
       PRINT "’ —€’…‹›‰ ‚€€’?"
       DO UNTIL X$ = "1" OR X$ = "2"
       X$ = INKEY$
       LOOP
       LOCATE 24, 5: PRINT P$
RETURN
    
    
    
    
500     END SUB

