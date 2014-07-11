{$O-}
unit M;             //  Дата создания: Май 2002
                       //  Дата подключения к TurboTest 6.0  : 01.11.02.
interface

uses Windows,WinApp,Messages,SysUtils,WinCtrl,CommCtrl;

type
  TMyMDI= class(TMDIWindow)
  protected
    procedure DoSize(Wparam,LParam:DWORD);override;
    function DoCommand(Wparam,LParam:DWORD):DWORD;override;
  public
    StatusBar:TStatusBar;                //  строка состояния
    ToolBar:TToolBar;
    HStatusBar:integer;                  //  высота строки состояния
    constructor Create(AParent:TWin);reintroduce;
    destructor Destroy;override;
  end;

implementation

constructor TMyMDI.Create;
var
  R:TRect;w:hwnd;m:HDC;
begin
  inherited Create(WS_OVERLAPPEDWINDOW,0,0,0,
            GetSystemMetrics(SM_CXSCREEN),GetSystemMetrics(SM_CYSCREEN)-260,
            AParent,nil,'MainWindow');
  HAccl:=LoadAccelerators(0,PChar(1));
  StatusBar:=TStatusBar.Create(Self);
  ToolBar:=TToolBar.Create(Self);
  GetWindowRect(StatusBar.Handle,R);
  HStatusBar:=R.Bottom-R.Top;
//  with TMDIChild.Create(Self,Client) do Show
end;


destructor TMyMDI.Destroy;
begin
  StatusBar.Free;
  inherited;
end;

function TMyMDI.DoCommand(Wparam, LParam: DWORD): DWORD;
begin
   Result:=inherited DoCommand(WParam,lParam)
end;

procedure TMyMDI.DoSize(Wparam, LParam: DWORD);
begin
  if StatusBar<>nil then StatusBar.WMSize(WParam,LParam);
end;


end.

