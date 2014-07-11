
{*******************************************************}
{                                                       }
{       Turbo Pascal for Windows Run-time Library       }
{       ObjectWindows Unit                              }
{                                                       }
{       Copyright (c) 1991 Borland International        }
{                                                       }
{*******************************************************}

unit ODialogs;

{$T-,R-}

interface

uses WinProcs, WinTypes, Objects, OWindows, Validate;

const

{ TCheckBox check states }

  bf_Unchecked = 0;
  bf_Checked   = 1;
  bf_Grayed    = 2;

{ Message number used for input validation }

  wm_PostInvalid = wm_User + 400;

type

{ TDialog creation attributes }

  TDialogAttr = record
    Name: PChar;
    Param: LongInt;
  end;

{ TDialog object }

  PDialog = ^TDialog;
  TDialog = object(TWindowsObject)
    Attr: TDialogAttr;
    IsModal: Boolean;
    constructor Init(AParent: PWindowsObject; AName: PChar);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Store(var S: TStream);
    function Create: Boolean; virtual;
    function Execute: Integer; virtual;
    procedure EndDlg(ARetValue: Integer); virtual;
    function GetItemHandle(DlgItemID: Integer): HWnd;
    function SendDlgItemMsg(DlgItemID: Integer; AMsg, WParam: Word;
      LParam: LongInt): LongInt;
    procedure Ok(var Msg: TMessage); virtual id_First + id_Ok;
    procedure Cancel(var Msg: TMessage); virtual id_First + id_Cancel;
    procedure WMInitDialog(var Msg: TMessage);
      virtual wm_First + wm_InitDialog;
    procedure WMQueryEndSession(var Msg: TMessage);
      virtual wm_First + wm_QueryEndSession;
    procedure WMClose(var Msg: TMessage);
      virtual wm_First + wm_Close;
    procedure WMPostInvalid(var Msg: TMessage);
      virtual wm_First + wm_PostInvalid;
    procedure DefWndProc(var Msg: TMessage); virtual;
  end;

{ TDlgWindow object }

  PDlgWindow = ^TDlgWindow;
  TDlgWindow = object(TDialog)
    constructor Init(AParent: PWindowsObject; AName: PChar);
    procedure GetWindowClass(var AWndClass: TWndClass); virtual;
    function Create: Boolean; virtual;
  end;

{ TControl object }

  PControl = ^TControl;
  TControl = object(TWindow)
    constructor Init(AParent: PWindowsObject; AnId: Integer;
      ATitle: PChar; X, Y, W, H: Integer);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    function Register: Boolean; virtual;
    function GetClassName: PChar; virtual;
    procedure WMPaint(var Msg: TMessage); virtual wm_First + wm_Paint;
  end;

{ TGroupBox object }

  PGroupBox = ^TGroupBox;
  TGroupBox = object(TControl)
    NotifyParent: Boolean;
    constructor Init(AParent: PWindowsObject; AnID: Integer;
      AText: PChar; X, Y, W, H: Integer);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetClassName: PChar; virtual;
    procedure SelectionChanged(ControlId: Integer); virtual;
  end;

{ TButton object }

  PButton = ^TButton;
  TButton = object(TControl)
    constructor Init(AParent: PWindowsObject; AnId: Integer;
      AText: PChar; X, Y, W, H: Integer; IsDefault: Boolean);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    function GetClassName: PChar; virtual;
  end;

{ TCheckBox object }

  PCheckBox = ^TCheckBox;
  TCheckBox = object(TButton)
    Group: PGroupBox;
    constructor Init(AParent: PWindowsObject; AnID: Integer;
      ATitle: PChar; X, Y, W, H: Integer; AGroup: PGroupBox);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    procedure Check;
    procedure Uncheck;
    procedure Toggle;
    function GetClassName: PChar; virtual;
    function GetCheck: Word;
    procedure SetCheck(CheckFlag: Word);
    function Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
    procedure BNClicked(var Msg: TMessage);
      virtual nf_First + bn_Clicked;
  end;

{ TRadioButton object }

  PRadioButton = ^TRadioButton;
  TRadioButton = object(TCheckBox)
    constructor Init(AParent: PWindowsObject; AnID: Integer;
      ATitle: PChar; X, Y, W, H: Integer; AGroup: PGroupBox);
    function GetClassName: PChar; virtual;
  end;

{ TStatic object }

  PStatic = ^TStatic;
  TStatic = object(TControl)
    TextLen: Word;
    constructor Init(AParent: PWindowsObject; AnId: Integer;
      ATitle: PChar; X, Y, W, H: Integer; ATextLen: Word);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word;
      ATextLen: Word);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetClassName: PChar; virtual;
    function GetText(ATextString: PChar; MaxChars: Integer): Integer;
    function GetTextLen: Integer;
    procedure SetText(ATextString: PChar);
    procedure Clear;
    function Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
  end;

{ TEdit object }

  PEdit	= ^TEdit;
  TEdit = object(TStatic)
    Validator: PValidator;
    constructor Init(AParent: PWindowsObject; AnId: Integer; ATitle: PChar;
       X, Y, W, H: Integer; ATextLen: Word; Multiline: Boolean);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word;
      ATextLen: Word);
    constructor Load(var S: TStream);
    destructor  Done; virtual;
    function GetClassName: PChar; virtual;
    procedure Undo;
    function CanClose: Boolean; virtual;
    function CanUndo: Boolean;
    procedure Paste;
    procedure Copy;
    procedure Cut;
    function GetNumLines: Integer;
    function GetLineLength(LineNumber: Integer): Integer;
    function GetLine(ATextString: PChar;
      StrSize, LineNumber: Integer): Boolean;
    procedure GetSubText(ATextString: PChar; StartPos, EndPos: Integer);
    function DeleteSubText(StartPos, EndPos: Integer): Boolean;
    function DeleteLine(LineNumber: Integer): Boolean;
    procedure GetSelection(var StartPos, EndPos: Integer);
    function DeleteSelection: Boolean;
    function IsModified: Boolean;
    procedure ClearModify;
    function GetLineFromPos(CharPos: Integer): Integer;
    function GetLineIndex(LineNumber: Integer): Integer;
    function IsValid(ReportError: Boolean): Boolean;
    procedure Scroll(HorizontalUnit, VerticalUnit: Integer);
    function SetSelection(StartPos, EndPos: Integer): Boolean;
    procedure Insert(ATextString: PChar);
    function Search(StartPos: Integer; AText: PChar; CaseSensitive: Boolean): Integer;
    procedure SetupWindow; virtual;
    procedure SetValidator(AValid: PValidator);
    procedure Store(var S: TStream);
    function  Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
    procedure CMEditCut(var Msg: TMessage);
      virtual  cm_First + cm_EditCut;
    procedure CMEditCopy(var Msg: TMessage);
      virtual  cm_First + cm_EditCopy;
    procedure CMEditPaste(var Msg: TMessage);
      virtual  cm_First + cm_EditPaste;
    procedure CMEditDelete(var Msg: TMessage);
      virtual  cm_First + cm_EditDelete;
    procedure CMEditClear(var Msg: TMessage);
      virtual  cm_First + cm_EditClear;
    procedure CMEditUndo(var Msg: TMessage);
      virtual  cm_First + cm_EditUndo;
    procedure WMChar(var Msg: TMessage);
      virtual  wm_First + wm_Char;
    procedure WMKeyDown(var Msg: TMessage);
      virtual  wm_First + wm_KeyDown;
    procedure WMGetDlgCode(var Msg: TMessage);
      virtual  wm_First + wm_GetDlgCode;
    procedure WMKillFocus(var Msg: TMessage);
      virtual  wm_First + wm_KillFocus;
  end;

{ TListBox message name type }

  TMsgName = (
    mn_AddString, mn_InsertString, mn_DeleteString,
    mn_ResetContent, mn_GetCount, mn_GetText,
    mn_GetTextLen, mn_SelectString, mn_SetCurSel,
    mn_GetCurSel);

{ Multiple selction transfer record }

  PMultiSelRec = ^TMultiSelRec;
  TMultiSelRec = record
    Count: Integer;
    Selections: array[0..32760] of Integer;
  end;

{ TListBox object }

  PListBox = ^TListBox;
  TListBox = object(TControl)
    constructor Init(AParent: PWindowsObject; AnId: Integer;
      X, Y, W, H: Integer);
    function GetClassName: PChar; virtual;
    function AddString(AString: PChar): Integer;
    function InsertString(AString: PChar; Index: Integer): Integer;
    function DeleteString(Index: Integer): Integer;
    procedure ClearList;
    function Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
    function GetCount: Integer;
    function GetString(AString: PChar; Index: Integer): Integer;
    function GetStringLen(Index: Integer): Integer;
    function GetSelString(AString: PChar; MaxChars: Integer): Integer;
    function SetSelString(AString: PChar; Index: Integer): Integer;
    function GetSelIndex: Integer;
    function SetSelIndex(Index: Integer): Integer;
  private
    function GetMsgID(AMsg: TMsgName): Word; virtual;
  end;

{ TComboBox object }

  PComboBox = ^TComboBox;
  TComboBox = object(TListBox)
    TextLen: Word;
    constructor Init(AParent: PWindowsObject; AnID: Integer;
      X, Y, W, H: Integer; AStyle: Word; ATextLen: Word);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Integer;
      ATextLen: Word);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetClassName: PChar; virtual;
    procedure ShowList;
    procedure HideList;
    function Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
    procedure SetupWindow; virtual;
    function GetTextLen: Integer;
    function GetText(Str: PChar; MaxChars: Integer): Integer;
    procedure SetText(Str: PChar);
    function SetEditSel(StartPos, EndPos: Integer): Integer;
    function GetEditSel(var StartPos, EndPos: Integer): Boolean;
    procedure Clear;
  private
    function GetMsgID(AMsg: TMsgName): Word; virtual;
  end;

{ TScrollBar transfer record }

  TScrollBarTransferRec = record
    LowValue: Integer;
    HighValue: Integer;
    Position: Integer;
  end;

{ TScrollBar object }

  PScrollBar = ^TScrollBar;
  TScrollBar = object(TControl)
    LineMagnitude, PageMagnitude: Integer;
    constructor Init(AParent: PWindowsObject; AnID: Integer;
      X, Y, W, H: Integer; IsHScrollBar: Boolean);
    constructor InitResource(AParent: PWindowsObject; ResourceID: Word);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetClassName: PChar; virtual;
    procedure SetupWindow; virtual;
    procedure GetRange(var LoVal, HiVal: Integer);
    function GetPosition: Integer;
    procedure SetRange(LoVal, HiVal: Integer);
    procedure SetPosition(ThumbPos: Integer);
    function DeltaPos(Delta: Integer): Integer;
    function Transfer(DataPtr: Pointer; TransferFlag: Word): Word; virtual;
    procedure SBLineUp(var Msg: TMessage);
      virtual nf_First + sb_LineUp;
    procedure SBLineDown(var Msg: TMessage);
      virtual nf_First + sb_LineDown;
    procedure SBPageUp(var Msg: TMessage);
      virtual nf_First + sb_PageUp;
    procedure SBPageDown(var Msg: TMessage);
      virtual nf_First + sb_PageDown;
    procedure SBThumbPosition(var Msg: TMessage);
      virtual nf_First + sb_ThumbPosition;
    procedure SBThumbTrack(var Msg: TMessage);
      virtual nf_First + sb_ThumbTrack;
    procedure SBTop(var Msg: TMessage);
      virtual nf_First + sb_Top;
    procedure SBBottom(var Msg: TMessage);
      virtual nf_First + sb_Bottom;
  end;

{ Multi-selection support routines }

function AllocMultiSel(Size: Integer): PMultiSelRec;
procedure FreeMultiSel(P: PMultiSelRec);

{ Stream routine }

