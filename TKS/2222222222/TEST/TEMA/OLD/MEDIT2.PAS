unit MEdit2;                     {��� ��砫쭮� ���ᨨ     : 21.01.02}
                                 {��� �����⠫쭮� ���ᨨ : 30.02.02}

interface

uses App,Views,Objects,Drivers,Types,MEdit1,Indic,DrDrop;

     {������� 0. �஢��� ����.��⠢�� � ����஢����}

const
  cmItemDropped=700;

type
  PEdit2 = ^TEdit2;
  TEdit2=object(TEdit1)
    ifShift:boolean;
    paste:byte;                                {����.᪮���.����� � ����}
    procedure InsertFrom(P:PEdit2);            {����� � ���஬}
    procedure ClipPaste;                       {��⠢�� �� ����}
    procedure ClipCopy;                        {��⠢�� � ����}
    procedure GoEnd;virtual;
    function  Minus:boolean;virtual;
    procedure Plus;virtual;
    procedure Home;virtual;
    function  FillLine(a1,a2,b:byte;atribut:word):boolean; {�����.梥� ⥪�� }
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
  ClipBoard:PEdit2=nil;                         {㪠��⥫� �� ����}

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
  if ClipBoard=@Self then               {�᫨ �-���� ����}
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
  if ifShift                            {�᫨ ����� ��������� Shift+End}
    then if FillLine(FindFirst(x),LastPosition(endX),y,syv) then
      paste:=y;
  inherited GoEnd
end;

procedure TEdit2.Home;
begin
  if ifShift then                       {�᫨ ����� ��������� Shift+Home}
    if FillLine(FindFirst(oldX),LastPosition(x),y,syv) then
      paste:=y;
  inherited Home
end;

function TEdit2.Minus:boolean;
begin
  Minus:=inherited Minus;
  if ifShift then                       {�᫨ ����� ��������� Shift + -}
  begin                  {���⪠ chars,�᫨ ⮫쪮 ���� �뤥�����}
    if (y<>paste) or (Hi(chars[y,x+1])<>syvM) then CleanColor;
    chars[y,x]:=syv+Lo(chars[y,x]);
    paste:=y;
  end;
end;

procedure TEdit2.Plus;
begin
  if ifShift then if x<endX then
  begin                  {���⪠ chars,�᫨ ⮫쪮 ���� �뤥�����}
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
  inherited HandleEvent(Event);
  case Event.What of
    evBroadCast :if Event.Command=cmItemDropped then
                 begin
                   FromMover(Event);
                   Exit; {��室 � �� ��砥,⠪ ��� �������� ��.����}
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
var                                    {������� �����ப� �� ��६�頥����}
  tp:TPoint;                           {���� � chars}
  k:byte;
begin
  if not MouseInView(MouseWhere) then Exit;
  MakeLocal(MouseWhere,tp);
  CleanColor;
  for k:=tp.x to tp.x+PMover(E.InfoPtr)^.len-1 do
    if k<=endX then chars[tp.y,k]:=PMover(E.InfoPtr)^.buffer[k-tp.x];
  paste:=tp.y;
  Draw;
  ClearEvent(E);   {��頥� ᮡ�⨥,�⮡� ���뫮 "���稢����" ��� ����}
end;

procedure TEdit2.PickUpItem(tp:TPoint);
var                                   {����᪨���� �뤥����� ⥪��,�᫨}
  mover:PMover;                       {饫��㫨 ��誮� ����� �뤥������}
  local:TPoint;                       {������,��� �뤥��� �����ப�,�᫨}
  E:TEvent;                           {饫祪 ��䨪�஢�� � "��⮬" ����}
  buffer:TBuffer;
  k,start,finish:byte;
begin
  MakeLocal(tp,local);
  if Hi(chars[local.y,local.x])<>syvM then
  begin                                {�᫨ ����⪠ ��楯��� �� ��.⥪��}
    CleanColor;                        {�-०�� �뤥����� ⥪�� ��誮�}
    repeat
      MakeLocal(MouseWhere,tp);
      if local.y<>tp.y then Continue;
      chars[tp.y,tp.x]:=syv+Lo(chars[tp.y,tp.x]);
      paste:=tp.y;
      WriteLine(0,tp.y,Size.X,1,chars[tp.y]);
    until  not MouseEvent(E,evMouseMove+evMouseAuto);
    Exit;
  end;                                 {�᫨ ⥪�� �뤥���-०�� ���஢��}
  start:=0;finish:=0;
  for k:=0 to High(buffer) do buffer[k]:=sym32;
  for k:=oldX to endX do                    {��宦����� ��砫� �뤥�����}
    if Hi(chars[paste,k])=syvM then
    begin
      start:=k;
      Break;
     end;
  for k:=endX downto oldX do                {��宦����� ���� �뤥�����}
    if Hi(chars[paste,k])=syvM then
    begin
      finish:=k;
      Break;
    end;
  for k:=start to finish+1 do                       {���������� ����}
    buffer[k-start]:=chars[paste,k];
  mover:=New(PMover,Init(local,buffer,finish-start+1));
  DeskTop^.Insert(Mover);
  repeat
    Mover^.MoveTo(MouseWhere.x,mouseWhere.Y-1);     {横� ����᪨�����}
  until not MouseEvent(E, evMouseMove);
  Message(DeskTop,evBroadCast,cmItemDropped,Mover);
  Dispose(Mover,Done);
end;
end.
