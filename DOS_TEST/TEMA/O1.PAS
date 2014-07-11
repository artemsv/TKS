program Opros;            {дата создания начальной версии     3.11: 25.10.01}
                          {дата создания окончательной версии 4.3 : 16.11.01}
                          {дата создания окончательной версии 4.31: 21.11.01}
                          {дата создания окончательной версии 4.67: XX.03.02}

uses
  App,Dos,Crt,Drivers,MyFunc,Views,MsgBoxMy,Objects,Types,MyLib,MOpros,
  Indicatr,Dialogs,MPicture,Menus,MyTSet,Strings,Stream,LdFnt;

const
  cmEndtimer = 200;             {сообщение об окончании времени}
  ifFirst:boolean=true;         {true-окно  первый раз на ?????}
  newPalette:string[1]=#2;      {новая палитра для строки контроля времени}

var                             {глобальные переменные}
  timer     : word;             {время в секундах на один вопрос}
  oldSecond : word;             {начальное время перед каждым вопросом}
  start     : boolean;          {флаг начала отсчета времени для кажд.вопр.}
  k         : byte;             {простой,ничем не примечательный счетчик}
  scan      : byte;             {скан-код клавиши}
  oldInt09H : pointer;          {указатель на старую процедуру}
  info      : RInfo;

{$F+}
procedure IntProc;interrupt;
begin
  scan:=Port[60];
  inline($FF/$1E/>oldInt09H)
end;
{$F-}

type
  POprosWin=^TOprosWin;
  TOprosWin=object(TWindow)
    constructor Init;
  end;

  POpros=^TOpros;
  TOpros=object(TOpr)
    vern,name,badst:string;
    badmas:TBadStr;
    prav,oc:integer;
    code,totalves:integer;
    ves:integer;
    jr3,jr4,jr5,ball:real;
    fch:tfc;
    fst:text;
    neprav:byte;
    mNumvoprs:array[0..255] of integer;      {случайные номера вопросов}
    mTimers:array[1..255] of word;
    count:byte;                             {номер вопроса при опросе}
    Hdr:PHdr;
    cBL:PCollection;
    constructor Init(var R:TRect;AIndVopr,AIndVar:PIndicator);
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure StartOpros;                   {подготовка к опросу}
    procedure SelectVar;                    {выбор варианта}
    procedure GoodAnswer;                   {реакция на правильный ответ}
    procedure BadAnswer;                    {реакция на неправильный ответ}
    procedure EndOpros;                     {конец опроса}
    procedure NextVopr(b,del:boolean);      {true-вверх;true-удалять}
  end;

  TMyApp=object(TApplication)
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure Run;virtual;
    procedure InitStatusLine;virtual;
    procedure InitmenuBar;virtual;
    procedure Idle;virtual;
  end;

  PTimerView=^TTimerView;
  TTimerView=object(TStaticText)
   function GetPalette:PPalette;virtual;
   procedure Clean;                         {очистить строку таймера}
   procedure UpDate;                        {обновить показания таймера}
  end;

var
  Opr  : POpros;
  MySet: TSet;

const
  PWin : POprosWin=nil;

procedure ReadInfo(var info:RInfo);
var
  f:text;
  k:byte;
