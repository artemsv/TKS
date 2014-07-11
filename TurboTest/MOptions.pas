{$O-}
unit MOptions;                           //  Дата создания: 21.10.02.

interface

uses Windows,WinCtrl,WinFunc,Inifiles,Messages,WinDlg,WinApp;

type
  ROptions=record
    CreateBak:boolean;               //  true - создается BAK - файл
    ColorSplit:COLORREF;             //  цвет разделительной линии
    ColorNum:COLORREF;               //  цвет номеров ответов
  end;

  TOptionDlg=class(TDialog)
  private
    Options:ROptions;
    StatusBar:TStatusBar;
  protected
    function InitDialog(Dlg:HWND;Param:DWORD):boolean;override;
  public
    function DlgProc(Dlg:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
  end;

procedure ExecOptions(Parent:TWindow);

implementation

uses Macro;

var State:DWORD;CaretDX:integer;

{ TOptionDlg }

function TOptionDlg.DlgProc(Dlg:HWND;Msg,WParam,LParam:DWORD):DWORD;
begin
  Result:=0;
  case Msg of
  WM_COMMAND :
     if HIWORD(WParam)=BN_CLICKED then
       case LOWORD(WParam) of
         101:;
         ID_OK:begin
                 State:=SendMessage(GetDlgItem(Dlg,101),BM_GETCHECK,0,0);
                 if State=BST_CHECKED then Options.ColorSplit:=2 else
                    Options.ColorSplit:=1;
                 EndDialog(Dlg,ID_OK);
                 Exit;
               end;
         ID_CANCEL:
          begin
            EndDialog(Dlg, ID_CANCEL);
            Exit;
          end;
       end;
  WM_SIZE:
//    StatusBar.Perform(WM_SIZE,WParam,LParam);
  end;
  Result:=0;
end;

function TOptionDlg.InitDialog(Dlg: HWND;Param:DWORD): boolean;
var IniFile:TIniFile;
begin
{  IniFile:=TIniFile.Create(Path+'\options.ini');
  CaretDX:=IniFile.ReadInteger('Caret','CaretDX',2);
  if CaretDX=2 then
    SendMessage(GetDlgItem(Dlg,101),BM_SETCHECK,BST_CHECKED,0) else
    SendMessage(GetDlgItem(Dlg,101),BM_SETCHECK,BST_UNCHECKED,0);
  IniFile.Free;}
  Result:=inherited InitDialog(Dlg,Param);
  exit;
  (TButton.Create(Self,40,80,100,24,'параметры',90));
  TGroupBox.Create(Self,10,10,200,200,'Сервис');
  {TRadio.Create(Self,100,100,60,14,'AAA',89);
  TRadio.Create(Self,100,120,60,14,'AAA',88);
  TRadio.Create(Self,100,140,60,14,'AAA',87);
  TRadio.Create(Self,100,160,60,14,'AAA',86);
   }
  StatusBar:=TStatusBar.Create (Self);
  (TCheckBox.Create(Self,100,260,60,14,'Курсор',85));
  SetWindowText(Handle,'Настройка')
end;

procedure ExecOptions(Parent:TWindow);
var TOD:TOptionDlg;
    Template:DLGTEMPLATE;
begin
  Template.style:=WS_SIZEBOX or WS_VISIBLE or WS_SYSMENU or WS_CAPTION or DS_MODALFRAME or DS_CENTER;
  Template.dwExtendedStyle:=0;
  Template.cdit:=0;
  Template.x:=100;
  Template.y:=100;
  Template.cx:=320;
  Template.cy:=200;
  TOD:=TOptionDlg.CreateIndirect(Parent,Template,678);
  TOD.ShowModal;
  TOD.Free;
end;

end.
