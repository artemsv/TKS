{$O-}
unit OprRTF;                      //  дата создания 6.0:  27.11.02

interface

uses Windows,UOleRTF;

type
  TOprosRTF=class(TOleRTF)
  private
    FRight:integer;
    FD:DWORD;
    HasRed:boolean;           //  true-имеется подсвеченный номер вопроса
  protected
    function WndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
    function DoCommand(Wparam,LParam:DWORD):boolean;override;
    function DoCharDown(WParam,LParam:DWORD):boolean;override;
    function DoKeyDown(WParam,LParam:DWORD):boolean;override;
    procedure DoMouseMove(Wparam,LParam:DWORD);
    procedure DoLDown(Wparam,LParam:DWORD);
    procedure Initial;override;
    function DoRTFCut:boolean;override;
    function DoRTFClear:boolean;override;
    function DoRTFCopy:boolean;override;
    function DoRTFPaste:boolean;override;
    procedure DoPopup(Wparam,LParam:DWORD);override;
  public
    function Shuffle(d:integer):DWORD;    //  мешает блоки и возвр.
    property D:DWORD read FD;
  end;

implementation

uses
  Messages,RichEdit,SysUtils,WinFunc,MConst;

{$R 'RES\OprRTF.res' }

{ TOprosRTF }

function TOprosRTF.DoCharDown(WParam, LParam: DWORD): boolean;
begin
  if Wparam in [49..57] then
    SendMessage(Parent.Handle,WM_COMMAND,CM_QUESTION,WParam-48);
  Result:=true;
end;

function TOprosRTF.DoCommand(Wparam, LParam: DWORD): boolean;
begin
  Result:=false;
  if (WParam >=10001) and (WParam<=10001+FD) then 
  begin
    if Wparam-10000=FRight then
    SendMessage(Parent.Handle,WM_COMMAND,CM_QUESTION,FRight) else
    SendMessage(Parent.Handle,WM_COMMAND,CM_QUESTION,$FF);
    Result:=true;
  end;
end;

function TOprosRTF.DoKeyDown(WParam, LParam: DWORD): boolean;
begin
  Result:=true;
end;

procedure TOprosRTF.DoLDown(Wparam, LParam: DWORD);
var
  k,m:integer;
  TP:TPoint;
begin
  for k:=1 to FD+1 do
  begin
    m:=FindText(IntToStr(k)+'.',0,4000,FT_MATCHCASE);
    SendMessage(Handle,EM_POSFROMCHAR,DWORD(@TP),m);
    if (HIWORD(LParam)in[TP.y..TP.y+14])and(LOWORD(LParam)in[0..10]) then
    begin
      if k=FRight then
      SendMessage(Parent.Handle,WM_COMMAND,CM_QUESTION,FRight) else
      SendMessage(Parent.Handle,WM_COMMAND,CM_QUESTION,$FF);
      Exit;
    end;
  end;
end;

procedure TOprosRTF.DoMouseMove(Wparam,LParam:DWORD);
var
  n,k:integer;
  TP:TPoint;

  procedure SetNumColor(n:DWORD;Color:COLORREF);
  var CF,oldCF:TCharFormat;
  begin
    SetSel(n,n+2);
    GetCharFormat(true,oldCF);
    CF:=oldCF;
    CF.crTextColor:=Color;
    CF.dwMask:=CF.dwMask or CFM_COLOR;
    CF.dwEffects:=CF.dwEffects and not CFE_AUTOCOLOR;
    SetCharFormat(SCF_SELECTION,CF);
    SetSel(n,n);  //  предотвращает появление выделения в последнем вопросе
  end;

begin
  SetCursor(LoadCursor(MainInstance,PChar(9802)));    //  курсор стрелка
  for k:=1 to FD+1 do
  begin
      //  нашли позицию очередного номера строки
    n:=FindText(IntToStr(k)+'.',0,4000,FT_MATCHCASE);
    SendMessage(Handle,EM_POSFROMCHAR,DWORD(@TP),n);
    if (HIWORD(LParam)in[TP.y..TP.y+14])and(LOWORD(LParam)in[0..10]) then
    begin
      SetNumColor(n,COLOR_NUM_ACTIVE);
      HasRed:=true;
