{$O-}
unit OleCtnr;				//  ¤ в  б®§¤ ­Ёп 31.10.02.

{$T-,H+,X+}

interface

uses Windows, Messages, CommCtrl, ActiveX, OleDlg, SysUtils, Classes,
     WinApp, Graphics, OleRTF,ComObj,WinFile,RichEdit;

const
  ovShow = -1;
  ovOpen = -2;
  ovHide = -3;
  ovUIActivate = -4;                      
  ovInPlaceActivate = -5;
  ovDiscardUndoState = -6;
  ovPrimary = -65536;

type
  TOleContainer = class;
  TOleWin = class;

  IAWLFrameWindow = interface(IOleInPlaceFrame)
    ['{CD02E1C0-52DA-11D0-9EA6-0020AF3D82DA}']
    procedure ClearBorderSpace;
    function Window: TWindow;
  end;

  TAutoActivate = (aaManual, aaGetFocus, aaDoubleClick);

  TSizeMode = (smClip, smCenter, smScale, smStretch, smAutoSize);

 TObjectState = (osEmpty, osLoaded, osRunning, osOpen, osInPlaceActive,
    osUIActive);

  TCreateType = (ctNewObject, ctFromFile, ctLinkToFile, ctFromData,
    ctLinkFromData);

  TCreateInfo = record
    CreateType: TCreateType;
    ShowAsIcon: Boolean;
    IconMetaPict: HGlobal;
    ClassID: TCLSID;
    FileName: WideString;
    DataObject: IDataObject;
  end;

  TVerbInfo = packed record
    Verb: Smallint;
    Flags: Word;
  end;

  TObjectMoveEvent = procedure(OleContainer: TOleContainer;
    const Bounds: TRect) of object;

  TFormBorderStyle = (bsNone, bsSingle, bsSizeable, bsDialog, bsToolWindow,
    bsSizeToolWin);
  TBorderStyle = bsNone..bsSingle;

  ISave = interface
  ['{0B17AC80-0057-11D0-BCF9-5254AB54128E}']
    function SaveToFile(const FileName:string):HResult;stdcall;
  end;

  TOleContainer = class(TWin, IUnknown, IOleClientSite,
    IOleInPlaceSite, IAdviseSink)
  private
    FRefCount: Longint;
    FLockBytes: ILockBytes;
    FStorage: IStorage;
    FOleObject: IOleObject;
    FDrawAspect: Longint;
    FViewSize: TPoint;
    FObjectVerbs: TStringList;
    FDataConnection: Longint;
    FDocForm: IAWLFrameWindow;
    FFrameForm: IAWLFrameWindow;
    FOleInPlaceObject: IOleInPlaceObject;
    FOleInPlaceActiveObject: IOleInPlaceActiveObject;
    FAccelTable: HAccel;
    FAccelCount: Integer;
//    FPopupVerbMenu: TPopupMenu;
    FAllowInPlace: Boolean;
    FAllowActiveDoc: Boolean;
    FAutoActivate: TAutoActivate;
    FAutoVerbMenu: Boolean;
    FBorderStyle: TBorderStyle;
    FCopyOnSave: Boolean;
    FOldStreamFormat: Boolean;
    FSizeMode: TSizeMode;
    FObjectOpen: Boolean;
    FUIActive: Boolean;
    FModified: Boolean;
    FModSinceSave: Boolean;
    FFocused: Boolean;
    FNewInserted: Boolean;
    FOnActivate: TNotifyEvent;
    FOnDeactivate: TNotifyEvent;
    FOnObjectMove: TObjectMoveEvent;
    FOnResize: TNotifyEvent;
    FDocView: IOleDocumentView;
    FDocObj: Boolean;
    { IOleClientSite }
    function SaveObject: HResult; stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
    function GetContainer(out container: IOleContainer): HResult; stdcall;
    function ShowObject: HResult; stdcall;
    function OnShowWindow(fShow: BOOL): HResult; stdcall;
    function RequestNewObjectLayout: HResult; stdcall;
    { IOleInPlaceSite }
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    function GetWindow(out wnd: HWnd): HResult; stdcall;
    function CanInPlaceActivate: HResult; stdcall;
    function OnInPlaceActivate: HResult; stdcall;
    function OnUIActivate: HResult; stdcall;
    function GetWindowContext(out frame: IOleInPlaceFrame;
      out doc: IOleInPlaceUIWindow; out rcPosRect: TRect;
      out rcClipRect: TRect; out frameInfo: TOleInPlaceFrameInfo): HResult;
      stdcall;
    function Scroll(scrollExtent: TPoint): HResult; stdcall;
    function OnUIDeactivate(fUndoable: BOOL): HResult; stdcall;
    function OnInPlaceDeactivate: HResult; stdcall;
    function DiscardUndoState: HResult; stdcall;
    function DeactivateAndUndo: HResult; stdcall;
    function OnPosRectChange(const rcPosRect: TRect): HResult; stdcall;
    { IAdviseSink }
    procedure OnDataChange(const formatetc: TFormatEtc;
      const stgmed: TStgMedium); stdcall;
    procedure OnViewChange(dwAspect: Longint; lindex: Longint); stdcall;
    procedure OnRename(const mk: IMoniker); stdcall;
    procedure OnSave; stdcall;
    procedure OnClose; stdcall;
    { IOleDocumentSite }
    function ActivateMe(View: IOleDocumentView): HRESULT; stdcall;
    { IOleUIObjInfo }
    function GetObjectInfo(dwObject: Longint;
      var dwObjSize: Longint; var lpszLabel: PChar;
      var lpszType: PChar; var lpszShortType: PChar;
      var lpszLocation: PChar): HResult; stdcall;
    function GetConvertInfo(dwObject: Longint; var ClassID: TCLSID;
      var wFormat: Word; var ConvertDefaultClassID: TCLSID;
      var lpClsidExclude: PCLSID; var cClsidExclude: Longint): HResult; stdcall;
    function ConvertObject(dwObject: Longint;
      const clsidNew: TCLSID): HResult; stdcall;
    function GetViewInfo(dwObject: Longint; var hMetaPict: HGlobal;
      var dvAspect: Longint; var nCurrentScale: Integer): HResult; stdcall;
    function SetViewInfo(dwObject: Longint; hMetaPict: HGlobal;
      dvAspect: Longint; nCurrentScale: Integer;
      bRelativeToOrig: BOOL): HResult; stdcall;
    { TOleContainer }
    procedure AdjustBounds;
    procedure CheckObject;
    procedure CreateAccelTable;
    procedure CreateStorage;
//    procedure DesignModified;
//    procedure DestroyAccelTable;
    procedure DestroyVerbs;
    function GetBorderWidth: Integer;
    function GetCanPaste: Boolean;
    function GetIconic: Boolean;
    function GetLinked: Boolean;
    function GetObjectDataSize: Integer;
    function GetObjectVerbs: TStrings;
    function GetOleClassName: string;
    function GetOleObject: Variant;
    function GetPrimaryVerb: Integer;
    function GetSourceDoc: string;
    function GetState: TObjectState;
    procedure InitObject;
    procedure ObjectMoved(const ObjectRect: TRect);
    procedure PopupVerbMenuClick(Sender: TObject);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetDrawAspect(Iconic: Boolean; IconMetaPict: HGlobal);
    procedure SetFocused(Value: Boolean);
    procedure SetIconic(Value: Boolean);
    procedure SetSizeMode(Value: TSizeMode);
    procedure SetUIActive(Active: Boolean);
    procedure SetViewAdviseSink(Enable: Boolean);
    procedure UpdateObjectRect;
    procedure UpdateView;
{    procedure CMDocWindowActivate(var Message: TMessage); message CM_DOCWINDOWACTIVATE;
    procedure CMUIDeactivate(var Message: TMessage); message CM_UIDEACTIVATE;
    procedure WMKillFocus(var Message: TWMSetFocus); message WM_KILLFOCUS;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
 } public
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): HResult; {override; }stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure Changed; dynamic;
    procedure GetWndClassEx(var WC:TWndClassEx);override;
