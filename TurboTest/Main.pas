{$O-}
unit Main;             //  Дата создания: Май 2002
                       //  Дата подключения к TurboTest 6.0  : 01.11.02.
interface

uses Windows,WinApp,Messages,FNewTema,WinFunc,WinCtrl,SysUtils,
     CommCtrl,ShellAPI,Contnrs,WinMenu,MConst,ActiveX,MTypes;

type
  TMyClient=class(TMDIClient)
  protected
    function DoEraseBkgnd(DC:HDC):integer;override;
  end;

  TMyMDI= class(TMDIWindow,IOleWindow,IOleInPlaceUIWindow,IOleInPlaceFrame)
  private
    mnuFile,mnuEdit,mnuQuestion,mnuObjects,mnuWindow,mnuService,mnuHelp:TMenuItem;
    mnuNew,mnuOld,mnuRed,mnuProperties,mnuPrint,mnuExit:TMenuItem;
    mnuCut,mnuCopy,mnuPaste,mnuDelete,mnuUndo,mnuSelectAll:TMenuItem;
    mnuQAdd,mnuQDelete,mnuQCopy,mnuQPaste,mnuQCut:TMenuItem;
    mnuEcuat,mnuBmp,mnuRefresh:TMenuItem;
    mnuCascade,mnuTileH,mnuTileV:TMenuItem;
    mnuOptions:TMenuItem;
    mnuAbout:TMenuItem;
    popFile,popEdit,popQuestion,popObjects,popWindow,popService,popHelp:TPopupMenu;

    btnNew,btnOld,btnRed,btnFont,btnUp,
    btnQAdd,btnQDelete,btnQCopy,btnQPaste,
    btnDown,btnMacro,btnEcuat,btnBmp,btnRefresh:TToolButton;
    procedure New;
    procedure Red;
    procedure Old;
    procedure Convert;
    procedure CreateMainMenu;
    procedure CreateToolBar;
  protected
    procedure GetWndClassEx(var WC:TWndClassEx);override;
    function GetClient:TMDIClient;override;
    procedure DoSize(Wparam,LParam:DWORD);override;
    procedure DoTimer(Wparam,LParam:DWORD);override;
    function CloseQuery:boolean;override;
    function DoCommand(Wparam,LParam:DWORD):DWORD;override;
  public
    ToolBar:TToolBar;                          //  панель инструментов
    StatusBar:TStatusBar;                      //  строка состояния
    HStatusBar:integer;                        //  высота строки состояния
    HToolBar:integer;                          //  высота панели инструментов
    MainMenu:TMainMenu;                        //  главное меню
    procedure FromCommandLine(st:string);
    procedure UpdateToolBar;
    procedure UpdateMenu;
    constructor Create(AParent:TWin);reintroduce;
    destructor Destroy;override;
    procedure UpdateCaretPos(position:longint);
    procedure UpdateInsertFlag(fInsert:boolean);
    function WndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
    { IOleWindow }
    function GetWindow(out wnd: HWnd): HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    { IOleInPlaceUIWindow }
    function GetBorder(out rectBorder: TRect): HResult; stdcall;
    function RequestBorderSpace(const borderwidths: TRect): HResult; stdcall;
    function SetBorderSpace(pborderwidths: PRect): HResult; stdcall;
    function SetActiveObject(const activeObject: IOleInPlaceActiveObject;
      pszObjName: POleStr): HResult; stdcall;
    { IOleInPlaceFrame }
    function InsertMenus(hmenuShared: HMenu;
      var menuWidths: TOleMenuGroupWidths): HResult; stdcall;
    function SetMenu(hmenuShared: HMenu; holemenu: HMenu;
      hwndActiveObject: HWnd): HResult; stdcall;
    function RemoveMenus(hmenuShared: HMenu): HResult; stdcall;
    function SetStatusText(pszStatusText: POleStr): HResult; stdcall;
    function EnableModeless(fEnable: BOOL): HResult; stdcall;
    function TranslateAccelerator(var msg: TMsg; wID: Word): HResult; stdcall;
  end;

implementation

uses
  WinRtf,MOptions,Macro,MSost,MRed,MEdit,MInput,Streams,MSelTema;

{$R RES\Main.res}

constructor TMyMDI.Create;
var
  R:TRect;
  w:integer;
