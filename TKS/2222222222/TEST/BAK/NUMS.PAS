program Nums;

uses Crt;

const
  constStr:array[0..19]of char=('0','1','2','3','4','5','6','7','8','9','A',
             'B','C','D','E','F','G','H','I','J');

function Power(digit,n:integer):longint;
var k:byte;z:integer;
begin
  z:=digit;
  if n=0 then Power:=1 else
  begin
    for k:=1 to n-1 do z:=z*digit;
    Power:=z;
  end;
end;

function Sstr(n:integer):string;
var st:string;
begin
  Str(n,st);
  Sstr:=st;
end;

function Ves(ch:char):byte;
var k:byte;
begin
  for k:=0 to 19 do
  if constStr[k]=ch then begin Ves:=k;Exit;end;
end;

var
  mNums:array[0..30] of char;
  a,b,sum,old,res:word;
  st1,st2:string; k,i:byte;

begin
repeat
  ClrScr;
  Write('Введите исходную систему счисления: ');Readln(old);
  if old=0 then halt;
  repeat
    Write('Введите число: ');
    Readln(st1);
{    for k:=0 to old do for i:=1 to Length(st1) do
      if Vval(st1[i])>Vval(constStr[k]) then Halt;}
    if st1='' then Halt else Break
  until false;
  Write('Введите новую систему счисления: ');Readln(res);
  for k:=0 to 30 do mNums[k]:=UpCase(st1[length(st1)-k]);
  sum:=0;
  if old<>10 then
    for k:=0 to length(st1)-1 do sum:=sum+Ves(mNums[k])*Power(old,k)
   else Val(st1,sum,a);
  st2:='';
  repeat
    a:=sum div res; b:=sum mod res;
    st2:=constStr[b]+st2;
    sum:=a
  until sum=0;
  Writeln;
  Writeln('Число '+st1+' в '+Sstr(old)+' - ичной системе равно числу '+st2+
    ' в '+Sstr(res)+'-ичной системе ');
  Readkey;
until false
end.
