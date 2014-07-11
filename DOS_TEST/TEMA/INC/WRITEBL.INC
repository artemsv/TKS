procedure TEditor.WriteBlock;
var
  k:integer;
begin
  k:=0;
  repeat
    Write(tfc(p^),lines[k]);
    Inc(k)
  until lines[k-1]='Û';
end;