//    procedure CreateParams(var Params: TCreateParams); override;
//    procedure DblClick; override;
//    procedure DefineProperties(Filer: TFiler); override;
//    procedure DoEnter; override;
//    function GetPopupMenu: TPopupMenu; override;
//    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
//    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
//      X, Y: Integer); override;
  public
    function WndProc(Wnd:HWND;Msg,WParam,LParam:DWORD):DWORD;override;
    constructor Create(AParent: TWin);
    destructor Destroy; override;
    function ChangeIconDialog: Boolean;
    procedure Close;
    procedure Copy;
    procedure CreateLinkToFile(const FileName: string; Iconic: Boolean);
    procedure CreateObject(const OleClassName: string; Iconic: Boolean);
    procedure CreateObjectFromFile(const FileName: string; Iconic: Boolean);
    procedure CreateObjectFromInfo(const CreateInfo: TCreateInfo);
    procedure DestroyObject;
    procedure DoVerb(Verb: Integer);
    function GetIconMetaPict: HGlobal;
    function InsertObjectDialog: Boolean;
    procedure LoadFromFile(const FileName: string);
    procedure LoadFromStream(Stream: TFile);
    procedure Paste;
    function PasteSpecialDialog: Boolean;
    procedure Run;
    procedure SaveAsDocument(const FileName: string);
    { ISave }
    function SaveToFile(const FileName: string):HResult;stdcall;

    procedure SaveToStream(Stream: TFile);
    procedure UpdateObject;
    procedure UpdateVerbs;
    procedure CreateNewObject(n:DWORD);
    property CanPaste: Boolean read GetCanPaste;
    property Linked: Boolean read GetLinked;
    property Modified: Boolean read FModified write FModified;
    property NewInserted: Boolean read FNewInserted;
    property ObjectVerbs: TStrings read GetObjectVerbs;
    property OleClassName: string read GetOleClassName;
    property OleObject: Variant read GetOleObject;
    property OleObjectInterface: IOleObject read FOleObject write FOleObject;
    property PrimaryVerb: Integer read GetPrimaryVerb;
    property SourceDoc: string read GetSourceDoc;
    property State: TObjectState read GetState;
    property StorageInterface: IStorage read FStorage write FStorage;
  published
    property AllowInPlace: Boolean read FAllowInPlace write FAllowInPlace default True;
    property AllowActiveDoc: Boolean read FAllowActiveDoc write FAllowActiveDoc default True;
    property AutoActivate: TAutoActivate read FAutoActivate write FAutoActivate default aaDoubleClick;
    property AutoVerbMenu: Boolean read FAutoVerbMenu write FAutoVerbMenu default True;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property CopyOnSave: Boolean read FCopyOnSave write FCopyOnSave default True;
    property Iconic: Boolean read GetIconic write SetIconic stored False;
    property OldStreamFormat: Boolean read FOldStreamFormat write FOldStreamFormat default False;
    property SizeMode: TSizeMode read FSizeMode write SetSizeMode default smClip;
  end;

  TOleWin= class(TInterfacedObject, IOleWindow, IOleInPlaceUIWindow,
    IOleInPlaceFrame, IAWLFrameWindow)
  private
    FForm: TWindow;
    FContainers: TList;
    FActiveObject: IOleInPlaceActiveObject;
    FSaveWidth: Integer;
    FSaveHeight: Integer;
    { IOleForm }
    procedure OnDestroy;
    procedure OnResize;
    { IOleWindow }
    function GetWindow(out wnd: HWnd): HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    { IOleInPlaceUIWindow }
    function GetBorder(out BorderRect: TRect): HResult; stdcall;
    function RequestBorderSpace(const borderwidths: TRect): HResult; stdcall;
    function SetBorderSpace(pborderwidths: PRect): HResult; stdcall;
    function SetActiveObject(const ActiveObject: IOleInPlaceActiveObject;
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
    { IAWLFrameForm }
    function Window: TWindow;
    procedure ClearBorderSpace;
  public
    constructor Create(Win:TWindow);
    destructor Destroy; override;
  end;

  TRTFOle=class(TOleContainer,IRichEditOleCallback)
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
  
procedure DestroyMetaPict(MetaPict: HGlobal);

implementation

uses MConst,OleConst,Main;

{$R 'C:\Program Files\Borland\Delphi5\Projects\Test6\RES\ole.res'}
 
const
  DataFormatCount = 2;
  StreamSignature = $434F4442; {'BDOC'}

type
  TStreamHeader = record
    case Integer of
      0: ( { New }
        Signature: Integer;
        DrawAspect: Integer;
        DataSize: Integer);
      1: ( { Old }
        PartRect: TSmallRect);
  end;

{ Private variables }

var
  PixPerInch: TPoint;
  CFObjectDescriptor: Integer;
  CFEmbeddedObject: Integer;
  CFLinkSource: Integer;
  DataFormats: array[0..DataFormatCount - 1] of TFormatEtc;

{ Return length of PWideChar string }

function WStrLen(Str: PWideChar): Integer;
begin
  Result := 0;
  while Str[Result] <> #0 do Inc(Result);
end;

{ Convert point from pixels to himetric }

function PixelsToHimetric(const P: TPoint): TPoint;
begin
  Result.X := MulDiv(P.X, 2540, PixPerInch.X);
  Result.Y := MulDiv(P.Y, 2540, PixPerInch.Y);
end;

{ Convert point from himetric to pixels }

function HimetricToPixels(const P: TPoint): TPoint;
begin
  Result.X := MulDiv(P.X, PixPerInch.X, 2540);
  Result.Y := MulDiv(P.Y, PixPerInch.Y, 2540);
end;

{ Center the given window on the screen }

procedure CenterWindow(Wnd: HWnd);
var
  Rect: TRect;
begin
  GetWindowRect(Wnd, Rect);
  SetWindowPos(Wnd, 0,
    (GetSystemMetrics(SM_CXSCREEN) - Rect.Right + Rect.Left) div 2,
    (GetSystemMetrics(SM_CYSCREEN) - Rect.Bottom + Rect.Top) div 3,
    0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
end;

{ Generic dialog hook. Centers the dialog on the screen in response to
  the WM_INITDIALOG message }

function OleDialogHook(Wnd: HWnd; Msg, WParam, LParam: Longint): Longint; stdcall;
begin
  Result := 0;
  if Msg = WM_INITDIALOG then
  begin
    if GetWindowLong(Wnd, GWL_STYLE) and WS_CHILD <> 0 then
      Wnd := GetWindowLong(Wnd, GWL_HWNDPARENT);
    CenterWindow(Wnd);
    Result := 1;
  end;
end;

{ Destroy a metafile picture }

procedure DestroyMetaPict(MetaPict: HGlobal);
begin
  if MetaPict <> 0 then
  begin
    DeleteMetaFile(PMetaFilePict(GlobalLock(MetaPict))^.hMF);
    GlobalUnlock(MetaPict);
    GlobalFree(MetaPict);
  end;
end;

{ Shade rectangle }

procedure ShadeRect(DC: HDC; const Rect: TRect);
const
  HatchBits: array[0..7] of Word = ($11, $22, $44, $88, $11, $22, $44, $88);
var
  Bitmap: HBitmap;
  SaveBrush: HBrush;
  SaveTextColor, SaveBkColor: TColorRef;
begin
  Bitmap := CreateBitmap(8, 8, 1, 1, @HatchBits);
  SaveBrush := SelectObject(DC, CreatePatternBrush(Bitmap));
  SaveTextColor := SetTextColor(DC, clWhite);
  SaveBkColor := SetBkColor(DC, clBlack);
  with Rect do PatBlt(DC, Left, Top, Right - Left, Bottom - Top, $00A000C9);
  SetBkColor(DC, SaveBkColor);
  SetTextColor(DC, SaveTextColor);
  DeleteObject(SelectObject(DC, SaveBrush));
  DeleteObject(Bitmap);
end;

{ Return the first piece of a moniker }

function OleStdGetFirstMoniker(const Moniker: IMoniker): IMoniker;
var
  Mksys: Longint;
  EnumMoniker: IEnumMoniker;
begin
  Result := nil;
  if Moniker <> nil then
  begin
    if (Moniker.IsSystemMoniker(Mksys) = 0) and
      (Mksys = MKSYS_GENERICCOMPOSITE) then
    begin
      if Moniker.Enum(True, EnumMoniker) <> 0 then Exit;
      EnumMoniker.Next(1, Result, nil);
    end
    else
      Result := Moniker;
  end;
end;

{ Return length of file moniker piece of the given moniker }

function OleStdGetLenFilePrefixOfMoniker(const Moniker: IMoniker): Integer;
var
  MkFirst: IMoniker;
  BindCtx: IBindCtx;
  Mksys: Longint;
  P: PWideChar;
begin
  Result := 0;
  if Moniker <> nil then
  begin
    MkFirst := OleStdGetFirstMoniker(Moniker);
    if (MkFirst <> nil) and
      (MkFirst.IsSystemMoniker(Mksys) = 0) and
      (Mksys = MKSYS_FILEMONIKER) and
      (CreateBindCtx(0, BindCtx) = 0) and
      (MkFirst.GetDisplayName(BindCtx, nil, P) = 0) and (P <> nil) then
    begin
      Result := WStrLen(P);
      CoTaskMemFree(P);
    end;
  end;
end;

function CoAllocCStr(const S: string): PChar;
begin
  Result := StrCopy(CoTaskMemAlloc(Length(S) + 1), PChar(S));
end;

function GetFullNameStr(const OleObject: IOleObject): string;
var
  P: PWideChar;
begin
  OleObject.GetUserType(USERCLASSTYPE_FULL, P);
  Result := P;
  CoTaskMemFree(P);
end;

function GetShortNameStr(const OleObject: IOleObject): string;
var
  P: PWideChar;
begin
  OleObject.GetUserType(USERCLASSTYPE_SHORT, P);
  Result := P;
  CoTaskMemFree(P);
end;

function GetDisplayNameStr(const OleLink: IOleLink): string;
var
  P: PWideChar;
begin
  OleLink.GetSourceDisplayName(P);
  Result := P;
  CoTaskMemFree(P);
end;

function GetAWLFrameWIndow(Form: TWindow): IAWLFrameWindow;
begin
//  Result := Form as IAWLFrameWindow;
end;

procedure LinkError(const Ident: string);
begin
  MessageBox(MainWindow.Handle,PChar(Ident), PChar(SLinkProperties),
    MB_OK or MB_ICONSTOP);
end;

{ TEnumFormatEtc - format enumerator for TDataObject }

type
  PFormatList = ^TFormatList;
  TFormatList = array[0..255] of TFormatEtc;

type
  TEnumFormatEtc = class(TInterfacedObject, IEnumFormatEtc)
  private
    FFormatList: PFormatList;
    FFormatCount: Integer;
    FIndex: Integer;
  public
    constructor Create(FormatList: PFormatList; FormatCount, Index: Integer);
    { IEnumFormatEtc }
    function Next(celt: Longint; out elt; pceltFetched: PLongint): HResult; stdcall;
    function Skip(celt: Longint): HResult; stdcall;
    function Reset: HResult; stdcall;
    function Clone(out enum: IEnumFormatEtc): HResult; stdcall;
  end;

constructor TEnumFormatEtc.Create(FormatList: PFormatList;
  FormatCount, Index: Integer);
begin
  inherited Create;
  FFormatList := FormatList;
  FFormatCount := FormatCount;
  FIndex := Index;
end;

function TEnumFormatEtc.Next(celt: Longint; out elt; pceltFetched: PLongint): HResult;
var
  I: Integer;
begin
  I := 0;
  while (I < celt) and (FIndex < FFormatCount) do
  begin
    TFormatList(elt)[I] := FFormatList[FIndex];
    Inc(FIndex);
    Inc(I);
  end;
  if pceltFetched <> nil then pceltFetched^ := I;
  if I = celt then Result := S_OK else Result := S_FALSE;
end;

function TEnumFormatEtc.Skip(celt: Longint): HResult;
begin
  if celt <= FFormatCount - FIndex then
  begin
    FIndex := FIndex + celt;
    Result := S_OK;
  end else
  begin
    FIndex := FFormatCount;
    Result := S_FALSE;
  end;
end;

function TEnumFormatEtc.Reset: HResult;
begin
  FIndex := 0;
  Result := S_OK;
end;

function TEnumFormatEtc.Clone(out enum: IEnumFormatEtc): HResult;
begin
  enum := TEnumFormatEtc.Create(FFormatList, FFormatCount, FIndex);
  Result := S_OK;
end;

{ TDataObject - data object for use in clipboard transfers }

type
  TDataObject = class(TInterfacedObject, IDataObject)
  private
    FOleObject: IOleObject;
    function GetObjectDescriptor: HGlobal;
  public
    constructor Create(const OleObject: IOleObject);
    { IDataObject }
    function GetData(const formatetcIn: TFormatEtc;
      out medium: TStgMedium): HResult; stdcall;
    function GetDataHere(const formatetc: TFormatEtc;
      out medium: TStgMedium): HResult; stdcall;
    function QueryGetData(const formatetc: TFormatEtc): HResult; stdcall;
    function GetCanonicalFormatEtc(const formatetc: TFormatEtc;
      out formatetcOut: TFormatEtc): HResult; stdcall;
    function SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
      fRelease: BOOL): HResult; stdcall;
    function EnumFormatEtc(dwDirection: Longint; out enumFormatEtc:
      IEnumFormatEtc): HResult; stdcall;
    function DAdvise(const formatetc: TFormatEtc; advf: Longint;
      const advSink: IAdviseSink; out dwConnection: Longint): HResult; stdcall;
    function DUnadvise(dwConnection: Longint): HResult; stdcall;
    function EnumDAdvise(out enumAdvise: IEnumStatData): HResult; stdcall;
  end;

constructor TDataObject.Create(const OleObject: IOleObject);
begin
  inherited Create;
  FOleObject := OleObject;
end;

function TDataObject.GetObjectDescriptor: HGlobal;
var
  DescSize, UTNCharLen, SOCCharLen: Integer;
  Descriptor: PObjectDescriptor;
  UserTypeName, SourceOfCopy: string;
  OleLink: IOleLink;
  P: PWideChar;
begin
  UserTypeName := GetFullNameStr(FOleObject);
  SourceOfCopy := UserTypeName;
  FOleObject.QueryInterface(IOleLink, OleLink);
  if OleLink <> nil then
  begin
    UserTypeName := Format(SLinkedObject, [UserTypeName]);
    SourceOfCopy := GetDisplayNameStr(OleLink);
  end;
  UTNCharLen := MultiByteToWideChar(0, 0, PChar(UserTypeName),
      Length(UserTypeName), nil, 0) + 1;
  SOCCharLen := MultiByteToWideChar(0, 0, PChar(SourceOfCopy),
      Length(SourceOfCopy), nil, 0) + 1;
  DescSize := SizeOf(TObjectDescriptor) +
    ((UTNCharLen + SOCCharLen) * Sizeof(WideChar));
  Result := GlobalAlloc(GMEM_MOVEABLE, DescSize);
  if Result <> 0 then
  begin
    Descriptor := GlobalLock(Result);
    FillChar(Descriptor^, DescSize, 0);
    with Descriptor^ do
    begin
      cbSize := DescSize;
      FOleObject.GetUserClassID(clsid);
      dwDrawAspect := DVASPECT_CONTENT;
      FOleObject.GetMiscStatus(DVASPECT_CONTENT, dwStatus);

      dwFullUserTypeName := SizeOf(TObjectDescriptor);
      P := PWideChar(Integer(Descriptor) + dwFullUserTypeName);
      MultiByteToWideChar(0, 0, PChar(UserTypeName), Length(UserTypeName),
        P, UTNCharLen);
      P[UTNCharLen-1] := #0;

      dwSrcOfCopy := dwFullUserTypeName + SOCCharLen * SizeOf(WideChar);
      P := PWideChar(Integer(Descriptor) + dwSrcOfCopy);
      MultiByteToWideChar(0, 0, PChar(SourceOfCopy), Length(SourceOfCopy),
        P, SOCCharLen);
      P[SOCCharLen-1] := #0;
    end;
    GlobalUnlock(Result);
  end;
end;

function TDataObject.GetData(const formatetcIn: TFormatEtc;
  out medium: TStgMedium): HResult;
var
  Descriptor: HGlobal;
begin
  Result := DV_E_FORMATETC;
  medium.tymed := 0;
  medium.hGlobal := 0;
  medium.unkForRelease := nil;
  with formatetcIn do
  begin
    if (cfFormat = CFObjectDescriptor) and (dwAspect = DVASPECT_CONTENT) and
      (tymed = TYMED_HGLOBAL) then
    begin
      Descriptor := GetObjectDescriptor;
      if Descriptor <> 0 then
      begin
        medium.tymed := TYMED_HGLOBAL;
        medium.hGlobal := Descriptor;
        Result := S_OK;
      end;
    end;
  end;
end;

function TDataObject.GetDataHere(const formatetc: TFormatEtc;
  out medium: TStgMedium): HResult;
var
  PersistStorage: IPersistStorage;
begin
  Result := DV_E_FORMATETC;
  with formatetc do
    if (cfFormat = CFEmbeddedObject) and (dwAspect = DVASPECT_CONTENT) and
      (tymed = TYMED_ISTORAGE) then
    begin
      medium.unkForRelease := nil;
      FOleObject.QueryInterface(IPersistStorage, PersistStorage);
      if PersistStorage <> nil then
      begin
        Result := OleSave(PersistStorage, IStorage(medium.stg), False);
        PersistStorage.SaveCompleted(nil);
      end;
    end;
end;

function TDataObject.QueryGetData(const formatetc: TFormatEtc): HResult;
begin
  Result := DV_E_FORMATETC;
  with formatetc do
    if dwAspect = DVASPECT_CONTENT then
      if (cfFormat = CFEmbeddedObject) and (tymed = TYMED_ISTORAGE) or
        (cfFormat = CFObjectDescriptor) and (tymed = TYMED_HGLOBAL) then
        Result := S_OK;
end;

function TDataObject.GetCanonicalFormatEtc(const formatetc: TFormatEtc;
  out formatetcOut: TFormatEtc): HResult;
begin
  formatetcOut.ptd := nil;
  Result := E_NOTIMPL;
end;

function TDataObject.SetData(const formatetc: TFormatEtc; var medium: TStgMedium;
  fRelease: BOOL): HResult;
begin
  Result := E_NOTIMPL;
end;

function TDataObject.EnumFormatEtc(dwDirection: Longint; out enumFormatEtc:
  IEnumFormatEtc): HResult;
begin
  if dwDirection = DATADIR_GET then
  begin
    enumFormatEtc := TEnumFormatEtc.Create(@DataFormats, DataFormatCount, 0);
    Result := S_OK;
  end else
  begin
    enumFormatEtc := nil;
    Result := E_NOTIMPL;
  end;
end;

function TDataObject.DAdvise(const formatetc: TFormatEtc; advf: Longint;
  const advSink: IAdviseSink; out dwConnection: Longint): HResult;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TDataObject.DUnadvise(dwConnection: Longint): HResult;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

function TDataObject.EnumDAdvise(out enumAdvise: IEnumStatData): HResult;
begin
  Result := OLE_E_ADVISENOTSUPPORTED;
end;

{ TOleContainer.IOleUIObjInfo - helper interface for Object Properties dialog }

function TOleContainer.GetObjectInfo(dwObject: Longint;
  var dwObjSize: Longint; var lpszLabel: PChar;
  var lpszType: PChar; var lpszShortType: PChar;
  var lpszLocation: PChar): HResult;
begin
  if @dwObjSize <> nil then
    dwObjSize := GetObjectDataSize;
  if @lpszLabel <> nil then
    lpszLabel := CoAllocCStr(GetFullNameStr(FOleObject));
  if @lpszType <> nil then
    lpszType := CoAllocCStr(GetFullNameStr(FOleObject));
  if @lpszShortType <> nil then
    lpszShortType := CoAllocCStr(GetShortNameStr(FOleObject));
  if @lpszLocation <> nil then
    lpszLocation := CoAllocCStr('Caption');     {TODO:???}
  Result := S_OK;
end;

function TOleContainer.GetConvertInfo(dwObject: Longint; var ClassID: TCLSID;
  var wFormat: Word; var ConvertDefaultClassID: TCLSID;
  var lpClsidExclude: PCLSID; var cClsidExclude: Longint): HResult;
begin
  FOleObject.GetUserClassID(ClassID);
  Result := S_OK;
end;

function TOleContainer.ConvertObject(dwObject: Longint;
  const clsidNew: TCLSID): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleContainer.GetViewInfo(dwObject: Longint; var hMetaPict: HGlobal;
  var dvAspect: Longint; var nCurrentScale: Integer): HResult;
begin
  if @hMetaPict <> nil then hMetaPict := GetIconMetaPict;
  if @dvAspect <> nil then dvAspect := FDrawAspect;
  if @nCurrentScale <> nil then nCurrentScale := 0;
  Result := S_OK;
end;

function TOleContainer.SetViewInfo(dwObject: Longint; hMetaPict: HGlobal;
  dvAspect: Longint; nCurrentScale: Integer;
  bRelativeToOrig: BOOL): HResult;
var
  ShowAsIcon: Boolean;
begin
  case dvAspect of
    DVASPECT_CONTENT: ShowAsIcon := False;
    DVASPECT_ICON: ShowAsIcon := True;
  else
    ShowAsIcon := Iconic;
  end;
  SetDrawAspect(ShowAsIcon, hMetaPict);
  Result := S_OK;
end;

{ TOleContainer.IOleClientSite }

function TOleContainer.GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
  out mk: IMoniker): HResult;
