unit UStatus;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,IniFiles,
  Macro,StdCtrls, Buttons, ExtCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    btnBeginTest: TButton;
    btnEndTest: TButton;
    BitBtn1: TBitBtn;
    Timer1: TTimer;
    StatusBar1: TStatusBar;
    procedure btnBeginTestClick(Sender: TObject);
    procedure btnEndTestClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    tim:integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}


procedure TForm1.btnBeginTestClick(Sender: TObject);
var Ini:TIniFile;b:boolean;
begin
  Ini:=TIniFile.Create(Path+'\info.ini');
  Ini.WriteBool('Root','test',true);
  Ini.UpdateFile;
  Ini.Free;
  btnBeginTest.Enabled:=false;
  btnEndTest.Enabled:=true;
  Timer1.Enabled:=true;
end;

procedure TForm1.btnEndTestClick(Sender: TObject);
var Ini:TIniFile;b:boolean;
begin
  Ini:=TIniFile.Create(Path+'\info.ini');
  Ini.WriteBool('Root','test',false);
  Ini.UpdateFile;
  Ini.Free;
  btnEndTest.Enabled:=false;
  btnBeginTest.Enabled:=true;
  Timer1.Enabled:=false;
  StatusBar1.SimpleText:='';
end;

procedure TForm1.FormCreate(Sender: TObject);
var Ini:TIniFile;b:boolean;
begin
  Tim:=0;
  Timer1.Enabled:=false;
  Ini:=TIniFile.Create(Path+'\info.ini');
  b:=Ini.ReadBool('Root','test',false);
  Ini.Free;
  if b then btnBeginTest.Enabled:=false else
  btnEndTest.Enabled:=false;
  StatusBar1.SimpleText:='';
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  inc(tim);
  if tim=1000000 then Tim:=0;
  if tim mod 2 =0 then
    StatusBar1.SimpleText:=''
  else
    StatusBar1.SimpleText:= 'Идет процесс тестирования...'

end;

procedure TForm1.BitBtn1Click(Sender: TObject);
var Ini:TIniFile;b:boolean;
begin
  Ini:=TIniFile.Create(Path+'\info.ini');
  Ini.WriteBool('Root','test',true);
  Ini.UpdateFile;
  Ini.Free;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var Ini:TIniFile;b:boolean;
begin
  Ini:=TIniFile.Create(Path+'\info.ini');
  Ini.WriteBool('Root','test',false);
  Ini.UpdateFile;
  Ini.Free;

end;

end.
