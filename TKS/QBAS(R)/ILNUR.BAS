PR = 0
SET TALK
DO WHILE PR < 5
COLOR 1
@ 2,10 SAY " ƒ‹€‚Ž… Œ…ž"
@ 2,10 TO 2,24 DOUBLE
COLOR 2
@ 4,1 SAY "1.€•Ž†„…ˆ… ŒŽ„“‹Ÿ ˆ €ƒ“Œ…’€ "
COLOR 3
@ 5,1 SAY "2.„…‰‘’‚ˆ… ‚ €‹ƒ…€ˆ—…‘ŠŽ‰ ”ŽŒ…"
COLOR 4
@ 6,1 SAY "3.„…‰‘’‚ˆ… ‚ ’ˆƒŽŽŒ…’ˆ—…‘ŠŽ‰ ”ŽŒ…"
COLOR 5
@ 7,1 SAY "4.‚›•Ž„"
MENU TO PR
IF PR = 1
CLEAR
INPUT A, B
R = SQR(A ^ 2 + B ^ 2)
IF A>0 .OR. B>0 THEN 5
IF A<0 .OR. B>0 THEN 6
IF A<0 .OR. B<0 THEN 7
IF A>0 .OR. B<0 THEN 8
5 S = ATN(B / A): GOTO 9
6 S = 4 * ATN(1) - ATN(INT(B / A)): GOTO 9
7 S = -4 * ATN(1) + ATN(INT(B / A)): GOTO9
8 S = ATN(B / A): GOTO 9
COLOR 6
9 PRINT "R="; R, "S="; S : WAIT A$
END IF
IF PR =2
CLEAR
COLOR 7
A = 0
DO WHILE A < 6
@ 2,7 SAY " „…‰‘’‚ˆ… ‚ €‹ƒ…€ˆ—…‘ŠŽ‰ ”ŽŒ…"
COLOR 8
@ 4,5 SAY "1.‘‹Ž†…ˆ…"
@ 5,5 SAY "2.“ŒŽ†…ˆ…"
@ 6,5 SAY "3.‚›—ˆ’€ˆ…"
@ 7,5 SAY "4.„…‹…ˆ…"
@ 8,5 SAY "5.‚›•Ž„"
MENU TO A
IF A=1
CLEAR
INPUT A1, B1, A2, B2
Z 1 = A 1 + A 2 ; Z 2 = B 1 + B 2
IF Z2 < 0 THEN 10
COLOR 8
PRINT "Z="; Z1; "+"; Z2; "J": GOTO 11
10 PRINT "Z="; Z1; Z2; "J"
11 WAIT A$
END IF
IF A=2
CLEAR
INPUT A1, A2, B1, B2
Z 1 = A 1 * A 2 ; Z 2 = B 1 * B 2
IF Z2 < 0 THEN 12
PRINT "Z="; Z1; "+"; X2; "J": GOTO 13
12 PRINT "Z="; Z1; Z2; "J"
13 WAIT A$
END IF
IF A=3
CLEAR
INPUT A1, B1, A2, B2
COLOR 7989





