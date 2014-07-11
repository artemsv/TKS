{$X+}                                        {дата создания:  20.10.01}
unit MyLib;

interface

uses Types;

type
  keyType=(Insrt,Caps,num,Scroll);
  st79=string[79];
  st3 =string[3];

procedure UnReadKey(keyW:word);   {возвращает в буфер клавиатуры слово}
                                  {посылает в буфер ввода расширенный код,
                                   имитируя нажатие Аlt-комбинаций и др.
                                   extCode - расширенный код}
function  HeapFunc(size:word):integer;
procedure UnReadExtCode(extCode:word);
                                  {возвращает true,если вкл. режим xxxLock}
procedure SetLockKey(Lock:keyType;b:boolean);
function  GetLockKey(Lock:keyType):boolean;
function  Sstr(n:integer):string; {возвращает строковое представление числа}
function  Rstr(n:real):string;    {возвращает строковое представление числа}
function  Vval(st:string):word;   {возвращает числовое представление строки}
function  GetStr(n:byte;ch:char):string;{возвращает строку символов длиной n}
function  Ins(source:string;var dest:string;index:byte):string;
                                  {вставляет строку source в строку dest
                                  в позиции index(без раздвигания) и возвра-
                                  щает новую строку}
function  InsM(source:string;var lin:TBuffer;index:byte):char;
                                  {вставляет строку source в массив lin
                                  в позиции index(без раздвигания) и возвра-
                                  щает новый массив}
procedure Wait;                   {ожидает нажатия любой клавиши}
procedure ClrKeyBuf;              {очистка буфера клавиатуры}
function  Binary(x:longint;NumOfBits:byte):string;
function  Hex(d:byte):string;     {возвращает шестнадцатиричную цифру}
function  DecToHex(d:longint):string;{возвращает шестнадцатиричное число}
procedure Sirena;
procedure Phone;
function  GetCurDir:string;                {возвращает текущий каталог}
function  Verify(FileName,directory:string):boolean;
function  FileExist(filename:string):boolean;{провер.наличие файла filename}
procedure Duplet(interval,ckolko:integer;VAR a:array of integer);
procedure Sort(var c:array of integer);
function  Time:LongInt;
function  GetSecond:word;                   {возвращает текущее число секунд}
function  Log10(x:real):real;
function  Pwr(a,x:real):real;
procedure FillWord(var V;nWord,fill:word);
function  CopyFile(fNamein,fNameOut:st79):boolean;{копирует файл в файл}
function  GetExt(filename:st79):string;
procedure Four(position,number:integer;var pm:array of char);
procedure DiskReadWriteMsg(st:string);

implementation

uses Crt,Dos,MsgBoxMy;


function GetBit(key:keyType):byte;              {внутренняя}
begin
  case key of
    Insrt :GetBit:=$60;
    Caps  :GetBit:=$40;
    Num   :GetBit:=$20;
    Scroll:GetBit:=$10
  end;
end;

{$F+}
function  HeapFunc(size:word):integer;
begin
  heapFunc:=1
end;
{$F-}

procedure UnReadKey;
const
  kbdStart=$1E;
  kbdEnd=$3C;
var
  kbdHead:word absolute $40:$1A;                {голова}
  kbdTail:word absolute $40:$1C;                 {хвост}
  oldTail:word;
begin
  oldTail:=kbdTail;
  if kbdTail=kbdEnd then kbdTail:=kbdStart
                    else Inc(kbdTail,2);
  if kbdTail=kbdHead then kbdTail:=oldTail
                     else MemW[$40:oldTail]:=keyW
end;

procedure UnReadExtCode(extCode:word);
begin
  UnreadKey(Swap(extCode));
end;

procedure SetLockKey(Lock:keyType;b:boolean);
var
  m:byte absolute 0:$417;
  bit:byte;
begin
  bit:=GetBit(Lock);
  if b then m:=m or bit                         {включить}
       else m:=m and (255-bit)                  {выключить}
end;

function GetLockKey(Lock:keyType):boolean;
var
  bit:byte;
begin
  bit:=GetBit(Lock);
  if (Mem[0:$417] and bit)=bit then GetLockKey:=true
  else GetLockKey:=false
end;

function Sstr(n:integer):string;
var st:string;
begin
  Str(n,st);
  Sstr:=st;
end;

function Rstr(n:real):string;
var st:string;
begin
  Str(n,st);
  Rstr:=st;
end;

function Vval(st:string):word;
var n:word;code:integer;
begin
  Val(st,n,code);
  Vval:=n
end;

function GetStr(n:byte;ch:char):string;
var
  st:string;k:byte;
begin
  st:='';
  for k:=1 to n do st:=st+ch;
  GetStr:=st
end;

function  Ins(source:string;var dest:string;index:byte):string;
var
  k:byte;
begin
  for k:=index to Length(source)+index-1 do
    if k<=Length(dest) then
      dest[k]:=source[k-index+1];
  Ins:=dest;
end;

function  InsM(source:string;var lin:TBuffer;index:byte):char;
var
  k:byte;
begin
  for k:=index to Length(source)+index-1 do
    if k>78 then Exit else
      lin[k]:=256*Hi(lin[k])+byte(source[k-index+1]);
end;

procedure Wait;
begin
  repeat
  until KeyPressed
end;

procedure ClrKeyBuf;
var
  ch:char;
begin
  while KeyPressed do
    ch:=ReadKey
end;

function Binary(x:longint;NumOfBits:byte):string;
var
  bit,i:byte;
  s:string[32];
begin
  s:='';
  for i:=0 to 31 do begin
    bit:=(x shl 1)shr 31;
    s:=s+Chr(Ord('0')+bit);
  end;
  Delete(s,1,32-NumOfBits);
  Binary:=s;
