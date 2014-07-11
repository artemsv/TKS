{$O-}
unit WinCtrl;                        //  дата создани€:  07.05.02

interface
                                     //  стандартные элементы управлени€

uses WinApp,Windows,CommCtrl,RichEdit,Classes,Messages,SysUtils;

type
  TToolButton=class;

  TToolBar=class(TWin)
  protected
    function GetHandle(AExStyle:DWORD;AClassName,AName:PChar;AStyle:DWORD;
             x,y,cX,cY:integer;Wnd:HWND;AMenu:HMENU;MainInstance:DWORD;
              LParam:Pointer):HWND;override;
  public
    constructor Create(AParent:TWin);virtual;
    procedure LoadBitmaps(const bitmaps:array of integer);
    procedure ToolTip(Buttons: PTBButton;Num:dword);
    function WndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
    procedure WMSize(Wparam,LParam:DWORD);
    procedure Separator;
    function GetButtonIndex(Index:word):TToolButton;
    function GetButtonCmd(ACmd:word):TToolButton;
  end;

  TToolButton=class
  private
    FParent:TToolBar;
    FID:DWORD;
    FBmpID,FBmpDis:DWORD;
  public
    Hint:array[0..30] of char;
    constructor Create(AParent:TToolBar;AID,ABmpID,ABmpDis:DWORD;AHint:PChar);
    procedure ChangeImage(ResID:DWORD);
    procedure Enable;
    procedure Disable;
    procedure Hide;
    procedure Show;
    function IsEnabled:boolean;
  end;

  TStatusBar=class(TWin)
  protected
    function WndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
    function GetHandle(AExStyle:DWORD;AClassName,AName:PChar;AStyle:DWORD;
             x,y,cX,cY:integer;Wnd:HWND;AMenu:HMENU;MainInstance:DWORD;
              LParam:Pointer):HWND;override;
  public
    constructor Create(AParent:TWin);virtual;
    procedure Clear(num:DWORD=256);          //  чистит панель num (или все)
    procedure SetParts(const a:array of integer);
    procedure SetText(num:DWORD;pch:PChar);
    procedure WMSize(Wparam,LParam:DWORD);
  end;

  TScrollBar=class(TWin)
  protected
    function GetClassname:PChar;override;
  end;

  TGroupBox=class(TWin)
  public
    constructor Create(AParent:TWin;x,y,cx,cy:integer;ALabel:PChar=nil);
  end;

  TButton=class(TWin)
  protected
    function GetClassName:PChar;override;
  public
    constructor Create(AParent:TWin;x,y,cx,cy:integer;AName:PChar;AID:word);
  end;

  TRadio=class(TWin)
  public
    constructor Create(AParent:TWin;x,y,cx,cy:integer;AName:PChar;AID:word;AGroup:boolean=false);
  end;

  TCheckBox=class(TWin)
  public
    constructor Create(AParent:TWin;x,y,cx,cy:integer;AName:PChar;AID:word);
  end;

  TComboBox=class(TWin)
  public
    constructor Create(AParent:TWin;Style:DWORD;x,y,x1,y1,AID:word);virtual;
    procedure AddItem(Item:PChar);
    procedure AddStrings(List:TStrings);
    procedure SetCurSel(Index:integer);
    function GetCurSel:integer;
    function GetSelItem:PChar;
    function FindString(pch:PChar):integer;
  end;

  TListBox=class(TWin)
  public
    constructor Create(AParent:TWin;Style:DWORD;x,y,x1,y1,AID:word);virtual;
    procedure AddItem(Item:PChar);
    procedure AddStrings(List:TStrings);
    procedure SetCurSel(Index:integer);
    function GetCurSel:integer;
    function GetSelItem:PChar;
  end;

  TEdit=class(TWin)
  public
    constructor Create(AParent:TWin;Style:DWORD;x,y,x1,y1,AID:word);virtual;
  protected
    function WndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
  end;

implementation

var
  lpfnWndProc:Pointer;
  colMap:COLORMAP;

function ToolBarProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;stdcall;
var
  ToolBar:TToolBar;
begin
  ToolBar:=TToolBar(GetWindowLong(Wnd,GWL_USERDATA));
  if ToolBar<>nil then Result:=ToolBar.WndProc(Wnd,Msg,WParam,LParam);
//  else Result:=CallWindowProc(Pointer(OldStatProc),Wnd,Msg,WParam,LParam);
end;

