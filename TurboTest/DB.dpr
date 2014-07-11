program DB;                                 //  дата создания : 13.12.02.

uses
  Forms,
  Windows,
  DBMain in 'DBMain.pas' {FrmMain},
  UFrmTems in 'UFrmTems.pas' {FrmTems},
  UFrmGruppa in 'UFrmGruppa.pas' {FrmGruppa},
  UFrmAddGr in 'UFrmAddGr.pas' {FrmAddGr},
  UFrmTeacher in 'UFrmTeacher.pas' {FrmTeacher},
  UFrmAddTchr in 'UFrmAddTchr.pas' {FrmAddTchr},
  UFiltfRec in 'UFiltfRec.pas' {FrmFiltrRec},
  UFiltrField in 'UFiltrField.pas' {FrmFiltrField},
  UFrmDB in 'UFrmDB.pas' {FrmDB},
  UFrmReport in 'UFrmReport.pas' {FrmReport},
  Streams in 'Streams.pas',
  UFrmOptions in 'UFrmOptions.pas' {FrmOptions},
  UFrmDesc in 'UFrmDesc.pas' {FrmDesc},
  UFrmStudents in 'UFrmStudents.pas' {FrmStudents},
  UFrmAddStudent in 'UFrmAddStudent.pas' {FrmAddStudent},
  UPassword in 'UPassword.pas' {FrmPassword},
  UFrmAddTema in 'UFrmAddTema.pas' {FrmAddTema};

{$R *.RES}

begin
  if FindWindow(nil,'TurboTest Status Window')<>0 then
  begin
    MessageBox(0,'Процесс тестирования не завершен!','TurboTest',MB_ICONWARNING);
    Halt;
  end;

  Application.Initialize;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
