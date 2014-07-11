procedure TEdit1.Plus;
begin
  if x<endX then Inc(x) else if y<y2 then
  begin
    Inc(y);x:=oldX
  end;
end;

function TEdit1.Minus:boolean;
begin
  Minus:=false;
  if (x=oldX) and (y=oldY) then Exit;
  if x>oldX then dec(x) else
  begin
    x:=endX;
    Dec(y);
  end;
  Minus:=true;
end;

procedure TEdit1.Up;
begin
  if y>0 then Dec(y)
end;

procedure TEDit1.Down;
begin
  if y < y2 then Inc(y);
end;

