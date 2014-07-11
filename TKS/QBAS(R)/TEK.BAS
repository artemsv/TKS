CLS
KEY ON
KEY 2, ""
KEY 1, "МЕНЮ"
KEY(1) ON
ON KEY(1) GOSUB VIXOD:



LOCATE 3, 13
PRINT "ДАННАЯ ПРОГРАММА СОСТАВЛЯЕТ ТЕСТЫ НА ЗАДАННУЮ ТЕМУ"
PRINT "\/\/\/\/\/\/\/\/\/\/\/\/\/\//\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/"

FOR EW = 1 TO 123238
NEXT EW


10 CLS
DIM a$(20, 15), m(20), a1(20), d(20), o$(20, 15), t1(20), t$(20, 10), k$(20, 15), k1(20), w(20), f(20)
l2 = 0
GOSUB 189
GOSUB 1870
z2 = 1: z3 = l
FOR b = z2 TO z3
GOSUB 12
FOR i = 1 TO 15
LINE INPUT a$(b, i)
IF a$(b, i) = "~" THEN 310
NEXT i
m(b) = 15: GOTO 320
310 m(b) = i - 1
320 GOSUB 980
CLS
n = m(b): r = 23 - n
PRINT "Текст вопроса занимает на экране "; n
IF n = 1 THEN PRINT "строку .": GOTO 540
IF n < 4 THEN PRINT "строки.": GOTO 540
IF n >= 5 AND n <= 9 THEN PRINT "строк."
540 PRINT " количество свободных строк для размещения меню ответов-"; r
IF r > 14 THEN PRINT "кол-во ответов не должно превышать 15"
570 INPUT "Кол-во неправильных ответов ", d(b)
IF d(b) >= r THEN 540
IF d(b) = 0 THEN PRINT "Их должно быть больше 0": GOTO 570
FOR v = 1 TO d(b)
PRINT "Задайте "; v; "-й неправильный ответ"
PRINT v; " "; : LINE INPUT o$(b, v): PRINT
NEXT v
PRINT "Задайте правильный ответ: "
LINE INPUT o$(b, v)
NEXT b
CLS
PRINT "Дайте информацию о выставлении оценки."
PRINT
PRINT "На ск-ко процентов должен быть правильным ответ,чтобы поставить:": PRINT
INPUT "оценку 3 ", j3
INPUT "оценку 4 ", j4
INPUT "оценку 5 ", j5
CLS
INPUT "Введите имя файла: ", h$
OPEN h$ FOR OUTPUT AS #1
PRINT #1, l1$; ","; z4
FOR b = 1 TO z4
PRINT #1, w(b); ","; m(b)
FOR i = 1 TO m(b)
PRINT #1, a$(b, i)
NEXT i
PRINT #1, d(b)
FOR v = 1 TO d(b) + 1
PRINT #1, o$(b, v)
NEXT v
NEXT b
PRINT #1, j3; ","; j4; ","; j5
CLOSE
CHAIN "D:\QBAS(R)\MEHЮ.BAS"

189 CLS
PRINT "Введите количество вопросов"
INPUT "", l
z4 = l
RETURN
1870 CLS
INPUT "Введите название темы: ", l1$
RETURN
980 CLS
INPUT "Вес вопроса (от 1 до 10) ", w(b)
RETURN
5000 RETURN
12 REM
CLS
LOCATE 13, 4
PRINT "Введите-"; b; "-й вопрс"
PRINT " Если кончили вводить вопрос: то нажмие клавишу ~"
RETURN
VIXOD:
RUN "D:\QBAS(R)\МЕНЮ.BAS"

