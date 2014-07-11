{$O-}
              //  "Уникальная" библиотека оконных классов Win32  -  WinApp 1.0
unit WinApp;                     //  Дата создания: Май-Июнь 2002
                                 //  05.10.02.-инкапсуляция MDIClient'a !!!
interface

uses Windows,Messages,WinFunc,WinMenu,Contnrs;

type
  TWin=class(TInterfacedObject)
  private
    FParent:TWin;                     //  владелец
    FLeft,FTop,FRight,FBottom,FWidth,FHeight:integer;
    FCaption:string;                  //  заголовок окна
    FWins:TObjectList;                //  список всех принадлежащих объектов
    function GetBoundsRect: TRect;
    function GetClientHeight: Integer;
    function GetClientWidth: Integer;
    procedure SetBoundsRect(const Rect: TRect);
    procedure SetClientHeight(Value: Integer);
    procedure SetClientSize(Value: TPoint);
    procedure SetClientWidth(Value: Integer);
    procedure SetHeight(const Value: Integer);
    procedure SetTop(const Value: Integer);
    procedure SetLeft(ALeft:integer);
    procedure SetWidth(const Value: Integer);
    function GetClientOrigin: TPoint;
    function GetClientRect: TRect;
    procedure SetCaption(const Value: string);
  protected
    function WndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;virtual;
    function ElseWndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;virtual;
    function RegClass(lpszClass:PChar):boolean;virtual;
    function GetClassName:PChar;virtual;
    function GetHandle(AExStyle:DWORD;AClassName,AName:PChar;AStyle:DWORD;
             x,y,cX,cY:integer;Wnd:HWND;AMenu:HMENU;MainInstance:DWORD;
              LParam:Pointer):HWND;virtual;
    procedure GetWndClassEx(var WC:TWndClassEx);virtual;
    procedure Initial;virtual;              //  вызывается из конструктора
  public
    OldProc:Pointer;             //  указатель на стандартный обработчик
    Handle:HWND;                            //  дескриптор самого окна
    constructor Create(AStyle,AExStyle:DWORD;x,y,cX,cY:integer;AParent:TWin;
      AName:PChar;AClassName:PChar=nil;AMenu:HMENU=0;LParam:Pointer=nil);virtual;
    destructor Destroy;override;            //  уничтожает окно
    procedure Insert(Win:TWin);             //  добавить объект в список
    procedure Remove(Win:TWin);             //  удалить объект из списка
    function Perform(Msg: Cardinal; WParam, LParam: Longint): Longint;
    procedure Hide;
    procedure Show(cmdShow:DWORD=SW_NORMAl);
    procedure SetFocus;                     //  уст.фокус на объект
    procedure Invalidate;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); virtual;
    function ScreenToClient(const Point: TPoint): TPoint;
    property Parent:TWin read FParent write FParent;
    property BoundsRect: TRect read GetBoundsRect write SetBoundsRect;
    property ClientHeight: Integer read GetClientHeight write SetClientHeight stored False;
    property ClientOrigin: TPoint read GetClientOrigin;
    property ClientRect: TRect read GetClientRect;
    property ClientWidth: Integer read GetClientWidth write SetClientWidth stored False;
    property Left: Integer read FLeft write SetLeft;
    property Top: Integer read FTop write SetTop;
    property Width: Integer read FWidth write SetWidth;
    property Height: Integer read FHeight write SetHeight;
    property Caption:string read FCaption write SetCaption;
    property Wins:TObjectList read FWins;
  end;

  TWindow=class(TWin)
  public
    HAccl:HAccel;                        //  таблица акселераторов
    ModalResult:integer;
    procedure UpdateWindow;
    function Run:WParam;virtual;         //  цикл приема и обработки событий
    function CloseQuery:boolean;virtual; //  запрос на закрытие окна
    function ShowModal:integer;          //  показать в модальном виде
    procedure Close;virtual;             //  закрыть окно
    function ProcessMessage:boolean;virtual;
    procedure HandleMessage;
    procedure SetMainMenu(MainMenu:TMainMenu);
    destructor Destroy; override;
  protected
    FTerminated:boolean;
    ifModal:boolean;
    function DoCommand(Wparam,LParam:DWORD):DWORD;virtual;
    procedure DoSize(Wparam,LParam:DWORD);virtual;
    procedure DoDestroy;virtual;
    procedure DoKeyDown(Wparam,LParam:DWORD);virtual;
    procedure DoMouseMove(Wparam,LParam:DWORD);virtual;
    procedure DoLDown(Wparam,LParam:DWORD);virtual;
    procedure DoChar(Wparam,LParam:DWORD);virtual;
    procedure DoTimer(Wparam,LParam:DWORD);virtual;
    procedure DoNotify(Wparam,LParam:DWORD);virtual;
    procedure DoSetFocus(WParam:DWORD);virtual;
    procedure DoKillFocus(WParam:DWORD);virtual;
    function WndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
    function ElseWndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
    procedure GetWndClassEx(var WC:TWndClassEx);override;
    procedure Initial;override;
  end;