constructor TToolBar.Create(AParent:TWin);
begin
  inherited Create( WS_CHILD or WS_VISIBLE or
                    TBSTYLE_TOOLTIPS or
                    TBSTYLE_FLAT or            //  опасный стиль  ;(
                    TBSTYLE_TRANSPARENT or
                    CCS_TOP or
                    CCS_ADJUSTABLE,
                    0,0,0,0,0,AParent,nil,'ToolBarWindow32');
  SetWindowLong(Handle,GWL_USERDATA,Longint(Self));
  oldProc:=Pointer(SetWindowLong(Handle,GWL_WNDPROC,DWORD(@ToolBarProc)));
  Perform(TB_BUTTONSTRUCTSIZE, sizeof(TTBBUTTON), 0);   //  об€зательно !!!
end;

function TToolBar.WndProc(Wnd: HWND; Msg, WParam, LParam: DWORD): DWORD;
begin
  if (Msg=WM_COMMAND) then             //  пересылаем родительскому окну
    SendMessage(Parent.Handle,Msg,Wparam,LParam)
  else Result:=CallWindowProc(Pointer(OldProc),Wnd,Msg,Wparam,LParam);
end;


procedure TToolBar.ToolTip;
var  ti:TOOLINFO;k:integer;pch:array[0..125] of char;
begin
{  WndToolTip:= }CreateWindowEx(0, TOOLTIPS_CLASS, 0, TTS_ALWAYSTIP,
		CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT,
                Parent.Handle, 0,0, 0);
	ti.cbSize := sizeof(TOOLINFO);
	ti.hwnd   := Handle;
	ti.hinst  := 0;
	ti.uFlags := TTF_SUBCLASS;
        for k:=0 to Num-1 do
	  if (Buttons.fsStyle = TBSTYLE_BUTTON) then
          begin
            SendMessage(Handle, TB_GETITEMRECT, k, LPARAM(@ti.rect));
            LoadString(0, Buttons.dwData, pch, sizeof(pch));
            ti.uId      := Buttons.idCommand;
	    ti.lpszText := pch;
//            SendMessage(WndToolTip, TTM_ADDTOOL, 0,LPARAM(@ti));
          end;
end;

procedure TToolBar.WMSize(Wparam, LParam: DWORD);
begin
  SendMessage(Handle,WM_SIZE,WParam,LParam);
end;

procedure TToolBar.Separator;
var
  TBB:TTBButton;
begin
  TBB.fsState:=TBSTATE_ENABLED;
  TBB.dwData:=0;
  TBB.bReserved[1]:=0;
  TBB.bReserved[2]:=0;
  TBB.iString:=0;
  TBB.iBitmap:=0;
  TBB.idCommand:=0;
  TBB.fsStyle:=TBSTYLE_SEP;
  Perform(TB_ADDBUTTONS, 1, lParam(@TBB));
end;

function TToolBar.GetHandle(AExStyle: DWORD; AClassName, AName: PChar;
  AStyle: DWORD; x, y, cX, cY: integer; Wnd: HWND; AMenu: HMENU;
  MainInstance: DWORD; LParam: Pointer): HWND;
begin
  Result:=CreateWindowEx(AExStyle,AClassName,AName,AStyle,x,y,cX,cY,Wnd,AMenu,
                   MainInstance,LParam)
end;

procedure TToolBar.LoadBitmaps(const bitmaps: array of integer);
var
  TBA:TBADDBITMAP;
  k:integer;
begin
  TBA.hInst:=0;
  for k:=Low(bitmaps) to High(bitmaps) do
  begin
    TBA.nID:=LoadImage(MainInstance,PChar(bitmaps[k]),IMAGE_BITMAP,0,0,
      LR_LOADTRANSPARENT or LR_LOADMAP3DCOLORS);
    //  или TBA.nID:=CreateMappedBitmap(MainInstance,AID,0,@colMap,1);
    Perform(TB_ADDBITMAP, 1, longint(@TBA));
  end;
end;

function TToolBar.GetButtonIndex(Index: word): TToolButton;
var
  TB:TTBButton;
begin
  if index+1>=Perform(TB_BUTTONCOUNT,0,0)then
  begin
    Result:=nil;
    Exit;
  end;
  Perform(TB_GETBUTTON,Index,DWORD(@TB));
  Result:=TToolButton(TB.dwData);
end;

function TToolBar.GetButtonCmd(ACmd: word): TToolButton;
var
  k:integer;
  TB:TTBButton;
begin
  Result:=nil;
  for k:=0 to Perform(TB_BUTTONCOUNT,0,0)-1 do
  begin
    Perform(TB_GETBUTTON,k,DWORD(@TB));
    if TB.idCommand=ACmd then
    begin
      Result:=TToolButton(TB.dwData);
      Exit;
    end;
  end;
end;

{ TToolButton }

procedure TToolButton.ChangeImage(ResID: DWORD);
begin
  FParent.Perform(TB_CHANGEBITMAP,FID,ResID);
end;

