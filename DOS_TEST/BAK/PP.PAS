uses Crt,MyLib,Printer;
var
  filename,st:string;
  ft:text;
  ch:char;
  k,n:word;
begin
  Clrscr;
  Writeln('����� ���� 䠩���');
  Writeln('������ ��� 䠩�� ��� �ᯥ�⪨(� ���७���):');
  Readln(filename);
  Assign(ft,filename);
  Reset(ft);
    k:=0;
    while not eof(ft) do
    begin
      Readln(ft,st);
      Inc(k);
    end;
    Close(ft);
    n:=k div 60;                        {᪮�쪮 楫�� ���⮢}
    if n in[0,1] then n:=1;
    k:=k mod 60;                        {᪮�쪮 ��ப � ��᫥���� ����}
    if k<>0 then Inc(n);                {�᫨ � ��᫥���� ��-� ����}
    Writeln;
    Writeln(Sstr(n)+' ����(�,��)'+',� ��᫥����-'+Sstr(k)+'��ப(�)');
    Writeln('��ᯥ����? (<Esc>-���,<Enter>-��)');
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
