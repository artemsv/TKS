{$O-}
unit WinMenu;                          //  Дата создания:      16.10.02.
                                       //  Дата модификации:   18.03.03.
interface

uses Windows,Contnrs;

type                                   //  запись характеризует
  POwnerItem=^ROwnerItem;              //  OwnerDraw - пункт меню
  ROwnerItem=record
    itemStr:string;
    bmpResID:word;                     //  номер картинки
    textColorHilite:COLORREF;
    textColorNormal:COLORREF;
    backColorHilite:COLORREF;
    backColorNormal:COLORREF;
    data:pointer;                      //  пользовательские данные
  end;

  TMenu=class;

  TMenuItem=class                      //  класс - пункт меню
  private
    FData:PChar;
    FHandle:HMENU;                            //  дескриптор хозяина пункта
    FCommand:word;                            //  идентификатор меню
    FFlags:UINT;
    FBMP:HBITMAP;
    FTextColor:COLORREF;                      //  цвет текста пункта
    brushHilite:HBRUSH;                  //  кисть для фона выбранного пункта
    brushNormal:HBRUSH;                  //  кисть для нормального фона
  public
    constructor Create(Menu:TMenu;AFlags:UINT;ACommand:word;AData:PChar;
      ATextColor:COLORREF=0;ABackHilite:COLORREF=0;ABackNormal:COLORREF=0);
    procedure MeasureItem(var MI:PMEASUREITEMSTRUCT);
    procedure DrawItem(var DI:PDRAWITEMSTRUCT);
    procedure Enable;
    procedure Disable;
    property Handle:HMENU read FHandle;
    property Command:word read FCommand;
  end;

  TMenu=class
  private
    FItems:TObjectList;                     //  список пунктов меню
    FHandle:HMENU;                          //  дескриптор меню
  public
    constructor Create;virtual;
    procedure AddSeparator;
    procedure InsertItem(Item:TMenuItem);
    property Handle:HMENU read FHandle;
  end;

  TPopupMenu=class(TMenu)
  public
    constructor Create;override;
    function MeasureItem(var MI:PMEASUREITEMSTRUCT):boolean;
    function DrawItem(var DI:PDRAWITEMSTRUCT):boolean;
  end;

  TMainMenu=class(TMenu)                      //  класс главное меню
  private
    FPopups:TObjectList;                      //  список подменю
  public
    constructor Create;override;
    procedure CreateSubMenu(APopup:TPopupMenu;AItem:TMenuItem);
    procedure MeasureItem(var MI:PMEASUREITEMSTRUCT);
    procedure DrawItem(var DI:PDRAWITEMSTRUCT);
  end;

implementation

{ TMenu }

procedure TMenu.AddSeparator;
begin
  AppendMenu(FHandle,MF_SEPARATOR,0,nil);
end;

constructor TMenu.Create;
begin
  FItems:=TObjectList.Create;
end;

procedure TMenu.InsertItem(Item: TMenuItem);
begin
  if Item.FFlags=MF_OWNERDRAW then
    AppendMenu(FHandle,ITem.FFlags,Item.FCommand,PChar(Item))
  else
    AppendMenu(FHandle,ITem.FFlags,Item.FCommand,Item.FData);
  FItems.Add(Item);
end;

{ TMenuItem }

constructor TMenuItem.Create(Menu:TMenu;AFlags:UINT;ACommand:word;AData:PChar;
  ATextColor:COLORREF=0;ABackHilite:COLORREF=0;ABackNormal:COLORREF=0);
begin
  FHandle:=Menu.Handle;
  FCommand:=ACommand;
  FData:=AData;
  FFlags:=AFlags;
  FTextColor:=ATextColor;
  if ABackHilite=0 then brushHilite:=HBRUSH(COLOR_HIGHLIGHT+1)
    else brushHilite:=CreateSolidBrush(ABackHilite);
  if ABackNormal=0 then brushNormal:=HBRUSH(COLOR_MENU+1)
    else brushNormal:=CreateSolidBrush(ABackNormal);
  if (FFlags=MF_OWNERDRAW) and (POwnerItem(FData).bmpResID<>0) then
    FBMP:=LoadImage(MainInstance,PChar(POwnerItem(FData).bmpResID),
      IMAGE_BITMAP,0,0,LR_LOADTRANSPARENT or LR_LOADMAP3DCOLORS)
  else FBMP:=0;
