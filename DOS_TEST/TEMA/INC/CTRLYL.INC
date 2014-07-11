procedure TEDit1.CtrlL;
var   k:byte;
begin
  if y=y2 then Exit;
  SaveOld;
  for k:=y2 downto y do chars[k]:=chars[k-1];
  for k:=oldX to x2 do chars[y,k]:=sym32;
end;

procedure TEdit1.CtrlY;
var   k:byte;
begin
  SaveOld;
  for k:=y to y2-1 do chars[k]:=chars[k+1];
  for k:=0 to x2 do chars[y2,k]:=sym32
end;

procedure TEdit1.CtrlT;
begin
  if Lo(chars[y,x])<>32 then
  while Lo(chars[y,x])<>32 do
    ShiftChars(endX,x)
  else if not EmptyLine(y,x) then
  while Lo(chars[y,x])=32 do
    ShiftChars(endX,x)
end;
