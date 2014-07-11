{$O-}
unit Macro;                         //  Дата создания: Сентябрь 2002

interface

uses Classes,WinApp;

var
  path:string;                      //  глобальная переменная

{$R RES\macro.res}
{$R RES\macronew.res}

function Macrok(AParent:TWindow):boolean;
procedure SaveMacro;

var
  Macroses:TStringList;

implementation

uses Streams,SysUtils,Windows,WinFunc,WinDlg,Messages,MTypes,MConst;

type
  TMacroDlg=class(TDialog)
  private
    ListBox:HWND;
  protected
    function InitDialog(Dlg:HWND;Param:DWORD):boolean;override;
    function CtlColorStatic(WParam,LParam:DWORD):DWORD;override;
    function CtlColorDlg(WParam,LParam:DWORD):DWORD;override;
    function CtlColorListBox(WParam,LParam:DWORD):DWORD;override;
  public
    function DlgProc(Dlg:HWND;Msg,Wparam,LParam:DWORD):DWORD;override;
  end;

  TMacroNewDlg=class(TDialog)
  protected
    function InitDialog(Dlg:HWND;Param:DWORD):boolean;override;
    function CtlColorStatic(WParam,LParam:DWORD):DWORD;override;
    function CtlColorDlg(WParam,LParam:DWORD):DWORD;override;
  public
    function DlgProc(Dlg:HWND;Msg,Wparam,LParam:DWORD):DWORD;override;
  end;
  
var
  st1:array[0..100]of char;
  listBox:HWND;
  TF:TFile;


function MacroK(AParent:TWindow):boolean;
var TMD:TMacroDlg;
begin
  if Macroses = nil then
  begin
    MessageBox(AParent.Handle,'Не найден файл MACROS.DAT.',MSG_CAPTION,16);
    Exit;
  end;
  TMD:=TMacroDlg.Create(AParent,87,0);
  TMD.ShowModal;
  TMD.Free;
end;

procedure SaveMacro;
begin
  if Macroses<>nil then Macroses.SaveToFile(path+'\macros.dat');
end;

{ TMacroDlg }

function TMacroDlg.CtlColorDlg(WParam, LParam: DWORD): DWORD;
begin
  Result:=CreateSolidBrush(COLOR_SELTEMA_DLG);
end;

function TMacroDlg.CtlColorListBox(WParam, LParam: DWORD): DWORD;
begin
  SetTextColor(Wparam,$000000);
  SetBkMode(WParam,TRANSPARENT);
  Result:=CreateSolidBrush(COLOR_MACRO_LST);
end;

function TMacroDlg.CtlColorStatic(WParam, LParam: DWORD): DWORD;
begin
  SetBkMode(WParam,TRANSPARENT);
  SetTextColor(Wparam,$FF0000);
  Result:=CreateSolidBrush(COLOR_SELTEMA_STATIC);
end;