end;

function  Hex(d:byte):string;
begin
  if d<10 then Hex:=Sstr(d)
  else Hex:=Chr(d+55);
end;

function  DecToHex(d:longint):string;
var
  r:byte;s:string[10];
begin
  s:='';
  while d>15 do
    begin
      r:=d mod 16;
      s:=Hex(r)+s;
      d:=d div 16
    end;
  s:=Hex(byte(d))+s;
  DecToHex:=s
end;

procedure Sirena;
var
  k:integer;
begin
  repeat
    for k:=400 to 800 do begin
      Sound(k);Delay(3);end;
    for k:=800 downto 400 do begin
      Sound(k);Delay(3);end;
    NoSound;
  until KeyPressed;
end;

procedure Phone;
var
  k:word;
begin
  repeat
    for k:=1 to 100 do
      begin
        Sound(1200);
        Delay(10);
        NoSound;
      end;
  until KeyPressed;
end;

function  GetCurDir;
var
  st:string;
begin
  GetDir(0,st);
  GetCurDir:=st
end;

function Verify;
begin
  if FSearch(FileName,directory)='' then Verify:=False
                                    else Verify:=True;
end;

function FileExist;
var
  Sr:SearchRec;
begin
  FindFirst(filename,AnyFile-VolumeID-Directory,Sr);
  FileExist:=DosError=0
end;

procedure Duplet(interval,ckolko:integer;VAR a:array of integer);
var
  n,k,r : integer;
  dupl  : boolean;
begin
   for k:=Low(a) to High(a) do a[k]:=0;
   Randomize;
   n:=1;
   repeat
     r:=Random(interval)+1;
     dupl:=false;
     for k:=1 to n do if r=a[k] then dupl:=true;
     if dupl then Continue;			{если повторяются,то снова}
     a[n]:=r;Inc(n)
   until n=ckolko+1;
end;

procedure Sort(var c:array of integer);
var
  max,buff,i,k:integer;
begin
  for k:=1 to High(c) do if c[k]=0 then begin max:=k-1;Break;end;
  for i:=1 to max-1 do
    FOR k:=i+1 TO max do
      if c[i]>c[k] then
         begin
           buff:=c[i];
           c[i]:=c[k];
           c[k]:=buff
         end;
end;

function Time:LongInt;
var
    hour,minute,second,sec100:word;
begin
  GetTime(hour,minute,second,sec100);
  Time:=(hour*3600+minute*60+second)
end;

function GetSecond:word;
var
  hour,minute,second,sec100:word;
begin
  GetTime(hour,minute,second,sec100);
  GetSecond:=second;
end;

function TestPrinter:shortint;
var
  r:registers;
begin
  TestPrinter:=100;
  r.ah:=$02;
  r.dx:=$00;
  intr($17,r);
  if (r.ah and $10)=$00 then TestPrinter:=-1            {не подключен}
  else
    if (r.ah and $00)=$00 then TestPrinter:=0   {подключен,но OFF LINE}
    else TestPrinter:=1                         {подключен,и  ON LINE  }
end;

function  Log10(x:real):real;
begin
  Log10:=Ln(x)/Ln(10)
end;

function  Pwr(a,x:real):real;
begin
  Pwr:=Exp(x*Ln(a))
end;

procedure FillWord(var V;nWord,fill:word);
begin
  inline($c4/$be/v/                    { LES DI,BP+V      }
         $8b/$8e/nWord/               { MOV CX,BP+nWord  }
         $8b/$86/fill/                 { MOV AX,BP+fill   }
         $fc/                          { CLD              }
         $f8/$a8)                      { REP STOSW        }

end;

function CopyFile(fNamein,fNameOut:st79):boolean;
var
  NumRead, NumWritten: Word;
  Buf: array[1..2048] of Char;{??????????? СДЕЛАТЬ УКАЗАТЕЛЬ!!!!!!!!!!!!!!!}
  f1,f2:file;
  size:longint;
  p:pointer;
begin
  CopyFile:=false;
  Assign(f1,fNameIn);
  {$I-}
  Reset(f1,1);
  if IOResult<>0 then
  begin
    MessageBox('Не удается открыть файл ',nil,mfOkButton);
    Wait;  {$I+};Exit;
  end;
    {$I+}
  Assign(f2,fNameOut);
  {$I-}
  Rewrite(f2, 1);
  if IOResult<>0 then
  begin
    MessageBox('Не удается открыть файл ',nil,mfOkButton);
    Wait;  {$I+};Exit;
  end;
  repeat
    BlockRead(f1, Buf, SizeOf(Buf), NumRead);
    BlockWrite(f2, Buf, NumRead, NumWritten);
  until (NumRead = 0) or (NumWritten <> NumRead);
  Close(f1);
  Close(f2);
  CopyFile:=true;
end;

function  GetExt(fileName:st79):string;
var
  b:byte;
begin
  b:=Pos('.',fileName);              {нашли точку в имени файла}
  GetExt:=Copy(fileName,b+1,Length(fileName)-b);
end;

procedure Four;
var
  i:integer;
  st:string[5];
begin
  Str(number,st);
  case Length(st) of
    1:st:='000'+st;
    2:st:='00'+st;
    3:st:='0'+st
  end;
  for i:=1 to 4 do
    pm[position+i-1]:=st[i];
end;

procedure DiskReadWriteMsg(st:string);
var a:byte;
begin
  a:=(78-Length(st)) div 2 - 2;
  TextAttr:=White+16*red+Blink;
  Window(a+2,10,a+5+Length(st),12);
  ClrScr;
  GotoXY(3,2);
  Write(st);
end;

end.