begin
  mk := nil;
  Result := E_NOTIMPL;
end;

function TOleContainer.GetContainer(out container: IOleContainer): HResult;
begin
  container := nil;
  Result := E_NOINTERFACE;
end;

function TOleContainer.ShowObject: HResult;
begin
  Result := S_OK;
end;

function TOleContainer.OnShowWindow(fShow: BOOL): HResult;
begin
  if FObjectOpen <> Boolean(fShow) then
  begin
    FObjectOpen := fShow;
//    Invalidate;
  end;
  Result := S_OK;
end;

function TOleContainer.RequestNewObjectLayout: HResult;
begin
  Result := E_NOTIMPL;
end;

{ TOleContainer.IOleInPlaceSite }

function TOleContainer.GetWindow(out wnd: HWnd): HResult;
begin
  if FDocObj then
    wnd := Handle
  else
    wnd := Parent.Handle;
  Result := S_OK;
end;

function TOleContainer.ContextSensitiveHelp(fEnterMode: BOOL): HResult;
begin
  Result := S_OK;
end;

function TOleContainer.CanInPlaceActivate: HResult;
begin
{  Result := S_FALSE;
  if not (csDesigning in ComponentState) and Visible and
    AllowInPlace and not Iconic then}
    Result := S_OK;
end;

