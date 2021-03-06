unit MyTset;                    {��� ᮧ����� �����:       20.11.01}

interface

type                            {��ꥪ�-������⢮ �ᥫ �� 0 �� 255}
  PSet=^TSet;                   {������⢮ ������� � �����}
  TSet=object
    len:byte;                                   {������⢮ ������⮢}
    up:byte;                                    {������ �࠭��}
    down:byte;                                  {������ �࠭��}
    voprs:set of byte;
    constructor Init(aDown,aUp:word);
    function  IsEmpty:boolean;
    procedure Insert(n:byte);                   {��⠢��� �������}
    procedure Delete(n:byte);                   {㤠����� �������}
    function  NextPlus(current:byte):byte;      {᫥���饥 �����}
    function  NextMinus(current:byte):byte;     {᫥���饥 ����}
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

function  TSet.NextPlus(current:byte):byte;     {current-�������,� ���ண�}
begin                                           {��稭��� ���� ᫥���饣�}
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