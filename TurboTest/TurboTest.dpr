program TurboTest;
uses
  SysUtils,
  Windows,
  ActiveX,
  Main in 'Main.pas',
  WinApp in 'winapp.pas',
  MOptions in 'MOptions.pas',
  MEdit in 'medit.pas',
  MConst in 'MConst.pas',
  OleRTF in 'OleRTF.pas',
  WinRTF in 'WinRTF.pas',
  WinFunc in 'WinFunc.pas',
  MSost in 'MSost.pas',
  MRed in 'MRed.pas',
  OleObj in 'OleObj.pas',
  UOleRTF in 'UOleRTF.pas',
  Streams in 'Streams.pas',
  FNewTema in 'FNewTema.pas',
  MInput in 'MInput.pas',
  WinCtrl in 'WinCtrl.pas',
  WinMenu in 'WinMenu.pas',
  MSelTema in 'MSelTema.pas',
  Macro in 'Macro.pas',
  WinDlg in 'WinDlg.pas',
  MProp in 'MProp.pas',
  MTypes in 'mtypes.pas',
  MPrnDlg in 'MPrnDlg.pas';

var st:string;

{TODO : Сделать удаление вопросов }

begin
  CoInitialize(nil);
  MainWindow:=TMyMDI.Create(nil);
  MainWindow.Show(SW_MAXIMIZE);
  st:=ParamStr(1);
  if st<>'' then TMyMDI(MainWindow).FromCommandLine(st);
  MainWindow.Run;
//  SaveMacro;
end.