function TOleContainer.OnInPlaceActivate: HResult;
begin
  FOleObject.QueryInterface(IOleInPlaceObject, FOleInPlaceObject);
  FOleObject.QueryInterface(IOleInPlaceActiveObject, FOleInPlaceActiveObject);
  Result := S_OK;
end;

function TOleContainer.OnUIActivate: HResult;
begin
  SetUIActive(True);
  Result := S_OK;
end;

function TOleContainer.GetWindowContext(out frame: IOleInPlaceFrame;
  out doc: IOleInPlaceUIWindow; out rcPosRect: TRect;
  out rcClipRect: TRect; out frameInfo: TOleInPlaceFrameInfo): HResult;
var
  Origin: TPoint;
begin
  frame := FFrameForm;
  doc := nil;
  if FDocObj then
  begin
    rcPosRect := Rect(0,0,Width,Height);
    rcClipRect := rcPosRect;
  end
  else
  begin
    Origin := Parent.ScreenToClient(ClientOrigin);  {TODO:Нечем}
    SetRect(rcPosRect, Origin.X, Origin.Y,
      Origin.X + Width, Origin.Y + Height);
      SetRect(rcClipRect, -16384, -16384, 16383, 16383);
  end;
  CreateAccelTable;
  with frameInfo do
  begin
    fMDIApp := False;
    FFrameForm.GetWindow(hWndFrame);
    hAccel := FAccelTable;
    cAccelEntries := FAccelCount;
  end;
  Result := S_OK;
end;

function TOleContainer.Scroll(scrollExtent: TPoint): HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleContainer.OnUIDeactivate(fUndoable: BOOL): HResult;
begin
  FFrameForm.SetMenu(0, 0, 0);
  FFrameForm.ClearBorderSpace;
  SetUIActive(False);
  Result := S_OK;
end;

function TOleContainer.OnInPlaceDeactivate: HResult;
begin
  FOleInPlaceActiveObject := nil;
  FOleInPlaceObject := nil;
  Result := S_OK;
end;

function TOleContainer.DiscardUndoState: HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleContainer.DeactivateAndUndo: HResult;
begin
  FOleInPlaceObject.UIDeactivate;
  Result := S_OK;
end;

function TOleContainer.OnPosRectChange(const rcPosRect: TRect): HResult;
begin
  try
    ObjectMoved(rcPosRect);
    UpdateObjectRect;
  except
    MessageBox(MainWindow.Handle,'Error',nil,$10);
    Halt
//    Application.HandleException(Self);
  end;
  Result := S_OK;
end;

{ TOleContainer.IAdviseSink }

procedure TOleContainer.OnDataChange(const formatetc: TFormatEtc;
  const stgmed: TStgMedium);
begin
  Changed;
end;

procedure TOleContainer.OnViewChange(dwAspect: Longint; lindex: Longint);
begin
  if dwAspect = FDrawAspect then UpdateView;
end;

procedure TOleContainer.OnRename(const mk: IMoniker);
begin
end;

procedure TOleContainer.OnSave;
begin
end;

procedure TOleContainer.OnClose;
begin
end;

{ TOleContainer.IOleDocumentSite }

function TOleContainer.ActivateMe(View: IOleDocumentView): HRESULT;
var
  Doc: IOleDocument;
begin
  Result := E_FAIL;
  if View = nil then
  begin   // If we're given a nil view, try to get one from the document object.
    if FOleObject.QueryInterface(IOleDocument, Doc) <> 0 then Exit;
    if Doc = nil then Exit;
    Result := Doc.CreateView(Self, nil, 0, View);
    if Result <> 0 then Exit;
  end
  else
    View.SetInPlaceSite(Self);

  FDocObj := True;
  FDocView := View;
  View.UIActivate(TRUE);    //Set up toolbars and menus first
  UpdateObjectRect;         //Then set window size, after toolbars
  View.Show(TRUE);
  Result := NOERROR;
end;

{ TOleContainer }

constructor TOleContainer.Create(Aparent:TWin);
begin
  inherited Create(WS_CLIPCHILDREN or WS_CHILD ,
            0,20,20,50,30,AParent,'Name','ClassName');
  FRefCount := 1;
  Width := 40;
  Height := 20;
  FAllowInPlace := True;
  FAllowActiveDoc := True;
  FAutoActivate := aaDoubleClick;
  FAutoVerbMenu := True;
  FBorderStyle := bsSingle;
  FCopyOnSave := True;
  FDrawAspect := DVASPECT_CONTENT;
  Show(SW_HIDE);
end;

destructor TOleContainer.Destroy;
begin
  DestroyObject;
  inherited Destroy;
end;

function TOleContainer._AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

procedure TOleContainer.AdjustBounds;
var
  Size: TPoint;
  Extra: Integer;
begin
  if (FSizeMode = smAutoSize) and (FOleObject <> nil) then
  begin
    Size := HimetricToPixels(FViewSize);
    Extra := GetBorderWidth * 2;
    SetBounds(Left, Top, Size.X + Extra, Size.Y + Extra);
  end;             {TODO: Убрал полностью}
end;

function TOleContainer.ChangeIconDialog: Boolean;
var
  Data: TOleUIChangeIcon;
begin
  CheckObject;
  Result := False;
  FillChar(Data, SizeOf(Data), 0);
  Data.cbStruct := SizeOf(Data);
  Data.dwFlags := CIF_SELECTCURRENT;
  Data.hWndOwner := MainWindow.Handle;
  Data.lpfnHook := OleDialogHook;
  OleCheck(FOleObject.GetUserClassID(Data.clsid));
  Data.hMetaPict := GetIconMetaPict;
  try
    if OleUIChangeIcon(Data) = OLEUI_OK then
    begin
      SetDrawAspect(True, Data.hMetaPict);
      Result := True;
    end;
  finally
    DestroyMetaPict(Data.hMetaPict);
  end;
end;

procedure TOleContainer.CheckObject;
begin
  if FOleObject = nil then
    raise EOleError.CreateRes(@SEmptyContainer);
end;

procedure TOleContainer.Close;
begin
  CheckObject;
  OleCheck(FOleObject.Close(OLECLOSE_SAVEIFDIRTY));
end;

procedure TOleContainer.Copy;
begin
  Close;
  OleCheck(OleSetClipboard(TDataObject.Create(FOleObject) as IDataObject));
end;

procedure TOleContainer.CreateAccelTable;
{var
  Menu: TMainMenu;}
begin              {
  if FAccelTable = 0 then
  begin
    Menu := FFrameForm.Form.Menu;
    if Menu <> nil then
      Menu.GetOle2AcceleratorTable(FAccelTable, FAccelCount, [0, 2, 4]);
  end;}                                    {TODO: Убрал полностью}
end;

procedure TOleContainer.CreateLinkToFile(const FileName: string;
  Iconic: Boolean);
var
  CreateInfo: TCreateInfo;
begin
  CreateInfo.CreateType := ctLinkToFile;
  CreateInfo.ShowAsIcon := Iconic;
  CreateInfo.IconMetaPict := 0;
  CreateInfo.FileName := FileName;
  CreateObjectFromInfo(CreateInfo);
end;

procedure TOleContainer.CreateObject(const OleClassName: string;
  Iconic: Boolean);
var
  CreateInfo: TCreateInfo;