end;

procedure TMenuItem.Disable;
begin
  if GetMenuState(FHandle,FCommand,MF_BYCOMMAND)<>MF_GRAYED then
    EnableMenuItem(FHandle,FCommand,MF_GRAYED);
end;

procedure TMenuItem.DrawItem(var DI: PDRAWITEMSTRUCT);
var
  clrPrevText, clrNewText: COLORREF;
  hfntPrev:HFONT;
  r,r1:TRect;
  mode,i:integer;
  itemStr: array[0..31]of char;
  memDC:hDC;
  Old:hGDIObj;
  Flag:boolean;
  b:byte;
begin
  lstrcpy(itemStr,PChar(POwnerItem(FData).itemStr));
  if itemStr[0]=#0 then exit;
  CopyRect(r,DI.rcItem);
  Flag:=((DI.itemState and ODS_GRAYED)=0)or((DI.itemState and ODS_CHECKED)<>0);
  if Flag then inc(r.Left, 19);
  //  устанавлмваем размеры квадратика с картинкой
  SetRect(r1,DI.rcItem.Left,DI.rcItem.Top,DI.rcItem.Left+18,DI.rcItem.Bottom);
  if (DI.itemState and ODS_SELECTED)<>0 then
  begin
    //  если пункт меню выбран
    if (DI.itemState and ODS_GRAYED)<>0 then
      clrNewText:=COLOR_GRAYTEXT       //  если пункт меню выбран, но запрещён
    else begin
       //  если пункт меню выбран и разрешён
       clrNewText:=COLOR_HIGHLIGHTTEXT;
       if FBMP<> 0 then                //  квадратик нужен, если есть картинка
       if Flag then
       if (DI.itemState and ODS_CHECKED)<>0 then
         DrawEdge(DI.hDC, r1, BDR_SUNKENOUTER, BF_RECT)
       else
         DrawEdge(DI.hDC, r1, BDR_RAISEDINNER, BF_RECT);
    end;
//      FillRect(DI.hDC, r, hBrush(COLOR_HIGHLIGHT+1));
      FillRect(DI.hDC, r, brushHilite);
  end else
  begin
    if (DI.itemState and ODS_GRAYED)<>0 then
    begin
      clrNewText:=COLOR_GRAYTEXT;
    end else
    begin
      clrNewText:=COLOR_MENUTEXT;
      if Flag then
        DrawEdge(DI.hDC, r1, BDR_RAISEDINNER, BF_RECT or BF_FLAT);
    end;
    FillRect(DI.hDC, r, brushNormal);
  end;
  inc(r.left,2);
  if Flag then
  begin
    memDC:=CreateCompatibleDC(DI.hDC);
    Old:=SelectObject(memDC, FBMP);
    BitBlt(DI.hDC, DI.rcItem.Left+1, (DI.rcItem.Top+
      DI.rcItem.Bottom-16)div 2,16, 16, memDC, 0, 0, SRCCOPY);
    SelectObject(memDC, Old);
    DeleteDC(memDC);
  end;
  if not Flag then inc(r.Left, 19);
  hfntPrev:= SelectObject(DI.hDC, GetStockObject(DEFAULT_GUI_FONT));
  mode:=SetBkMode(DI.hDC, TRANSPARENT);
  if ((DI.itemState and ODS_GRAYED)<>0)and
    ((DI.itemState and ODS_SELECTED)=0) then
  begin
    clrPrevText := SetTextColor(DI.hDC,GetSysColor(COLOR_BTNHILIGHT));
    OffsetRect(r,1,1);
    DrawText(DI.hDC, itemStr,lstrlen(itemStr),r,DT_SINGLELINE or DT_VCENTER);
    OffsetRect(r,-1,-1);
    SetTextColor(DI.hDC, GetSysColor(clrNewText));
  end else
    clrPrevText := SetTextColor(DI.hDC,GetSysColor(clrNewText));
  DrawText(DI.hDC, itemStr,lstrlen(itemStr),r,DT_SINGLELINE or DT_VCENTER or DT_LEFT);
  SetBkMode(DI.hDC, mode);
  SelectObject(DI.hDC, hfntPrev);
  SetTextColor(DI.hDC, clrPrevText);
