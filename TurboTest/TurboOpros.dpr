program TurboOpros;
uses
  Windows,
  IniFiles,
  Macro in 'Macro.pas',
  WinApp in 'WinApp.pas',
  OprMain in 'OprMain.pas',
  OprChild in 'OprChild.pas',
  OprTypes in 'OprTypes.pas',
  MInput in 'MInput.pas',               
  WinDlg in 'WinDlg.pas',
  OprRTF in 'OprRTF.pas',
  UOleRTF in 'UOleRtf.pas',
  WinRTF in 'WinRtf.pas',
  MEdit in 'MEdit.pas',
  MRed in 'MRed.pas',
  MConst in 'MConst.pas',
  MListName in 'MListName.pas',
  MMark in 'MMark.pas',
  WinFunc in 'WinFunc.pas',
  qsort in 'Qsort.pas',
  Streams in 'Streams.pas',
  WinCtrl in 'WinCtrl.pas',
  MProp in 'MProp.pas',
  ActiveX;

begin
  Coinitialize(nil);
  MainWindow:=TOprosMainWindow.Create;
  MainWindow.Show(SW_MAXIMIZE);
  MainWindow.Run;
end.
