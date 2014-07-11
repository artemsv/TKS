{$O-}
unit MSost;                              //  ���� �������� : 06.11.02.

interface

uses Windows,WinApp,MRed,Main,UOleRTF;

type
  TSost=class(TRed)
  private
    FCount:integer;                      //  ����� �������� �����
    Frame:TFrame;                        //  ������� ������������ ����
    procedure WriteInvite(Invite:PCHar); //  ����������� � ������ �������
    procedure Block;                     //  ������� �� ������� kbBlock
    procedure NewFrame;                  //  ������� ����� ����
  protected
    function CloseQuery:boolean;override;
    procedure DoSetFocus(WParam:DWORD);override;
    function DoCommand(Wparam,LParam:DWORD):DWORD;override;
    function Init:boolean;override;
  public
    constructor Create(AParent:TMDIWindow;AClient:TMDIClient;FileName:PChar);override;
  end;

implementation

uses MConst,SysUtils,RichEDit,Messages,CommCtrl;

{ TSost }

procedure TSost.Block;
var
  m:integer;
  oldCF,CF:TCharFormat;
begin
  if FCount=Header.d+1 then NewFrame           //  ���� ������ ���������� �����
  else begin
    RTF.SetSel(RTF.GetTextLen,RTF.GetTextLen); //������-� ����� ������
    if FCount=0 then                           //  ���� ��� ������ ��� ������
    begin
      if RTF.Text='' then Exit;                //  ���� � ������� ��� ��������
      RTF.AddSplitter
    end else                                   //  ��������� ������.�����
      RTF.Perform(WM_CHAR,13,0);               //  �������� ������� Enter
    m:=RTF.GetCurCaretX;
    RTF.Perform(WM_CHAR,49+FCount,0);          //  ����� ������
    RTF.Perform(WM_CHAR,46,0);                 //  �����
    RTF.GetCharFormat(true,oldCF);
    CF:=oldCF;
    CF.szFaceName:='System';
    CF.dwEffects:=CF.dwEffects and not CFE_AUTOCOLOR;
    CF.crTextColor:=COLOR_NUM_PASSIVE;
    CF.dwMask:=CF.dwMask or CFM_COLOR or CFM_FACE;
    RTF.SetSel(m,m+2);                       //  �������� ����� � ������
    RTF.SetCharFormat(SCF_SELECTION,CF);     //  ������ ������� �������
    RTF.SetSel(m+2,m+2);
    RTF.SetCharFormat(SCF_SELECTION,oldCF);  //  �����. ������ ������
    Inc(Fcount);                             //  ��������� �������� ������
    Frame.Nums[FCount]:=RTF.GetCount-1;      //  ���������� ����� � �����
    if FCount=Header.d+1 then WriteInvite('������� ���������� �����')else
    WriteInvite(PChar(('������� '+IntToStr(FCount)+'-� ������������ �����')));
  end;
end;

constructor TSost.Create(AParent:TMDIWindow;AClient:TMDIClient;FileName: PChar);
var
  CF:TCharFormat;
begin
  inherited;
  if Header.nn=Header.ckolko then
    raise Exception.Create('       ������� ��� �������!       ');
  FCount:=0;
  WriteInvite('������� ������');
  NumFrame:=Header.nn+1;          // ������� ���� - ���������� ����� ����.
  TMyMDI(Parent).StatusBar.SetText(3,PChar('������ '+IntToStr(NumFrame)));
  Frame:=TFrame.Create;           //  ������� �����(������) ����
  RTF.SetFrame(Frame);            //  ������������� ��� � ��������
  RTF.SetSel(0,0);
  FillChar(CF,SizeOf(TCharFormat),0);
  CF.cbSize:=SizeOf(TCharFormat);
  CF.dwMask:=CFM_FACE or CFM_COLOR or CFM_SIZE;
  CF.yHeight:=200;
  CF.szFaceName:='System';
  CF.crTextColor:=$000000;
  RTF.SetCharFormat(SCF_SELECTION,CF);            //  ����� ������ �������
end;

function TSost.CloseQuery: boolean;
begin
  Result:=false;
  case MessageBox(Handle,'� ���� ���� ������� ���������.���������?','Turbo Test',
      MB_ICONWARNING or MB_YESNOCANCEL) of
    ID_CANCEL:Exit;
    ID_YES:SaveTema;
  end;
  Result:=true;
end;

function TSost.DoCommand(Wparam, LParam: DWORD):DWORD;
begin
  case WParam of
    CM_DOWN,CM_UP:Exit;           //  ��� ������� �� PgUp-PgDown
    DOM_BLOCK:Block;              //  ��������� ����������� �����
    DOM_CANSELECTALL:Result:=1;   //  ������ �������� ���
  else
    Result:=inherited DoCommand(WParam,LParam);
  end;
end;

procedure TSost.DoSetFocus(WParam:DWORD);
begin
  inherited;
  if FCount=0 then WriteInvite('������� ������') else
    if FCount<Header.d then
      WriteInvite(PChar('������� '+IntToStr(FCount)+' ������������ �����'))
    else
      WriteInvite('������� ���������� �����');
end;

function TSost.Init: boolean;
begin
  Result:=false;
  if not LoadTema then Exit;;
  Result:=true;
end;

procedure TSost.NewFrame;
var
  KL:HKL;
begin
  KL:=GetKeyBoardLayout(0);       //  ���������� ������� ��������
  FModified:=true;
  RTF.UpdateFrame;                //  ���������� ��������� � ������� �����
  Frames.Add(Frame);              //  ���. � ������ ���������� ����
  Frame:=TFrame.Create;           //  ������� �����(������) ����
  RTF.SetFrame(Frame);            //  ������������� ���
  Inc(NumFrame);                  //  ����� �������� �����
  Header.nn:=Header.nn+1;         //  ������� ���-�� ��������� ������
  TMyMDI(Parent).StatusBar.SetText(3,PChar('������ '+IntToStr(NumFrame)));
  WriteInvite('������� ������');
  FCount:=0;                      //  ������ ����-������
  if NumFrame>Header.ckolko then  //  ���� ������� ��� �����
  begin
    MessageBox(Handle,'          ���� �������!          ','Turbo Test ',0);
    SaveTema;
    Free
  end;
  ActivateKeyBoardLayout(KL,0);       //  ��������������� ��������� ����.
end;

procedure TSost.WriteInvite(Invite:PChar);
begin
  TMyMDI(Parent).StatusBar.SetText(2,PChar(invite));
end;

end.
