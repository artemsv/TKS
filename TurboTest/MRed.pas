{$O-}
unit MRed;                              //  ���� �������� : 06.11.02.

interface

uses Windows,WinApp,MEdit,Contnrs,UOleRTF,Main,Streams,MOptions;

type
  TRed=class(TEdit)
  private
    FFrames:TObjectList;              //  ������ ������
    FOptions:ROptions;                //  ���������
    FFrameCopied:DWORD;               //  ����� �������������� �����
    procedure SaveFrames(TF:TFile);
    procedure LoadFrames(TF:TFile);
    procedure CreateBAK;              //  ������� BAK-����
    procedure CopyMe;                 //  �������� ������� ����
    procedure PasteMe;
  protected
    NumFrame:DWORD;                   //  ����� �������� �����
    Header:THeader;                   //  ������-���������
    FFileName:PChar;
    function Init:boolean;virtual;
    function LoadTema:boolean;override;
    function SaveTema:boolean;override;
    function CloseQuery:boolean;override;
    procedure DoSetFocus(WParam:DWORD);override;
    procedure DoKillFocus(WParam:DWORD);override;
    procedure DeleteFrame;virtual;
    procedure AddFrame;virtual;
    function DoCommand(WParam,LParam:DWORD):DWORD;override;
    procedure PgUpDown(key:DWORD);    //  ������������ �����
    procedure Refresh;          //  �������� ���� �� ������(�������)
    procedure Properties;
    procedure Print;
    function CanEditMenu:DWORD;
    function CanRTFUndo:DWORD;
    function CanRTFPaste:DWORD;
  public
    constructor Create(AParent:TMDIWindow;AClient:TMDIClient;FileName:PChar);override;
    destructor Destroy;override;
    property Frames:TObjectList read FFrames;
    property Options:ROptions read FOptions;
  end;

implementation

uses
  SysUtils,MConst,Messages,OleObj,MTypes,WinFunc,MProp,MPrnDlg;

const
  MSG_DELETE_FRAME='������������� �������� �������� ������� � ��������?';
  MSG_DELETE_FRAME2='������ ������� ������������ ������ � ����.';
  MSG_ADD_FRAME='����� �������� ����� ������ ������ � ����� ����.����������?';

{ TRed }

constructor TRed.Create(AParent:TMDIWindow;AClient:TMDIClient;FileName: PChar);
begin
  inherited;
  FFileName:=FileName;
  Init;                        
end;

procedure TRed.CreateBAK;
begin
end;

destructor TRed.Destroy;
begin
  if Header<>nil then Header.Free;
  if FFrames<>nil then FFrames.Free;
  inherited;
  SendMessage(Parent.Handle,WM_COMMAND,CM_STATUSTEXTCLEAR,0);  
end;

function TRed.CloseQuery: boolean;
begin
  RTF.UpdateFrame;                     //  ���������� ��������� ���������
  FModified:=FModified or RTF.Modified;//  �������� ���� ���������
  Result:=false;
  if FModified then
  case MessageBox(Handle,'� ���� ���� ������� ���������.���������?','Turbo Test',
     MB_ICONWARNING or MB_YESNOCANCEL) of
     ID_CANCEL:Exit;
     ID_YES:SaveTema;
  end;
  Result:=true;
end;

function TRed.DoCommand(WParam, LParam: DWORD):DWORD;
begin
  Result:=inherited DoCommand(WParam,LParam);;
  case WParam of
    CM_UP,CM_DOWN:PgUpDown(WParam);
    CM_QDELETE:DeleteFrame;
    CM_QADD:AddFrame;
    CM_PROP:Properties;
    CM_PRINT:Print;
    DOM_CUT..DOM_REFRESH:RTF.Perform(WM_COMMAND,WParam,0);
    CM_REFRESH:Refresh;                      // �������� �������
    DOM_COPYME:CopyMe;
    DOM_PASTEME:PasteMe;
    DOM_CANEDITMENU:Result:=CanEditMenu;     //  ������ ���������� � ��������
    DOM_CANRTFUNDO: Result:=CanRTFUndo;      //  ���������-�� ����� ��������
    DOM_CANRTFPASTE: Result:=CanRTFPaste;    //  ���������-�� ����� ��������
    DOM_CANEMBED: Result:=DWORD(DoEmbed);    //  ������ � ���� �������
  end;
end;

procedure TRed.DoKillFocus(WParam:DWORD);
begin
  SendMessage(Parent.Handle,WM_COMMAND,CM_STATUSTEXTCLEAR,0);
end;

procedure TRed.DoSetFocus(WParam:DWORD);
begin
  RTF.SetFocus;
  SendMessage(Parent.Handle,WM_COMMAND,DOM_UPDATECARETPOS,
     MakeLong(RTF.Row+1,RTF.Column+1));
  SendMessage(Parent.Handle,WM_COMMAND,DOM_UPDATEINSERTFLAG,DWORD(RTF.Insert));
  TMyMDI(Parent).StatusBar.SetText(3,PChar('������ '+IntToStr(NumFrame)));
  inherited
end;

function TRed.Init:boolean;
begin
  Result:=false;
  if not LoadTema then
    raise Exception.Create('���������� ��������� ���� '+FFileName);
  if Header.nn=0 then
    raise Exception.Create('�� ���� ���� ������� �� ����������.');
  TMyMDI(Parent).StatusBar.SetText(3,PChar('������ '+IntToStr(NumFrame)));
  RTF.SetFrame(TFrame(FFrames[0]));
  Result:=true;
end;

procedure TRed.LoadFrames(TF: TFile);
var
  k:integer;
begin
  for k:=0 to Header.nn-1 do
    FFrames.Add(TFrame.Load(TF));
end;

