program WININI;
{$APPTYPE CONSOLE}
uses
  IniFiles,
  WIndows,
  SysUtils;
var
  Ini:TIniFile;
  st:string;
begin
  Writeln('Enter Password');
  Readln(st);
  if St<>'xxx2003' then Halt;
  Ini:=TIniFile.Create('system.ini');
  st:=Ini.ReadString('boot','shell','default');
  if MessageBox(0,PChar('���������� EXPLORER?'),nil,MB_ICONQUESTION or MB_YESNO)=ID_YES then
    Ini.WriteString('boot','shell','explorer.exe');
  if MessageBox(0,PChar('���������� Windows 2003?'),nil,MB_ICONQUESTION or MB_YESNO)=ID_YES then
    Ini.WriteString('boot','shell','Win2003.exe');
  Ini.Free
end.
