{$O-}
unit Streams;                          //  Дата создания:  06.11.02
{
   Переделанный под версию 6.0
}

interface

uses MConst,Windows,SysUtils,MTypes;

const
  MagicHeader = $53545341;              //   {  'ASTS'  }
  version:longint=$00302E36;            //   {  '6.3 '  }
type
  TFile = class;

  TPersistObject = class//(TInterfacedObject)//  абстрактный потоковый класс
  public
    ObjType:word;                       //  идент.номер потокового класса
    constructor Load(TF:TFile);virtual;abstract;
    procedure Store(TF:TFile);virtual;abstract;
  end;

  TFile = class                     //  этот класс позволяет осуществить
  private                           //  полиморфический ввод-вывод
    FHandle:HFILE;                  //  дескриптор файла
    FFileName:string;               //  имя файла
  public
    constructor Create(AFileName:string;Mode:word);virtual;
    destructor Destroy;override;
    function Seek(Offset,Origin:Integer):integer;
    function SeekEnd:integer;
    function Write(var Buffer;Count:LongWord):integer;
    function Read(var Buffer;Count:LongWord):integer;
    function ReadPchar:PChar;
    function ReadPchar2(var Len:DWORD):PChar;
    function ReadStr:shortstring;
    procedure WriteStr(st:string);
    procedure WritePchar(pch:PChar);
    function Get:TPersistObject;                //  получить объект
    procedure Truncate(pos:integer);            //  усекает файл
    procedure Erase;                            //  удаляет файл
    procedure Put(Obj:TPersistObject);          //  сохранить объект
    property Handle:HFILE read FHandle;
    property FileName:string read FFileName;
  end;

  THeader = class(TPersistObject)          //  объект - заголовок
  private
    Fnn:byte;                              //  текущее количество вопросов
    FCkolko:byte;                          //  заявленное количество
    FkTem:byte;                            //  код темы
    Fd:byte;                               //  кол-во неправильных ответов
    FTema:PChar;                           //  название темы
    FfName:PChar;                          //  имя файла
    FComment:PChar;                        //  комментарий
    FDateCreate:PChar;                     //  дата создания
    FDateModified:PChar;                   // дата последней модификации
    procedure SetDateModified(const Value: PChar);
  public
    constructor Create (HD:THdr);
    constructor Load(TF:TFile);override;
    procedure Store(TF:TFile);override;
    property FName:PChar read FfName;
    property tema:PChar read FTema;
    property nn:byte read Fnn write Fnn;
    property ckolko:byte read FCkolko;
    property d:byte read Fd;
    property DateCreate:PChar read FDateCreate;
    property DateModified :PChar read FDateModified write SetDateModified;
    property Comment:PChar read FComment write FComment;
  end;

  PIndexArray = ^TIndexArray;
  TIndexArray = array[0..maxNumVoprs] of longint;

  TIndex = class(TPersistObject)    //  объект таблица индексов
  private
    Index:PIndexArray;
    FSize:byte;
  public
    constructor Create(ASize:longint);
    constructor Load(TF:TFile);override;
    destructor Destroy;override;
    procedure Store(TF:TFile);override;
  end;

  TTestFile = class(TFile)
  private
    FHeader:THeader;
    FBeginPos:longint;
  public
    constructor Create(FileName:string);reintroduce;// сущесвующего
    constructor CreateNew(Header:THeader);      //  создание нового
    destructor Destroy;override;
    procedure WriteSignature;
    procedure ReadSignature;
    function GetHeader:THeader;                 //  возвращает заголовок
    procedure ChangeNN(nn:byte);
    function SeekBegin:integer;
  end;

  { TStreamRec }

  PStreamRec = ^TStreamRec;
  TStreamRec = record
    ObjType: Word;
    VmtLink: DWORD;
    Load: Pointer;
    Store: Pointer;
    Next: Pointer;
  end;

implementation

uses UOleRTF;

{ TFile }

