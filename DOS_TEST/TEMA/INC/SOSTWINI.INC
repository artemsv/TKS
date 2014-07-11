constructor TSostWin.Init;
var
  R:TRect;
  Indicator:PIndicator;
  Ps:PView;
  fn:PathStr;
  hd:PHdr;
begin
  if n=cmOld then begin if not SelectTem(fn) then Fail end
  else begin if not Titul(hd) then Fail;fn:=StrPas(hd^.fname);end;
  R.Assign(0,0,80,23);
  TWindow.Init(R,'Составление вопросов',0);
  R.Assign(2, Size.Y - 1, 16, Size.Y);
  Indicator := New(PIndicator, Init(R));
  Insert(Indicator);
  Options:=Options or ofTileable;
  GetClipRect(R);R.Grow(-1,-1);
  Ps:=Application^.ValidView(New(PSost,Init(R,fn,Indicator)));
  if Ps=nil then Fail;
  Insert(Ps);
end;