end;

procedure TMenuItem.Enable;
begin
  if GetMenuState(FHandle,FCommand,MF_BYCOMMAND)<>MF_ENABLED then
    EnableMenuItem(FHandle,FCommand,MF_ENABLED);
end;

procedure TMenuItem.MeasureItem(var MI: PMEASUREITEMSTRUCT);
var
  hfntPrev:HFONT;
  r:TRect;
  DC:hDC;
  itemStr: string;
  n:integer;
  POI:ROwnerItem;
begin
  Windows.SetRectEmpty(r);
  itemStr:=POwnerItem(FData).itemStr;
  if itemStr<>'' then
  begin
    DC:=GetDC(0);
    //   hfntPrev:= SelectObject(DC, MyFont);
    DrawText(DC, PChar(itemStr),
          Length(itemStr),
          r,
          DT_SINGLELINE or DT_CALCRECT or DT_LEFT);
    // SelectObject(DC, hfntPrev);
    ReleaseDC(0, DC);
    if r.bottom<18 then r.Bottom:=18;
  end;
  MI.itemWidth := r.Right;
  MI.itemHeight :=r.Bottom;
end;

{ TMainMenu }

constructor TMainMenu.Create;
begin
  inherited;
  FHandle:=CreateMenu;
  FPopups:=TObjectList.Create;
end;

procedure TMainMenu.CreateSubMenu(APopup: TPopupMenu; AItem: TMenuItem);
var
  MI:MENUITEMINFO;
  k:integer;
begin
  for k:=0 to FItems.Count-1 do
    if TMenuItem(FItems[k])=AItem then
    begin
      FillCHar(MI,SizeOf(MI),0);
      MI.cbSize:=SizeOf(MI);
      MI.fMask:=MIIM_SUBMENU;
      MI.fType:=MFT_STRING;
      MI.hSubMenu:=APopup.Handle;
      SetMenuItemInfo(FHandle,TMenuItem(FItems[k]).FCommand,false,MI);
    end;
  FPopups.Add(APopup);
end;

procedure TMainMenu.DrawItem(var DI: PDRAWITEMSTRUCT);
var
  k:integer;
begin
  if DI^.CtlType=ODT_MENU then
    for k:=0 to FPopups.Count-1 do
      if TPopupMenu(FPopups[k]).DrawItem(DI) then Exit;
end;

procedure TMainMenu.MeasureItem(var MI: PMEASUREITEMSTRUCT);
var
  k:integer;
begin
  if MI^.CtlType=ODT_MENU then
    for k:=0 to FPopups.Count-1 do
      if TPopupMenu(FPopups[k]).MeasureItem(MI) then Exit;
end;

{ TPopupMenu }

constructor TPopupMenu.Create;
begin
  inherited;
  FHandle:=CreatePopupMenu;
end;

function TPopupMenu.DrawItem(var DI: PDRAWITEMSTRUCT): boolean;
var
  k:integer;
begin
  Result:=false;
  for k:=0 to FItems.Count-1 do
    if TMenuItem(FItems[k])=TMenuItem(DI^.itemData) then
    begin
      TMenuItem(FItems[k]).DrawItem(DI);
      Result:=true;
      Exit;
    end;
end;

function TPopupMenu.MeasureItem(var MI: PMEASUREITEMSTRUCT): boolean;
var
  k:integer;
begin
  Result:=false;
  for k:=0 to FItems.Count-1 do
    if TMenuItem(FItems[k])=TMenuItem(MI^.itemData) then
    begin
      TMenuItem(FItems[k]).MeasureItem(MI);
      Result:=true;
      Exit;
    end;
end;

end.
