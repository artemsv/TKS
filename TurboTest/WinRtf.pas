{$O-}
unit WinRTF;                    //  Дата создания :  30.10.02.
                                //  Частичный экспорт из ComCtrls.pas  ;)
interface

{$R RES\WinRTF.res}

uses Streams,WinApp,Windows,RichEdit;

type
  TSearchType = (stWholeWord, stMatchCase);
  TSearchTypes = set of TSearchType;
  TNumberingStyle = (nsNone, nsBullet);

  TRtf=class(TWin)
  private
    FRow: Longint;
    FColumn: Longint;
    FInsert:boolean;
    procedure SetColumn(Value:integer);
    procedure SetRow(Value:integer);
    function GetRow:integer;
    function GetColumn:integer;
    function GetText: string;
    procedure SetSelText(const Value: string);
    procedure SetSelLength(Value: Integer);
    procedure SetText(const Value: string);
    procedure UpdateCaretPos;
    procedure UpdateInsertFlag;
  protected
    function WndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
    function GetModify: boolean;
    procedure SetModify(const Value: boolean);
    function DoCharDown(WParam,LParam:DWORD):boolean;virtual;
    function DoKeyDown(WParam,LParam:DWORD):boolean;virtual;
    function DoMouseMove(WParam,LParam:DWORD):boolean;virtual;
    function DoLDown(WParam,LParam:DWORD):boolean;virtual;
    function DoCommand(Wparam,LParam:DWORD):boolean;virtual;
    function GetSelStart:integer;
    procedure SetSelStart(const Value: Integer);
    function Get(Index: Integer): string;
    procedure Put(Index: Integer; const S: string);
    procedure DoPopup(WParam,LParam:DWORD);virtual;
    function DoEmbed:boolean;virtual;
    procedure InsertObject;
    procedure ScrollCaret;
    function DoRTFCut:boolean;virtual;
    function DoRTFClear:boolean;virtual;
    function DoRTFPaste:boolean;virtual;
    function DoRTFCopy:boolean;virtual;
  public
    constructor Create(AParent:TWin;AStyle,AExStyle:DWORD);virtual;
    procedure SetCharFormat(uFlags:DWORD;chf:TCharFormat);
    procedure GetCharFormat(fSelection: boolean;var CF:TCharFormat);
    procedure SetSel(startX,endX:integer);
    procedure SelectAll;virtual;
    procedure HideSelection(fShowHide:boolean);
    procedure SetBackColor(color:COLORREF);
    procedure DeleteLine(Index:integer);
    function  WhichLine(charPos:integer):integer;//  возвращает номер
                               //  строки,содержащей символ номер charPos
    procedure InsertLine(Index: Integer;const Line: string;PCF:Pointer=nil);
    procedure AddLine(const Line:string);
    function LineFromChar(Index:integer):integer;
    function GetLine(index:integer):PChar;
    function SaveToStream(TF:TFile):boolean;
    function LoadFromStream(TF:TFile):boolean;
    function DoOperation(st:string):boolean;virtual;    
    procedure SetTextBuf(Buffer: PChar);
    function GetTextBuf(Buffer: PChar; BufSize: Integer): Integer;
    function GetTextLen: Integer;
    function GetCaretPos:TPoint;
    function GetCount:integer;
    function GetSelLen:integer;
    function GetSelText:string;
    function GetSelTextBuf(Buffer: PChar; BufSize: Integer): Integer;
    function FindText(const SearchStr: string;
      StartPos, Length: Integer; Flags: integer): Integer;
    function GetCurCaretX:integer;        //  возвр.номер тек.симв.с начала
    function PosFromChar(charPos:integer):TPoint;
    function CharFromPos(LParam:DWORD):DWORD;
    procedure SetSelLen(Value: Integer);
    procedure SetCaretPos(Point:TPoint);
    procedure Clear;
    function  GetFormat:DWORD;
    procedure SetPara(var Para:TParaFormat);
    procedure GetPara(var Para:TParaFormat);
    procedure InitPara(var Para:TParaFormat);
    procedure SetBullet(Value: TNumberingStyle);
    function GetFirstIndent:longint;
    procedure SetFirstIndent(value:integer);
    function GetLeftIndent:longint;
    procedure SetLeftIndent(value:integer);
    function GetRightIndent:longint;
    procedure SetRightIndent(value:integer);
    property Strings[Index: Integer]: string read Get write Put; default;
    property Modified:boolean read GetModify write SetModify;
    property Row: Longint read GetRow write SetRow;
    property Column: Longint read GetColumn write SetColumn;
    property SelLength: Integer read GetSelLen write SetSelLen;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelText: string read GetSelText write SetSelText;
    property Text: string read GetText write SetText;
    property Insert :boolean read FInsert;
  end;

