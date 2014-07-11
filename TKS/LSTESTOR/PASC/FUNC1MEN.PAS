Unit Func1men;

Interface

Uses password,func3men,crt,dos,ramatest,groups,teeeee,menutest;

Var
sostexit:boolean;
lich:boolean;
coltes:word;
test:array[1..1000] of boolean;
test1:array[1..1000] of word;
vopros4:array[1..1000] of integer;
fotch:text;
vesobv:integer;
vopros:struct;

Procedure Testirovanie;
Procedure Otchet;

Implementation

Procedure Testirovanie;

Label
back,back1,back2;

Var
per,per1,per2,per3,per4,per5,per6,per9:word;
sost:boolean;
a:men;
res:byte;
readtes:word;
nimvo:word;
vopro:array[1..4] of shortint;
hour,minute,secund,sec100,hour1,minute1,secund1,sec1001:word;
cht:char;
chtd:shortint;
code:integer;

Begin
vesobv:=0;
sostexit:=false;
lich:=false;
cleaall;
rama1;
for res:= 1 to 100 do
  a.vop[res]:='';
a.vop[1]:='ˆ­¤¨¢¨¤ã «ì­®¥ â¥áâ¨à®¢ ­¨¥';
a.vop[2]:='ˆá¯®«ì§®¢ ­¨¥ á¯¨áª®¢';
a.vop[3]:='NIL';
menu(a,res);
if res=0 then
  begin
    sostexit:=true;
    exit;
  end;
if res=1 then
  begin
    curon;
    lich:=true;
    cleaall;
    rama1;
    gotoxy(5,10);
    write('‚¢¥¤¨â¥ ”ˆ: ');
    readln(MFIO);
    mgr:='';
    curoff;
  end;
if res=2 then
  begin
    choisegroups;
  end;
if MFIO='' then
  begin
    sostexit:=true;
    exit;
  end;
coltes:=filesize(fa);
randomize;
for per:= 1 to coltes do
  test[per]:=false;
for per:=1 to coltes do
  begin
back:
    sost:=false;
    nimvo:=random(coltes)+1;
    if coltes=1 then
      begin
        test1[1]:=1;
        goto back2;
      end;
    for per1:=1 to per do
      begin
        if test1[per1]=nimvo then
          sost:=true;
      end;
    if sost=true then
      goto back;
    test1[per]:=nimvo;
  end;
back2:
for per:=1 to coltes do
  begin
    curoff;
    cleaall;
    window(2,1,79,6);
    textcolor(0);
    clrscr;
    gotoxy(1,6);
    write('ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ');
    window(2,1,78,5);
    chten(test1[per]-1,vopros);
    for per1:= 1 to 4 do
      begin
        gotoxy(1,per1);
        write(vopros.vopr[per1]);
      end;
    for per1:= 1 to 4 do
      vopro[per1]:=0;
    for per1:=1 to 4 do
      begin
back1:
        sost:=false;
        per2:=random(4)+1;
        for per3:=1 to per1 do
          begin
            if vopro[per3]=per2 then
              sost:=true;
          end;
        if sost=true then
          goto back1;
        vopro[per1]:=per2;
      end;
    window(2,6,78,25);
    per3:=1;
    gotoxy(1,1);
    write('1ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    gotoxy(1,2);
    for per1:=1 to 4 do
      begin
        for per2:= 1 to 4 do
          begin
            gotoxy(1,per3+per2);
            write(vopros.otv[vopro[per1],per2]);
          end;
        if per1<>4 then
          begin
            per3:=per3+5;
            gotoxy(1,per3);
            write(per1+1,'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
          end;
      end;
    gettime(hour1,minute1,secund1,sec1001);
    per9:=conf.timer;
    if conf.timer=0 then
      per9:=99;
    cht:='p';
    while (per9<>0) and (cht='p') do
      begin
        if keypressed<>false then
          begin
            cht:=readkey;
            if cht=#27 then
              begin
                sostexit:=true;
                exit;
              end;
            if (cht='1') or (cht='2') or (cht='3') or (cht='4') then
              begin
                val(cht,chtd,code);
                if vopro[chtd]=4 then
                  begin
                    test[per]:=true;
                    vesobv:=vesobv+vopros.ves;
                  end;
              end
              else
                cht:='p';
          end;
        gettime(hour1,minute1,secund,sec1001);
        if conf.timer<>0 then
          begin
            if secund<>secund1 then
              begin
                per9:=per9-1;
                gotoxy(74,1);
                write('   ');
                gotoxy(75,1);
                write(per9);
                secund1:=secund;
              end;
          end;
      end;
   end;
end;

Procedure Otchet;

Label
back1,back2;

Var
per1,per2,per3,per4,per6,per7:word;
nev,pernev:string;
sos:boolean;
vesov,vesov1,per5:integer;

Begin
per5:=0;
vesov:=0;
vesov1:=0;
if conf.fileofotch='' then
  halt;
assign(fotch,conf.fileofotch);
{$I-}
reset(fotch);
{$I+}
if ioresult<>0 then
  begin
    rewrite(fotch);
  end
  else
    begin
      append(fotch);
    end;
per2:=0;
for per1:=1 to coltes do
  begin
    vesov:=vesov+vopros4[per1];
    if test[per1]=false then
      begin
        per2:=per2+1;
        vesov1:=vesov1+vopros4[per1];
      end;
  end;
per3:=length(mfio);
for per4:=1 to 30-per3 do;
   mfio:=mfio+' ';
if vesobv<conf.oc[3] then
  begin
    per5:=2;
  end;
if (vesobv>=conf.oc[3]) and (vesobv<conf.oc[4]) then
  begin
    per5:=3;
  end;
if (vesobv>=conf.oc[4]) and (vesobv<conf.oc[5]) then
  begin
    per5:=4;
  end;
if vesobv>=conf.oc[5] then
  begin
    per5:=5;
  end;
nev:='';
sos:=false;
writeln(fotch,mfio,mgr,' æ¥­ª :',per5,' Š®«¨ç¥áâ¢® ­¥¢¥à­ëå ®â¢¥â®¢:',per2);
if per2<>0 then
  begin
writeln(fotch,'¥¢¥à­ë¥ ®â¢¥âë: ');
for per4:= 1 to coltes do
  begin
    sos:=false;
    if test[per4]=false then
      begin
        str(test1[per4],pernev);
        nev:=nev+pernev+' ';
        if length(nev)>=77 then
          begin
            writeln(fotch,nev);
            nev:='';
            sos:=true;
          end;
      end;
  end;
if sos=false then
  writeln(fotch,nev);
end;
close(fotch);
end;
end.