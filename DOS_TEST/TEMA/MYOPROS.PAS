unit MyOpros;

interface

uses Dos,Crt,MRed,Drivers,MyFunc,Views,MsgBoxMy,Objects,Types,MyLib;

type
  POprosWin=^TOprosWin;
  TOprosWin=object(TWindow)
    constructor Init;
  end;

type
  Popros=^TOpros;
  TOpros=object(TScroller)
    x,y,oldX:byte;
    right:byte;                           {правильный ответ текущего вопроса}
    header:THeader;
    date:st8;
    filename:st12;
    cBlocks:PCollection;
    lines:pm1;
    chars:array[0..y2] of TBuffer;              {главный массив-копия экрана}
    catalog:string;
    numVar,numVopr:integer;
    fch:tfch;
    invite:string;
    constructor Init(var R:TRect);
    procedure LoadEditFile;
    procedure BlokRead;
    procedure IntermixLines;
    procedure Draw;virtual;
    procedure CleanLine(n:byte);
    procedure CleanChars;
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure SelectVar;
    procedure Inp(VAR aDate:st8;VAR gruppa,index:STRING;VAR kodgr,
                    kodtem,total:integer);
  end;


implementation

constructor TOprosWin.Init;
var
  R:TRect;
  Opr:POpros;
begin
  R.Assign(0,0,80,23);TWindow.Init(R,'Тест-опрос',0);
  GetClipRect(R);
  R.Grow(-1,-1);
  Opr:=New(POpros,Init(R));
  if Opr=nil then Fail
  else Insert(Opr);
end;

type
  st8=string[8];
var
  date:st8;
  i,J,count:byte;
  ch:char;
  catalog,gruppa,index,vern,name,badst:string;
  badmas,sluch:array[0..30]of integer;
  otv,right,num,numvar,NumVopr,prav,neprav,oc:integer;
  k,code,totalves,totaltim:integer;
  firsttim,oldtim,newtim:word;
  kodgr,kodtem,ves,total:integer;
  jr3,jr4,jr5,ball:real;
  fch:tfch;


procedure TOpros.SelectVar;
var n:integer;
begin
 filename:='tema.'+header.index;
 Assign(fch,filename);
 Reset(fch);
 n:=ReadFour(fch);
 Close(fch);
 InputInt(1,n,'номер варианта(от 1 до '+Sstr(n)+')',numVar);
end;

procedure TOpros.Inp;
var
  a:word;
  h:THeader;
  fst:text;
  st:string;
