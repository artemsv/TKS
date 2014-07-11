procedure TSost.WriteSostInvite;
begin
  if count=0 then invite:='Введите '+Sstr(numVopr)+'-й вопрос' else
  if count=testFile.Hdr^.d+1 then invite:='Введите правильный ответ'
  else invite:='Введите '+Sstr(count)+'-й неправильный ответ';
  WriteInvite;
end;
