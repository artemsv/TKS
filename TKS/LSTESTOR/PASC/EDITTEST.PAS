Unit edittest;

Interface

Type
singstr=array[1..78,1..4] of string[1];
strmas=array[1..4] of string[78];

Procedure Razbien(tes:strmas;var tes1:singstr);
Procedure Soedin(tes:singstr;var tes1:strmas);
Procedure Edittext(tes:strmas;var tes1:strmas);

Implementation

Uses dos,crt,ramatest;

Var
x,y,klkod:integer;
kl,klav:string;
sim:string[1];

Procedure Razbien(tes:strmas;var tes1:singstr);

Var
a,b:integer;

Begin
for b:= 1 to 4 do
  begin
    for a:= 1 to 78 do
      begin
        tes1[a,b]:=copy(tes[b],a,1);
      end;
  end;
end;

Procedure Soedin(tes:singstr;var tes1:strmas);

Var
a,b:integer;

Begin
for b:= 1 to 4 do
  begin
    tes1[b]:='';
    for a:= 1 to 78 do
      begin
        tes1[b]:=tes1[b]+tes[a,b];
      end;
  end;
end;

Procedure Edittext(tes:strmas;var tes1:strmas);

Var
tes2:singstr;

Label
back,enda;


Begin
textcolor(15);
rama2;
razbien(tes,tes2);
for x:=1 to 78 do
  begin
    for y:=1 to 4 do
      begin
        gotoxy(x,y);
        write(tes2[x,y]);
      end;
  end;
x:=1;
y:=1;
gotoxy(x,y);
back:
if keypressed=false then
  goto back;
kl:=readkey;
if kl=#8 then
  begin
    goto back;
  end;
if kl=#27 then
  begin
    soedin(tes2,tes1);
    goto enda;
  end;
if kl=#13 then
  begin
    if y=4 then
      goto back;
    y:=y+1;
    x:=1;
    gotoxy(x,y);
  end;
if kl<>#0 then
  begin
    x:=wherex;
    y:=wherey;
    tes2[x,y]:=kl;
    if (x=77) and (y=4) then
      goto back;
    sim:=kl;
    write(kl);
    x:=x+1;
    goto back;
  end;
klkod:=ord(readkey);
if klkod=72 then
  begin
    if y=1 then
      goto back;
    y:=y-1;
    gotoxy(x,y);
  end;
if klkod=80 then
  begin
    if y=4 then
      goto back;
    y:=y+1;
    gotoxy(x,y);
  end;
if klkod=75 then
  begin
    if x=1 then
      goto back;
    x:=x-1;
    gotoxy(x,y);
  end;
if klkod=77 then
  begin
    if x=78 then
      goto back;
    x:=x+1;
    gotoxy(x,y);
  end;
goto back;
enda:
soedin(tes2,tes1);
End;
End.