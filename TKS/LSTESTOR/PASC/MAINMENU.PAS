Unit Mainmenu;

Interface

uses menutest,ramatest;

Var
w:men;
k:byte;

Procedure Clea;
Procedure Mm(var r:byte);
Procedure Mm2(var r:byte);
Procedure Mm3(var r:byte);

Implementation

Procedure Clea;

Var
b:byte;

Begin
for b:= 1 to 100 do
  w.vop[b]:='';
end;

Procedure Mm(var r:byte);

Begin
clea;
cleaall;
rama1;
w.vop[1]:='����஢����';
w.vop[2]:='������஢���� ��⮢';
w.vop[3]:='����ன�� ।����';
w.vop[4]:='NIL';
menu(w,r);
end;

Procedure Mm2(var r:byte);

Begin
clea;
cleaall;
rama1;
w.vop[1]:='��������� �����';
w.vop[2]:='��������� �⢥⮢';
w.vop[3]:='��������� ��� �����';
w.vop[4]:='�������� ���� ���';
w.vop[5]:='������� ���';
w.vop[6]:='NIL';
menu(w,r);
end;

Procedure Mm3(var r:byte);

Begin
clea;
cleaall;
rama1;
w.vop[1]:='������஢���� ��㯯 � 䠬���� ������';
w.vop[2]:='��������� ��஫�� ��⥬�';
w.vop[3]:='��������� �⠢�� �� ���⠢����� �業��';
w.vop[4]:='��������� ��ࠬ��� ⠩���';
w.vop[5]:='�������� ������';
w.vop[6]:='��������� 䠩�� ���஢���� (�� 㬮�砭��)';
w.vop[7]:='��������� 䠩�� ���� (�� 㬮�砭��)';
w.vop[8]:='��������� 䠩�� ��㯯 (�� 㬮�砭��)';
w.vop[9]:='��ᬮ�� ��⠭����';
w.vop[10]:='NIL';
menu(w,r);
end;

Procedure Mm4(var r:byte);

Begin
clea;
cleaall;
rama1;
w.vop[1]:='�������� ��饣���';
w.vop[2]:='������� ��饣���';
w.vop[3]:='NIL';
menu(w,r);
end;
end.