constructor TToolButton.Create(AParent:TToolBar;AID,ABmpID,ABmpDis:DWORD;AHint:PChar);
var
  TBB:TTBButton;
begin
  FParent:=AParent;
  FID:=AID;                      //  идентификатор кнопки - команда
  FBmpID:=ABmpID;
  FBmpDis:=ABmpDis;              //  номер картинки дл€ запрещЄнной кнопки
  lstrcpy(Hint,AHint);           //  всплывающа€ подсказка
  TBB.fsState:=TBSTATE_ENABLED;
  TBB.dwData:=DWORD(Self);
  TBB.bReserved[1]:=0;
  TBB.bReserved[2]:=0;
  TBB.iString:=0;
  TBB.idCommand:=AID;             //  идентификатор комманды
  TBB.iBitmap:=FBmpID;            //  номер картинки
  TBB.fsStyle:=TBSTYLE_BUTTON;
  FParent.Perform(TB_ADDBUTTONS, 1, lParam(@TBB));
end;

procedure TToolButton.Disable;
begin
  if FBmpDis<>DWORD(-1) then             //  если объ€влен номер картинки
    ChangeImage(FBmpDis);
  FParent.Perform(TB_ENABLEBUTTON,FID,0);
end;

procedure TToolButton.Enable;
begin
  if FBmpDis<>DWORD(-1) then             //  если объ€влен номер картинки
    ChangeImage(FBmpID);
  FParent.Perform(TB_ENABLEBUTTON,FID,1);
end;

procedure TToolButton.Hide;
begin
  FParent.Perform(TB_HIDEBUTTON,FID,1);
end;

function TToolButton.IsEnabled: boolean;
begin
  Result:=boolean(FParent.Perform(TB_ISBUTTONENABLED,FID,0));
end;

procedure TToolButton.Show;
begin
  FParent.Perform(TB_HIDEBUTTON,FID,0);
end;

{ TStatusBar }

function StatusBarProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;stdcall;
var
  StatusBar:TStatusBar;
begin
  StatusBar:=TStatusBar(GetWindowLong(Wnd,GWL_USERDATA));
  if StatusBar<>nil then Result:=StatusBar.WndProc(Wnd,Msg,WParam,LParam)
//    else Result:=CallWindowProc(Pointer(OldStatProc),Wnd,Msg,WParam,LParam);
end;

procedure TStatusBar.Clear(num:DWORD);
var
  n:integer;
begin
  if num=256 then for n:=0 to Perform(SB_GETPARTS,0,0)-1 do SetText(n,nil)
  else SetText(num,nil);
end;

constructor TStatusBar.Create(AParent: TWin);
begin
  inherited Create(WS_CHILD or WS_VISIBLE,0,0,0,0,0,AParent,
     nil,'msctls_statusbar32');
  SetWindowLong(Handle,GWL_USERDATA,Longint(Self));
  oldProc:=Pointer(SetWindowLong(Handle,GWL_WNDPROC,DWORD(@StatusBarProc)));
end;

function TStatusBar.GetHandle(AExStyle: DWORD; AClassName, AName: PChar;
  AStyle: DWORD; x, y, cX, cY: integer; Wnd: HWND; AMenu: HMENU;
  MainInstance: DWORD; LParam: Pointer): HWND;
begin
  Result:=CreateStatusWindow(AStyle,nil,Wnd,0);
end;

procedure TStatusBar.SetParts(const a: array of integer);
begin
  Perform(SB_SETPARTS,High(a)+1,longint(@a))
end;

procedure TStatusBar.SetText(num: DWORD; pch: PChar);
begin
  SendMessage(Handle, WM_USER+1, num, longint(pch));
end;

procedure TStatusBar.WMSize(Wparam, LParam: DWORD);
begin
  SendMessage(Handle,WM_SIZE,SIZE_RESTORED,LParam);
end;

function TStatusBar.WndProc(Wnd: HWND; Msg, WParam, LParam: DWORD): DWORD;
begin
  Result:=CallWindowProc(Pointer(OldProc),Wnd,Msg,Wparam,LParam);
end;                  

{ TButton }

constructor TButton.Create(AParent:TWin;x,y,cx,cy:integer;AName:PChar;AID:word);
begin
  inherited Create(BS_PUSHBUTTON or WS_CHILD or WS_VISIBLE,0,x,y,cx,cy,AParent,AName,nil,AID)
end;

function TButton.GetClassName: PChar;
begin
  Result:='BUTTON';
end;

{ TComboBox }

procedure TComboBox.AddItem(Item: PChar);
begin
  SendMessage(Handle,CB_ADDSTRING,0,DWORD(Item));
end;

procedure TComboBox.AddStrings(List:TStrings);
var
  k:integer;
begin
  for k:=0 to List.Count-1 do AddItem(PChar(List.Strings[k]));