//      Exit;
    end else
      SetNumColor(n,COLOR_NUM_PASSIVE);
  end;
end;

procedure TOprosRTF.DoPopup(Wparam, LParam: DWORD);
var
  TrayPopupMenu,TPMenu:HMENU;
  p:TPoint;
  k:integer;
begin
  TPMenu:=LoadMenu (MainInstance,PChar (702));
  TrayPopupMenu:=GetSubMenu (TPMenu,0);
  for k:=2 to FD+1 do
    AppendMenu(TrayPopupMenu,MF_BYPOSITION,10000+k,
       PChar('Правильный ответ-'+IntToStr(k)));
  GetCursorPos(P);
  TrackPopupMenu(TRayPopupMenu,TPM_LEFTBUTTON,P.X,P.Y,0,Handle,nil);
end;

function TOprosRTF.DoRTFClear: boolean;
begin
  Result:=true;
end;

function TOprosRTF.DoRTFCopy: boolean;
begin
  Result:=true;
end;

function TOprosRTF.DoRTFCut: boolean;
begin
  Result:=true;
end;

function TOprosRTF.DoRTFPaste: boolean;
begin
  Result:=true;
end;

procedure TOprosRTF.Initial;
begin
  inherited;
  HasRed:=false;
end;

function TOprosRTF.Shuffle(d: integer): DWORD;
var
  TempRTF:TOleRTF;
  x,k,n,m:integer;
  Poss,a:array[0..20]of integer;
  pch:array[0..2]of char;
begin
  FD:=d;                                    //  количество неверных отв.
  Perform(WM_SETREDRAW,0,0);                //  запретили перерисовку
  Duplet(d+1,d+1,a);                        //  создали массив случайных
  for Result:=0 to d+1 do
    if a[Result]=d+1 then Break;            //  ищем номер прав. ответа
  FRight:=Result;
  TempRTF:=TOprosRTF.Create(Parent,ES_MULTILINE,0); //  создаем временный RTF
  TempRTF.SetFrame(Frame);                          //  уст.в нём свой кадр
  //  удаляем пустые строки (сам забыл зачем!!!)
  for k:=TempRTF.GetCount-1 downto TempRTF.WhichLine(TempRTF.FindText(
                          IntToStr(d+1)+'.',0,4000,FT_MATCHCASE))-2 do
    if TempRTF.Strings[k]='' then TempRTF.DeleteLine(k);
  // в настоящем RTF оставляем только вопрос и черту, остальное стираем
  x:=FindText('1.',0,3000,FT_MATCHCASE);
  SetSel(x,x+10000);                          //  выд.от '1.' до конца
  SendMessage(Handle,WM_CLEAR,0,0);           //  стерли от '1.' до конца
  //  вырезаем блоки из временного и вставляем в настоящий RTF
  for k:=1 to d+1 do
  begin
    n:=TempRTF.FindText(IntToStr(a[k])+'.',0,4000,FT_MATCHCASE);
    if a[k] = d+1 then m:=10000 else
    m:=TempRTF.FindText(IntToStr(a[k]+1)+'.',0,4000,FT_MATCHCASE);
    TempRTF.SetSel(n,m);
    TempRTF.Perform(WM_COPY,0,0);
    poss[k]:=GetCurCaretX;
    Perform(WM_PASTE,0,0);
  end;
  pch[1]:='.';pch[2]:=#0;
  for k:=1 to d+1 do
  begin
    SetSel(poss[k],poss[k]+2);
    pch[0]:=char(48+k);
    Perform(EM_REPLACESEL,1,DWORD(@pch));
  end;
  TempRTF.Free;
  Perform(WM_SETREDRAW,1,0);
//  SetSel(0,0);
  InvalidateRect(Handle, nil, false);
end;

function TOprosRTF.WndProc(Wnd: HWND; Msg, WParam, LParam: DWORD): DWORD;
begin
  Result:=0;
  case Msg of
    WM_SETFOCUS:;
    WM_MOUSEMOVE:DoMouseMove(WParam,LParam);
    WM_LBUTTONDOWN:DoLDown(WParam,LParam);
  else
    Result:=inherited WndProc(Wnd,Msg,Wparam,LParam);
  end;
end;

end.
