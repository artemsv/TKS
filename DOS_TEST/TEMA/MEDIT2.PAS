unit MEdit2;                     {дата начальной версии     : 21.01.02}
                                 {дата окончатальной версии : 30.02.02}

interface

uses App,Views,Objects,Drivers,Types,MEdit1,Indic,DrDrop;

     {УРОВЕНЬ 0. Уровень буфера.Вставка и копирование}

const
  cmItemDropped=700;

type
  PEdit2 = ^TEdit2;
  TEdit2=object(TEdit1)
    ifShift:boolean;
    paste:byte;                                {коорд.скопир.линии в буфере}
    procedure InsertFrom(P:PEdit2);            {обмен с буфером}
    procedure ClipPaste;                       {вставка из буфера}
    procedure ClipCopy;                        {вставка в буфер}
    procedure GoEnd;virtual;
    function  Minus:boolean;virtual;
    procedure Plus;virtual;
    procedure Home;virtual;
    function  FillLine(a1,a2,b:byte;atribut:word):boolean; {измен.цвет текста }
    procedure PickUpItem(tp:TPoint);virtual;
    procedure FromMover(var E:TEvent);virtual;
    procedure HandleEvent(var Event:TEvent);virtual;
end;

type
  PWorkWin2=^TWorkWin2;                          {?????????????????}
  TWorkWin2=object(TWindow)
    Editor:PEdit2;
    constructor Init(st:string);
    procedure HandleEvent(var Event:TEvent);virtual;
  end;

const
  ClipBoard:PEdit2=nil;                         {указатель на буфер}

implementation

constructor TWorkWin2.Init;
var
  R:TRect;
  Indicator:PIndicator;
begin
  R.Assign(0,0,80,23);
  TWindow.Init(R,st,0);
  R.Assign(2, Size.Y - 1, 16, Size.Y);
  Indicator := New(PIndicator, Init(R));
  Insert(Indicator);
  Options:=Options or ofTileable;
  GetClipRect(R);
  R.Grow(-1,-1);
  Editor:=New(PEdit2,Init(R,Indicator));
  if Editor=nil then Fail;
  Insert(Editor);
end;

procedure TWorkWin2.HandleEvent(var Event:TEvent);
begin
  if (Event.What=evCommand) and (Event.command=cmClose) and
  (ClipBoard=Editor) then Hide else inherited HandleEvent(Event)
end;

procedure TEdit2.InsertFrom(P:PEdit2);
var
  k:byte;
begin
  if ClipBoard=@Self then               {если я-окно буфера}
  begin
    y:=1;
    CleanChars;
    x:=oldX;
  end;
  for k:= P^.oldx to endX do
    if Hi(P^.chars[P^.paste,k])=$71 then
    begin
      chars[y,x]:=P^.chars[P^.paste,k];
      Plus;
    end;
  paste:=y;
end;

procedure TEdit2.ClipPaste;
begin
  CleanColor;
  if (Clipboard<>nil) and (ClipBoard<>@Self)
    then InsertFrom(ClipBoard);
end;

procedure TEdit2.ClipCopy;
begin
  if (ClipBoard<>nil) and (ClipBoard<>@Self) then
    ClipBoard^.InsertFrom(@Self);
end;

function TEdit2.FillLine;
var
  k:byte;
begin
  FillLine:=false;
  if a1=a2 then Exit;
  CleanColor;
  for k:=a1 to a2 do
    chars[b,k]:=atribut+Lo(chars[b,k]);
  FillLine:=true
end;

procedure TEdit2.GoEnd;
begin
  if ifShift                            {если нажата комбинация Shift+End}
    then if FillLine(FindFirst(x),LastPosition(endX),y,syv) then
      paste:=y;
  inherited GoEnd
end;

procedure TEdit2.Home;
begin
  if ifShift then                       {если нажата комбинация Shift+Home}
    if FillLine(FindFirst(oldX),LastPosition(x),y,syv) then
      paste:=y;
  inherited Home
end;

function TEdit2.Minus:boolean;
begin
  Minus:=inherited Minus;
  if ifShift then                       {если нажата комбинация Shift + -}
  begin                  {очистка chars,если только начато выделение}
    if (y<>paste) or (Hi(chars[y,x+1])<>syvM) then CleanColor;
    chars[y,x]:=syv+Lo(chars[y,x]);
    paste:=y;
  end;
