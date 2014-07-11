unit Menutest;

Interface

uses dos,crt;

Type
men=record
  vop:array[1..100] of string[60];
    end;

Var
te:string[60];

Procedure Menu(m:men;var res:byte);

Implementation

Procedure Menu(m:men;var res:byte);

Var
a,z,k,n,b,c,c1,x,x1,y,y1,ce,cm,position,position1,kod,position3:integer;
sim:char;

Label
Back,start,enter;

Begin
c1:=0;
textbackground(7);
clrscr;
textcolor(0);
for a:= 1 to 100 do
  begin
    if m.vop[a]='NIL' then
      begin
        b:=a-1;
      end;
  end;
for a:= 1 to b do
  begin
    c:=length(m.vop[a]);
    if c>=c1 then
      begin
        c1:=c;
      end;
  end;
if (c1=1) or (c1=0) then
  begin
    c:=39;
  end;
if c1=60 then
  begin
    c:=9
  end;
if (c1>1) and (c1<60) then
  begin
    c:=39-trunc(c1/2);
  end;
x1:=lo(windmax);
y1:=hi(windmax);
if b=1 then
  begin
    ce:=trunc(y1/2);
    cm:=1
  end;
if (b>1) and (b<y1) then
  begin
    ce:=trunc(y1/2-b/2);
    cm:=b
  end;
if b>=y1 then
  begin
    ce:=1;
    cm:=y1;
  end;
textbackground(7);
clrscr;
textbackground(2);
textcolor(0);
gotoxy(c,ce);
for z:= 1 to b do
  begin
    n:=length(m.vop[z]);
    if n<c1 then
      begin
        n:=c1-n;
        for k:= 1 to n do
          begin
            m.vop[z]:=m.vop[z]+' ';
          end;
      end;
  end;
write(m.vop[1]);
position:=ce;
position1:=1;
for a:=2 to cm do
  begin
    textbackground(7);
    gotoxy(c,ce+a-1);
    write(m.vop[a]);
  End;
back:
if keypressed=false then
  goto back;
sim:=readkey;
if sim=#27 then
    begin
      res:=0;
      exit;
    end;
if sim=#13 then
  begin
    res:=position1;
    exit;
  end;
kod:=ord(readkey);
if kod = 80 then
  Begin
    textbackground(7);
    gotoxy(c,position);
    write(m.vop[position1]);
    if (position>=1) and (position<y1) then
      begin
        if m.vop[position1+1]='NIL' then
          begin
            textbackground(2);
            gotoxy(c,position);
            write(m.vop[position1]);
            goto back;
          end;
        position:=position+1;
        position1:=position1+1;
        textbackground(2);
        gotoxy(c,position);
        write(m.vop[position1]);
        textbackground(7);
      end;
    if position=y1 then
      begin
        if m.vop[position1+1]='NIL' then
          begin
            textbackground(2);
            gotoxy(c,position);
            write(m.vop[position1]);
            goto back;
          end;
        position1:=position1+1;
        for a:= 1 to y1 do
          begin
            gotoxy(c,a);
            write(m.vop[position1-y1+a]);
          end;
        gotoxy(c,y1);
        textbackground(2);
        write(m.vop[position1]);
        textbackground(7);
      end;
    goto back;
  end;
if kod = 72 then
  Begin
    textbackground(7);
    gotoxy(c,position);
    write(m.vop[position1]);
    if position1=1 then
      begin
        textbackground(2);
        gotoxy(c,position);
        write(m.vop[position1]);
        goto back;
      end;
    if (position=1) and (position1>=2) then
      begin
        textbackground(2);
        position1:=position1-1;
        position3:=position1;
        gotoxy(c,1);
        write(m.vop[position1]);
        textbackground(7);
        for a:=2 to y1 do
          begin
            position3:=position3+1;
            gotoxy(c,a);
            write(m.vop[position3]);
          end;
      end;
    if position>=2 then
      begin
        position:=position-1;
        position1:=position1-1;
        textbackground(2);
        gotoxy(c,position);
        write(m.vop[position1]);
      end;
  end;
goto back;
end;
End.