unit MVariant;

interface

uses Dos,Crt,MRed,Drivers,MyFunc,Views,MsgBoxMy,Objects,Types,MyLib;

type
  PVariant=^TVariant;
  TVariant=object(TEditor)
    nQ:integer;                           {������⢮ ����ᮢ � ��ਠ��}
    nV:integer;                           {������⢮ ��ਠ�⮢}
    mismach:boolean;                      {true-� ��ਠ�� ��砩�� ������}
    oneTema:boolean;                      {true-��ਠ��� ����⥬��}
    cBaseBlocks:PCollection;              {�������� � ������� �� ���. 䠩��}
    constructor Init;
  end;

implementation

constructor TVariant.Init;
var
  a:word;
  k:byte;
  numVar:byte;
  mas:array[0..20]of integer;
  p:PChar;
begin
  a:=MessageBox(#3'������ ��६�訢���?',nil,mfYesNoCancel);
  mismach:=a=cmYes;
  if a=cmCancel then Exit
  else if mismach then
  if InputInt(1,100,'�ॡ㥬�� ������⢮ ��ਠ�⮢',nV,0)=cmCancel then Exit;
  if InputInt(1,20,'������⢮ ����ᮢ � ��ਠ��',nQ,0)=cmCancel then  Exit;
  a:=MessageBox(#3'������ � ��ਠ�� ����⥬��?',nil,mfYesNoCancel);
  if a=cmCancel then Exit else oneTema:=a=cmYes;
  if SelectTema(header)=cmCancel then Exit;
  if not mismach then
    begin
      k:=header.nn div nQ;
      nV:=k;
      if MessageBox(#3+'�������� '+Sstr(k)+' ��ਠ��(a,��)'+#13+#13+
      #3'���ࠨ����?',nil,mfYesButton+mfNoButton)=cmNo then Exit;
    end;
  filename:=header.fName;                    {������ 䠩� ⥬�}
  if not LoadEditFile then
  begin
    Dispose(cBlocks,Done);
    Fail
  end;
  cBaseBlocks:=New(PCollection,Init(50,5));
  lines:=cblocks^.At(0);                     {����砥� ��������� ⥬�}
  Four(0,nV,mChar);Four(4,nQ,mChar);Four(8,nQ,mChar);
  for k:=0 to 11 do lines[k]:=mChar[k];      {�����塞 lines(�.�. ���������}
  cBlocks^.AtPut(0,lines);                   {��⠢�塞 ��������� ���������}
  for k:=0 to cBlocks^.count-1 do            {ᮧ���� ��������-�㡫����}
    begin
      p:=cBlocks^.At(k);
      cBaseBlocks^.Insert(p);
    end;
  p:=lines;                                  {p-㪠��⥫� �� ���������}
  cBlocks^.DeleteAll;                        {����塞 ࠡ���� ��������}

  {$I-}                                      {���室�� � ��⠫�� VAR}
  ChDir('\TEST\VAR');
  if IOResult<>0 then
  begin
    MessageBox(#3'��⠫�� VAR �� ������!',nil,mfOkButton);
    cBlocks^.DeleteAll;
    Dispose(cBlocks,Done);
    Exit
  end;
                                        {横� ����� �� ��� ������ ��ਠ��}
  for numVar:=1 to nV do
    begin
      filename:=MakeVarFileName(header.index,numVar);
      if mismach
        then Duplet(header.nn,nQ,mas)                    {��砩�� ������}
        else for k:=1 to nQ do mas[k]:=k+(numVar-1)*nQ;  {�� ���浪�}
      cBlocks^.Insert(p);                                {��⠢��� ���������}
      for k:=1 to nQ do                       {������塞 ��砩�묨 �������}
          cBlocks^.Insert(cBaseBlocks^.At(mas[k]));
      SaveEditFile(false);
      cBlocks^.DeleteAll;
    end;

  Sound(1000);
  MessageBox(#3'C��⠢����: '+Sstr(nV)+' ��ਠ�⮢.',nil,mfOkButton);
  Nosound;
  ChDir('\TEST\TEMA');
  filename:='tema.'+header.index;
  if not OpenFile(filename,pf,0,true) then
  begin
    MessageBox(#3'�����ࠧ��!!!',nil,mfOkButton);
    Exit;                                               {??????????}
  end;
  Four(0,nV,mChar);         {�����.� ������ 䠩� ���-�� ��⠢�.��ਠ�⮢}
  for k:=0 to 3 do Write(tfc(pf^),mChar[k]);
  Close(tfc(pf^));
end;
end.