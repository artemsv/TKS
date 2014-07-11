procedure TEdit1.CtrlLeft;
var
  z:byte;
begin
 if x<oldX then Exit;
 if Lo(chars[y,x])<>32 then Dec(x);
 z:=x;
 while Lo(chars[y,x])=32 do
   if x>oldX then Dec(x)
             else Break;
   if x=oldX then x:=z;
 while Lo(chars[y,x])<>32 do
   if x>oldX then Dec(x) else Break;
   if x>oldX then Inc(x);
end;

procedure TEdit1.CtrlRight;
var
  z:byte;
begin
  if x>=endX then Exit;
  if Lo(chars[y,x])<>32 then
  while (Lo(chars[y,x])<>32) do
    begin
      Inc(x);
      if x=endX then Break;
    end;
    z:=x;
  while Lo(chars[y,x])=32 do
   if x<endX then Inc(x) else Break;
   if x=endX then x:=z;
end;
