procedure TSost.WriteSostInvite;
begin
  if count=0 then invite:='������ '+Sstr(numVopr)+'-� �����' else
  if count=testFile.Hdr^.d+1 then invite:='������ �ࠢ���� �⢥�'
  else invite:='������ '+Sstr(count)+'-� ���ࠢ���� �⢥�';
  WriteInvite;
end;
