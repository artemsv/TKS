{$O-}
unit MEdit;                              //  Дата создания : 06.11.02.

interface

uses Windows,UOleRTF,ActiveX,WinApp,OleRTF,RIchEdit,Main,Streams;

//  Базовый класс в иерархии классов.Позволяет просто вводить текст и
//  вставлять в него объекты.

type
  TEdit=class(TMDIChild,IRichEDitOleCallback)
  private
    procedure ChangeFont;
    procedure CreateObject(objType:DWORD);
  protected
    FileName:PChar;
    procedure DoSize(Wparam,LParam:DWORD);override;
    function DoCommand(Wparam,LParam:DWORD):DWORD;override;
    function SaveTema:boolean;virtual;abstract;
    function LoadTema:boolean;virtual;abstract;
    function GetRTF:TOleRTF;virtual;
    function DoEmbed:boolean;    
  public
    RTF:TOleRTF;
    FModified:boolean;                //  изменили ли какой либо кадр темы?
    constructor Create(AParent:TMDIWindow;AClient:TMDIClient;AFileName:PChar);virtual;
    destructor Destroy;override;
    { IRichEditOlCallback }
    function GetNewStorage( out stg: pointer): HRESULT; stdcall;
    function GetInPlaceContext(out Frame: IOleInPlaceFrame;out Doc:
             IOleInPlaceUIWindow; var FrameInfo: POleInPlaceFrameInfo):HRESULT; stdcall;
    function ShowContainerUI(fShow: BOOL): HRESULT; stdcall;
    function QueryInsertObject(const clsid: TGUID; stg: pointer; cp:
             longint):HRESULT; stdcall;
    function DeleteObject(oleobj: pointer): HRESULT; stdcall;
    function QueryAcceptData(dataobj: pointer; var cfFormat: word;
         reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT; stdcall;
    function ContextSensitiveHelp (fEnterMode: BOOL): HRESULT; stdcall;
    function GetClipboardData(const chrg: TCharRange; reco: DWORD;
             out dataobj: pointer): HRESULT; stdcall;
    function GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD;
             var dwEffect: DWORD): HRESULT; stdcall;
    function GetContextMenu(seltype: Word; oleobj: pointer;
             const chrg: TCharRange; var menu: HMENU): HRESULT; stdcall;
  end;

implementation

uses OleObj,SysUtils,MConst,Messages,WinFunc;

{ TEdit }

procedure TEdit.ChangeFont;
var
  LF:TLogFont;
  Color:COLORREF;
  CF:TCharFormat;
begin
  //RTF.Perform(WM_SETREDRAW,0,0);
  RTF.GetCharFormat(true,CF);
  FillChar(LF,SizeOf(LF),0);

  LF.lfHeight:=-MulDiv(CF.yHeight div 20,96,72);
  LF.lfPitchAndFamily:=CF.bPitchAndFamily;
  LF.lfCharSet:=CF.bCharSet;
  Move(CF.szFaceName,LF.lfFaceName,lstrlen(CF.szFaceName));
  if (CF.dwEffects and CFE_ITALIC)<>0 then LF.lfItalic:=1;
  if (CF.dwEffects and CFE_STRIKEOUT)<>0 then LF.lfStrikeout:=1;
  if (CF.dwEffects and CFE_UNDERLINE)<>0 then LF.lfUnderline:=1;

  if not GetFont(Handle,LF,Color) then
    Exit;
  if not RTF.IfNum(RTF.SelText) then     // если в выделенном есть номер
    Exit;
  FillChar(CF,SizeOf(CF),0);
  CF.cbSize:=SizeOf(CF);
  CF.yHeight :=20*-MulDiv(LF.lfHeight,72,96);

  if LF.lfStrikeout=1 then CF.dwEffects:=CF.dwEffects or CFE_STRIKEOUT;
  if LF.lfUnderline=1 then CF.dwEffects:=CF.dwEffects or CFE_UNDERLINE;
  if LF.lfItalic=1 then CF.dwEffects:=CF.dwEffects or CFE_ITALIC;
  CF.bCharSet:=LF.lfCharSet;

  lstrcpy(CF.szFaceName,LF.lfFaceName);
  CF.dwMask:=CFM_COLOR or CFM_SIZE or CFM_FACE or CFM_ITALIC or
    CFM_PROTECTED or CFM_BOLD or CFM_UNDERLINE or CFM_STRIKEOUT;
  CF.crTextColor:=Color;
  RTF.SetCharFormat(SCF_SELECTION,CF);
//  RTF.Perform(WM_SETREDRAW,1,0);
  InvalidateRect(RTF.Handle,nil,false);
end;

function TEdit.ContextSensitiveHelp(fEnterMode: BOOL): HRESULT;
begin
  Result:=S_OK;
end;

constructor TEdit.Create(AParent:TMDIWindow;AClient:TMDIClient;AFileName: PChar);
var
  KL:HKL;
begin
  KL:=GetKeyBoardLayout(0);
  inherited Create(AParent,AClient);
  RTF:=GetRTF;
//  SendMessage(RTF.Handle,EM_SETBKGNDCOLOR,0,$BEE7F2);
  FModified:=false;
