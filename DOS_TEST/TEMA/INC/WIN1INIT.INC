constructor TWorkWin1.Init;
var
  R:TRect;
  Indicator:PIndicator;
begin
  R.Assign(0,0,80,23);
  TWindow.Init(R,st,0);
  R.Assign(2, Size.Y - 1, 16, Size.Y);
  Indicator := New(PIndicator, Init(R));
  Insert(Indicator);
  Options:=Options or ofTileable;
  GetClipRect(R);
  R.Grow(-1,-1);
  Editor:=New(PEdit1,Init(R,Indicator));
  if Editor=nil then Fail;
  Insert(Editor);
end;
