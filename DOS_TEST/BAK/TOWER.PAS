uses Crt;

type
  tsm=string[10];

var
  sm:array[1..3] of tsm;


procedure Draw;
var
  i,k,len:byte;
  code:integer;
begin
  for i:=1 to 3 do
    for k:=20 downto 20-Length(sm[i]) do
    begin
      Val(sm[i][21-k],len,code);
      GotoXY(7*i+len,k);
      TextColor(len);
      for code:=1 to 2*len+3 do Write(#219)
    end;
end;

begin
   clrScr;
   sm[1]:='321';
   sm[2]:='87654321';
   sm[3]:='654321';
   Draw;
end.