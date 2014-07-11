Unit MOpros;                 {дата создания начальной версии:       25.10.01}
                             {дата создания окончательной  версии:  15.11.01}
interface

uses Crt,Dos,Drivers,Views,Types,Objects,MyLib,MsgBoxMy,MyFunc,Indicatr,
     MEdit,Strings;

type
  TOpr=object(TEdit)
    right:byte;                         {правильный ответ текущего вопроса}
    header:THeader;
    date:st8;
    gruppa,index:string;
    kodGr,total:integer;
    cBlocks:PCollection;
    numVar,numVopr:integer;
    IndVopr,IndVar:PIndicator;
    function LoadEditFile:boolean;
    procedure IntermixLines;
    procedure Inp;
  end;


implementation


procedure TOpr.Intermixlines;
var
  mas:array[0..10]of integer;
  position,k,j,atribut:word;
  ch:char;
begin
  CleanChars;
  lines:=cBlocks^.At(numVopr);
  Duplet(header.d+1,header.d+1,mas);
  for k:=1 to header.d+1 do
    if mas[k]=header.d+1 then right:=k;
  x:=0;y:=1;ch:=lines[4];k:=5;
  repeat
    chars[y,x]:=sym+byte(ch);
    ch:=lines[k];
    Inc(k);
    Inc(x);
    if x>xE then begin Inc(y);x:=0;end;
  until (ch=#221) or (ch=#219);Draw;
  position:=k-2;                      {позиция конца самого вопроса в lines}
  if x>0 then begin Inc(y);x:=0;end;
  for k:=0 to x2 do chars[y,k]:=syl+196;     {разделительная черта}
  for k:=1 to header.d+1 do                  {цикл по всем ответам}
    begin
      j:=position;                           {устанавл.начало поиска в lines}
      repeat                                 {поиск начала ответа}
        Inc(j);
        ch:=lines[j];
        if ch=#219 then begin Draw;Break;end;
        if ch=#221 then
           if Ord(lines[j+1])-48=Ord(char(mas[k])) then Break;
      until lines[j]=#219;
      x:=2;Inc(y);Inc(j,3);
      chars[y,0]:=syn+k+48;chars[y,1]:=syn+46;Draw;
      repeat
        if x<oldX then atribut:=syn else atribut:=sym;
        ch:=lines[j];
        if ch=#221 then Break;
        if ch<>#219 then chars[y,x]:=atribut+byte(ch);
        Inc(j);Inc(x);
        if x>xE then
        begin
          Inc(y);
          if y=y2+1 then Exit;x:=0;
        end;
      until (ch=#221) or (ch=#219);
      Draw;
    end;
end;

function TOpr.LoadEditFile;
begin
  LoadEditFile:=false;
  if not OpenFile(filename,pf,0,true) then Exit;
  cBlocks:=New(PCollection,Init(10,5));
  DiskReadWriteMsg('Идет загрузка с диска!');
  while not Eof(tfc(pf^)) do
    begin
      if memavail<4096 then
      begin
        MessageBox(#3'Не хватает памяти ',nil,mfError+mfOkButton);
        cBlocks^.DeleteAll;
        Close(tfc(pf^));
        Exit;
      end;
      ReadBlock(pf);                          {считать блок}
      cBlocks^.Insert(StrNew(mChar));        {в коллекцию-указатель на блок}
    end;
  Close(tfc(pf^));
  LoadEditFile:=true;
end;

procedure TOpr.Inp;
var
  a:word;
  fst:text;
  st,sa:string;
  cGrup:PCollection;
begin
  if not Verify('info.dat',GetCurDir) then
    begin
      cGrup:=New(PCollection,Init(20,1));
      Assign(fst,'gruppa.dat');
      {$I-}
      Reset(fst);
      if IOResult<>0 then MsgHalt('Файл gruppa.dat не найден!');
      while not Eof(fst) do
      begin
        Readln(fst,st);
        Readln(fst,sa);
        cGrup^.Insert(NewStr(st));
      end;
      if ListDialog(cGrup,'Выберите группу',gruppa,kodGr,0)=cmCancel then Halt;
      Inc(kodGr);                     {увеличиваем,т.к. в ListDialog с нуля}
      st:='';
      date:=EnterDate;
      if date='' then Halt;
      repeat
        SelectTema(header);                       {выбор темы опроса}
        filename:='var001.'+header.index;
        {$I-}
        ChDir('\TEST\VAR');
        if IOResult<>0 then
        begin
          MessageBox(#3'Ошибка перехода в каталог'+#13#13#3'VAR',nil,mfOk);
          Halt;
        end;
        if not Verify(filename,GetCurDir) then    {есть ли по ней вопросы}
          begin
            if MessageBox(#3'Вопросы по теме '+header.tema+#13+#13+
              #3'не составлены!  Выйти?',nil,mfYesNoCancel)=cmYes then Halt;
            ChDir('\TEST');
          end;
      until Verify(filename,GetCurDir);
      GetDir(0,st);    {проверяем ,какой каталог текущий по выходу из цикла}
      if st<>'\TEST' then ChDir('\TEST');  {если VAR, то меняем}
      InputInt(1,100,'количество баллов,отводящееся на этот опрос?',total,0);
      Assign(fst,'info.dat');
      Rewrite(fst);
      Writeln(fst,date);
      Writeln(fst,gruppa);
      Writeln(fst,kodgr);
      Writeln(fst,header.index);
      Writeln(fst,header.kTem);
      Writeln(fst,total);
      Close(fst);
  {    SetTime(0,0,0,0);}
    end                                         {info.dat отсутствует}
  else begin
         {$I-}
         Assign(fst,'info.dat');
      	 Reset(fst);
      	 Readln(fst,date);                     {считали дату,группу,тему}
      	 Readln(fst,gruppa);
         Readln(fst,kodgr);
         Readln(fst,header.index);
         Readln(fst,header.kTem);
         Readln(fst,total);
         if IOResult<>0 then
         begin
           MessageBox(#3'Неверный формат файла'+#13#13#3'info.dat',nil,mfOk);
           Halt;
         end;
      	 Close(fst);
         {$I+}
       end;
end;
end.