end;

constructor TComboBox.Create(AParent: TWin;Style:DWORD;x,y,x1,y1,AID:word);
begin
  inherited Create(WS_VISIBLE or WS_CHILD or WS_VSCROLL or Style,
       0,x,y,x1,y1,AParent,nil,'COMBOBOX',AID,nil);
end;

function TComboBox.FindString(pch: PChar): integer;
begin
  Result:=SendMessage(Handle,CB_FINDSTRING,0,DWORD(pch));
end;

function TComboBox.GetCurSel: integer;
begin
  Result:=SendMessage(Handle,CB_GETCURSEL,0,0)
end;

function TComboBox.GetSelItem: PChar;
var
  st1:array[0..123] of char;
begin
  SendMessage(Handle,CB_GETLBTEXT,GetCurSel,DWORD(@st1));
  Result:=StrNew(st1);
end;

procedure TComboBox.SetCurSel(Index:integer);
begin
  SendMessage(Handle,CB_SETCURSEL,Index,0);
end;

{ TScrollBar }


{ TListBox }

procedure TListBox.AddItem(Item: PChar);
begin
  SendMessage(Handle,LB_ADDSTRING,0,DWORD(Item));
end;

procedure TListBox.AddStrings(List: TStrings);
var
  k:integer;
begin
  for k:=0 to List.Count-1 do AddItem(PChar(List.Strings[k]));
end;

constructor TListBox.Create(AParent:TWin;Style:DWORD; x, y, x1,y1,AID: word);
begin
  inherited Create(WS_VISIBLE or WS_CHILD or WS_VSCROLL or Style,
       0,x,y,x1,y1,AParent,nil,'LISTBOX',AID,nil);
end;

function TListBox.GetCurSel: integer;
begin
  Result:=SendMessage(Handle,LB_GETCURSEL,0,0)
end;

function TListBox.GetSelItem: PChar;
var
  st1:array[0..123] of char;
begin
  SendMessage(Handle,LB_GETTEXT,GetCurSel,DWORD(@st1));
  Result:=StrNew(st1);
end;

procedure TListBox.SetCurSel(Index: integer);
begin
  SendMessage(Handle,LB_SETCURSEL,Index,0);
end;

{ TEdit }

function EditProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;stdcall;
var Edit:TEdit;
begin
  Edit:=TEdit(GetWindowLong(Wnd,GWL_USERDATA));
  if Edit<>nil then Result:=Edit.WndProc(Wnd,Msg,WParam,LParam)
end;


constructor TEdit.Create(AParent: TWin; Style: DWORD; x, y, x1, y1,AID: word);
begin
  inherited Create(WS_VISIBLE or WS_CHILD  or Style,
       0,x,y,x1,y1,AParent,nil,'EDIT',AID,nil);
  SetWindowLong(Handle,GWL_USERDATA,Longint(Self));
  oldProc:=Pointer(SetWindowLong(Handle,GWL_WNDPROC,DWORD(@EditProc)));
end;

function TEdit.WndProc(Wnd: HWND; Msg, WParam, LParam: DWORD): DWORD;
begin
  if (Msg=WM_CHAR) and(Wparam=13)
    then
    begin
      Result:=0;
      Exit;
    end;
  Result:=CallWindowproc(oldProc,Wnd,Msg,Wparam,LParam)
end;

{ TScrollBar }


function TScrollBar.GetClassname: PChar;
begin
  Result:='SCROLLBAR'
end;

{ TGroupBox }

constructor TGroupBox.Create(AParent: TWin; x, y, cx, cy: integer;
  ALabel: PChar);
begin
  inherited Create(BS_GROUPBOX or WS_CHILD or WS_VISIBLE,0,x,y,cx,cy,AParent,ALabel,'BUTTON',0)
end;

{ TRadio }

constructor TRadio.Create(AParent: TWin; x, y, cx, cy: integer;
  AName: PChar; AID: word;AGroup:boolean=false);
var
  GroupStyle:DWORD;
begin
  if not AGroup then groupStyle:=0 else GroupStyle:=WS_GROUP;
  inherited Create(GroupStyle or BS_AUTORADIOBUTTON or WS_CHILD or WS_VISIBLE,0,x,y,cx,cy,AParent,AName,'BUTTON',AID)
end;

{ TCheckBox }

constructor TCheckBox.Create(AParent: TWin; x, y, cx, cy: integer;
  AName: PChar; AID: word);
begin
  inherited Create(BS_AUTOCHECKBOX or WS_CHILD or WS_VISIBLE,0,x,y,cx,cy,AParent,AName,'BUTTON',AID)
end;

initialization
 colMap.cFrom:=$FFFFFF;
 colMap.cTo:=GetSysColor(COLOR_MENU);

end.
