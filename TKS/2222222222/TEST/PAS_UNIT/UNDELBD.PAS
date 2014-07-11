program UnDelBd;
uses types;
var f,d:tfr;
k:word;
bd:resultdata;
begin
  assign(f,'bd.dat');
  reset(f);
  while not eof(f) do
    begin
      Read(f,bd);
      bd.flag:=221;
      Seek(f,FilePos(f)-1);
      write(f,bd);
    end;
  close(f);
end.

