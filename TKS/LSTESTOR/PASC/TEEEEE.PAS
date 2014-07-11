Unit TEEEEE;

Interface

Uses menutest;

Type
struct=record
  vopr:array[1..4] of string[78];
  otv:array[1..4,1..4] of string[78];
  ves:word;
       end;

Var
fa:file of struct;
filper:string;

Procedure Dobavl(tes:struct);
Procedure Zap(tes:struct);
Procedure Chten(num:longint;var tes:struct);
Procedure Edit(num:longint;var tes:struct);
Procedure Delvop(num:longint);
Procedure Insvop(tes:struct;num:longint);
Procedure Openfa(filer:string);

Implementation

Uses dos,crt;

Procedure Openfa(filer:string);

Var
pere:byte;
a:men;

Begin
assign(fa,filer);
{$I-}
reset(fa);
{$I+}
if ioresult<>0 then
  Begin
    for pere:=1 to 100 do
      a.vop[pere]:='';
    a.vop[1]:='Создать файл тестов';
    a.vop[2]:='Выйти не создавая';
    a.vop[3]:='NIL';
    menu(a,pere);
    if (pere=0) or (pere=2) then
      halt;
    if pere=2 then
      rewrite(fa);
  end;
end;

Procedure Dobavl(tes:struct);

Begin
seek(fa,filesize(fa));
write(fa,tes);
end;

Procedure Zap(tes:struct);

Begin
write(fa,tes);
end;

Procedure Chten(num:longint;var tes:struct);

Begin
seek(fa,num);
read(fa,tes);
end;

Procedure Edit(num:longint;var tes:struct);

Begin
seek(fa,num);
read(fa,tes);
seek(fa,num);
end;

Procedure Insvop(tes:struct;num:longint);

Var
buf:struct;
a,filsize:longint;

Begin
filsize:=filesize(fa);
if num>=filsize then
  begin
    dobavl(tes);
    exit;
  end;
if num=filsize-1 then
  begin
    Chten(num,buf);
    seek(fa,num);
    zap(tes);
    zap(buf);
    exit;
  end;
chten(num,buf);
seek(fa,num);
zap(tes);
for a:= num+1 to filsize do
  begin
    if a<>filsize then
      chten(a,tes);
    seek(fa,a);
    zap(buf);
    buf:=tes;
  end;
end;

Procedure Delvop(num:longint);

Var
buf:struct;
fi:file of struct;
a,filsize:longint;

Begin
filsize:=filesize(fa);
close(fa);
rename(fa,'temptt');
assign(fa,'temptt');
assign(fi,filper);
reset(fa);
rewrite(fi);
for a:= 0 to filsize-1 do
  begin
    if a<>num then
      begin
        chten(a,buf);
        write(fi,buf);
      end;
  end;
close(fi);
close(fa);
assign(fa,filper);
assign(fi,'temptt');
reset(fa);
erase(fi);
end;
end.

