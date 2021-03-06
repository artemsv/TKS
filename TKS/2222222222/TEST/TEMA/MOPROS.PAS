Unit MOpros;                 {��� ᮧ����� ��砫쭮� ���ᨨ:       25.10.01}
                             {��� ᮧ����� �����⥫쭮�  ���ᨨ:  15.11.01}
interface

uses Crt,Dos,Drivers,Views,Types,Objects,MyLib,MsgBoxMy,MyFunc,Indicatr,
     MEdit3,Strings,Stream;

var
  colVopr,tim,total:integer;
  date:st8;
  gruppa:string;

type
  RTem=record
    t:st12;
    n:byte;
  end;

  RInfo=record
    date:st8;
    gr:st8;
    kGr:byte;
    fnt:st12;
    kolTem:byte;
    tems:array[1..10] of RTem;
    total:integer;
    tim:integer;
    j5,j4,j3:byte;
  end;


type
  TOpr=object(TEdit3)
    right:byte;                         {�ࠢ���� �⢥� ⥪�饣� �����}
    numVar:integer;
    IndVopr,IndVar:PIndicator;
    procedure IntermixLines;
  end;

procedure Inp(var info:RInfo);

implementation


procedure TOpr.Intermixlines;
var
  mas:array[0..10]of integer;
  position,k,j,atribut:word;
  ch:char;
  BL:PBlock;
begin
  CleanChars;
  lines:=PBlock(cBlocks^.At(numVopr))^.block;
  Duplet(testFile.Hdr^.d+1,testFile.Hdr^.d+1,mas);
  for k:=1 to testFile.Hdr^.d+1 do
    if mas[k]=testFile.Hdr^.d+1 then right:=k;
  x:=0;y:=1;ch:=lines[0];k:=1;
  repeat
    chars[y,x]:=sym+byte(ch);
    ch:=lines[k];
    Inc(k);
    Inc(x);
    if x>xE then begin Inc(y);x:=0;end;
  until (ch=#221) or (ch=#219);Draw;
  position:=k-2;                      {������ ���� ᠬ��� ����� � lines}
  if x>0 then begin Inc(y);x:=0;end;
  for k:=0 to x2 do chars[y,k]:=syl+196;     {ࠧ����⥫쭠� ���}
  for k:=1 to testFile.Hdr^.d+1 do                  {横� �� �ᥬ �⢥⠬}
    begin
      j:=position;                           {��⠭���.��砫� ���᪠ � lines}
      repeat                                 {���� ��砫� �⢥�}
        Inc(j);
        ch:=lines[j];
        if ch=#219 then begin Draw;Break;end;
        if ch=#221 then
           if Ord(lines[j+1])-48=Ord(char(mas[k])) then Break;
      until lines[j]=#219;
      x:=2;Inc(y);Inc(j,3);
      chars[y,0]:=syn+k+48;chars[y,1]:=syn+46;Draw;
      repeat
        if x<oldX then atribut:=syn else atribut:=sym;
        ch:=lines[j];
        if ch=#221 then Break;
        if ch<>#219 then chars[y,x]:=atribut+byte(ch);
        Inc(j);Inc(x);
        if x>xE then
        begin
          Inc(y);
          if y=y2+1 then Exit;x:=0;
        end;
      until (ch=#221) or (ch=#219);
      Draw;
    end;
end;

procedure WriteInfo(info:RInfo);
var
  f:text;
  k:byte;
begin
  Assign(f,'info.dat');
  {$I-}
  Rewrite(f);
  if IOresult<>0 then begin
    MessageBox(#3'�訡�� �� ᮧ����� 䠩�� INFO.DAT !',nil,mfOkButton);
    Halt;
  end;
  Writeln(f,info.date);
  Writeln(f,info.gr);
  Writeln(f,info.kGr);
  Writeln(f,info.fnt);
  Writeln(f,info.kolTem);
  for k:=1 to info.kolTem do
  begin
    Writeln(f,info.tems[k].t);
    Writeln(f,info.tems[k].n);
  end;
  Writeln(f,info.total);
  Writeln(f,info.tim);
  Writeln(f,info.j5);
  Writeln(f,info.j4);
  Writeln(f,info.j3);
  if IOresult<>0 then begin
    MessageBox(#3'�訡�� �� ����� 䠩�� INFO.DAT !',nil,mfOkButton);
    Halt;
  end;
  {$I+}
  Close(f);
end;



procedure Inp;
var
  a:word;
  fst:text;
  kodGr:integer;
  AFn:pathStr;
  st,sa:string;
  cCol:PCollection;
  SR:SearchRec;
  k:integer;
begin
  if not Verify('info.opr',GetCurDir) then
    begin
      cCol:=New(PCollection,Init(20,1));
      Assign(fst,'gruppa.dat');
      {$I-}
      Reset(fst);
      if IOResult<>0 then MsgHalt('���� gruppa.dat �� ������!');
      while not Eof(fst) do
      begin
        Readln(fst,st);
        Readln(fst,sa);
        cCol^.Insert(NewStr(st));
      end;
      Close(fst);
      if ListDialog(cCol,'�롥�� ��㯯�',gruppa,kodGr,0)=cmCancel then Halt;
      Inc(kodGr);                     {㢥��稢���,�.�. � ListDialog � ���}
      st:='';
      date:=EnterDate;
      if date='' then Halt;
      cCol^.DeleteAll;
      Dos.FindFirst('D:\TEST\TEMA\FONT\*.fnt',AnyFile,SR);
      while DosError=0 do
      begin
        cCol^.Insert(NewStr(SR.name));
        FindNext(SR);
      end;
      if cCol^.count=0 then begin
        Messagebox(#3'����� ���⮢ �� �������!'+#13+#13+
          #3'�� 㬮�砭��-standart.fnt',nil,mfOkButton);st:='standart.fnt'
      end else
      if ListDialog(cCol,'�롥�� 䠩� ���⮢',st,k,0)=cmCancel then Halt;
      info.fnt:=st;
      if MessageBox(#3'���� ������� �⠭�����?',nil,mfYesNoCancel)=cmYes
      then begin
        SelectTem(AFn);
        info.tems[1].t:=AFn;
        info.tems[1].n:=10;
        info.date:=date;
        info.gr:=gruppa;
        info.kGr:=kodGr;
        info.kolTem:=1;
        info.total:=100;
        info.tim:=120;
        info.j5:=80;
        info.j4:=70;
        info.j3:=50;
        WriteInfo(info);
        Exit;
      end;
      MessageBox(#3'�६���� ����饭�!!!',nil,mfOkButton);
      Halt;
      InputInt(1,100,'������⢮ ������,�⢮��饥�� �� ��� ����?',total,0);
      InputInt(1,600,'�६� � ᥪ㭤�� �� ���� �����',tim,0);
      InputInt(1,255,'������⢮ ����ᮢ',colVopr,0);
    end                                         {info.dat ���������}
  else
{  ReadInfo(info);}
end;
end.