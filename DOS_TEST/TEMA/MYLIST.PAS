unit MyList;                    {дата создания модуля  7.11.01}

interface

uses Drivers,Views,Objects,Types,MyFunc,MsgBoxMy,Mred;

type
  PListWin=^TListWin;
  TlistWin=object(TWindow)
    constructor Init(n:byte);
  end;

  PListBlocks=^TListBlocks;
  TListBlocks=object(TEditor)
    constructor Init(var R:TRect;h:THeader);
    procedure HandleEvent(Var Event:TEvent);virtual;
  end;

implementation

constructor TListWin.Init;
var
  h:THeader;
  cCol:PCollection;
  st:string;
  k:integer;
  f:tfc;
  R:TRect;
  PList:PListBlocks;
begin
  if n=2 then
  begin
    cCol:=GetFilesList('tema_bak.*');
    if cCol=nil then
    begin
      MessageBox(#3'Нет BAK-файлов!',nil,mfOkButton);
      Fail;
    end;
    if ListDialog(cCol,'Выберите',st,k,6)=cmCancel then Fail;
    h.fName:=st;
    if not ReadHeader(h) then Fail
  end
  else
  if SelectTema(h)=cmCancel then Fail;
  R.Assign(0,0,80,23);
  TWindow.Init(R,'Просмотр',0);
  GetClipRect(R);
  R.Grow(-1,-1);
  PList:=New(PListBlocks,Init(R,h));
  if PList=nil then Fail;
  Insert(PList);
end;

constructor TListBlocks.Init;
begin                          {в данном случае это режим листания,который }
  inherited Init(R,h,nil);     {не подразумевает обработку каких-либо собы-}
  list:=true;                  {тий кроме нажатия на PageUp,PageDown,AltR  }
  HideCursor;                  {*******}
end;

procedure TListBlocks.HandleEvent;
begin
  if Event.What=evKeyDown then
  case Event.KeyCode of
    kbPgUp,kbPgDn,kbAltR:inherited HandleEvent(Event);
  end;
  if Event.What=evCommand  then
   if (Event.Command=cmQuit) or (Event.Command=cmClose) then
     inherited HandleEvent(Event);
end;
end.