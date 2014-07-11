program kod;
var
  k:byte;
  fd,fw,old,out:file of char;
  ch:char;
  st,name:string;
  dos,win:array[1..66] of char;
  d,w:set of char;
type
  rec=record
    r:char;
    w:char
  end;
  tmas=array[1..66] of rec;
var
  mas:tmas;
begin
  Writeln('Конвертер DOS в WIN');
  Assign(fw,'c:\windows\command\win_kod.dat');
  Reset(fw);
  Assign(fd,'dos_kod.dat');
  Reset(fd);
  for k:=1 to 66 do
  begin
    Read(fw,mas[k].w);Include(w,mas[k].w);
    Read(fd,mas[k].r);Include(d,mas[k].r);
  end;
{  for k:=1 to 66 do Read(fd,dos[k]);
  for k:=1 to 66 do Read(fw,win[k]);}
  Close(fw);
  Close(fd);
  Writeln('Введите имя преобразуемого файла');
  Readln(name);
  Assign(old,name);
  Reset(old);
  st:='~'+Copy(name,2,Length(name)-1);
  Assign(out,st);
  Rewrite(out);
  while not eof(old) do
  begin
    Read(old,ch);
    if ch in w then
      for k:=1 to 66 do if ch=mas[k].w then begin ch:=mas[k].r;Break end;
    Write(out,ch);
  end;
end.
