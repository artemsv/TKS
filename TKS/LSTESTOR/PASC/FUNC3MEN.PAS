Unit Func3men;

Interface

uses dos,crt,ramatest,menutest,password;

Type
cfg=record
  password:string[5];
  oc:array [3..5] of word;
  timer:word;
  fileoftest:string;
  fileofotch:string;
  fileofgroup:string;
    end;
gr=record
  Fio:string[30];
  Group:string[10];
   end;

Var
filconf,filgroup:string;
fg:file of gr;
pas:ch5;
stav:array [3..5] of word;
tim:word;
fot,foo,gro:string;
Group:string[10];
Fio:string[30];
conf:cfg;
fc:file of cfg;

Procedure Inp1(x,y:byte;var st:word);
Procedure Grf;
Procedure Izmpass;
Procedure Izmstav;
Procedure Izmtim;
Procedure Izmfot;
Procedure Izmfoo;
Procedure Izmgroup;
Procedure Saver;

Implementation

Procedure Inp1(x,y:byte;var st:word);

Var
a:byte;
c,s:string;
code:integer;

Label
Back,forw;

Begin
s:='';
gotoxy(x,y);
For a:= 1 to 3 do
  begin
    back:
    if keypressed=false then
      goto back;
    c:=readkey;
    if c=#27 then
      begin
        st:=65535;
        exit;
      end;
    if c=#13 then
      goto forw;
    val(c,st,code);
    if code<>0 then
      goto back;
    write(c);
    s:=s+c;
  end;
  forw:
  val(s,st,code);
end;

Procedure Grf;

Begin
assign(fc,'testls.cfg');
reset(fc);
if ioresult<>0 then
  begin
    write('ошибка при откпытии файла конфигурации');
    halt;
  end;
read(fc,conf);
end;

Procedure Izmpass;

Begin
cleaall;
rama1;
pass(pas);
conf.password:=pas;
end;

Procedure Izmstav;

Var
per:byte;

Begin
cleaall;
rama1;
curon;
clrscr;
for per := 3 to 5 do
  begin
    gotoxy(5,8+per-2);
    write('Введите ставку на ',per,':');
    inp1(5,29,stav[per]);
    conf.oc[per]:=stav[per];
  end;
curoff;
end;

Procedure Izmtim;

Begin
cleaall;
rama1;
curon;
clrscr;
gotoxy(5,10);
write('Введите новые параметры таймера:');
inp1(5,42,tim);
curoff;
conf.timer:=tim
end;

Procedure Izmfot;

Begin
cleaall;
rama1;
curon;
clrscr;
gotoxy(5,10);
write('Введите имя файла:');
gotoxy(5,24);
read(fot);
conf.fileoftest:=fot;
end;

Procedure Izmfoo;

Begin
cleaall;
rama1;
curon;
clrscr;
gotoxy(5,10);
write('Введите имя файла:');
gotoxy(5,24);
readln(foo);
conf.fileofotch:=foo;
end;

Procedure Izmgroup;

Begin
cleaall;
rama1;
curon;
clrscr;
gotoxy(5,10);
write('Введите имя файла:');
gotoxy(5,24);
read(gro);
conf.fileofgroup:=gro;
end;

Procedure Saver;

Begin
seek(fc,0);
write(fc,conf);
close(fc);
reset(fc);
read(fc,conf);
end;
end.





