{$o-}
program WinA;

uses
  Windows,
  WinApp,
  WinCtrl,
  WinMenu,
  Messages,
  M in 'm.pas';
type
  TWind=class(TWindow)
    protected
      function DoCommand(WParam,LParam:DWORD):DWORD;override;
    end;

var
  Window:TWind;
  MainMenu:TMainMenu;
  Btn:TButton;
  mnuFile:TMenuItem;
  popFile:TPopupMenu;
  mnuNew,mnuOld,mnuRed,mnuExit:TMenuItem;
  ListBox:TListBox;
{ TWind }

function TWind.DoCommand(WParam, LParam:DWORD): DWORD;
begin
  if LOWORD(WParam)=346 then
    if HIWORD(WParam)=LBN_DBLCLK then Halt;
  Result:=0;
end;

begin
  MainWindow:=TWindow.Create(WS_OVERLAPPEDWINDOW,WS_EX_CLIENTEDGE,
      100,100,500,200,nil,'Привет, васёк!!!','Win');
  MainWindow.Show();
  MainWindow.Run
end.