begin
  CreateInfo.CreateType := ctNewObject;
  CreateInfo.ShowAsIcon := Iconic;
  CreateInfo.IconMetaPict := 0;
  CreateInfo.ClassID := ProgIDToClassID(OleClassName);
  CreateObjectFromInfo(CreateInfo);
end;

procedure TOleContainer.CreateObjectFromFile(const FileName: string;
  Iconic: Boolean);
var
  CreateInfo: TCreateInfo;
begin
  CreateInfo.CreateType := ctFromFile;
  CreateInfo.ShowAsIcon := Iconic;
  CreateInfo.IconMetaPict := 0;
  CreateInfo.FileName := FileName;
  CreateObjectFromInfo(CreateInfo);
end;

procedure TOleContainer.CreateObjectFromInfo(const CreateInfo: TCreateInfo);
begin
  DestroyObject;
  try
    CreateStorage;
    with CreateInfo do
    begin
      case CreateType of
        ctNewObject:
          OleCheck(OleCreate(ClassID, IOleObject, OLERENDER_DRAW, nil,
            Self, FStorage, FOleObject));
        ctFromFile:
          OleCheck(OleCreateFromFile(GUID_NULL, PWideChar(FileName), IOleObject,
            OLERENDER_DRAW, nil, Self, FStorage, FOleObject));
        ctLinkToFile:
          OleCheck(OleCreateLinkToFile(PWideChar(FileName), IOleObject,
            OLERENDER_DRAW, nil, Self, FStorage, FOleObject));
        ctFromData:
          OleCheck(OleCreateFromData(DataObject, IOleObject,
            OLERENDER_DRAW, nil, Self, FStorage, FOleObject));
        ctLinkFromData:
          OleCheck(OleCreateLinkFromData(DataObject, IOleObject,
            OLERENDER_DRAW, nil, Self, FStorage, FOleObject));
      end;
      FDrawAspect := DVASPECT_CONTENT;
      InitObject;
{      FOleObject.SetExtent(DVASPECT_CONTENT, PixelsToHimetric(
        Point(Width, Height)));}
      SetDrawAspect(ShowAsIcon, IconMetaPict);
      UpdateView;
    end;
  except
    DestroyObject;
    raise;
  end;
end;

{procedure TOleContainer.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or WS_CLIPCHILDREN;
    WindowClass.Style := WindowClass.Style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;
 }
procedure TOleContainer.CreateStorage;
begin
  OleCheck(CreateILockBytesOnHGlobal(0, True, FLockBytes));
  OleCheck(StgCreateDocfileOnILockBytes(FLockBytes, STGM_READWRITE
    or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, FStorage));
end;

{procedure TOleContainer.DblClick;
begin
  if FAutoActivate = aaDoubleClick then
    DoVerb(ovPrimary)
  else
    inherited;
end;

procedure TOleContainer.DefineProperties(Filer: TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Data', LoadFromStream, SaveToStream,
    FOleObject <> nil);
end;

procedure TOleContainer.DesignModified;
var
  Form: TCustomForm;
begin
  Form := GetParentForm(Self);
  if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
end;

procedure TOleContainer.DestroyAccelTable;
begin
  if FAccelTable <> 0 then
  begin
    DestroyAcceleratorTable(FAccelTable);
    FAccelTable := 0;
    FAccelCount := 0;
  end;
end;
 }
procedure TOleContainer.DestroyObject;
var
  DataObject: IDataObject;
begin
  if FOleObject <> nil then
  begin
    SetViewAdviseSink(False);
    if FDataConnection <> 0 then
    begin
      FOleObject.QueryInterface(IDataObject, DataObject);
      if DataObject <> nil then
      begin
        DataObject.DUnadvise(FDataConnection);
        DataObject := nil;
      end;
      FDataConnection := 0;
    end;
    FOleObject.Close(OLECLOSE_NOSAVE);
//    Invalidate;                     {TODO:Нечем}
    Changed;
  end;
  FDocView := nil;
  FOleObject := nil;
  FStorage := nil;
  FLockBytes := nil;
  DestroyVerbs;
//  DestroyAccelTable;
end;

procedure TOleContainer.DestroyVerbs;
begin
{  FPopupVerbMenu.Free;
  FPopupVerbMenu := nil;
 } FObjectVerbs.Free;
  FObjectVerbs := nil;
end;

{procedure TOleContainer.DoEnter;
begin
  if FAutoActivate = aaGetFocus then DoVerb(ovShow);
  inherited;
end;
 }
procedure TOleContainer.DoVerb(Verb: Integer);
var
  H: THandle;
  R: TRect;
begin
  CheckObject;
  if Verb > 0 then
  begin
    if FObjectVerbs = nil then UpdateVerbs;
    if Verb >= FObjectVerbs.Count then
      raise EOleError.CreateRes(@SInvalidVerb);
    Verb := Smallint(Integer(FObjectVerbs.Objects[Verb]) and $0000FFFF);
  end else
    if Verb = ovPrimary then Verb := 0;
  if FDocObj then
  begin
    GetWindowRect(Handle,R);
    H := Handle;
  end
  else
  begin
    R := BoundsRect;
    H := Parent.Handle;
  end;
  OleCheck(FOleObject.DoVerb(Verb, nil, Self, 0, H, R));
end;

function TOleContainer.GetBorderWidth: Integer;
begin
  Result := 1;
end;

function TOleContainer.GetCanPaste: Boolean;
var
  DataObject: IDataObject;
begin
  Result := Succeeded(OleGetClipboard(DataObject)) and
    ((OleQueryCreateFromData(DataObject) = 0) or
     (OleQueryLinkFromData(DataObject) = 0));
end;

function TOleContainer.GetIconic: Boolean;
begin
  Result := FDrawAspect = DVASPECT_ICON;
end;

function TOleContainer.GetIconMetaPict: HGlobal;
var
  DataObject: IDataObject;
  FormatEtc: TFormatEtc;
  Medium: TStgMedium;
  ClassID: TCLSID;
begin
  CheckObject;
  Result := 0;
  if FDrawAspect = DVASPECT_ICON then
  begin
    FOleObject.QueryInterface(IDataObject, DataObject);
    if DataObject <> nil then
    begin
      FormatEtc.cfFormat := CF_METAFILEPICT;
      FormatEtc.ptd := nil;
      FormatEtc.dwAspect := DVASPECT_ICON;
      FormatEtc.lIndex := -1;
      FormatEtc.tymed := TYMED_MFPICT;
      if Succeeded(DataObject.GetData(FormatEtc, Medium)) then
        Result := Medium.hMetaFilePict;
    end;
  end;
  if Result = 0 then
  begin
    OleCheck(FOleObject.GetUserClassID(ClassID));
    Result := OleGetIconOfClass(ClassID, nil, True);
  end;
end;

function TOleContainer.GetLinked: Boolean;
var
  OleLink: IOleLink;
begin
  CheckObject;
  FOleObject.QueryInterface(IOleLink, OleLink);
  Result := (OleLink <> nil);
end;

function TOleContainer.GetObjectDataSize: Integer;
var
  DataHandle: HGlobal;
begin
  if Succeeded(GetHGlobalFromILockBytes(FLockBytes, DataHandle)) then
    Result := GlobalSize(DataHandle) else
    Result := 0;
end;

function TOleContainer.GetObjectVerbs: TStrings;
begin
  if FObjectVerbs = nil then UpdateVerbs;
  Result := FObjectVerbs;
end;

function TOleContainer.GetOleClassName: string;
var
  ClassID: TCLSID;
begin
  CheckObject;
  OleCheck(FOleObject.GetUserClassID(ClassID));
  Result := ClassIDToProgID(ClassID);
end;

function TOleContainer.GetOleObject: Variant;
begin
  CheckObject;
  Result := Variant(FOleObject as IDispatch);
end;

{function TOleContainer.GetPopupMenu: TPopupMenu;
var
  I: Integer;
  Item: TMenuItem;
begin
  if FAutoVerbMenu and (FOleObject <> nil) and (ObjectVerbs.Count > 0) then
  begin
    if FPopupVerbMenu = nil then
    begin
      FPopupVerbMenu := TPopupMenu.Create(Self);
      for I := 0 to ObjectVerbs.Count - 1 do
      begin
        Item := TMenuItem.Create(Self);
        Item.Caption := ObjectVerbs[I];
        Item.Tag := I;
        Item.OnClick := PopupVerbMenuClick;
        FPopupVerbMenu.Items.Add(Item);
      end;
    end;
    Result := FPopupVerbMenu;
  end else
    Result := inherited GetPopupMenu;
end;
 }
function TOleContainer.GetPrimaryVerb: Integer;
begin
  if FObjectVerbs = nil then UpdateVerbs;
  for Result := 0 to FObjectVerbs.Count - 1 do
    if Integer(FObjectVerbs.Objects[Result]) and $0000FFFF = 0 then Exit;
  Result := 0;
end;

function TOleContainer.GetSourceDoc: string;
var
  OleLink: IOleLink;
begin
  CheckObject;
  Result := '';
  FOleObject.QueryInterface(IOleLink, OleLink);
  if OleLink <> nil then
    Result := GetDisplayNameStr(OleLink);
end;

function TOleContainer.GetState: TObjectState;
begin
  if FOleObject = nil then
    Result := osEmpty
  else if FObjectOpen then
    Result := osOpen
  else if FUIActive then
    Result := osUIActive
  else if OleIsRunning(FOleObject) then
    Result := osRunning
  else
    Result := osLoaded;
end;

procedure TOleContainer.InitObject;
var
  DataObject: IDataObject;
  FormatEtc: TFormatEtc;
