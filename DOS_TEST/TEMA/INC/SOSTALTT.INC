procedure TSost.AltT;
begin
  inherited AltT;
  count:=testFile.Hdr^.d+1;
  CleanInvite;
  invite:='             Отредактируете и нажмите 0/Ins';
  WriteInvite;
end;
