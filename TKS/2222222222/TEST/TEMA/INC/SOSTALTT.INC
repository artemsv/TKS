procedure TSost.AltT;
begin
  inherited AltT;
  count:=testFile.Hdr^.d+1;
  CleanInvite;
  invite:='             ��।������ � ������ 0/Ins';
  WriteInvite;
end;
