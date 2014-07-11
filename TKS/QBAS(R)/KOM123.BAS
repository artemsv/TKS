  REM         
  GOSUB 8: COLOR 2, 0
  LOCATE 2, 22
  PRINT "ŠŽŒ‹…Š‘›… —ˆ‘‹€";
  LOCATE 4, 6: PRINT "ŠŽŒ‹…Š‘›… —ˆ‘‹€-—ˆ‘‹€ ‚ˆ„€ a+bi,ƒ„… a ˆ b -„…‰‘’‚ˆ’…‹œ›… —ˆ‘‹€";
  LOCATE 5, 6: PRINT "€ i-ŒˆŒ€Ÿ …„…ˆ–€";
  LOCATE 6, 2: PRINT "******************************************************************************";
  LOCATE 7, 6: PRINT "Žƒ€ŒŒ€ Ž ‡€„€›Œ €€Œ…’€Œ a ˆ b ‚›—ˆ‘‹Ÿ…’ ŒŽ„“‹œ ˆ";
  LOCATE 8, 6: PRINT "€ƒ“Œ…’ ˆ Ž…„…‹Ÿ…’ ’ˆƒŽŽŒ…’ˆ—…‘Š“ž ˆ ŽŠ€‡€’…‹œ“ž ”ŽŒ›";
  GOSUB 22
  CLS
  GOSUB 8
1 REM Œ…ž
  CLS : GOSUB 8
  LOCATE 3, 33: PRINT "Œ…ž";
  LOCATE 5, 26: PRINT "’…“…’‘Ÿ Ž…„…‹ˆ’œ";
  LOCATE 7, 20: PRINT "1   ŒŽ„“‹œ ˆ €ƒ“Œ…’";
  LOCATE 8, 20: PRINT "2   ’ˆƒŽŽŒ…’ˆ—…‘Š“ž ”ŽŒ“";
  LOCATE 9, 20: PRINT "3   ŽŠ€‡€’…‹œ“ž ”ŽŒ“";
  LOCATE 10, 20: PRINT "4   ‚Ž‡‚…„…ˆ… ‚ –…‹“ž ‘’……œ";
  LOCATE 11, 20: PRINT "5   ŠŽ…– €Ž’›";
  LOCATE 12, 1: PRINT "********************************************************************************";
  LOCATE 21, 4: PRINT "‚›…ˆ’… “†›‰ “Š’ €†€’ˆ…Œ ‘ŽŽ’‚…’‘’‚“ž™…‰ Š‹€‚ˆ˜ˆ";
  LOCATE 22, 4: INPUT Z
  IF Z = 1 THEN 3
  IF Z = 2 THEN 6
  IF Z = 3 THEN 7
  IF Z = 4 THEN 2
  IF Z = 5 THEN 23
  CLS : GOTO 1
2 REM ‘’……œ
  CLS : GOSUB 8: GOSUB 9: GOSUB 8: GOSUB 10: GOSUB 20
  LOCATE 10, 7: PRINT "‚ Š€Š“ž –…‹“ž ‘’……œ ‚› †…‹€…’… ‚Ž‡‚…‘’ˆ ‚€˜… —ˆ‘‹Ž"; : INPUT W: CLS : GOSUB 8
  T = INT(W): S = (T + W) / 2
  IF S <> W THEN 18
  R = P ^ W: F = F * W: G = G * W
  LOCATE 10, 7: PRINT "…‡“‹œ’€’ ‚ ’ˆƒŽŽŒ…’ˆ—…‘ŠŽ‰ ”ŽŒ…";
  LOCATE 13, 10: PRINT "‚ €„ˆ€€• Z="; R; "*(COS("; F; ")+iSIN("; F; "))";
  LOCATE 14, 10: PRINT "‚ ƒ€„“‘€• Z="; R; "*(COS("; G; ")+iSIN("; G; "))";
  LOCATE 16, 7: PRINT "…‡“‹œ’€’ ‚ ŽŠ€‡€’…‹œŽ‰ ”ŽŒ…";
  LOCATE 18, 10: PRINT "‚ €„ˆ€€• Z="; R; "*e^(i*"; F; ")";
  LOCATE 19, 10: PRINT "‚ ƒ€„“‘€• Z="; R; "*e^(i*"; G; ")";
  GOSUB 22: GOTO 1
18 COLOR 2, 0: LOCATE 13, 13
  PRINT "‚‚Ž„ˆ’… ’Ž‹œŠŽ –…‹›… ‡€—…ˆŸ";
  FOR X = 1 TO 10000: NEXT X
  GOSUB 22: CLS : GOTO 1
3 REM ŒŽ„“‹œ******************************************************************
  CLS
  GOSUB 8: GOSUB 9: CLS : GOSUB 8: GOSUB 10: GOSUB 20
  IF R = 0 THEN 4
  LOCATE 12, 7: PRINT "€ƒ“Œ…’ ‚ €„ˆ€€•="; F;
  LOCATE 13, 7: PRINT "€ƒ“Œ…’ ‚ ƒ€„“‘€•="; G;
  LOCATE 14, 7: PRINT "ŒŽ„“‹œ="; R
  GOTO 5
4 REM
  LOCATE 12, 7: PRINT "€ƒ“Œ…’ …Ž…„…‹…"
  LOCATE 13, 7: PRINT "ŒŽ„“‹œ €‚… “‹ž"
