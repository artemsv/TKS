unit OleRTF;                          //  Дата создания: 31.10.02.
                                      //  итерфейсный модуль
interface

uses RichEdit,Windows,ActiveX;

const
  REO_GETOBJ_POLEOBJ	      =       1;  //  Get OLE object interface.
  REO_GETOBJ_PSTG	      =       2;  //  Get Storage interface.
  REO_GETOBJ_POLESITE	      =       4;  //  Get OLE site interface.
  REO_GETOBJ_NO_INTERFACES    =       8;  //  Get no interfaces.
  REO_GETOBJ_ALL_INTERFACES   =       16; //  Get all interfaces.

type
    PCHARRANGE=^CHARRANGE;
                 
    PREOBJECT=^REOBJECT;
    REOBJECT=packed record
      cbStruct:DWORD;           // size of structure in bytes
      cp:DWORD;                 // character position of object
      clsid:TGuid;              // class identifier of object
      poleobj:IOleObject;       // OLE object interface
      pstg:IStorage;            // associated storage interface
      polesite:IOleClientSite;  // associated client site interface
      size:TSize;               // size of object (may be 0,0)
      dvaspect:DWORD;           // display aspect to use
      dwFlags:DWORD;            // object status flags
      dwUser:DWORD;             // user-defined value
    end;

  IRichEditOle=interface
    function GetClientSite(out clientSite: IOleClientSite): HResult;stdcall;
    function GetObjectCount:ULONG;stdcall;
    function GetLinkCount:ULONG;stdcall;
    function GetObject(iob:ULONG;pObject:PREOBJECT;dwFlags:DWORD):HResult;stdcall;
    function InsertObject(pObject:PREOBJECT):HResult;stdcall;
    function ConvertObject(iob:ULONG;rclsidNew:TGUID;szUserTypeNew:PChar):HResult;stdcall;
    function ActivateAs(rclsid,rclsidAs:TGUID):HResult;stdcall;
    function SetHostNames(lpstrContainerApp,lpstrContainerObj:PChar):HResult;stdcall;
    function SetLinkAvailable(iob:ULONG;fAvailable:BOOL):HResult;stdcall;
    function SetDvaspect(iob:ULONG;dvaspect:DWORD):HResult;stdcall;
    function HandsOffStorage(iob:ULONG):HResult;stdcall;
    function SaveCompleted(iob:ULONG;lpstg:IStorage):HResult;stdcall;
    function InPlaceDeactivate():HResult;stdcall;
    function ContextSensitiveHelp(FEnterMode:BOOL):HResult;stdcall;
    function GetClipBoardData(lpchrg:PCHARRANGE;reco:DWORD;DataObj:IDataObject):HResult;stdcall;
    function ImportDataObject(DataObj:IDataObject;clipFormat:DWORD;
             hMetaPict:HGLOBAL):HResult;stdcall;
  end;

  IRichEditOleCallback=interface
  ['{B82A9E60-00F6-11D0-BCF9-5254AB54128E}']
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

end.
 