implementation

uses MConst,Messages,SysUtils;

function OpenCallback(dwCookie: Longint; pbBuff: PByte;
  cb: Longint; var pcb: Longint): Longint; stdcall;
var TF:TFile;
begin
  TF:=TFile(dwCookie);
  pcb:=_lread(TF.Handle,pbBuff, cb);
  if pcb=-1 then
  begin
   pcb:=0;
   Result := 1;
  end else Result := NoError;
end;

function SaveCallback(dwCookie: Longint; pbBuff: PByte;
  cb: Longint; var pcb: Longint): Longint; stdcall;
var
  TF:TFile;
begin
  TF:=TFile(dwCookie);
  pcb:= _lwrite(TF.Handle,Pointer(pbBuff), cb);
  if pcb<>cb then
  begin
   if pcb=-1 then pcb:=0;
   Result := 2;
  end else Result := NoError;
end;

{ TRtf }

function RtfProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;stdcall;
var
  Rtf:TRtf;
begin
  Rtf:=TRtf(GetWindowLong(Wnd,GWL_USERDATA));
  if Rtf<>nil
    then Result:=Rtf.WndProc(Wnd,Msg,WParam,LParam)
//    else Result:=CallWindowProc(Pointer(OldRtfProc),Wnd,Msg,WParam,LParam);
end;

procedure TRtf.AddLine(const Line: string);
begin

end;

function TRtf.CharFromPos(LParam: DWORD): DWORD;
begin
  Result:=SendMessage(Handle,EM_CHARFROMPOS,0,LParam);
  //  старшее слово -zero-bazed line index,младшее - zero-bazed char. index
end;

procedure TRtf.Clear;
begin
  SetWindowText(Handle,'');
  Modified:=false;
end;


constructor TRtf.Create(AParent: TWin;AStyle,AExStyle:DWORD);
var
  hRTFLib:THandle;
begin
  hRTFLib:= LoadLibrary('riched32.dll');
  if hRTFLib=0 then Halt;
  inherited Create(WS_CHILD or AStyle,AExStyle,0,0,0,0,Aparent,nil,'RICHEDIT');
  SetWindowLong(Handle,GWL_USERDATA,Longint(Self));
  oldProc:=Pointer(SetWindowLong(Handle,GWL_WNDPROC,longint(@RtfProc)));
  FInsert:=true;
  UpdateCaretPos;
  UpdateInsertFlag;
  SetFocus;
end;

procedure TRtf.DeleteLine(Index:integer);
const
  Empty: PChar = '';
var
  Selection: TCharRange;
begin
  if Index < 0 then Exit;
  Selection.cpMin := SendMessage(Handle, EM_LINEINDEX, Index, 0);
  if Selection.cpMin <> -1 then
  begin
    Selection.cpMax := SendMessage(Handle, EM_LINEINDEX, Index + 1, 0);
    if Selection.cpMax = -1 then
      Selection.cpMax := Selection.cpMin +
        SendMessage(Handle, EM_LINELENGTH, Selection.cpMin, 0);
    SendMessage(Handle, EM_EXSETSEL, 0, Longint(@Selection));
    SendMessage(Handle, EM_REPLACESEL, 0, Longint(Empty));
  end;
