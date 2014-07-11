{$O-}
unit OprMain;           //  дата преобразования в версию 6.0 : 15.11.02

interface

uses
  Windows,WinApp,WinCtrl,UOleRTF,MRed,Streams,OprTypes, MConst;

const
  Title='';
  Invite2='Начало опроса - F5';
  Invite3='Завершить - F12';
  Invite1='Сменить задание-F1';

type              //  класс клиентсого окна

  TOprosClient=class(TMDIClient)
  protected
    function DoEraseBkgnd(DC:HDC):integer;override;
  end;
                 //  класс рамочного окна
  TOprosMainWindow=class(TMDIWindow)
  private
    FInfo:RInfo;                         //  запись-настройки
    procedure CreateOprChild;            //  создать окно опроса
    function ReadInfo:boolean;           //  считать настройки
    function CreateInfo(info:RInfo;b:boolean):boolean;//  создать файл настроек
  protected
    function DoCommand(Wparam,LParam:DWORD):DWORD;override;
    procedure DoSize(WParam,LParam:DWORD);override;
    function GetClient:TMDIClient;override;
    function WndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
  public
    StatusBar:TStatusBar;                //  строка статуса
    HStatusBar:integer;                  //  высота строки состояния
    FTitle:string;
    KL:HKL;                             //  раскладка клавиатуры
    procedure NCPaint;                   //  прорисовка неклиентской части
    constructor Create;
    destructor Destroy;override;
  end;

implementation

{$R 'RES\OprMain.res'}

uses
  Messages,SysUtils,FNewTema,RichEdit,WinFunc,OprChild,IniFiles,MInput,
  CommCtrl,MListName,MMark,Macro;

{ TOprosMainWindow }

constructor TOprosMainWindow.Create;
var
  info:RInfo;
  R:TRect;
  Menu:HMENU;
var
  Ini:TIniFile;
  b:boolean;
begin
  inherited Create(//WS_OVERLAPPEDWINDOW
                    WS_CAPTION or WS_BORDER or WS_SYSMENU
                   ,WS_EX_CLIENTEDGE,0,0,GetSystemMetrics(SM_CXMAXIMIZED),
                   GetSystemmetrics(SM_CYMAXIMIZED),nil,nil,'TurboOpros');
{  Ini:=TIniFile.Create(Path+'\info.ini');
  b:=Ini.ReadBool('Root','test',false);
  if not b then
  begin
    MessageBox(Handle,'Тестирование запрещено','TurboTest 6.0',$10);
    Halt;
  end;
  Registrated(Handle);}
  FTitle:=Title;
  SendMessage(Handle,WM_SETICON,ICON_BIG,LoadIcon(MainInstance,PChar(401)));
  HAccl:=LoadAccelerators(0,PChar(402));        //  быстрые клавиши
  StatusBar:=TStatusBar.Create(Self);           //  создание строки статуса
  StatusBar.SetParts([208,560,-1]);          //  разделение её на панели
  StatusBar.Perform(WM_SETFONT,GetStockObject(DEFAULT_GUI_FONT),0);
  StatusBar.SetText(0,Invite1);StatusBar.SetText(1,Invite2);
  StatusBar.SetText(2,Invite3);
  GetWindowRect(StatusBar.Handle,R);
  HStatusBar:=R.Bottom-R.Top;
  if FileExists(Path+'\info.ini') then ReadInfo else
    if not CreateInfo(info,false) then Halt;
  Menu:=GetSystemMenu(Handle,false);
  DeleteMenu(Menu,SC_CLOSE,0);
  DeleteMenu(Menu,SC_MOVE,0);
  DeleteMenu(Menu,SC_SIZE,0);
  DeleteMenu(Menu,SC_MAXIMIZE,0);
  DeleteMenu(Menu,SC_RESTORE,0);
  DeleteMenu(Menu,SC_MINIMIZE,0);
  DeleteMenu(Menu,0,MF_BYPOSITION);
  AppendMenu(Menu,MF_BYPOSITION or MF_STRING,34564,'Сменить задание');
  AppendMenu(Menu,MF_BYPOSITION or MF_STRING,34565,'Начать тестирование');
  AppendMenu(Menu,MF_BYPOSITION or MF_STRING,34566,'Завершить');
