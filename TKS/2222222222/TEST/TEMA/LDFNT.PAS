unit LdFnt;               {дата создания программы:   19.02.02 }

interface
procedure LoadFont;
implementation

uses
  Dos,Objects,crt;

procedure LoadFont;
var
  s,o,r:word;
  f:file;
  p:pointer;
  a:array[1..4096]of byte;
  cCol:pCollection;
  SS:SearchRec;
  st:string;
  n,code:integer;
begin
  cCol:=new(PCollection,init(10,0));
  ChDir('D:\TEST\TEMA\FONT\');
  FindFirst('*.fnt',AnyFile,SS);
  if dosError<>0 then
  begin
    Writeln;Writeln;
    Writeln('В текущем каталоге файлы шрифтов (*.fnt) не найдены!!!');
    Halt
  end;
  while doserror=0 do
  begin
    cCol^.Insert(NewStr(ss.Name));
    FindNext(ss);
  end;
  ClrScr;
  for r:=0 to cCol^.count-1 do
    Writeln(r:30,'  ',PString(cCol^.At(r))^);
  Writeln;Writeln('Введите номер шрифта (q-выход)':49);
  GotoXY(30,WhereY);
  repeat
    GotoXY(WhereX,WhereY+1);
    Readln(st);
    if st='q' then Halt;
    Val(st,n,code);
  until (code=0) and(n<=cCol^.count-1);
  Assign(f,PString(cCol^.At(n))^);
  Reset(f,1);
  BlockRead(f,a,SizeOf(a),r);
  s:=Seg(a);o:=Ofs(a);
asm
  mov ax,s
  mov es,ax
  mov ax,o
  mov bp,ax
  mov ah,11h
  mov al,0
  mov cx,256
  mov dx,0
  mov bl,0
  mov bh,16
  int 10h
end;
  ChDir('D:\TEST\');
end;
end.