begin
  inherited Create(WS_OVERLAPPEDWINDOW,0,0,0,GetSystemMetrics(SM_CXSCREEN),
         GetSystemMetrics(SM_CYSCREEN)-260,AParent,nil,'MainWindow');
//  Registrated(Handle);
  HAccl:=LoadAccelerators(0,PChar(1));      //  быстрые клавиши
  StatusBar:=TStatusBar.Create(Self);
  GetWindowRect(StatusBar.Handle,R);
  HStatusBar:=R.Bottom-R.Top;
  StatusBar.SetParts([38,96,396,-1]);
  StatusBar.Perform(WM_SETFONT,GetStockObject(DEFAULT_GUI_FONT),0);
  SetWindowText(Handle,'Редактор тестов');
  SetTimer(Handle, 222, 100,nil);           //  запускаем системный таймер
  CreateToolBar;
  CreateMainmenu;
end;

destructor TMyMDI.Destroy;
begin
  ToolBar.Free;
  StatusBar.Free;
  MainMenu.Free;
  SaveMacro;
  inherited;
end;

function TMyMDI.DoCommand(Wparam, LParam: DWORD):DWORD;
begin
  Result:=0;
  case LOWORD(WParam) of
    DOM_UPDATECARETPOS:UpdateCaretPos(LParam);
    CM_CASCADE:Client.Cascade;
    CM_TILEH:Client.Tile(MDITILE_HORIZONTAL);
    CM_TILEV:Client.Tile(MDITILE_VERTICAL);
    SC_CLOSE:Client.SendActive(WM_CLOSE,0,0);
    SC_MINIMIZE :begin Client.RestoreActive;
        ShowWindow(Client.GetActiveWnd,SW_MINIMIZE);end;
    SC_RESTORE : Client.RestoreActive;
    CM_EXIT:if CloseQuery then Close;//PostQuitMessage(0);
    CM_ABOUT:ShellAbout(Handle,'Редактор тестов',
     'Copyright (c) 2000,2003 by Artem Sokolov',LoadIcon(MainInstance,PChar(154)));
    CM_NEW:New;
    CM_OLD:Old;
    CM_RED:Red;
    CM_MACRO:MacroK(Self);
    CM_FONT,CM_PROP,CM_PRINT:Client.SendActive(WM_COMMAND,WParam,LParam);
    CM_DOWN,CM_UP,CM_ECUAT,CM_BMP,CM_REFRESH,CM_QADD..CM_QPASTE:
      Client.SendActive(WM_COMMAND,WParam,LParam);
    CM_STATUSTEXTCLEAR:StatusBar.Clear;
    CM_OPTIONS:ExecOptions(Self);                         //  окно настройки
    DOM_CUT..DOM_SELECTALL:
      SendMessage((Client.GetActiveWnd),WM_COMMAND,WParam,0);
    DOM_UPDATEINSERTFLAG:UpdateInsertFlag(boolean(LParam));
    MDI_CHILD_FIRST..MDI_CHILD_FIRST+10: Client.Activate(WParam);
  end;
end;

procedure TMyMDI.DoSize(Wparam, LParam: DWORD);
begin
  if StatusBar<>nil then StatusBar.WMSize(WParam,LParam);
  if ToolBar<>nil then ToolBar.WMSize(WParam,LParam);
  if Client<>nil then Client.WMSize(MakeLong(0,HToolBar),MakeLong(LoWord(LParam),
    (HiWord(LParam)-HToolBar-HStatusBar)))
end;

procedure TMyMDI.GetWndClassEx(var WC: TWndClassEx);
begin
  inherited;
  WC.hIcon:=LoadIcon(MainInstance,Pchar(154));
end;

procedure TMyMDI.Old;
var
  TS:TSost;
  tema,fileName:string;
begin
  if not GetTemaFile(Self,'Выберите тему для продолжения ввода',tema,fileName)
    then Exit;
  TS:=nil;
  try
    UpdateWindow;                   //  чтобы убрать след от окна диалога
    TS:=TSost.Create(Self,Client,PChar(fileName));
    TS.Show(SW_MAXIMIZE);
    TS.RTF.Show(SW_MAXIMIZE);
  except
    on E:Exception do
    begin
      DoCommand(CM_STATUSTEXTCLEAR,0);
      MessageBox(Handle,PChar(E.Message),'TurboTest',0);
      if TS<>nil then TS.Free;
    end;
  end;
  RefreshWindowMenu;
