CLS
DIM n(50)
PRINT "������ �᫮,�⭮�⥫쭮 ���ண� �㦭� �ய��樮���쭮 "
PRINT "                    ��।�����  童�� �鸞"
INPUT B
INPUT "������ ������⢮ 童��� � ���: ", m

'���� ��� 童��� �鸞 � ��宦����� �� �㬬�(�� �㬬� ࠢ�� B)

FOR i = 1 TO m
  PRINT "������ "; i; "-� 童� �鸞: ";
  INPUT n(i)
  A = A + n(i)
NEXT i

'��宦����� �����樥�� �ய��樮���쭮��

k = B / A

'��宦����� ������ �鸞 �ᥫ

PRINT "       ����� ������ �鸞"
PRINT
FOR i = 1 TO m
  PRINT i; ".", k * n(i)
NEXT

'�஢�ઠ

FOR i = 1 TO m
  S = S + k * n(i)
NEXT
PRINT "�஢�ઠ:"; "  "; "�㬬� ������ �鸞 ࠢ��: "; S

