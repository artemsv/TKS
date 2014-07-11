unit MEdit3;                     {дата начальной версии     : 22.01.02}
                                 {дата окончатальной версии : 30.01.02}

interface

uses
  App,Views,Objects,Drivers,Types,MEdit2,Indic,MyFunc,Mylib,MsgBoxMy,
  Strings,Menus;

     {УРОВЕНЬ 3. Умеет загружать и просматривать блоки какой либо темы.
                 Обрабатывает сам только PgDn,PgUp,AltR.}

const
  inv='             Включен режим просмотра';
  cmChangeColor=701;

type                          {объект-окно ,в котором}
  PWorkWin3=^TWorkWin3;       {редактируютс и просматриваются вопросы}
  TWorkWin3=object(TWindow)
    constructor Init;
  end;

  PEdit3=^TEdit3;
  TEdit3=object(TEdit2)
    ifList:boolean;                     {true-обрабатываются PgUp,PgDown}
    line:shortInt;                      {true-режим листания}
    numVopr:integer;
    header:THeader;                     {заголовок}
    list:boolean;                       {режим листания}
    cBlocks:PCollection;                {коллекция блоков}
    fileName:st79;
    invite:string;                      {УЬРАТЬ НЕМЕДЛЕННО!!!!!!!!!!!!}
    lines:PChar;
    mChar:tm1;                                 {блок-массив символов}
    constructor Init(var R:TRect;h:THeader;AIndicator:PIndicator);
    procedure HandleEvent(Var Event:TEvent);virtual;
    procedure ReadBlock(p:Pointer);
    procedure ShowChars;virtual;
    function  LoadEditFile(var cCol:PCollection):boolean;
    procedure PageDownUp(n:word);virtual;
    procedure WriteInvite;                     {вывод приглашения}
    procedure CleanInvite;                     {стирает приглашение}
    procedure GoTonewNumber;
  end;


implementation

constructor TWorkWin3.Init;
var
  R         : TRect;
  Indicator : PINdicator;
  h         : THeader;
  Pw        : PView;
begin
  if SelectTema(h)=cmCancel then Fail;
  R.Assign(0,0,80,23);
  TWindow.Init(R,'Редактирование',0);
  R.Assign(2, Size.Y - 1, 16, Size.Y);
  Indicator := New(PIndicator, Init(R));
  Insert(Indicator);
  Options:=Options or ofTileable;
  GetClipRect(R);
  R.Grow(-1,-1);
  Pw:=Application^.ValidView(New(PEdit3,Init(R,h,Indicator)));
  if Pw=nil then Fail;
  Insert(Pw);
end;

constructor TEdit3.Init;
begin
  inherited Init(R,AIndicator);
  HideCursor;
  CleanInvite;
  endX:=x2-1;
  list:=true;                               {режим листания при редакт.}
  ifList:=true;
  fileName:=h.fName;
  numVopr:=1;
  if not LoadEditFile(cBlocks) then Fail;   {если не удалось загрузить блоки}
  header:=h;
  invite:=inv;
  ShowChars;
  Draw;
  HelpCtx:=2;
end;

procedure TEdit3.ShowChars;
var
  position:integer;
  k:byte;
  atribut:word;
  ch:char;
  ifFirst:boolean;
begin
  CleanChars;
  invite:=inv+GetStr(27,' ')+'Вопрос № '+Sstr(numVopr);
  WriteInvite;
  if numVopr>cBlocks^.count-1 then Exit;          {аварийный выход}
  lines:=cBlocks^.At(numVopr);
  x:=0;y:=1;ch:=lines[4];position:=5;
  position:=4;ifFirst:=true;
  repeat
    if ch=#221 then begin
      if x>0 then Inc(y);
      x:=0;
      if ifFirst then begin
        for k:=0 to x2 do chars[y,k]:=syl+196;
        ifFirst:=false;
        line:=y;
        Inc(y);
      end;
    end else begin
      if x<oldX then atribut:=syn else atribut:=sym;
      k:=byte(ch);
      chars[y,x]:=atribut+k;
      Inc(x);
      if x>endX then begin
        x:=0;
        Inc(y);
      end;
      if y>y2 then Break;
    end;
    Inc(position);
    ch:=lines[position];
  until ch=#219;
