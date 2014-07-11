unit net1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
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
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    Button2: TButton;
    OpenDialog1: TOpenDialog;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    CheckBox16: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    st:string;
    Cat:string;
    procedure SetShell(name,shell:string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses IniFiles,FileCtrl;

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  CheckBox1.Checked:=false;
  CheckBox2.Checked:=false;
  CheckBox3.Checked:=false;
  CheckBox4.Checked:=false;
  CheckBox5.Checked:=false;
  CheckBox6.Checked:=false;
  CheckBox7.Checked:=false;
  CheckBox8.Checked:=false;
  CheckBox9.Checked:=false;
  CheckBox10.Checked:=false;
  CheckBox11.Checked:=false;
  CheckBox12.Checked:=false;
  CheckBox13.Checked:=false;
  CheckBox14.Checked:=false;
  CheckBox15.Checked:=false;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  CheckBox1.Checked:=true;
  CheckBox2.Checked:=true;
  CheckBox3.Checked:=true;
  CheckBox4.Checked:=true;
  CheckBox5.Checked:=true;
  CheckBox6.Checked:=true;
  CheckBox7.Checked:=true;
  CheckBox8.Checked:=true;
  CheckBox9.Checked:=true;
  CheckBox10.Checked:=true;
  CheckBox11.Checked:=true;
  CheckBox12.Checked:=true;
  CheckBox13.Checked:=true;
  CheckBox14.Checked:=true;
  CheckBox15.Checked:=true;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if not OpenDialog1.Execute then Exit;
  st:=OpenDialog1.FileName;
  Label3.Caption:=st;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Cat:='';
  if not SelectDirectory('Выберите папку-приемник на станции','',Cat) then Exit;
  Label4.Caption:=Cat;
end;

procedure TForm1.SetShell(name, shell: string);
var Ini:TIniFile;
begin
  try
    Ini:=TIniFile.Create('\\'+name+'\c\Windows\System.ini');
    Ini.WriteString('boot','shell',shell);
    Ini.Free;
  except
    MessageBox(Handle,PChar('Станция '+name+' не работает.'),nil,0);
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var k:integer;
begin
  for k:=0 to ComponentCount-1 do
    if Components[k] is TCheckBox then
      if TCheckBox(Components[k]).Checked then
        SetShell(TCheckBox(Components[k]).Caption,'explorer.exe');
end;

procedure TForm1.Button7Click(Sender: TObject);
var k:integer;
begin
  for k:=0 to ComponentCount-1 do
    if Components[k] is TCheckBox then
      if TCheckBox(Components[k]).Checked then
        SetShell(TCheckBox(Components[k]).Caption,'Win2003.exe');
end;

end.
