unit MEdit0;                          {дата начальной версии     : 19.01.02}
                                      {дата окончатальной версии : 26.01.02}

interface

uses Views,Objects,Drivers,Types,MyLib;

     {УРОВЕНЬ 0. Простое окно с курсором.Необрабатывает никаких событий}

type
  PEdit0 = ^TEdit0;
  TEdit0=object(TView)
    chars:TChars;                              {главный массив-копия экрана}
    constructor Init(R:TRect);
    procedure Draw;virtual;
    procedure ClearAll;virtual;
    procedure CleanColor;virtual;
  end;

type
  PWorkWin0=^TWorkWin0;
  TWorkWin0=object(TWindow)
    Editor:PEdit0;
    constructor Init(st:string);
  end;

implementation

constructor TWorkWin0.Init;
var
  R:TRect;
begin
  R.Assign(0,0,80,23);
  TWindow.Init(R,st,0);
  Options:=Options or ofTileable;
  GetClipRect(R);
  R.Grow(-1,-1);
  Editor:=New(PEdit0,Init(R));
  if Editor=nil then Fail;
  Insert(Editor);
end;


constructor TEdit0.Init;
begin
  Inherited Init(R);
  Options:=Options or ofSelectable;
  EventMask:=EventMask or evBroadCast;
  sym    :=  256*$1E;
  syl    :=  256*$1B;
  syn    :=  256*$1F;
  syv    :=  256*$71;
  symM   :=  $1E;
  syvM   :=  $71;
  sym32  :=  sym+32;
  syn32  :=  syn+32;
  ShowCursor;
  GrowMode:=gfGrowHiX+gfGrowHiY;
  ClearAll;
end;

procedure TEdit0.ClearAll;{assembler;}
var
  i,j:byte;
begin{
asm
  les di,Self
  lea di,es:[di].TEDit0.chars
  mov ax,ds
  mov es,ax
  cld
  mov cx,x2*y2
  mov ax,sym32
{  stosw
end;}
  for i:=0 to y2 do for j:=0 to x2 do chars[i,j]:=sym32;
end;
procedure TEdit0.CleanColor;
var
  i,j:byte;
begin
  for i:=0 to y2 do
    for j:=0 to x2 do
      chars[i,j]:=sym+Lo(chars[i,j]);
end;

procedure TEdit0.Draw;
var
  k:byte;
begin
  for k:=0 to Size.Y do
      WriteLine(0,k,Size.X,1,chars[k]);
end;

end.
