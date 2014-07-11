unit Indicatr;

interface

uses Views,Objects,Drivers,MyLib;

const
  CIndicator = #2#3;

type
  PIndicator = ^TIndicator;
  TIndicator = object(TView)
    numVopr:integer;
    invite:string;
    constructor Init(var bounds: TRect);
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure SetState(AState: word; enable:boolean); virtual;
    procedure SetValue(aNumVopr:integer;n:byte);
  end;

implementation

{ TIndicator }

constructor TIndicator.Init(var Bounds: TRect);
var
  R: TRect;
begin
  TView.Init(Bounds);
  GrowMode := gfGrowLoY + gfGrowHiY;
end;

procedure TIndicator.Draw;
var
  Color: Byte;
  Frame: Char;
  S: String;
  B: TDrawBuffer;
begin
  if State and sfDragging = 0 then
  begin
    Color := GetColor(1);
    Frame := #205;
  end else
  begin
    Color := GetColor(2);
    Frame := #196;
  end;
  MoveChar(B, Frame, Color, Size.X);
  MoveStr(B,invite+Sstr(numVopr)+' ', GetColor(2));
  WriteBuf(0, 0, Size.X, 1, B);
end;

function TIndicator.GetPalette: PPalette;
const
  P: string[Length(CIndicator)] = CIndicator;
begin
  GetPalette := @P;
end;

procedure TIndicator.SetState(AState: Word; Enable: Boolean);
begin
  TView.SetState(AState, Enable);
  if AState = sfDragging then DrawView;
end;

procedure TIndicator.SetValue;
begin
  case n of
    1:invite:=' Вопрос номер: ';
    2:invite:=' Вариант: ';
    3:invite:=' Ваше время: '
  end;
  numVopr:=aNumVopr;
  DrawView;
end;
end.