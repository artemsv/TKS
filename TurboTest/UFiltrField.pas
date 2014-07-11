unit UFiltrField;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms,   IniFiles;

type
  TFrmFiltrField = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    GroupBox2: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    procedure FormCreate(Sender: TObject);
  end;

var
  FrmFiltrField: TFrmFiltrField;

implementation

{$R *.DFM}

procedure TFrmFiltrField.FormCreate(Sender: TObject);
var Ini:TIniFile;
begin
  Ini:=TIniFile.Create('test_db.ini');
  CheckBox1.Checked:=Ini.ReadBool('ShowFields','���',true);
  CheckBox2.Checked:=Ini.ReadBool('ShowFields','������',true);
  CheckBox3.Checked:=Ini.ReadBool('ShowFields','���������� �������',false);
  CheckBox4.Checked:=Ini.ReadBool('ShowFields','��������',false);
  CheckBox5.Checked:=Ini.ReadBool('ShowFields','����',true);
  CheckBox6.Checked:=Ini.ReadBool('ShowFields','����',false);
  CheckBox7.Checked:=Ini.ReadBool('ShowFields','������',true);
  CheckBox8.Checked:=Ini.ReadBool('ShowFields','�������������',false);
  CheckBox9.Checked:=Ini.ReadBool('ShowFields','�����',false);
  CheckBox10.Checked:=Ini.ReadBool('ShowFields','������',false);
  Ini.Free;

end;

end.