procedure RegisterODialogs;

const
  RDialog: TStreamRec = (
    ObjType: 54;
    VmtLink: Ofs(TypeOf(TDialog)^);
    Load:    @TDialog.Load;
    Store:   @TDialog.Store);

const
  RDlgWindow: TStreamRec = (
    ObjType: 55;
    VmtLink: Ofs(TypeOf(TDlgWindow)^);
    Load:    @TDlgWindow.Load;
    Store:   @TDlgWindow.Store);

const
  RControl: TStreamRec = (
    ObjType: 56;
    VmtLink: Ofs(TypeOf(TControl)^);
    Load:    @TControl.Load;
    Store:   @TControl.Store);

const
  RMDIClient: TStreamRec = (
    ObjType: 58;
    VmtLink: Ofs(TypeOf(TMDIClient)^);
    Load:    @TMDIClient.Load;
    Store:   @TMDIClient.Store);

const
  RButton: TStreamRec = (
    ObjType: 59;
    VmtLink: Ofs(TypeOf(TButton)^);
    Load:    @TButton.Load;
    Store:   @TButton.Store);

const
  RCheckBox: TStreamRec = (
    ObjType: 60;
    VmtLink: Ofs(TypeOf(TCheckBox)^);
    Load:    @TCheckBox.Load;
    Store:   @TCheckBox.Store);

const
  RRadioButton: TStreamRec = (
    ObjType: 61;
    VmtLink: Ofs(TypeOf(TRadioButton)^);
    Load:    @TRadioButton.Load;
    Store:   @TRadioButton.Store);

const
  RGroupBox: TStreamRec = (
    ObjType: 62;
    VmtLink: Ofs(TypeOf(TGroupBox)^);
    Load:    @TGroupBox.Load;
    Store:   @TGroupBox.Store);

const
  RListBox: TStreamRec = (
    ObjType: 63;
    VmtLink: Ofs(TypeOf(TListBox)^);
    Load:    @TListBox.Load;
    Store:   @TListBox.Store);

const
  RComboBox: TStreamRec = (
    ObjType: 64;
    VmtLink: Ofs(TypeOf(TComboBox)^);
    Load:    @TComboBox.Load;
    Store:   @TComboBox.Store);

const
  RScrollBar: TStreamRec = (
    ObjType: 65;
    VmtLink: Ofs(TypeOf(TScrollBar)^);
    Load:    @TScrollBar.Load;
    Store:   @TScrollBar.Store);

const
  RStatic: TStreamRec = (
    ObjType: 66;
    VmtLink: Ofs(TypeOf(TStatic)^);
    Load:    @TStatic.Load;
    Store:   @TStatic.Store);

const
  REdit: TStreamRec = (
    ObjType: 67;
    VmtLink: Ofs(TypeOf(TEdit)^);
    Load:    @TEdit.Load;
    Store:   @TEdit.Store);

implementation

uses Strings, OMemory;

{ Used while determining when to validate a TEdit control.  Inhibits
  focus change from validating the control when bringing up a dialog
  to report invalid data. }

const
  ProcessFocus: Boolean = True;

{ TDialog }

{ Constructor for a TDialog object.  Calls TWindowsObject.Init, creating
  an instance thunk for the TDialog. }

constructor TDialog.Init(AParent: PWindowsObject; AName: PChar);
begin
  TWindowsObject.Init(AParent);
  DisableAutoCreate;
  if PtrRec(AName).Seg <> 0 then Attr.Name := StrNew(AName)
  else Attr.Name := AName;
  Attr.Param := 0;
  IsModal := False;
end;

{ Destructor for a TDialog.  TWindowsObject.Done is called to free
  the instance thunk. }

destructor TDialog.Done;
begin
  if PtrRec(Attr.Name).Seg <> 0 then StrDispose(Attr.Name);
  TWindowsObject.Done;
end;

{ Constructor for a TDialog object.  Initializes the TDialog with
  data from the passed TStream. }

constructor TDialog.Load(var S: TStream);
var
  NameIsNumeric: Boolean;
begin
  TWindowsObject.Load(S);
  DisableAutoCreate;
  with Attr do
  begin
    S.Read(NameIsNumeric, SizeOf(NameIsNumeric));
    if NameIsNumeric then S.Read(Name, SizeOf(Name))
    else Name := S.StrRead;
    S.Read(Param, SizeOf(Param));
  end;
  S.Read(IsModal, SizeOf(IsModal));
end;

{ Stores data of the TDialog object in the passed TStream. }

procedure TDialog.Store(var S: TStream);
var
  NameIsNumeric: Boolean;
begin
  TWindowsObject.Store(S);
  with Attr do
  begin
    NameIsNumeric := PtrRec(Name).Seg = 0;
    S.Write(NameIsNumeric, SizeOf(NameIsNumeric));
    if NameIsNumeric then S.Write(Name, SizeOf(Name))
    else S.StrWrite(Name);
    S.Write(Param, SizeOf(Param));
  end;
  S.Write(IsModal, SizeOf(IsModal));
end;

{ Creates an MS-Windows modeless dialog, and associates the modeless
  dialog interface element with the TDialog.  Creation and association is
  not attempted if the Status data field is non-zero. }

function TDialog.Create: Boolean;
var
  HParent: HWnd;
begin
  if Status = 0 then
  begin
    DisableAutoCreate;
    EnableKBHandler;
    IsModal := False;
    if Parent = nil then HParent := 0 else HParent := Parent^.HWindow;
    HWindow := CreateDialogParam(HInstance, Attr.Name, HParent, Instance,
      Attr.Param);
    if HWindow = 0 then Status := em_InvalidWindow;
  end;
  Create := Status = 0;
end;

{ Creates an MS-Windows modal dialog, using the creation attributes
  previously set in the Attr data field.  Associates the modal dialog
  interface element with the TDialog.  Creation and association is not
  attempted if the Status data field is non-zero. }

function TDialog.Execute: Integer;
var
  HParent: HWnd;
  ReturnValue: Integer;
  OldKbHandler: PWindowsObject;
begin
  if Status = 0 then
  begin
    DisableAutoCreate;
    EnableKBHandler;
    IsModal := True;
    if Parent = nil then HParent := 0 else HParent := Parent^.HWindow;
    OldKbHandler := Application^.KBHandlerWnd;
    ReturnValue := DialogBoxParam(HInstance, Attr.Name, HParent, Instance,
      Attr.Param);
    Application^.KBHandlerWnd := OldKbHandler;
    { -1 if the function cannot create the dialog box }
    if ReturnValue = -1 then Status := em_InvalidWindow;
    HWindow := 0;
    Execute := ReturnValue;
  end
  else Execute := Status;
end;

{ Destroys the MS-Windows dialog associated with the TDialog. }

procedure TDialog.EndDlg(ARetValue: Integer);

  procedure DoEnableAutoCreate(P: PWindowsObject); far;
  begin
    if P^.HWindow <> 0 then P^.EnableAutoCreate;
  end;

begin
  if IsModal then
  begin
    ForEach(@DoEnableAutoCreate);
    EndDialog(HWindow, ARetValue)
  end;
end;

{ Responds to an incoming wm_InitDialog message.  This message is sent
  after an MS-Windows dialog is created and before the dialog is displayed.
  Calls SetupWindow to perform set up for the dialog. }

procedure TDialog.WMInitDialog(var Msg: TMessage);
begin
  SetupWindow;
end;

{ Respond to Windows attempt to close close down. Note: A DIALOG needs
  to invert the test because windows expects the opposite of a normal
  window. }

procedure TDialog.WMQueryEndSession(var Msg: TMessage);
begin
  if @Self = Application^.MainWindow then
    Msg.Result := Integer(not Application^.CanClose)
  else Msg.Result := Integer(not CanClose);
end;

{ Responds to a message from a child edit control that its contents
  are invalid.  Posts the invalid message using that child's Validator
  and returns the focus to that child.  This response method is used
  to allow the KillFocus processing for the Edit control to post the
  message outside the KillFocus chain, since posting a message box
  while the focus is being taken causes a number of problems.  The
  TEdit puts the handle to itself in WParam. }

procedure TDialog.WMPostInvalid(var Msg: TMessage);
var
  AnEdit: PEdit;
begin
  SetFocus(Msg.WParam);
  AnEdit := PEdit(GetObjectPtr(Msg.WParam));
  if (AnEdit <> nil) and (AnEdit^.Validator <> nil) then
    AnEdit^.Validator^.Error;
  ProcessFocus := True;
end;

