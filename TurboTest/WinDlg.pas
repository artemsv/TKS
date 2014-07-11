{$O-}
unit WinDlg;                     //  Дата создания: 22.10.02.

interface

uses WinApp,Windows,Messages;

type
  TDialog=class(TWin)         //  класс-прототип модального диалогового окна
  private
    FParent:TWindow;          //  указатель на родительское окно
    FResID:word;              //  идентификатор ресурса в файле
    FParam:DWORD;             //  дополнительный параметр
    FTemplate:DlgTemplate;
  protected
    function InitDialog(Dlg:HWND;Param:DWORD):boolean;virtual; // обработка WM_INITDIALOG
    function DlgProc(Dlg:HWND;Msg,Wparam,LParam:DWORD):DWORD;virtual;
    procedure DoPaint;virtual;
    function CtlColorDlg(WParam,LParam:DWORD):DWORD;virtual;
    function CtlColorStatic(WParam,LParam:DWORD):DWORD;virtual;
    function CtlColorListBox(WParam,LParam:DWORD):DWORD;virtual;
  public
    constructor Create(AParent:TWindow;AResID:word;AParam:DWORD);virtual;
    constructor CreateIndirect(AParent:TWindow;ATemplate:DlgTemplate;AParam:DWORD);virtual;
    destructor Destroy;override;
    function ShowModal:DWORD;
    property Parent:TWindow read FParent;
    property Param:DWORD read FParam;
  end;

implementation

function DialogProc(Dlg:HWND;Msg,WParam,LParam:DWORD):DWORD;stdcall;
var
  Dialog:TDialog;
begin
  if Msg=WM_INITDIALOG then
  begin
    SetWindowLong(Dlg,GWL_USERDATA,LParam);  //  прячем указатель Self
    if LParam<>0 then
      if not TDialog(LParam).InitDialog(Dlg,TDialog(LParam).FParam) then
      begin
        EndDialog(Dlg,0);
        TDialog(LParam).Free;
        SetWindowLong(Dlg,GWL_USERDATA,0);  //!!!
        Exit;
      end;
    Result:=0;
  end
  else begin
    Dialog:=TDialog(GetWindowLong(Dlg, GWL_USERDATA));  //  извлекаем указатель
    if Dialog=nil then Result:=0 else
    Result:=Dialog.DlgProc(Dlg,Msg,WParam,LParam); //  вызов диал.процедуры
  end;
end;

{ TDialog }

constructor TDialog.Create(AParent: TWindow; AResID: word;AParam:DWORD);
begin
  FParent:=AParent;
  FResID:=AResID;
  FParam:=AParam;
end;

function TDialog.ShowModal: DWORD;
begin
  if FResID=0 then
  Result:=DialogBoxIndirectParam(MainInstance,FTemplate,FParent.Handle,
        @DialogProc,DWORD(Self))
  else
  Result:=DialogBoxParam(MainInstance,PChar(FResID),FParent.Handle,
        @DialogProc,DWORD(Self))
end;

function TDialog.DlgProc(Dlg: HWND; Msg, Wparam, LParam: DWORD): DWORD;
begin
  Result:=0;
  case Msg of
    WM_COMMAND:;
    WM_CTLCOLORSTATIC:Result:=CtlColorStatic(WParam,LParam);
    WM_CTLCOLORDLG:Result:=CtlColorDlg(WParam,LParam);
    WM_CTLCOLORLISTBOX:Result:=CtlColorListBox(WParam,LParam);
    WM_PAINT:DoPaint;
  end;
end;

function TDialog.InitDialog(Dlg:HWND;Param:DWORD):boolean;
begin
  Handle:=Dlg;
  Result:=true;
end;

procedure TDialog.DoPaint;
begin
end;

function TDialog.CtlColorDlg(WParam, LParam: DWORD): DWORD;
begin
  Result:=0;
end;

function TDialog.CtlColorListBox(WParam, LParam: DWORD): DWORD;
begin
  Result:=0;
end;

function TDialog.CtlColorStatic(WParam, LParam: DWORD): DWORD;
begin
  Result:=0;
end;

destructor TDialog.Destroy;
begin
end;

constructor TDialog.CreateIndirect(AParent: TWindow;ATemplate:DlgTemplate;AParam:DWORD);
begin
  FParent:=AParent;
  FResID:=0;
  FTemplate:=ATemplate;
  FParam:=AParam;
end;

end.