end;

procedure TMyMDI.UpdateCaretPos(position:longint);
var
  buf:array[0..40]of char;
  Cr:array [0..1] of longint;
begin
  Cr[0]:=LOWORD(position);Cr[1]:=HIWORD(position);
  wvsprintf(buf,'%3u:%u',@Cr);
  if (LOWORD(position)>1000) or (HIWORD(position)>1000) then  //защита от
     FillChar(buf,10,0);// Неверного значения столбцов при выделении
  StatusBar.SetText(0,buf);
end;

procedure TMyMDI.UpdateInsertFlag(fInsert: boolean);
begin
  if fInsert then StatusBar.SetText(1,'Замена')
             else StatusBar.SetText(1,'Вставка')
end;

function TMyMDI.WndProc(Wnd: HWND; Msg, WParam, LParam: DWORD): DWORD;
var
  TTB:TToolButton;
begin
  Result:=0;
  case Msg of
    WM_NOTIFY:
      if (PTOOLTIPTEXT(LParam).hdr.code=TTN_NEEDTEXT) then
      begin
        TTB:=ToolBar.GetButtonCmd(PNMHDR(LParam).idFrom);
        if TTB<>nil then       //  если TBB nil,
          lstrcpyn(PTOOLTIPTEXT(lparam).szText,TTB.Hint,StrLen(TTB.Hint)+2) ;
        Result:=1;
      end
    else
       case PNMHDR(lParam).code of
        TBN_BEGINADJUST, TBN_BEGINDRAG, TBN_ENDDRAG,
        TBN_QUERYDELETE, TBN_QUERYINSERT, TBN_ENDADJUST:
         Result:=1;
       end;
    WM_MEASUREITEM:if Assigned(MainMenu) then
    begin
       MainMenu.MeasureItem(PMEASUREITEMSTRUCT(LParam));
       Result:=1;
    end;
    WM_DRAWITEM:if Assigned(MainMenu) then
      begin
        MainMenu.DrawItem(PDRAWITEMSTRUCT(LParam));
        Result:=1;
      end;
  else
    Result:=inherited WndProc(Wnd,Msg,WParam,LParam);
  end;
end;

{ TMyMDI.IOleWindow }

function TMyMDI.ContextSensitiveHelp(fEnterMode: BOOL): HResult;
begin
  Result:=S_OK;
end;

function TMyMDI.GetWindow(out wnd: HWnd): HResult;
begin
  Result:=S_OK;
  wnd:=Handle;
end;

{ IOleInPlaceUIWindow }

function TMyMDI.GetBorder(out rectBorder: TRect): HResult;
begin
  //Result:=E_NOTIMPL;
  rectBorder:=ClientRect;
  Result:=S_OK;
end;

function TMyMDI.RequestBorderSpace(const borderwidths: TRect): HResult;
begin
//  Result:=S_OK;
  Result:=E_NOTIMPL;
end;

function TMyMDI.SetActiveObject(const activeObject: IOleInPlaceActiveObject;
           pszObjName: POleStr): HResult;
begin
  Result:=S_OK;
//  Result:=E_NOTIMPL;
end;

function TMyMDI.SetBorderSpace(pborderwidths: PRect): HResult;
begin
  Result:=S_OK;
//  Result:=E_NOTIMPL;
end;

{ IOleInPlaceFrame }

function TMyMDI.EnableModeless(fEnable: BOOL): HResult;
begin
  Result:=S_OK;
end;

function TMyMDI.InsertMenus(hmenuShared: HMenu;
  var menuWidths: TOleMenuGroupWidths): HResult;
begin
  Result:=S_OK;
//  Result:=E_NOTIMPL;
end;

function TMyMDI.RemoveMenus(hmenuShared: HMenu): HResult;
begin
  Result:=S_OK;
//  Result:=E_NOTIMPL;
end;

function TMyMDI.SetMenu(hmenuShared, holemenu: HMenu;
  hwndActiveObject: HWnd): HResult;
begin
  Result:=S_OK;
//  Result:=E_NOTIMPL;
end;