{  Класс клиентского окна MDI }

  TMDIChild = class;

  TMDIClient=class(TWin)
  private
    FChildren:TObjectList;                                //  список дочерних окон
  protected
    function DoEraseBkgnd(DC:HDC):integer;virtual;
    function DoXScroll(Msg,WParam,LParam:DWORD):integer;
    function WndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
  public
    constructor Create(Aparent:TWindow);reintroduce;
    procedure WMSize(Wparam,LParam:DWORD);
    function CreateChild(MC:MDICREATESTRUCT):HWND;
    procedure Activate(num:integer);        //  активизировать окно номер
    function GetActiveWnd:HWND;             //  вернуть дескриптор активного
    function GetActiveChild:TMDIChild;      //  вернуть активное окно
    function SendActive(Msg,WParam,LParam:DWORD):DWORD;  //  посылка активному
    procedure SendToAll(Msg,WParam,LParam:DWORD);
    procedure DestroyChild(Child:HWND);
    procedure MinimizeActive;
    procedure RestoreActive;
    procedure Cascade;                      //  каскадировать окна
    procedure Tile(TileFlag:DWORD);         //  расположить черепицей
    property Children:TObjectList read FChildren;  // список дочерних окон
  end;

  TChildClass=class of TMDIChild;

{  Класс Рамочного окна MDI }

  TMDIWindow=class(TWindow)
  private
    OldClientProc:DWORD;               //  старая клиентская процедура
  protected
    Client:TMDIClient;                 //  клиентское окна
    procedure DoSize(WParam,LParam:DWORD);override;
    function GetClient:TMDIClient;virtual;
    function CloseQuery:boolean;override;
  public
    constructor Create(AStyle,AExStyle:DWORD;x,y,cX,cY:integer;AParent:TWin;
      AName,AClassName:PChar;AMenu:HMENU=0;LParam:Pointer=nil);override;
    function ElseWndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
    procedure CreateChild(InstanceClass:TChildClass;var Reference);
    destructor Destroy;override;
    function Run:WParam;override;
    function ProcessMessage:boolean;override;
    procedure SetWindowMenu(MenuItem:TMenu);
    procedure RefreshWindowMenu;
  end;

{  Класс дочернего окна MDI }

  TMDIChild=class(TWindow)
  public
    Client:TMDIClient;                //  клиентское окна
    constructor Create(AParent:TMDIWindow;AClient:TMDIClient);reintroduce;virtual;
    destructor Destroy;override;
    procedure Close;override;
  protected
    function ElseWndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
    procedure GetWndClassEx(var WC:TWndClassEx);override;
    procedure GetMDIStruct(var Mdic:MDICREATESTRUCT);virtual;
    procedure DoSize(Wparam,LParam:DWORD);override;
  end;
                                       
{ Task window management }

type
  PTaskWindow = ^TTaskWindow;
  TTaskWindow = record
    Next: PTaskWindow;
    Window: HWnd;
  end;

var
  TaskActiveWindow: HWnd = 0;
  TaskFirstWindow: HWnd = 0;
  TaskFirstTopMost: HWnd = 0;
  TaskWindowList: PTaskWindow = nil;

var
  MainWindow:TWindow;                //  главное окно приложения

const
  MDI_CHILD_FIRST                =   40000;      //  первое дочернее окно

function StdWndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;stdcall;

implementation

uses SysUtils;