end;

function TEdit3.LoadEditFile;
begin
  LoadEditFile:=false;
  if not OpenFile(filename,pf,0,true) then Exit;
  if cCol=nil then cCol:=New(PCollection,Init(10,5));
  DiskReadWriteMsg('Идет загрузка с диска!');
  while not Eof(tfc(pf^)) do
    begin
      if memavail<4096 then
      begin
        MessageBox(#3'Не хватает памяти ',nil,mfError+mfOkButton);
        cCol^.DeleteAll;
        Close(tfc(pf^));
        Exit;
      end;
      ReadBlock(pf);                          {считать блок}
      cCol^.Insert(StrNew(mChar));        {в коллекцию-указатель на блок}
    end;
  Close(tfc(pf^));
  LoadEditFile:=true;
end;

procedure TEdit3.ReadBlock;
var
  k:integer;
begin
  k:=0;
  while not Eof(tfc(p^)) do
    begin
      Read(tfc(p^),mChar[k]);
      if mChar[k]=#219 then Break;
      Inc(k);
    end;
  mChar[k+1]:=#0;                               {терминальный ноль}
end;

procedure TEdit3.WriteInvite;
var
  k:byte;
begin
  for k:=1 to Length(invite) do
    chars[0,k+2]:=syl+byte(invite[k]);
end;

procedure TEdit3.CleanInvite;
var
  k:byte;
begin
  for k:=1 to x2 do chars[0,k]:=syl+32;
end;


procedure TEDit3.PageDownUp(n:word);
begin
  Inc(numVopr,n);
  if numVopr>cBlocks^.count-1 then numVopr:=1;
  if numVopr=0 then numVopr:=cBlocks^.count-1;
  ClearAll;
  ShowChars;
end;

procedure TEdit3.GoToNewNumber;
var
  m:integer;
begin
  if InputInt(1,header.nn,'номер вопроса     ',m,9)=cmCancel then Exit;
  numVopr:=0;
  PageDownUp(m);
end;

procedure TEdit3.HandleEvent;
var
  R:TRect;
  PM:PMenuPopup;
  k,i:byte;
begin
  if not list then Inherited HandleEvent(Event);
  case Event.What of
    evBroadCast :if Event.Command=cmChangeColor then
                 begin
                   SetColors;
                   for k:=0 to x2 do chars[0,k]:=syn+Lo(chars[0,k]);
                   for k:=1 to y2 do for i:=0 to oldX do chars[k,i]:=
                   syn+Lo(chars[k,i]);
                   for k:=1 to y2 do for i:=oldX to x2 do chars[k,i]:=
                   sym+Lo(chars[k,i]);
                   Draw;
                 end else exit;
    evMouseDown :Exit;
    evCommand   :Exit;
    evKeyDown   :
       case Event.KeyCode of
         kbAltK  : begin R.Assign(10,10,30,17);
                    PM:=New(PMenuPopup,Init(R,NewMenu(StdWindowMenuItems(nil))));
                    w:=DeskTop^.ExecView(PM);
                    if w<>cmCancel then begin
                      Event.What:=evCommand;
                      Event.Command:=w;
                      PutEvent(Event);
                    end;
                   end;
                                            {вставка целого вопроса в буфер}
         kbAltR    :if ClipBoard<>nil then
                    begin
                      ClipBoard^.chars:=chars;
                      ClipBoard^.paste:=line;    {в paste хранится line}
                      ClipBoard^.Draw;
                     end;

         kbAltS    :GoToNewNumber;
         kbPgDn,
         kbPgUp    :if ifList then
                       PageDownUp((Event.KeyCode div 256-1)div 4-19);
       else
         Exit;
       end;
  else
    Exit;
  end;
  ClearEvent(Event);
  UpDate;
end;
end.

