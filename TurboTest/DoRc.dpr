program DoRc;
uses
  WIndows,
  SysUtils;

var st:string;
begin
  st:=ParamStr(1);
  MessageBox(0,PChar(st),nil,0);

end.
