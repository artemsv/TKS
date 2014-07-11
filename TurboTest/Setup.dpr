program Setup;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2},
  Unit3 in 'Unit3.pas' {Form3},
  UFrame3 in 'UFrame3.pas' {Frame3: TFrame},
  UFrmProgress in 'UFrmProgress.pas' {FrmProgress},
  WinShell in 'WinShell.pas',
  UThread in 'UThread.pas',
  UFrame1 in 'UFrame1.pas' {Frame1: TFrame},
  UFrame2 in 'UFrame2.pas' {Frame2: TFrame},
  UDir in 'UDir.pas' {Form4},
  UErr in 'UErr.pas' {FrmError};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TFrmError, FrmError);
  Application.Run;
end.
