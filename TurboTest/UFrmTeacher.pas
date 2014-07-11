unit UFrmTeacher;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms;

type
  TFrmTeacher = class(TForm)
    GroupBox1: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    ListBox1: TListBox;
    Button3: TButton;
    Button4: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  end;

var
  FrmTeacher: TFrmTeacher;

implementation

uses UFrmAddTchr;

{$R *.DFM}

procedure TFrmTeacher.FormCreate(Sender: TObject);
begin
  ListBox1.Items.LoadFromFile('teachers.dat');
  ListBox1.ItemIndex :=0;
end;

procedure TFrmTeacher.Button3Click(Sender: TObject);
label erd;
begin
erd:
  with TFrmAddTchr.Create(Application) do
  begin
    if ShowModal=mrOk then
    begin
      if ListBox1.Items.IndexOf(Edit1.Text)<>-1 then
      begin
        Application.MessageBox('Такой преподаватель уже имеется!!!','Turbo Test',0);
        Free;
        goto erd
      end;
      if (Edit1.Text<>'') then 
      ListBox1.Items.Add(Edit1.Text);
    end;
    Free;
  end;
  ListBox1.SetFocus;
  ListBox1.ItemIndex:=0;
end;

procedure TFrmTeacher.Button1Click(Sender: TObject);
begin
  LIstBox1.Items.SaveToFile('teachers.dat');
end;

procedure TFrmTeacher.Button4Click(Sender: TObject);
var n:integer;
begin
  n:=ListBox1.ItemIndex;
  ListBox1.Items.Delete(n);
  if n=ListBox1.Items.Count then Dec(n);
  listBox1.ItemIndex:=n;
end;

end.
