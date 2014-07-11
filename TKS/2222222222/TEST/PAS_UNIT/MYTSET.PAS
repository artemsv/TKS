unit MyTset;                    {дата создания модуля:       20.11.01}

interface

type                            {объект-множество чисел от 0 до 255}
  PSet=^TSet;                   {множество замкнуто в кольцо}
  TSet=object
    len:byte;                                   {количество элементов}
    up:byte;                                    {верхняя граница}
    down:byte;                                  {нижняя граница}
    voprs:set of byte;
    constructor Init(aDown,aUp:word);
    function  IsEmpty:boolean;
    procedure Insert(n:byte);                   {вставить элемент}
    procedure Delete(n:byte);                   {удаление эелмента}
    function  NextPlus(current:byte):byte;      {следующее вверх}
    function  NextMinus(current:byte):byte;     {следующее вниз}
  end;

implementation

var
  k:byte;

constructor TSet.Init(aDown,aUp:word);
begin
  if (aUp<0) or (aup>255) or (adown<0) or (aDown>255) then Fail;
  voprs:=[];
  down:=aDown;
  up:=aUp;
  len:=up-down+1;
  for k:=down to up do Include(voprs,k)
end;

function TSet.IsEmpty:boolean;
begin
  if voprs=[] then IsEmpty:=true
  else IsEmpty:=false
end;

procedure TSet.Insert(n:byte);
begin
  Include(voprs,n);
  Inc(len);
  if (n<down) then down:=n;
  if (n>up) then up:=n;
end;

procedure TSet.Delete(n:byte);
begin
  Exclude(voprs,n);
  Dec(len);
  for k:=down to up do
    if k in voprs then
    begin
      down:=k;
      Break;
    end;
  for k:=up downto down do
    if k in voprs then
    begin
      up:=k;
      Break;
    end;
end;

function  TSet.NextPlus(current:byte):byte;     {current-элемент,с которого}
begin                                           {начинать поиск следующего}
 if current=up then NextPlus:=down else
 for k:=up downto current+1 do
   if k in voprs then NextPlus:=k;
end;

function TSet.NextMinus(current:byte):byte;          {}
begin
 if current=down then Nextminus:=up else
 for k:=down to current-1 do
   if k in voprs then NextMinus:=k;
end;

end.