begin
{  FDocForm := GetAWLFrameWindow(Parent);
  FFrameForm := FDocForm;
  FDocForm.AddContainer(Self);
  if IsFormMDIChild(FDocForm.Form) then
  begin
    FFrameForm := GetVCLFrameForm(Application.MainForm);
    FFrameForm.AddContainer(Self);
  end;}
  SetViewAdviseSink(True);
  FOleObject.SetHostNames(PWideChar(WideString('Turbo Test 6.0')),
    PWideChar(WideString('Test')));
  OleSetContainedObject(FOleObject, True);
  FOleObject.QueryInterface(IDataObject, DataObject);
  if DataObject <> nil then
  begin
    FormatEtc.cfFormat := 0;
    FormatEtc.ptd := nil;
    FormatEtc.dwAspect := -1;
    FormatEtc.lIndex := -1;
    FormatEtc.tymed := -1;
    DataObject.DAdvise(FormatEtc, ADVF_NODATA, Self, FDataConnection);
  end;
end;

function TOleContainer.InsertObjectDialog: Boolean;
var
  Data: TOleUIInsertObject;
  NameBuffer: array[0..255] of Char;
  CreateInfo: TCreateInfo;
begin
  Result := False;
  FNewInserted := False;
  FillChar(Data, SizeOf(Data), 0);
  FillChar(NameBuffer, SizeOf(NameBuffer), 0);
  Data.cbStruct := SizeOf(Data);
  Data.dwFlags := IOF_SELECTCREATENEW;
  Data.hWndOwner := MainWIndow.Handle;
  Data.lpfnHook := OleDialogHook;
  Data.lpszFile := NameBuffer;
  Data.cchFile := SizeOf(NameBuffer);
  try
    if OleUIInsertObject(Data) = OLEUI_OK then
    begin
      if Data.dwFlags and IOF_SELECTCREATENEW <> 0 then
      begin
        CreateInfo.CreateType := ctNewObject;
        CreateInfo.ClassID := Data.clsid;
      end else
      begin
        if Data.dwFlags and IOF_CHECKLINK = 0 then
          CreateInfo.CreateType := ctFromFile else
          CreateInfo.CreateType := ctLinkToFile;
        CreateInfo.FileName := NameBuffer;
      end;
      CreateInfo.ShowAsIcon := Data.dwFlags and IOF_CHECKDISPLAYASICON <> 0;
      CreateInfo.IconMetaPict := Data.hMetaPict;
      CreateObjectFromInfo(CreateInfo);
      if CreateInfo.CreateType = ctNewObject then FNewInserted := True;
      Result := True;
    end;
  finally
    DestroyMetaPict(Data.hMetaPict);
  end;
end;

{procedure TOleContainer.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (FAutoActivate <> aaManual) and (Key = VK_RETURN) then
  begin
    if ssCtrl in Shift then DoVerb(ovShow) else DoVerb(ovPrimary);
    Key := 0;
  end;
end;
}
procedure TOleContainer.LoadFromFile(const FileName: string);
var
  Stream: TFile;
begin
  Stream := TFile.Create(FileName, fmOpenRead);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TOleContainer.LoadFromStream(Stream: TFile);
var
  DataHandle: HGlobal;
  Buffer: Pointer;
  Header: TStreamHeader;
begin
  DestroyObject;
  Stream.Read(Header, SizeOf(Header));
  if (Header.Signature <> StreamSignature) and not FOldStreamFormat then
    raise EOleError.CreateRes(@SInvalidStreamFormat);
  DataHandle := GlobalAlloc(GMEM_MOVEABLE, Header.DataSize);
  if DataHandle = 0 then OutOfMemoryError;
  try
    Buffer := GlobalLock(DataHandle);
    try
      Stream.Read(Buffer^, Header.DataSize);
    finally
      GlobalUnlock(DataHandle);
    end;
    OleCheck(CreateILockBytesOnHGlobal(DataHandle, True, FLockBytes));
    DataHandle := 0;
    OleCheck(StgOpenStorageOnILockBytes(FLockBytes, nil, STGM_READWRITE or
      STGM_SHARE_EXCLUSIVE, nil, 0, FStorage));
    OleCheck(OleLoad(FStorage, IOleObject, Self, FOleObject));
    FDrawAspect := Header.DrawAspect;
    InitObject;
    UpdateView;
  except
    if DataHandle <> 0 then GlobalFree(DataHandle);
    DestroyObject;
    raise;
  end;
end;

{procedure TOleContainer.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then SetFocus;
  inherited MouseDown(Button, Shift, X, Y);
end;
 }
procedure TOleContainer.Changed;
begin
{  if not (csReading in ComponentState) then
  begin
    FModified := True;
    FModSinceSave := True;
    DesignModified;
  end;}
end;

procedure TOleContainer.ObjectMoved(const ObjectRect: TRect);
var
  R: TRect;
  I: Integer;
begin
  if Assigned(FOnObjectMove) then
  begin
    R := ObjectRect;
    I := GetBorderWidth;
    InflateRect(R, I, I);
    FOnObjectMove(Self, R);
  end;
end;

procedure TOleContainer.Paste;
var
  DataObject: IDataObject;
  Descriptor: PObjectDescriptor;
  FormatEtc: TFormatEtc;
  Medium: TStgMedium;
  CreateInfo: TCreateInfo;
begin
  if not CanPaste then Exit;
  OleCheck(OleGetClipboard(DataObject));
  try
    CreateInfo.CreateType := ctFromData;
    CreateInfo.ShowAsIcon := False;
    CreateInfo.IconMetaPict := 0;
    CreateInfo.DataObject := DataObject;
    FormatEtc.cfFormat := CFObjectDescriptor;
    FormatEtc.ptd := nil;
    FormatEtc.dwAspect := DVASPECT_CONTENT;
    FormatEtc.lIndex := -1;
    FormatEtc.tymed := TYMED_HGLOBAL;
    if Succeeded(DataObject.GetData(FormatEtc, Medium)) then
    begin
      Descriptor := GlobalLock(Medium.hGlobal);
      if Descriptor^.dwDrawAspect = DVASPECT_ICON then
        CreateInfo.ShowAsIcon := True;
      GlobalUnlock(Medium.hGlobal);
      ReleaseStgMedium(Medium);
    end;
    if CreateInfo.ShowAsIcon then
    begin
      FormatEtc.cfFormat := CF_METAFILEPICT;
      FormatEtc.ptd := nil;
      FormatEtc.dwAspect := DVASPECT_ICON;
      FormatEtc.lIndex := -1;
      FormatEtc.tymed := TYMED_MFPICT;
      if Succeeded(DataObject.GetData(FormatEtc, Medium)) then
        CreateInfo.IconMetaPict := Medium.hMetaFilePict;
    end;
    CreateObjectFromInfo(CreateInfo);
  finally
    DestroyMetaPict(CreateInfo.IconMetaPict);
  end;
end;

function TOleContainer.PasteSpecialDialog: Boolean;
const
  PasteFormatCount = 2;
var
  Data: TOleUIPasteSpecial;
  PasteFormats: array[0..PasteFormatCount - 1] of TOleUIPasteEntry;
  CreateInfo: TCreateInfo;
begin
  Result := False;
  if not CanPaste then Exit;
  FillChar(Data, SizeOf(Data), 0);
  FillChar(PasteFormats, SizeOf(PasteFormats), 0);
  Data.cbStruct := SizeOf(Data);
  Data.hWndOwner := MainWindow.Handle;
  Data.lpfnHook := OleDialogHook;
  Data.arrPasteEntries := @PasteFormats;
  Data.cPasteEntries := PasteFormatCount;
  Data.arrLinkTypes := @CFLinkSource;
  Data.cLinkTypes := 1;
  PasteFormats[0].fmtetc.cfFormat := CFEmbeddedObject;
  PasteFormats[0].fmtetc.dwAspect := DVASPECT_CONTENT;
  PasteFormats[0].fmtetc.lIndex := -1;
  PasteFormats[0].fmtetc.tymed := TYMED_ISTORAGE;
  PasteFormats[0].lpstrFormatName := '%s';
  PasteFormats[0].lpstrResultText := '%s';
  PasteFormats[0].dwFlags := OLEUIPASTE_PASTE or OLEUIPASTE_ENABLEICON;
  PasteFormats[1].fmtetc.cfFormat := CFLinkSource;
  PasteFormats[1].fmtetc.dwAspect := DVASPECT_CONTENT;
  PasteFormats[1].fmtetc.lIndex := -1;
  PasteFormats[1].fmtetc.tymed := TYMED_ISTREAM;
  PasteFormats[1].lpstrFormatName := '%s';
  PasteFormats[1].lpstrResultText := '%s';
  PasteFormats[1].dwFlags := OLEUIPASTE_LINKTYPE1 or OLEUIPASTE_ENABLEICON;
  try
    if OleUIPasteSpecial(Data) = OLEUI_OK then
    begin
      if Data.fLink then
        CreateInfo.CreateType := ctLinkFromData else
        CreateInfo.CreateType := ctFromData;
      CreateInfo.ShowAsIcon := Data.dwFlags and PSF_CHECKDISPLAYASICON <> 0;
      CreateInfo.IconMetaPict := Data.hMetaPict;
      CreateInfo.DataObject := Data.lpSrcDataObj;
      CreateObjectFromInfo(CreateInfo);
      Result := True;
    end;
  finally
    DestroyMetaPict(Data.hMetaPict);
  end;
end;

procedure TOleContainer.PopupVerbMenuClick(Sender: TObject);
begin
//  DoVerb((Sender as TMenuItem).Tag);
end;

