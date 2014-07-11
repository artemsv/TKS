program Reg;

uses
  ActiveX,
  Windows;

const
  TestKey='Software\TurboTest';
var
  phk:hkey;
  lpSystemInfo: TSystemInfo;
  G:TGUID;
  st:PWideChar;
  s:string;
begin
  CoCreateGUID(G);
  ST:='localserver';
 // StringFromGUID2(G,st,40);
//
  GetSystemInfo(lpSystemInfo);
  RegCreateKey(HKEY_CURRENT_USER,PChar(TestKey+'\'+st), phk);
  RegCloseKey(phk);
end.
