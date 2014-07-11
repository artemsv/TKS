unit MEdit;                         {дата создания модуля:      08.10.01}
                                    {дата последнего изменения: 17.01.02}

interface

uses App,Dialogs,Drivers,Objects,Menus,Views,MsgBoxmy,Types,Indic,
     MBase,MyFunc,MyLib,MEdit0;
type
  PEdit=^TEdit;
  TEdit=object(TEdit0)
    line:byte;                                 {разделительная линия}
    first:boolean;                             {true-???????????????}
    paste:byte;                                {коорд.скопир.линии в буфере}
    macro:boolean;                             {true-cMacro изменяли}
    cMacro:PCollection;                        {коллекция макроопределений}
    invite:string[77];                         {текущее приглашение}
    x,y:byte;                                  {текущая позиция в chars}
    maxY,maxX,oldX,oldY:byte;
    edit:boolean;                              {true-режим редактирования}
    ins:boolean;                               {true-режим замены}
    ifAnyPlace:boolean;                        {true-курсор мож.нах.везде}
    ifBigChars:boolean;                        {true-в окне есть весь вопрос}
    lines:PChar;                               {указатель на блок}
    mChar:tm1;                                 {блок-массив символов}
    buffer:TBuffer;                            {буфер видеопамяти}
    indicator:PIndicator;                      {индикатор положения курсора}
    filename:st79;
    constructor Init(var R:TRect;AIndicator:PIndicator);
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure InsertFrom(P:PEdit);             {обмен с буфером}
    procedure ClipPaste;                       {вставка из буфера}
    procedure ClipCopy;                        {вставка в буфера}
    procedure ChangeMacroKey;                  {меняет макроопределение}
    procedure ShowMacroKey;                    {просмотр макроопределение}
    procedure MacroKey;                        {загрузка макроопр.из файла}
    procedure MacroString(cod:word);
    procedure SaveMacro;                       {сохраняет макроопр.в ыайле}
    function  SetMarkers:boolean;              {проставл.маркеры-разделители}
    function  MaxPosition(n:byte):boolean;     {ищет максим.значим позицию}
    procedure Plus;                            {сдвиг курсора и x вправо}
    procedure Minus;                           {сдвиг курсора и x влево}
    procedure Up;                              {сдвиг курсора и y вверх}
    procedure Compressor;                      {преобраз. chars в блок}
    procedure WriteBlock(p:pointer);           {запись блока в файл}
    procedure ReadBlock(p:pointer);            {считывание блока из файла}
    procedure Cls;
    procedure ShowChars;virtual;
    procedure FillLine(a1,a2,b:byte;atribut:word); {измен.цвет текста }
    procedure CleanChars;                      {}
    procedure CleanLine(n:byte);               {}
    procedure WriteInvite;                     {вывод приглашения}
    procedure CleanInvite;                     {стирает приглашение}
    procedure SetNormalColor;virtual;          {}
    function  LastPosition:byte;               {возвращает макс.поз.в строке}
    function  EmptyLine(n:byte):boolean;       {возвр.true,если строка пуст.}
    procedure PickUpItem(A:byte;B:TPoint);virtual;
end;

const
  ClipBoard:PEdit=nil;                         {указатель на буфер}

type
  PWorkWin=^TWorkWin;                          {?????????????????}
  TWorkWin=object(TWindow)
    Editor:PEdit;
    constructor Init(st:string);
    procedure HandleEvent(var Event:TEvent);virtual;
  end;

implementation

const
  altNum:array[1..8] of byte=(240,241,242,243,244,245,246,247);

constructor TWorkWin.Init;
var
  R:TRect;
  Indicator:PIndicator;
begin
  R.Assign(0,0,80,23);TWindow.Init(R,st,0);
  R.Assign(2, Size.Y - 1, 16, Size.Y);
  Indicator := New(PIndicator, Init(R));
  Insert(Indicator);
  Options:=Options or ofTileable;
  GetClipRect(R);
  R.Grow(-1,-1);
  Editor:=New(PEdit,Init(R,Indicator));
  if Editor=nil then Fail;
  Insert(Editor);
end;

procedure TWorkwin.HandleEvent;
begin
  if (Event.Command=cmClose) and(ClipBoard=Editor) then Hide
  else inherited HandleEvent(Event);
