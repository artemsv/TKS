{$O-}
unit OleObj;                       //  Дата создания : 07.11.02.

interface

uses ActiveX,Windows,Streams,ComObj,OleRTF,WinRTF,SysUtils;

const
  //  GUID Усгфешщт 3.0
  GUID_Ecuat:TGUID=(D1:183810;D2:0;D3:0;D4:(192,0,0,0,0,0,0,70));
  //  GUID Microsoft Pan\int
  GUID_MSPaint:TGUID=(D1:3554888481;D2:40309;D3:4122;D4:(140,61,0,170,0,26,22,82));
  Signature       = $4F455341;   { ASEO }

  {  класс,позволяющий внедрять объекты в составной документ }

type
  TOleObject=class(TInterfacedObject,IOleClientSite)
  private
    FStorage:IStorage;
    FLockBytes:ILockBytes;
    FOleObject:IOleObject;
  public
    charPos:integer;      //  позиция в RTF, в которую вставляется объект
    constructor Create;virtual;
    constructor Load(TF:TFile);              //  загружает объект из файла TF
    constructor CreateFromFile(FileName:string);
    procedure Store(TF:TFile);               //  сохраняет объект в файле TF
    procedure CreateStorage;
    // внедряет объект в RTF в позицию charPos
    procedure Embed(REO:IRichEditOle;charPos:integer;RTF:TRtf);
    property Storage:IStorage read FStorage;
    property LockBytes:ILockBytes read FLockBytes;
    property OleObject:IOleObject read FOleObject;
    { IOleClientSite }
    function SaveObject: HResult; stdcall;
    function GetMoniker(dwAssign: Longint; dwWhichMoniker: Longint;
      out mk: IMoniker): HResult; stdcall;
    function GetContainer(out container: IOleContainer): HResult; stdcall;
    function ShowObject: HResult; stdcall;
    function OnShowWindow(fShow: BOOL): HResult; stdcall;
    function RequestNewObjectLayout: HResult; stdcall;
  end;

  TOleBMP=class(TOleObject)
  public
    constructor Create;override;
  end;

  TOleEcuat=class(TOleObject)
  public
    constructor Create;override;
  end;


implementation

var
  PixPerInch: TPoint;
  CFObjectDescriptor: Integer;
  CFEmbeddedObject: Integer;
  CFLinkSource: Integer;
  DataFormats: array[0..1] of TFormatEtc;
type
  TStreamHeader = record
    Signature: Integer;
    DataSize: Integer;
  end;
  
{ TOleObject }

constructor TOleObject.Create;
begin
  CreateStorage;
  charPos:=-1;
end;

constructor TOleObject.CreateFromFile(FileName: string);
var P:TPoint;
begin
  P.x:=30;
  P.y:=20;
  CreateStorage;
  charPos:=-1;
  OleCheck(OleCreateFromFile(GUID_NULL, PWideChar(FileName), IOleObject,
            OLERENDER_DRAW, nil, Self, FStorage, FOleObject));
  FOleObject.SetExtent(DVASPECT_CONTENT, P);
end;

procedure TOleObject.CreateStorage;
begin
  OleCheck(CreateILockBytesOnHGlobal(0, True, FLockBytes));
  OleCheck(StgCreateDocfileOnILockBytes(FLockBytes, STGM_READWRITE
    or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, FStorage));
end;

procedure TOleObject.Embed(REO: IRichEditOle; charPos: integer;RTF:TRtf);
var RO:REOBJECT;
begin
  FillChar(RO,SizeOf(RO),0);
  RO.cbStruct:=SizeOf(RO);
  RO.cp:=charPos;
  RO.dwFlags:=1;
  RO.dvaspect:=DVASPECT_CONTENT;
  REO.GetClientSite(RO.polesite);
  RO.pstg:=FStorage;
  RO.poleobj:=FOleObject;
  RO.dwUser:=DWORD(Self);
  REO.InsertObject(@RO);
  RTF.SetSel (charPos,charPos+1);             // Выделили пустой объект
end;

function TOleObject.GetContainer(out container: IOleContainer): HResult;
begin
  container := nil;
  Result := E_NOINTERFACE;
end;

function TOleObject.GetMoniker(dwAssign, dwWhichMoniker: Integer;
  out mk: IMoniker): HResult;
begin
  mk := nil;
  Result := E_NOTIMPL;
end;

constructor TOleObject.Load(TF: TFile);
var
  DataHandle: HGlobal;
  Buffer: Pointer;
  Header: TStreamHeader;
begin
  CreateStorage;
  TF.Read(charPos,SizeOf(charPos));
  TF.Read(Header, SizeOf(Header));
  if (Header.Signature <> Signature) then
    raise EOleError.Create('Неправильный формат внедренного объекта');
  DataHandle := GlobalAlloc(GMEM_MOVEABLE, Header.DataSize);
  if DataHandle = 0 then OutOfMemoryError;
  try
    Buffer := GlobalLock(DataHandle);
    try
      TF.Read(Buffer^, Header.DataSize);
    finally
      GlobalUnlock(DataHandle);
    end;
    OleCheck(CreateILockBytesOnHGlobal(DataHandle, True, FLockBytes));
    DataHandle := 0;
    OleCheck(StgOpenStorageOnILockBytes(FLockBytes, nil, STGM_READWRITE or
      STGM_SHARE_EXCLUSIVE, nil, 0, FStorage));
    OleCheck(OleLoad(FStorage, IOleObject, Self, FOleObject));
  except
    if DataHandle <> 0 then GlobalFree(DataHandle);
    raise;
  end;
end;

function TOleObject.OnShowWindow(fShow: BOOL): HResult;
begin
  Result := S_OK;
end;

function TOleObject.RequestNewObjectLayout: HResult;
begin
  Result := E_NOTIMPL;
end;

function TOleObject.SaveObject: HResult;
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
end;

function TOleObject.ShowObject: HResult;
begin
  Result := S_OK;
end;

procedure TOleObject.Store(TF: TFile);
var
  TempLockBytes: ILockBytes;
  TempStorage: IStorage;
  DataHandle: HGlobal;
  Buffer: Pointer;
  Header: TStreamHeader;
begin
  OleCheck(CreateILockBytesOnHGlobal(0, True, TempLockBytes));
  OleCheck(StgCreateDocfileOnILockBytes(TempLockBytes, STGM_READWRITE
    or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, TempStorage));
  OleCheck(FStorage.CopyTo(0, nil, nil, TempStorage));
  OleCheck(TempStorage.Commit(STGC_DEFAULT));
  OleCheck(GetHGlobalFromILockBytes(TempLockBytes, DataHandle));
  Header.Signature := Signature;
  Header.DataSize := GlobalSize(DataHandle);
  TF.Write(charPos,SizeOf(charPos));
  TF.Write(Header,SizeOf(Header));
  Buffer := GlobalLock(DataHandle);
  try
    TF.Write(Buffer^, Header.DataSize);
  finally
    GlobalUnlock(DataHandle);
  end;
end;

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

{ TOleBMP }

constructor TOleBMP.Create;
begin
  inherited;
  OleCheck(OleCreate(GUID_MSPaint, IOleObject, OLERENDER_DRAW, nil,
     Self, FStorage, FOleObject));
end;

{ TOleEcuat }

constructor TOleEcuat.Create;
begin
  inherited;
  OleCheck(OleCreate(GUID_Ecuat, IOleObject, OLERENDER_DRAW, nil,
     Self, FStorage, FOleObject));
end;

initialization
  Initialize;
end.
