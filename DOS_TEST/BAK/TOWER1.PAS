program Tower1;
uses Crt;

type
  tsm=string[10];

procedure MoveDisk(n:byte;Source,Dest,Tmp:char);
begin
  if n=1 then Writeln('��� 1 � ',Source,' �� ',Dest)
  else
  begin
    movedisk(n-1,Source,Tmp,Dest);
    Writeln('��� ',n:1,' � ',Source,' �� ',Dest);
    MoveDisk(n-1,Tmp,Dest,Source)
  end;
end;

  var n:byte;

  begin
    ClrScr;
    Write('������ ���-�� ��᪮�: ');
    Readln(n);
    MoveDisk(n,'A','B','C')
  end.