//  Импорт из FORMS.PAS с разрешения Borland Corporation  ;)

procedure EnableTaskWindows(WindowList: Pointer);
var
  P: PTaskWindow;
begin
  while WindowList <> nil do
  begin
    P := WindowList;
    if IsWindow(P^.Window) then EnableWindow(P^.Window, True);
    WindowList := P^.Next;
    Dispose(P);
  end;
end;                   

function DoDisableWindow(Window: HWnd; Data: Longint): Bool; stdcall;
var
  P: PTaskWindow;
begin
  if (Window <> TaskActiveWindow) and IsWindowVisible(Window) and
    IsWindowEnabled(Window) then
  begin
    New(P);
    P^.Next := TaskWindowList;
    P^.Window := Window;
    TaskWindowList := P;
    EnableWindow(Window, False);
  end;
  Result := True;
end;

function DisableTaskWindows(ActiveWindow: HWnd): Pointer;
var
  SaveActiveWindow: HWND;
  SaveWindowList: Pointer;
begin
  Result := nil;
  SaveActiveWindow := TaskActiveWindow;
  SaveWindowList := TaskWindowList;
  TaskActiveWindow := ActiveWindow;
  TaskWindowList := nil;
  try
    try
      EnumThreadWindows(GetCurrentThreadID, @DoDisableWindow, 0);
      Result := TaskWindowList;
    except
      EnableTaskWindows(TaskWindowList);
      raise;
    end;
  finally
    TaskWindowList := SaveWindowList;
    TaskActiveWindow := SaveActiveWindow;
  end;
end;

         //  Стандартная оконная функция .Вызывается из Windows

function StdWndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;stdcall;
var
  Win:TWin;                      //  указатель на окно,адресат сообщения
  p:Pointer;
begin
  Result:=0;
  Win:=nil;
  if Msg =WM_NCCREATE then          //  "Выковыриваем" Self и прячем его
  begin                             //         в USERDATA
    p:=Pointer(Lparam);
    p:= Pointer(P^);
    P:=Pointer(PMdiCreateStruct(P)^.Lparam);
    SetWindowLong(Wnd,GWL_USERDATA,Longint(p));
  end
  else                              //  получаем Self из USERDATA
    Win:=TWin(GetWindowLong(Wnd, GWL_USERDATA));
  try
    if Win<>nil
      then Result:=Win.WndProc(Wnd,Msg,WParam,LParam)
      else Result:=DefWindowProc(Wnd,Msg,WParam,LParam);
  except
    on E:Exception do begin
      MessageBox(0,PChar(E.Message+#13+#13+
      'Приложение будет завершено.'),'Ошибка',MB_ICONERROR);
      Halt;
    end;
  end;
end;

{ TWin }                     //  Предок всех визуальных классов

constructor TWin.Create(AStyle, AExStyle: DWORD; x, y, cX, cY: integer;
  AParent: TWin; AName, AClassName: PChar; AMenu: HMENU;LParam:Pointer);
var
  Mdic:MDICREATESTRUCT;
  Wnd:HWND;
  WP:TWindowPlacement;
begin
  TObject.Create;
  if AClassname=nil then AClassName:=GetClassName;
  if not RegClass(AClassName) then Fail;
  if LParam=nil then
  begin
    ZeroMemory(@Mdic,SizeOf(Mdic));
    mdic.lParam:=DWORD(Self);                //  Прячем указатель!!!
    LParam:=@mdic
  end;
  if AParent=nil then Wnd:=0 else Wnd:=AParent.Handle;
  FParent:=AParent;
  Handle:=GetHandle(AExStyle,AClassName,AName,AStyle,x,y,cX,cY,
                         Wnd,AMenu,MainInstance,LParam);
  WP.length:=SizeOf(WP);
  GetWindowPlacement(Handle,@Wp);
  FLeft:=WP.rcNormalPosition.Left;
  FTop:=WP.rcNormalPosition.Top;
  FRight:=WP.rcNormalPosition.Right;
  FBottom:=WP.rcNormalPosition.Bottom;
  FWidth:=FRight-FLeft;
  FHeight:=FBottom-FTop;
  Initial;
  FWins:=TObjectList.Create;
  SendMessage(Handle,WM_SETFONT,GetStockObject(DEFAULT_GUI_FONT),0);
