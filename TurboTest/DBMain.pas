unit DBMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, Db, ComCtrls, ToolWin, ImgList;

var
    fioR:boolean=true;
    ocR:boolean=true;
    pravR:boolean=true;
    colR:boolean=true;
    temaR:boolean=true;
    dateR:boolean=true;
    gruppaR:boolean=true;
    teacherR:boolean=true;
    timeR:boolean=true;
    badStrR:boolean=true;

    InsDelR:boolean=true;

type
  TFrmMain = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    DataSource1: TDataSource;
    N11: TMenuItem;
    N2: TMenuItem;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ImageList1: TImageList;
    N12: TMenuItem;
    N13: TMenuItem;
    ToolButton9: TToolButton;
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure ToolButton9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

uses ShellAPI, DBTables, UFrmTems, UFrmGruppa, UFrmTeacher, UFrmDB,
  UFrmReport, UFrmOptions, IniFiles, WinFunc;

{$R *.DFM}

procedure TFrmMain.N4Click(Sender: TObject);
begin
  Close
end;

procedure TFrmMain.N5Click(Sender: TObject);
begin
  ShellAbout(Handle,'Монитор БД',
     'Монитор базы данных тестовой системы'#13'Copyright (c) 2000,2003 by Artem Sokolov',0);
end;

procedure TFrmMain.N6Click(Sender: TObject);
begin
  with TFrmReport.Create(Application) do ShowModal;
end;

procedure TFrmMain.N9Click(Sender: TObject);
begin
  with TFrmGruppa.Create(Application) do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TFrmMain.N10Click(Sender: TObject);
begin
  with TFrmTeacher.Create(Application) do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TFrmMain.N8Click(Sender: TObject);
begin
  with TFrmTems.Create(Application) do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TFrmMain.N11Click(Sender: TObject);
var Ini:TIniFile;st:string;
begin
  Ini:=TIniFile.Create('test_db.ini');
  st:=Ini.ReadString('Options','main','db01')+'.db';
  if not FileExists(st) then
  begin
    MessageBox(Handle,PChar('Файл базы данных по умолчанию '+
      st+' не найден.'),'Монитор БД',16);
    Exit;
  end;
  with TFrmDB.Create(Application) do
  begin
    ShowModal;
    Free
  end;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
var x,y:integer;
begin
//  Registrated(HandlE);
  Top:=0;
  Left:=0;
  Width:=GetSystemMetrics(SM_CXSCREEN);
  Height:=GetSystemMetrics(SM_CYCAPTION)+GetSystemMetrics(SM_CYMENU)+6+
  ToolBar1.Height;
  if FileExists('report.dat') then Exit;
  ToolButton1.Enabled:=false;
  ToolButton9.Enabled:=false;
  N6.Enabled:=false;
end;

procedure TFrmMain.N13Click(Sender: TObject);
begin
  with TFrmOptions.Create(Application) do
  begin
    ShowModal;
    Free;
  end;
end;

procedure TFrmMain.ToolButton9Click(Sender: TObject);
begin
  if FileExists('report.dat') then
  begin
    DeleteFile('report.dat');
    ToolButton9.Enabled:=false;
    ToolButton1.Enabled:=false;
  end;
end;

end.

