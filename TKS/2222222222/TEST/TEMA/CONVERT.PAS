uses
  MyFunc,Stream,Strings,Types,New1,Objects;
var
  mChar:tm1;
  TT:TTestFile;
  h:THeader;
  Hd:Phdr;
  tem,ff:array[0..23] of char;
  pch:Pchar;
  Bl:PBlock;
  f:tfc;
  s:PStream;
  st,st1:string;
  n,k:integer;
  ch:char;
  index:PIndex;
begin
  Writeln('Введите имя исходного файла');
  Readln(st1);
  h.fName:=st1;
  if not ReadHeader(h) then Halt;
  StrPCopy(tem,h.tema);
  pch:='Asd';
  Writeln('Введите имя нового файла');
  Readln(st);
  StrPCopy(ff,st);
  Hd:=New(PHdr,Init(h.nn,h.ckolko,h.kTem,h.d,tem,ff,pch));
  TT.Init(st,stCreate,Hd);

  Assign(f,st1);
  Reset(f);
  ch:=#32;
  for k:=0 to 500 do mChar[k]:=#32;
  while ch<>#219 do Read(f,ch);
  n:=0;
  while not Eof(f) do
  begin
    k:=0;
    Inc(n);
    while not Eof(f) do
    begin
      Read(f,ch);
      mChar[k]:=ch;
      if mChar[k]=#219 then Break;
      Inc(k);
    end;
    mChar[k+1]:=#0;
    for k:=0 to 500 do begin mChar[k]:=mChar[k+4];if mChar[k]=#0 then Break;end;
    BL:=New(PBlock,Init(n,StrNew(mChar)));
    TT.PutBlock(BL);
    Dispose(Bl);
  end;
  TT.Done;
  Close(f);
end.