function TRed.LoadTema: boolean;
var
  TF:TTestFile;
begin
  Result:=true;
  TF:=TTestFile.Create(FFileName);             //  ��������� ���. ����
  Header:=TF.GetHeader;                        //  �������� ���������
  FFrames:=TObjectList.Create;                 //
  NumFrame:=1;                                 //  ������� ����-������
  LoadFrames(TF);                              //  ��������� �����
  TF.Free;
end;

procedure TRed.PgUpDown(key: DWORD);
var
  KL:HKL;
begin
  KL:=GetKeyBoardLayout(0);           //  ���������� ������� ��������
  if RTF.Modified then                //  ���� ������ ���������
    RTF.UpdateFrame;                  //  ���������� ��������� ���������
  FModified:=FModified or RTF.Modified;
  if Key=CM_DOWN then
  begin
    Inc(NumFrame);
    if NumFrame=Header.nn+1 then NumFrame:=1;
  end
  else begin
    Dec(NumFrame);
    if NumFrame=0 then NumFrame:=Header.nn;
  end;
  RTF.SetFrame(TFrame(FFrames[NumFrame-1]));  //  ������������� ����� ����
  ActivateKeyBoardLayout(KL,0);       //  ��������������� ��������� ����.
  TMyMDI(Parent).StatusBar.SetText(3,PChar('������ '+IntToStr(NumFrame)));
end;

procedure TRed.Refresh;
var
  n1,n2:integer;
begin
  n1:=rtf.row;n2:=rtf.column;            // ��������� ��������� �������
  RTF.UpdateFrame;
  RTF.RestoreFrame;
  rtf.row:=n1;rtf.column:=n2;            // ������������ ��������� �������
end;

procedure TRed.SaveFrames(TF: TFile);
var
  k:integer;
begin
  for k:=0 to Header.nn-1 do
    TFrame(FFrames[k]).Store(TF);
end;

function TRed.SaveTema: boolean;
var
  TF:TTestFile;
begin
  RTF.UpdateFrame;                     //  ���������� ��������� ���������
  if Options.CreateBak then CreateBAK; //  ������ BAK-����
  TF:=TtestFile.Create(FFileName);     //  ��������� ���. ����
  TF.Truncate(0);                      //  ������� ����
  TF.WriteSignature;                   //  ��������� ASTS
  Header.DateModified:=StrNew(PChar(DateToStr(GetCurrentDateTime)));// �������� ����
  TF.Put(Header);                      //  ��������� ������-���������
  SaveFrames(TF);                      //  ��������� ����� � ������
  TF.Free;
  Result:=true;
end;

procedure TRed.CopyMe;
begin
  FFrameCopied:=NumFrame
end;

function TRed.CanEditMenu: DWORD;
begin
  if RTF.SelText=RTF.Text then Result:=1             //  ������� ���� �����
    else Result:=DWORD(RTF.DoOperation(RTF.SelText));
  if Length(RTF.SelText)=0 then Result:=0;
end;

function TRed.CanRTFPaste: DWORD;
var
  Format:DWORD;
begin
  Format:=RTF.GetFormat;
  if RTF.SelText=RTF.Text then Result:=1
  else
  Result:=DWORD(IsClipboardFormatAvailable(Format));
end;

function TRed.CanRTFUndo: DWORD;
begin
  Result:=RTF.Perform(EM_CANUNDO,0,0);
end;


procedure TRed.PasteMe;
begin
  RTF.SetFrame(TFrame(FFrames[FFrameCopied-1]));  // ������������� ����� ����
end;

procedure TRed.DeleteFrame;
begin
  if FFrames.Count=1 then
  begin
    MessageBox(Handle,MSG_DELETE_FRAME2,MSG_CAPTION,MB_ICONWARNING);
    Exit;
  end else
  if MessageBox(Handle,MSG_DELETE_FRAME,MSG_CAPTION,$124)=ID_NO then Exit;
  FFrames.Remove(FFrames[NumFrame-1]);
  Header.nn:=Header.nn-1;
  FModified:=true;
  PgUpDown(CM_DOWN);
end;

procedure TRed.AddFrame;
var Frame:TFrame;
begin
  if MessageBox(Handle,MSG_ADD_FRAME,MSG_CAPTION,$24) = ID_NO then Exit;
  Frame:=TFrame.Create;
  RTF.SetFrame(Frame);
end;

procedure TRed.Properties;
var
  TPD:TPropDlg;
  W:TWindow;
begin
  W:=TWindow.Create(WS_OVERLAPPEDWINDOW,0,100,100,300,200,Self,nil);
  W.ShowModal;
  W.Free;
  TPD:=TPropDlg.Create(Self,3011,DWORD(Header));
  if TPD.ShowModal=ID_OK then FModified :=true;
  TPD.Free;
end;

//  ������������ �����������

procedure TRed.Print;
var
  TPD:TPrintDlg;
  PrintRec:RPrintRec;
  Ext:string;
  TF:TFile;
  k:integer;
begin
  PrintRec.FileName:=ChangeFileExt(ExtractFileName(Header.FName),'');
  TPD:=TPrintDlg.Create(Self,340,DWORD(@PrintRec));
  if TPD.ShowModal=ID_CANCEL then
  begin
    TPD.Free;
    Exit;
  end;
  TPD.Free;
  if PrintRec.ifRTF then Ext:='.rtf' else ext:='.txt';
  PrintRec.FileName:=ChangeFileExt(PrintRec.FileName,ext);
  TF:=TFile.Create(PrintRec.FileName,CREATE_ALWAYS);
  for k:=0 to Header.nn-1 do
  begin
    TF.Write(TFrame(FFrames[k]).Buf,TFrame(FFrames[k]).Size);
  end;
  TF.Free;
end;

end.

