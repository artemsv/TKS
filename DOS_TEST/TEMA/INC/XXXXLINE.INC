
function TEdit1.EmptyLine(a,b:byte):boolean;
var k:byte;
begin
  EmptyLine:=true;                      {���砫�-�����}
  for k:=b to endX do
    if Lo(chars[a,k])<>32 then
    begin
      EmptyLine:=false;
      Exit
    end;
end;

procedure TEdit1.CleanLine(b:byte);
var
  k:byte;
begin
  for k:=oldX to endX do chars[b,k]:=Hi(chars[b,k])+32
end;
