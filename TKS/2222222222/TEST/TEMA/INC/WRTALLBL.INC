procedure TEditor.WriteAllBlocks(n:integer;p:pointer);
var
  k,e:integer;
begin
  for k:=n to cBlocks^.count-1 do
  begin
    lines:=cBlocks^.At(k);
    WriteBlock(p);
  end;
  CleanChars;                                      {?????????????????}
end;