function TOleContainer.QueryInterface(const iid: TIID; out obj): HResult;
begin
  Pointer(obj) := nil;
  Result := E_NOINTERFACE;
  if IsEqualIID(iid, IOleDocumentSite) and
    (not FAllowActiveDoc ) then Exit;
  if GetInterface(iid, obj) then Result := S_OK;
end;

function TOleContainer._Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
end;

procedure TOleContainer.Run;
begin
  CheckObject;
  OleCheck(OleRun(FOleObject));
end;

function TOleContainer.SaveObject: HResult;
var
  PersistStorage: IPersistStorage;
begin
  Result := S_OK;
  if FOleObject = nil then Exit;
  PersistStorage := FOleObject as IPersistStorage;
  OleCheck(OleSave(PersistStorage, FStorage, True));
  PersistStorage.SaveCompleted(nil);
  PersistStorage := nil;
  OleCheck(FStorage.Commit(STGC_DEFAULT));
  FModSinceSave := False;
end;

procedure TOleContainer.SaveAsDocument(const FileName: string);
var
  TempStorage: IStorage;
  PersistStorage: IPersistStorage;
begin
  CheckObject;
  if FModSinceSave then SaveObject;
  FOleObject.QueryInterface(IPersistStorage, PersistStorage);
  if PersistStorage <> nil then
  begin
    OleCheck(StgCreateDocFile(PWideChar(WideString(Filename)), STGM_READWRITE
      or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, TempStorage));
    OleCheck(OleSave(PersistStorage, TempStorage, False));
    PersistStorage.SaveCompleted(nil);
  end;
end;

function TOleContainer.SaveToFile(const FileName: string):HResult;
var
  Stream: TFile;
begin
  Stream := TFile.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TOleContainer.SaveToStream(Stream: TFile);
var
  TempLockBytes: ILockBytes;
  TempStorage: IStorage;
  DataHandle: HGlobal;
  Buffer: Pointer;
  Header: TStreamHeader;
  R: TRect;
begin
  CheckObject;
  if FModSinceSave then SaveObject;
  if FCopyOnSave then
  begin
    OleCheck(CreateILockBytesOnHGlobal(0, True, TempLockBytes));
    OleCheck(StgCreateDocfileOnILockBytes(TempLockBytes, STGM_READWRITE
      or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, TempStorage));
    OleCheck(FStorage.CopyTo(0, nil, nil, TempStorage));
    OleCheck(TempStorage.Commit(STGC_DEFAULT));
    OleCheck(GetHGlobalFromILockBytes(TempLockBytes, DataHandle));
  end else
    OleCheck(GetHGlobalFromILockBytes(FLockBytes, DataHandle));
  if FOldStreamFormat then
  begin
    R := BoundsRect;
    Header.PartRect.Left := R.Left;
    Header.PartRect.Top := R.Top;
    Header.PartRect.Right := R.Right;
    Header.PartRect.Bottom := R.Bottom;
  end else
  begin
    Header.Signature := StreamSignature;
    Header.DrawAspect := FDrawAspect;
  end;
  Header.DataSize := GlobalSize(DataHandle);
  Stream.Write(Header, SizeOf(Header));
  Buffer := GlobalLock(DataHandle);
  try
    Stream.Write(Buffer^, Header.DataSize);
  finally
    GlobalUnlock(DataHandle);
  end;
end;

procedure TOleContainer.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    AdjustBounds;
//    Invalidate;
  end;
end;

procedure TOleContainer.SetDrawAspect(Iconic: Boolean;
  IconMetaPict: HGlobal);
var
  OleCache: IOleCache;
  EnumStatData: IEnumStatData;
  OldAspect, AdviseFlags, Connection: Longint;
  TempMetaPict: HGlobal;
  FormatEtc: TFormatEtc;
  Medium: TStgMedium;
  ClassID: TCLSID;
  StatData: TStatData;
begin
  OldAspect := FDrawAspect;
  if Iconic then
  begin
    FDrawAspect := DVASPECT_ICON;
    AdviseFlags := ADVF_NODATA;
  end else
  begin
    FDrawAspect := DVASPECT_CONTENT;
    AdviseFlags := ADVF_PRIMEFIRST;
  end;
  if (FDrawAspect <> OldAspect) or (FDrawAspect = DVASPECT_ICON) then
  begin
    OleCache := FOleObject as IOleCache;
    if FDrawAspect <> OldAspect then
    begin
      OleCheck(OleCache.EnumCache(EnumStatData));
      if EnumStatData <> nil then
        while EnumStatData.Next(1, StatData, nil) = 0 do
          if StatData.formatetc.dwAspect = OldAspect then
            OleCache.Uncache(StatData.dwConnection);
      FillChar(FormatEtc, SizeOf(FormatEtc), 0);
      FormatEtc.dwAspect := FDrawAspect;
      FormatEtc.lIndex := -1;
      OleCheck(OleCache.Cache(FormatEtc, AdviseFlags, Connection));
      SetViewAdviseSink(True);
    end;
    if FDrawAspect = DVASPECT_ICON then
    begin
      TempMetaPict := 0;
      if IconMetaPict = 0 then
      begin
        OleCheck(FOleObject.GetUserClassID(ClassID));
        TempMetaPict := OleGetIconOfClass(ClassID, nil, True);
        IconMetaPict := TempMetaPict;
      end;
      try
        FormatEtc.cfFormat := CF_METAFILEPICT;
        FormatEtc.ptd := nil;
        FormatEtc.dwAspect := DVASPECT_ICON;
        FormatEtc.lIndex := -1;
        FormatEtc.tymed := TYMED_MFPICT;
        Medium.tymed := TYMED_MFPICT;
        Medium.hMetaFilePict := IconMetaPict;
        Medium.unkForRelease := nil;
        OleCheck(OleCache.SetData(FormatEtc, Medium, False));
      finally
        DestroyMetaPict(TempMetaPict);
      end;
    end;
    if FDrawAspect = DVASPECT_CONTENT then UpdateObject;
    UpdateView;
  end;
end;

procedure TOleContainer.SetFocused(Value: Boolean);
var
  R: TRect;
  DC:HDC;
begin
  if FFocused <> Value then
  begin
    DC:=GetDC(Handle);
    FFocused := Value;
    if GetUpdateRect(Handle, PRect(nil)^, False) then
    else
    begin
      R := ClientRect;
      InflateRect(R, -GetBorderWidth, -GetBorderWidth);
      DrawFocusRect(DC,R);
    end;
    ReleaseDC(Handle,DC);
  end;
end;

procedure TOleContainer.SetIconic(Value: Boolean);
begin
  if GetIconic <> Value then
  begin
    CheckObject;
    SetDrawAspect(Value, 0);
  end;
end;

procedure TOleContainer.SetSizeMode(Value: TSizeMode);
begin
  if FSizeMode <> Value then
  begin
    FSizeMode := Value;
    AdjustBounds;
  end;
end;

procedure TOleContainer.SetUIActive(Active: Boolean);
var
  Form: TWin;
begin
  try
    FUIActive := Active;
    Form := Parent;
    if Form <> nil then
      if Active then
      begin
{       if (Form.ActiveOleControl <> nil) and
          (Form.ActiveOleControl <> Self) then
          Form.ActiveOleControl.Perform(CM_UIDEACTIVATE, 0, 0);
        Form.ActiveOleControl := Self;}
        SetFocus;
      end else
      begin
{       if Form.ActiveOleControl = Self then Form.ActiveOleControl := nil;
        if Form.ActiveControl = Self then Windows.SetFocus(Handle);
        DestroyAccelTable;
        if Assigned(FOnDeactivate) then FOnDeactivate(Self);}
      end;
  except
    raise
  end;     {TODO:Не реализовано полностью}
end;

procedure TOleContainer.SetViewAdviseSink(Enable: Boolean);
var
  ViewObject: IViewObject;
  AdviseSink: IAdviseSink;
begin
  if FOleObject.QueryInterface(IViewObject, ViewObject) <> 0 then Exit;
  if Enable then AdviseSink := Self else AdviseSink := nil;
  ViewObject.SetAdvise(FDrawAspect, 0, AdviseSink);
end;

procedure TOleContainer.UpdateObject;
begin
  if FOleObject <> nil then
  begin
    OleCheck(FOleObject.Update);
    Changed;
  end;
end;

procedure TOleContainer.UpdateObjectRect;
var
  P: TPoint;
  R: TRect;
begin
  if FDocObj and (FDocView <> nil) then
  begin
    GetWindowRect(Handle,R);
    FDocView.SetRect(R)
  end
  else
  begin
    P := Parent.ScreenToClient(ClientOrigin);
    R := Rect(P.X, P.Y, P.X + Width, P.Y + Height);
    if FOleInPlaceObject <> nil then
      FOleInPlaceObject.SetObjectRects(R, Rect(-16384, -16384, 16383, 16383));
  end;
end;

procedure TOleContainer.UpdateVerbs;
var
  EnumOleVerb: IEnumOleVerb;
  OleVerb: TOleVerb;
  VerbInfo: TVerbInfo;
begin
  CheckObject;
  DestroyVerbs;
  FObjectVerbs := TStringList.Create;
  if FOleObject.EnumVerbs(EnumOleVerb) = 0 then
  begin
    while (EnumOleVerb.Next(1, OleVerb, nil) = 0) and
      (OleVerb.lVerb >= 0) and
      (OleVerb.grfAttribs and OLEVERBATTRIB_ONCONTAINERMENU <> 0) do
    begin
      VerbInfo.Verb := OleVerb.lVerb;
      VerbInfo.Flags := OleVerb.fuFlags;
      FObjectVerbs.AddObject(OleVerb.lpszVerbName, TObject(VerbInfo));
    end;
  end;
