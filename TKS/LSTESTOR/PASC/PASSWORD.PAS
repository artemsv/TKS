Unit Password;

Interface

Uses dos,crt;

Type
ch5=string[5];

Const
lu=#201;
ld=#200;
ru=#187;
rd=#188;
h=#205;
v=#186;

Var
Pas:ch5;

Procedure Pass(var pas:ch5);
Procedure Curon;
Procedure Curoff;

Implementation

Procedure Pass(var pas:ch5);

Label
back;

Var
a,x,y,c:byte;
ch:string;

Begin
x:=25;
y:=10;
c:=0;
clrscr;
gotoxy(x,10);
write(lu);
for a:= 1 to 20 do
  write(h);
write(ru);
gotoxy(x,y+1);
write(v);
write('   Введите пароль!');
write('  ',v);
gotoxy(x,y+2);
write(v,'                    ',v);
gotoxy(x,y+3);
write(ld);
for a:= 1 to 20 do
  write(h);
write(rd);
back:
if keypressed=false then
  goto back;
c:=c+1;
gotoxy(x+c+7,y+2);
write('*');
ch:=readkey;
pas:=pas+ch;
if c<>5 then
  goto back;
end;

Procedure Curoff;

Begin
Asm
mov ah,1
mov ch,0
mov cl,0
int 10h
end;
end;

Procedure Curon;

Begin
Asm
mov ah,1
mov ch,6
mov cl,7
int 10h
end;
end;
















end.


