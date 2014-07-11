unit MEdit3;                     {дата начальной версии     : 22.01.02}
                                 {дата окончатальной версии : 30.01.02}

interface

uses
  App,Views,Objects,Drivers,Types,MEdit2,Indic,MyFunc,Mylib,MsgBoxMy,
  Strings,Menus,Stream,Dos;

     {УРОВЕНЬ 3. Умеет загружать и просматривать блоки какой либо темы.
                 Обрабатывает сам только PgDn,PgUp,AltR.}

const
  inv='             Включен режим просмотра';

type                          {объект-окно ,в котором}
  PWorkWin3=^TWorkWin3;       {редактируютс и просматриваются вопросы}
  TWorkWin3=object(TWindow)
    constructor Init;
  end;

  PEdit3=^TEdit3;
  TEdit3=object(TEdit2)
    testFile:TTestFile;
    ifList:boolean;                     {true-обрабатываются PgUp,PgDown}
    line:shortInt;                      {true-режим листания}
    numVopr:integer;
    list:boolean;                       {режим листания}
    cBlocks:PCollection;                {коллекция блоков}
    invite:string;                      {УЬРАТЬ НЕМЕДЛЕННО!!!!!!!!!!!!}
    lines:PChar;
    mChar:tm1;                                 {блок-массив символов}
    constructor Init(var R:TRect;AFn:PathStr;AIndicator:PIndicator);
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure ShowChars;virtual;
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
  Pw        : PView;
  fn        : PathStr;
begin
  if not SelectTem(fn) then Fail;
  R.Assign(0,0,80,23);
  TWindow.Init(R,'Редактирование',0);
  R.Assign(2, Size.Y - 1, 16, Size.Y);
  Indicator := New(PIndicator, Init(R));
  Insert(Indicator);
  Options:=Options or ofTileable;
  GetClipRect(R);
  R.Grow(-1,-1);
  Pw:=Application^.ValidView(New(PEdit3,Init(R,fn,Indicator)));
  if Pw=nil then Fail;
  Insert(Pw);
end;

constructor TEdit3.Init;
begin
  inherited Init(R,AIndicator);
  FillChar(mChar,SizeOf(mChar),32);
  if not testFile.Init(AFn,stOpen,nil) then Fail;
  HideCursor;
  CleanInvite;
  endX:=x2-1;
  list:=true;                               {режим листания при редакт.}
  ifList:=true;
  numVopr:=1;
  cBlocks:=testFile.GetAllBlocks;
  invite:=inv;
  ShowChars;
  Draw;
  HelpCtx:=2;
end;

{$I showchar.inc}

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
  if InputInt(1,testFile.Hdr^.nn,'номер вопроса     ',m,9)=cmCancel then Exit;
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
    evBroadCast :Exit;
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

