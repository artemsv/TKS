{$O-}
unit MSelTema;                               //  дата создания: 03.02.03

interface

uses
  WinApp;

function GetTemaFile(AParent:TWindow;AInvite:string;var st1,st2:string):boolean;

implementation

uses
  Windows,SysUtils, Classes, WinDlg, Streams, Messages, WinFunc, MConst;

var
  tema,fileName,invite:string;
  st1:array[0..40] of char;

type
  TTemaDlg=class(TDialog)
  private
    ListBox:HWND;
    Files:TStringList;
  protected
    function InitDialog(Dlg:HWND;Param:DWORD):boolean;override;
    function CtlColorStatic(WParam,LParam:DWORD):DWORD;override;
    function CtlColorDlg(WParam,LParam:DWORD):DWORD;override;
    function CtlColorListBox(WParam,LParam:DWORD):DWORD;override;
  public
    function DlgProc(Dlg:HWND;Msg,Wparam,LParam:DWORD):DWORD;override;
  end;

{$R RES\SelTema.Res}

function GetTemaFile(AParent:TWindow;AInvite:string;var st1,st2:string):boolean;
var
  TD:TTemaDlg;
begin
  Result:=false;
  invite:=AInvite;
  TD:= TTemaDlg.Create(AParent,10,0);
  if TD.ShowModal<>ID_OK then Exit;
  st1:=tema;st2:=fileName;
  TD.Free;
  Result:=true;
end;

{ TTemaDlg }

function TTemaDlg.CtlColorDlg(WParam, LParam: DWORD): DWORD;
begin
  Result:=CreateSolidBrush(COLOR_SELTEMA_DLG);
end;

function TTemaDlg.CtlColorListBox(WParam, LParam: DWORD): DWORD;
begin
  SetTextColor(Wparam,$000000);
  SetBkMode(WParam,TRANSPARENT);
  Result:=CreateSolidBrush(COLOR_SELTEMA_LST);
end;

function TTemaDlg.CtlColorStatic(WParam, LParam: DWORD): DWORD;
begin
  SetBkMode(WParam,TRANSPARENT);
  SetTextColor(Wparam,$FF0000);
  Result:=CreateSolidBrush(COLOR_SELTEMA_STATIC);
end;

function TTemaDlg.DlgProc(Dlg: HWND; Msg, Wparam, LParam: DWORD): DWORD;
var
  k:integer;
begin
  Result:=0;
  case Msg of
    WM_COMMAND:
      case LOWORD(WParam) of
        101:if HIWORD(Wparam) = LBN_DBLCLK then
          begin
            k:=SendMessage(ListBox,LB_GETCURSEL,0,0);     //  номер текущей
            SendMessage(ListBox,LB_GETTEXT,k,DWORD(@st1));// получаем строку
            fileName:=Files[k];
            tema:=st1;
            EndDialog(Dlg,ID_OK);
          end;
        ID_OK:
          begin
            k:=SendMessage(ListBox,LB_GETCURSEL,0,0);     //  номер текущей
            SendMessage(ListBox,LB_GETTEXT,k,DWORD(@st1));// получаем строку
            fileName:=Files[k];
            tema:=st1;
            EndDialog(Dlg,ID_OK);
          end;
        ID_CANCEL:
          EndDialog(Dlg,ID_CANCEL);
      end;
  else
    Result:=inherited DlgProc(Dlg,Msg,WParam,LParam);
  end;
end;

function TTemaDlg.InitDialog(Dlg: HWND;Param:DWORD): boolean;
var
  TS:TSearchRec;
  TF:TTestFile;
  TH:THeader;
begin
  CenterWindow(Dlg);
  SetWindowText(GetDlgItem(Dlg,102),PChar(invite));
  Files:=TStringList.Create;
  ListBox:=GetDlgItem(Dlg,101);
  if FindFirst('*.tem',faAnyFile,TS) = 0 then
  begin
      try
        TF:=TTestFile.Create(TS.Name);
        TH:=TF.GetHeader;
        SendMessage(ListBox,LB_ADDSTRING,0,DWORD(PChar(TH.tema)));
        Files.Add(TS.Name);
        TH.Free;
        TF.Free;
      except
        On E:Exception do
        begin
          MessageBox(0,PChar(E.Message),'Turbo Test - Ошибка',$10);
        end;
      end;
    while FindNext(TS) = 0 do
    begin
      try
        TF:=TTestFile.Create(TS.Name);
        TH:=TF.GetHeader;
      except
        On E:Exception do
        begin
          MessageBox(0,PChar(E.Message),'Turbo Test - Ошибка',$10);
          Continue;
        end;
      end;
      SendMessage(ListBox,LB_ADDSTRING,0,DWORD(PChar(TH.tema)));
      Files.Add(TS.Name);
      TH.Free;
      TF.Free;
    end;
  end;
  FindClose(TS);
  Windows.SetFocus(ListBox);
  SendMessage(ListBox,LB_SETCURSEL,0,0);
  Result:=inherited InitDialog(Dlg,Param);
end;

end.