end;

destructor TWin.Destroy;
var
  k:integer;
begin
  for k:=0 to FWins.Count-1 do
    TWin(FWins[k]).Destroy;
  if Handle<>0 then DestroyWindow(Handle);
  SetWindowLong(Handle,GWL_USERDATA,0);     //  обнуляем указатель Self
end;

function TWin.ElseWndProc(Wnd: HWND; Msg, WParam, LParam: DWORD): DWORD;
begin
  Result:=DefWindowProc(Wnd,Msg,Wparam,LParam);
end;

function TWin.GetBoundsRect: TRect;
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Right := Left + Width;
  Result.Bottom := Top + Height;
end;

function TWin.GetClassName: PChar;
begin
  Result:='TWin';
end;

function TWin.GetClientHeight: Integer;
begin
  Result := ClientRect.Bottom;
end;

function TWin.GetClientOrigin: TPoint;
begin end;

function TWin.GetClientRect: TRect;
begin end;

function TWin.GetClientWidth: Integer;
begin
  Result := ClientRect.Right;
end;


function TWin.GetHandle(AExStyle: DWORD; AClassName, AName: PChar;
  AStyle: DWORD; x, y, cX, cY: integer; Wnd: HWND; AMenu: HMENU;
  MainInstance: DWORD; LParam: Pointer): HWND;
begin
  Result:=CreateWindowEx(AExStyle,AClassName,AName,AStyle,x,y,cX,cY,Wnd,AMenu,
                   MainInstance,LParam)
end;