begin
  Assign(f,'info.opr');
  {$I-}
  Reset(f);
  if IOresult<>0 then begin
    MessageBox(#3'Ошибка чтения файла INFO.DAT !',nil,mfOkButton);
    Halt;
  end;
  Readln(f,info.date);
  Readln(f,info.gr);
  Readln(f,info.kGr);
  Readln(f,info.fnt);
  Readln(f,info.kolTem);
  for k:=1 to info.kolTem do
  begin
    Readln(f,info.tems[k].t);
    Readln(f,info.tems[k].n);
  end;
  Readln(f,info.total);
  Readln(f,info.tim);
  Readln(f,info.j5);
  Readln(f,info.j4);
  Readln(f,info.j3);
  Close(f);
  if IOresult<>0 then begin
    MessageBox(#3'Неверный формат файла INFO.DAT !',nil,mfOkButton);
    Halt;
  end;
end;

procedure TTimerView.UpDate;
begin
  if not start then Exit;
  if GetSecond<>oldSecond then
  begin
    Dec(timer);
    if timer=0 then Message(Opr,evBroadCast,cmEndtimer,nil);
     oldSecond:=GetSecond;
  end;
  DisposeStr(text);
  text:=NewStr(#3'Ваше время:'+Sstr(timer));
  Draw;
end;

procedure TTimerView.Clean;
begin
  DisposeStr(text);
  text:=NewStr('   ');
  Draw
end;

function TTimerView.GetPalette;
begin
  GetPalette:=@newPalette
end;

var
  T,Q:PTimerView;

procedure TMyApp.Idle;
begin
  T^.UpDate
end;

procedure TMyApp.HandleEvent;
begin
  if (Event.What=evCommand) and (Event.Command=cmQuit) then if
    MessageBox(#3'Подтверждаете выход?',nil,mfYesButton+mfNoButton) in
      [cmNo,cmCancel] then ClearEvent(Event) else SetIntVec($09,oldInt09H);
  inherited HandleEvent(Event);
end;

procedure TMyApp.Run;
var
  R:TRect;
begin
  R.Assign(62,24,80,25);
  New(T,Init(R,''));
  R.Assign(65,0,80,1);
  TMyApp.Insert(New(PTimerView,Init(R,'Turbo Test 4.67')));
  TMyApp.Insert(T);
  R.Assign(2,24,38,25);
  Q:=New(PTimerView,Init(R,'Стрелки '+#24+','+#25+' - просмотр вопросов.'));
  Q^.Hide;
  TMyApp.Insert(Q);
  PWin:=POprosWin(Application^.ValidView(New(POprosWin,Init)));
  if PWin=nil then MsgHalt('Сбой в конструкторе!!!'+#13+#13+
     #3'Вызов из TApplication.Run');
  DeskTop^.Insert(PWin);
  ifFirst:=false;
  inherited Run;
end;

procedure TMyApp.InitStatusLine;
var
  R:TRect;
begin
  GetExtent(R);
  R.a.y:=Pred(R.b.y);
  StatusLine:=New(PStatusLine,Init(R,
  NewStatusDef(0,$FFFF,NewStatusKey('',kbAltX,cmQuit,nil),nil)))
end;

procedure TMyApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);R.B.Y := R.A.Y + 1;
  MenuBar :=New(PMenuBar,Init(R,nil))
end;

constructor TOprosWin.Init;
var
  R:TRect;
  IndVopr,IndVar:PIndicator;
begin
  start:=false;
  R.Assign(0,0,80,23);
  TWindow.Init(R,'Тест-опрос',0);
  R.Assign(2, Origin.Y , 20, Origin.Y+1);
  IndVopr:= New(PIndicator, Init(R));Insert(IndVopr);
  R.Assign(57, Origin.Y , 75, Origin.Y+1);
  IndVar:= New(PIndicator, Init(R));Insert(IndVar);
  GetClipRect(R);R.Grow(-1,-1);
  Opr:=New(POpros,Init(R,IndVopr,IndVar));
  if Opr=nil then Fail
  else Insert(Opr);
end;

procedure TOpros.SelectVar;
var
  n:integer;
begin
{  if not OpenFile('\TEST\TEMA\tema.'+header.index,pf,0,true) then Halt;
  n:=ReadFour(pf);
  Close(tfc(pf^));
  InputInt(1,n,'номер варианта(от 1 до '+Sstr(n)+')',numVar,0);}
  numVar:=1;
end;

constructor TOpros.Init;
var
  fn:PathStr;
begin
  ReadInfo(info);
  fn:=info.tems[1].t;
  if not inherited Init(R,fn,nil) then Fail;
  Hdr:=New(PHdr,Init(TestFile.Hdr^.nn,TestFile.Hdr^.ckolko,TestFile.Hdr^.kTem,
    TestFile.Hdr^.d,TestFile.Hdr^.Tema,TestFile.Hdr^.fName,TestFile.Hdr^.pch));
  IndVopr:=AIndVopr;
  IndVar:=AIndVar;
  StartOpros;
  HideCursor;
end;

procedure TOpros.HandleEvent;
var
  key:integer;
begin                                                        {время вышло}
  if (Event.What=evBroadCast) and (Event.Command=cmEndTimer) then
    BadAnswer;
  if Event.What=evKeyDown then Val(Event.CharCode,key,code);
  if (code=0) and ((key>0) and (key<testFile.Hdr^.d+2)) then
  begin
    ClrKeyBuf;
    ClearEvent(Event);
    if key=right then GoodAnswer else BadAnswer;
  end;
  if (Event.What=evKeyDown) then
    case Event.KeyCode of
      kbUp:if timer>10 then NextVopr(false,false);
      kbDown:if timer>10 then NextVopr(true,false)
    end;
end;

procedure TOpros.StartOpros;
begin
   prav:=0;
   ball:=0;
   neprav:=0;
   T^.Clean;                                    {очистка контроллера времени}
   numvar:=0;                                   {пока номер варианта=0}
   w:=DeskTop^.ExecView(New(PPicture,Init));
   case w of
     cmOk:SelectVar;
     cmCancel:Halt;
   end;
   jr3:=info.j3 /100;jr4:=info.j4/100;jr5:=info.j5/100;
   if not mySet.Init(1,info.tems[1].n) then MsgHalt('Сбой в конструкторе mySet');
   Duplet(testFile.Hdr^.nn,info.tems[1].n,mNumVoprs);
   for k:=1 to colVopr do mTimers[k]:=info.tim+1;
   count:=1;
   numVopr:=mNumVoprs[count];
   timer:=info.tim;
   CleanChars;
   InterMixLines;
   IndVopr^.SetValue(1,1);
   IndVar^.SetValue(numVar,2);
   if not ifFirst and (PWin<>nil) then PWin^.Show;
   Draw;
   Q^.Show;
   start:=true;
end;

procedure TOpros.BadAnswer;
begin
  name:='';
  k:=PBlock(cBlocks^.At(numVopr))^.num;
  Inc(neprav);	                            {общее кол-во неправ.ответов}
  badmas[neprav]:=k;                        {в масс.непр.отв.-ном.вопр.}
  NextVopr(true,true);
end;

procedure TOpros.GoodAnswer;
begin
  Inc(prav);
  NextVopr(true,true);
end;

procedure TOpros.NextVopr;
var
  oldCount:byte;
begin
  oldCount:=count;
  mTimers[count]:=timer;                    {запомнили оставшееся время}
  if b then count:=mySet.NextPlus(count)    {получаем следующий}
  else count:=mySet.NextMinus(count);
  if del then myset.Delete(oldCount);       {исключ.сей вопр.из еще возможных}
  if mySet.IsEmpty then EndOpros;           {конец,если нет возможных}
  numVopr:=mNumVoprs[count];
  if (numVopr>cBlocks^.count-1) or (count>info.tems[1].n)
  then EndOpros
  else InterMixLines;
  if IndVopr<>nil then IndVopr^.SetValue(count,1);
  timer:=mTimers[count]                     {начальное значение }
end;

procedure TOpros.EndOpros;
var
  st,ballStr:string;
  russ:boolean;                              {true-если все буквы-русские}
begin
  T^.Clean;                                  {очистка контролера времени}
  PWin^.Hide;                                {спрятали окно}
  Q^.Hide;                                   {строка подсказки}
  start:=false;
 { Sort(badmas);                              {сортировка по возрастанию}
  name:='';
  for k:=1 to neprav do name:=name+'.'+Sstr(badmas[k]);            {name}
  badst:=Copy(name,2,Length(name)-1);        {убираем точку в name}
  Str(prav,vern);                            {кол_во прав.ответов в строку}
  ves:=info.total div info.tems[1].n;             {вес в баллах одного вопроса}
  ball:=ves*prav;                            {подсчитываем его баллы}
  k:=trunc(ball);                            {преобразуем в целое}
  Str(k,ballStr);
  if ball<info.total*jr3 then oc:=2;
  if (ball=info.total*jr3) or (ball>info.total*jr3) and
    (ball<info.total*jr4) then oc:=3;
  if (ball=info.total*jr4) or (ball>info.total*jr4) and
    (ball<info.total*jr5) then oc:=4;
  if (ball=info.total*jr5) or (ball>info.total*jr5) then oc:=5;
  repeat
    name:='';
    russ:=true;
    while Length(name)<4 do
      InputBox('','Введите имя тестируемого:',name,15,0);
    for k:=1 to Length(name) do if (Ord(name[k])<128)and
      not(name[k] in[' ','.']) then russ:=false;
    if not russ then MessageBox(#3'Только русские буквы!!!',nil,mfOkButton);
  until russ;
  Assign(fst,'otchet.dat');
  {$I-}
  if not Verify('otchet.dat',GetCurDir) then Rewrite(fst) else Append(fst);
  {$I+}
  st:=StrPas(testFile.Hdr^.tema);
  Writeln(fst,info.date:8,name:15,info.gr:8,info.kgr:3,numvar:4,oc:2,ballStr:5,
     st:12,testFile.Hdr^.kTem:3,' ',badst);
  Close(fst);
  CleanChars;
  Draw;
  StartOpros;
end;

var
  MyApp:TMyApp;
begin
  Myapp.Init;
  Myapp.Run;
  MyApp.Done
end.

