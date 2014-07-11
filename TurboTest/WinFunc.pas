{$O-}
unit WinFunc;                     //  Дата создания: Май 2002
                     //  Функции - оболочки для стандартных функций Windows
interface

uses Windows,CommDlg,Richedit,MTypes;

function GetColor(Wnd:HWND;old:COLORREF):COLORREF;
function GetFont(Wnd:HWND;var LF:TLogFont;var color:COLORREF):boolean;
function GetFileName(Wnd:HWND;filtr,inv:PChar;var st:PChar):boolean;
function Sstr(N:integer):string;
procedure Duplet(interval,ckolko:integer;VAR a:array of integer);
function Baland(DC:HDC):integer;
procedure Box;
function Key(KeyData:longint): TState;
function GetRect(x1,y1,x2,y2:word):TRect;
function LoadResStr(ID,Size:DWORD):PChar;
function Point(AX, AY: Integer): TPoint;
function SmallPoint(AX, AY: SmallInt): TSmallPoint;
function Rect(ALeft, ATop, ARight, ABottom: Integer): TRect;
function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect;
function GetAffix(num:integer):string;
function GetTim(Tim:integer):string;
procedure ShowLoadMsg(Handle:HWND);
procedure EraseLoadMsg(Handle:HWND);
function GetCurrentDateTime: TDateTime;
procedure CenterWindow(Wnd:HWND);
procedure Registrated(Handle:HWND);

implementation

uses Registry,SysUtils,Messages;

function GetColor(Wnd:HWND;old:COLORREF):COLORREF;
var
  C:TChooseColor;
  mas:array[0..16] of COLORREF;
  k:byte;
begin
  FillChar(mas,SizeOf(mas),0);
  for k:=0 to 16 do mas[k]:=GetsysColor(k);
  FillChar(C,SizeOf(c),0);
  C.lStructSize:=SizeOf(c);
  C.hWndOwner:=Wnd;
  C.rgbResult:=old;
  C.lpCustColors:=@mas;
  if ChooseColor(C) then
    Result:=C.rgbResult
    else Result:=old
end;

function GetFont(Wnd:HWND;var LF:TLogFont;var color:COLORREF):boolean;
var
  CF:TChooseFont;
begin
  LF.lfWidth:=400;
  LF.lfEscapement:=0;
  LF.lfOrientation:=0;
  LF.lfWeight:=FW_NORMAL;
//  LF.lfItalic:=0;
  //LF.lfUnderline:=0;
  //LF.lfStrikeOut:=0;
  //LF.lfCharSet:=ANSI_CHARSET;
  LF.lfOutPrecision:=OUT_DEFAULT_PRECIS;
  LF.lfClipPrecision:=CLIP_DEFAULT_PRECIS;
  LF.lfQuality:=DEFAULT_QUALITY;
//  LF.lfPitchAndFamily:=DEFAULT_PITCH or FF_MODERN;

  FillChar(CF,SizeOf(CF),0);
  cf.lStructSize:=SizeOf(CF);
  CF.hWndOwner:=Wnd;
  CF.hDC:=0;
  CF.rgbColors:=color;
  CF.lpLogFont:=@LF;
  CF.hInstance:=MainInstance;
  CF.Flags:=CF_NOFACESEL or CF_SCREENFONTS or
                         CF_PRINTERFONTS or CF_APPLY or CF_EFFECTS;
  Result:=ChooseFont(CF);
  if not Result then Exit ;
  LF:=CF.lpLogFont^;
  color:=CF.rgbColors;
end;

function OpenFileWndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;
begin
  Result:=0;
end;

function GetFileName(Wnd:HWND;filtr,inv:PChar;var st:PChar):boolean;
var
  OpenFN: TOpenFileName;
  h:array [0..123] of char;
  buffer:array [0..127] of char;
begin
  Result:=false;
  FillChar(OpenFN,SizeOf(TOpenFileName),0);
  StrMove(h,inv,StrLen(inv)+1);
  OpenFN.hInstance     := MainInstance;
  OpenFN.hwndOwner     := Wnd;
  OpenFN.lpstrFilter   := filtr;
  OpenFN.nFilterIndex:=1;
  OpenFN.lStructSize   := sizeof(TOpenFileName);
  OpenFN.lpstrFile     := h;
  OpenFN.lpstrTitle:='Выберите файл темы';
  GetCurrentDirectory(128,buffer);
  OpenFN.lpstrInitialDir:=buffer;
  OpenFN.nMaxFile      := SizeOf(h);
  OpenFN.lpstrDefExt   := nil;
  OpenFN.flags         := OFN_EXPLORER or OFN_FILEMUSTEXIST or
                   OFN_NOREADONLYRETURN or OFN_HIDEREADONLY or OFN_ENABLEHOOK;
  OpenFN.lpfnHook:=@OpenFileWndProc;
  if not GetOpenFileName(OpenFN) then Exit;
  st:=StrNew(h);
  Result:=true;
end;                     

procedure Box;
begin
  MessageBox(0,'Отладка','Delphi 5',0);
end;

function Sstr(N:integer):string;
begin
  Str(N,Result)
end;

procedure Duplet(interval,ckolko:integer;var a:array of integer);
var
  n,k,r : integer;
  dupl  : boolean;
