unit WinFile;

interface

uses Windows;

type
  TFile = class;

  TPersistObject = class(TInterfacedObject)//  абстрактный потоковый класс
  public
    ObjType:word;                       //  идент.номер потокового класса
    constructor Load(TF:TFile);virtual;abstract;
    procedure Store(TF:TFile);virtual;abstract;
  end;

  TFile = class                     //  этот класс позволяет осуществить
  private                           //  полиморфический ввод-вывод
    FHandle:HFILE;                  //  дескриптор файла
  public
    constructor Create(FileName:string;Mode:word);virtual;
    destructor Destroy;override;
    function Seek(Offset,Origin:Integer):integer;
    function SeekEnd:integer;
    function Write(var Buffer;Count:LongWord):integer;
    function Read(var Buffer;Count:LongWord):integer;
    function ReadPchar:PChar;
    procedure WritePchar(pch:PChar);
//    function Get:TPersistObject;                //  получить объект
//    procedure Put(Obj:TPersistObject);          //  сохранить объект
    property Handle:HFILE read FHandle;
  end;


implementation

uses SysUtils;
{ TFile }

constructor TFile.Create(FileName: string; Mode: word);
begin
  FHandle:=integer(CreateFile(PChar(FileName),GENERIC_READ or GENERIC_WRITE,
    0,nil,Mode,FILE_ATTRIBUTE_NORMAL,0));
  if FHandle=INVALID_HANDLE_VALUE then
    raise EXception.Create(FileName+'INVALID_HANDLE_VALUE')
end;

destructor TFile.Destroy;
begin
  CloseHandle(FHandle);
end;

{function TFile.Get: TPersistObject;
var ObjType,ww:word;p:Pointer;st:shortstring;
begin
  p:=self;
  ww:=Self.FHandle;
  Read(ObjType,2);                 //  идент.номер потокового класса
  p:=ClassType;
  asm
    mov edx,[eax].vmtSelfPtr;
    mov edx,[eax].vmtTypeInfo;
    mov edx,[eax].vmtClassName;
    mov edx,[eax].vmtParent;
  end;
  st:=ClassName;
{ if ObjType=$4848 then              TypeOf
  asm
    MOV EBX,self
    CALL THeader.ClassName
    Mov Result,EAX
  end else
  case ObjType of
    $4646 : Result:=TFrame.Load(Self);             //  'FF'    17990
    $5151 : Result:=TQuestion.Load(Self);          //  'QQ'    20817
    $4141 : Result:=TAnswer.Load(Self);            //  'AA'    16705
    $4C4C : Result:=TDrawStr.Load(Self);           //  'LL'    19532
    $4949 : Result:=TIndex.Load(Self);             //  'II'    18761
    $4848 : Result:=THeader.Load(Self);            //  'HH'    18504
    $4E4E : Result:=TNumLine.Load(Self);           //  'NN'
    $4343 : Result:=TColorTable.Load(Self);        //  'CC'    17219
    $4F4F : Result:=TFontTable.Load(Self);         //  'OO'    20303
    $5050 : Result:=TPlainLine.Load(Self);         //  'PP'    20560
    $4444 : Result:=TPlainALine.Load(Self);        //  'DD'
    $4242 : Result:=TBmp.Load(Self);               //  'BB'
    $4545 : Result:=TEcuation.Load(Self);          //  'EE'
  else
    Raise Exception.Create('Попытка чтения незарегестрированного объекта.'+
       #13+#13'Идентификационный номер объекта - '+IntToHex(ObjType,2)+
          ' ('+Chr(LOBYTE(ObjType))+Chr(HIBYTE(ObjType))+')')
  end;
end;

procedure TFile.Put(Obj: TPersistObject);
begin
  if Write(Obj.ObjType,2)=-1 then
    raise Exception.Create('Ошибка в TFile.Put');
  Obj.Store(Self)
end;
          }
function TFile.Read(var Buffer; Count: LongWord): integer;
begin
  if not ReadFile(FHandle,Buffer,Count,LongWord(Result),nil) then
     raise Exception.Create('Ошибка в TFile.Read')
//    Result:=-1
end;

function TFile.ReadPchar: PChar;
var len:word;r:LongWord;
begin
  if not ReadFile(FHandle,len,SizeOf(len),r,nil) or (SizeOf(len)<>r) then
    raise Exception.Create('Сбой в TFile.ReadPchar');
  if len=0 then
  begin
    Result:=nil;
    Exit;
  end;
  Result:=StrAlloc(len+1);               // проверка на nil
  if Result<>'' then
  if not ReadFile(FHandle,Result^,len,r,nil) or (len<>r) then
       raise Exception.Create('Сбой в TFile.ReadPchar');;
end;

function TFile.Seek(Offset, Origin: Integer): integer;
begin
 Result := SetFilePointer(FHandle, Offset, nil, Origin); {TODO asdfsdf}
end;

function TFile.SeekEnd: integer;
begin
  Seek(0,FILE_END);
end;

function TFile.Write(var Buffer; Count: LongWord): integer;
begin
  if not WriteFile(FHandle,Buffer,Count,LongWord(Result),nil)
    then raise Exception.Create('Ошибка в TFile.Write')// := -1
end;

procedure TFile.WritePchar(pch: PChar);
var len:word;rWCount:LongWord;
begin
  if pch=nil then len:=0 else len:=StrLen(pch);
  if not WriteFile(FHandle,len,SizeOf(len),rWCount,nil) then Exit;
  if not WriteFile(FHandle,pch^,len,rWCount,nil) then Exit;
end;


end.
