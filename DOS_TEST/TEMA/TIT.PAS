function  Titul(var header:THeader):word;
const
  st:string='';
  mmm:byte=0;
  mLin : set of byte=[];
var
  R      : TRect;
  h      : THead;
  code,dd: integer;
begin
  Titul:=cmCancel;
  repeat
    if InputBox('','������ ����� ⥬�',st,12,0)=cmCancel then Exit;
  until st<>'';
  header.tema:=st;st:='';
  repeat
    if InputBox('','������ ���७��',st,3,0)=cmCancel then Exit;
    header.index:=st;
    st:='tema.'+st;
    if Verify(st,GetCurDir) then MessageBox(#3'������ ���७��'+#13+#13+
            #3'㦥 ��१�ࢨ஢���!',nil,mfOkButton);
  until not Verify(st,GetCurDir) or (length(st)=3);
  header.fName:=st;
  if InputInt(10,maxTime,'�६�,�⢮��饥�� �� ���� �����',header.tim,0)=
    cmCancel then Exit;;
  if InputInt(1,maxVoprsInTema,'������⢮ ����ᮢ',header.ckolko,0)=
    cmCancel then Exit;;
  if InputInt(1,maxWrongAnswer,'������⢮ ���ࠢ����� �⢥⮢',dd,0)=
    cmCancel then Exit;;
  st:='';
  if not OpenFile('temas.dat',pf,3,true) then Exit;
  while not Eof(tfh(pf^)) do
  begin                                   {��������� ������⢮ ������ ⥬}
    Inc(mmm);
    Read(tfh(pf^),h);
    Include (mLin,h.ktem);
  end;
  repeat                        {�஢�ઠ �� �ਣ����쭮��� ������ ����}
    if InputBox('','������ ��� ⥬�',st,3,0)=cmCancel then Exit;
    Val(st,mmm,code);
    if mmm in mLin then MessageBox(#3'��� ��� ��१�ࢨ஢��!',
      nil,mfOkButton) else if code=0 then Break
  until false;
  {��������!!! 04.12.01 �����㦨���� ��࠭��� ����:㪠��⥫� pf ���⨫�� �
      �� �맮�� InputInt (䠩� tfh(pf^) �ॢ�頫�� � �������!!!}
  with header do
  begin
    d:=mmm*100+dd;                     {㯫�⭥��� header.d}
    j3:=55;j4:=70;j5:=85;nn:=0;colv:=0;
  end;
  h.kTem:=mmm;
  header.kTem:=mmm;
  h.tema:=header.tema;
  h.index:=header.index;
  Seek(tfh(pf^),FileSize(tfh(pf^)));
  Write(tfh(pf^),h);
  Close(tfh(pf^));
  WriteHeader(header);                 {������⢮ ����.�⢥⮢-����訩}
  header.d:=dd;                        {ࠧ㯫�⭥��� ���� header.d}
  Titul:=cmOk;
end;
