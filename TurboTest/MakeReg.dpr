program MakeReg;

//  программа регистрирует комплекс тестирования TurboTest 6.0

//  создает ветви в реестре:

//  HKEY_CURRENT_USER\Software\TurboTest\LocalServer

//  HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\Microsoft\Windows


uses
  Windows,
  SysUtils;

const
  TestKey='Software\TurboTest';
var
  phk:HKEY;

begin
  RegCreateKey(HKEY_CURRENT_USER,PChar(TestKey+'\LocalServer'),phk);
  RegCloseKey(phk);
  RegCreateKey(HKEY_LOCAL_MACHINE,'System\CurrentControlSet\Services\Microsoft\Windows',phk);
  RegCloseKey(phk);
  MessageBox(0,'TurboTest зарегистрирован успешно.','TurboTest',0);
end.
 