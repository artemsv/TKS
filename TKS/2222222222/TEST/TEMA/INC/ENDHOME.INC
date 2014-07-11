procedure TEdit1.GoEnd;
begin
  x:=LastPosition(x2);
  if (x<endX) and ((x<>oldX) or ((x=oldX) and ((Lo(chars[y,x])<>32))))
     then Inc(x)
end;

procedure TEdit1.Home;
begin
  x:=oldX
end;