end;

function TRtf.DoCharDown(WParam,LParam: DWORD): boolean;
begin
  CallWindowProc(OldProc,Handle,WM_CHAR,Wparam,LParam);
  UpdateCaretPos;
  Result:=true;
end;


function TRtf.DoCommand(Wparam, LParam: DWORD): boolean;
begin
  Result:=false;
end;

function TRtf.DoKeyDown(WParam, LParam: DWORD): boolean;
begin
  CallWindowProc(OldProc,Handle,WM_KEYDOWN,Wparam,LParam);
  UpdateCaretPos;
  if WParam=45 then UpdateInsertFlag;
  Result:=true;
end;

function TRtf.DoLDown(WParam, LParam: DWORD): boolean;
begin
  Result:=false
end;

function TRtf.DoMouseMove(WParam, LParam: DWORD): boolean;
begin
  Result:=false
end;

procedure TRtf.DoPopup(WParam,LParam:DWORD);
var
  TrayPopupMenu,TPMenu:HMENU;
  p:TPoint;
begin
  TPMenu:=LoadMenu (MainInstance,PChar (701));
  TrayPopupMenu:=GetSubMenu (TPMenu,0);
  GetCursorPos(P);

  if not (DoOperation(SelText) and (Length(SelText)<>0)) then
  begin
    EnableMenuItem(TRayPopupMenu,0,MF_GRAYED or MF_BYPOSITION); //  Вырезать
    EnableMenuItem(TRayPopupMenu,1,MF_GRAYED or MF_BYPOSITION); //  Копировать
    EnableMenuItem(TRayPopupMenu,3,MF_GRAYED or MF_BYPOSITION); //  Удалить
  end;
  if SelText=Text then
  begin
    EnableMenuItem(TRayPopupMenu,0,MF_ENABLED or MF_BYPOSITION); //  Вырезать
    EnableMenuItem(TRayPopupMenu,1,MF_ENABLED or MF_BYPOSITION); //  Копировать
    EnableMenuItem(TRayPopupMenu,3,MF_ENABLED or MF_BYPOSITION); //  Удалить
  end;
  if not DoEmbed then
    EnableMenuItem(TRayPopupMenu,7,MF_GRAYED or MF_BYPOSITION);
  if Perform(EM_CANUNDO,0,0)=0 then
    EnableMenuItem(TRayPopupMenu,4,MF_GRAYED or MF_BYPOSITION);

  TrackPopupMenu(TRayPopupMenu,TPM_LEFTBUTTON,P.X,P.Y,0,Handle,nil);
end;

function TRtf.DoRTFClear: boolean;
begin
  Result:=true;
end;

function TRtf.DoRTFCopy: boolean;
begin
  Result:=true;
end;

function TRtf.DoRTFCut: boolean;
begin
  Result:=true;
end;

function TRtf.DoRTFPaste: boolean;
begin
  Result:=true;
end;

function TRtf.FindText(const SearchStr: string; StartPos, Length: Integer;
  Flags: integer): Integer;
var
  Find: TFindText;
begin
  with Find.chrg do
  begin
    cpMin := StartPos;
    cpMax := cpMin + Length;
  end;
  Find.lpstrText := PChar(SearchStr);
  Result := SendMessage(Handle, EM_FINDTEXT, Flags, LongInt(@Find));
end;

function TRtf.Get(Index: Integer): string;
var
  Text: array[0..4095] of Char;
  L: Integer;