function TMyMDI.SetStatusText(pszStatusText: POleStr): HResult;
begin
  Result:=S_OK;
  StatusBar.SetText(3,PChar(pszStatusText));
end;

function TMyMDI.TranslateAccelerator(var msg: TMsg; wID: Word): HResult;
begin
//  Result:=S_OK;
  Result:=E_NOTIMPL;
end;

procedure TMyMDI.New;
var
  FileName:PChar;
  NT:TNewTemaDlg;
begin
  NT:=TNewTemaDlg.Create(Self,1,0);
  if NT.ShowModal = ID_OK then FileName:=NT.Name else FileName:=nil;
  NT.Free;
  if FileName<>nil then with TSost.Create(Self,Client,FileName) do
  begin
    Show(SW_MAXIMIZE);
    RTF.Show(SW_MAXIMIZE);
  end;
  RefreshWindowMenu;
end;

procedure TMyMDI.Red;
var TR:TRed;tema,fileName:string;
begin
  if not GetTemaFile(Self,'Выберите тему для редактирования',tema,fileName)
    then Exit;
  try
    UpdateWindow;                   //  чтобы убрать след от окна диалога
    ShowLoadMsg(Client.Handle);
    TR:=TRed.Create(Self,Client,PChar(FileName));
    TR.Show;//(SW_MAXIMIZE);
    TR.RTF.Show(SW_MAXIMIZE);
    SendMessage(TR.Handle,WM_SETFOCUS,0,0);
  except
    On E:Exception do
    begin
      EraseLoadMsg(Client.Handle);
      MessageBox(Handle,PChar(E.Message),'Turbo Test',$10);
      Exit;
      if TR<>nil then TR.Free;
    end;
  end;
  RefreshWindowMenu;
end;

procedure TMyMDI.UpdateToolBar;
var w:integer;
begin
  if Client.GetActiveWnd=0 then
  begin
    btnFont.Disable;btnUp.Disable;btnDown.Disable;
    btnEcuat.Disable;btnBmp.Disable;btnRefresh.Disable;
//    btnQAdd.Disable;btnQDelete.Disable;btnQCOpy.Disable;btnQPaste.Disable;
  end
  else begin
    btnFont.Enable;                         //  Font
    if CLient.GetActiveChild is TSost then
    begin
      btnUp.Disable;btnDown.Disable;        //  при составлении листать нельзя
  {    btnQAdd.Disable;btnQDelete.Disable;
      btnQCopy.Disable;btnQPaste.Disable}
    end else
    begin
      btnUp.Enable;btnDown.Enable;          // разрешить листание - это TRed
//      btnQAdd.Enable;btnQDelete.Enable;btnQCopy.Enable;btnQPaste.Enable;
    end;
    if Client.SendActive(WM_COMMAND,DOM_CANEMBED,0)<>0 then
    begin
      btnEcuat.Enable;                      // Разрешить вставку объектов
      btnBmp.Enable;
      btnRefresh.Enable;
    end else
    begin
      btnEcuat.Disable;                     // запретить вставку объектов
      btnBmp.Disable;
    end;
  end;
end;

procedure TMyMDI.DoTimer(Wparam, LParam: DWORD);
begin
  inherited;
  UpdateToolBar;                         //  обновить состояние кнопок
  UpdateMenu;                            //  обновить состояние пунктов меню
end;

procedure TMyMDI.UpdateMenu;
begin
  if Client.GetActiveWnd=0 then
  begin
    mnuCut.Disable;mnuCopy.Disable;mnuPaste.Disable;mnuDelete.Disable;
//    mnuQAdd.Disable;mnuQDelete.Disable;mnuQCopy.Disable;mnuQPaste.Disable;
    mnuUndo.Disable;//mnuSelectAll.Disable;
    mnuEcuat.Disable;mnuBmp.Disable;mnuRefresh.Disable;
    mnuCascade.Disable;mnuTileH.Disable;mnuProperties.Disable;mnuTileV.Disable
  end else
  begin
    mnuCascade.Enable;mnuTileH.Enable;mnuTileV.Enable;    //  меню Окна
    mnuRefresh.Enable;                   //  меню Объекты
    mnuEdit.Enable;mnuProperties.Enable;
    mnuPaste.Enable;                     //  Вставить
    //mnuSelectAll.Enable;                 //  Выделить все

