CLS
INPUT "������ ��� 䠩��: ", h$
DIM a$(20, 15), m(20), d(20), o$(20, 15), w(20), o3(20), o2(20)
OPEN h$ FOR INPUT AS #1
INPUT #1, l1$, l
FOR b = 1 TO l
INPUT #1, w(b), m(b)
FOR i = 1 TO m(b)
LINE INPUT #1, a$(b, i)
NEXT i
INPUT #1, d(b)
FOR v = 1 TO d(b) + 1
LINE INPUT #1, o$(b, v)
NEXT v
NEXT b
INPUT #1, j3, j4, j5
CLOSE
10 CLS
PRINT
PRINT
PRINT
PRINT
PRINT TAB(20); "1-������ �᫮ ����ᮢ"
PRINT TAB(20); "2-������ ᮤ�ঠ��� ����ᮢ"
PRINT TAB(20); "3-������ ���-�� ���ࠢ����� �⢥⮢"
PRINT TAB(20); "4-������ ᮤ�ঠ��� ���ࠢ����� �⢥⮢"
PRINT TAB(20); "5-������ ᮤ�ঠ��� �ࠢ����� �⢥⮢"
PRINT TAB(20); "6-������"
PRINT TAB(20); "7-�����"
100 za$ = INKEY$
IF za$ = "1" THEN 2000
IF za$ = "2" THEN 3000
IF za$ = "3" THEN 4000
IF za$ = "4" THEN 5000
IF za$ = "5" THEN 6000
IF za$ = "6" THEN 7000
IF za$ = "7" THEN END ELSE 100
2000  CLS
PRINT "�㤥� ������ �᫮ ����ᮢ?"
LOCATE 20, 20
PRINT "������ �㤥�?"
GOSUB 5
CLS
INPUT "B����� ���-�� ����ᮢ: ", l
GOTO 10
3000
FOR i = 1 TO l
225 CLS
PRINT "�㤥� ������ ᮤ�ঠ��� "; i; "-�� �����?"
GOSUB 5
FOR y = 1 TO 15
LOCATE 20, 20
PRINT "������ "; i; "-� �����"
LOCATE 7 + y, 3
LINE INPUT a$(i, y)
IF a$(i, y) = "~" THEN 20
NEXT y
CLS
m(i) = 15: GOTO 25
20 m(i) = y - 1
CLS
FOR f = 1 TO m(i)
PRINT a$(i, f)
NEXT f
LOCATE 20, 20
PRINT "�㤥� �� ������?"
PRINT "�᫨ ���-1  ,��-0"
INPUT v
IF v = 0 THEN 225
25 NEXT i
GOTO 10
4000 CLS
PRINT "�㤥� ������ ���-�� ���ࠢ����� �⢥⮢"
GOSUB 5
CLS
INPUT "������ ����� � ���-�� ������� �⢥⮢: ", b, i
d(b) = i
GOTO 10
5000 CLS
FOR b = 1 TO l
PRINT "�㤥� ������ �⢥�� "; b; "-�� �����"
INPUT da$
IF da$ = "Y" OR da$ = "y" OR da$ = "�" OR da$ = "�" THEN 35
IF da$ = "~" THEN 10
FOR k = 1 TO d(b)
PRINT "�㤥� ������ "; k; "-� ������ �⢥� "; b; "-�� �����"
INPUT da$
IF da$ = "y" OR da$ = "Y" OR da$ = "�" OR da$ = "�" THEN 34
IF da$ = "~" THEN 35
CLS
INPUT o$(b, k)
CLS
PRINT o$(b, k)
34 NEXT k
35 NEXT b
CLS
GOTO 10
6000
FOR b = 1 TO l
CLS
PRINT o$(b - 1, d(b) + 1)
PRINT "�㤥� ������ ���� �⢥� �"; b; "-� �����"
INPUT da$
CLS
IF da$ = "Y" OR da$ = "y" OR da$ = "�" OR da$ = "�" THEN GOTO 38
IF da$ = "~" THEN 10
INPUT o$(b, d(b) + 1)
38 NEXT b
GOTO 10
7000 CLS : INPUT h$
OPEN h$ FOR OUTPUT AS #1
PRINT #1, l1$, l
FOR b = 1 TO l
PRINT #1, w(b), m(b)
FOR i = 1 TO m(b)
PRINT #1, a$(b, i)
NEXT i
PRINT #1, d(b)
FOR v = 1 TO d(b) + 1
PRINT #1, o$(b, v)
NEXT v
NEXT b
PRINT #1, j3, j4, j5
CLOSE
















5 PRINT "�᫨ �� - '� ' ���� '�'"
6 az$ = INKEY$
IF az$ = "" THEN 6
IF az$ = "y" OR az$ = "Y" OR az$ = "�" OR az$ = "�" THEN 10 ELSE
RETURN
15 PRINT "�㤥� ������?"
7 as$ = INKEY$
IF as$ = "" THEN 7
IF as$ = "y" OR as$ = "Y" OR as$ = "�" OR as$ = "�" THEN
END IF
RETURN















