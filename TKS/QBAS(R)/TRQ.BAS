 CLS
RANDOMIZE TIMER
'INPUT "Введите имя файла: ", h$
DIM a$(20, 15), m(20), d(20), o$(20, 15), w(20), o3(20), o2(20), k(500), c(200)
h$ = "d:\qbasic\cs.bas"
OPEN "ЦУМС.BAS" FOR INPUT AS #1
INPUT #1, L1$, l
FOR b = 1 TO l
INPUT #1, w(b), m(b)
FOR i = 1 TO m(b)
LINE INPUT #1, a$(b, i)
NEXT i
INPUT #1, d(b)
FOR V = 1 TO d(b) + 1
LINE INPUT #1, o$(b, V)
NEXT V
NEXT b
INPUT #1, j3, j4, j5
CLOSE
'-----------------------------------------------
z9 = l
FOR k = 0 TO l
c(i) = INT(z9 * RND(k) + 1)
777 FOR i = 1 TO k
IF i = k THEN 788
IF c(i) <> c(k) THEN 788
c(k) = INT(z9 * RND(k) + 1)
GOTO 777
788 NEXT i
NEXT k
FOR m98 = 1 TO l
PRINT c(m)
NEXT m98

'------------------------------------------------
FOR b = 1 TO l
CLS
FOR i = 1 TO m(b)
PRINT a$(c(b), i)
NEXT i
PRINT "-----------------------------------------------------------------------------"
d = d(b) + 1: z = d
FOR i = 1 TO d
ng(i) = INT(z * RND(i)) + 1
610 FOR j = 1 TO i
IF j = i THEN 600
IF ng(j) <> ng(i) THEN 600
ng(i) = INT(z * RND(i) + 1)
GOTO 610
600 NEXT j
IF ng(i) = z THEN c5 = i
PRINT i; ". "; o$(c(b), ng(i))
NEXT i
620 PRINT : PRINT : PRINT "Введите номеp пpавильного ответа": INPUT rtp
IF rtp <> c5 THEN o3(b) = rtp:  la(b) = c(b): novik = novik + 1
IF rtp = c5 THEN o2(b) = o2(b) + 1: k% = k% + w(b)
CLS
NEXT b
650 PRINT "                          Дата опpоса: "; DATE$
PRINT "                           Вpемя опроса:"; TIME$
PRINT
PRINT
INPUT "Введите имя тестируемого: ", nama$
INPUT "Введите название группы:  ", gr$
GOSUB 2000
GOTO otp:
2000 FOR h = 1 TO l
n = n + w(h)
NEXT h
r = k% * 100 / n
IF r < j3 THEN oc = 2
IF r = j3 OR r > j3 AND r < j4 THEN oc = 3
IF r = j4 OR r > j4 AND r < j5 THEN oc = 4
IF r = j5 OR r > j5 THEN oc = 5
otp:
OPEN "SS.BAS" FOR APPEND AS #2
PRINT #2, nama$; ","; gr$; ","; oc; ","; r
notv$ = STR$(la(1))
IF notv$ = "0" THEN 50
FOR ti = 2 TO novik
la$ = STR$(la(ti))
notv$ = notv$ + "," + la$
NEXT ti
PRINT #2, notv$
50 CLOSE
RUN "D:\QBAS(R)\ЗАПИСЬ.BAS"
END