{    if Client.GetActiveChild is TSost then
    begin
      mnuQAdd.Disable;mnuQDelete.Disable;mnuQCopy.Disable;mnuQPaste.Disable;
    end else
    begin
      mnuQAdd.Enable;mnuQDelete.Enable;mnuQCopy.Enable;mnuQPaste.Enable;
    end;}
    if Client.SendActive(WM_COMMAND,DOM_CANEDITMENU,0)<>0 then
    begin
      mnuCut.Enable;                     //  Вырезать
      mnuCopy.Enable;                    //  Копировать
      mnuDelete.Enable;                  //  Удалить
    end else
    begin
      mnuCut.Disable;                    //  Вырезать
      mnuCopy.Disable;                   //  Копировать
      mnuDelete.Disable;                 //  Удалить
    end;
    if Client.SendActive(WM_COMMAND,DOM_CANRTFUNDO,0)<>0 then
      mnuUndo.Enable else mnuUndo.Disable;
    if Client.SendActive(WM_COMMAND,DOM_CANEMBED,0)=0 then
    begin                                  // запретить вставку объектов
      mnuEcuat.Disable;
      mnuBmp.Disable;
    end else
    begin                                  // разрешить вставку объектов
      mnuEcuat.Enable;
      mnuBmp.Enable
    end;
  end;
//  DrawMenuBar(Handle);
end;

function TMyMDI.CloseQuery: boolean;
begin
  Result:=false;
  Client.SendToAll(WM_CLOSE,0,0);       //  приказали всем закрыться
  if Client.GetActiveWnd<>0 then Exit;     //  если хоть один не закрылся-выход
  Result:=true;
end;

{ TMyClient }

function TMyClient.DoEraseBkgnd(DC: HDC): integer;
var R:TRect;oldBrush,Brush:HBRUSH;oldF,f:HFONT;lf:TLogFont;cx,a,b,cy:integer;
const
  cRect=$809AAF;                    //  цвет заставки Turbo Test
  cBack=$809AAE;
  cText=$44584F;//$666776;
begin
  cx:=GetSystemMetrics(SM_CXSCREEN);
  cy:=GetSystemMetrics(SM_CYSCREEN);
  a:=cx div 2;b:=cy div 2;
  //  Фон
  GetWindowRect(Handle,R);
  Brush:=CreateSolidBrush(cBack);
  oldBrush:=SelectObject(DC,Brush);
  Rectangle(DC,0,0,R.Right,R.Bottom);
  SelectObject(DC,oldBrush);
  DeleteObject(Brush);
  //  Создание логического шрифта
  FillChar(lf,SizeOf(lf),0);
  lf.lfItalic:=1;
  lf.lfStrikeOut:=0;
  lf.lfUnderline:=0;
  lf.lfHeight:=200;
  lf.lfWidth:=50;
  lf.lfFaceName:='Tahoma';
  lf.lfWeight:=700;
  f:=CreateFontIndirect(LF);
  oldF:=SelectObject(DC,f);
  SetBkColor(DC,cRect);
  SetTextColor(DC,cText);
  TextOut(DC,a-310,b-240,'Turbo Test',10);
  SetBkMode(DC,TRANSPARENT);
  SetTextColor(DC,cBack+8);
  TextOut(DC,a-305,b-235,'Turbo Test',10);
  SelectObject(DC,oldF);
  DeleteObject(f);
  Result := 1;
end;

function TMyMDI.GetClient: TMDIClient;
begin
  Result:=TMyClient.Create(Self);
end;

procedure TMyMDI.Convert;        //  преобразует файлы старого формата вновый
var
  f:file of byte;
  b:byte;
begin
  Assign(f,'inform03.tx2');
  Reset(f);
  while not eof(f) do
  begin
    Read(f,b);
    if b=219 then
    begin
      Client.SendActive(WM_COMMAND,DOM_BLOCK,0);
    end
    else TSost(Client.GetActiveChild).RTF.Perform(WM_CHAR,b,0);
  end;
  CloseFile(f);
end;