end;

function TOprosMainWindow.CreateInfo(info:RInfo;b:boolean): boolean;
var
  Ini:TIniFile;
begin
  Result:=false;
  if not Input(Self,Info,b) then Exit;;
  FInfo:=info;
  Ini:=TIniFile.Create(Path+'\info.ini');
  Ini.WriteString('Root','date',FInfo.date);
  Ini.WriteString('Root','gruppa',FInfo.gr);
  Ini.WriteString('Root','tema',FInfo.tema);
  Ini.WriteString('Root','teacher',FInfo.teacher);
  Ini.WriteInteger('Root','time',FInfo.tim);
  Ini.WRiteString('Root','file',FInfo.fnt);
  Ini.WriteInteger('Root','colVopr',FInfo.colVopr);
  Ini.WriteInteger('Root','j5',FInfo.j5);
  Ini.WriteInteger('Root','j4',FInfo.j4);
  Ini.WriteInteger('Root','j3',FInfo.j3);
  Ini.WriteBool('Root','eraseOtchetFile',FInfo.eraseOtchetFile);
  Ini.WriteBool('Root','canList',FInfo.canList);
  Ini.WriteBool('Root','showOc',FInfo.showOC);
  IF FInfo.addToOtchetFile THEN
  Ini.WriteBool('Root','addToOtchetFile',true)
  else   Ini.WriteBool('Root','addToOtchetFile',false);
  Ini.WriteInteger('Root','colorBack',FInfo.colorBack);
  Ini.Free;
  if info.eraseOtchetFile then
    if FileExists(Path+'\'+OtchetFile) then
     DeleteFile(Path+'\'+OtchetFile);
  Result:=true;
end;

procedure TOprosMainWindow.CreateOprChild;
var
  fio:string;
  TOC:TOprosChild;
  Ini:TIniFile;
  b:boolean;
begin
{  Ini:=TIniFile.Create(Path+'\info.ini');
  b:=Ini.ReadBool('Root','test',false);
  if not b then
  begin
    MessageBox(Handle,'Тестирование запрещено','TurboTest 6.0',$10);
    Halt;
  end;}
  if Client.GetActiveWnd<>0 then Exit;
  if not ListName(Self,fio,FInfo) then Exit;
  UpdateWindow;                        //  чтобы убрать след от окна диалога
  ShowLoadMsg(Client.Handle);          //  отображение загрузочного сообщения
  FTitle:=fio;                         //  в заголовок окна-фамилию учащегося
  TOC:=TOprosChild.Create(Self,Client,FInfo,fio);
  SendMessage(TOC.RTF.Handle,EM_SETBKGNDCOLOR,0,FInfo.colorBack);
  TOC.Show(SW_MAXIMIZE);
  StatusBar.Clear(2);
end;

destructor TOprosMainWindow.Destroy;
begin
  StatusBar.Free;
  inherited;                   
end;

function TOprosMainWindow.DoCommand(Wparam, LParam: DWORD):DWORD;
begin
  Result:=0;
  case loword(Wparam) of
    SC_CLOSE:MessageBox(Handle,'sdfsdfs',nil,0);
    34564:if Client.GetActiveWnd=0 then CreateInfo(FInfo,true);  //  VK_F1
    34565:CreateOprChild;                    //  F5           //  VK_F5
    34566:if Client.GetActiveWnd<>0 then Exit else PostQuitMessage(0); //  VK_F12
    34567:                                  //  CTRL+Alt+F12
      if Client.GetActiveWnd<>0 then
      begin
        if MessageBox(Client.GetActiveWnd,'Опрос не завершен.Прервать?',
          'Turbo Test',MB_OKCANCEL+MB_ICONWARNING+MB_DEFBUTTON2) =ID_OK then
          begin
            Client.SendActive(WM_CLOSE,0,0);
            StatusBar.SetText(0,Invite1);StatusBar.SetText(1,Invite2);
            StatusBar.SetText(2,Invite3);
            Caption:='Turbo Test';
            NCPaint;
          end else Exit;
      end else PostQuitMessage(0);
    CM_STATUSTEXTCLEAR:StatusBar.Clear;
  end;
end;


procedure TOprosMainWindow.DoSize(WParam, LParam: DWORD);
begin
  if StatusBar<>nil then StatusBar.WMSize(0,LParam);
  LParam:=MakeLong(LOWORD(LParam),HIWORD(LParam)-HStatusBar);
  inherited;
end;

function TOprosMainWindow.GetClient: TMDIClient;
begin
  Result:=TOprosClient.Create(Self);
end;

procedure TOprosMainWindow.NCPaint;
var
  DC:HDC;
  cy,cx,bx:integer;
  R:TRect;
  B:HBRUSH;
begin
  DC:=GetWindowDC(Handle);
  cx:=GetSystemMetrics(SM_CXSCREEN);
  bx:=GetSystemMetrics(SM_CXSIZEFRAME);
  cy:=GetSystemMetrics(SM_CYCAPTION);
  SetRect(R,0,0,cx+13,cy+3);
  B:=CreateSolidBrush($AEA883);
  FillRect(DC,R,B);
  DeleteObject(B);
  SetBkMode(DC,TRANSPARENT);
  TextOut(DC,10,5,PChar(FTitle),Length(FTitle));
  ReleaseDC(DC,Handle);
end;

function TOprosMainWindow.ReadInfo: boolean;
var
  Ini:TIniFile;
begin
  Ini:=TIniFile.Create(Path+'/info.ini');
  FInfo.date:=Ini.ReadString('Root','date','01.01.01');
  FInfo.gr:=Ini.ReadString('Root','gruppa','as-12');
  FInfo.tema:=Ini.ReadString('Root','tema','Вариантная');
  FInfo.teacher:=Ini.ReadString('Root','teacher','Инкогнито');
  Finfo.tim:=Ini.ReadInteger('Root','time',90);
  FInfo.fnt:=Ini.ReadString('Root','file','var.tem');
  FInfo.colVopr:=Ini.ReadInteger('Root','colVopr',5);
  FInfo.j5:=Ini.ReadInteger('Root','j5',85);
  FInfo.j4:=Ini.ReadInteger('Root','j4',70);
  FInfo.j3:=Ini.ReadInteger('Root','j3',55);
  FInfo.eraseOtchetFile:=Ini.ReadBool('Root','eraseOtchetFile',true);
  FInfo.canList:=Ini.ReadBool('Root','canList',false);
  FInfo.showOC:=Ini.ReadBool('Root','showOC',true);
  FInfo.colorBack:=Ini.ReadInteger('Root','colorBack',$FFFFFF);
  FInfo.addToOtchetFile:=Ini.ReadBool('Root','addToOtchetFile',true);
  Ini.Free
end;

function TOprosMainWindow.WndProc(Wnd: HWND; Msg, WParam,
  LParam: DWORD): DWORD;
var
  P:TPoint;
  a:array[0..4] of integer;
begin
  Result:=0;
  case Msg of
    WM_INITMENU:NCPaint;
    WM_SYSCOMMAND:
    case WParam of
      34564:if Client.GetActiveWnd=0 then CreateInfo(FInfo,true);  //  VK_F1
      34565:CreateOprChild;                    //  F5           //  VK_F5
      34566:if Client.GetActiveWnd<>0 then Exit else PostQuitMessage(0); //  VK_F12
    else
      Result:=inherited WndProc(Wnd,Msg,WParam,LParam);
    end;
    WM_NCLBUTTONDBLCLK,WM_NCLBUTTONDOWN:;
    WM_NOTIFY:
    if (PNMHDR(LParam).code=NM_CLICK) and (PNMHDR(LParam).hwndFrom=StatusBar.Handle) then
    begin
      GetCursorPos(P);
      SendMessage(StatusBar.Handle,SB_GETPARTS,7,DWORD(@a));
      if (P.x<a[0]) then if Client.GetActiveWnd=0 then CreateInfo(FInfo,true);
      if (P.x>a[1]) then if Client.GetActiveWnd=0 then PostQuitMessage(0);
      if (P.x>a[0]) and (P.x<a[1]) then CreateOprChild;
    end;

  else
    Result:=inherited WndProc(Wnd,Msg,WParam,LParam);
  end;
  if (Msg=WM_SETFOCUS) or (Msg=WM_KILLFOCUS)or (Msg=WM_ACTIVATE) or
      (Msg=WM_NCPAINT) then NCPaint;
end;

{ TOprosClient }

function TOprosClient.DoEraseBkgnd(DC: HDC): integer;
var
  R:TRect;
  Brush:HBRUSH;
  f:HFONT;
  lf:TLogFont;
  cx,a,b,cy:integer;
const
  c:COLORREF=$72A58D;                    //  цвет заставки Turbo Test
  Color2:COLORREF=$123765;               //  цвет второй надписи
begin
  cx:=GetSystemMetrics(SM_CXSCREEN);
  cy:=GetSystemMetrics(SM_CYSCREEN);
  a:=cx div 2;b:=cy div 2;
  inherited DoEraseBkgnd(DC);
  GetWindowRect(Handle,R);
  Brush:=CreateSolidBrush($809AAE);
  SelectObject(DC,Brush);
  Rectangle(DC,0,0,R.Right,R.Bottom);
  DeleteObject(Brush);
  SelectObject(DC,GetStockObject(BLACK_PEN));
  Brush:=CreateSolidBrush(c);
  SelectObject(DC,Brush);
  Rectangle(DC,a-250,b-150,a+250,b+150);
  SetRect(R,a-250+1,b-150+1,a+250-1,b+150-1);
  FillRect(DC,R,Brush);SetBkColor(DC,C);
  SetTextColor(DC,$000000);
  FillChar(lf,SizeOf(lf),0);lf.lfItalic:=1;
  lf.lfStrikeOut:=0;lf.lfUnderline:=0;
  lf.lfHeight:=112;lf.lfWidth:=50;lf.lfFaceName:='Tahoma';
  lf.lfWeight:=700;f:=CreateFontIndirect(LF);SelectObject(DC,f);
  SetBkMode(DC,TRANSPARENT);
  TextOut(DC,a-210,b-140,'Turbo',5);TextOut(DC,a-40,b-30,'Test',4);
  SetTextColor(DC,Color2);
  TextOut(DC,a-205,b-135,'Turbo',5);TextOut(DC,a-35,b-25,'Test',4);
  SetTextColor(DC,$000000);
  DeleteObject(f);
  lf.lfHeight:=24;lf.lfWidth:=9;lf.lfFaceName:='Times New Roman';
  lf.lfWeight:=400;f:=CreateFontIndirect(LF);SelectObject(DC,f);
  TextOut(DC,a-220,b+95,'Copyright @ 2000,2002 by Sokol Software Inc.',44);
  TextOut(DC,a-220,b+45,'Version 6.0',11);
  DeleteObject(f);
  Arc(DC,a+200,b,a+220,b+20,0,0,0,0);lf.lfItalic:=0;
  lf.lfHeight:=16;lf.lfWidth:=5;lf.lfFaceName:='System';
  lf.lfWeight:=100;f:=CreateFontIndirect(LF);SelectObject(DC,f);
  TextOut(DC,a+205,b+2,'R',1);
  DeleteObject(f);
  Result := 1;
end;
end.