procedure TWin.GetWndClassEx(var WC: TWndClassEx);
begin
  ZeroMemory (@WC,SizeOf (WC));
  with WC do
  begin
    cbSize:=SizeOf(WC);
    cbWndExtra:=12;
    style:=CS_HREDRAW+CS_VREDRAW;
    lpfnWndProc:=TFNWndProc (@StdWndProc);
    hIcon:=0;
    hCursor:=LoadCursor (0,PChar (IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
  end;
end;

procedure TWin.Hide;
begin
  ShowWindow(Handle,SW_HIDE);
end;

procedure TWin.Initial;
begin
end;

procedure TWin.Insert(Win: TWin);
begin
  FWins.Add(Win);
end;

procedure TWin.Invalidate;
var
  R:TRect;
begin
  GetWindowRect(Handle,R);
  InvalidateRect(Handle,@R,true);
end;

function TWin.Perform(Msg: Cardinal; WParam, LParam: Integer): Longint;
begin
  Result:=SendMessage(Handle,Msg,WParam,LParam)
end;

function TWin.RegClass(lpszClass: PChar): boolean;
var
  WC:TWndClassEx;
begin
  Result:=false;
  if not GetClassInfoEx(MainInstance,lpszClass,WC) then
  begin                                           //такого класса нет
    GetWndClassEx(wc);		                  // fill class attributes
    wc.hInstance:= MainInstance;
    wc.lpszClassName:= lpszClass;
    if RegisterClassEx(wc)=0 then Exit;
  end;
  Result:=true;
end;

procedure TWin.Remove(Win: TWin);
begin
  FWins.Remove(Win)
end;

function TWin.ScreenToClient(const Point: TPoint): TPoint;
var
  Origin: TPoint;
begin
  Origin := ClientOrigin;
  Result.X := Point.X - Origin.X;
  Result.Y := Point.Y - Origin.Y;
end;

procedure TWin.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  WindowPlacement:TWindowPlacement;
begin
  SetWindowPos(Handle,0,ALeft,ATop,AWidth,AHeight,SWP_NOZORDER+SWP_NOACTIVATE);
  FLeft := ALeft;
  FTop := ATop;
  FWidth := AWidth;
  FHeight := AHeight;
  WindowPlacement.Length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Handle, @WindowPlacement);
  WindowPlacement.rcNormalPosition := BoundsRect;
  SetWindowPlacement(Handle, @WindowPlacement);
end;

procedure TWin.SetBoundsRect(const Rect: TRect);
begin
  with Rect do
    SetBounds(Left, Top, Right - Left, Bottom - Top);
end;

procedure TWin.SetCaption(const Value: string);
begin
  SetWindowText(Handle,PChar(Value));
end;

procedure TWin.SetClientHeight(Value: Integer);
begin
  SetClientSize(Point(ClientWidth, Value));
end;

procedure TWin.SetClientSize(Value: TPoint);
var
  Client: TRect;
begin
  Client := GetClientRect;
  SetBounds(FLeft, FTop, Width - Client.Right + Value.X, Height - Client.Bottom + Value.Y);
end;

procedure TWin.SetClientWidth(Value: Integer);
begin
  SetClientSize(Point(Value, ClientHeight));
end;

procedure TWin.SetFocus;
begin
  Windows.SetFocus(Handle)
end;

procedure TWin.SetHeight(const Value: Integer);
begin
  FHeight := Value;
  SetBounds(FLeft, FTop, FWidth, FHeight);
end;

procedure TWin.SetLeft(ALeft: integer);
begin
  FLeft:=ALeft;
  SetBounds(FLeft, FTop, FWidth, FHeight);
end;

procedure TWin.SetTop(const Value: Integer);
begin
  FTop := Value;
  SetBounds(FLeft, FTop, FWidth, FHeight);
end;

procedure TWin.SetWidth(const Value: Integer);
begin
  FWidth := Value;
  SetBounds(FLeft, FTop, FWidth, FHeight);
end;

procedure TWin.Show(cmdShow: DWORD);
begin
  ShowWindow(Handle,cmdShow);
end;

function TWin.WndProc(Wnd: HWND; Msg, WParam, LParam: DWORD): DWORD;
begin
  Result:=ElseWndProc(Wnd,Msg,WParam,LParam);
end;

{    TWindow   }

function TWindow.WndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;
begin
  Result:=0;
  case Msg of
    WM_KEYDOWN:DoKeyDown(Wparam,LParam);
    WM_CHAR:DoChar(Wparam,LParam);
    WM_COMMAND:Result:=DoCommand(Wparam,LParam);
    WM_SIZE:DoSize(Wparam,LParam);
  {  WM_DESTROY:
      if Self=MainWindow then PostQuitMessage(0);}
    WM_CLOSE:Close;
    WM_TIMER:DoTimer(Wparam,LParam);
    WM_SETFOCUS:DoSetFocus(WParam);
    WM_KILLFOCUS:DoKillFocus(WParam);
  else
    Result:=ElseWndProc(Wnd,Msg,WParam,LParam);
  end;
end;

procedure TWindow.GetWndClassEx(var WC:TWndClassEx);
begin
  ZeroMemory(@WC,SizeOf(WC));
  with WC do
  begin
    cbSize:=SizeOf(WC);
    cbWndExtra:=12;
//    style:=CS_HREDRAW+CS_VREDRAW;  //  иначе при перерисовке фона-мигает
    lpfnWndProc:=TFNWndProc (@StdWndProc);
    hIcon:=0;
    hCursor:=LoadCursor (0,PChar (IDC_ARROW));
    hbrBackground:=COLOR_WINDOW;
    lpszMenuName:=nil;
  end;
end;

procedure TWindow.UpdateWindow;
begin
  Windows.UpdateWindow(Handle)
end;

function TWindow.Run: WParam;
var
  Msg:TMsg;
begin                                              {TODO : Атавизм}
  HAccl:=LoadAccelerators(0,PChar(1)); //  быстрые клавиши
  while GetMessage(Msg, 0, 0, 0) do
  if (TranslateAccelerator(Handle,HAccl,Msg)=0) then
  begin
    TranslateMessage(Msg);
    DispatchMessage(Msg);
  end
end;

function TWindow.ElseWndProc(Wnd: HWND; Msg, WParam, LParam: DWORD): DWORD;
begin
  Result:=DefWindowProc(Wnd,Msg,WParam,LParam)
end;

procedure TWindow.DoChar(Wparam, LParam: DWORD);
begin
end;

function TWindow.DoCommand(Wparam, LParam: DWORD):DWORD;
begin
end;

procedure TWindow.DoDestroy;
begin
end;

procedure TWindow.DoKeyDown(Wparam, LParam: DWORD);
begin
end;

procedure TWindow.DoLDown(Wparam, LParam: DWORD);
begin
end;

procedure TWindow.DoMouseMove(Wparam, LParam: DWORD);
begin
end;

procedure TWindow.DoNotify(Wparam, LParam: DWORD);
begin
end;

procedure TWindow.DoSize(Wparam, LParam: DWORD);
begin
end;

procedure TWindow.DoTimer(Wparam, LParam: DWORD);
begin
end;

procedure TWindow.DoKillFocus(WParam:DWORD);
begin
end;

procedure TWindow.DoSetFocus(WParam:DWORD);
begin
  ElseWndProc(Handle,WM_SETFOCUS,Wparam,0)
end;

procedure TWindow.Close;
begin
  if not CloseQuery then Exit;
  if ifModal then ModalResult:=1 else
  Free;
end;

function TWindow.ShowModal: integer;
var
  Msg:TMsg;
  ActiveWindow: HWnd;
  WindowList: Pointer;
begin
  ActiveWindow:=GetActiveWindow;
  Show(SW_NORMAL);
  ifModal:=true;                          //  окно модальное
  ModalResult:=0;
  WindowList := DisableTaskWindows(0);
  EnableWindow(Handle,true);
  repeat
    HandleMessage
  until ModalResult<>0;
  EnableTaskWindows(WindowList);
  ifModal:=false;
  SetActiveWindow(ActiveWindow)
end;

function TWindow.CloseQuery: boolean;
begin
  Result:=true;
end;

function TWindow.ProcessMessage:boolean;
var
  Msg:TMsg;
begin
  Result:=false;
  if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then
  begin
    Result:=true;
    if Msg.Message <> WM_QUIT then
    begin
      if (TranslateAccelerator(Handle,HAccl,Msg)=0) then
      begin
        TranslateMessage(Msg);
        DispatchMessage(Msg);
      end
    end
    else
      FTerminated := True;
  end;
end;

procedure TWindow.HandleMessage;
begin
  while ProcessMessage do;
end;

procedure TWindow.Initial;
begin
  inherited;
  ifModal:=false;
end;

procedure TWindow.SetMainMenu(MainMenu: TMainMenu);
begin
  SetMenu(Handle,MainMenu.Handle);
end;

destructor TWindow.Destroy;
begin
  inherited;
  if MainWindow=Self then PostQuitMessage(0);
end;

{ TMDIClient }

function MDIClientProc(Wnd:HWND;Msg,Wparam,LParam:DWORD):DWORD;stdcall;
var
  MDIClient:TMDIClient;
begin
  MDIClient:=TMDIClient(GetWindowLong(Wnd,GWL_USERDATA));
  if MDIClient<>nil then
    Result:=MDIClient.WndProc(MDIClient.Handle,Msg,WParam,LParam) // else
//    Result:=CallWindowProc(Pointer(OldClientProc),Wnd,Msg,WParam,LParam)
end;

procedure TMDIClient.Activate(num: integer);
begin
  Perform(WM_MDIACTIVATE,TMDIChild(Children[num-MDI_CHILD_FIRST]).Handle,0);
end;

procedure TMDIClient.Cascade;
begin
  SendMessage(handle,WM_MDICASCADE,MDITILE_SKIPDISABLED,0);
end;

constructor TMDIClient.Create(Aparent: TWindow);
var
  WR:CLIENTCREATESTRUCT;
begin
  WR.idFirstChild:=MDI_CHILD_FIRST;
  inherited Create(WS_CHILD or WS_VISIBLE or WS_GROUP or WS_TABSTOP or
                   WS_CLIPCHILDREN or WS_HSCROLL or WS_VSCROLL or
                   WS_CLIPSIBLINGS or MDIS_ALLCHILDSTYLES,WS_EX_CLIENTEDGE,
                   0,0,0,0,Aparent,nil,'MDICLIENT',0,@WR);
  SetWindowLong(Handle,GWL_USERDATA,Longint(Self));
  FChildren:=TObjectList.Create;
end;

function TMDIClient.CreateChild(MC: MDICREATESTRUCT): HWND;
begin
  Result:=SendMessage(Handle,WM_MDICREATE,0,longint(@MC));
end;

procedure TMDIClient.DestroyChild(Child: HWND);
begin
  SendMessage(Handle,WM_MDIDESTROY,Child,0);
end;

function TMDIClient.DoEraseBkgnd(DC: HDC): integer;
begin
  CallWindowProc(Pointer(TMDIWindow(Parent).OldClientProc),Handle,
     WM_ERASEBKGND,DC,0);
  Result:=1;
end;

function TMDIClient.DoXScroll(Msg,WParam, LParam: DWORD): integer;
begin
  Result:=CallWindowProc(Pointer(TMDIWindow(Parent).OldClientProc),Handle,
       Msg,Wparam,LParam);
end;

function TMDIClient.GetActiveWnd: HWND;
begin
  Result:=SendMessage(Handle,WM_MDIGETACTIVE,0,0);
end;

function TMDIClient.GetActiveChild: TMDIChild;
begin
  Result:=TMDIChild(GetWindowLong(GetActiveWnd,GWL_USERDATA));
end;

procedure TMDIClient.MinimizeActive;
begin
  SendMessage(Handle,WM_MDIRESTORE,SendMessage(Handle,WM_MDIGETACTIVE,0,0),0);
end;

procedure TMDIClient.RestoreActive;
begin
  SendMessage(Handle,WM_MDIRESTORE,SendMessage(Handle,WM_MDIGETACTIVE,0,0),0);
end;

function TMDIClient.SendActive(Msg,WParam,LParam:DWORD): DWORD;
begin
  Result:=SendMessage(GetActiveWnd,Msg,Wparam,LParam);
end;

procedure TMDIClient.SendToAll(Msg, WParam, LParam: DWORD);
var
  k:integer;
begin
  for k:=FChildren.Count-1 downto 0 do
    SendMessage(TMDIChild(FChildren.Items[k]).Handle,Msg,Wparam,LParam)
end;

procedure TMDIClient.Tile(TileFlag: DWORD);
begin
  SendMessage(Handle,WM_MDITILE,TileFlag,0);
end;

procedure TMDIClient.WMSize(Wparam, LParam: DWORD);
begin
  MoveWindow(Handle,LOWORD(WParam),HIWORD(WParam),LOWORD(LParam),
    HIWORD(LParam),true);
end;

function TMDIClient.WndProc(Wnd: HWND; Msg, WParam, LParam: DWORD): DWORD;
begin
  case Msg of
    WM_ERASEBKGND:Result:=DoEraseBkgnd(WParam);
    WM_VSCROLL, WM_HSCROLL:Result:=DoXScroll(Msg,WParam,LParam)
  else
    Result:=CallWindowProc(Pointer(TMDIWindow(Parent).OldClientProc),Wnd,
      Msg,Wparam,LParam);
  end;
end;

{ TMDIWindow }

function TMDIWindow.CloseQuery: boolean;
var
  k:integer;
begin
  Result:=false;
  if Client<>nil then for k:=0 to Client.FChildren.Count-1 do
    if not TMDIChild(Client.FChildren[k]).CloseQuery then Exit;
  Result:=true;
end;

constructor TMDIWindow.Create(AStyle,AExStyle:DWORD;x,y,cX,cY:integer;
    AParent:TWin;AName,AClassName:PChar;AMenu:HMENU;Lparam:Pointer);
begin
  inherited Create(AStyle,AExStyle,x,y,cx,cy,AParent,Aname,AClassName
    {AMenu, nil});
  Client:= GetClient;
  CLient.Show(SW_MAXIMIZE);
  HAccl:=0;
  oldClientProc:=SetWindowLong(Client.Handle,GWL_WNDPROC,DWORD(@MDIClientProc));
end;

procedure TMDIWindow.CreateChild(InstanceClass: TChildClass; var Reference);
var
  Instance:TMDIChild;
begin
  Instance:=TMDIChild(InstanceClass.NewInstance);
  TMDIChild(Reference):=Instance;
  try
    Instance.Create(Self,Client);
  except
    TMDIChild(Reference):=nil;
    raise
  end;
end;

destructor TMDIWindow.Destroy;
begin
  if Client<>nil then Client.Free;
  inherited;
end;

procedure TMDIWindow.DoSize(WParam, LParam:DWORD);
begin
  if Client<>nil then Client.WMSize(WParam,LParam);
end;

function TMDIWindow.ElseWndProc(Wnd: HWND; Msg, WParam,LParam: DWORD): DWORD;
begin
  if (Client=nil) or (Msg<>WM_SIZE) then
    Result:=DefWindowProc(Wnd,Msg,Wparam,LParam) else
    Result:=DefFrameProc(Wnd,Client.Handle,Msg,WParam,LParam);
end;

function TMDIWindow.GetClient: TMDIClient;
begin
  Result:=TMDIClient.Create (Self);
end;

function TMDIWindow.ProcessMessage: boolean;
var
  Msg:TMsg;
begin
  Result:=false;
  if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then
  begin
    Result:=true;
    if Msg.Message <> WM_QUIT then
    begin
      if (TranslateAccelerator(Handle,HAccl,Msg)=0) and not
          TranslateMDISysAccel(Client.Handle,Msg) then
      begin
        TranslateMessage(Msg);
        DispatchMessage(Msg);
      end
    end
    else
      FTerminated := True;
  end;
end;

procedure TMDIWindow.RefreshWindowMenu;
begin
  SendMessage(Client.Handle,WM_MDIREFRESHMENU,0,0);
  DrawMenuBar(Handle);
end;

function TMDIWindow.Run: WParam;
var
  Msg:TMsg;
begin
  while GetMessage(Msg, 0, 0, 0) do
      if (TranslateAccelerator(Handle,HAccl,Msg)=0) and not
          TranslateMDISysAccel(Client.Handle,Msg) then
      begin
        TranslateMessage(Msg);
        DispatchMessage(Msg);
      end
{
  repeat
    HandleMessage
  until FTerminated;}
end;

procedure TMDIWindow.SetWindowMenu(MenuItem: TMenu);
begin
  Client.Perform(WM_MDISETMENU,0,MenuItem.Handle);
end;

{ TMDIChild }

procedure TMDIChild.Close;
begin
  if not CloseQuery then Exit;
  Client.FChildren.Remove(Self);
end;

constructor TMDIChild.Create(AParent: TMDIWindow;AClient:TMDIClient);
var
  Mdic:MDICREATESTRUCT;
begin
  FParent:=AParent;
  if not RegClass('Child') then Fail;
  GetMDIStruct(Mdic);
  Client:=AClient;
  Handle:=Client.CreateChild(Mdic);
  Client.FChildren.Add(Self);
end;

destructor TMDIChild.Destroy;
begin
  Client.DestroyChild(Handle);
end;

procedure TMDIChild.DoSize(Wparam, LParam: DWORD);
begin
  DefMDIChildProc(Handle,WM_SIZE,WParam,LParam);
end;

function TMDIChild.ElseWndProc(Wnd: HWND; Msg, WParam,LParam: DWORD): DWORD;
begin
  Result:=DefMDIChildProc(Wnd,Msg,WParam,LParam);
end;

procedure TMDIChild.GetMDIStruct(var Mdic: MDICREATESTRUCT);
begin
  ZeroMemory(@Mdic,SizeOf(Mdic));
  Mdic.lParam:=LPARAM(Self);                //  Прячем указатель!!!
  Mdic.szClass:='Child';
  Mdic.szTitle:=nil;
  Mdic.x:=CW_USEDEFAULT;
  Mdic.y:=CW_USEDEFAULT;
  Mdic.cx:=CW_USEDEFAULT;
  Mdic.cy:=CW_USEDEFAULT;
  Mdic.style:=WS_CAPTION or WS_SIZEBOX or WS_SYSMENU
      or WS_MAXIMIZEBOX or WS_MINIMIZEBOX or WS_CLIPSIBLINGS;
  Mdic.hOwner:=HInstance;
end;

procedure TMDIChild.GetWndClassEx(var WC: TWndClassEx);
begin
  ZeroMemory (@WC,SizeOf (WC));
  WC.cbSize:=SizeOf (WC);
  WC.cbWndExtra:=0;
  WC.style:=CS_HREDRAW+CS_VREDRAW;
  WC.lpfnWndProc:=TFNWndProc (@StdWndProc);
  WC.hInstance:=MainInstance;
  WC.hIcon:=0;
  WC.hCursor:=LoadCursor (0,PChar (IDC_ARROW));
  WC.hbrBackground:=GetStockObject (WHITE_BRUSH);
  WC.lpszMenuName:=nil;
  WC.lpszClassName:='Child';
end;
end.


