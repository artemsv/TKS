program LoadFont;               {��� ᮧ����� �ணࠬ��:   19.02.02 }

uses
  Dos,Objects,crt;
var
  s,o,r:word;
  f:file;
  ft:text;
  p:pointer;
  a:array[1..4096]of byte;
  st:string;
  n,code:integer;
begin
{  cCol:=new(PCollection,init(10,0));
  FindFirst('*.fnt',AnyFile,SS);
  if dosError<>0 then
  begin
    Writeln;Writeln;
    Writeln('� ⥪�饬 ��⠫��� 䠩�� ���⮢ (*.fnt) �� �������!!!');
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
  Writeln;Writeln('������ ����� ���� (q-��室)':49);
  GotoXY(30,WhereY);
  repeat
    GotoXY(WhereX,WhereY+1);
    Readln(st);
    if st='q' then Halt;
    Val(st,n,code);
  until (code=0) and(n<=cCol^.count-1);
  Assign(f,PString(cCol^.At(n))^);}
  Chdir('D:\TEST\tema');
  Assign(ft,'info.opr');
  Reset(ft);
  for s:=1 to 4 do readln(ft,st);
  Close(ft);
  if st='standart.fnt' then begin Chdir('D:\test\TEST\');Halt;end;
  ChDir('D:\TEST\TEMA\FONT\');
  Assign(f,st);
  Reset(f,1);
  BlockRead(f,a,SizeOf(a),r);
  Close(f);
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
  Chdir('D:\TEST\tema');
end.