end;
                                                { TEdit }
constructor TEdit.Init;
var
  k:byte;
  st:string;
begin
  inherited Init(R);
  oldX:=2;
  line:=4;
  paste:=1;
  x:=oldX;y:=0;oldY:=0;maxX:=x;maxY:=oldY;
  ins:=false;
  edit:=false;
  indicator:=AIndicator;
  CleanChars;
  line:=0;
  first:=false;
  cMacro:=New(PCollection,Init(10,2));
  macro:=false;
  MacroKey;
  WriteInvite;
  SetCursor(oldX,1);
  Draw;
  ifAnyPlace:=true;
end;

procedure TEdit.ChangeMacroKey;
var
  DD:PDialog;
  R:TRect;
  st:string;
  p:PString;
  k:integer;
begin
  if ListDialog(cMacro,'Выберите нужное макроопределение',st,k,9)=cmCancel
   then Exit;
  st:=Copy(st,12,Length(st)-10);
  repeat
    if InputBox('','Введите новое макроопределение',st,30,0)=cmCancel
     then Exit;
  until Length(st)>=1;
  p:=cmacro^.At(k);
  st:=Copy(p^,1,11)+st;
  cMacro^.AtPut(k,NewStr(st));                  {замена на новое}
  macro:=true;                                  {true-значит cMacro изменяли}
end;

procedure TEdit.ShowMacroKey;
begin
  WatchWindow(cMacro,8,4,72,14);
end;

procedure TEdit.MacroKey;
var
  k:byte;
  st:string;
