constructor TEditWin.Init;
var
  R         : TRect;
  Indicator : PINdicator;
  Pw        : PView;
  fn        : PathStr;
begin
  if not SelectTem(fn) then Fail;
  R.Assign(0,0,80,23);
  TWindow.Init(R,'Редактирование',0);
  R.Assign(2, Size.Y - 1, 16, Size.Y);
  Indicator := New(PIndicator, Init(R));
  Insert(Indicator);
  Options:=Options or ofTileable;
  GetClipRect(R);
  R.Grow(-1,-1);
  Pw:=Application^.ValidView(New(PEditor,Init(R,fn,Indicator)));
  if Pw=nil then Fail;
  Insert(Pw);
end;
