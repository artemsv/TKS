{$O-}
unit MListName;                 //  дата создания : 11.12.02

interface

uses
  WinApp,Windows,SysUtils,Messages,WinCtrl,OprTypes,WinDlg;

type
  TListNameDlg=class(TDialog)
  private
    name:array[0..25] of char;
    ListBox:HWND;
  protected
    function InitDialog(Dlg:HWND;Param:DWORD):boolean;override;
    function DlgProc(Dlg:HWND;Msg,Wparam,LParam:DWORD):DWORD;override;
    function CtlColorStatic(WParam,LParam:DWORD):DWORD;override;
    function CtlColorDlg(WParam,LParam:DWORD):DWORD;override;
    function CtlColorListBox(WParam,LParam:DWORD):DWORD;override;
  end;

function ListName(AParent:TWindow;var st:string;AInfo:RInfo):boolean;

implementation

uses WinFunc, Classes, Macro, Streams, MConst;

{$R RES\ListName.res}

{ TListNameDlg }

var
  grup:string;
  arr:array[0..100] of string;
  count:integer;
  info:RInfo;

function TListNameDlg.CtlColorDlg(WParam, LParam: DWORD): DWORD;
begin
  Result:=CreateSolidBrush(COLOR_LISTNAME_DLG);
end;

function TListNameDlg.CtlColorListBox(WParam, LParam: DWORD): DWORD;
begin
  SetTextColor(Wparam,$66);
  SetBkMode(WParam,TRANSPARENT);
  Result:=CreateSolidBrush($C3DCC8);
end;

function TListNameDlg.CtlColorStatic(WParam, LParam: DWORD): DWORD;
begin
  SetBkMode(WParam,TRANSPARENT);
  Result:=CreateSolidBrush(COLOR_LISTNAME_STATIC);
end;

function TListNameDlg.DlgProc(Dlg: HWND; Msg, Wparam, LParam: DWORD): DWORD;
var
  k:integer;
begin
  Result:=0;
  case Msg of
    WM_COMMAND :
      begin
        if LOWORD(WParam) = 101 then begin             // событие от ListBox'а
          if HIWORD(WParam)=LBN_DBLCLK then            //  двойной щелчок
          begin
            k:=SendMessage(ListBox,LB_GETCURSEL,0,0);     //  номер текущей
            SendMessage(ListBox,LB_GETTEXT,k,DWORD(@name));// получаем строку
            EndDialog(Dlg,ID_OK)
          end;
        end
        else
       case WParam of
        ID_OK:
          begin
            k:=SendMessage(ListBox,LB_GETCURSEL,0,0);     //  номер текущей
            SendMessage(ListBox,LB_GETTEXT,k,DWORD(@name));// получаем строку
            EndDialog(Dlg,ID_OK);
            Exit;
          end;
        ID_CANCEL:
          begin
            EndDialog(Dlg, ID_CANCEL);
            Exit;
          end;
       end;
      end;
  else
    Result:=inherited DlgProc(Dlg,Msg,Wparam,LParam)
  end;
end;

function TListNameDlg.InitDialog(Dlg: HWND;Param:DWORD): boolean;
var
  k:integer;
  pch:PChar;
  TSL:TStringList;
begin
  CenterWindow(Dlg);
  Result:=false;
  grup:=Path+'\'+info.gr+'.grp';
//  grup:=Path+'\temp.grp';
  TSL:=TSTringList.Create;
  try
    TSL.LoadFromFile(grup);
  except
    MessageBox(Dlg,PChar('Ошибка открытия файла '+grup),nil,$10);
    Exit;
  end;
  ListBox:=GetDlgItem(Dlg,101);
  for k:=0 to  TSL.Count-1 do
  begin
    pch:=StrNew(PChar(TSL[k]));
    SendMessage(ListBox,LB_ADDSTRING,0,DWORD(pch));
  end;
  SetDlgItemText(Dlg,32,PChar(info.teacher));
  SetDlgItemText(Dlg,31,PChar(info.date));
  SetDlgItemText(Dlg,33,PChar(info.gr));
  SetDlgItemText(Dlg,34,PChar(info.tema));
  SetDlgItemText(Dlg,35,PChar(IntToStr(info.colVopr)));
  SetDlgItemText(Dlg,36,PChar(GetTim(info.tim)));
  Windows.SetFocus(ListBox);
  Sendmessage(ListBox,LB_SETCURSEL,0,0);
  Result:=inherited InitDialog(Dlg,Param);
end;

function ListName(AParent:TWindow;var st:string;AInfo:RInfo):boolean;
var
  LND:TListNameDlg;
begin
  Result:=false;
  info:=AInfo;
  LND:=TListNameDlg.Create(AParent,3450,0);
  if LND.ShowModal = ID_OK then Result:=true;
  if Result=true then st:=LND.Name;
  LND.Free;
end;
end.
