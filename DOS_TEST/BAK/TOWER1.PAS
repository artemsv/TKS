program Tower1;
uses Crt;

type
  tsm=string[10];

procedure MoveDisk(n:byte;Source,Dest,Tmp:char);
begin
  if n=1 then Writeln('Диск 1 с ',Source,' на ',Dest)
  else
  begin
    movedisk(n-1,Source,Tmp,Dest);
    Writeln('Диск ',n:1,' с ',Source,' на ',Dest);
    MoveDisk(n-1,Tmp,Dest,Source)
  end;
end;

  var n:byte;

  begin
    ClrScr;
    Write('Введите кол-во дисков: ');
    Readln(n);
    MoveDisk(n,'A','B','C')
  end.