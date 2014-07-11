uses Crt,myCol,MyLib,Objects;
var
  col:PMyCicleCollection;
  k,i:byte;
  p:PString;
  st:string;
begin
  ClrScr;
  col:=New(PMyCicleCollection,Init(10,1));
  for K:=1 to 10 do
  begin
    st:=sstr(k);
    col^.Insert(NewStr(st));
  end;
  for k:=1 to 5 do begin
    p:=Pstring(col^.GetPrev);
    if p<>nil then Writeln(p^);
  end;
  for k:=1 to 5 do begin
    p:=Pstring(col^.GetNext);
    if p<>nil then Writeln(p^);
  end;

end.