{ Returns the handle of the dialog's control which has the passed Id. }

function TDialog.GetItemHandle(DlgItemID: Integer): HWND;
begin
  GetItemHandle := GetDlgItem(HWindow, DlgItemID);
end;

{ Sends the passed message to the dialog's control which has the passed
  Id. }

function TDialog.SendDlgItemMsg(DlgItemID: Integer; AMsg, WParam: Word;
  LParam: LongInt): LongInt;
begin
  SendDlgItemMsg :=
    SendDlgItemMessage(HWindow, DlgItemID, AMsg, WParam, LParam);
end;

{ Specifies that default processing for an incoming message is to be
  performed by MS-Windows by setting the Result field of the passed Msg
  to zero. }

procedure TDialog.DefWndProc(var Msg: TMessage);
begin
  Msg.Result := 0;
end;

{ Responds to an incoming notification message from a button with an Id
  equal to id_OK.  Calls CanClose.  If the call returns True, calls
  TransferData and then ends the dialog, returning id_OK. }

procedure TDialog.Ok(var Msg: TMessage);
begin
  if IsModal then
  begin
    if CanClose then
    begin
      TransferData(tf_GetData);
      EndDlg(id_OK);
    end;
  end else CloseWindow;
end;

{ Responds to an incoming notification message from a button with an Id
  equal to id_Cancel.  Ends the dialog, returning id_Cancel. }

procedure TDialog.Cancel(var Msg: TMessage);
begin
  if IsModal then EndDlg(id_Cancel) else CloseWindow;
end;

procedure TDialog.WMClose(var Msg: TMessage);
begin
  Cancel(Msg);
end;

{ TDlgWindow }

{ Constructor for a TDlgWindow object.  Calls TDialog.Init, setting
  the auto creation flag to True so that DlgWindow's appearing in
  their parent's child window list will be recreated. }

constructor TDlgWindow.Init(AParent: PWindowsObject; AName: PChar);
begin
  TDialog.Init(AParent, AName);
  EnableAutoCreate;
end;

{ Specifies registration attributes for the MS-Windows window class of the
  TDlgWindow, allowing instances of TDlgWindow to be registered.  Sets the
  fields of the passed TWndClass parameter to the default attributes
  appropriate for a TDlgWindow. }

procedure TDlgWindow.GetWindowClass(var AWndClass: TWndClass);
begin
  AWndClass.style := cs_HRedraw or cs_VRedraw;
  AWndClass.lpfnWndProc := @DefDlgProc;
  AWndClass.cbClsExtra := 0;
  AWndClass.cbWndExtra := DlgWindowExtra;
  AWndClass.hbrBackground := HBrush(color_window + 1);
  AWndClass.lpszMenuName := nil;
  AWndClass.hInstance := HInstance;
  AWndClass.hIcon := LoadIcon(0, idi_Application);
  AWndClass.hCursor := LoadCursor(0, idc_Arrow);
  AWndClass.lpszClassName := GetClassName;
end;

{ Creates an MS-Windows dialog window and associates the dialog window
  interface element with the TDlgWindow.  Calls Self.Register to ensure
  that the TDlgWindow's MS-Windows window class has been registered, then
  calls TDialog.Create. }

function TDlgWindow.Create: Boolean;
begin
  Create := False;
  if Register then Create := TDialog.Create;
end;

{ TControl }

{ Constructor for a TControl.  Calls TWindow.Init, and sets
  creation attributes using the parameters passed and default values. }

constructor TControl.Init(AParent: PWindowsObject; AnId: Integer;
  ATitle: PChar; X, Y, W, H: Integer);
begin
  TWindow.Init(AParent, ATitle);
  Attr.Id := AnId;
  Attr.X := X;
  Attr.Y := Y;
  Attr.W := W;
  Attr.H := H;
  Attr.Style := ws_Child or ws_Visible or ws_Group or ws_TabStop;
end;

{ Constructor for a TControl to be associated with a MS-Windows
  interface element created by MS-Windows from a resource definition.
  Initializes its data fields using passed parameters.  Data transfer
  is enabled for the TControl. }

constructor TControl.InitResource(AParent: PWindowsObject; ResourceID: Word);
begin
  TWindow.InitResource(AParent, ResourceID);
  EnableTransfer;
end;

{ Generates a run-time error (via call to inherited Abstract method)
  because an attempt should not be made to retrieve the window class name
  for an instance of this abstract object type.  Redefines ancestor's
  GetClassName, which returns a pointer to the name of the MS-Windows
  window class of the window object. Descendant classes redefine this
  method to return the MS-Windows window class name for their instances. }

function TControl.GetClassName: PChar;
begin
  Abstract;
end;

{ Redefines ancestor's Register method, which registers an MS-Windows class
  for a window object.  This method simply returns True because TControl
  descendants have pre-registered MS-Windows window classes. }

function TControl.Register: Boolean;
begin
  Register := True;
end;

{ Responds to an incoming wm_Paint message by calling the default window
  procedure, supplied by MS-Windows, which is appropriate for the TControl.
  Redefines ancestor's WMPaint. }

procedure TControl.WMPaint(var Msg: TMessage);
begin
  DefWndProc(Msg);
end;

{ TButton }

{ Constructor for a TButton object.  Initializes its data fields using
  parameters passed and default values. }

constructor TButton.Init(AParent: PWindowsObject; AnId: Integer; AText: PChar;
  X, Y, W, H: Integer; IsDefault:  Boolean);
begin
  TControl.Init(AParent, AnId, AText, X, Y, W, H);
  if IsDefault then
    Attr.Style := Attr.Style or bs_DefPushButton
  else Attr.Style := Attr.Style or bs_PushButton;
end;

{ Constructor for a TButton to be associated with a MS-Windows interface
  element created by MS-Windows from a resource definition. Initializes
  its data fields using passed parameters.  Disables transfer of state
  data for the TButton. }

constructor TButton.InitResource(AParent: PWindowsObject; ResourceID: Word);
begin
  TControl.InitResource(AParent, ResourceID);
  DisableTransfer;
end;

{ Returns the name of the MS-Windows window class for TButtons. }

function TButton.GetClassName: PChar;
begin
  if BWCCClassNames then
    GetClassName := 'BorBtn'
  else
    GetClassName := 'Button';
end;

{ TCheckBox }

{ Constructor for a TCheckBox object.  Initializes the object with data
  from the passed TStream. }

constructor TCheckBox.Load(var S: TStream);
begin
  TButton.Load(S);
  GetSiblingPtr(S, Group);
end;

{ Stores data of the TCheckBox object in the passed TStream. }

procedure TCheckBox.Store(var S: TStream);
begin
  TButton.Store(S);
  PutSiblingPtr(S, Group);
end;

{ Constructor for a TCheckBox object.  Initializes its data fields using
  passed parameters and default values. }

constructor TCheckBox.Init(AParent: PWindowsObject; AnID: Integer;
  ATitle: PChar; X, Y, W, H: Integer; AGroup: PGroupBox);
begin
  TControl.Init(AParent, AnID, ATitle, X, Y, W, H);
  Attr.Style := ws_Child or ws_Visible or ws_TabStop or bs_AutoCheckbox;
  Group := AGroup;
end;

{ Constructor for a TControl to be associated with a MS-Windows
  interface element created by MS-Windows from a resource definition.
  Initializes its data fields using passed parameters.  Data transfer
  is enabled for the TCheckBox. }

constructor TCheckBox.InitResource(AParent: PWindowsObject; ResourceID: Word);
begin
  TButton.InitResource(AParent, ResourceID);
  EnableTransfer;
  Group := nil;
end;

{ Transfers state information for the TCheckBox. The TransferFlag passed
  specifies whether data is to be read from or written to the passed
  buffer, or whether the data element size is simply to be returned. The
  return value is the size (in bytes) of the transfer data. }

function TCheckBox.Transfer(DataPtr: Pointer; TransferFlag: Word): Word;
var
  CheckFlag: Word;
begin
  if TransferFlag = tf_GetData then
  begin
    CheckFlag := GetCheck;
    Move(CheckFlag, DataPtr^, SizeOf(CheckFlag));
  end
  else if TransferFlag = tf_SetData then SetCheck(Word(DataPtr^)); 
  Transfer := SizeOf(CheckFlag);
end;

{ Returns the check state of the associated check box.  Returns bf_Unchecked
  (0), bf_Checked (1), or (if 3-state) bf_Grayed (2). }

function TCheckBox.GetCheck: Word;
begin
  GetCheck := SendMessage(HWindow, bm_GetCheck, 0, 0);
end;

{ Returns the name of the MS-Windows window class for TCheckBox. }

function TCheckBox.GetClassName: PChar;
begin
  if BWCCClassNames then
    GetClassName := 'BorCheck'
  else
    GetClassName := TButton.GetClassName;
end;

{ Sets the check state of the associated check box.  Unchecks, checks, or
  grays the checkbox (if 3-state) according to the CheckFlag passed.
  (Pass bf_Unchecked (0), bf_Checked (1), or bf_Grayed (2)). If a Group has
  been specified for the TCheckBox, notifies the Group that the state of the
  check box has changed. }

procedure TCheckBox.SetCheck(CheckFlag: Word);
begin
  SendMessage(HWindow, bm_SetCheck, CheckFlag, 0);
  if (Group <> nil) then Group^.SelectionChanged(Attr.Id);
end;

{ Places a checkmark in associated check box. }

procedure TCheckBox.Check;
begin
  SetCheck(1);
end;

{ Removes a checkmark from the associated check box. }

procedure TCheckBox.Uncheck;
begin
  SetCheck(0);
end;

{ Toggles the check state of the check box. }

procedure TCheckBox.Toggle;
begin
  if ((GetWindowLong(HWindow, gwl_Style) and bs_Auto3State) =  bs_Auto3State) then
    SetCheck((GetCheck+1) mod 3)
  else SetCheck((GetCheck+1) mod 2);
end;

{ Responds to an incoming bn_Clicked message.  If a Group has been
  specified for the TCheckBox, notifies the Group that the state of
  this TCheckBox has changed. }

procedure TCheckBox.BNClicked(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if (Group <> nil) then
    Group^.SelectionChanged(Attr.Id);
  DefNotificationProc(Msg);
end;

{ TRadioButton }

{ Constructor for a TRadioButton object.  Initializes its data fields
  using passed parameters and default values. }

constructor TRadioButton.Init(AParent: PWindowsObject; AnID: Integer;
  ATitle: PChar; X, Y, W, H: Integer; AGroup: PGroupBox);
begin
  TCheckBox.Init(AParent, AnID, ATitle, X, Y, W, H, AGroup);
  Attr.Style := ws_Child or ws_Visible or bs_AutoRadioButton;
end;

{ Returns the name of the MS-Windows window class for TRadioButton. }

function TRadioButton.GetClassName: PChar;
begin
  if BWCCClassNames then
    GetClassName := 'BorRadio'
  else
    GetClassName := TButton.GetClassName;
end;

{ TGroupBox }

{ Constructor for a TGroupBox object.  Initializes the object with data
  from the passed TStream. }

constructor TGroupBox.Load(var S: TStream);
begin
  TControl.Load(S);
  S.Read(NotifyParent, SizeOf(NotifyParent));
end;

{ Stores data of the TGroupBox object in the passed TStream. }

procedure TGroupBox.Store(var S: TStream);
begin
  TControl.Store(S);
  S.Write(NotifyParent, SizeOf(NotifyParent));
end;

{ Constructor for a TGroupBox object.  Initializes its data fields using
  parameters passed and default values. }

constructor TGroupBox.Init(AParent: PWindowsObject; AnID: Integer;
  AText: PChar; X, Y, W, H: Integer);
begin
  TControl.Init(AParent, AnId, AText, X, Y, W, H);
  NotifyParent := True;
  Attr.Style := (Attr.Style or bs_GroupBox) and (not ws_TabStop);
end;

{ Constructor for a TGroupBox to be associated with a MS-Windows interface
  element created by MS-Windows from a resource definition. Initializes
  its data fields using passed parameters.  Disables transfer of state
  data for the TGroupBox.  }

constructor TGroupBox.InitResource(AParent: PWindowsObject; ResourceID: Word);
begin
  TControl.InitResource(AParent, ResourceID);
  NotifyParent := True;
  DisableTransfer;
end;

{ Returns the name of MS-Windows window class for a TGroupBox. }

function TGroupBox.GetClassName: PChar;
begin
  GetClassName := 'Button';
end;

{ Notifies parent that the selection in the associated groupbox has
  changed.  This method is called by TCheckBoxes grouped in the groupbox
  when their state changes. }

procedure TGroupBox.SelectionChanged(ControlId: Integer);
begin
  if NotifyParent then
    SendMessage(Parent^.HWindow, wm_Command, Attr.ID,
      MakeLong(HWindow, ControlId));
end;

{ TStatic }

{ Constructor for a TStatic object.  Initializes its data fields using
  passed parameters and default values.   By default, an associated
  static control will have left-justified text. }

constructor TStatic.Init(AParent: PWindowsObject; AnId: Integer;
  ATitle: PChar; X, Y, W, H: Integer; ATextLen: Word);
begin
  TControl.Init(AParent, AnId, ATitle, X, Y, W, H);
  TextLen := ATextLen;
  Attr.Style := (Attr.Style or ss_Left) and (not ws_TabStop);
end;

{ Constructor for a TStatic to be associated with a MS-Windows
  interface element created by MS-Windows from a resource definition.
  Initializes its data fields using passed parameters.  Data transfer
  is disabled, by default, for the TStatic. }

constructor TStatic.InitResource(AParent: PWindowsObject; ResourceID: Word;
  ATextLen: Word);
begin
  TControl.InitResource(AParent, ResourceID);
  TextLen := ATextLen;
end;

{ Constructor for a TStatic object.  Initializes the object with data
  from the passed TStream. }

constructor TStatic.Load(var S: TStream);
begin
  TControl.Load(S);
  S.Read(TextLen, SizeOf(TextLen));
end;

{ Stores data of the TStatic object in the passed TStream. }

procedure TStatic.Store(var S: TStream);
begin
  TControl.Store(S);
  S.Write(TextLen, SizeOf(TextLen));
end;

{ Returns the name of the MS-Windows window class for a TStatic control. }

function TStatic.GetClassName: PChar;
begin
  GetClassName := 'Static';
end;

{ Transfers state information for TStatic controls. The TransferFlag passed
  specifies whether data is to be read from or written to the passed
  buffer, or whether the data element size is simply to be returned. The
  return value is the size (in bytes) of the transfer data. TStatic objects
  are different from other TControl objects in one key respect.  If the
  TStatic is created with InitResource then wb_EnableTransfer is False, else
  it is true.  This presupposes that if you are interested in creating a
  TStatic object directly, you probably want to be able to initialize it.
  This behavior can be modified with EnableTransfer/DisableTransfer.}

function TStatic.Transfer(DataPtr: Pointer; TransferFlag: Word): Word;
begin
  if TransferFlag = tf_GetData then
    GetText(DataPtr, TextLen)
  else if TransferFlag = tf_SetData then
    SetText(DataPtr);
  Transfer := TextLen;
end;

{ Fills the passed string with the text of the associated text
  control.  Returns the number of characters copied.  }

function TStatic.GetText(ATextString: PChar; MaxChars: Integer): Integer;
begin
  GetText := GetWindowText(HWindow, ATextString, MaxChars);
end;

{ Returns the length of the control's text }

function TStatic.GetTextLen: Integer;
begin
  GetTextLen := GetWindowTextLength(HWindow);
end;

{ Sets the contents of the associated static text control to the passed
  string. }

procedure TStatic.SetText(ATextString: PChar);
begin
  SetWindowText(HWindow, ATextString);
end;

{ Clears the text of the associated static text control. }

procedure TStatic.Clear;
begin
  SetText('');
end;

{ TEdit }

{ Constructor for a TEdit object.  Initializes its data fields using
  passed parameters and default values.   By default, an associated
  static control will have a border and its text will be left-justified.
  Also by default, an associated multiline edit control will have
  horizontal and vertical scroll bars. }

constructor TEdit.Init(AParent: PWindowsObject; AnId: Integer; ATitle: PChar;
  X, Y, W, H: Integer; ATextLen: Word; Multiline: Boolean);
begin
  TStatic.Init(AParent, AnId, ATitle, X, Y, W, H, ATextLen);
  Attr.Style := (Attr.Style and not ss_Left) or es_Left or
    es_AutoHScroll or ws_Border or ws_TabStop;
  if Multiline then
    Attr.Style := Attr.Style or es_Multiline or es_AutoVScroll or
      ws_VScroll or ws_HScroll;
  Validator := nil;
end;

{ Constructor for a TEdit that is to be associated with a Windows
  resource.  Identical to ancestral InitResource with the addition
  of an initialization for the Validator.
}
constructor TEdit.InitResource(AParent: PWindowsObject; ResourceID: Word;
  ATextLen: Word);
begin
  inherited InitResource(AParent, ResourceID, ATextLen);
  Validator := nil;
end;

{ Constructor for a TEdit object.  Initializes the object with data
  from the passed TStream. }

constructor TEdit.Load(var S: TStream);
begin
  TStatic.Load(S);
  Validator := PValidator(S.Get);
end;

{ Destroys an instance of TEdit by disposing of its Validator (if any),
  and then calling upon the inherited destructor to complete the process. }

destructor TEdit.Done;
begin
  SetValidator(nil);
  inherited Done;
end;

{ Returns the name of the MS-Windows window class for TEdits. }

function TEdit.GetClassName: PChar;
begin
  GetClassName := 'Edit';
end;

{ Only allows the Edit Control to be closed if it passes
  Validation.  Otherwise returns the focus to Self. }

function TEdit.CanClose: Boolean;
var
  OkToClose: Boolean;
begin
  OkToClose := inherited CanClose;
  if OkToClose then
    if IsWindowEnabled(HWindow) and not IsValid(True) then
    begin
      OkToClose := False;
      SetFocus(HWindow);
    end;
  CanClose := OkToClose;
end;

{ Returns a Boolean value indicating whether or not the last change to the
  text of the associated edit control can be undone.  }

function TEdit.CanUndo: Boolean;
begin
  CanUndo := SendMessage(HWindow, em_CanUndo, 0, 0) <> 0;
end;

{ Undoes the last change to the to the text of the associated edit
  control. }

procedure TEdit.Undo;
begin
  SendMessage(HWindow, wm_Undo, 0, 0);
end;

{ Pastes the contents of the clipboard into the text of the associated
  edit control. }

procedure TEdit.Paste;
begin
  SendMessage(HWindow, wm_Paste, 0, 0);
end;

{ Copies the text selected in the associated edit control to the
  clipboard. }

procedure TEdit.Copy;
begin
  SendMessage(HWindow, wm_Copy, 0, 0);
end;

{ Cuts the text selected in the associated edit control into the
  clipboard. }

procedure TEdit.Cut;
begin
  SendMessage(HWindow, wm_Cut, 0, 0);
end;

{ Responds to an incoming "Cut" command (with a cm_EditCut command
  identifier) by calling Self.Cut. }

procedure TEdit.CMEditCut(var Msg: TMessage);
begin
  Cut;
end;
    
{ Responds to an incoming "Copy" command (with a cm_EditCopy command
  identifier) by calling Self.Copy. }

procedure TEdit.CMEditCopy(var Msg: TMessage);
begin
  Copy;
end;

{ Responds to an incoming "Paste" command (with a cm_EditPaste command
  identifier) by calling Self.Paste. }

procedure TEdit.CMEditPaste(var Msg: TMessage);
begin
  Paste;
end;

{ Responds to an incoming "Delete" command (with a cm_EditDelete command
  identifier) by calling Self.Delete. }

procedure TEdit.CMEditDelete(var Msg: TMessage);
begin
  DeleteSelection;
end;

{ Responds to an incoming "Clear" command (with a cm_EditClear command
  identifier) by calling Self.Clear. }

procedure TEdit.CMEditClear(var Msg: TMessage);
begin
  Clear;
end;

{ Responds to an incoming "Undo" command (with a cm_EditUndo command
  identifier) by calling Self.Undo. }

procedure TEdit.CMEditUndo(var Msg: TMessage);
begin
  Undo;
end;

{ Returns the number of lines in the associated edit control.  Returns
  zero if an error occurs or if the edit control contains no text. }

function TEdit.GetNumLines: Integer;
begin
  GetNumLines := SendMessage(HWindow, em_GetLineCount, 0, 0);
end;

{ Returns the length of the line (whose number is passed) in the
 associated edit control.  If -1 is passed as the line number, the
 following applies: returns the length of the line upon which the caret
 is positioned; if text is selected on the line, returns the line length
 minus the number of selected characters; if selected text spans more
 than one line,  returns the length of the lines minus the number of
 selected characters. }

function TEdit.GetLineLength(LineNumber: Integer): Integer;
var
  StartPos: Integer;
begin
  StartPos := -1;
  if (LineNumber > -1) then
    StartPos := GetLineIndex(LineNumber);
  GetLineLength := SendMessage(HWindow, em_LineLength, StartPos, 0);
end;

{ Retrieves the text of the line of the associated edit control with the
  passed line number.  Return False if an error occurs or if the text will
  not fit in the passed buffer. }

function TEdit.GetLine(ATextString: PChar;
  StrSize, LineNumber: Integer): Boolean;
var
  BytesCopied: Integer;
begin
  if (StrSize >= GetLineLength(LineNumber) + 1) then
  begin
    PWord(ATextString)^ := StrSize;
    BytesCopied := SendMessage(HWindow, em_GetLine, LineNumber,
      LongInt(ATextString));
    ATextString[BytesCopied] := #0;
    GetLine := True;
  end
  else GetLine := False;
end;

{ Selects the text in the associated edit control which begins and ends
  at the passed positions. }

function TEdit.SetSelection(StartPos, EndPos: Integer): Boolean;
var
  LValue: LongRec;
begin
  LValue.Lo := StartPos;
  LValue.Hi := EndPos;
  SetSelection := SendMessage(HWindow, em_SetSel, 0, Longint(LValue)) <> 0;
end;

{ Returns, in the passed var parameters, the starting and ending
  positions of the text selected in the associated edit control. }

procedure TEdit.GetSelection(var StartPos, EndPos: Integer);
var
  RetValue: LongRec;
begin
  Longint(RetValue) := SendMessage(HWindow, em_GetSel, 0, 0);
  StartPos := RetValue.Lo;
  EndPos := RetValue.Hi;
end;

{ Returns a Boolean value indicating whether or not the user has changed
  the text in the associated edit control. }

function TEdit.IsModified: Boolean;
begin
  IsModified := (SendMessage(HWindow, em_GetModify, 0, 0) <> 0);
end;

{ Performs the actual validation of Self, returning True if Self
  is valid, and False if not, and setting the focus to Self if
  invalid.  Reports an error to the user if ReportError is True,
  otherwise just returns the validity to allow deferred reporting.
  Local method for use by all other methods which must validate.
  NOTE that validation is only performed for Edit Controls containing
  a single line of text. }

function TEdit.IsValid(ReportError: Boolean): Boolean;
var
  S  : string;
  Sz : array [0..255] of Char;
begin
  IsValid := True;  { Unless proven otherwise }

  if (Validator <> nil) and (GetNumLines <= 1) then
  begin
    if TextLen > High(Sz) then
      GetText(Sz, High(Sz))
    else
      GetText(Sz, TextLen);

    S := StrPas(Sz);

    if ReportError then
      IsValid := Validator^.Valid(S)
    else
      IsValid := Validator^.IsValid(S);
  end;
end;

{ Clears the change flag for the associated edit control. }

procedure TEdit.ClearModify;
begin
  SendMessage(HWindow, em_SetModify, 0, 0);
end;

{ Returns the number of the line of the associated edit control which
  contains the character whose position is passed.  If the position
  passed is greater than the position of the last character, the number
  of the last line is returned. If -1 is passed, the number of the line
  which contains the first selected character is returned. }

function TEdit.GetLineFromPos(CharPos: Integer): Integer;
begin
  GetLineFromPos := SendMessage(HWindow, em_LineFromChar, CharPos, 0);
end;

{ Returns the number of characters in the associated edit control that
  occur before the line whose number is passed.  If -1 is passed, the
  line number of the line upon which the caret is positioned is used. }

function TEdit.GetLineIndex(LineNumber: Integer): Integer;
begin
  GetLineIndex := SendMessage(HWindow, em_LineIndex, LineNumber, 0);
end;

{ Scrolls the text of the associated edit control by the specified
  horizontal and vertical amounts. }

procedure TEdit.Scroll(HorizontalUnit, VerticalUnit: Integer);
var
  LValue: LongRec;
begin
  LValue.Lo := VerticalUnit;
  LValue.Hi := HorizontalUnit;
  SendMessage(HWindow, em_LineScroll, 0, LongInt(LValue));
end;

{ Sets the selection of the associated edit control to the passed string.
  (Does a "paste" type of action without affecting the clipboard). }

procedure TEdit.Insert(ATextString: PChar);
begin
  SendMessage(HWindow, em_ReplaceSel, 0, LongInt(ATextString));
end;

{ Searchs for and selects the given text in the edit control and
  returns the offset of the text or -1 if the text is not found.
  If the StartPos = -1 then it is assumed that the start pos is
  the end of the current selection.
}
function TEdit.Search(StartPos: Integer; AText: PChar;
  CaseSensitive: Boolean): Integer;
var
  SText, Line, Pos: PChar;
  LineSize, LineLen, NumLines, CurLine, Offset, SBeg: Integer;
begin
  Search := -1;
  if AText[0] = #0 then Exit;
  Line := nil;
  LineSize := 0;
  if StartPos = -1 then GetSelection(SBeg, StartPos);
  if CaseSensitive then
    SText := AText else
    SText := AnsiLower(StrNew(AText));
  CurLine := GetLineFromPos(StartPos);
  Offset :=  StartPos - GetLineIndex(CurLine);
  NumLines := GetNumLines;
  while CurLine < NumLines do
  begin
    LineLen := GetLineLength(CurLine);
    if LineLen >= LineSize then
    begin
      if Line <> nil then FreeMem(Line, LineSize);
      LineSize := LineLen + 1;
      Line := MemAlloc(LineSize);
    end;
    if Line = nil then Exit;
    GetLine(Line, LineSize, CurLine);
    if not CaseSensitive then AnsiLower(Line);
    Pos := StrPos(@Line[Offset], SText);
    if Pos <> nil then
    begin
      SBeg := GetLineIndex(CurLine) + (Pos - Line);
      SetSelection(SBeg, SBeg + StrLen(SText));
      Search := SBeg;
      CurLine := MaxInt - 1;
    end;
    Offset := 0;
    Inc(CurLine);
  end;
  if Line <> nil then FreeMem(Line, LineSize);
  if not CaseSensitive then StrDispose(SText);
end;

{ Deletes the selected text in the associated edit control.  Returns
  False if no text is selected. }

function TEdit.DeleteSelection: Boolean;
var
  StartPos, EndPos: Integer;
begin
  DeleteSelection := True;
  GetSelection(StartPos, EndPos);
  if StartPos <> EndPos then
    SendMessage(HWindow, wm_Clear, 0, 0)
  else DeleteSelection := False;
end;

{ Deletes the text of the associated edit control between the passed
  positions.  Returns False if an error occurs. }

function TEdit.DeleteSubText(StartPos, EndPos: Integer): Boolean;
begin
  DeleteSubText :=
    SetSelection(StartPos, EndPos) and DeleteSelection;
end;

{ Deletes the text at the passed line number in the associated edit
  control.  If -1 is passed, deletes the current line.  Returns False
  if the line passed is out of range (and not -1) or if an error occurs. }

function TEdit.DeleteLine(LineNumber: Integer): Boolean;
var
  FirstPos, LastPos: Integer;
begin
  DeleteLine := False;
  if LineNumber = -1 then LineNumber := GetLineFromPos(GetLineIndex(-1));
  FirstPos := GetLineIndex(LineNumber);
  if FirstPos <> -1 then
  begin
    LastPos := GetLineIndex(LineNumber + 1);
    if LastPos = -1 then LastPos := FirstPos + GetLineLength(LineNumber);
    if (FirstPos = 0) and (FirstPos = LastPos) then
    begin
      SetText('');
      DeleteLine := True;
    end
    else
      DeleteLine := DeleteSubText(FirstPos, LastPos);
  end;
end;

{ Retrieves the text of the associated edit control between the passed
  positions. }

procedure TEdit.GetSubText(ATextString: PChar;
  StartPos, EndPos: Integer);
const
  cr_lf: PChar = #13#10;
var
  StartLine, EndLine, StartChar, EndChar: Integer;
  TempSize, TempIndex, TempStart, TempEnd: Integer;
  TempLine, TempLineLength: Integer;
  OkToContinue: Boolean;
  PLine: PChar;
begin
  if EndPos >= StartPos then
  begin
    StartLine := GetLineFromPos(StartPos);
    EndLine := GetLineFromPos(EndPos);
    StartChar := StartPos - GetLineIndex(StartLine);
    EndChar := EndPos - GetLineIndex(EndLine);
    TempIndex := 0;
    OkToContinue := True;
    for TempLine := StartLine to EndLine do
      if OkToContinue then
      begin
	TempLineLength := GetLineLength(TempLine);
        Inc(TempLineLength, 2); { Count the CR/LF }
        { Allocate memory for the line, leaving room for the terminating 0 }
	GetMem(PLine, TempLineLength + 1);
	if TempLine = StartLine then TempStart := StartChar
	else TempStart := 0;
	if TempLine = EndLine then TempEnd := EndChar
	else TempEnd := TempLineLength;
	TempSize := TempEnd - TempStart;
	if GetLine(PLine, TempLineLength + 1, TempLine) then
	begin
          StrCat(PLine, cr_lf); { Add back then CR/LF }
	  StrMove(@ATextString[TempIndex], @PLine[TempStart], TempSize);
	  TempIndex := TempIndex + TempSize;
        end
	else OkToContinue := False;
	FreeMem(PLine, TempLineLength + 1);
      end;
    ATextString[TempIndex] := #0;
  end;
end;

{ Stores data of the TEdit object in the passed TStream. }
procedure TEdit.Store(var S: TStream);
begin
  TStatic.Store(S);
  S.Put(Validator);
end;

{ Sets the given Validator object to be Self's validator.  Disposes
  of the current validator, if any. }

procedure TEdit.SetValidator(AValid: PValidator);
begin
  if Validator <> nil then Validator^.Free;
  Validator := AValid;
end;

{ The window belongs to us if any of the window handles has an object
  attached }

function IsOurs(Wnd: HWnd): Boolean;
begin
  while (Wnd <> 0) and (GetObjectPtr(Wnd) = nil) do
    Wnd := GetParent(Wnd);
  IsOurs := Wnd <> 0;
end;

{ Validates Self whenever the focus is about to be lost.
  Holds onto the focus if Self is not valid.  Checks first
  to make sure that the focus is not being taken by either
  (a) another app, or (b) a Cancel button, or (c) an OK
  button (in which case CanClose will validate); in each case,
  we don't want to validate. }

procedure TEdit.WMKillFocus(var Msg: TMessage);
var
  BtnId : Integer;
begin
  if ProcessFocus and IsOurs(Msg.WParam) then
  begin
    BtnId := GetDlgCtrlID(Msg.WParam);

    { Note that we do not allow IsValid to post the message
      box, since the change of focus resulting from that message
      will interfere with the change we are in the process of
      completing.  Instead, post a message to the Parent informing
      it of the validation failure, and providing it with a handle
      to Self. }

    if (BtnId <> id_Cancel) and (BtnId <> id_Ok) and not IsValid(False) then
    begin
      DefWndProc(Msg);
      ProcessFocus := False;
      PostMessage(Parent^.HWindow, wm_PostInvalid, HWindow, 0);
      Msg.Result := 0;
      Exit;
    end
  end;
  DefWndProc(Msg);
end;

{ Validates Self whenever a character is entered.  Allows
  the character entry to be processed normally, then validates
  the result and restores Self's text to its original state
  if there is an incorrect entry.

  By default, the SupressFill parameter of the IsValidInput
  method call to the Validator is set to False, so that it
  is free to modify the string, if it is so configured. }

procedure TEdit.WMChar(var Msg: TMessage);
var
  S         : string;
  Sz, OldSz : array [0..255] of Char;
  Len       : Integer;
  StartPos, EndPos: Integer;
  WasAppending: Boolean;
begin
  if (Validator <> nil) and (GetNumLines <= 1) and
    (Msg.wParam <> vk_Back) then
  begin
    Len := TextLen;
    if Len > High(OldSz) then Len := High(OldSz);
    GetText(OldSz, Len);
    GetSelection(StartPos, EndPos);
    WasAppending := EndPos = StrLen(OldSz);

    DefWndProc(Msg);      { Process the new char ... }

    GetText(Sz, Len);
    S := StrPas(Sz);      { Validator expects a Pascal string }

    { Run the result of the edit through the validator.  If incorrect,
      then restore the original text.  Otherwise, set the (possibly)
      modified result of the validation back into the edit control,
      so the results of the auto-fill (if any) can be viewed.
    }
    GetSelection(StartPos, EndPos);
    if (Validator^.Options and voOnAppend = 0) or
      (WasAppending and (EndPos = StrLen(Sz))) then
    begin
      if not Validator^.IsValidInput(S, False) then
        SetText(OldSz)
      else
      begin
        StrPCopy(Sz, S);
        SetText(Sz);
        if (StartPos >= StrLen(OldSz)) and (StrLen(Sz) > StrLen(OldSz)) then
          StartPos := StrLen(Sz);
        if (EndPos >= StrLen(OldSz)) and (StrLen(Sz) > StrLen(OldSz)) then
          EndPos := StrLen(Sz);
      end;
      SetSelection(StartPos, EndPos);
    end
    else
    begin
      if EndPos = StrLen(Sz) then
        if not Validator^.IsValidInput(S, False) then
          Validator^.Error;
    end;
  end
  else
    DefWndProc(Msg);
end;

{ Responds to the GetDlgCode query according to the
  current state of the control.  If the edit control
  contains valid input, then TABs are allowed for
  changing focus.  Otherwise, requests that TABs be
  sent to Self, where we will generate the Invalid
  message (See WMKeyDown below). }

procedure TEdit.WMGetDlgCode(var Msg: TMessage);
begin
  DefWndProc(Msg);
  if not IsValid(False) then
    Msg.Result := Msg.Result or dlgc_WantTab;
end;

{ If the TAB key is sent to the Edit Control, check
  the validity before allowing the focus to change.
  The control will only get a TAB if WMGetDlgCode (above)
  allows it, which is done when the control contains
  invalid input (we re-validate here just for completeness,
  in case descendants redefine any of this behavior).

  We need to validate on TAB focus-changes because there
  is a case not handled by WMKillFocus: when focus is
  lost ts        end orator.  IflgpEdes8 contocus is
  lostDyo modify t= St handled by WMKillFocus: when focus is
  lost ts        end orator.  IflgpEdes8 contocus is
  lostDyo modify t= St handled by WMKillFocus: when focus is
  lost ts        end orator.  IflgpEdes8 contocus is
  lostDyo modify t= St handled by WMKillFocus: when focus is
  lost tscess the 'rocess of
 <> 0;
e
  4lPato
{ Re
 }
procedure Tr.  ;of the associated es is
 reservedlPatonpuDp, or (b)rst
  to maatoCo tSDp, or (b)r=r TempLiatot= St Dp, or (b)=inue theatoNOcess otate
  if there aton
 tLi    if not V8here atoNOt.SetValidatorSelectionatoBYratLIG:= at th=empSize,atoBYratLIG:f
 <> =LineLengatoGLOB
o tS Msg.ResneLeing foGlobalit contrco moe[TempStaSpecialiCre   t], Temposd;
e v     St haWput, VaAU thenEQen(SzpLineLengmpStat], Teodify t= ( ishigh words)ngmpSWtonVERL #13 each cae;
	FrS_: TMes= 1) anh cCe;
	FrS_ndex(EndLine);0pLineLerS_ing tTABs are allowneLerS_ich is done wSelectneLerS_VISIStatic.Stif theneLerS_ StartPos then0V8here rS_i
  SIStledSr=r Temere rS_i
  ing t Stt
  toneLerS_ihe control wus isere rS_iAPTan objectr objeLeing  forS_ =  >  |orS_
  FineEe rS_ =  >  procedure TrneLerS_   FineEfocus is
 neLerS_Vding: Booleacess tneLerS_, EndPos: Intus: whneLerS_    begin
	Tem0;
beginS_THICKFineEfocem0;
4eLerS_,s is
  lostem0;
2eLerS_Vs is
  lostem0;
1eLerS_GROx(EndLine);0;
2eLerS_TALinOcessed norm
1eLerS_ich is dBOXe);0;
2eLerS_ihe contBOXe);0;
      ;cenda
e t], TempSy t= SpSWtonVERL #13 f
 <> =LWtonVERL #13 e+ rS_iAPTan o+ rS_    begi+ rS_THICKFineEf+ rS_ich is dBOXe+ rS_ihe contBOX	FrS_ndex(en TempStarS_ndex(E+orS_ =  >  + rS_    begLerS_ing ten TempStarS_ing tLerS_T
  ten TempStarS_nVERL #13 f
 <> SpSWtoT
  tEndLine);rS_nVERL #13 	FrS_: TMesndLine);rS_StrMove(@ArS_ ontBOXe)ine);rS_THICKFineE    ;cExtended t], TempSy t= (lTemwords)ngrS_EX_   ocuALFineEfous: whngrS_EX_ geOBJ vk_Backcess tngrS_EX_NOhen restore t is
 ngrS_EX_nOcMOnd (BtnId <> i08LengmpStapredefined clipboardnd omat= St haF_Self's valida8 contCGetLineIndex(Start2ntCGeM  (
  PICe Inv3ntCGeSYit threx(Start4ntCGer
  changingart5 haF_SIF
  changinart6 haF_OEMSelf's valart7ntCGerB  changingart8ntCGe StrLen(Sgingart9ntCGe forATAcheck
  0ntCGeRIF
  changinar1ontCGeWA[TempIndex]ar12LengC   EndChISPLA t i8Leing    foowner displayntCGerSPSelf's valaridiing    fodisplay textntCGerSPtLineIndexari2iing    fodisplay bitmapntCGerSPM  (
  PICe xari3h   fodisplay metafilengmpStaPthe ediclipboardnd omat rang  St haGe Rdled ldSz);
    Ge2eLeing    foAnything ins iis rang  doesn't haGe Rdled r.  If incorre2ffeing    fogetoGlobalFree'd haGeGDIOBJtores Self's   ieLeing    foAnything ins iis rang  gets haGeGDIOBJrocedure TEdi  iffeing    foDeleteObject'edlPlPlPMAKEn(OereOURCE MAEnd a
ure TEdimov TEdiax,a
ure TEdix orTEdidx,dx
ure TEdiforMTempStarPredefined resource typt= St hRT_  Checks firsar1 associated es; must be p moed through MAKEn(OereOURCE hRT_tLineIndex(Star2 hRT_hich case Ca
  is RT_idator <> nil) 4s RT_Message);
var5s RT_   t message
 6s RT_ alledissage
 7s RT_ all(we re-validatRT_ACe f> STeckspleteRT_RCrATAcheck
  0nt St**ocuTE: if any new resource typt= are introduced aboves iis point,s isns ie St**ov     of r
FEn rCE must be chang d. St**o(RT_GROx(_  Check- RT_  Chec) must always be   calito r
FEn rCE St**o(RT_GROx(_hich - RT_hich) must always be   calito r
FEn rCE S
r
FEn rCE (Sgingartr1ontteRT_GROx(_  CheckgartrRT_  Check+ r
FEn rCE SRT_GROx(_hich  kgartrRT_hich + r
FEn rCE S S S S    Validos lPM  Otherw   Uvk_Backstruc
ure szyo modwe re-vadd ?
ure szTitledwe re-vadd ?
ure hOwner dwe re-vadw ?
ure xe associated esdw ?
ure ye associated esdw ?
ure cxcassociated esdw ?
ure cycassociated esdw ?
ure ify tsociated esdd ?
M  Otherw   Uvk_ets re ha at tOtherw   Uvk_Bstruc
ure ht], TeMenued esdw ?
ure idFirstChi
  esdw ?
a at tOtherw   Uvk_ets rethe contr;lidos lPlPlP StrLent tR  SetTextstruc
ure peRe
  esated esdb ?
ure peGreenesated esdb ?
ure peB    esated esdb ?
ure peFlagodwe re-vadb ?
 StrLent tR  SetTextets re h; LogicaliPalette Ssag StrLen(SgingTextstruc
ure palVen 
e ed esdw ?
ure palNumEntrieodwedw ?
ure palPalEntryre-vadb ?es; array of  StrLent tR  Ssag StrLen(SgingTextets re h; (var Msg   Uvk_d orownerdraw
rvar Msg   Uvk_gTextstruc
ure drCtlTyptciated esdw ?
ure drCtlItring;
  Ssdw ?
ure dritemItring;
  Sdw ?
ure dritemAct
e ed esdw ?
ure dritemSs     ed esdw ?
ure drhwndItemng;
  Sdw ?
ure drhDp, or (b)rst Sdw ?
ure drrcItemng;
  S  DB selowR vk_dup(?)
ure dritemDataiated esdd ?
rvar Msg   Uvk_ets re h; ( f>Tge of   Uvk_d orownerdraw
r f>Tge of   Uvk_extstruc
ure deCtlTyptciated esdw ?
ure deCtlItring;
  Ssdw ?
ure deitemItring;
  Sdw ?
ure dehwndItemng;
  Sdw ?
ure deitemDataiated esdd ?
r f>Tge of   Uvk_ets re h; MEASURge of   Uvk_d orownerdraw
MEASURge of   Uvk_xtstruc
ure meCtlTyptciated esdw ?
ure meCtlItring;
  Ssdw ?
ure meitemItring;
  Sdw ?
ure meitemWidteing    dw ?
ure meitemHeightng    dw ?
ure meitemDataiated esdd ?
MEASURge of   Uvk_ets re h; y [hen e of  Uvk_d orownerdraw sorting
a [hen e of   Uvk_xtstruc
ure coCtlTyptciadw ?
ure coCtlItring;dw ?
ure cohwndItemngdw ?
ure coitemIt1ng;dw ?
ure coitemData1add ?
ure coitemIt2ng;dw ?
ure coitemData2add ?
a [hen e of   Uvk_xtets re h; Owner draw control typt= SODT_idator <> 8 contODT_LISTBOXe)iart2ntODT_a [BOBOXe); is ODT_pEdes8 conart4nt h; Owner draw act
e= SODAz);
t tdit to vaODAz <> vk_Back=t2ntODA_ aCUS<> nil) 4s  h; Owner draw ts   ntODSz <> vk3 each cae    ODSzGRAYPos then0V
2eLeODSz StartPos t is
  loODSzCHECKE StrLen(
begiODSz aCUS<> nil)  whneLepStaPeekMIflgpEescOpt
e= SPMt Coen);
   ;0;
h SPMtoen);
   ach cae    PMt CYIELos then0V
2eLepStaSett], TePos FlagoMKilPt CSs done whe=es ie    ilPt Cn);
    Ge=es ie2   ilPt CZ=  >  proc=es ie4   ilPt Cs is
  los=es ie8   ilPt Cmessage (Se=es is
  ilPtis
FineEfocu=es i2
  ilPtlost ts    cu=es i4
  ilPtdefi ts    cu=es i8
  ilPtNOt   tLi    =es sere ilPt Cs PCSsTan o=es 2ineLeng      ValidatoMESSAGESre h; Listbox  IflgpEdesLB_ADD   t messagefocu=e(input, +1)esLB_INt, T   t messagef=e(input, +2)esLB_r f>Tg   t messagef=e(input, +3)esLB_ereETts  Ell(we re-v=e(input, +5)esLB_eET <>dInput(S, False)(input, +6)esLB_eET  Ch<>dInput(S, Fe)(input, +7)esLB_GET <>dInput(S, False)(input, +8)esLB_GET  Ch<>dInput(S, Fe)(input, +9)esLB_GETSelf's validafocu=e(input, +10)esLB_GETSelfLEh case Ca
u=e(input, +11)esLB_GET OUll(we re-vaa
u=e(input, +12)esLB_eE> vk   t messagef=e(input, +13)esLB_edissagewe re-vaa
u=e(input, +14)esLB_GETSOPts EX re-vaa
u=e(input, +15)esLB_Fts    t messagefoc=e(input, +16)esLB_GET <> OUll(we re-va=e(input, +17)esLB_GET <>e of (we re-va=e(input, +18)esLB_eETTALinOc (we re-va=e(input, +19)esLB_GETHORIZs  StrXTt th=e(input, +20)esLB_eETHORIZs  StrXTt th=e(input, +21)esLB_eETTOPts EX re-vaa
u=e(input, +24)esLB_GETe ofR vk_Backaa
u=e(input, +25)esLB_GETe ofrATAcheck
u=e(input, +26)esLB_eETe ofrATAcheck
u=e(input, +27)esLB_eE>e ofRFalsheck
u=e(input, +28)esLB_eETCen Tts EX re-vaa=e(input, +31)esLB_GET en Tts EX re-vaa=e(input, +32)es    Validator^.ELB_eETe ofHEIGH);
    Ge(input, +33)esLB_GETe ofHEIGH);
    Ge(input, +34)esLB_Fts    t mEXAvk_Back=t(input, +35)esthe contrthe con;lidatoMESSAGESre h; Listbox pSy t= SLBtoNOore t, or (b)rst
  e    LBtohecf's validafocuen0V
2eLeLBtoNOs is
  lost tst is
  loLBtoMU tIPLEh<>dInput(en(
begiLBto EndChs
FIXE StrLen(s
  LBto EndChs
VARIartPt
  to maLBtoH tS  t m    if not Vi4
  LBtout,TALinOc (we re-=inue theLBtoNOn(OEGRALHEIGH);if there LBtoMU tICOLUM8 contocus 2here LBtoWANTcesBOAChINPUTe allowre LBtorXTt DEDh<>dInput(en(8owre LBtoSTAorARtring;
  S= LBtoNOore t+ LBtohecf'+ rS_Vding: B+orS_ =  > e LBto StartP CSEndPos: =empSize, h; Listbox No: whcat
e Codt= SLBN_ERRSPACE (Sgin=es(-2)esLBN_eE>CHFalsheck8 contLBN_
{ Re
changingart2esLBN_eE>CArCELngingart3esLBN_eET aCUS<> nil)  4s LBN_KILL aCUS<> niart5 h      ValidatoMESSAGESre h; Edit Control MIflgpEdesEM_GET <>dInput(S, False)(input, +0)esEM_eET <>dInput(S, False)(input, +1)esEM_GETR vk_Backaa
ugef=e(input, +2)esEM_eETR vk_Backaa
ugef=e(input, +3)esEM_eETR vkN(EndLine)ef=e(input, +4)esEM_eEndPos: Int(we re-v=e(input, +5)esEM_tleEeEndPos: Int(we e)(input, +6)esEM_GETocure t, or (b)rse)(input, +8)esEM_eETocure t, or (b)rse)(input, +9)esEM_GETtleE OUll(we re-v=e(input, +10)esEM_tleEts EX re-vaa
u
u=e(input, +11)esEM_eETHFaDtatic.Stvaa
u=e(input, +12)esEM_GETHFaDtatic.Stvaa
u=e(input, +13)esEM_tleEtP GTHic.Stvaa
u=e(input, +17)esEM_s PLACE <>dInput(S, =e(input, +18)esEM_eET all(we re-vae-va=e(input, +19)esEM_GETtleE_Backaa
ugef=e(input, +20)esEM_tlMITSelf's validafo=e(input, +21)esEM_CArUs  _Backaa
ugef=e(input, +22)esEM_Us  _Backaa
ugefef=e(input, +23)esEM_FMTtleE (we re-vaa
u=e(input, +24)esEM_tleEFROMCHFissagewe=e(input, +25)esEM_eETW=  Bthe
changingar(input, +26)esEM_eETTALinOc (we re-va=e(input, +27)esEM_eETP tSW=  CHFissage=e(input, +28)esEM_EMPTYUs  BU
FEnssage=e(input, +29)es    Validator^.EEM_GETtoresVISIStatleE_=e(input, +30)esEM_eETtheDONL t, or (b)=e(input, +31)esEM_eETW=  Bthe
PROC-vaa=e(input, +32)esEM_GETW=  Bthe
PROC-vaa=e(input, +33)esEM_GETP tSW=  CHFissage=e(input, +34)esthe contrthe con;lidatoMESSAGESre h h; Edit Control pSy t= (lTemword)estS_LEFl(we re-vaa
u=e0;
h StS_Ct tEissagewe r
  e    tS_RIGH);
    ocuen0V
2eLeEtoMU tItleE_Backaa is
  loEtoU#13RCASE_Backaa is
8 loEtoLOW3RCASE_Backaa is1
h StS_P tSW=      ocuen0V2
h StS_AUTOVding: Bf not Vi4
  tS_AUTOHding: Bf not Vi8
  tS_NOdefih<>dInput(en(1
h StS_OEMts VERf's valarllowre     Validator^.EES_RheDONL t, or (ben(8owre EtoWANTn TURNheck
  0owre Ehe contr h; Edit Control No: whcat
e Codt= SEN_eET aCUS<> nilt(en(1
h StN_KILL aCUS<> niocus 2here tN_CHFalsheck niocus 3here tN_UPDge (Sek niocus 4here tN_ERRSPACE (Sginocus 5here tN_MAXSelf's valida8  5h1re tN_Hding: Bf nolida8  6h1re tN_Vding: Bf nolida8  6h2eLepS    ValidatoMESSAGESre h; Butt
e Control MIflgpEdesBM_GETCHECK(S, False)(input, +0)esBM_eETCHECK(S, False)(input, +1)esBM_GET Tge (Sek ni=e(input, +2)esBM_eET Tge (Sek ni=e(input, +3)esBM_eET TYtatic.Stva=e(input, +4)estrthe con;lidatoMESSAGESre h; Butt
e Control pSy t= (lTemword)esBtoPUSHpEdes8 connot VihesBto VaPUSHpEdes8 coen(1hesBtoCHECKBOXe)i niocus 2hesBtoAUTOCHECKBOXe)i us 3hesBtoRADIOBEdes8 connus 4hesBto3 Tge (Sek nida8  5hesBtoAUTO3 Tge (Sek 8  6hesBtoGROx(BOXe)i niocus 7hesBtout, pEdes8 connot V8hesBtoAUTORADIOBEdes8 t V9hesBto EndChs
)i niocus BhesBtoLEFlSelf's validGe2eze, h; User Butt
e No: whcat
e Codt= SBN_a aCKE StrL niocus  SBN_PAIll(we re-vae-to vaBN_HI>e owe re-vae-to2vaBN_UNHI>e owe re-va  is BN_
StartPor <> nil) 4s BN_
OUrtPa aCKE Str=t5 h  ; (ialog pSy t= (lTemwords)esDSzALiALIGh case Caen(1hesDSz YSocuA Bf nolidus 2hesDtoLOCStrDI);
    Ge2ezes;/* Edit items get LocalistorgpE. */esDSz ET all(we re-va) 4ezes;/* User spec whe
 font_d orDlg controls */esDSzocuA FineEfocuvalidezes;/* Can be combined witeirS_CAPTan o */esDSzNOnDtaMSmessage
 1
hs;/* inpt tEinDta  IflgpE will not be sent_*/espS    ValidatoMESSAGESre h; (ialog box  IflgpEdesDM_GET VaItring;
 e)(input, +0)esDM_eET VaItring;
 e)(input, +1)estrthe c
 ;idatoMESSAGESre h; (ialog Codt= SDLGCoWANTARROWS<> niar  e  > ni;  /* Control want= arrTemkeyodwe re-va*/esDLGCoWANTTAL    ocuen0V
2e> ni;  /* Control want= tabmkeyodwe re-vava*/esDLGCoWANTALLcesSckaa is
  > ni;  /* Control want= all keyodwe re-vava*/esDLGCoWANTMESSAGEckaa is
  > ni;  /* P mod IflgpE to control e re-vava*/esDLGCoH tSET <>dInput is
8 > ni;  /* Unden tats  EM_eET <>d IflgpE ava*/esDLGCo VaPUSHpEdes8 c is1
h> ni;  /* Default pushbutt
e ackaa
ugefef*/esDLGCoU  VaPUSHpEdes8n0V2
h> ni;  /* Non-default pushbutt
e ackaa
uge*/esDLGCoRADIOBEdes8 cont Vi4
> ni;  /* Radio butt
e ackaa
ugefefe-vava*/esDLGCoWANTCHFiS<> nil)  w8
> ni;  /* Want inpCHFis IflgpEdefefe-vava*/esDLGCo TgeIp, or (b)ren(1
h> ni;  /* Ss  ic item: don't includtciated */esDLGCopEdes8 conno   Ge2e
h> ni;  /* Butt
e item: can be checke
  esat*/espS; yombo Box return Va   = SCB_OKA t, or (b)rarts  SCB_ERR(we re-vae-toes(-1)esCB_ERRSPACE (Sgin=ess(-2)espS; yombo Box No: whcat
e Codt= SCBN_ERRSPACE (Sgitoes(-1)esCBN_eE>CHFalshecktoes1esCBN_
{ Re
changintoes2esCBN_eET aCUS<> nitoes3esCBN_KILL aCUS<> ntoes4 SCBN_EDI)CHFalshectoes5 SCBN_EDI)UPDge (Setoes6esCBN_
ROP   8 connus  7espS; yombo Box sSy t= (lTemwords)esCBtohIMPtatic.Stvaa
u=e  e    CBto
ROP   8 connocuen0V
2eLeCBto
ROP   8LISTnocuen0V
3eLeCBto EndChs
FIXE Str is1
h SCBto EndChs
VARIartPn0V2
h SCBtoAUTOHding: Bf nolt Vi4
  CBto EMts VERf's valot Vi8
  CBtohecf's validafocuen(1
h SCBtoH tS  t m    if nus 2here CBtoNOn(OEGRALHEIGH);us 4here pS    ValidatoMESSAGESre h; yombo Box  IflgpEdesCB_GETEDI) <>dInput(S, Fae)(input, +0)esCB_tlMITSelf's validafo
 e)(input, +1)esCB_eETEDI) <>dInput(S, Fae)(input, +2)esCB_ADD   t messagefocuni=e(input, +3)esCB_r f>Tg   t messagefva=e(input, +4)esCB_edissagewe re-vaa
u-v=e(input, +5)esCB_GET OUll(we re-vaa
ue e)(input, +6)esCB_GET  Ch<>dInput(S, F Fe)(input, +7)esCB_GETLBSelf's validafo
 e)(input, +8)esCB_GETLBSelfLEh case Ca
u=e(input, +9)esCB_INt, T   t messagef-v=e(input, +10)esCB_ereETts  Ell(we re-v
u=e(input, +11)esCB_Fts    t messagefoc
u=e(input, +12)esCB_eE> vk   t messagef
u=e(input, +13)esCB_eET  Ch<>dInput(S, F
u=e(input, +14)esCB_eost
ROP   8 connocueu=e(input, +15)esCB_GETe ofrATAcheck
uoc=e(input, +16)esCB_eETe ofrATAcheck
u
u=e(input, +17)es    Validator^.ECB_GET
ROPPEDts  ng:R vk_=e(input, +18)esCB_eETe ofHEIGH);
    va=e(input, +19)esCB_GETe ofHEIGH);
    va=e(input, +20)esCB_eETEXTt DEDUI validafo=e(input, +21)esCB_GETEXTt DEDUI validafo=e(input, +22)esCB_GET
ROPPED Tge (Sek n=e(input, +23)esCB_Fts    t mEXAvk_Back
u=e(input, +24)esEhe contrthe c ;lidatoMESSAGESre h; Ss  ic Control sSy t= (lTemword)esSS_LEFl(we re-vaa
u=e0;hesSS_Ct tEissagewe r
 1hesSS_RIGH);
    ocuen02hesSS_ICO8 connocueui us 3hesSS_BLACKR vk_Backaaus 4hesStoGRAYR vk_Backaa
8  5hesStoWHe oR vk_Backaaus 6hesSS_BLACKFineEfocuvali 7hesStoGRAYFineEfocuvaot V8hesStoWHe oFineEfocuvali 9hesStohIMPtatic.Stvaa
us BhesSS_LEFlida=  WRAPa
us ChesSS_NOPRVaIXe)i niocus8
> ni; Don't do "&" character translat
ee pS    Validator^.E    ValidatoMESSAGESre h;Ss  ic Control MIflgpEdesSTM_eETICO8 connocue)(input, +0)esSTM_GETICO8 connocue)(input, +1)esEhe conEhe contr; Scroll Bar pSy t= (lTemword)esSBtoHORZackaa
ugefefe-vava=e0;
h SSBtoVERf's valogefefe-vava=e0;1h SSBtonOcALIGh case Caconnocuen0V
2eLeSBtoLEFlALIGh case Caconnocun0V
2eLeSBtoBOdesMALIGh case Caconno is
  loSBtoRIGH)ALIGh case Caconnoc is
  loSBtoSIZEBOXnOcLEFlALIGh casen0V
2eLeSBtoSIZEBOXBOdesMRIGH)ALIGh  is
  loSBtoSIZEBOXvalogefefe-vava=e0;8re pS    Valid YSoETtICSre h; GetSystemMetrics() codt= SSnpCXdinEEh case Ca
unus 0 SSnpCYdinEEh case Ca
unus 1 SSnpCXVding: Bf nolidagart2esSnpCYHding: Bf nolidagart3esSnpCYCAPTan o  nolidagart4 SSnpCX =  >  case Ca
unus 5esSnpCY =  >  case Ca
unus 6 SSnpCXDLGFineEfocuvaounus 7esSnpCYDLGFineEfocuvaounus 8esSnpCYVTHUML    ocueounus 9 SSnpCXHTHUML    ocueounus 10 SSnpCXICO8 connocueui nus 11 SSnpCYICO8 connocueui nus 12esSnpCX  ChO  case Ca
unus 13esSnpCYC ChO  case Ca
unus 14 SSnpCYMENU connocueui nus 15esSnpCXFULLdinEEh case Cus 16 SSnpCYFULLdinEEh case Cus 17esSnpCYKANJIato   case Cus 18esSnpMOut,PereEll(we re-us 19esSnpCYVding: Bf nolidagart20 SSnpCXHding: Bf nolidagart21 SSnpDEBUmessagefocunigart22esSnpSWAPpEdes8 conno   Ge 23esSnpereERVED1gefocunigart24esSnpereERVED2gefocunigart25esSnpereERVED3gefocunigart26esSnpereERVED4gefocunigart27esSnpCXMIh case Caconnoc i 28esSnpCYMIh case Caconnoc i 29 SSnpCXSIZEcase Caconnoc i 30 SSnpCYdIZEcase Caconnoc i 31 SSnpCXFineEfocuvaounnoc i 32esSnpCYFineEfocuvaounnoc i 33esSnpCXMIhTRACK(S, Falsc i 34 SSnpCYMIhTRACK(S, Falsc i 35pS    Validator^.ESnpCXDOUrtPa 
changingart36 SSnpCYDOUrtPa 
changingart37esSnpCXICO8SPACt messageart38esSnpCYICO8SPACt messageart39 SSnpMENU
ROPALIGhMEll(wart40 SSnpPENato    (we re-va=e 41 SSnpDBCeElartPtring;
 e) 42onEhe conSnpCoETtICSMAXring;
 e) 43estrthe c
 ;id YSoETtICSre h    VallidCOLORre hCOLOR_eEndPoBFissageweiocus  SCOLOR_BACKGROxN StrL nioc-to vaCOLOR_AvkIVECAPTan o  nolito2vaCOLOR_INAvkIVECAPTan o  no  is COLOR_MENU connocueui nnil) 4s COLOR_ato   case Ceui nnil) 5s COLOR_ato   FineEfocuvaounus6s COLOR_MENUSelf's validafo
= 7esCOLOR_ato   Self's validaf= 8esCOLOR_CAPTan Self's valida8 9vaCOLOR_AvkIVE =  >  case Ca= 10 SCOLOR_INAvkIVE =  >  case = 11 SCOLOR_APPa= KSPACE (Sginocus12vaCOLOR_HIGHLIGH);
    ocuen1is COLOR_HIGHLIGH)Self's vali= 14 SCOLOR_BTNFACE (Sginoc vali= 15s COLOR_BTNSHA   case Ceui n= 16 SCOLOR_GRAYSelf's validafo
= 17esCOLOR_BTNSelf's validafo
 e)18es    Validator^.ECOLOR_INAvkIVECAPTan Self'= 19esCOLOR_BTNHI>eGH);
    ocu=t20 SEhe conEhe c
 ;idCOLORre h; yommats  to p modWinHelp()esHELP_Cn Self's v=  e  > ;/* Display topic in ulTopic */esHELP_QUI);
    G0V
2e> ;/* Terminate help */esHELP_to EX
    G0V
3 > ;/* Display index */esHELP_HELPONHELP G0V
4 > ;/* Display help 
e using help */esHELP_eETIo EX
 G0V
5 > ;/* Set the current_Index d ormulti index help */esHELP_ces
    ocu=(1  > ;/* Display topic d orkeyword in offabData_*/espS    ValidCOMMespSNOPARIT t, or (bens 0 SODDPARIT t, or (toes1esEVENPARIT t, or toes2esMARKPARIT t, or toes3esSPACEPARIT t, ortoes4 S SONg  OPBI);
   ens 0 SONE5  OPBI)S<> ntoes1esTWO  OPBI)S<> n toes2espS GNORatic.Stvaa
uss 0Stvaa
; /* Ignore signal e r OPBda8 9 Ca
oes3esSPACEPARInptoes¬Y SOD9(M
EL    o fO8es     Eate help */esH HELPONHELOD9(M
EL   cs() fo=e(inprec-vass 5esSnpCY =  >AllocMHELO h; B22)GFineEfocuvaPMHELO h;Rec.Stvaa
ussPvaPMHELO h;Rec.Ste signal AllocMHELO h;eoun
h>SoETtICSB22)aounus 8esnput, +16)esCB_PeounMemAlloc(, +22) 9 1OPPE2e(input,ICSPaoun
h>) codt= SSn, +16)esCB_B_P^.Counwre E+22);)esCB_B_AllocMHELO h;eounP;)esCB_re h;Ss eET aCUS<> nitI)S<> ntoeFreeMHELO h; PvaPMHELO h;Recere tN_MAXSelf'sPaoun
h>) codeFreeMem(P, (P^.Counwr9 1OPPE2e(in h; (ialog Cn0V rouu=ee5  OPBI)S<> ntoeRN_MesCrODe rogse re-vae-to2va_MesCrType(RDe roge(inpuva_MesCrType(RDlg Ca
une(inpuva_MesCrType(RlTemwore(inpuva_MesCrType(RBu<> ne(inpuva_MesCrType(RlheckELPe(inpuva_MesCrType(RRadioBu<> ne(inpuva_MesCrType(RGroupELPe(inpuva_MesCrType(RsH HELPe(inpuva_MesCrType(RlTwe re-e(inpuva_MesCrType(R1esTWO  Oe(inpuva_MesCrType(R1dafice(inpuva_MesCrType(Rn(1he(in h; (ial h;es8üCt, fo=e(inprec-vass 5esSnRRa.5pELPbe(iata_*iS<> nil)  w8
> ni;  /* Want iWant iWant iWant iWant iWant iWant p	vae-thes=loelf'sPaouny1 r7adi unsupporss 5esT t, or Pv  /LOR_eEndPoBFs4 SCB_ERR(we Invalid rTyunsupporss 5i 5esS() fopELP4 SSnpCX = oBFs4 S2B_ERR(we , fo=e(AlPaody OpeDLGCo TgeIp() fopENLP4 SSnpCX =oBFs4 S3B_ERR(we , fo=e(ET  OpeDLGCo TgeIpgeIp() fopEMEMOR  ens 0 SONE4 S4B_ERR(we UnablDLGCoCoHeEfO hq(RRasgeIp() fopEoesAUL signal e r4 S5B_ERR(we esCrTyes2ava*/esDL comh>)rsIp() fopEesDDWARS<> ntoes44 SC0)ERR(we Hardware(ET  PreaItrigeIpgeIp() fopEB9esalsc i 34oes44 SC1)ERR(we IllegL  ByO hSizreturn VpgeIp() fopEBAAXrh; Ss  ioes44 SC2)ERR(we Unsupporss 5BaudRfO hn VpgeIp() ffocuvvItrs  OPICS/esDLsPvaPMHELO h;Rec.Ste sAny C8 connocur aCUS<deFreeMe() fOPICSFLA IflgpEdest, +16)esCB_PeounMemAd certaes2O8 connocuMe() fOPITXEMPn toes2espS  SSn, +16)esT)(inmittpe(RRadEmpwreeFreeMe() fOPICY SOD9(ounP;)esCB_re h;Ss eECY SO8 ngAd f*O hn VpgeIpeMe() fOPIDe rOD9(ounP;)esCB_r_MAXSelf'De rO8 ngAd f*O hn VpgeIpeMe() fOPInpuvaPE2e(in h; (ialog Cn0V npuvaO8 ngAd f*O hn VpgeIpeM() fOPIvaPMHELO h;Recere tNsCrType(RvaPMHEr aCUS<deFreeMeVpgeIpeM() fOPIgitoes(-1)esCType(RlTemwore(iLine f*Ous<> ntoeocbData 5esT t,OPInput, +15)esCLPe(inpuva_MesCrRI)S<(M
EL  dh>) codeFreeMem(T t,OPIPgitoes(-1)espuva_MesCrType(RPrinnocu> ntoeocbDaodeFreeMem() fOPICY TtICSre h    e(R1esTWO  OeCY Sf*O hn VpgeIpeMepgeIpeMe() fOPIDe TtICSre h    e(R; (ial h;eDe rf*O hn VpgeIpeMepgeIpeMe() fOPInpuvTtICSre h<> nil)  w8
> nnpuvaf*O hn VpgeIpeMepgeIpeM() fOPInI)ST hn Vpge<> ni2)  w8
> nnI)S<T)(ilI)S<Edge/espUS<>toe() ffofocuvscWan Funct, +f noETXOFF(iata_*iS<> nil  be checke
ilid*O hXOFF(r aCUS<deFreeMe() foETXOsSnpCYDLGFineEni2  be checke
ilid*O hXONEr aCUS<deFreeMeV() foETRY SOD9(ounP;)esCB3  be checke
in RY Shighuva_MesCrType(RlTwe reLRRY SOD9(ounP;)esCB4  be checke
in RY Seoun
h>SoEsCrType(RlTwe roETDTtoes(-1)esCType(5  be checke
in DTtohighuva_MesCrType(RlTwe reLRDTtoes(-1)esCType(6  be checke
in DTtoeoun
h>SoEsCrType(RlTwe rf
u=DEVs(-1)esCType(7  be checkeReaISTM fo=e(if possiblDLgeIp() ffoi;  /rtPa 
changing rol MIf;ecke
in if /LOioButoei; TM fo=e(IT t, or toes3esyommats; new escWan funct, +f ne-v_BAi; T  Pao roPa 
chang; Macueupporss 5i; Tid ne-v_BASPAT  Pao r9Pa 
chang; Macueupporss 5SPATid ne-vBASEIRQ  Pao 10Pa 
chang; ida pors base & irqButoea pors;
    G0V5Baud RfO hispUSput(S,R_110Pa 
cPao npC1t(S, FR_300Pa 
cPao npC11(S, FR_600Pa 
cPao npC12(S, FR_1200Pa 
Pao npC13(S, FR_2400Pa 
Pao npC14(S, FR_4800Pa 
Pao npC15(S, FR_9600Pa 
Pao npC16(S, FR_14400Pa Pao npC17(S, FR_19200Pa Pao npC1e Ca;>SoEsCrType(RlTnpC19 MI(reaIrS<d)Ca;>SoEsCrType(RlTnpC1A MI(reaIrS<d)Ca FR_38400Pa Pao npC1B Ca;>SoEsCrType(RlTnpC1C MI(reaIrS<d)Ca;>SoEsCrType(RlTnpC1D MI(reaIrS<d)Ca;>SoEsCrType(RlTnpC1E MI(reaIrS<d)Ca FR_56000Pa Pao npC1F Ca;>SoEsCrType(RlTnpCog CI(reaIrS<d)Ca;>SoEsCrType(RlTnpC21 CI(reaIrS<d)Ca;>SoEsCrType(RlTnpC22 MI(reaIrS<d)Ca FR_128000PaPao npC23 Ca;>SoEsCrType(RlTnpCo4 CI(reaIrS<d)Ca;>SoEsCrType(RlTnpC25 CI(reaIrS<d)Ca;>SoEsCrType(RlTnpC26 MI(reaIrS<d)Ca FR_256000PaPao npC27 Ca
u;(inpifUS<>, +f* Teretoes2se Cacon2es lP comes
 oVESPACNOTIFY ml Bar pSyCNacoCEinH  Pao 1sCrType(RlT; byO s are(av(ilablDLes2offainpnpuq(RRaSyCNaICONSMe sPao  28esSnpCYMT; fewocue8 n w* WTriggocubyO s still
hn VpgeIpeMepgeIpeMesSnpCYMT; remaes2es2offainppnpuq(RRa waitI)S
hn VpgeIpeMepgeIpeMesSnpCYMT; GCobeue)(inmitted.SyCNaOPBITPa 
Pao  30 SSnpCYdT;  n enablDd evItr haseocbData nioc-to v ffofoDCs 13esstruc
hn VDCs_IdeFreeMeVpgeIpdb ?H HELPONnnocEL  , fo=e(/LOR_eEndPpe(RlTwe rhn VDCs_BaudRfO hn Vpgedw ?H HELPOBaudrfO hat which , +I)S<Ppe(RlTwe rhn VDCs_ByO Sizreturn Vdb ?H HELPONumbocues bits/byO , 4-oPa 
chanwe rhn VDCs_CounwreMeVpgeIpdb ?H HELPO0-4=None,Odd,vvIt,Mark,Spacreturwe rhn VDCs_SEVEBitseVpgeIpdb ?H HELPO0,1,2_Cn , 1.5,  28esSnpCYMTeturwe rhn VDCs_RlsLPe(inpuva_Mdw ?H HELPOLPe(inpuutoenpuvaGCobeuaISTTeturwe rhn VDCs_CtsLPe(inpuva_Mdw ?H HELPOLPe(inpuutoeCY SGCobeuaISTTeturrwe rhn VDCs_DsrLPe(inpuva_Mdw ?H HELPOLPe(inpuutoeDe rGCobeuaISTTeturrwe r rhn VDCs_BitMask1sCrTypedb ? r rhn V;>SoB9es fBp 
ry: 1;>SoEsLPOBp 
ry Madi (skip EOFaO8ecketurrwe rhn V;>SoB9es fRts(toablD:1RR(we ,on't Terern RY Sat HELOh; B2urrwe rhn V;>SoB9es fCounwr: 1;>SoEsLPOEnablDLpounwreO8eckI)S<Ppe(RlTrrwe rhn V;>SoB9es f* WxCtsFse :1RR OeCY Sh
2e>hakI)S<s
 inppnpu(RlTrrwe rhn V;>SoB9es f* WxDsrFse :1RR OeDe rh
2e>hakI)S<s
 inppnpu(RlTrrwe rhn V;>SoB9es fDummr: 2;>SoEsCckeReaIrS<deFreeMeVpgeIpeMPpe(RlTrrwe rhn V;>SoB9es fDtr(toablD:1RR(we ,on't Terern DTtoat HELOh; B2urrwe r rhn VDCs_BitMask 28esSnpdb ? r rhn V;>SoB9es f* WX: 1;>SoEsEsLPOEnablDLinppnpuX-ON/X-OFF(iata_*iwe rhn V;>SoB9es fInX: 1;>SoEsEssLPOEnablDLinpnpuX-ON/X-OFF(iata_*irwe rhn V;>SoB9es fCeC8 c: 1;>SoEsLPOEnablDLCounwre E+eRees1cemItrigewe rhn V;>SoB9es fN<> : 1;>SoEsEsLPOEnablDLN<> sstrippI)S<Ppe(RlTrrewe rhn V;>SoB9es fChEvt: 1;>SoEsELPOEnablDLRx2O8 connocuevItr.(RlTrrwe rhn V;>SoB9es fDtr;eou: 1;>SoEwe ,T rh
2e>hake<s
 inpnpupe(RlTrrewe rhn V;>SoB9es fRts;eou: 1;>SoEwe RY Sh
2e>hake<s
 inpnpupe(RlTrrewe rhn V;>SoB9es f