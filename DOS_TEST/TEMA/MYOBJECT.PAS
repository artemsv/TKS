unit MyObject;                            {дата создания модуля: 09.10.01}

interface

uses Views,Objects,Drivers,Types,Dialogs,MyLib,MsgBox;

type                                    {прокрутчик-использ.в окне справки}
  PInterior = ^TInterior;
  TInterior = object(TScroller)
    cColl:PCollection;
    constructor Init(var R: TRect; H,V: PScrollBar;aColl:PCollection);
    procedure Draw; virtual;
  end;

type                                     {окно просмотра файлов}
  PWatchWindow = ^TWatchWindow;
  TWatchWindow = object(TWindow)
    function GetPalette:PPalette;virtual;
    procedure HandleEvent(var Event:TEvent);virtual;
    constructor Init(R:TRect;fName:st12;c:PCollection);
  end;

type                                            {объект-контролер кучи}
  PHeapView=^THeapView;
  THeapView=object(TStaticText)
   constructor Init(var R:TRect);
   procedure UpDate;
  end;

type                                            {окно выбора тем}
  PMyDialog=^TMyDialog;
  TMyDialog=object(TDialog)
    procedure HandleEvent(VAR Event:TEvent);Virtual;
  end;

implementation
                                                { TInterior }
constructor TInterior.Init;
begin
  TScroller.Init(R,H,V);cColl:=aColl;
  GrowMode := gfGrowHiX + gfGrowHiY;
  Options := Options or ofFramed;
  SetLimit(128, cColl^.count);
end;

procedure TInterior.Draw;
var
  color : byte;
  s     : string;
  k     : integer;
  B     : TDrawBuffer;
begin
  color := GetColor(1);
  for k := 0 to Pred(Size.Y) do
  begin
    MoveChar(B, ' ', color, Size.X);
    if (k+Delta.Y<cColl^.count) and (cColl^.At(k+Delta.Y)<>nil) then
      begin
        s:=PString(cColl^.At(k+Delta.Y))^;
        MoveStr(B,Copy(s,Delta.X+1,Length(s)-Delta.X),color)
      end;
    WriteLine(0,k,Size.X,1,B);
  end;
end;

constructor TWatchWindow.Init;
var
  HScrollBar, VScrollBar: PScrollBar;
  Interior:PInterior;
begin
  TWindow.Init(R,'Справка', wnNoNumber);
  VScrollBar := StandardScrollBar(sbVertical + sbHandleKeyboard);
  HScrollBar := StandardScrollBar(sbHorizontal + sbHandleKeyboard);
  GetExtent(R);R.Grow(-1,-1);
  Interior:=New(PInterior, Init(R, HScrollBar, VScrollBar,c));
  Insert(Interior);
end;

procedure TWatchWindow.HandleEvent;
begin
  if (Event.What=evCommand) and (Event.Command=cmClose) then
     EndModal(Event.Command);
  if (Event.What=evKeyDown) and (Event.KeyCode=kbEsc) then
  begin Event.Command:=cmClose;EndModal(Event.Command);end;
  inherited HandleEvent(Event);
end;

function TWatchWindow.GetPalette;
const
  newPalette:string[8]=cGrayWindow;
begin
  GetPalette:=@newPalette
end;
                                                { THeapView }
constructor THeapView.Init;
var
  s:string;
begin
  Str(MemAvail,s);
  Inherited Init(R,#3+s+Sstr(mem[0:$417]));
end;

procedure THeapView.UpDate;
var
  s:string;
begin
  Str(MemAvail,s);
  DisposeStr(text);
  text:=NewStr(#3+s);
  Draw;
end;
                                                { TMyDialog }

procedure TMyDialog.HandleEvent(var Event:TEvent);
begin
  if (Event.What = evMouseDown) and (Event.Double) then
  begin
    Event.What := evCommand;
    Event.Command := cmOK;
    PutEvent(Event);
    ClearEvent(Event);
  end;
  Inherited HandleEvent(Event);
end;
end.