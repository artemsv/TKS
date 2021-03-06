unit MVarian2;                     {��� �����⥫쭮� ���ᨨ: 17.01.01}

interface

uses Dos,Crt,MRed,Drivers,MyFunc,Views,MsgBoxMy,Objects,Types,MyLib,MHelp;

type
  PVariant=^TVariant;
  TVariant=object(TEditor)
    nQ:integer;                           {������⢮ ����ᮢ � ��ਠ��}
    nV:integer;                           {������⢮ ��ਠ�⮢}
    mismach:boolean;                      {true-� ��ਠ�� ��砩�� ������}
    oneTema:boolean;                      {true-��ਠ��� ����⥬��}
    cBaseBlocks:PCollection;              {�������� � ������� �� ���. 䠩��}
    ntem:integer;                         {������⢮ ⥬ � ��ਠ��}
    total,summa:integer;
    constructor Init;
  end;

implementation

constructor TVariant.Init;
const
  mCBlocks:array[1..10] of PCollection=
        (nil,nil,nil,nil,nil,nil,nil,nil,nil,nil);
var
  mHeader:array[1..10] of THeader;      {���ᨢ ���������� ⥬ � ��ਠ��}
  k,i:byte;
  numVar:byte;
  mas:array[0..20] of integer;          {���ᨢ ��砩��� ����஢ ����ᮢ}
  p:PChar;
  newIndex:string;                      {����� ���७�� ᡮ୮� ⥬�}
begin
  mismach:=true;
  if InputInt(1,maxVoprsInVar,'������⢮ ����ᮢ � ��ਠ��',nQ,hcVarNq)=
      cmCancel then  Exit;
  if InputInt(1,maxTemInVar,'������⢮ ⥬ � ��ਠ��',ntem,hcVarNTem)=
      cmCancel then Exit;
  total:=0;summa:=0;
  for k:=1 to nTem do
  begin
    if SelectTema(mHeader[k])=cmCancel then Fail;
    total:=total+summa;
    repeat
      if InputInt(1,nQ-total,'������⢮ ����ᮢ �� ⥬� '+
        mHeader[k].tema,summa,hcVarSumma)=cmCancel then exit;
    until nQ-total>=ntem-k;
    mHeader[k].colv:=summa;
  end;
  if nTem=1 then
  begin
    newIndex:=mHeader[1].index;
    w:=MessageBox(#3'������ ��६�訢���?',nil,mfYesNoCancel);
    if w=cmCancel then Exit;
    mismach:=w=cmYes;
    if not mismach then
    begin
      nV:=mHeader[1].nn div nQ;
      k:=mHeader[1].nn mod nQ;
      if k<>0 then
      begin
        MessageBox(#3'������⢮ ����ᮢ('+Sstr(mHeader[1].nn)+
          ')  �� �⮩ ⥬� �� ������� ��楫� �� �ॡ㥬�� �᫮ ����ᮢ('+
          Sstr(nQ)+')',nil,mfOkButton);
        Exit;
      end else
      if MessageBox(#3+'�������� '+Sstr(nV)+' ��ਠ��(a,��)'+#13+#13+
      #3'���ࠨ����?',nil,mfYesButton+mfNoButton)=cmNo then Exit;
    end else
      if InputInt(1,maxVarInTema,'�ॡ㥬�� ������⢮ ��ਠ�⮢',nV,hcVarNv)
          =cmCancel then Exit;
  end else
  begin
    if InputInt(1,maxVarInTema,'�ॡ㥬�� ������⢮ ��ਠ�⮢',nV,hcVarNv)=
      cmCancel then Exit;
    if Inputbox('','������ ����� ���७��',newIndex,hcVarNewIndex,0)=
      cmCancel then Exit;
  end;
  for k:=1 to nTem do
  begin
    filename:=mHeader[k].fName;                    {������ 䠩� ⥬�}
    if not LoadEditFile(mCBlocks[k]) then
    begin
      Dispose(cBlocks,Done);
      Fail
    end;
  end;
  lines:=mCBlocks[1]^.At(0);                     {����砥� ��������� ⥬�}
  Four(0,nV,mChar);Four(4,nQ,mChar);Four(8,nQ,mChar);
  for k:=0 to 11 do lines[k]:=mChar[k];      {�����塞 lines(�.�. ���������}
  cBlocks^.AtPut(0,lines);                   {��⠢�塞 ��������� ���������}
  p:=lines;                                  {p-㪠��⥫� �� ���������}
  {$I-}                                      {���室�� � ��⠫�� VAR}
  ChDir('\TEST\VAR');
  if IOResult<>0 then
  begin
    MessageBox(#3'��⠫�� VAR �� ������!',nil,mfOkButton);
    cBlocks^.DeleteAll;
    Dispose(cBlocks,Done);
    Exit
  end;
  cBlocks:=New(PCollection,Init(50,5));
                                        {横� ����� �� ��� ������ ��ਠ��}
  for numVar:=1 to nV do
  begin
    filename:=MakeVarFileName(newIndex,numVar);       {�ﯠ�� ��� 䠩��}
    cBlocks^.Insert(p);                               {��⠢��� ���������}
    for k:=1 to nTem do
    begin
      if mismach                                      {��砩�� ������}
        then Duplet(mHeader[k].nn,mHeader[k].colv,mas)
                                                      {�� ���浪�}
        else for k:=1 to mHeader[k].colv do mas[k]:=k+(numVar-1)*nQ;
      for i:=1 to mHeader[k].colv do    {������塞 ��砩�묨 �������}
        cBlocks^.Insert(mCBlocks[k]^.At(mas[i]));
    end;
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
