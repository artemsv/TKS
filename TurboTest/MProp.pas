{$O-}
unit MProp;

interface

uses Windows,WinDlg,Streams;

type
  TPropDlg=class(TDialog)
  private
    Header:THeader;
  protected
    function InitDialog(Dlg:HWND;Param:DWORD):boolean;override;
    function CtlColorStatic(WParam,LParam:DWORD):DWORD;override;
    function CtlColorDlg(WParam,LParam:DWORD):DWORD;override;
  public
    function DlgProc(Dlg:HWND;Msg,Wparam,LParam:DWORD):DWORD;override;
  end;

implementation

uses MConst, Messages, WinFunc, SysUtils, WinCtrl;
{$R RES\prop.res}
{ TPropDlg }

function TPropDlg.CtlColorDlg(WParam, LParam: DWORD): DWORD;
begin
  Result:=CreateSolidBrush(COLOR_SELTEMA_DLG);
end;

function TPropDlg.CtlColorStatic(WParam, LParam: DWORD): DWORD;
begin
  SetBkMode(WParam,TRANSPARENT);
  SetTextColor(Wparam,$0000);  
  Result:=CreateSolidBrush(COLOR_SELTEMA_STATIC);
end;

function TPropDlg.DlgProc(Dlg: HWND; Msg, Wparam, LParam: DWORD): DWORD;
var
  buf:array [0..1024] of char;
begin
  Result:=0;
  case Msg of
    WM_COMMAND:
      case LOWORD(Wparam) of
        ID_OK:
          begin
            if GetFocus=GetDlgItem(Dlg,18) then exit;
            GetDlgItemText(Dlg,18,@buf,255);
            StrDispose(Header.Comment);
            Header.Comment:=StrNew(buf);
            EndDialog(Dlg,ID_OK);
          end;
        ID_CANCEL:EndDialog(Dlg,ID_CANCEL);
      end;
  else
    Result:=inherited DlgProc(Dlg,Msg,WParam,LParam);
  end;
end;

function TPropDlg.InitDialog(Dlg: HWND; Param: DWORD): boolean;
begin
  Header:=THeader(Param);
  CenterWindow(Dlg);
  SetDlgItemText(Dlg,11,Header.tema);
  SetDlgItemText(Dlg,12,Header.FName);
  SetDlgItemInt(Dlg,13,Header.ckolko,false);
  SetDlgItemInt(Dlg,14,Header.nn,false);
  SetDlgItemInt(Dlg,15,Header.d,false);
  SetDlgItemText(Dlg,16,Header.DateCreate);
  SetDlgItemText(Dlg,17,Header.DateModified);
  SetDlgItemText(Dlg,18,Header.Comment);
  Result:=inherited InitDialog(Dlg,Param);
end;

end.


