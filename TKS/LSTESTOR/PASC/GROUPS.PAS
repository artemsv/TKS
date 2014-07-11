Unit Groups;

Interface

Uses dos,crt,func3men,menutest,ramatest;

Var
alfa:integer;
fogr:boolean;
fgt:file of gr;
MGR,MFIO:string;

Procedure Opengr;
Procedure Editgroups;
Procedure Udalgroups;
Procedure Choisegroups;

Implementation

Procedure Opengr;

Var
a:men;
res:byte;
filogr:string;

Begin
fogr:=false;
filogr:= conf.fileofgroup;
assign(fg,filogr);
{$i-}
reset(fg);
{$I+}
if ioresult<>0 then
  begin
    a.vop[1]:='Создать файл базы данных';
    a.vop[2]:='Выйти не создавая';
    a.vop[3]:='NIL';
    menu(a,res);
    if (res=2) or (res=0) then
      exit;
    if res=1 then
      begin
        rewrite(fg);
      end;
  end;
fogr:=true;
end;


Procedure Editgroups;

Var
b:gr;
a:men;
res:byte;

Begin
if fogr=false then
  exit;
cleaall;
rama1;
gotoxy(5,10);
write('Введите ФИО учащегося: ');
readln(fio);
gotoxy(5,12);
write('Введите группу учащегося: ');
readln(group);
a.vop[1]:='Занести фамилию в список';
a.vop[2]:='Выйти без записи';
a.vop[3]:='NIL';
menu(a,res);
if (res=2) or (res=0) then
  exit;
if res=1 then
  begin
  b.group:=group;
  b.fio:=fio;
  seek(fg,filesize(fg));
  write(fg,b);
  end;
End;

Procedure Udalgroups;

Label
back;

Var
res:byte;
findf:boolean;
Sizefi:longint;
per,per1,per4,per6:word;
per3:gr;
per5,vgr,vfio:string;
a,b:men;
sost:array[1..100] of integer;

Begin
for per:=1 to 100 do
  begin
    a.vop[per]:='';
    sost[per]:=0;
  end;
cleaall;
rama1;
per4:=1;
if filesize(fg)<1 then
  exit;
close(fg);
reset(fg);
read(fg,per3);
a.vop[1]:=per3.group;
if filesize(fg)=1 then
  goto back;
for per:=2 to filesize(fg) do
  begin
    read(fg,per3);
    findf:=false;
    for per1:=1 to per4 do
      begin
        if per4>99 then
          exit;
        if a.vop[per1]=per3.group then
          findf:=true;
      end;
    if findf=false then
      begin
        per4:=per4+1;
        a.vop[per4]:=per3.group;
      end;
  end;
back:
a.vop[per4+1]:='NIL';
menu(a,res);
if res=0 then
  exit;
vgr:=a.vop[res];
cleaall;
rama1;
per4:=0;
seek(fg,0);
for per:=1 to 100 do
  begin
    a.vop[per]:='';
    sost[per]:=0;
  end;
for per:=1 to filesize(fg) do
  begin
    read(fg,per3);
    if per3.group=vgr then
      begin
        if per4>99 then
          exit;
        per4:=per4+1;
        a.vop[per4]:=per3.fio;
        sost[per4]:=per;
      end;
  end;
a.vop[per4+1]:='NIL';
menu(a,res);
if res=0 then
  exit;
sizefi:=filesize(fg);
close(fg);
rename(fg,'temptt');
assign(fg,'temptt');
assign(fgt,conf.fileofgroup);
reset(fg);
rewrite(fgt);
cleaall;
rama1;
for per1:= 0 to sizefi-1 do
  begin
    if per1<>sost[res]-1 then
      begin
        seek(fg,per1);
        read(fg,per3);
        write(fgt,per3);
      end;
  end;
close(fgt);
close(fg);
assign(fg,conf.fileofgroup);
assign(fgt,'temptt');
reset(fg);
erase(fgt);
end;

Procedure Choisegroups;

Label
back;

Var
res:byte;
findf:boolean;
Sizefi:longint;
per,per1,per4,per6:word;
per3:gr;
per5,vgr,vfio:string;
a,b:men;
sost:array[1..100] of integer;

Begin
for per:=1 to 100 do
  begin
    a.vop[per]:='';
    sost[per]:=0;
  end;
cleaall;
rama1;
per4:=1;
seek(fg,0);
if filesize(fg)<1 then
  exit;
read(fg,per3);
a.vop[1]:=per3.group;
if filesize(fg)=1 then
  goto back;
for per:=2 to filesize(fg) do
  begin
    read(fg,per3);
    findf:=false;
    for per1:=1 to per4 do
      begin
        if per4>99 then
          exit;
        if a.vop[per1]=per3.group then
          findf:=true;
      end;
    if findf=false then
      begin
        per4:=per4+1;
        a.vop[per4]:=per3.group;
      end;
  end;
back:
a.vop[per4+1]:='NIL';
menu(a,res);
if res=0 then
  exit;
MGR:=a.vop[res];
cleaall;
rama1;
per4:=0;
seek(fg,0);
for per:=1 to 100 do
  begin
    a.vop[per]:='';
    sost[per]:=0;
  end;
for per:=1 to filesize(fg) do
  begin
    read(fg,per3);
    if per3.group=MGR then
      begin
        if per4>99 then
          exit;
        per4:=per4+1;
        a.vop[per4]:=per3.fio;
        sost[per4]:=per;
      end;
  end;
a.vop[per4+1]:='NIL';
menu(a,res);
if res=0 then
  exit;
MFIO:=a.vop[res];
End;
End.


