procedure TMyMDI.CreateMainMenu;
const
  mnNew:ROwnerItem=(itemStr:'Создать...';bmpResID:1;data:nil);
  mnOld:ROwnerItem=(itemStr:'Продолжить...';bmpResID:2;data:nil);
  mnRed:ROwnerItem=(itemStr:'Редактировать...';bmpResID:3;data:nil);
  mnExit:ROwnerItem=(itemStr:'Выход';bmpResID:0;data:nil);

  mnCut:ROwnerItem=(itemStr:'Вырезать...Ctrl+X';bmpResID:21;data:nil);
  mnCopy:ROwnerItem=(itemStr:'Копировать...Ctrl+C';bmpResID:22;data:nil);
  mnPaste:ROwnerItem=(itemStr:'Вставить...Ctrl+V';bmpResID:23;data:nil);
  mnDelete:ROwnerItem=(itemStr:'Удалить...Ctrl+Del';bmpResID:25;data:nil);
  mnUndo:ROwnerItem=(itemStr:'Отменить...Alt+Backspace';bmpResID:24;data:nil);

  mnQAdd:ROwnerItem=(itemStr:'Добавить вопрос';bmpResID:51;data:nil);
  mnQDelete:ROwnerItem=(itemStr:'Удалить вопрос';bmpResID:52;data:nil);
  mnQCopy:ROwnerItem=(itemStr:'Копировать вопрос';bmpResID:53;data:nil);
  mnQPaste:ROwnerItem=(itemStr:'Вставить вопрос';bmpResID:54;data:nil);
  mnProperties:ROwnerItem=(itemStr:'Свойства';bmpResID:0;data:nil);

  mnEcuat:ROwnerItem=(itemStr:'Формула';bmpResID:8;data:nil);
  mnBmp:ROwnerItem=(itemStr:'Картинка';bmpResID:9;data:nil);
  mnRefresh:ROwnerItem=(itemStr:'Обновить';bmpResID:10;data:nil);

  mnCascade:ROwnerItem=(itemStr:'Каскадом';bmpResID:61;data:nil);
  mnTileH:ROwnerItem=(itemStr:'Черепицей 1';bmpResID:62;data:nil);
  mnTileV:ROwnerItem=(itemStr:'Черепицей 2';bmpResID:63;data:nil);

  mnAbout:ROwnerItem=(itemStr:'О программе...';bmpResID:41;data:nil);
  mnOptions:ROwnerItem=(itemStr:'Настройка';bmpResID:0;data:nil);
begin
  MainMenu:=TMainMenu.Create;
  mnuFile:=TMenuItem.Create(MainMenu,MF_STRING,100,'Тема');
  mnuEdit:=TMenuItem.Create(MainMenu,MF_STRING,102,'Правка');
//  mnuQuestion:=TMenuItem.Create(MainMenu,MF_STRING,103,'Вопрос');
  mnuObjects:=TMenuItem.Create(MainMenu,MF_STRING,104,'Объекты');
  mnuWindow:=TMenuItem.Create(MainMenu,MF_STRING,105,'Окно');
  mnuHelp:=TMenuItem.Create(MainMenu,MF_STRING,106,'Справка');
  MainMenu.InsertItem(mnuFile);
  MainMenu.InsertItem(mnuEdit);
  //MainMenu.InsertItem(mnuQuestion);
  MainMenu.InsertItem(mnuObjects);
  MainMenu.InsertItem(mnuWindow);
  MainMenu.InsertItem(mnuHelp);
  SetMainMenu(MainMenu);

  popFile:=TPopupMenu.Create;
  mnuNew:=TMenuItem.Create(MainMenu,MF_OWNERDRAW,CM_NEW,PChar(@mnNew));
  mnuOld:=TMenuItem.Create(MainMenu,MF_OWNERDRAW,CM_OLD,PChar(@mnOld));
  mnuRed:=TMenuItem.Create(MainMenu,MF_OWNERDRAW,CM_RED,PChar(@mnRed));
  mnuProperties:=TMenuItem.Create(MainMenu,MF_OWNERDRAW,CM_PROP,PChar(@mnProperties));
