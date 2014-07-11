unit DrDrop;                     {дата начальной версии     : 21.01.02}
                                 {дата окончатальной версии : xx.01.02}

interface

uses  Drivers,Views,Objects,Types;

type
  PMover = ^TMover;
  TMover = object(TView)
    buffer:TBuffer;
    len:byte;                           {длина подстроки в буфере}
    constructor Init(AWhere: TPoint; ABuffer:TBuffer;ALen:byte);
    procedure Draw; virtual;
  end;

implementation

constructor TMover.Init(AWhere: TPoint; ABuffer:TBuffer;Alen:byte);
var
  R: TRect;
  k:byte;
begin
  R.Assign(AWhere.X, AWhere.Y, AWhere.X +ALen, AWhere.Y +1);
  inherited Init(R);
  len:=ALen;
  for k:=0 to len-1 do buffer[k]:=ABuffer[k];
  SetState(sfShadow, True);
end;

procedure TMover.Draw;
var
  B: TDrawBuffer;
begin
  WriteLine(0,0,Size.X,1,Buffer);
end;

end.