unit Stream;                            {дата создания модуля:  14.02.02}
                                        {дата окончательной версии:20.02.02}
interface

uses
  Objects,Dos;

type

  PIndexArray=^TIndexArray;
  TIndexArray=array[0..255] of longint;

  PIndex=^TIndex;
  TIndex=object(TObject)
    size:byte;                            { количество индексов(т.е. блоков)}
    constructor Init(ASize:byte);
    constructor Load(var S:TStream);
    destructor Done;virtual;
    function Position(n:integer):longint;      { возвращает позицию блока n }
    procedure Store(var S:TStream);
    procedure Add(n:integer;value:longint);
  private
    Index:PIndexArray;                    { массив индексов}
  end;

  PHdr=^THdr;
  THdr=object(TObject)
    nn,ckolko:byte;
    kTem:byte;
    d:byte;
    tema:PChar;
    fName:PChar;
    pch:PChar;
    constructor Load(var S:TStream);
    procedure Store(var S:TStream);
    constructor Init(Ann,Ackolko,AkTem,Ad:byte;ATema,AfName,Apch:PChar);
    destructor Done;virtual;
  end;

  PBlock=^TBlock;
  TBlock=object(TObject)
    num:byte;                               {номер блока; начинается с 1}
    block:PChar;
    constructor Init(n:byte;p:PChar);
    constructor Load(var S:TStream);
    procedure Store(var S:TStream);
    destructor Done;virtual;
  end;

  TTestFile=object(TObject)
    stream:PStream;
    Hdr:PHdr;                                      {объект-заголовок}
    constructor Init(filename:PathStr;mode:word;Ahdr:PHdr);
    destructor Done;virtual;
    function GetBlock(num:byte):PBlock;            {считать блок из потока}
    function InvalidBlock:PBlock;
    function GetAllBlocks:PCollection;             {получить всен блоки}
    procedure PutAllBlocks(cCol:PCollection);      {записать все блоки}
    procedure RecordPositionInIndex(n:byte);
    procedure AddBlockAndRestore(BL:PBlock);
    procedure PutBlock(BL:PBlock);                 {записать блок BL в поток}
  private
    Index:PIndex;                              {объект-таблица индексов}
  end;

const                                        {регистрационные записи}
  RIndex:TStreamRec=(
    ObjType:1000;
    VmtLink:Ofs(TypeOf(TIndex)^);
    Load:@TIndex.Load;
    Store:@TIndex.Store
  );
  RHdr:TStreamRec=(
    ObjType:1001;
    VmtLink:Ofs(TypeOf(THdr)^);
    Load:@THdr.Load;
    Store:@THdr.Store
  );
  RBlock:TStreamRec=(
    ObjType:1002;
    VmtLink:Ofs(TypeOf(TBlock)^);
    Load:@TBlock.Load;
    Store:@TBlock.Store
  );

procedure RegisterStreams;

implementation

uses Strings,MyFunc,MsgBoxMy;

{  ThelpIndex  }

constructor TIndex.Init;
var
  p:PIndexArray;
begin
  TObject.Init;
  size:=ASize;
  GetMem(index,size*6);
  FillChar(Index^,size*SizeOf(longint),$00)
end;

constructor TIndex.Load(var S:TStream);
begin
  S.Read(size,SizeOf(size));
  if size=0 then Index:=nil else
  begin
    GetMem(Index,SizeOf(longint)*Size);
    S.Read(Index^,SizeOf(longint)*Size);
  end
end;

destructor TIndex.Done;
begin
  FreeMem(Index,SizeOf(longint)*Size);
  TObject.Done
end;

function TIndex.Position(n:integer):longint;
begin
  if n<=size then Position:=Index^[n]
  else Position:=0
end;

procedure TIndex.Add(n:integer;value:longint);
begin
  Index^[n]:=value
end;

procedure TIndex.Store(var S:TStream);
begin
  S.Write(size,SizeOf(size));
  S.Write(Index^,SizeOf(longint)*size)
end;

{  THdr  }

constructor THdr.Load(var S:TStream);
begin
  S.Read(nn,SizeOf(nn));
  S.Read(ckolko,SizeOf(ckolko));
  S.Read(kTem,SizeOf(ktem));
  S.Read(d,SizeOf(d));
  fName:=S.StrRead;
  tema:=S.StrRead;
  pch:=S.StrRead
end;

procedure THdr.Store(var S:TStream);
begin
  S.Write(nn,SizeOf(nn));
  S.Write(ckolko,SizeOf(ckolko));
  S.Write(kTem,SizeOf(ktem));
  S.Write(d,SizeOf(d));
  S.StrWrite(fName);
  S.StrWrite(tema);
  S.StrWrite(pch)
end;

constructor THdr.Init;
begin
  TObject.Init;
  nn:=Ann;ckolko:=Ackolko;kTem:=AkTem;d:=Ad;
  fName:=StrNew(AfName);
  tema:=StrNew(Atema);
  pch:=StrNew(Apch);