function TMacroDlg.DlgProc(Dlg: HWND; Msg, Wparam, LParam: DWORD): DWORD;
var k:integer;TMND:TMacroNewDlg;
begin
  case Msg of
    WM_COMMAND :
      if LOWORD(WParam) = 101 then  begin    // событие от ListBox'а
        if HIWORD(WParam)=LBN_DBLCLK then    //  двойной щелчок
        begin
          k:=SendMessage(ListBox,LB_GETCURSEL,0,0);     //  номер текущей
          SendMessage(ListBox,LB_GETTEXT,k,DWORD(@st1));// получаем строку
          TMND:=TMacroNewDlg.Create(Parent,3,0);
          EnableWindow(Dlg,false);
          if TMND.ShowModal<>ID_OK then
          begin
            TMND.Free;
            EnableWindow(Dlg,true);
            Windows.SetFocus(ListBox);
            Exit;
          end;
          TMND.Free;
          EnableWindow(Dlg,true);
          SendMessage(ListBox,LB_DELETESTRING,k,0);
          SendMessage(ListBox,LB_INSERTSTRING,k,DWORD(@st1));
          SendMessage(ListBox,LB_SETCURSEL,k,0);
        end;end
        else
     case WParam  of
       103:                                     //  кнопка Изменить
       begin
          k:=SendMessage(ListBox,LB_GETCURSEL,0,0);     //  номер текущей
          SendMessage(ListBox,LB_GETTEXT,k,DWORD(@st1));// получаем строку
          TMND:=TMacroNewDlg.Create(Parent,3,0);
          EnableWindow(Dlg,false);
          if TMND.ShowModal<>ID_OK then
          begin
            TMND.Free;
            EnableWindow(Dlg,true);
            Windows.SetFocus(ListBox);
            Exit;
          end;
          TMND.Free;
          EnableWindow(Dlg,true);
          SendMessage(ListBox,LB_DELETESTRING,k,0);
          SendMessage(ListBox,LB_INSERTSTRING,k,DWORD(@st1));
          SendMessage(ListBox,LB_SETCURSEL,k,0);
        end;
       ID_OK:
          begin
            for k:=1 to 33 do
              SendMessage(ListBox,LB_GETTEXT,k-1,DWORD(Macroses[k]));
            EndDialog(Dlg,ID_OK);
            Exit;
          end;
       ID_CANCEL:
         begin
           EndDialog(Dlg, ID_CANCEL);
           Exit;
         end;
     end;
  else
    Result:=inherited DlgProc(Dlg,Msg,WParam,LParam)
  end;
end;

function TMacroDlg.InitDialog(Dlg: HWND;Param:DWORD): boolean;
var k:integer;
begin
  CenterWindow(Dlg);
  ListBox:=GetDlgItem(Dlg,101);
  Windows.SetFocus(ListBox);
  for k:=0 to 17 do
    if Macroses[k]<>'' then
    SendMessage(ListBox,LB_ADDSTRING,0,DWORD(Macroses[k]));
  SendMessage(ListBox,LB_SETCURSEL,0,0);        //  выделить первую
  Result:=inherited InitDialog(Dlg,Param);
end;

{ TMacroNewDlg }

function TMacroNewDlg.CtlColorDlg(WParam, LParam: DWORD): DWORD;
begin
  Result:=CreateSolidBrush(COLOR_SELTEMA_DLG);
end;

function TMacroNewDlg.CtlColorStatic(WParam, LParam: DWORD): DWORD;
begin
  SetBkMode(WParam,TRANSPARENT);
  SetTextColor(Wparam,$FF0000);
  Result:=CreateSolidBrush(COLOR_SELTEMA_STATIC);
end;

function TMacroNewDlg.DlgProc(Dlg: HWND; Msg, Wparam,LParam: DWORD): DWORD;
var w:word;
begin
  case Msg of
  WM_COMMAND :
      if LOWORD(WParam) = 101 then              // событие от Edit'a
      begin
        w:=HIWORD(WParam);
        if w = EN_MAXTEXT then
          MessageBox(Dlg,'Длина вводимого макроса ограничена 30-ю символами!'
          ,'Предупреждение',MB_ICONWARNING)
      end else
     case WParam  of
      ID_OK:
        begin
          GetWindowText(GetDlgItem(Dlg,101),@st1[13],20);
          EndDialog(Dlg,ID_OK);
          Exit;
        end;
      ID_CANCEL:
        begin
          EndDialog(Dlg, ID_CANCEL);
          Exit;
        end;
    end;
  else
    Result:=inherited DlgProc(Dlg,Msg,WParam,LParam)
  end;

end;

function TMacroNewDlg.InitDialog(Dlg: HWND;Param:DWORD): boolean;
begin
  CenterWindow(Dlg);
  Windows.SetFocus(GetDlgItem(Dlg,101));
  SetWindowText(GetDlgItem(Dlg,101),@st1[13]);
  SendMessage(GetDlgItem(Dlg,101),EM_SETLIMITTEXT,30,0);
end;

initialization
  Path:=ParamStr(0);
  Path:=ExtractFileDir(Path);
  Macroses:=TStringList.Create;
  try
    Macroses.LoadFromFile(path+'\macros.dat');
  except
    on E:Exception do
    begin
      FreeAndNil(Macroses);
      MessageBox(0,PChar(E.Message),MSG_CAPTION,0);
    end;
  end
end.