//  mnuPrint:=TMenuItem.Create(Mainmenu,MF_STRING,CM_PRINT,'Печатать');
  mnuExit:=TMenuItem.Create(MainMenu,MF_OWNERDRAW,CM_EXIT,PChar(@mnExit));
  popFile.InsertItem(mnuNew);
  popFile.InsertItem(mnuOld);
  popFile.InsertItem(mnuRed);
  popFile.InsertItem(mnuProperties);
  //  popFile.InsertItem(mnuPrint);
  popFile.AddSeparator;
  popFile.InsertItem(mnuExit);

  MainMenu.CreateSubMenu(popFile,mnuFile);

  popEdit:=TPopupMenu.Create;
  mnuCut:=TMenuItem.Create(MainMenu,MF_OWNERDRAW,DOM_CUT,PChar(@mnCut));
  mnuCopy:=TMenuItem.Create(MainMenu,MF_OWNERDRAW,DOM_COPY,PChar(@mnCopy));
  mnuPaste:=TMenuItem.Create(MainMenu,MF_OWNERDRAW,DOM_PASTE,PChar(@mnPaste));
  mnuDelete:=TMenuItem.Create(MainMenu,MF_OWNERDRAW,DOM_DELETE,PChar(@mnDelete));
  mnuUndo:=TMenuItem.Create(MainMenu,MF_OWNERDRAW,DOM_UNDO,PChar(@mnUndo));
//  mnuSelectAll:=TMenuItem.Create(MainMenu,MF_STRING,DOM_SELECTALL,'Выделить все...Ctrl+A');
  popEdit.InsertItem(mnuCut);
  popEdit.InsertItem(mnuCopy);
  popEdit.InsertItem(mnuPaste);
  popEdit.InsertItem(mnuDelete);
  popEdit.AddSeparator;
  popEdit.InsertItem(mnuUndo);
  //popEdit.InsertItem(mnuSelectAll);
  MainMenu.CreateSubMenu(popEdit,mnuEdit);

{  popQuestion:=TPopupMenu.Create;
  mnuQAdd:=TMenuItem.Create(popQuestion,MF_OWNERDRAW,CM_QADD,PChar(@mnQAdd));
  mnuQDelete:=TMenuItem.Create(popQuestion,MF_OWNERDRAW,CM_QDELETE,PChar(@mnQDelete));
  mnuQCopy:=TMenuItem.Create(popQuestion,MF_OWNERDRAW,CM_QCOPY,PChar(@mnQCopy));
  mnuQpaste:=TMenuItem.Create(popQuestion,MF_OWNERDRAW,CM_QPASTE,PChar(@mnQPaste));

  popQuestion.InsertItem(mnuQAdd);
  popQuestion.InsertItem(mnuQDelete);
  popQuestion.InsertItem(mnuQCopy);
  popQuestion.InsertItem(mnuQPaste);
  popQuestion.InsertItem(mnuProperties);
  MainMenu.CreateSubMenu(popQuestion,mnuQuestion);
 }
  popObjects:=TPopupMenu.Create;
  mnuEcuat:=TMenuItem.Create(popObjects,MF_OWNERDRAW,CM_ECUAT,PChar(@mnEcuat));
  mnuBmp:=TMenuItem.Create(popObjects,MF_OWNERDRAW,CM_BMP,PChar(@mnBmp));
  mnuRefresh:=TMenuItem.Create(popObjects,MF_OWNERDRAW,CM_REFRESH,PChar(@mnRefresh));
  popObjects.InsertItem(mnuEcuat);
  popObjects.InsertItem(mnuBmp);
  popObjects.AddSeparator;
  popObjects.InsertItem(mnuRefresh);
  MainMenu.CreateSubMenu(popObjects,mnuObjects);

  mnuEcuat.Disable;
  mnuBmp.Disable;
  mnuRefresh.Disable;

  popWindow:=TPopupMenu.Create;
  mnuCascade:=TMenuItem.Create(popWindow,MF_OWNERDRAW,CM_CASCADE,PChar(@mnCascade));
  mnuTileH:=TMenuItem.Create(popWindow,MF_OWNERDRAW,CM_TILEH,PChar(@mnTileH));
  mnuTileV:=TMenuItem.Create(popWindow,MF_OWNERDRAW,CM_TILEV,PChar(@mnTileV));
  popWindow.InsertItem(mnuCascade);
  popWindow.Insertitem(mnuTileH);
  popWindow.Insertitem(mnuTileV);
  MainMenu.CreateSubMenu(popWindow,mnuWindow);
  SetWindowMenu(popWindow);

  popService:=TPopupmenu.Create;
  mnuService:=TMenuItem.Create(MainMenu,MF_STRING,107,'Настройка');
  //MainMenu.InsertItem(mnuService);
  mnuOptions:=TMenuItem.Create(popService,MF_OWNERDRAW,CM_OPTIONS,PChar(@mnOptions));
  popService.InsertItem(mnuOptions);