BEGIN
  if not Verify('info.dat',GetCurDir) then
    begin
      Assign(fst,'gruppa.dat');
      Reset(fst);
      while not Eof(fst) do
        begin
          Readln(fst,st);
          if st=gruppa then
            begin
              Readln(fst,kodgr);
              Break;
            end;
        end;
      InputBox('','Enter date',st,8);
      repeat
        SelectTema(h);
        filename:='var001.'+h.index;
        ChDir(catalog+'\var');
        if not Verify(filename,GetCurDir) then
          begin
            if MessageBox(#3'Вопросы по теме'+h.tema+#13+#13+
              #3'не составлены!  Выйти?',nil,mfYesNoCancel)=cmYes then Exit;
            ChDir(catalog);
          end;
      until Verify(filename,GetCurDir);
      GetDir(0,st);    {проверяем ,какой каталог текущий по выходу из цикла}
      IF st<>catalog THEN ChDir(catalog);  {если VAR, то меняем}
      InputInt(1,100,'Сколько баллов отводится на этот опрос?',total);
      REPEAT Readln(total);UNTIL (total<1000) AND (total>0);
      Assign(fst,'info.dat');
      Rewrite(fst);
      Writeln(fst,date);
      Writeln(fst,gruppa);
      Writeln(fst,kodgr);
{      Writeln(fst,tema);}
      Writeln(fst,index);
      Writeln(fst,kodtem);
      Writeln(fst,total);
      Close(fst);
      SetTime(0,0,0,0);
    END       {info.dat отсутствует}
  ELSE BEGIN
         Assign(fst,'info.dat');
      	 Reset(fst);
      	 Readln(fst,date);                     {считали дату,группу,тему}
      	 Readln(fst,gruppa);
         Readln(fst,kodgr);
{      	 Readln(fst,tema);}
         Readln(fst,index);
         Readln(fst,kodtem);
         Readln(fst,total);
      	 Close(fst);
       END;
END;

constructor TOpros.Init;
var
  a:word;
  h:THeader;
begin
   inherited Init(R,nil,nil);
   SetLimit(78,23);ShowCursor;
   GrowMode:=gfGrowHiX+gfGrowHiY;
   if SelectTema(header)=cmCancel then Fail;
   a:=MessageBox(#3'ТЕСТ-ОПРОС',nil,mfOkButton);
   case a of
     cmOk:SelectVar;
     cmCancel:Exit;
   end;
   GetDir(0,catalog);                           {определяем текущий каталог}
   {Inp(date,gruppa,index,kodgr,kodtem,total);}
    numvar:=0;                                  {пока номер варианта=0}
    filename:=MakeVarFileName(header.index,numvar);        {сляпали имя файла}
    ChDir(catalog+'\VAR');                      {в каталог с вопросами}
    Assign(fch,filename);
    {$I-}
    Reset(fch);
    if IOResult<>0 then
      begin
        MessageBox(#3'Нельзя считать вопросы по теме '+#13+#13+#3+
        header.tema+'(файл '+filename+')',nil,mfOkButton);
        ChDir(catalog);
        Fail;
      end;
    cBlocks:=New(PCollection,Init(10,1));
    LoadEditFile;
    ChDir(catalog);
    numVopr:=1;
    InterMixLines;
    Draw;
end;

procedure TOpros.HandleEvent;
begin
  if Event.What=evKeyDown then
  case Event.KeyCode of
     kbCtrlPgDn:begin
                  Inc(numVopr);
                  if numVopr>cBlocks^.count-1 then
                    numVopr:=1;
                    InterMixLines;
                end;
     kbCtrlPgUp:begin
                  Dec(numVopr);if numVopr=0 then
                  numVopr:=cBlocks^.count-1;
                  InterMixLines;
                end;
   end;
   Draw;
end;

procedure TOpros.Intermixlines;
var
  mas:array[0..100]of integer;position,k,j,atribut:word;
begin
  HideCursor;
  CleanChars;
  lines:=cBlocks^.At(numVopr);
  Duplet(header.d+1,header.d+1,mas);
  for k:=1 to header.d+1 do if mas[k]=header.d+1 then right:=k;
  x:=0;y:=1;ch:=lines^[4];k:=5;
  repeat
    chars[y,x]:=sym+byte(ch);ch:=lines^[k];
    Inc(k);Inc(x);if x>xE then begin Inc(y);x:=0;end;
  until (ch=#221) or (ch=#219);Draw;
  position:=k-2;                      {позиция конца самого вопроса в lines}
  if x>0 then begin Inc(y);x:=0;end;
  for k:=0 to x2 do chars[y,k]:=syl+196;     {разделительная черта}
  for k:=1 to header.d+1 do                  {цикл по всем ответам}
    begin
      j:=position;                           {устанавл.начало поиска в lines}
      repeat                                 {поиск начала ответа}
        Inc(j);
        ch:=lines^[j];
        if ch=#219 then begin Draw;Break;end;
        if ch=#221 then
           if Ord(lines^[j+1])-48=Ord(char(mas[k])) then Break;
      until lines^[j]=#219;
      x:=2;Inc(y);Inc(j,3);
      chars[y,0]:=sym+k+48;chars[y,1]:=sym+46;Draw;
      repeat
        if x<oldX then atribut:=syn else atribut:=sym;
        ch:=lines^[j];if ch=#221 then Break;
        if ch<>#219 then chars[y,x]:=atribut+byte(ch);
        Inc(j);Inc(x);if x>xE then
                              begin Inc(y);if y=y2+1 then Exit;x:=0;end;
      until (ch=#221) or (ch=#219);
  Draw;end;
end;

procedure TOpros.LoadEditFile;
var s:word;w:char;
begin
  New(lines);
  Assign(fch,fileName);{$I-}Reset(fch);{$I+}if IOResult<>0 then begin
  MessageBox('Нельзя открыть файл '+fileName,nil,mfOkButton);Halt;end;
  Window(25,7,55,11);TextBackGround(4);ClrScr;
  TextColor(15+128);GotoXY(5,3);Write('Идет загрузка с диска!'); s:=0;
  while not Eof(fch) do
    begin
      New(lines);
      if (lines=nil) or (memavail<16384) then
        begin
          MessageBox(#3'Не хватает памяти ',nil,mfError+mfOkButton);
          Exit;
        end;
      BlokRead;
      cBlocks^.Insert(lines);
    end;
  Close(fch)
end;

procedure TOpros.BlokRead;
var k:integer;ch:char;
begin k:=0;
  while not Eof(fch) do
    begin
      Read(fch,ch);
      lines^[k]:=ch;
      if ch=#219 then Break;Inc(k);
    end;
end;

procedure TOpros.Draw;
var
  k:byte;
begin
  for k:=0 to y2 do
      WriteLine(0,k,xE+2,1,chars[k]);
end;

procedure TOpros.CleanLine;
var k:byte;
begin chars[n,0]:=syn+32;chars[n,1]:=syn+32;
for k:=oldX to xE+1 do chars[n,k]:=sym32;end;

procedure TOpros.CleanChars;
var k:byte;
begin for k:=0 to y2 do CleanLine(k) end;

end.

cmOpros:DeskTop^.Insert(New(POprosWin,Init));