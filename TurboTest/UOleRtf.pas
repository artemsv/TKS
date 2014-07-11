{$O-}
unit UOleRTF;                          //  ���� �������� : 08.11.02.

interface

uses Windows,Contnrs,Streams,OleRTF,WinApp,WinRTF,OleObj;

type
  TANums=array[0..7] of byte;
  TRTFBuf=array[0..4095] of char;

{ ����� ������������� � ���� ���� �������� ����,���������� � ���� �����
  ��� RichEdit'a � ������ ���������� ��������.���������� ����������
  ��������� RichEdit'a }

  TFrame = class
  public
    FObjectList:TObjectList;                  //  ������ ���������� ��������
    Size:DWORD;                               //  ������ ���������
    Position:DWORD;                           //  ������������ � RTF
    Nums:TANums;                              //  ������ ����� � ��������
    Buf:TRTFBuf;                              //  ��������� ��� RTF-������
    constructor Create;
    constructor Load(TF:TFile);
    procedure Store(TF:TFile);
  end;

{  ����� ������������� ������������ ������� RICHEDIT � ���������:
        -��������� OLE-��������
        -�������������� ����� ����� ����� �������
        -������ ������ �������
}

  TOleRTF=class(TRtf)
  private
    FRichEditOle:IRichEditOle;            // OLE �������� RichEdit'a
    FFrame:TFrame;                        // ����,� ������� �������� RichEdit
    procedure InsertMacros(num:integer);  //  ������� ������� ����� num
  protected
    //  true - ������ �������� ��� ���� ������������ ������� WM_XXX
    function DoKeyDown(WParam,LParam:DWORD):boolean;override;
    function DoCharDown(WParam,LParam:DWORD):boolean;override;
    function DoMouseMove(Wparam,LParam:DWORD):boolean;override;
    function DoLDown(Wparam,LParam:DWORD):boolean;override;
    function DoRTFCut:boolean;override;          //  true -�������� ���������
    function DoRTFClear:boolean;override;        //  true -�������� ���������
    function DoRTFCopy:boolean;override;         //  true -�������� ���������
    function DoRTFPaste:boolean;override;        //  true -�������� ���������
  public
    constructor Create(AParent:TWin;AStyle,AExStyle:DWORD);override;
    procedure AddSplitter;                       //  �����.����.�����
    function GetObjectCount:integer;             //  ����� �����. ��������
    function GetObject(num:integer):TOleObject;  //  �����.������ ����� num
    procedure DeleteObject(num:integer);         //  ����.������ ����� num
    procedure DeleteAllObjects;                  //  ������� ��� �������
    function GetFrame:TFrame;                    //  ������� ����� �����
    function DoOperation(st:string):boolean;override;
    function IfNum(st:string):boolean;virtual;   //  true -�������� ���������
    function If13(st:string):boolean;            //  true -�������� ���������
    function DoEmbed:boolean;override;
    procedure SetFrame(Frame:TFrame);            //  ���������� ����� ����
    procedure UpdateFrame;                       //  ����.��������� � �����
    procedure RestoreFrame;                      //  ���.��������� �� �����
    procedure Embed(Obj:TOleObject);             //  �������� ������
    property Frame:TFrame read FFrame;
    property RichEditOle:IRichEditOle read FRichEditOle;
  end;

implementation

uses ActiveX,Messages,RichEdit,SysUtils,MConst,Macro;

const
  ReadError = $0001;
  WriteError = $0002;
  NoError = $0000;

const
  SplitLine:array[0..158] of char=('-','-','-','-','-','-','-','-','-','-',
  '-','-','-','-','-',
  '-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-',
  '-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-',
  '-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-',
  '-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-',
  '-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-',
  '-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-',
  '-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-',
  '-','-','-','-','-','-','-','-','-','-','-','-','-','-','-','-',#13,#10);

{ TFrame }

constructor TFrame.Create;
begin
  inherited;
  FillChar(Buf,SizeOf(Buf),0);
  Size:=0;
  Position:=0;
  FObjectList:=nil;
  FillChar(Nums,SizeOf(TANums),0);
  FObjectList:=TObjectList.Create;        //  ������ ��������� ��������
end;

constructor TFrame.Load(TF: TFile);
var
  ObjCount,k:integer;
begin
  FObjectList:=TObjectList.Create;        //  ������ ��������� ��������
  Position:=0;
  TF.Read(Nums,SizeOf(TANums));           //  ������� ������ ������� �����
  TF.Read(Size,SizeOf(Size));             //  ������� ������ ������
  TF.Read(Buf,Size);                      //  ������� ��� �����
  TF.Read(ObjCount,SizeOf(ObjCount));     //  ������� ����� �����.��������
  if ObjCount=0 then Exit;                //  ��� ���������� ��������
  for k:=1 to ObjCount do
    FObjectList.Add(TOleObject.Load(TF)); //  ��������� �����.�������
end;

procedure TFrame.Store(TF: TFile);
var
  k,ObjCount:integer;
begin
  TF.Write(Nums,SizeOf(TANums));          //  ��������� ������ �����
  TF.Write(Size,SizeOf(Size));            //  ��������� ������ ������
  TF.Write(Buf,Size);                     //  ��������� �����
  if FObjectList=nil then ObjCount:=0
    else ObjCount:=FObjectList.Count;
  TF.Write(ObjCount,SizeOf(ObjCount));       //  ����.����� �����.��������
  for k:=0 to ObjCount-1 do
    TOleObject(FObjectList[k]).Store(TF);    //  ��������� �����.�������
end;

{ TOleRTF }             // ��������� ����� �� RTF

function GetFrameCallback(dwCookie: Longint; pbBuff: PByte;
                 cb: Longint; var pcb: Longint): Longint; stdcall;
begin
  pcb:=cb;
  if cb>0 then
  begin
    Move(pbBuff^,TFrame(dwCookie).buf[TFrame(dwCookie).Size],pcb);
    Inc(TFrame(dwCookie).Size,cb);
  end;
  Result:=NoError
end;

procedure TOleRTF.AddSplitter;
var
  oldCF,CF:TCharFormat;
  st:string;
begin
  CF.cbSize:=SizeOf(TCharFormat);
  GetCharFormat(true,oldCF);
  CF:=oldCF;
  CF.szFaceName:='MS Sans Serif';
  CF.dwEffects:=CF.dwEffects and not CFE_AUTOCOLOR;
  CF.crTextColor:=$FF; //COLOR_NUM_PASSIVE;
  CF.dwMask:=CF.dwMask or CFM_COLOR ;
  InsertLine(GetCount,SplitLine,@CF);  //  ��������� ������ SplitLine
  SetCharFormat(SCF_SELECTION,oldCF);  //  ��������������� ������ ������
end;

constructor TOleRTF.Create(AParent: TWin; AStyle, AExStyle: DWORD);
begin
  inherited;                        //  �������� OLE ��������� RichEdit'a
  Perform(EM_GETOLEINTERFACE,0,DWORD(@RichEditOle));
//  Perform(EM_SETOLECALLBACK,0,DWORD(Self));
end;

procedure TOleRTF.DeleteAllObjects;
var
  k:integer;
begin
  for k:=GetObjectCount-1 downto 0 do
    DeleteObject(k);
end;

procedure TOleRTF.DeleteObject(num: integer);
var
  RO:REOBJECT;
begin
  RO.cbStruct:=SizeOf(REOBJECT);
  RichEditOle.GetObject(num,@RO,1);
  SetSel(RO.cp,RO.cp+1);
  Perform(WM_KEYDOWN,VK_DELETE,0);
end;

function TOleRTF.DoCharDown(WParam, LParam: DWORD): boolean;
var
  st:string;
  CF:TCharFormat;
  n:integer;
label
  erd;
begin
  Result:=true;
  st:=Copy(Text,0,SelStart);     //  ����� �� �����������
  if Length(st)<2 then goto erd;
  if (st[Length(st)]='.') and (st[Length(st)-1] in ['1'..'9']) then
  begin                       //  ����� ����� ����� �� ������� ������
    n:=GetCurCaretX;
    SetSel(n,n+1);
    GetCharFormat(true,CF);
    SetSel(n,n);
    SetCharFormat(SCF_SELECTION,CF);
  end;
erd:
  if SelLength>0 then
    if not DoOperation(SelText) then Exit;
  st:=Strings[Row];
  if Pos('--------------------------------------------------------------',
          st)<>0 then Exit else
  if LParam=5373953 then Exit
    else Result:=inherited DoCharDown(WParam,LParam);
end;

function TOleRTF.DoEmbed: boolean;    // true-������� ������� ���������
var
  n,k:integer;
  st:string;
begin
  Result:=false;
  if SelText<>'' then Exit;           //  ������ ������� ��� ������� ���������
  Result:=DoRTFPaste;
  for k:=0 to GetCount do
  begin
    st:=GetLine(k);
    if Length(st)<2 then Continue;
    if (st[1]='1') and (st[2]='.') then
    begin
      n:=k-1;      //  ����� ����� � �������������� ������
      Break;
    end;
  end;
  k:=WhichLine(GetCurCaretX);      // �������� ����� ������� ������
  if (k>=n) and (n<>0) then Result:=false;      // ������ ������� ���� �����
end;

function TOleRTF.DoKeyDown(WParam, LParam: DWORD): boolean;
var
  n:integer;
  st,st1:string;
  Shift,Ctrl:boolean;
label
  er;
begin
  Result:=true;
  if Wparam=27 then                        //  ������� Esc ������� ���������
  begin
    HideSelection(true);
    SetSel(0,0);
    Exit;
  end;
  if SelLength>0 then
    if not DoOperation(SelText) then Exit;
  st:=Strings[Row];
  if Pos('--------------------------------------------------------------',
          st)<>0 then
    if not (Wparam in [VK_UP,VK_DOWN]) then Exit;
  Shift:=GetKeyState(VK_SHIFT)<0;          //  ��������� ������� Shift
  Ctrl:=GetKeyState(VK_CONTROL)<0;         //  ��������� ������� Ctrl
  if Ctrl and (WParam=90) then Exit;       //  Ctrl+Z
  if Ctrl and (WParam=65) then Exit;       //  Ctrl+A
{  begin                                   //  �� �����������
    SelectAll;
    Exit;
  end;}
  if (WParam=VK_BACK) or (WParam=VK_LEFT) then
  begin
    n:=GetCurCaretX;
    if n<2 then goto er;
    st:=Text;
    st:=Copy(st,n-1,2);
    if (st='1.') or(st='2.') or(st='3.') or(st='4.') or(st='5.') or
    (st='6.') or(st='7.') or(st='8.') or(st='9.') then Exit
  end;

  if (WParam=VK_DELETE) or (WParam=VK_RIGHT) then
  begin
    n:=GetCurCaretX;
    st:=Text;
    st:=Copy(st,n+1,4);
    if (Pos('1.',st)<>0) or(Pos('2.',st)<>0) or(Pos('3.',st)<>0) or
    (Pos('4.',st)<>0) or(Pos('5.',st)<>0) or(Pos('6.',st)<>0) or
    (Pos('7.',st)<>0) or(Pos('8.',st)<>0) or(Pos('9.',st)<>0) or
    (Pos('--',st)<>0) then Exit
  end;

  if WParam=VK_HOME then
  begin
    st:=Strings[Row];
    if not ((st[1] in ['1','2','3','4','5','6','7','8','9']) and
       (st[2]='.')) then goto er;
    Column:=2;
    Exit;
  end;
  if Wparam=VK_DOWN then
  begin
    if Ctrl then Exit;           //  ������ Ctrl+Down
    n:=Row+1;
    if n>=GetCount then Exit;
    st:=Strings[n];
    if length(st)<2 then goto er;
    if not ((st[1] in ['1','2','3','4','5','6','7','8','9']) and
       (st[2]='.')) then goto er;
    if Column>2 then  goto er;
    Column:=2;
  end;
  if (WParam=VK_UP) then
  begin
    if Ctrl then Exit;             //  ������ Ctrl+Up
    if Row=0 then Exit;
    st:=Strings[Row-1];
    if length(st)<2 then goto er;
    if not ((st[1] in ['1','2','3','4','5','6','7','8','9']) and
       (st[2]='.')) then goto er;
    if Column>2 then  goto er;
    Column:=2;
  end;

er:
  //  ������ �����-������
  if (WParam in [VK_F2..VK_F12]) and (Shift or Ctrl) then
    if Shift then
    begin
      if WParam in [VK_F2..VK_F9] then InsertMacros(WParam-112) else
      if Wparam in [VK_F11..VK_F12] then InsertMacros(WParam-113);
    end;
    if Ctrl then
    begin
      if WParam in [VK_F2..VK_F3] then InsertMacros(WParam-102) else
      if WParam = VK_F5 then InsertMacros(WParam-103) else
      if Wparam in [VK_F7..VK_F9] then InsertMacros(WParam-104) else
      if Wparam in [VK_F11..VK_F12] then InsertMacros(WParam-105)
    end;
  //  ������� �������� ������
  if WParam in [VK_PRIOR,VK_NEXT] then
     SendMessage(Parent.Handle,WM_COMMAND,WParam-28,0) else
  //  ������� kbBlock - ��� �����������
  if LParam=5373953 then
    SendMessage(Parent.Handle,WM_COMMAND,DOM_BLOCK,0) else
  Result:=inherited DoKeyDown(Wparam,LParam)
end;

function TOleRTF.DoLDown(Wparam, LParam: DWORD): boolean;
var
  n,k:integer;
  TP:TPoint;
  st1,st2:string;
  h,l:word;
begin
  Result:=true;                    //  ������ ��������
  for k:=1 to 9 do
  begin
    n:=FindText(IntToStr(k)+'.',0,4000,FT_MATCHCASE); //  4000 - ����.�����
    if n=-1 then Break;
    SendMessage(Handle,EM_POSFROMCHAR,DWORD(@TP),n);
    h:=HIWORD(LParam);l:=LOWORD(LParam);
    if{(HIWORD(LParam)in[TP.y..TP.y+16])and}(LOWORD(LParam)in[0..10])then Exit;
  end;
  Result:=false;                          // �����
end;

function TOleRTF.DoMouseMove(Wparam, LParam:DWORD): boolean;
begin
  Result:=false;
  if SelLength<>0 then Result:=true;
end;

function TOleRTF.DoOperation(st: string): boolean;
begin
  //if st=Text then Result:=true else           //  ���� ������� ���� ����
  Result:=IfNum(st) and If13(st);
end;

function TOleRTF.DoRTFClear: boolean;
begin
  Result:=true;                                 //  �������� ��������
  if DoOperation(SelText) then Exit;
  Result:=false;                                //  ������ ��������}
end;

function TOleRTF.DoRTFCopy: boolean;
begin
  //  ��������������� ����� ��������� ����������� � ������� ��������
  if SelText=Text then
  begin
    Result:=false;
    Parent.Perform(WM_COMMAND,DOM_COPYME,0);
  end else
  //
  Result:=DoOperation(SelText);
end;

function TOleRTF.DoRTFCut: boolean;
begin
  Result:=DoRTFClear;
end;

function TOleRTF.DoRTFPaste: boolean;
var
  st1,st2:string;
begin
  //  ��������������� ����� ��������� ����������� � ������� ��������
  if (SelText=Text) and (Length(Text)>0) then
  begin
    Result:=false;
    Parent.Perform(WM_COMMAND,DOM_PASTEME,0);
    Exit;
  end;
  //
  Result:=false;                         //  ������ ��������
  st1:=Copy(Text,0,SelStart);            //  ����� �� �����������
  st2:=Copy(Text,SelStart+SelLength+1,Length(Text)-SelStart-SelLength);//�����
  if Length(st1)>0 then if st1[Length(st1)]='-' then Exit;
  if Length(st2)>0 then if st2[1]='-' then Exit;
  Result:=true;                          //  ���������� �������
  Result:=DoOperation(SelText) and Result;
end;

procedure TOleRTF.Embed(Obj: TOleObject);
var
  RO:REOBJECT;
begin
  FillChar(RO,SizeOf(RO),0);
  RO.cbStruct:=SizeOf(RO);
  RO.cp:=Obj.charPos;                       // ������� ������� � ������
  RO.dwFlags:=1;                            // REO_RESIZABLE = 1  ???
  RO.dvaspect:=DVASPECT_CONTENT;
  RichEditOle.GetClientSite(RO.polesite);   // ��������� ����������� �����
  RO.pstg:=Obj.Storage;                     // ��������� ��������� �������
  RO.poleobj:=Obj.OleObject;                // ��������� ������ �������
  RO.dwUser:=DWORD(Obj);                    // ��������� �� ������ ����
  try
    RichEditOle.InsertObject(@RO);          // ��������� ������ � RichEdit
  except
    RaiseLastWin32Error;
    MessageBox(Handle,'������ ������� �������',nil,$10);
    Halt;
  end;                       //  �.�.��������� ����� � ������ SF_RTFNOOBJS,
  SetSel(RO.cp+1,RO.cp+2);            //  ������� ������ ����� �������
  Perform(WM_KEYDOWN,VK_DELETE,0);    //  �������� ������� ������� Delete
end;

function TOleRTF.GetFrame:TFrame;
begin
  UpdateFrame;                   //  ���������� ��������� ���������
  Result:=FFrame;
end;

function TOleRTF.GetObject(num: integer): TOleObject;
var
  RO:REOBJECT;
begin
  RO.cbStruct:=SizeOf(REOBJECT);                     //  ���������.������
  RichEditOle.GetObject(num,@RO,REO_GETOBJ_POLEOBJ);
  Result:=TOleObject(RO.dwUser);                     //  ��������� �� ������
  Result.charPos:=RO.cp;                             //  ������� �������
end;

function TOleRTF.GetObjectCount: integer;
begin
  Result:=RichEditOle.GetObjectCount;
end;

function SetFrameCallback(dwCookie: Longint; pbBuff: PByte;
                 cb: Longint; var pcb: Longint): Longint; stdcall;
begin
  if cb > TFrame(dwCookie).Size-TFrame(dwCookie).Position then
    pcb:=TFrame(dwCookie).Size - TFrame(dwCookie).Position else pcb:=cb;
  if pcb>0 then
  begin
    Move(TFrame(dwCookie).Buf[TFrame(dwCookie).Position],pbBuff^,pcb);
    Inc(TFrame(dwCookie).Position,pcb);
  end;
  Result:=NoError;
end;

function TOleRTF.If13(st: string): boolean;   //  �� ������ �� #13#10 � ��-
var                                           //  �������� ������ st
  st1,st2:string;
begin
  Result:=true;                            //  ����� �� ��������
  if st='' then Exit;
  if st=#13#10 then begin Result:=false;exit;end;
  st1:=Copy(Text,0,SelStart);     //  ����� �� �����������
  st2:=Copy(Text,SelStart+SelLength+1,Length(Text)-SelStart-SelLength);//�����
  if Length(st2)=0 then Exit;
  if (Pos(#13#10,st)<>0) then
    if (((st2[1] in ['1'..'9']) and (st2[2]='.')) or (st2[1]='-')) then
      Result:=false;
end;

function TOleRTF.IfNum(st: string): boolean;      // ���-�� � ��������� �����
var
  st1,st2:string;
  n1,n2:integer;
begin                                           //  ������ � ������
  Result:=true;                                 //  ����� �� ��������
  if st='' then Exit;
  if (Pos('1.',st)<>0) or(Pos('2.',st)<>0) or(Pos('3.',st)<>0) or
     (Pos('4.',st)<>0) or(Pos('5.',st)<>0) or(Pos('6.',st)<>0) or
     (Pos('7.',st)<>0) or(Pos('8.',st)<>0) or(Pos('9.',st)<>0) or
     (Pos('-',st)<>0) then Result:=false ;
  st1:=Copy(Text,0,SelStart);     //  ����� �� �����������
  n1:=Length(st1);
  //  ����� ����� ����������� �������
  st2:=Copy(Text,SelStart+SelLength+1,Length(Text)-SelStart-SelLength);//�����
  n2:=Length(st2);
  //  ��������,�� ������ �� ��������� ������ ������ � ���������� �����
  if n1>=1 then
    if (st[1]='.') and (st1[Length(st1)] in ['1'..'9']) then Result:=false;
  if n2>=1 then
    if (st[Length(st)] in ['1'..'9']) and (st2[1]='.') then Result:=false;
end;

procedure TOleRTF.InsertMacros(num: integer);
begin
  SendMessage(Handle,EM_REPLACESEL,1,DWORD(Macroses[num])+13);
end;

procedure TOleRTF.RestoreFrame;
var
  ES:TEditStream;
  k:integer;
begin
  ES.dwError:=0;
  ES.dwCookie:=DWORD(FFrame);
  ES.pfnCallback:=@SetFrameCallback;
  FFrame.Position:=0;                             //  ������ � ������ ������
  SendMessage(Handle,EM_STREAMIN,SF_RTF,DWORD(@ES));
  if FFrame.FObjectList=nil then Exit;
  for k:=0 to FFrame.FObjectList.Count-1 do       //  �������� �������
    Embed(TOleObject(FFrame.FObjectList[k]));
  Modified:=false;                                //  �.�. ����� ���������
  SetSel(0,0);
end;                                              //  Modified ����� true

procedure TOleRTF.SetFrame(Frame: TFrame);
begin
  FFrame:=Frame;                                  //  �������� ����
  RestoreFrame;                                   //  ��������� � RTF
end;

procedure TOleRTF.UpdateFrame;
var
  ES:TEditStream;
  n,k:integer;
begin                                             //  �������������� ����
  FillChar(FFrame.Buf,SizeOf(FFrame.Buf),0);
  FFrame.FObjectList:=TObjectList.Create;
  FFrame.Size:=0;                        //  ������ � ������ ������
  ES.dwError:=0;
  ES.pfnCallback:=@GetFrameCallback;
  ES.dwCookie:=DWORD(FFrame);
  n:=GetObjectCount;                     //  ����� ���������� ��������
  for k:=0 to n-1 do
    FFrame.FObjectList.Add(GetObject(k)); //  ��������� ������� � ������
  Sendmessage(Handle,EM_STREAMOUT,SF_RTFNOOBJS,DWORD(@ES));
end;

begin
  CoInitialize(nil);
end.
