function TEdit1.LastPosition(start:byte):byte;  {возвращает макс.поз.в строке}
var
  k:byte;
begin
  LastPosition:=oldX;
  for k:=start downto oldX do
    if Lo(chars[y,k])<>32 then
    begin
      LastPosition:=k;
      Exit;
    end;
end;

function TEdit1.FindFirst(start:byte):byte;
var  
  k:byte;
begin
  FindFirst:=start;
  if Lo(chars[y,start])<>32 then Exit;
  for k:=start to endX do
    if Lo(chars[y,k])<>32 then
    begin
      FindFirst:=k;
      Exit;
    end;
end;
