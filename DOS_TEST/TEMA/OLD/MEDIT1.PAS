unit MEdit1;                {дата начальной версии     : 19.01.02}
                            {дата окончатальной версии : 30.01.02}

interface

uses
  Views,Objects,Drivers,Types,MEdit0,Indic,myCol;

     {УРОВЕНЬ 1.  Имеет доступ к любой точке экрана,вставляет символ в
       любое место,полностью обрабатывает события от мышм}

type
  PEdit1 = ^TEdit1;
  TEdit1=object(TEdit0)
    x,y:byte;                             {текущее положение курсора в chars}
    endX:byte;                            {наибольшая позиция x в строке}
    maxX,maxY:byte;                       {максимальная позиция в chars}
    oldX,oldY:byte;                       {"старое" положение курсора}
    indicator:PIndicator;                 {индикатор положения курсора}
    cColOld:PMyCicleCollection;           {стек возврата}
    constructor Init(R:TRect;AIndicator:PIndicator);
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure Plus;virtual;                    {сдвиг курсора и x вправо}
    function  Minus:boolean;virtual;           {true-сдвиyли курсор и x влево}
    procedure Up;virtual;                      {сдвиг курсора и y вверх}
    procedure Down;virtual;                    {сдвиг курсора и y вниз}
    procedure GoEnd;virtual;                   {сдвиг курсора и x в конец}
    procedure Enter;virtual;                   {}
    procedure Home;virtual;                    {сдвиг курсора и x в начало}
    procedure CtrlL;virtual;                   {вставка строки в поз.курсора}
    procedure CtrlY;virtual;                   {уд.строки в позиции курсора}
    procedure CtrlT;virtual;                   {уд.слова справа от курсора}
    procedure CtrlLeft;virtual;                {на слово влево}
    procedure CtrlRight;virtual;               {на слово вправо}
    procedure Undo(b:boolean);virtual;
    procedure SaveOld;virtual;
    procedure PutSymbol(ch:char);virtual;      {вставка символа}
    procedure PickUpItem(tp:TPoint);virtual;   {обраб.событий от мыши}
    procedure ShiftChars(a1,a2:byte);virtual;  {сдвиг символов на 1}
    procedure CleanChars;                      { очистка chars(только текст)}
    procedure UpDate;                          {обновляет chars}
    function  LastPosition(start:byte):byte;   {возвращает макс.поз.в строке}
    function  FindFirst(start:byte):byte;      {ищет первую непустую позицию
                                                от курсора до конца строки}
    function  MaxPosition(n:byte):boolean;     {ищет максим.значим позицию}
    function  EmptyLine(a,b:byte):boolean;       {true-строка a от b пустая}
    procedure CleanLine(b:byte);
  end;

type
  PWorkWin1=^TWorkWin1;                          {?????????????????}
  TWorkWin1=object(TWindow)
    Editor:PEdit1;
    constructor Init(st:string);
  end;

implementation

{$I Win1Init.inc}

constructor TEdit1.Init;
begin
  inherited Init(R);
  indicator:=AIndicator;
  cColOld:=New(PMyCicleCollection,Init(10,1));
  endX:=x2;
  oldY:=0;
  oldX:=0;
end;

{$I PlMiUpDn.inc}
{$I EndHome.inc }
{$I CtrlYL.inc  }

procedure TEdit1.PutSymbol;
begin
  SaveOld;
  if not GetState(sfCursorIns) then
    ShiftChars(x,endX);
  chars[y,x]:=sym+byte(ch);
  Plus;
end;

procedure TEdit1.UpDate;
begin
  SetCursor(x,y);
  if Indicator <> nil then Indicator^.SetValue(Cursor, true);
  Draw;
end;

procedure TEdit1.PickUpItem(tp:TPoint);
begin
end;

{$I LastFirs.inc}

procedure TEdit1.CleanChars;
var
  k,i:byte;
begin
  for k:=0 to y2 do
    for i:=0 to x2 do chars[k,i]:=Hi(chars[k,i])*256+32
end;

{$I Shift.inc   }
{$I MaxPos.inc  }
{$I XXXXLine.inc}


procedure TEdit1.Enter;
var
  z,k,b,i:byte;
