Uses dos,crt,edittest,ramatest,password,groups,func1men,func2men,func3men,mainmenu,teeeee;

Label
back1,back2,back3;

Var
vopros12:struct;
per1:word;
per2:integer;
rez:byte;
ad:char;
par:ch5;

Begin
per2:=0;
grf;
openfil(conf.fileoftest);
opengr;
back1:
curoff;
cleaall;
rama1;
mm(rez);
if rez=0 then
  begin
    textcolor(15);
    textbackground(0);
    cleaall;
    curon;
    writeln('U_Alex LS TestEditor 2001.');
    writeln('Tashkent, Gubin Alexey, tel.681040');
    halt;
  end;
if rez=2 then
  begin
    par:='';
    textbackground(7);
    clrscr;
    pass(par);
    if par<>conf.password then
      goto back1;
back3:
    mm2(rez);
    if rez=0 then
      goto back1;
    if rez=1 then
      begin
        redte;
        curoff;
        goto back3;
      end;
    if rez=2 then
      begin
        rednev;
        curoff;
        goto back3;
      end;
    if rez=3 then
      begin
        izmves;
        curoff;
        goto back3;
      end;
    if rez=4 then
      begin
        dobntest;
        curoff;
        goto back3;
      end;
    if rez=5 then
      begin
        udaltst;
        curoff;
        goto back3;
      end;
  end;
if rez=3 then
  begin
    par:='';
    pass(par);
    textbackground(7);
    clrscr;
    if par<>conf.password then
      goto back1;
back2:
    mm3(rez);
    if rez=0 then
      goto back1;
    if rez=1 then
      begin
        editgroups;
        goto back2;
        curoff;
      end;
    if rez=2 then
      begin
        izmpass;
        curoff;
        saver;
        goto back2;
      end;
    if rez=3 then
      begin
        izmstav;
        curoff;
        saver;
         goto back2;
      end;
    if rez=4 then
      begin
        izmtim;
        curoff;
        saver;
        goto back2;
      end;
    if rez=5 then
      begin
        udalgroups;
        curoff;
        goto back2;
      end;
    if rez=6 then
      begin
        izmfot;
        curoff;
        saver;
        goto back2;
      end;
    if rez=7 then
      begin
        izmfoo;
        curoff;
        saver;
        goto back2;
      end;
    if rez=8 then
      begin
        izmgroup;
        curoff;
        saver;
        goto back2;
      end;
    if rez=9 then
      begin
        cleaall;
        rama1;
        writeln('Пароль: ',conf.password);
        writeln('Ставки на3: ',conf.oc[3],', на4: ',conf.oc[4],', на5:',conf.oc[5]);
        writeln('Таймер: ',conf.timer,' сек.');
        writeln('Файл тестирования: ',conf.fileoftest);
        writeln('Файл отчета: ',conf.fileofotch);
        writeln('Файл групп: ',conf.fileofgroup);
        write('Общий вес вопросов: ');
        for per1:=0 to filesize(fa)-1 do
          begin
            chten(per1,vopros12);
            per2:=per2+vopros12.ves;
          end;
        writeln(per2);
        writeln('Количество тестов: ',filesize(fa));
        ad:=readkey;
        goto back2;
      end;
  end;
if rez=1 then
  begin
    textcolor(0);
    textbackground(7);
    clrscr;
    testirovanie;
    if sostexit=true then
      goto back1;
    otchet;
    goto back1;
  end;
end.