begin
  Word((@Text)^) := SizeOf(Text);
  L := SendMessage(Handle, EM_GETLINE, Index, Longint(@Text));
  if (Text[L - 2] = #13) and (Text[L - 1] = #10) then Dec(L, 2);
  SetString(Result, Text, L);
end;

function TRtf.GetCaretPos: TPoint;
var
  CharRange: TCharRange;
begin
  SendMessage(Handle, EM_EXGETSEL, 0, LongInt(@CharRange));
  Result.X := CharRange.cpMax;
  Result.Y := SendMessage(Handle, EM_EXLINEFROMCHAR, 0, Result.X);
  Result.X := Result.X - SendMessage(Handle, EM_LINEINDEX, -1, 0);
end;

procedure TRtf.GetCharFormat(fSelection: boolean;var CF:TCharFormat);
begin
  CF.cbSize:=SizeOf(TCharFormat);
  Perform(EM_GETCHARFORMAT,DWORD(fSelection),DWORD(@CF));
end;

function TRtf.GetColumn: integer;
begin
  Result :=SelStart - Perform(EM_LINEINDEX, -1, 0);
end;

function TRtf.GetCount: integer;
begin
  Result:=Perform(EM_GETLINECOUNT,0,0);
end;

function TRtf.GetCurCaretX: integer;
var
  CR:TCharRange;
begin
  SendMessage(Handle, EM_EXGETSEL, 0, LongInt(@CR));
  Result:=CR.cpMax;
end;

function TRtf.GetFirstIndent: longint;
var
  Paragraph: TParaFormat;
begin
  GetPara(Paragraph);
  Result := Paragraph.dxStartIndent div 20
end;

function TRtf.GetLeftIndent: longint;
var
  Paragraph: TParaFormat;
begin
  GetPara(Paragraph);
  Result := Paragraph.dxOffset div 20;
end;

function TRtf.GetLine(index: integer): PChar;
var pch:array[0..4095] of char;m:integer;
begin
  pch[0]:=#255;              //  первое слово в буфере-размер буфера
  pch[1]:=#16;               //  второй байт этого слова
  m:=(Perform(EM_GETLINE,Index,DWORD(@pch)));
  pch[m-2]:=#0;
  Result:=StrNew(pch);
end;

function TRtf.GetModify: boolean;
begin
  Result := SendMessage(Handle, EM_GETMODIFY, 0, 0) <> 0;
end;

procedure TRtf.GetPara(var Para: TParaFormat);
begin
  InitPara(Para);
  SendMessage(Handle, EM_GETPARAFORMAT, 0, LPARAM(@Para));
end;

function TRtf.GetRightIndent: longint;
var
  Paragraph: TParaFormat;
begin
  GetPara(Paragraph);
  Result := Paragraph.dxRightIndent div 20;
end;

function TRtf.GetRow: integer;
begin
  Result := Perform(EM_LINEFROMCHAR, -1, 0);
end;

function TRtf.GetSelLen: integer;
var
  CharRange: TCharRange;
begin
  SendMessage(Handle, EM_EXGETSEL, 0, Longint(@CharRange));
  Result := CharRange.cpMax - CharRange.cpMin;
end;

function TRtf.GetSelStart: integer;
var
  CharRange: TCharRange;
begin
  SendMessage(Handle, EM_EXGETSEL, 0, Longint(@CharRange));
  Result := CharRange.cpMin;
end;

function TRtf.GetSelText: string;
var
  Length: Integer;
begin
  SetLength(Result, GetSelLen + 1);
  Length := SendMessage(Handle, EM_GETSELTEXT, 0, Longint(PChar(Result)));
  SetLength(Result, Length);
end;

function TRtf.GetSelTextBuf(Buffer: PChar; BufSize: Integer): Integer;
var
  S: string;
begin
  S := GetSelText;
  Result := Length(S);
  if BufSize < Length(S) then Result := BufSize;
  StrPLCopy(Buffer, S, Result);
end;

function TRtf.GetText: string;
var
  Len: Integer;
begin
  Len := GetTextLen;
  SetString(Result, PChar(nil), Len);
  if Len <> 0 then GetTextBuf(Pointer(Result), Len + 1);
end;

function TRtf.GetTextBuf(Buffer: PChar; BufSize: Integer): Integer;
begin
  Result := Perform(WM_GETTEXT, BufSize, Longint(Buffer));
end;

function TRtf.GetTextLen: Integer;
begin
  Result := Perform(WM_GETTEXTLENGTH, 0, 0);
end;

procedure TRtf.HideSelection(fShowHide:boolean);
begin
  Perform(EM_HIDESELECTION,Ord(fShowHide),0);
end;

procedure TRtf.InitPara(var Para: TParaFormat);
begin
  FillChar(Para,SizeOf(Para),0);
  Para.cbSize:=SizeOf(Para);
end;

procedure TRtf.InsertLine(Index: Integer;const Line: string;PCF:Pointer=nil);
var
  L: Integer;
  Selection: TCharRange;
  Fmt: PChar;
  Str: string;
begin
  if Index >= 0 then
  begin
    Selection.cpMin := SendMessage(Handle, EM_LINEINDEX, Index, 0);
    if Selection.cpMin >= 0 then Fmt := '%s'#13#10
    else begin
      Selection.cpMin :=
        SendMessage(Handle, EM_LINEINDEX, Index - 1, 0);
      if Selection.cpMin < 0 then Exit;
      L := SendMessage(Handle, EM_LINELENGTH, Selection.cpMin, 0);
//      if L = 0 then Exit;
      Inc(Selection.cpMin, L);
      Fmt := #13#10'%s';
    end;
    Selection.cpMax := Selection.cpMin;
    SendMessage(Handle, EM_EXSETSEL, 0, Longint(@Selection));
    Str := Format(Fmt, [Line]);
    if PCF<>nil then SetCharFormat(SCF_SELECTION,TCharFormat(PCF^));
    SendMessage(Handle, EM_REPLACESEL, 0, LongInt(PChar(Str)));
    if SelStart <> (Selection.cpMax + Length(Str)) then
      raise Exception.Create('sRichEditInsertError');
  end;
end;

procedure TRtf.InsertObject;
begin
  MessageBox(Handle,'Не реализовано.',nil,$10);
end;

function TRtf.GetFormat: DWORD;
var
  Format:word;
  name:array[0..125] of char;
begin
  Result := 0;
  Format := EnumClipboardFormats(0);
  while Format <> 0 do
  begin
    GetClipboardFormatName(Format,name,120);
    if name=CF_RTF then
    begin
      Result := Format;
      Break;
    end
    else Format := EnumClipboardFormats(Format);
  end;
end;

function TRtf.LineFromChar(Index: integer): integer;
begin
  Result:=Perform(EM_EXLINEFROMCHAR,0,Index);
end;

function TRtf.LoadFromStream(TF:TFile): boolean;
var
  ES:EDITSTREAM;
begin
  Result:=true;
  ES.dwCookie:=DWORD(TF);
  ES.dwError:=0;
  ES.pfnCallback:=@OpenCallBack;
  Perform(EM_STREAMIN,SF_RTF,DWORD(@ES));
end;

function TRtf.PosFromChar(charPos: integer): TPoint;
begin
  SendMessage(Handle,EM_POSFROMCHAR,DWORD(@Result),charPos);
end;

procedure TRtf.Put(Index: Integer; const S: string);
var
  Selection: TCharRange;
begin
  if Index >= 0 then
  begin
    Selection.cpMin := SendMessage(Handle, EM_LINEINDEX, Index, 0);
    if Selection.cpMin <> -1 then
    begin
      Selection.cpMax := Selection.cpMin +
        SendMessage(Handle, EM_LINELENGTH, Selection.cpMin, 0);
      SendMessage(Handle, EM_EXSETSEL, 0, Longint(@Selection));
      SendMessage(Handle, EM_REPLACESEL, 0, Longint(PChar(S)));
    end;
  end;
end;

function TRtf.SaveToStream(TF:TFile): boolean;
var
  ES:EDITSTREAM;
begin
  Result:=true;
  ES.dwCookie:=DWORD(TF);
  ES.dwError:=0;
  ES.pfnCallback:=@SaveCallBack;
  Perform(EM_STREAMOUT,SF_RTF,DWORD(@ES));
end;

procedure TRtf.ScrollCaret;
begin
  Perform(EM_SCROLLCARET,0,0);
end;

procedure TRtf.SetBackColor(color: COLORREF);
begin
  Perform(EM_SETBKGNDCOLOR,0,color);
end;

procedure TRtf.SetBullet(Value: TNumberingStyle);
var
  Para:TParaFormat;
begin
  case Value of
    nsBullet: if GetLeftIndent < 10 then SetLeftIndent(10);
    nsNone: SetLeftIndent(0);
  end;
  InitPara(Para);
  with Para do
  begin
    dwMask := PFM_NUMBERING;
    wNumbering := Ord(Value);
  end;
  SetPara(Para);
end;

procedure TRtf.SetCaretPos(Point: TPoint);
begin
  SelStart := Perform(EM_LINEINDEX, Point.x, 0);
end;

procedure TRtf.SetCharFormat(uFlags:DWORD;chf: TCharFormat);
begin
  Perform(EM_SETCHARFORMAT,uFlags,DWORD(@chf));
end;

procedure TRtf.SetColumn(Value: integer);
begin
  { Get the length of the current line using the EM_LINELENGTH
    message. This message takes a character position as WParam.
    The length of the line in which that character sits is returned. }
  FColumn := Perform(EM_LINELENGTH, Perform(EM_LINEINDEX, GetRow, 0), 0);
  { If the FColumn is greater than the value passed in, then set
    FColumn to the value passed in }
  if FColumn > Value then
    FColumn := Value;
  // Now set SelStart to the newly specified position
  SelStart := Perform(EM_LINEINDEX, GetRow, 0) + FColumn;
end;

procedure TRtf.SetFirstIndent(value: integer);
var
  Paragraph: TParaFormat;
begin
  InitPara(Paragraph);
  with Paragraph do
  begin
    dwMask := PFM_STARTINDENT;
    dxStartIndent := Value * 20;
  end;
  SetPara(Paragraph);
end;


procedure TRtf.SetLeftIndent(value: integer);
var
  Paragraph: TParaFormat;
begin
  InitPara(Paragraph);
  with Paragraph do
  begin
    dwMask := PFM_OFFSET;
    dxOffset := Value * 20;
  end;
  SetPara(Paragraph);
end;

procedure TRtf.SetModify(const Value: boolean);
begin
  SendMessage(Handle, EM_SETMODIFY, Byte(Value), 0) 
end;

procedure TRtf.SetPara(var Para: TParaFormat);
begin
  SendMessage(Handle, EM_SETPARAFORMAT, 0, LPARAM(@Para));
end;


procedure TRtf.SetRightIndent(value: integer);
var
  Paragraph: TParaFormat;
begin
  InitPara(Paragraph);
  with Paragraph do
  begin
    dwMask := PFM_RIGHTINDENT;
    dxRightIndent := Value * 20;
  end;
  SetPara(Paragraph);
end;

procedure TRtf.SetRow(Value: integer);
begin
  SelStart := Perform(EM_LINEINDEX, Value, 0);
  FRow := SelStart;
end;

procedure TRtf.SetSel(startX, endX: integer);
begin
  Perform(EM_SETSEL,startX,endX);
end;

procedure TRtf.SetSelLen(Value: Integer);
begin
  SendMessage(Handle, EM_REPLACESEL, 0, Longint(PChar(Value)));
end;

procedure TRtf.SetSelLength(Value: Integer);
var
  CharRange: TCharRange;
begin
  SendMessage(Handle, EM_EXGETSEL, 0, Longint(@CharRange));
  CharRange.cpMax := CharRange.cpMin + Value;
  SendMessage(Handle, EM_EXSETSEL, 0, Longint(@CharRange));
  SendMessage(Handle, EM_SCROLLCARET, 0, 0);
end;

procedure TRtf.SetSelStart(const Value: Integer);
var
  CharRange: TCharRange;
begin
  CharRange.cpMin := Value;
  CharRange.cpMax := Value;
  SendMessage(Handle, EM_EXSETSEL, 0, Longint(@CharRange));
end;

procedure TRtf.SetSelText(const Value: string);
begin
  SendMessage(Handle, EM_REPLACESEL, 0, Longint(PChar(Value)));
end;

procedure TRtf.SetText(const Value: string);
begin
  if GetText <> Value then SetTextBuf(PChar(Value));
end;

procedure TRtf.SetTextBuf(Buffer: PChar);
begin
  Perform(WM_SETTEXT, 0, Longint(Buffer));
end;

procedure TRtf.UpdateCaretPos;
begin
  FRow:=GetRow;
  FColumn:=GetColumn;
  if Parent<>nil then SendMessage(Parent.Handle,WM_COMMAND,
          DOM_UPDATECARETPOS,MakeLong(FRow+1,FColumn+1));
end;

procedure TRtf.UpdateInsertFlag;
begin
  Finsert:=not FInsert;
  SendMessage(Parent.Handle,WM_COMMAND,DOM_UPDATEINSERTFLAG,DWORD(FInsert));
end;

function TRtf.WhichLine(charPos: integer): integer;
begin
  Result:=SendMessage(Handle,EM_LINEFROMCHAR,charPos,0);
end;

function TRtf.WndProc(Wnd: HWND; Msg, WParam, LParam: DWORD): DWORD;
begin
  Result:=0;
  case Msg of
    WM_CUT:if not DoRTFCut then Exit;
    WM_CLEAR:if not DoRTFClear then Exit;
    WM_COPY:if not DoRTFCopy then Exit;
    WM_PASTE:if not DoRTFPaste then Exit;
    WM_COMMAND:if DoCommand(WParam,LParam) then Exit else
      case WParam of
        DOM_CUT:begin Msg:=WM_CUT;if not DoRTFCut then Exit;end;
        DOM_COPY:begin Msg:=WM_COPY;if not DoRTFCopy then Exit;end;
        DOM_PASTE:begin Msg:=WM_PASTE;if not DoRTFPaste then Exit;end;
        DOM_DELETE:begin Msg:=WM_CLEAR;if not DoRTFClear then Exit;end;
        DOM_UNDO:Msg:=WM_UNDO;
        DOM_SELECTALL:SelectAll;
        DOM_ECUAT:SendMessage(Parent.Handle,WM_COMMAND,CM_ECUAT,0);
        DOM_BMP:SendMessage(Parent.Handle,WM_COMMAND,CM_BMP,0);
        DOM_REFRESH: SendMessage(Parent.Handle,WM_COMMAND,CM_REFRESH,0);
      end;
    WM_MOUSEMOVE:if  DoMouseMove(WParam,LParam) then Exit;
    WM_LBUTTONDOWN:if DoLDown(Wparam,LParam) then Exit;
    WM_CHAR:
      if DoCharDown(Wparam,LParam) then Exit;
    WM_KEYDOWN:if DoKeyDown(Wparam,LParam)then Exit;
    WM_RBUTTONDOWN,WM_CONTEXTMENU: DoPopup(Wparam,LParam);
    WM_DROPFILES:SendMessage(Parent.Handle,WM_DROPFILES,WParam,0);
  end;
  Result:=CallWindowProc(OldProc,Wnd,Msg,Wparam,LParam);
  if Msg=WM_LBUTTONDOWN then UpdateCaretPos;
end;

function TRtf.DoOperation(st: string): boolean;
begin
  Result:=true;
end;

function TRtf.DoEmbed: boolean;
begin
  Result:=false;
end;

procedure TRtf.SelectAll;
begin
  if Parent.Perform(WM_COMMAND,DOM_CANSELECTALL,0)=0 then  //  если можно
    SetSel(0,Length(Text));
end;

end.