//  MainMenu.CreateSubMenu(popService,mnuService);

  popHelp:=TPopupMenu.Create;
  mnuAbout:=TMenuItem.Create(popHelp,MF_OWNERDRAW,CM_ABOUT,PChar(@mnAbout));
  popHelp.InsertItem(mnuAbout);
  MainMenu.CreateSubMenu(popHelp,mnuHelp);
end;

procedure TMyMDI.CreateToolBar;
var
  R:TRect;
begin
  ToolBar:=TToolbar.Create(Self);
  ToolBar.LoadBitmaps([1,2,3,4,5,6,7,8,9,10,25,51,52,53,54,71]);
  GetWindowRect(ToolBar.Handle,R);
  HToolBar:=R.Bottom-R.Top;
  btnNew:=TToolButton.Create(ToolBar,CM_NEW,0,DWORD(-1),'Создать новую тему');
  btnOld:=TToolButton.Create(ToolBar,CM_OLD,1,DWORD(-1),'Продолжить ввод темы');
  btnRed:=TToolButton.Create(ToolBar,CM_RED,2,DWORD(-1),'Редактировать тему');
  ToolBar.Separator;
  btnFont:=TToolButton.Create(ToolBar,CM_FONT,3,DWORD(-1),'Выбор параметров шрифта');
  btnUp:=TToolButton.Create(ToolBar,CM_UP,4,DWORD(-1),'Листать назад');
  btnDown:=TToolButton.Create(ToolBar,CM_DOWN,5,DWORD(-1),'Листать вперёд');
  btnMacro:=TToolButton.Create(ToolBar,CM_MACRO,6,DWORD(-1),'Макро');
  btnEcuat:=TToolButton.Create(ToolBar,CM_ECUAT,7,DWORD(-1),'Вставить формулу');
  btnBmp:=TToolButton.Create(ToolBar,CM_BMP,8,15,'Вставить рисунок');
  btnRefresh:=TToolButton.Create(ToolBar,CM_REFRESH,9,DWORD(-1),'Обновить содержимое редактора');
//  ToolBar.Separator;
{  btnQAdd:=TToolButton.Create(ToolBar,CM_QADD,11,DWORD(-1),'Добавить в тему вопрос');
  btnQDelete:=TToolButton.Create(ToolBar,CM_QDELETE,12,DWORD(-1),'Удалить текущий вопрос');
  btnQCopy:=TToolButton.Create(ToolBar,CM_QCOPY,13,DWORD(-1),'Копировать текущий вопрос');
  btnQPaste:=TToolButton.Create(ToolBar,CM_QPASTE,14,DWORD(-1),'Вставить из буфера');
 } btnFont.Disable;btnUp.Disable;btnDown.Disable;
//  btnEcuat.Disable;btnBmp.Disable;btnRefresh.Disable;
  //btnQAdd.Disable;btnQDelete.Disable;btnQCopy.Disable;btnQPaste.Disable;
  GetWindowRect(ToolBar.Handle,R);
  HToolBar:=R.Bottom-R.Top;
end;


procedure TMyMDI.FromCommandLine(st: string);
var
  TR:TRed;
  tema,fileName:string;
begin
  try
    UpdateWindow;                   //  чтобы убрать след от окна диалога
    ShowLoadMsg(Client.Handle);
    TR:=TRed.Create(Self,Client,PChar(st));
    TR.Show;//(SW_MAXIMIZE);
    TR.RTF.Show(SW_MAXIMIZE);
    SendMessage(TR.Handle,WM_SETFOCUS,0,0);
  except
    On E:Exception do
    begin
      EraseLoadMsg(Client.Handle);
      MessageBox(Handle,PChar(E.Message),'Turbo Test',$10);
      Exit;
      if TR<>nil then TR.Free;
    end;
  end;
  RefreshWindowMenu;
end;

end.

