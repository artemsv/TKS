uses Crt,MyLib,Printer;
var
  filename,st:string;
  ft:text;
  ch:char;
  k,n:word;
begin
  Clrscr;
  Writeln('Введите имя файла для распечатки(без расширения):');
  Readln(filename);
  Assign(ft,filename+'.PAS');
  Reset(ft);
    k:=0;
    while not eof(ft) do
    begin
      Readln(ft,st);
      Inc(k);
    end;
    Close(ft);
    n:=k div 60;                        {сколько целых листов}
    if n in[0,1] then n:=1;
    k:=k mod 60;                        {сколько строк в последнем листе}
    if k<>0 then Inc(n);                {если в последнем что-то есть}
    Writeln;
    Writeln(Sstr(n)+' лист(а,ов)'+',в последнем-'+Sstr(k)+'строк(а)');
    Writeln('Распечатать? (<Esc>-Нет,<Enter>-Да)');
    repeat
      ch:=ReadKey;
    until (ch=#27) or (ch=#13);
    if ch=#27 then Halt;
    Reset(ft);
    while not eof(ft) do
    begin
      Readln(ft,st);
      Writeln(lst,st);
    end;
    Close(ft);
end.
