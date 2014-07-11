unit UFrmOptions;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms;

type
  TFrmOptions = class(TForm)
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    GroupBox2: TGroupBox;
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
    GroupBox3: TGroupBox;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Button3: TButton;
    Label2: TLabel;
    CheckBox12: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox12Click(Sender: TObject);
  end;

var
  FrmOptions: TFrmOptions;
  Ok:boolean;

implementation

uses Dialogs, DBTables, DB, IniFiles, UPassword, DBMain, UFrmDB;

{$R *.DFM}

procedure TFrmOptions.FormCreate(Sender: TObject);
var Ini:TIniFile;
begin
  Ok:=false;
  ComboBox1.Items.LoadFromFile('file_db.dat');
  Ini:=TIniFile.Create('test_db.ini');
  CheckBox1.Checked:=Ini.ReadBool('Options','deleteReport',true);
  ComboBox1.Text:=Ini.ReadString('Options','main','DB01.db');
  // переключатели ReadOnly - полей
  CheckBox2.Checked:=not fioR;
  CheckBox3.Checked:=not ocR;
  CheckBox4.Checked:=not pravR;
  CheckBox5.Checked:=not colR;
  CheckBox6.Checked:=not temaR;
  CheckBox7.Checked:=not dateR;
  CheckBox8.Checked:=not gruppaR;
  CheckBox9.Checked:=not teacherR;
  CheckBox10.Checked:=not timeR;
  CheckBox11.Checked:=not badstrR;
  CheckBox12.Checked:=not InsDelR;
  Ini.Free;
end;

procedure TFrmOptions.Button1Click(Sender: TObject);
var Ini:TIniFile;
begin
  Ok:=true;
end;

procedure TFrmOptions.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:=false;
  if Ok then
  begin
    if not FileExists(ComboBox1.Text+'.db') then
       MessageBox(Handle,PChar('Файла базы данных '+
       ComboBox1.Text+' не существует!'),'Turbo Test',0)
    else CanClose:=true;
    Exit;
  end;
  CanClose:=true;
end;

procedure TFrmOptions.Button2Click(Sender: TObject);
begin
  Ok:=false;
end;

procedure TFrmOptions.FormClose(Sender: TObject; var Action: TCloseAction);
var Ini:TIniFile;
begin
  if not Ok then Exit;
  Ini:=TIniFile.Create('test_db.ini');
  Ini.WriteBool('Options','deleteReport',CheckBox1.Checked);
  Ini.WriteString('Options','main',ComboBox1.Text);
  Ini.Free;

  fioR:=not CheckBox2.Checked;
  ocR:=not CheckBox3.Checked;
  pravR:=not CheckBox4.Checked;
  colR:=not CheckBox5.Checked;
  temaR:=not CheckBox6.Checked;
  dateR:=not CheckBox7.Checked;
  gruppaR:=not CheckBox8.Checked;
  teacherR:=not CheckBox9.Checked;
  timeR:=not CheckBox10.Checked;
  badstrR:=not CheckBox11.Checked;

  InsDelR:=not CheckBox12.Checked;

end;

procedure TFrmOptions.Button3Click(Sender: TObject);
var st,st1:string;FTable:TTable;f:textFile;
label dfr;
begin
  st:='';
dfr:
  if not InputQuery('Turbo Test','Введите новое имя файла базы даных',st) then Exit;
  if FileExists(st+'.db') then
  case
    MessageBox(Handle,'Такой файл уже существует.Заменить?','Turbo Test',
                             MB_YESNOCANCEL) of
    ID_CANCEL : Exit;
    ID_YES:
      begin
        ComboBox1.Items.Delete(ComboBox1.Items.IndexOf(st));
        SysUtils.DeleteFile(st+'.db');
      end;
    ID_NO:goto dfr
  end;
  FTable:=TTable.Create(Application);
  FTable.DatabaseName:=GetCurrentDir;
  FTable.TableName:=st+'.db';
  FTable.TableType:=ttParadox;
  With FTable.FieldDefs do begin
    Add('ФИО',ftString,25,false);
    Add('Оценка',ftSmallInt,0,false);
    Add('Прав',ftSmallInt,0,false);
    Add('Вопросов',ftSmallInt,0,false);
    Add('Тема',ftString,20,false);
    Add('Дата',ftDate,0,false);
    Add('Группа',ftString,7,false);
    Add('Преподаватель',ftString,20,false);
    Add('Время',ftTime,0,false);
    Add('Неправ',ftString,100,false);    
  end;
  FTable.CreateTable;
  FTable.Open;
  Ftable.Close;
  st1:=ComboBox1.Text;                        //  просто сохранили
  ComboBox1.Items.Add(st);
  ComboBox1.Text :=st1;                       //  восстановили
  AssignFIle(f,'file_db.dat');
  Append(f);
  Writeln(f,st);
  CLoseFile(f);
end;

procedure TFrmOptions.CheckBox2Click(Sender: TObject);
begin
  if TCheckBox(Sender).Checked then
  if Visible then
  if not GetPassword then TCheckBox(Sender).Checked:=false;
end;


procedure TFrmOptions.CheckBox12Click(Sender: TObject);
begin
  if TCheckBox(Sender).Checked then
  if Visible then
  if not GetPassword then TCheckBox(Sender).Checked:=false;
end;

end.
