program Redactor;

uses MsgBoxMy,MBase,MyLib;

var a:TMyApplication;
begin
  HeapError:=@HeapFunc;
  a.init;
  a.run;
  a.done;
end.