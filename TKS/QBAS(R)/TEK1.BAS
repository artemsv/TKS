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
PRINT "����� ����� �������� �� ��࠭� "; n
IF n = 1 THEN PRINT "��ப� .": GOTO 540
IF n < 4 THEN PRINT "��ப�.": GOTO 540
IF n >= 5 AND n <= 9 THEN PRINT "��ப."
540 PRINT " ������⢮ ᢮������ ��ப ��� ࠧ��饭�� ���� �⢥⮢-"; r
IF r > 14 THEN PRINT "���-�� �⢥⮢ �� ������ �ॢ���� 15"
570 INPUT "���-�� ���ࠢ����� �⢥⮢ ", d(b)
IF d(b) >= r THEN 540
IF d(b) = 0 THEN PRINT "�� ������ ���� ����� 0": GOTO 570
FOR v = 1 TO d(b)
PRINT "������ "; v; "-� ���ࠢ���� �⢥�"
PRINT v; " "; : LINE INPUT o$(b, v): PRINT
NEXT v
PRINT "������ �ࠢ���� �⢥�: "
LINE INPUT o$(b, v)
NEXT b
CLS
PRINT "���� ���ଠ�� � ���⠢����� �業��."
PRINT
PRINT "�� �-�� ��業⮢ ������ ���� �ࠢ���� �⢥�,�⮡� ���⠢���:": PRINT
INPUT "�業�� 3 ", j3
INPUT "�業�� 4 ", j4
INPUT "�業�� 5 ", j5
CLS
INPUT "������ ��� 䠩��: ", h$
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
END
189 CLS
PRINT "������ ������⢮ ����ᮢ"
INPUT "", l
z4 = l
RETURN
1870 CLS
INPUT "������ �������� ⥬�: ", l1$
RETURN
980 CLS
INPUT "��� ����� (�� 1 �� 10) ", w(b)
RETURN
5000 RETURN
12 REM
PRINT "������-"; b; "-� �����"
PRINT " �᫨ ���稫� ������� �����: � ������ ������� ~"
RETURN

