Unit BaseWin;

interface

uses Types,Views;

type
  PBaseWindow = ^ TBaseWindow;
  TBaseWindow = object(TWindow)
    oldX,oldY,x,y,line,paste:byte;
    chars:TChars;
    procedure Draw;virtual;
    procedure CleanLine(n:byte);               {}
    procedure CleanChars;
    procedure CleanColor;
    procedure CleanSymbols;
    procedure CleanAll;
    procedure Cls;
    procedure FillLine(a1,a2,b:byte;atribut:word); {измен.цвет текста }
    procedure SetNormalColor;virtual;          {}
    function  LastPosition:byte;               {возвращает макс.поз.в строке}
    function  EmptyLine(n:byte):boolean;       {возвр.true,если строка пуст.}
  end;

implementation

procedure TBaseWindow.Draw;
var
  k:byte;
begin
  inherited Draw;
  for k:=0 to Size.Y-3 do
    WriteLine(1,k+1,Size.X-2,1,chars[k]);
end;

procedure TBaseWindow.CleanLine;
var
  k:byte;
begin
  chars[n,0]:=syn+32;
  chars[n,1]:=syn+32;
  for k:=oldX to xE+1 do
    chars[n,k]:=sym32;
end;

procedure TBaseWindow.CleanChars;
var
  k:byte;
begin
  for k:=0 to y2 do CleanLine(k)
end;

procedure TBaseWindow.CleanColor;
var
  i,j:byte;
begin
  for i:=0 to y2 do for j:=0 to xE+1 do chars[i,j]:=sym+Lo(chars[i,j])
end;

procedure TBaseWindow.CleanSymbols;
var
  i,j:byte;
begin
  for i:=0 to y2 do for j:=0 to xE+1 do chars[i,j]:=256*Hi(chars[i,j])+32
end;

procedure TBaseWindow.CleanAll;
var
  i,j:byte;
begin
  for i:=0 to y2 do for j:=0 to xE+1 do chars[i,j]:=sym32
end;



procedure TBaseWindow.Cls;
begin
  CleanChars;
  x:=oldX;oldY:=1;
  y:=oldy;line:=0;paste:=0;
  SetCursor(x,y);
  Draw;
end;

procedure TBaseWindow.FillLine;
var
  k:byte;
begin
  for k:=a1 to a2 do
    chars[b,k]:=atribut+Lo(chars[b,k]);
end;

procedure TBaseWindow.SetNormalColor;
var
  i,j:byte;
begin
  for i:=0 to y2 do for j:=0 to 78 do chars[i,j]:=sym+Lo(chars[i,j])
end;

function TBaseWindow.LastPosition:byte;
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

function TBaseWindow.EmptyLine;
var
  k:byte;
begin
  EmptyLine:=true;
  for k:=0 to x2 do
    if Lo(chars[n,k])<>32 then EmptyLine:=false;
end;

end.