constructor TFile.Create(AFileName: string; Mode: word);
begin
  FHandle:=integer(CreateFile(PChar(AFileName),GENERIC_READ or GENERIC_WRITE,
    0,nil,Mode,FILE_ATTRIBUTE_NORMAL,0));
  if FHandle=INVALID_HANDLE_VALUE then
    raise EXception.Create('Ошибка доступа к файлу '+AFileName);
  FFileName:=FileName
end;

destructor TFile.Destroy;
begin
  CloseHandle(FHandle);
end;

procedure TFile.Erase;
begin
  DeleteFile(FFileName);
  Free;
end;

function TFile.Get: TPersistObject;
var
  ObjType,ww:word;
  p:Pointer;
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
{ if ObjType=$4848 then              TypeOf
  asm
    MOV EBX,self
    CALL THeader.ClassName
    Mov Result,EAX
  end else}
  case ObjType of
//    $4646 : Result:=TFrame.Load(Self);             //  'FF'    17990
    $4949 : Result:=TIndex.Load(Self);             //  'II'    18761
    $4848 : Result:=THeader.Load(Self);            //  'HH'    18504
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

function TFile.Read(var Buffer; Count: LongWord): integer;
begin
  if not ReadFile(FHandle,Buffer,Count,LongWord(Result),nil) then
     raise Exception.Create('Ошибка в TFile.Read')
//    Result:=-1
end;

function TFile.ReadPchar: PChar;
var
  len:DWORD;
begin
  Result:=ReadPChar2(len);
end;

function TFile.ReadPchar2(var Len: DWORD): PChar;
var
  r:LongWord;
begin
  if not ReadFile(FHandle,Len,SizeOf(Len),r,nil) or (SizeOf(Len)<>r) then
    raise Exception.Create('Сбой в TFile.ReadPchar');
  if Len=0 then
  begin
    Result:=nil;
    Exit;
  end;
  Result:=StrAlloc(Len+1);               // проверка на nil
  ZeroMemory(Result,Len+1);
  if Result<>'' then
  if not ReadFile(FHandle,Result^,Len,r,nil) or (Len<>r) then
       raise Exception.Create('Сбой в TFile.ReadPchar');;
end;

function TFile.ReadStr: shortstring;
var
  n:byte;
begin
  Result:='';
  while true do
  begin
    Read(n,1);
    if n=13 then
    begin
      Read(n,1);
      Exit;
    end;
    Result:=Result+char(n);
  end;
end;

function TFile.Seek(Offset, Origin: Integer): integer;
begin
 Result := SetFilePointer(FHandle, Offset, nil, Origin); {TODO asdfsdf}
end;

function TFile.SeekEnd: integer;
begin
  Seek(0,FILE_END);
end;

procedure TFile.Truncate(pos:integer);
begin
  Seek(pos,FILE_BEGIN);
  SetEndOfFile(Handle);
end;

function TFile.Write(var Buffer; Count: LongWord): integer;
begin
  if not WriteFile(FHandle,Buffer,Count,LongWord(Result),nil)
    then raise Exception.Create('Ошибка в TFile.Write')// := -1
end;

procedure TFile.WritePchar(pch: PChar);
var
  len,rWCount:LongWord;
begin
  if pch=nil then len:=0 else len:=StrLen(pch);
  if not WriteFile(FHandle,len,SizeOf(len),rWCount,nil) then Exit;
  if not WriteFile(FHandle,pch^,len,rWCount,nil) then Exit;
end;

procedure TFile.WriteStr(st: string);
var
  pch:PChar;
  cr:word;
begin
  cr:=$0D0A;
  pch:=StrNew(PChar(st));
  Write(pch^,Length(st));
  Write(cr,2);
  StrDispose(pch)
end;

{ THeader }

constructor THeader.Create(HD:THdr);
begin
  ObjType:=$4848;
  Fnn:=HD.nn;
  FCkolko:=HD.Ckolko;
  FkTem:=HD.kTem;
  Fd:=HD.d;
  FTema:=StrNew(HD.tema);
  FfName:=StrNew(HD.fName);
  FComment:=StrNew(HD.Comment);
  FDateCreate:=StrNew(HD.DateCreate);
  FDateModified:=StrNew(HD.DateModified);