5 GOSUB 22: CLS : GOTO 1
6 REM ’ˆƒŽŽŒ…’ˆŸ********************************************************
  CLS
  GOSUB 8: GOSUB 9: GOSUB 8: GOSUB 10: GOSUB 20
  IF R = 0 THEN 24
  LOCATE 12, 10: PRINT "’ˆƒŽŽŒ…’ˆ—…‘Š€Ÿ ”ŽŒ€ ‚ €„ˆ€€•"
  LOCATE 13, 15: PRINT "Z="; R; "*COS("; F; ")+iSIN("; F; "))"
  LOCATE 15, 10: PRINT "’ˆƒŽŽŒ…’ˆ—…‘Š€Ÿ ”ŽŒ€ ‚ ƒ€„“‘€•"
  LOCATE 16, 15: PRINT "Z="; R; "*(COS("; G; ")+iSIN("; G; ")"
  GOSUB 22: CLS : GOTO 1
7 REM
  GOSUB 8: GOSUB 9: CLS : GOSUB 8: GOSUB 10
  IF R = 0 THEN 25
  GOSUB 20
  LOCATE 12, 12: PRINT "ŽŠ€‡€’…‹œ€Ÿ ”ŽŒ€ ‚ €„ˆ€€•  Z="; R; "*e^(i*"; F; ")";
  LOCATE 15, 12: PRINT "ŽŠ€‡€’…‹œ€Ÿ ”ŽŒ€ ‚ ƒ€„“‘€•  Z="; R; "*e^(i*"; G; ")";
  GOSUB 22: CLS : GOTO 1
8 REM €ŒŠ€
  CLS : COLOR 5, 0
  FOR K = 4 TO 25: LOCATE K, 1: PRINT "*"; : NEXT K
  FOR K = 4 TO 25: LOCATE K, 80: PRINT "*"; : NEXT K
 
  LOCATE 1, 1: PRINT "*******************************************************************************";
  LOCATE 25, 1: PRINT "*********************************************************************************":
  COLOR 2, 0
  RETURN
9 REM
  LOCATE 3, 4: PRINT "‡€„€‰’… „…‰‘’‚ˆ’…‹œ“ž —€‘’œ ‚€˜…ƒŽ —ˆ‘‹€"; : LOCATE 4, 4: INPUT a
  LOCATE 6, 4: PRINT "‡€„€‰’… ŒˆŒ“ž —€‘’œ ‚€˜…ƒŽ —ˆ‘‹€"; : LOCATE 7, 4: INPUT b
  RETURN
10 REM
  R = SQR(a ^ 2 + b ^ 2)
  IF R = 0 THEN RETURN
  P = 4 * ATN(1)
  IF a = 0 THEN 14
  K = ATN(b / a)
  IF b = 0 THEN 11
  IF a > 0 AND b > 0 THEN 11
  IF a < 0 AND b > 0 THEN 12
  IF a < 0 AND b < 0 THEN 13
11 F = K
   GOTO 16
12 F = P + K
   GOTO 16
13 F = K - P
   GOTO 16
14 IF b = 0 THEN 15
   F = -(P / 2)
   GOTO 16
15 F = P / 2
16 IF F < 0 THEN 17
GOTO 19
17 F = F + P
19 G = (F * 180) / P
20 REM&***********************&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
   IF b < 0 THEN 21
  LOCATE 5, 5: PRINT "€‹ƒ…€ˆ—…‘Š€Ÿ ”ŽŒ€ ‚€˜…ƒŽ —ˆ‘‹€ Z="; a; "+"; b; "i"
  RETURN
21 REM
   b = ABS(b)
   LOCATE 5, 5: PRINT "€‹ƒ…€ˆ—…‘Š€Ÿ ”ŽŒ€ ‚€˜…ƒŽ —ˆ‘‹€ Z="; a; "-"; b; "i"
   RETURN
22 REM:COLOR 8,2
   LOCATE 21, 4: PRINT "„‹Ÿ Ž„Ž‹†…ˆŸ €Ž’› €†Œˆ’… ‹ž“ž Š‹€‚ˆ˜“";
   LOCATE 22, 4: INPUT a&: PRINT : PRINT : RETURN
24 REM
   CLS
   GOSUB 8: COLOR 8, 2
   LOCATE 15, 5: PRINT "‚€˜… —ˆ‘‹Ž €‚Ž “‹ž"
   LOCATE 17, 5: PRINT "’ˆƒŽŽŒ…’ˆ—…‘Š€Ÿ ”ŽŒ€ Ž’‘“’‘’‚“…’,’€Š Š€Š €ƒ“Œ…’ …Ž…„…‹…"
   LOCATE 20, 5: PRINT "€—ˆ’… ‘ €—€‹€"; : INPUT D&
   GOTO 1
25 REM
   LOCATE 15, 5: PRINT "‚€˜… —ˆ‘‹Ž €‚Ž “‹ž"
   LOCATE 20, 5: PRINT "ŽŠ€‡€’…‹œ€Ÿ ”ŽŒ€ Ž’‘“’‘’‚“…’,’€Š Š€Š €ƒ“Œ…’ …Ž…„…‹…"
   LOCATE 23, 5: PRINT "€—ˆ’… ‘ €—€‹€"; : INPUT D&
   GOTO 1
23 SCREEN 1
   COLOR 2, 0: CLS
   LINE (10, 10)-(310, 190), 2, B
   LINE (20, 20)-(300, 180), 0, BF
   LOCATE 13, 13
   PRINT "THE END OF WORK"






