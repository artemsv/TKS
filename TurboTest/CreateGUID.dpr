program CreateGUID;

{$Apptype console}

uses
  Windows,
  ActiveX,
  ComObj,
  SysUtils;

const
  TestKey='Software\TurboTest';

var f:file of char;
  G:TGUID;
  stW:PWideChar;
  s,st34:string;
  ch:char;
  st:string;
  k:integer;
  Pass:string;
  phk:HKEY;
begin
  Writeln('TurboTest 6.0 Registration');
  Writeln('Enter password:');
  Readln(Pass);
  if Length(Pass)<5 then Halt;
  if not ((Pass[1]='A') and (Pass[5]='M')) then
  begin
    Writeln('Wrong password!!!');
    Writeln('Registration aborted');
    Readln;
    Halt;
  end;

  CoCreateGUID(G);
  st34:=GUIDToString(G);
  RegCreateKey(HKEY_CURRENT_USER,PChar(TestKey+'\LocalServer'),phk);
  RegCloseKey(phk);
  Assign(f,'C:\Windows\StartOpros.exe');
  Reset(f);
  Seek(f,$1b175);
  for k:=2 to 38 do
  begin
    ch:=char(st34[k]);
    Write(f,ch);
  end;
  Close(f);

  RegCreateKey(HKEY_CLASSES_ROOT,PChar('CLSID\'+st34+'\InprocServer32'),phk);
  RegCloseKey(phk);

  Writeln('Registration was completed')
  Readln;
end.
