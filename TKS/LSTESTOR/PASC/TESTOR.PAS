Unit Testor;

Interface

Type
ch5=string[5];

Procedure Openfil(nam:string);
Procedure Inp(x,y:byte;var st:word);
Procedure Redte;
Procedure Rednev;
Procedure Izmves;
Procedure Dobntest;
Procedure Udaltst;

Implementation

uses teeeee,menutest,Edittest,crt,ramatest,password;

var
v:struct;

Procedure Openfil(nam:string);

Begin
filper:=nam;
Assign(fa,filper);
reset(fa);
end;

Procedure Inp(x,y:byte;var st:word);

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

Procedure Redte;

Var
nom1,nom2,per:byte;
piro:struct;
et:strmas;
vp:word;

Begin
clrscr;
gotoxy(22,10);
write('Введите номер редактируемого вопроса');
inp(36,11,vp);
edit(vp,piro);
for per:=1 to 4 do
  et[per]:=piro.vopr[per];
cleaall;
rama1;
gotoxy(25,12);
write(vp,' редактируемый вопрос');
curon;
textcolor(15);
edittext(et,et);
for per:=1 to 4 do
  piro.vopr[per]:=et[per];
zap(piro);
curoff;
cleaall;
rama1;
end;

Procedure Rednev;

Label
back;

Var
per:byte;
vp,vpn:word;
piro:struct;
et:strmas;

Begin
clrscr;
gotoxy(22,10);
write('Введите номер редактируемого вопроса');
inp(36,11,vp);
gotoxy(17,12);
write('Введите номер неверного ответа(4-верный ответ)');
back:
inp(36,13,vpn);
if vpn<=0 then
  goto back;
edit(vp,piro);
for per:=1 to 4 do
  et[per]:=piro.otv[vpn,per];
cleaall;
rama1;
gotoxy(25,12);
write(vp,' редактируемый вопрос');
gotoxy(25,13);
write(vpn,' редактируемый ответ');
curon;
textcolor(15);
edittext(et,et);
for per:=1 to 4 do
  piro.otv[vpn,per]:=et[per];
zap(piro);
curoff;
cleaall;
rama1;
end;

Procedure Izmves;

Var
ves:word;
piro:struct;

Begin
clrscr;
gotoxy(22,10);
write('Введите номер редактируемого вопроса');
inp(36,11,ves);
edit(ves,piro);
cleaall;
rama1;
gotoxy(30,10);
write('Введите новый вес');
inp(36,11,ves);
zap(piro);
end;

Procedure Dobntest;

Label
back;

Var
a:men;
et:strmas;
piro:struct;
per,per1,res:byte;
per3:word;

Begin
cleaall;
rama1;
for per:=1 to 4 do
  et[per]:='';
curon;
gotoxy(22,10);
write('Редактируется вопрос');
textcolor(15);
edittext(et,et);
for per:=1 to 4 do
  piro.vopr[per]:=et[per];
for per1:=1 to 4 do
  begin
    for per:=1 to 4 do
      et[per]:='';
    cleaall;
    rama1;
    gotoxy(22,10);
    write('Редактируется ответ');
    gotoxy(28,11);
    if per1=4 then
      write('верный') else
      write('неверный ');
    textcolor(15);
    edittext(et,et);
    for per:=1 to 4 do
      piro.otv[per1,per]:=et[per];
  end;
cleaall;
rama1;
a.vop[1]:='Добавить вопрос в конец';
a.vop[2]:='Вставить вопрос';
a.vop[3]:='NIL';
menu(a,res);
cleaall;
rama1;
if res=0 then
  exit;
if res=1 then
  dobavl(piro);
if res=2 then
  begin
  gotoxy(18,10);
  write('Введите на каком месте должен стоять вопрос (0-',filesize(fa),')');
back:
  inp(32,11,per3);
  if (per3<0) or (per3>filesize(fa)) then
    goto back;
  insvop(piro,per3);
  end;
curoff;
cleaall;
rama1;
end;

Procedure Udaltst;

Var
Per:word;

Begin
cleaall;
rama1;
gotoxy(24,10);
write('Введите номер удаляемого теста');
inp(36,11,per);
if per=65535 then
  exit;
delvop(per);
cleaall;
rama1;
end;
end.