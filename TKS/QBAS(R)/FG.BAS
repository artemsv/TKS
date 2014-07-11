a = 309: B = 228
SCREEN 12
DIM a%(5000)
CIRCLE (a, B), 10, 4
GET (a - 20, B - 20)-(a + 20, B + 20), a%
CLS
LINE (0, 0)-(618, 456), 4, B
LINE (1, 1)-(617, 455), 9, B
CIRCLE (a, B), 308, 4
';PAINT (5, 5), 2, 9
';PAINT   (600, 450), 2, 9


PUT (a, B), a%, XOR
10 a$ = INKEY$
IF a$ = "" THEN 10
IF a$ = "1" THEN GOSUB lft:
IF a$ = "3" THEN GOSUB rght:
IF a$ = "2" THEN GOSUB dwn:
IF a$ = "5" THEN GOSUB up:  ELSE 10
GOTO 10
lft:
PUT (a, B), a%, XOR
a = a - 5
PUT (a, B), a%, OR
RETURN
rght:
PUT (a, B), a%, XOR
a = a + 5
PUT (a, B), a%, OR
RETURN
dwn:
PUT (a, B), a%, XOR
B = B + 5
PUT (a, B), a%, OR
RETURN
up:
PUT (a, B), a%, XOR
B = B - 5
PUT (a, B), a%, OR
RETURN

