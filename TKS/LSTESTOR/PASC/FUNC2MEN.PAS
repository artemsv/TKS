Unit func2men;

Interface

Procedure Openfil(nam:string);
Procedure Inp(x,y:byte;var st:word);
Procedure Redte;
Procedure Rednev;
Procedure Izmves;
Procedure Dobntest;
Procedure Udaltst;

Implementation

Uses teeeee,menutest,edittest,crt,ramatest,password,func3men;

Type
ch5=string[5];

var
v:struct;

Procedure Openfil(nam:string);

Var
a:men;
per:byte;

Begin
filper:=nam;
Assign(fa,filper);
{$i-}
reset(fa);
{$i+}
if ioresult=0 then
  exit;
cleaall;
rama1;
gotoxy(30,1);
write('Файл ',filper,' не существует создать?');
window(2,3,78,24);
a.vop[1]:='Да';
a.vop[2]:='Нет';
a.vop[3]:='NIL';
menu(a,per);
if (per=2) or (per=0) then
  exit;
if per=1 then
  Begin
    if filper='' then
      begin
        cleaall;
        rama1;
        gotoxy(30,10);
        write('Введите имя файла');
        gotoxy(35,11);
        readln(conf.fileoftest);
        saver;
      end;
    rewrite(fa);
  end;
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
curon;
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
    curon;
    write(c);
    s:=s+c;
  end;
  forw:
  val(s,st,code);
end;

Procedure Redte;

Label
back;

Var
nom1,nom2,per:byte;
piro:struct;
et:strmas;
vp:word;

Begin
curon;
cleaall;
rama1;
clrscr;
curon;
gotoxy(22,10);
write('Введите номер редактируемого вопроса');
back:
inp(36,11,vp);
if vp>filesize(fa)-1 then
  goto back;
edit(vp,piro);
for per:=1 to 4 do
  et[per]:=piro.vopr[per];
cleaall;
rama1;
gotoxy(25,12);
write(vp,' редактируемый вопрос');
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
back,back1;

Var
per:byte;
vp,vpn:word;
piro:struct;
et:strmas;


Begin
cleaall;
rama1;
curon;
clrscr;
gotoxy(22,10);
write('Введите номер редактируемого вопроса');
goto back1;
back1:
inp(36,11,vp);
if vp>filesize(fa)-1 then
  goto back1;
gotoxy(17,12);
write('Введите номер неверного ответа(4-верный ответ)');
back:
inp(36,13,vpn);
if vpn=0 then
  exit;
if vpn>4 then
  goto back;
curoff;
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

Label
back;

Var
ves:word;
piro:struct;
vp:word;

Begin
cleaall;
rama1;
curon;
clrscr;
gotoxy(22,10);
write('Введите номер редактируемого вопроса');
back:
inp(36,11,vp);
if vp=999 then
  exit;
if vp>filesize(fa)-1 then
  goto back;
edit(vp,piro);
cleaall;
rama1;
gotoxy(30,9);
write('Текущий вес:',piro.ves);
gotoxy(30,10);
write('Введите новый вес');
inp(36,11,ves);
curoff;
if ves=999 then
  exit;
piro.ves:=ves;
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
clrscr;
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
    curon;
    edittext(et,et);
    for per:=1 to 4 do
      piro.otv[per1,per]:=et[per];
  end;
curoff;
cleaall;
rama1;
piro.ves:=0;
a.vop[1]:='Добавить вопрос в конец';
a.vop[2]:='Вставить вопрос';
a.vop[3]:='Выйти не сохраняя';
a.vop[4]:='NIL';
menu(a,res);
cleaall;
rama1;
if (res=0) or (res=3) then
  exit;
if res=1 then
  dobavl(piro);
if res=2 then
  begin
  curon;
  clrscr;
  gotoxy(18,10);
  write('Введите на каком месте должен стоять вопрос (0-',filesize(fa),')');
back:
  inp(32,11,per3);
  if per3>filesize(fa) then
    goto back;
  Insvop(piro,per3);
  end;
curoff;
cleaall;
rama1;
end;

Procedure Udaltst;

Label
back;

Var
Per:word;
vp:word;

Begin
cleaall;
rama1;
curon;
clrscr;
gotoxy(24,10);
write('Введите номер удаляемого теста');
back:
inp(36,11,vp);
if vp=999 then
  exit;
if vp>filesize(fa)-1 then
  goto back;
delvop(vp);
curoff;
cleaall;
rama1;
end;
end.