end;

procedure TOleContainer.UpdateView;
var
  ViewObject2: IViewObject2;R:TRect;
begin
  exit;
  if Succeeded(FOleObject.QueryInterface(IViewObject2, ViewObject2)) then
  begin
    ViewObject2.GetExtent(FDrawAspect, -1, nil, FViewSize);
    AdjustBounds;
  end;
  //  Invalidate;
  Changed;
end;

{ TOleForm.IOleInPlaceFrame }

function TOleWin.GetWindow(out wnd: HWnd): HResult;
begin
  wnd := FForm.Handle;
  Result := S_OK;
end;

function TOleWin.ContextSensitiveHelp(fEnterMode: BOOL): HResult;
begin
  Result := S_OK;
end;

function TOleWin.GetBorder(out BorderRect: TRect): HResult;
begin
  Result := S_OK;
  BorderRect := FForm.ClientRect;
end;

function TOleWin.RequestBorderSpace(const borderwidths: TRect): HResult;
begin
  Result := S_OK;
end;

function TOleWin.SetBorderSpace(pborderwidths: PRect): HResult;
begin
  Result := S_OK;
end;

function TOleWin.SetActiveObject(const ActiveObject: IOleInPlaceActiveObject;
  pszObjName: POleStr): HResult;
var
  Window, ParentWindow: HWnd;
begin
  Result := S_OK;
  FActiveObject := ActiveObject;
  if FActiveObject = nil then Exit;
  if FActiveObject.GetWindow(Window) = 0 then
    while True do
    begin
      ParentWindow := GetParent(Window);
      if ParentWindow = 0 then Break;
      begin
        SetWindowPos(Window, HWND_TOP, 0, 0, 0, 0,
          SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
        Break;
      end;
      Window := ParentWindow;
    end;
  FSaveWidth := FForm.Width;
  FSaveHeight := FForm.Height;
end;

function TOleWin.InsertMenus(hmenuShared: HMenu;
  var menuWidths: TOleMenuGroupWidths): HResult;
{var
  Menu: TMainMenu;}
begin
{  Menu := FForm.Menu;
  if Menu <> nil then
    Menu.PopulateOle2Menu(hmenuShared, [0, 2, 4], menuWidths.width);}
  Result := S_OK;
end;

function TOleWin.SetMenu(hmenuShared: HMenu; holemenu: HMenu;
  hwndActiveObject: HWnd): HResult;
begin
//  Menu := FForm.Menu;
  Result := S_OK;
  {if Menu <> nil then
  begin
    Menu.SetOle2MenuHandle(hmenuShared);
    Result := OleSetMenuDescriptor(holemenu, Menu.WindowHandle,
      hwndActiveObject, nil, nil);
  end;}
end;

function TOleWin.RemoveMenus(hmenuShared: HMenu): HResult;
begin
{  while GetMenuItemCount(hmenuShared) > 0 do
    RemoveMenu(hmenuShared, 0, MF_BYPOSITION);}
  Result := S_OK;
end;

function TOleWin.SetStatusText(pszStatusText: POleStr): HResult;
var st:PChar;
begin
  st:=StrNew(PChar(pszStatusText));
  TMyMDI(Window.Parent.Handle).StatusBar.SetText(3,st);
  Result := S_OK;
end;

function TOleWin.EnableModeless(fEnable: BOOL): HResult;
begin
  Result := S_OK;
end;

function TOleWin.TranslateAccelerator(var msg: TMsg; wID: Word): HResult;
begin
//  Menu := FForm.Menu;
  {if (Menu <> nil) and Menu.DispatchCommand(wID) then}
    Result := S_OK {else
    Result := S_FALSE; }
end;

{ TOleForm }

constructor TOleWin.Create(Win:TWindow);
begin
  inherited Create;
  FForm := Win;
//  FForm.OleFormObject := Self;
end;

destructor TOleWin.Destroy;
begin
{  if FForm <> nil then FForm.OleFormObject := nil;
  FHiddenControls.Free;
  FContainers.Free;
 } inherited Destroy;
end;

procedure TOleWin.ClearBorderSpace;
var
  I: Integer;
begin
end;


function TOleWin.Window: TWindow;
begin
  Result := FForm;
end;

{ Initialization }

procedure Initialize;
var
  DC: HDC;
begin
  DC := GetDC(0);
  PixPerInch.X := GetDeviceCaps(DC, LOGPIXELSX);
  PixPerInch.Y := GetDeviceCaps(DC, LOGPIXELSY);
  ReleaseDC(0, DC);
  CFObjectDescriptor := RegisterClipboardFormat('Object Descriptor');
  CFEmbeddedObject := RegisterClipboardFormat('Embedded Object');
  CFLinkSource := RegisterClipboardFormat('Link Source');
  DataFormats[0].cfFormat := CFEmbeddedObject;
  DataFormats[0].dwAspect := DVASPECT_CONTENT;
  DataFormats[0].lIndex := -1;
  DataFormats[0].tymed := TYMED_ISTORAGE;
  DataFormats[1].cfFormat := CFObjectDescriptor;
  DataFormats[1].dwAspect := DVASPECT_CONTENT;
  DataFormats[1].lIndex := -1;
  DataFormats[1].tymed := TYMED_HGLOBAL;
end;

procedure TOleContainer.GetWndClassEx(var WC: TWndClassEx);
begin
  inherited;
  WC.style:=WC.style and not (CS_HREDRAW or CS_VREDRAW);
end;

function TOleContainer.WndProc(Wnd: HWND; Msg, WParam,
  LParam: DWORD): DWORD;
var Menu,Sub:HMenu;P:TPoint;DC:HDC;R:TRect;
begin
  case msg of
    WM_SETFOCUS:if FOleObject<>nil then
      begin
        DC:=GetDC(Handle);
        GetWindowRect(Handle,R);
        OleDraw(FOleObject, FDrawAspect, DC, R);
        ReleaseDC(Handle,DC);
      end;
    WM_PAINT:
      if FOleObject<>nil then
      begin
        DC:=GetDC(Handle);
        GetWindowRect(Handle,R);
        OleDraw(FOleObject, FDrawAspect, DC, R);
        ReleaseDC(Handle,DC);
      end;
    WM_COMMAND:
    case Wparam of
      1200:DoVerb(0);
      1201:DoVerb(1);
    end;
    WM_CONTEXTMENU:
    begin
      Menu:=LoadMenu(MainInstance,PChar(1111));
      Sub:=GetSubMenu(Menu,0);
      GetCursorPos(P);
      TrackPopupMenu(Sub,TPM_LEFTBUTTON,P.X,P.Y,0,Handle,nil);
//      DoVerb(ovPrimary)
    end;
  end;
  Result:=DefWindowProc(Wnd,Msg,Wparam,LParam);
end;

procedure TOleContainer.CreateNewObject(n:DWORD);
var
  NameBuffer: array[0..255] of Char;
  CreateInfo: TCreateInfo;
  k:integer;
const
  GUID_Ecuat:TGUID=(D1:183810;D2:0;D3:0;D4:(192,0,0,0,0,0,0,70));
  GUID_MSPaint:TGUID=(D1:3554888481;D2:40309;D3:4122;D4:(140,61,0,170,0,26,22,82));
begin
  CreateInfo.CreateType := ctNewObject;
  case n of
    CNO_ECUAT : CreateInfo.ClassID:=GUID_Ecuat;
    CNO_BMP   : CreateInfo.ClassID:=GUID_MSpaint;
  end;
  CreateInfo.ShowAsIcon := false;
  CreateInfo.IconMetaPict := 0;
  CreateObjectFromInfo(CreateInfo);
end;

{ TRTFOle }

function TRTFOle.ContextSensitiveHelp(fEnterMode: BOOL): HRESULT;
begin
  Result:=S_OK;
end;

function TRTFOle.DeleteObject(oleobj: pointer): HRESULT;
begin
  Result:=S_OK;
end;

function TRTFOle.GetClipboardData(const chrg: TCharRange; reco: DWORD;
  out dataobj: pointer): HRESULT;
begin
  Result:=S_OK;
end;

function TRTFOle.GetContextMenu(seltype: Word; oleobj: pointer;
  const chrg: TCharRange; var menu: HMENU): HRESULT;
begin
  Result:=S_OK;
  menu:=LoadMenu(MainInstance,PChar('TEcuation'));
end;

function TRTFOle.GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD;
  var dwEffect: DWORD): HRESULT;
begin
  Result:=S_OK;
end;

function TRTFOle.GetInPlaceContext(out Frame: IOleInPlaceFrame;out Doc:
             IOleInPlaceUIWindow; var FrameInfo: POleInPlaceFrameInfo):HRESULT; stdcall;
begin
  Result:=S_OK;
end;

function TRTFOle.GetNewStorage(out stg: pointer): HRESULT;
begin
  Result:=S_OK;
  stg:=Pointer(FStorage);
end;

function TRTFOle.QueryAcceptData(dataobj: pointer; var cfFormat: word;
  reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT;
begin
  Result:=S_OK;
end;

function TRTFOle.QueryInsertObject(const clsid: TGUID; stg: pointer;
  cp: Integer): HRESULT;
begin
  Result:=S_OK;
end;

function TRTFOle.ShowContainerUI(fShow: BOOL): HRESULT;
begin
  Result:=S_OK;
end;

procedure TOleWin.OnDestroy;
begin
end;

procedure TOleWin.OnResize;
begin

end;

initialization
  OleInitialize(nil);
  Initialize;
finalization
  OleUninitialize;
end.