end;

procedure TEdit2.Plus;
begin
  if ifShift then if x<endX then
  begin                  {очистка chars,если только начато выделение}
    if (y<>paste) or (Hi(chars[y,x-1])<>syvM) then CleanColor;
    chars[y,x]:=syv+Lo(chars[y,x]);
    paste:=y;
  end;
  inherited Plus
end;

procedure TEdit2.HandleEvent;
var
  k,j,z:byte;
begin
  if (Mem[0:$417] and 3)<>0 then ifShift:=true else ifShift:=false;
  if (Event.KeyCode <>kbEnd) and (Event.KeyCode <>kbLeft) and
  (Event.KeyCode <>kbRight) and (Event.KeyCode <>kbHome) then ifShift:=false;
  inherited HandleEvent(Event);
  case Event.What of
    evBroadCast :if Event.Command=cmItemDropped then
                 begin
                   FromMover(Event);
                   Exit; {выход в любом случае,так как возможны др.окна}
                 end else Exit;
    evMouse:Exit;
    evCommand:Exit;
    evKeyDown:
      case Event.KeyCode of
        kbCtrlIns :ClipCopy;
        kbShiftIns:ClipPaste;
      else
        Exit
      end;
  end;
  ClearEvent(Event);
  UpDate;
end;

procedure TEdit2.FromMover(var E:TEvent);
var                                    {копирует подстроку из перемещаемого}
  tp:TPoint;                           {буфера в chars}
  k:byte;
begin
  if not MouseInView(MouseWhere) then Exit;
  MakeLocal(MouseWhere,tp);
  CleanColor;
  for k:=tp.x to tp.x+PMover(E.InfoPtr)^.len-1 do
    if k<=endX then chars[tp.y,k]:=PMover(E.InfoPtr)^.buffer[k-tp.x];
  paste:=tp.y;
  Draw;
  ClearEvent(E);   {очищаем событие,чтобы небыло "просачивания" под окно}
end;

procedure TEdit2.PickUpItem(tp:TPoint);
var                                   {перетаскивает выделенный текст,если}
  mover:PMover;                       {щелкнули мышкой внутри выделенной}
  local:TPoint;                       {области,или выделяет подстроку,если}
  E:TEvent;                           {щелчек зафиксирован в "чистом" месте}
  buffer:TBuffer;
  k,start,finish:byte;
begin
  MakeLocal(tp,local);
  if Hi(chars[local.y,local.x])<>syvM then
  begin                                {если попытка зацепить не выд.текст}
    CleanColor;                        {то-режим выделения текста мышкой}
    repeat
      MakeLocal(MouseWhere,tp);
      if local.y<>tp.y then Continue;
      chars[tp.y,tp.x]:=syv+Lo(chars[tp.y,tp.x]);
      paste:=tp.y;
      WriteLine(0,tp.y,Size.X,1,chars[tp.y]);
    until  not MouseEvent(E,evMouseMove+evMouseAuto);
    Exit;
  end;                                 {если текст выделен-режим буксировки}
  start:=0;finish:=0;
  for k:=0 to High(buffer) do buffer[k]:=sym32;
  for k:=oldX to endX do                    {нахождение начала выделения}
    if Hi(chars[paste,k])=syvM then
    begin
      start:=k;
      Break;
     end;
  for k:=endX downto oldX do                {нахождение конца выделения}
    if Hi(chars[paste,k])=syvM then
    begin
      finish:=k;
      Break;
    end;
  for k:=start to finish+1 do                       {заполнение буфера}
    buffer[k-start]:=chars[paste,k];
  mover:=New(PMover,Init(local,buffer,finish-start+1));
  DeskTop^.Insert(Mover);
  repeat
    Mover^.MoveTo(MouseWhere.x,mouseWhere.Y-1);     {цикл перетаскивания}
  until not MouseEvent(E, evMouseMove);
  Message(DeskTop,evBroadCast,cmItemDropped,Mover);
  Dispose(Mover,Done);
end;

end.
