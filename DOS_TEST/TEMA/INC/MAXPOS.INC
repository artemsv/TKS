function TEdit1.MaxPosition(n:byte):boolean;
var
  i,j:byte;
begin
  MaxPosition:=false;
  for i:=n downto oldY do
  begin
    for j:=x2 downto 0 do
    begin
      if char(Lo(chars[i,j]))<>#32 then   {если нашли значимый символ}
      begin
        maxX:=j+1;
        maxY:=i;
        if not ((maxY=oldY) and (maxX=oldX)) then MaxPosition:=true;
        Exit;
      end;
    end;
  end;
end;