begin
  cMacro:=New(PCollection,Init(27,1));
  if not Verify('macro.dat',GetCurDir) and (@Self<>ClipBoard) then
    begin
      MessageBox(#3'Не найден файл MACRO.DAT.',nil,mfOkButton);
      for k:=1 to 27 do
      cMacro^.Insert(NewStr('Нет данных!!  Нет данных!!  Нет данных!!'));
      Exit;
    end;
  if not OpenFile('macro.dat',pf,2,true) then Exit;  {?????????????}
  while not Eof(tft(pf^)) do
    begin
      Readln(tft(pf^),st);
      cMacro^.Insert(NewStr(st));
    end;
  Close(tft(pf^));
end;

procedure TEdit.MacroString;
const
  ps:PString=nil;
var
  k:byte;
begin
  k:=cod div 256;
  if k in macroShift then Dec(k,$55) else
  if k in macroCtrl  then Dec(k,$56) else
  if k in macroAlt   then Dec(k,$57) else Exit;
  if k > cMacro^.count-1 then
       begin
         MessageBox('Выход за границу!!!',nil,mfOkButton);
         Exit;
       end;
  ps:=cMacro^.At(k);
  k:=12;
  while k<=Length(ps^) do
    begin
      chars[y,x]:=sym+byte(ps^[k]);
      Plus;
      Inc(k);
    end;
end;

procedure TEdit.SaveMacro;
var
  k:byte;
  ps:PString;
begin
  if MessageBox(#3'Сохранить возможные изменения'+#13+#3'в файле MACRO.DAT?',
   nil,mfYesButton+mfNoButton)<>cmYes then Exit;
  if not OpenFile('Macro.dat',pf,2,false) then Exit;
  for k:=0 to cMacro^.count-1 do
  begin
    ps:=PString(cMacro^.At(k));
    Writeln(tft(pf^),ps^);
  end;
  Close(tft(pf^));
end;

procedure TEdit.Plus;
begin
  if x<x2 then Inc(x);
end;

procedure TEdit.Minus;
begin
  if (x>oldX) or ifAnyPlace then if x>0 then Dec(x);
end;

procedure TEdit.Up;
begin
  if y>0 then Dec(y)
end;

function TEdit.MaxPosition;
var
  i,j:byte;
begin
  MaxPosition:=false;
  for i:=n downto oldY do
  begin
    for j:=xE downto 0 do
    begin
      if char(Lo(chars[i,j]))<>#32 then   {если нашли значимый символ}
      begin
        maxX:=j+1;
        maxY:=i;
        if not ((maxY=oldY) and (maxX=oldX)) then MaxPosition:=true;
        Exit;
      end;
    end;
  end;
end;

procedure TEdit.WriteBlock;
var
  k:integer;
begin
  k:=0;
  repeat
    Write(tfc(p^),lines[k]);
    Inc(k)
  until lines[k-1]='█';
end;

procedure TEdit.ReadBlock;
var
  k:integer;
begin
  k:=0;
  while not Eof(tfc(p^)) do
    begin
      Read(tfc(p^),mChar[k]);
      if mChar[k]=#219 then Break;
      Inc(k);
    end;
  mChar[k+1]:=#0;                               {терминальный ноль}
end;

procedure TEdit.CleanLine;
var
  k:byte;
begin
  chars[n,0]:=syn+32;
  chars[n,1]:=syn+32;
  for k:=oldX to xE+1 do
    chars[n,k]:=sym32;
end;

procedure TEdit.CleanChars;
var
  k:byte;
begin
  for k:=0 to y2 do CleanLine(k)
end;

procedure TEdit.Cls;
begin
  CleanChars;
  x:=oldX;oldY:=1;
  y:=oldy;line:=0;paste:=0;
  SetCursor(x,y);
  Draw;
end;

procedure TEdit.ShowChars;
var
  position:integer;
  k:byte;
  atribut:word;
  ch:char;
begin
  x:=0;y:=1;ch:=lines[4];position:=5;
  repeat
    chars[y,x]:=sym+byte(ch);
    ch:=lines[position];
    Inc(position);Inc(x);
    if x>xE then
    begin
      Inc(y);x:=0;
    end;
  until (ch=#221) or (ch=#219);
  if x>0 then
  begin
    Inc(y);x:=0;
  end;
  for k:=0 to x2 do chars[y,k]:=syl+196;
  line:=y;
  repeat
    Inc(y);
    if y=y2+1 then Break;
    x:=0;
    repeat
      if x<oldX then atribut:=syn else atribut:=sym;
      ch:=lines[position];
      if ch=#221 then Break;
      if ch<>#219 then chars[y,x]:=atribut+byte(ch);
      Inc(position);Inc(x);
      if x>xE then
      begin
        Inc(y);
        if y=y2+1 then Exit;
        x:=0;
      end;
    until (ch=#221) or (ch=#219);
    Inc(position);
  until ch=#219;
  x:=oldX;y:=1;
  SetCursor(x,y);Draw;
end;


function TEdit.SetMarkers;                      {проставляет разделители }
var
  k:byte;
  pDoubleChars:^TChars;
begin
  SetMarkers:=false;
  New(pDoubleChars);
  pDoubleChars^:=chars;                         {массив-копия}
  if not MaxPosition(y2) then Exit;             {позиция для маркера #219}
  chars[maxY,maxX]:=sym+219;
  CleanLine(line);                              {стираем разд. линию}
  oldY:=0;
  k:=maxY;
  while Lo(chars[k,0])=32 do Dec(k);
  repeat
    if Lo(chars[k,0])<>32 then
    begin
      MaxPosition(k-1);
      if maxY=0 then                        {если не окончен}
      begin                                 {восстанавливаем chars}
        MessageBox(#3'Вопрос не окончен!',nil,mfOkButton);
        Move(pDoubleChars^,chars,y2*(xE+1));
        Dispose(pDoubleChars);
        Draw;
        Exit;
      end;
      chars[maxY,maxX]:=sym221;             {маркер конца блока}
    end;
    Dec(k);
  until k=1;
  Dispose(pDoubleChars);
  SetMarkers:=true;
end;

procedure Tedit.Compressor;
var
  k,i,j:byte;
  position:integer;
  ch:char;
begin i:=1;position:=3;
  repeat j:=0;
    repeat
      Inc(position);
      mChar[position]:=char(Lo(chars[i,j]));
      ch:=char(Lo(chars[i,j]));
      Inc(j);
      if j=xE+1 then
      begin
        j:=0;
        Inc(i);
      end;
    until (ch=#221) or (ch=#219);
    if j>0 then Inc(i);
    while Lo(chars[i,0])=32 do Inc(i);
  until mChar[position]=#219;
  mChar[position+1]:=#0;
end;

procedure TEdit.FillLine;
var
  k:byte;
begin
  for k:=a1 to a2 do
    chars[b,k]:=atribut+Lo(chars[b,k]);
end;

procedure TEdit.WriteInvite;
var
  k:byte;
begin
  for k:=1 to Length(invite) do
    chars[0,k+2]:=syl+byte(invite[k]);
end;

procedure TEdit.CleanInvite;
var
  k:byte;
begin
  for k:=1 to x2 do chars[0,k]:=syl+32;
end;

procedure TEdit.SetNormalColor;
begin
end;

function TEdit.LastPosition:byte;
var
  k:byte;
begin
  LastPosition:=oldX;
  for k:=x2 downto oldX do
    if Lo(chars[y,k])<>32 then
    begin
      LastPosition:=k;
      Exit;
    end;
end;

function TEdit.EmptyLine;
var
  k:byte;
begin
  EmptyLine:=true;
  for k:=0 to x2 do
    if Lo(chars[n,k])<>32 then EmptyLine:=false;
end;

procedure TEdit.InsertFrom(P:PEdit);
var
  k:byte;
begin
  if ClipBoard=@Self then               {если я-окно буфера}
  begin
    y:=1;
    paste:=y;
    CleanChars;
    x:=oldX;
  end;
  for k:= oldx to x2 do
    if Hi(P^.chars[P^.paste,k])=$71 then
    begin
      chars[y,x]:=P^.chars[P^.paste,k];
      Plus;
    end;
  Draw;
end;

procedure TEdit.ClipPaste;
begin
  SetNormalColor;
  if (Clipboard<>nil) and (ClipBoard<>@Self)
    then InsertFrom(ClipBoard);
end;

procedure TEdit.ClipCopy;
begin
  if (ClipBoard<>nil) and (ClipBoard<>@Self) then
    ClipBoard^.InsertFrom(@Self);
end;

procedure TEdit.HandleEvent;
var
  R:TPoint;
  status:boolean;
  k,j,z:byte;
  Mouse:TPoint;
begin
  if (Mem[0:$417] and 3)<>0 then status:=true else status:=false;
  inherited HandleEvent(Event);
  if (Event.What=evMouseDown) and (Event.Buttons=mbLeftButton) then
    if MouseEvent(Event,evMouseMove) and (Event.Buttons=mbLeftButton) then
    begin
      PickUpItem(paste,Mouse);
      ClearEvent(Event);
    end
    else
    begin
      MakeLocal(MouseWhere,R);
      if ifAnyPlace or (((R.x>=oldX) and (R.y>=oldY)) or
        (edit and ((R.x>=oldX) and (R.y>0)))) then
      begin x:=R.x;y:=R.y;end;
        if Event.Double then if Event.Buttons=2 then
          begin  SetNormalColor;FillLine(oldX,x2,y,syV);end;
    end;
  case Event.What of
    evKeyDown:
        case Event.KeyCode of
          kbAlt2..
          kbAlt9    :if y>=oldY then begin chars[y,x]:=sym+
                       altNum[Event.KeyCode div $100-$78];Plus;end;
          kbAltZ    :if @Self=ClipBoard then    {очистка,если это буфер}
                      begin
                        paste:=0;
                        ifBigChars:=false;
                        Cls
                      end;
          kbAltF1   :ChangeMacroKey;
          kbCtrlLeft:if x>oldX then
                      begin
                        if chars[y,x]<>sym32 then Dec(x);
                        z:=x;
                        while chars[y,x]=sym32 do
                          if x>oldX then Dec(x)
                                    else Break;
                          if x=oldX then x:=z;
                        while chars[y,x]<>sym32 do
                          if x>oldX then Dec(x) else Break;
                          if x>oldX then Inc(x);
                      end;
          kbCtrlRight:if x<x2 then
                       begin
                         if chars[y,x]<>sym32 then
                         while (chars[y,x]<>sym32) do
                           begin
                             Inc(x);
                             if x=x2 then Break;
                           end;
                         z:=x;
                         while chars[y,x]=sym32 do
                          if x<x2 then Inc(x) else Break;
                          if x=x2 then x:=z;
                         end;
          kbCtrlF1  :ShowMacroKey;

          kbBack    :if (x>oldX) or ifAnyPlace then
                     begin
                       Minus;
                       chars[y,x]:=sym32;
                       for k:=x to x2-1 do chars[y,k]:=chars[y,k+1];
                       chars[y,k+1]:=sym32;
                     end;
                                        {вставить строку в позицию курсора}
          kbCtrlL   :if (y<y2) and (y<>line+1)and EmptyLine(y2) then
                     begin
                       for k:=y2 downto y do chars[k]:=chars[k-1];
                        CleanLine(y);
                       if y<=line then
                       begin
                         FillLine(0,1,line,syn);Inc(line);
                         FillLine(0,xE,line,syl);
                       end;
                       if y<=oldY then Inc(oldY);Inc(y);
                     end;
                                            {стереть строку и поднять текст}
         kbCtrlY   :begin
                       if (y<line) or (Lo(chars[y,0])=32) then
                       begin
                         for k:=y to y2-1 do for j:=0 to x2 do
                           chars[k,j]:=chars[k+1,j];
                         if y<line then
                         begin
                           FillLine(0,1,line,syn);Dec(line);
                           FillLine(0,xE,line,syl);
                         end;
                         for j:=0 to x2 do chars[y2,j]:=sym32;
                       end else
                         for j:=oldX to x2 do chars[y,j]:=sym32;x:=oldx;
                     end;

          kbCtrlDel :for k:=x to x2+1 do chars[y,k]:=sym32;
          kbCtrlIns :ClipCopy;
          kbCtrlEnd :begin MaxPosition(y2);x:=maxX;y:=maxY;end;
          kbCtrlHome:begin x:=oldX;y:=oldY;end;
          kbDel     :if x=xE then Exit else
                        begin
                          for k:=x to x2-1 do chars[y,k]:=chars[y,k+1];
                          chars[y,x2]:=sym32;
                        end;
          kbDown    :if y <20 then Inc(y);
          kbEnd     :if status then
                       begin
                         if x<x2 then
                           begin
                             paste:=y;
                             FillLine(x,LastPosition,y,syV);
                           end;
                       end else
                       begin
                         x:=LastPosition;
                         if x<x2 then Inc(x);
                       end;
          kbEnter   :if y=line-1 then
                       begin
                         Inc(y,2);
                         x:=2;
                       end else
                       if y<y2 then
                         begin
                           x:=oldX;
                           for k:=oldX to x2 do
                             if Lo(chars[y,k])<>32 then
                                begin
                                  x:=k;
                                  Break;
                                end;
                             Inc(y);
                         end;
          kbEsc     :begin paste:=0;SetNormalColor;end;
          kbF2      :begin if (y=oldy) or (x>X2-3) then
                     begin MessageBox(#3'Нет места!',nil,mfOkButton);exit;end;
                      chars[y,x]:=sym+byte('\');chars[y,x+1]:=sym+byte('/');
                      chars[y-1,x+3]:=sym+196;end;
          kbHome    :x:=oldX;
          kbIns     :begin SetState(sfCursorIns,not GetState(sfCursorIns));
                            ins:= not ins;end;
          kbLeft    :Minus;
          kbRight   :if status then begin if x<x2 then begin if (paste<>0)
                     and (y<>paste) then begin paste:=y;setnormalColor;end;
                     chars[y,x]:=syV+Lo(chars[y,x]);Inc(x);end;end else Plus;
          kbShiftIns:ClipPaste;
          kbSpace   :if x<x2 then begin for j:=x2 downto x do
                     chars[y,j]:=chars[y,j-1];chars[y,x2]:=sym32;
                     chars[y,x]:=sym32;Inc(x);end;
          kbTab     :if not ((y=y2) and (x>x2-4)) then for k:=0 to 3 do Plus;
          kbUp      :if ifAnyPlace or ((y >oldY) or edit) and (y>1) then Up;
        else begin
               if Event.CharCode=#0 then MacroString(Event.KeyCode);
               if (Event.CharCode<>#0) and (event.CharCode>#31) then
                  begin
                    if first then        {если клавиша нажата первый раз}
                    begin
                      first:=false;
                      CleanInvite;
                    end;
                    if not ins then for k:=x2 downto x+1 do
                       chars[y,k]:=chars[y,k-1];
                    chars[y,x]:=sym+byte(Event.CharCode);
                    Plus;
                  end;
             end;
        end;
    end;
  SetCursor(x,y);
  if Indicator <> nil then Indicator^.SetValue(Cursor, true);
  Draw;status:=false;
end;

procedure TEdit.PickUpItem;
begin
end;
end.
