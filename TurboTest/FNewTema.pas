{$O-}
unit FNewTema;
                                     //   ���� �������� :  06.06.02
interface

uses Windows,WinFunc,WinApp,Messages,SysUtils,MTypes,WinDlg,Streams,MConst;

type
  TNewTemaDlg=class(TDialog)
  private
    tema:array[0..1024] of char;
    num:integer;
    HD:THdr;                // ������������ ������
    procedure WriteTema;    //  ������� ���� ���� � � ���������                                                   
  protected
    function InitDialog(Dlg:HWND;Param:DWORD):boolean;override;
    function CtlColorDlg(WParam,LParam:DWORD):DWORD;override;
    function CtlColorStatic(WParam,LParam:DWORD):DWORD;override;
  public
    Name:PChar;
    function DlgProc(Dlg:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
  end;

implementation

{$R RES\FNewTema.res}

{ TNewTemaDlg }

function TNewTemaDlg.CtlColorDlg(WParam, LParam: DWORD): DWORD;
begin
  Result:=CreateSolidBrush(COLOR_NEWTEMA_DLG);
end;

function TNewTemaDlg.CtlColorStatic(WParam, LParam: DWORD): DWORD;
begin
  SetBkMode(WParam,TRANSPARENT);
  Result:=CreateSolidBrush(COLOR_NEWTEMA_DLG);
end;

function TNewTemaDlg.DlgProc(Dlg: HWND; Msg, WParam, LParam: DWORD): DWORD;
var
  t:BOOL;
  st:string;
begin
  Result:=0;
  case Msg of
    WM_COMMAND :
     case WParam of
      ID_OK:
        begin
          GetDlgItemText(Dlg,10,tema,20);      //  �������� ���� ����
          st:=tema;
          if st='' then
          begin
            MessageBox(Dlg,'�� ������� �������� ����!','Turbo Test',MB_ICONERROR);
            Windows.SetFocus(GetDlgItem(Dlg,10));
            Exit;
          end;
          HD.Tema:=StrNew(tema);

          GetDlgItemText(Dlg,11,tema,20);      //  �������� ���� �����
          st:=tema;
          if st='' then
          begin
            MessageBox(Dlg,'�� ������� �������� �����!','Turbo Test',MB_ICONERROR);
            Windows.SetFocus(GetDlgItem(Dlg,11));
            Exit;
          end;
          HD.fName:=StrNew(tema);
          if FileExists(HD.fName+'.tem') then
            if MessageBox(Dlg,'���� ���� � ����� ������ ��� ����������! ������������?',
              'Turbo Test',MB_ICONWARNING or MB_YESNO)=ID_NO then
              begin
                Windows.SetFocus(GetDlgItem(Dlg,11));
                Exit;
              end;

          num:=GetDlgItemInt(Dlg,12,t,true);   //  �������� ���� ckolko
          if not (num in [1..255]) then
          begin
            if not t then
            begin
              MessageBox(Dlg,'������������ �������� � ���� <���������� ��������>!','Turbo Test',MB_ICONERROR);
              Windows.SetFocus(GetDlgItem(Dlg,12));Exit;
            end;
            SetWindowText(GetDlgItem(Dlg,12),nil);
            MessageBox(0,'�������� ����� ���� �� ������ 255!','Turbo Test',MB_ICONERROR);
            Windows.SetFocus(GetDlgItem(Dlg,12));Exit;
          end;
          HD.Ckolko:=num;

          num:=GetDlgItemInt(Dlg,13,t,true);   //  �������� ���� d
          if not (num in [1..9]) then
          begin
            if not t then
            begin
              MessageBox(Dlg,'������������ �������� � ����'#13' <���������� ������������ �������>!','Turbo Test',MB_ICONERROR);
              Windows.SetFocus(GetDlgItem(Dlg,12));Exit;
            end;
            SetWindowText(GetDlgItem(Dlg,13),nil);
            MessageBox(0,'������������ ������� ����� ���� �� ������ 9!',
                         'Turbo Test',MB_ICONERROR);
            Windows.SetFocus(GetDlgItem(Dlg,13));Exit;
          end;
          HD.d:=num;
          GetDlgItemText(Dlg,14,tema,1024);
          HD.Comment:=tema;
          WriteTema;
          Name:=HD.fName;
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

function TNewTemaDlg.InitDialog(Dlg: HWND;Param:DWORD): boolean;
begin
  CenterWindow(Dlg);                      //  ��������� ���� �� ������ ������
  Windows.SetFocus(GetDlgItem(Dlg,10));   //  ��������� ������ �� ������ ���.
  Result:=true;
end;

procedure TNewTemaDlg.WriteTema;
var
  k:integer;
  buf:array[0..255] of char;
  TH:THeader;
  TF:TTestFile;
  f:textFile;
  st:string;
begin
  for k:=0 to StrLen(HD.fName) do buf[k]:=HD.fName[k];
  lstrcat(buf,'.tem');
  StrDispose(HD.fName);
  HD.fName:=StrNew(buf);
  name:=StrNew(buf);
  TH:=THeader.Create(HD);                  //  ������ ���������
  TF:=TTestFile.CreateNew(TH);             //  ������-����
  TF.Free;
  AssignFile(f,'temas.dat');
  if not FileExists('temas.dat') then
  try
    Rewrite(f);
  except
    on E:Exception do
    begin
      MessageBox(0,'������ �������� ����� TEMAS.DAT.','Turbo Test',MB_ICONERROR);
      Exit;
    end;
  end
  else
  try
   Append(f)
  except
    on E:Exception do
    begin
      MessageBox(0,'������ ������� � ����� TEMAS.DAT.','Turbo Test',MB_ICONERROR);
      Exit;
    end;
  end;
  st:=string(HD.Tema);
  Writeln(f,st);
  CLoseFile(f);

  AssignFile(f,'file_tem.dat');
  try
   Append(f)
  except
    on E:Exception do
    begin
      MessageBox(0,'������ ������� � ����� FILE_TEM.DAT.','Turbo Test',MB_ICONERROR);
      Exit;
    end;
  end;
  st:=string(HD.fName);
  Writeln(f,st);
  CLoseFile(f);
end;

end.