end;

constructor THeader.Load(TF: TFile);
begin
  ObjType:=$4848;
  TF.Read(Fnn,1);
  TF.Read(FCkolko,1);
  TF.Read(FkTem,1);
  TF.Read(Fd,1);
  FTema:=TF.ReadPChar;
  FfName:=TF.ReadPChar;
  FDateCreate:=TF.ReadPchar;
  FDateModified:=TF.ReadPchar;
  FComment:=TF.ReadPChar;
end;

procedure THeader.SetDateModified(const Value: PChar);
begin
  FDateModified := Value;
end;

procedure THeader.Store(TF: TFile);
begin
  TF.Write(Fnn,1);
  TF.Write(FCkolko,1);
  TF.Write(FkTem,1);
  TF.Write(Fd,1);
  TF.WritePChar(FTema);
  TF.WritePChar(FfName);
  TF.Writepchar(FDateCreate);
  TF.WritePchar(FDateModified);
  TF.WritePChar(FComment);
end;

{ TIndex }

constructor TIndex.Create(ASize: Integer);
begin
  ObjType:=$4949;
  FSize:=ASize;
  GetMem(Index,ASize*SizeOf(longint));       //  резервируем память
  FillChar(Index^,ASize*SizeOf(longint),65);
end;

destructor TIndex.Destroy;
begin
  FreeMem(Index,FSize*SizeOf(longint));      //  освобождаем память
  inherited;
end;

constructor TIndex.Load(TF: TFile);
begin
  ObjType:=$4949;
  TF.Read(FSize,SizeOf(FSize));
  GetMem(Index,FSize*4);
  TF.Read(INdex^,FSize*4)
end;

procedure TIndex.Store(TF: TFile);
begin
  TF.Write(FSize,SizeOf(FSize));
  TF.Write(Index^,FSize*SizeOf(longint))
end;

{ TTestFile }

procedure TTestFile.ChangeNN(nn: byte);
begin
  Seek(14,0);
  Write(nn,1);
end;

constructor TTestFile.Create(FileName: string);
begin
  inherited Create(FileName,OPEN_EXISTING);
  ReadSignature;
  FHeader:=THeader(Get);
  FBeginPos:=SetFilePointer(FHandle,0,nil,FILE_CURRENT);
end;

constructor TTestFile.CreateNew(Header: THeader);
begin
  if inherited Create(Header.FfName,CREATE_ALWAYS)=nil then
  begin
    MessageBox(0,'Сбой в конструкторе CreateNew','Error',0);
    Halt;
  end;
  WriteSignature;
  FHeader:=Header;
  Put(FHeader);
end;

destructor TTestFile.Destroy;
begin
  FHeader.Free;    //почему все поля равны нулю???????????
  inherited;
end;

function TTestFile.GetHeader: THeader;
var
  HD:THdr;
begin
  with HD do
  begin
    ckolko:=FHeader.FCkolko;
    nn:=FHeader.Fnn;
    d:=FHeader.Fd;
    kTem:=65;
    tema:=StrNew(FHeader.FTema);
    fName:=StrNew(FHeader.fName);
    Comment:=StrNew(FHeader.FComment);
    DateCreate:=StrNew(FHeader.FDateCreate);
    DateModified:=StrNew(FHeader.FDateModified);
  end;
  Result:=THeader.Create(HD);
end;

procedure TTestFile.ReadSignature;
var
  magic:longint;
begin
  Read(magic,4);
  if magic<>magicHeader then
    raise Exception.Create('Неправильный формат файла.');
  Read(magic,4);      //  резерв 4 слова
  Read(magic,4);
  if magic<>version then
    raise Exception.Create('Неизвестная версия файла.');
end;

function TTestFile.SeekBegin: integer;
begin
  Seek(FBeginPos,FILE_BEGIN);
end;

procedure TTestFile.WriteSignature;
var
  magic:longint;
begin
  magic:=magicHeader;
  Write(magic,4);
  magic:=0;
  Write(magic,4);
  magic:=version;
  Write(magic,4);
end;

end.