begin
   if (ckolko=0) or (interval<ckolko) then
      raise Exception.Create('Error in Duplet!!!');
   for k:=Low(a) to High(a) do a[k]:=0;
   Randomize;
   n:=1;
   repeat
     r:=Random(interval)+1;
     dupl:=false;
     for k:=1 to n do if r=a[k] then dupl:=true;
     if dupl then Continue;			{Ґб«Ё Ї®ўв®аповбп,в® б­®ў }
     a[n]:=r;Inc(n)
   until n=ckolko+1;
end;

function Baland(DC:HDC):integer;
var Size:TSize;
begin
  GetTextExtentPoint32(DC,'X',1,Size);
  Result:=Size.cy
end;

function Key(KeyData:longint): TState;
const
  AltMask = $20000000;
begin
  Result := [];
  if GetKeyState(VK_SHIFT) < 0 then Include(Result, ssShift);
  if GetKeyState(VK_CONTROL) < 0 then Include(Result, ssCtrl);
end;

function GetRect(x1,y1,x2,y2:word):TRect;
begin
  SetRect(Result,x1,y1,x2,y2);
end;

function LoadResStr(ID,Size:DWORD):PChar;
begin
  Result:=StrAlloc(Size+1);
  LoadString(MainInstance,ID,Result,Size);
end;

function Point(AX, AY: Integer): TPoint;
begin
  with Result do
  begin
    X := AX;
    Y := AY;
  end;
end;

function SmallPoint(AX, AY: SmallInt): TSmallPoint;
begin
  with Result do
  begin
    X := AX;
    Y := AY;
  end;
end;

function Rect(ALeft, ATop, ARight, ABottom: Integer): TRect;
begin
  with Result do
  begin
    Left := ALeft;
    Top := ATop;
    Right := ARight;
    Bottom := ABottom;
  end;
end;

function Bounds(ALeft, ATop, AWidth, AHeight: Integer): TRect;
begin
  with Result do
  begin
    Left := ALeft;
    Top := ATop;
    Right := ALeft + AWidth;
    Bottom :=  ATop + AHeight;
  end;
end;

function GetAffix(num:integer):string;
var
  st:string;
begin
  st:=IntToStr(num);
  case st[Length(st)] of
    '0','5'..'9':Result:='ов';
    '1':Result:='';
  else
    Result:='а'
  end;
  if num in [11..14] then Result:='ов'
end;

function GetTim(Tim:integer):string;
var
  sec,min,hour:integer;
  st1,st2:string;
begin
  hour:=tim div 3600;
  tim:=tim mod 3600;
  if hour=0 then st1:='00:' else
  if Hour<10 then st1:='0'+IntToStr(hour)+':' else st1:=IntToStr(hour)+':';
  min:=tim div 60;
  if min<10 then st1:=st1+'0';
  st1:=st1+IntToStr(min)+':';
  sec:=tim mod 60;
  if sec<10 then st1:=st1+'0';
  Result:=st1+IntToStr(sec);
end;

procedure ShowLoadMsg(Handle:HWND);
var
  DC:HDC;
  R:TRect;
  x,y:integer;
  B:HBRUSH;
begin
  DC:=GetDC(Handle);
  GetWindowRect(Handle,R);
  x:=(R.Right-R.Left)div 2;
  y:=(R.Bottom-R.Top) div 2;
  SetBkMode(DC,TRANSPARENT);
  Rectangle(DC,x-80,y-30,x+80,y+30);
  SetRect(R,x-80+1,y-30+1,x+80-1,y+30-1);
  B:=CreateSolidBrush($FF);
  FillRect(DC,R,B);
  TextOut(DC,x-80+30,y-15,'Идет загрузка!!!',14);
  ReleaseDC(DC,Handle);
  DeleteObject(B);
end;

procedure EraseLoadMsg(Handle:HWND);
var
  R:TRect;
begin
  GetWindowRect(Handle,R);
  InvalidateRect(Handle,@R,true);
end;

function GetCurrentDateTime: TDateTime;
var
  SystemTime: TSystemTime;
begin
  GetLocalTime(SystemTime);
  Result := SystemTimeToDateTime(SystemTime);
end;

procedure CenterWindow(Wnd:HWND);
var
  rc:TRect;
begin
  GetWindowRect(Wnd, rc);
  SetWindowPos(Wnd, 0,
     ((GetSystemMetrics(SM_CXSCREEN) - (rc.right - rc.left)) div 2),
     ((GetSystemMetrics(SM_CYSCREEN) - (rc.bottom - rc.top)) div 2),
     0, 0, SWP_NOSIZE or SWP_NOACTIVATE);
end;

procedure Registrated(Handle:HWND);
var
  Reg:TRegistry;
begin
  Exit;
  Reg := TRegistry.Create;
  try

    Reg.RootKey := HKEY_CURRENT_USER;
    if not Reg.OpenKey('\Software\TurboTest\LocalServer',false) then
    begin
      MessageBox(Handle,'Программа не зарегистрирована','TurboTest',0);
      Halt;
    end;
{    Reg.RootKey:=HKEY_LOCAL_MACHINE;
    if not Reg.OpenKey('\System\CurrentControlSet\Services\Microsoft\Windows',false) then
    begin
      MessageBox(Handle,'Программа не зарегистрирована','TurboTest',0);
      Halt;
    end;}
  finally
    Reg.CloseKey;
    Reg.Free;
  end;
end;

end.

