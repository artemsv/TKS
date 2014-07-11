program StartOpros;          //  программа заглушка, устанавливается на
                             //  рабочей станции для нее необходима регистрация
                             //  с помощью программы регистрации RegStartOpros
uses
  IniFiles,
  Registry,
  ActiveX,
  Windows;
{$R RES/OprMain.res}
const
  Empty='{A2671DA0-5F78-11D7-8517-00C0268E488F}';
var
  Path:string;
  Ini:TIniFile;
  d:integer;
  Reg:TRegistry;
  st,st1:string;
  st2:PWideChar;
begin
  if Path=Empty then ;
  Reg:=TRegistry.Create;
  Reg.RootKey:=HKEY_CLASSES_ROOT;
  st:='C'+'L'+'S'+'I'+'D'+'\';
  if not Reg.OpenKey(st+Empty+'\InprocServer32',false) then
  begin
    MessageBox(0,'Программа не зарегистрирована','TurboTest 6.0',MB_ICONWARNING);
    Halt;
  end;
  Reg.CloseKey;
  Reg.Free;
  Ini:=TIniFile.Create('TurboOpros.ini');
  Path:=Ini.ReadString('Root','Path','default');
  Ini.Free;
  WinExec(Pchar(Path+'/TurboOpros.exe'),SW_MAXIMIZE);
end.
