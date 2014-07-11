unit MPrnDlg;                          //  Дата создания : 30.04.03.

interface

uses Windows,WinDlg;


type
  PPrintRec=^RPrintRec;
  RPrintRec=record
    ifRTF:boolean;
    FileName:string;
    inFile:boolean;
    onlyQuestions:boolean;
  end;

  TPrintDlg=class(TDialog)
  private
    PrintRec:PPrintRec;
  protected
    function InitDialog(Dlg:HWND;Param:DWORD):boolean;override;
  public
    function DlgProc(Dlg:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
  end;

implementation

{$R RES\Print.res}

uses Messages,WinFunc;

{ TPrintDlg }

function TPrintDlg.DlgProc(Dlg: HWND; Msg, WParam, LParam: DWORD): DWORD;
begin
  Result:=0;
  case Msg of
    WM_COMMAND :
      if HIWORD(WParam)=BN_CLICKED then
        case LOWORD(WParam) of
          ID_OK:begin
                  PrintRec^.onlyQuestions:=
                    SendDlgItemMessage(Dlg,106,BM_GETCHECK,0,0)=BST_CHECKED;
                  PrintRec^.ifRTF:=
                    SendDlgItemMessage(Dlg,120,BM_GETCHECK,0,0)=BST_CHECKED;
                  PrintRec^.inFile:=
                    SendDlgItemMessage(Dlg,122,BM_GETCHECK,0,0)=BST_CHECKED;                  
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
    Result:=inherited DlgProc(Dlg,Msg,Wparam,LParam)
  end;
end;

function TPrintDlg.InitDialog(Dlg: HWND; Param: DWORD): boolean;
begin
  CenterWindow(Dlg);
  PrintRec:=PPrintRec(Param);
  Result:=inherited InitDialog(Dlg,Param);
  SendDlgItemMessage(Dlg,106,BM_SETCHECK,BST_CHECKED,0);
  SendDlgItemMessage(Dlg,120,BM_SETCHECK,BST_CHECKED,0);
  SendDlgItemMessage(Dlg,122,BM_SETCHECK,BST_CHECKED,0);
  SetDlgItemText(Dlg,111,PChar(PrintRec^.FileName))
end;

end.