//  RTF.Perform(EM_SETOLECALLBACK,0,DWORD(Self as IRichEditOleCallback));
  Perform(WM_SETICON,ICON_BIG,LoadIcon(MainInstance,PChar(154)));
  RTF.Show(SW_MAXIMIZE);
//  Show(SW_MAXIMIZE);                                 {TODO: Show-временно}
  ActivateKeyBoardLayout(Kl,0);        //  странно, но Show Меняет раскладку!
  FileName:=AFileName;
end;

procedure TEdit.CreateObject(objType: DWORD);
var
  OL:TOleObject;
begin
{ case MessageBox(Handle,'Вы хотите создать новый объект?','Turbo Test 6.0',
    MB_ICONQUESTION or MB_YESNOCANCEL or MB_SYSTEMMODAL) of
    ID_CANCEL:Exit;
    ID_YES:if objtype=CM_ECUAT then OL:=TOleEcuat.Create else OL:=TOleBMP.Create;
    ID_NO:
      begin
        if not GetFileName(Handle,'Файлы объектов'#0'*.ole'#0#0,
            'ec.ole',FileName) then Exit;
          OL.LoadFromFile(FileName);
      end;
  end;                              }
{  if objType<>CM_ECUAT then
      begin
        if not GetFileName(Handle,'Файлы объектов'#0'*.bmp'#0#0,
            'ec.ole',FileName) then Exit;
          OL:=TOleBMP.CreateFromFile(FileName);
      end;
 }
  if not DoEmbed then Exit;
  if objtype=CM_ECUAT then OL:=TOleEcuat.Create else OL:=TOleBMP.Create;
  OL.Embed(RTF.RichEditOle,RTF.GetCurCaretX,RTF);
end;

function TEdit.DeleteObject(oleobj: pointer): HRESULT;
begin
  Result:=S_OK;
end;

destructor TEdit.Destroy;
begin
  if RTF<>nil then RTF.Free;
  inherited;
end;

function TEdit.DoCommand(Wparam, LParam: DWORD):DWORD;
begin
  Result:=0;
  case Wparam of
    CM_ECUAT,CM_BMP:CreateObject(Wparam);
    CM_FONT:ChangeFont;                  //  окно выбора шрифта
    DOM_UPDATECARETPOS:
      SendMessage(Parent.Handle,WM_COMMAND,DOM_UPDATECARETPOS,LParam);
    DOM_UPDATEINSERTFLAG:
      SendMessage(Parent.Handle,WM_COMMAND,DOM_UPDATEINSERTFLAG,LParam);
  end;
end;

function TEdit.DoEmbed: boolean;
begin
  Result:=RTF.DoEmbed;
end;

procedure TEdit.DoSize(Wparam, LParam:DWORD);
begin
  if RTF<>nil then
    MoveWindow(RTF.Handle,0,0,LOWORD(LParam),HIWORD(LParam),false);
  inherited;
end;

function TEdit.GetClipboardData(const chrg: TCharRange; reco: DWORD;
  out dataobj: pointer): HRESULT;
begin
  Result:=S_OK;
end;

function TEdit.GetContextMenu(seltype: Word; oleobj: pointer;
  const chrg: TCharRange; var menu: HMENU): HRESULT;
begin
  Result:=S_OK;
  menu:=LoadMenu(MainInstance,PChar(701));
  menu:=GetSubMenu(menu,0);
end;

function TEdit.GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD;
  var dwEffect: DWORD): HRESULT;
begin
  Result:=E_NOTIMPL;
end;

function TEdit.GetInPlaceContext(out Frame: IOleInPlaceFrame;out Doc:
             IOleInPlaceUIWindow; var FrameInfo: POleInPlaceFrameInfo):HRESULT; stdcall;
var
  P:POleInPlaceFrameInfo;
begin
  Result:=S_OK;
  Frame:=Parent as IOleInPlaceFrame;
  Doc:=nil;//Frame;//}Parent as IOleInPlaceUIWindow;
  New(P);
  FrameInfo:=P;
  FrameInfo^.cb:=SizeOf(TOleInPlaceFrameInfo);
  FrameInfo^.fMDIApp:=true;
  FrameInfo^.hwndFrame:=Parent.Handle;
  FrameInfo^.haccel:=0;
  FrameInfo^.cAccelEntries:=0;
end;

function TEdit.GetNewStorage(out stg: pointer): HRESULT;
begin
  Result:=E_NOTIMPL;
end;

function TEdit.GetRTF: TOleRTF;
begin
  Result:=TOleRTF.Create(Self,ES_MULTILINE or ES_AUTOVSCROLL or ES_AUTOHSCROLL
    or ES_NOOLEDRAGDROP or WS_VSCROLL or WS_HSCROLL,WS_EX_ACCEPTFILES );
end;

function TEdit.QueryAcceptData(dataobj: pointer; var cfFormat: word;
  reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT;
begin
  Result:=E_NOTIMPL;
end;

function TEdit.QueryInsertObject(const clsid: TGUID; stg: pointer;cp: Integer): HRESULT;
begin
  Result:=S_OK;//Result:=E_NOTIMPL;
end;


function TEdit.ShowContainerUI(fShow: BOOL): HRESULT;
begin
  Result:=S_OK;
end;

end.