end;

destructor THdr.Done;
begin
  if pch<>nil then StrDispose(pch);
  inherited Done
end;

{  TBlock  }

constructor TBlock.Init(n:byte;p:PChar);
begin
  TObject.Init;
  num:=n;
  block:=p;                     {??????????? можно ли так?А не NEW???}
end;

constructor TBlock.Load(var S:TStream);
begin
  S.Read(num,SizeOf(num));
  block:=S.StrRead
end;

procedure TBlock.Store(var S:TStream);
begin
  S.Write(num,SizeOf(num));
  S.StrWrite(block)
end;

destructor TBlock.Done;
begin
  if block<>nil then StrDispose(block);
  inherited Done
end;

{  TTestFile  }

const
  MagicHeader=$53545341;                { 'ASTS' }
  tem:array[0..11] of byte=($41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41,$41);
  fn:array[0..7] of byte=($42,$42,$42,$42,$42,$42,$42,$42);
  pc:PChar='Это заголовок созданного файла!!!';
  pc1:PChar=nil;

constructor TTestFile.Init(filename:PathStr;mode:word;AHdr:PHdr);
var
  magic,size:longint;
  null:longint;
  PS:PStream;
begin
  magic:=0;
  null:=0;
  if not OpenStream(filename,PS,mode) then
  begin
    MessageBox(#3'Нельзя открыть файл'+#13+#13++#3+filename,nil,mfOkButton);
    Fail
  end;
  PS^.Seek(0);
  if PS^.GetSize>SizeOf(magic) then
    PS^.Read(magic,SizeOf(magic));
  if magic<>MagicHeader then
  begin                                     {файл создали}
    magic:=MagicHeader;
    Hdr:=AHdr;
    Index:=New(PIndex,Init(Hdr^.ckolko));
    PS^.Write(null,SizeOf(magic));
    PS^.Write(null,SizeOf(magic));  {2 раза-резерв}
    PS^.Write(magic,SizeOf(magic));
    PS^.Put(Index);
    PS^.Put(Hdr);
  end
  else
  begin
    PS^.Seek(12);
    Index:=PIndex(PS^.Get);             {считали объект-таблицу индексов}
    Hdr:=PHdr(PS^.Get);                     {считали объект-заголовок}
  end;
  stream:=PS
end;

destructor TTestFile.Done;
begin
  stream^.Seek(12);
  stream^.Put(Index);
  Dispose(stream,Done);
  Dispose(Hdr,Done);
  Dispose(Index,Done);
end;

function TTestFile.GetBlock(num:byte):PBlock;
var
  pos:word;
begin
  pos:=Index^.Position(num-1);
  if pos>0 then
  begin
    stream^.Seek(pos);
    GetBlock:=PBlock(stream^.Get)
  end
  else GetBlock:=InvalidBlock
end;

function TTestFile.InvalidBlock:PBlock;
const
  p:Pchar='Неправильный блок!!!▌1.Ошибка!!!▌2.Ошибка!!!▌3.Ошибка!!!█';
var
  BL:PBLock;
begin
  BL:=New(PBlock,Init(0,p));
  InvalidBlock:=BL
end;

procedure TTestFile.RecordPositionInIndex(n:byte);
begin
  Index^.Add(n-1,stream^.GetPos);
end;

procedure TTestFile.AddBlockAndRestore(BL:PBlock);
begin
  stream^.Seek(12++3+index^.size*SizeOf(longint));
  stream^.Put(Hdr);
  stream^.Seek(stream^.GetSize);
  PutBlock(BL);
  stream^.Seek(12);
  stream^.Put(index);
end;

procedure TTestFile.PutBlock(BL:PBlock);
begin
  RecordPositionInIndex(BL^.num);
  stream^.Put(BL);
end;

function TTestFile.GetAllBlocks:PCollection;
var
  cCol:PCollection;
  k:byte;
  BL:PBlock;
begin
  cCol:=New(PCollection,Init(10,2));
  cCol^.Insert(Hdr);
  for k:=1 to Hdr^.nn do
  begin
    BL:=GetBlock(k);
    cCol^.Insert(BL);
  end;
  GetAllBlocks:=cCol;
end;

procedure TTestFile.PutAllBlocks(cCol:PCollection);
var
  k:byte;
begin
  stream^.Seek(12++3+index^.size*SizeOf(longint));
  stream^.Put(Hdr);
  for k:=1 to cCol^.count-1 do
     PutBlock(PBlock(cCol^.At(k)));
  stream^.Seek(12);
  stream^.Put(index);
end;

procedure RegisterStreams;
begin
  RegisterType(RIndex);
  Registertype(RHdr);
  RegisterType(RBlock);
end;
begin
  RegisterStreams;
end.