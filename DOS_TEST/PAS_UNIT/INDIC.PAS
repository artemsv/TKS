unit Indic;

interface

uses Views,Objects,Drivers;

const
  CIndicator = #2#3;

type
  PIndicator = ^TIndicator;
  TIndicator = object(TView)
    Location: TPoint;
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure SetValue(ALocation: TPoint; AModified: Boolean);
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
  L: array[0..1] of Longint;
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
  {if Modified then WordRec(B[0]).Lo := 15;}
  L[0] := Location.Y;
  L[1] := Location.X;
  FormatStr(S, ' %d:%d ', L);
  MoveStr(B[8 - Pos(':', S)],S, Color);
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

procedure TIndicator.SetValue(ALocation: TPoint; AModified: Boolean);
begin
  if (Longint(Location) <> Longint(ALocation))then
  begin
    Location := ALocation;
    DrawView;
  end;
end;
end.