begin
  if y=y2 then Exit;
  Inc(y);
  CtrlL;
  Dec(y);
  z:=x;
  x:=FindFirst(oldX);
  if x>z then b:=z else b:=x;
  for k:=z to endX do
    if (b+k-z)<=endX then chars[y+1,b+k-z]:=chars[y,k];
  for k:=z to endX do chars[y,k]:=sym32;
  Inc(y);
  x:=FindFirst(oldX);
end;

{$I Leftrigh.inc}

procedure TEdit1.Undo(b:boolean);
var
  p:pm2;
  i,j:byte;
begin
  if b then p:=pm2(cColOld^.GetPrev)
  else p:=pm2(cColOld^.GetNext);
  if p=nil then Exit;
  for i:=0 to y2 do for j:=0 to x2 do
    chars[i,j]:=sym+p^[i,j];
  CleanColor;
end;

procedure TEdit1.SaveOld;
var
  i,j:byte;
  p:pm2;
begin
  if cColOld^.count<cColOld^.limit then New(p)
  else p:=pm2(cColold^.At(cColOld^.start));
  for i:=0 to y2 do for j:=0 to endX do p^[i,j]:=Lo(chars[i,j]);
  if cColOld^.count<cColOld^.limit then cColOld^.Insert(p) else
    cColOld^.Insert(p);
end;

procedure TEdit1.HandleEvent;
var
  z,k,j:byte;
  tp:TPoint;
begin
  inherited HandleEvent(Event);

  case Event.What of
    evBroadcast:Exit;
    evCommand:Exit;
    evMouseDown:
      begin
        if Event.Double then CleanColor;
        tp:=MouseWhere;
        if MouseEvent(Event,evMouseMove) and (Event.Buttons=mbLeftButton) then
        PickUpItem(tp);
        MakeLocal(MouseWhere,tp);
        if (tp.x>=oldX) and (tp.y>=oldY) then
          begin x:=tp.x;y:=tp.y;end;
      end;
    evKeyDown:
      case Event.KeyCode of
        kbAltBack :Undo(true);
        kbBlock   :Exit;
        kbCtrlBack:Undo(false);
        kbCtrlDel :for k:=x to endX do chars[y,k]:=sym32;
        kbCtrlHome:begin x:=oldX;y:=oldY;end;
        kbCtrlEnd :begin MaxPosition(y2);x:=maxX;y:=maxY;end;
        kbCtrlY   :CtrlY;
        kbCtrlL   :CtrlL;
        kbCtrlLeft:Ctrlleft;
        kbCtrlRight:CtrlRight;
                       {удаление слова слева}

        kbCtrlR   :if (Lo(chars[y,x-1])<>32) and (Lo(chars[y,x])=32) then
                                    { курсор стоит в конце слова }
                     while Lo(chars[y,x-1])<>32 do
                     begin
                       ShiftChars(endX,x-1);
                       Minus;
                     end
                   else             { курсор стоит в середине слова }
                   if (Lo(chars[y,x-1])<>32) and (Lo(chars[y,x])<>32) then
                   begin
                     while Lo(chars[y,x-1])<>32 do
                     begin
                       ShiftChars(endX,x-1);
                       Minus;
                     end;
                   end              { курсор стоит в пустом месте }
                   else             { или в начале слова}
                   if (Lo(chars[y,x-1])=32) then
                   begin
                     z:=Lastposition(x);
                     while (Lo(chars[y,x-1])=32) and (x>oldX) do
                     begin
                       ShiftChars(endX,z+1);
                       Minus
                     end;
                   end;
        kbCtrlT   :CtrlT;              {удаление слова справа}
        kbBack    :if Minus then Shiftchars(endx,x);
        kbEnd     :GoEnd;
        kbEnter   :Enter;
        kbDel     :ShiftChars(endX,x);
        kbDown    :Down;
        kbHome    :Home;
        kbIns     :SetState(sfCursorIns,not GetState(sfCursorIns));
        kbLeft    :Minus;
        kbRight   :Plus;
        kbSpace   :if x<endX then
                   begin
                     ShiftChars(x,endX);       {сдвиг пробелом}
                     Inc(x);
                   end else if y<y2 then Plus;
        kbTab     :if not ((y=y2) and (x>endX-4)) then for k:=0 to 3 do Plus;
        kbUp      :Up;
      else
        if  byte(Event.CharCode) in [32..255] then PutSymbol(Event.CharCode)
          else exit;
      end;
    end;
  ClearEvent(Event);
  UpDate;
end;
end.