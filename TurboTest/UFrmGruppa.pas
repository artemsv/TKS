unit UFrmGruppa;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms;

type
  TFrmGruppa = class(TForm)
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
  end;

var
  FrmGruppa: TFrmGruppa;

implementation

uses UFrmAddGr, UFrmStudents;

{$R *.DFM}

procedure TFrmGruppa.FormCreate(Sender: TObject);
begin
  ListBox1.Items.LoadFromFile('gruppa.dat');
  ListBox1.ItemIndex:=0;
end;

procedure TFrmGruppa.Button3Click(Sender: TObject);
begin
  ListBox1.Items.SaveToFile('gruppa.dat');
end;

procedure TFrmGruppa.Button1Click(Sender: TObject);
begin
  ListBox1.Items.Delete(ListBox1.ItemIndex);
  ListBox1.SetFocus;
  ListBox1.ItemIndex:=0;
end;

procedure TFrmGruppa.Button2Click(Sender: TObject);
label erd;
begin
erd:
  with TFrmAddGr.Create(Application) do
  begin
    if ShowModal=mrOk then
    begin
      if ListBox1.Items.IndexOf(Edit1.Text)<>-1 then
      begin
        Application.MessageBox('Такая группа уже имеется!!!','Turbo Test',0);
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

procedure TFrmGruppa.Button5Click(Sender: TObject);
var TS:TSearchRec;f1:textFile;st:string;
begin
  AssignFile(f1,'gruppa.dat');
  Rewrite(f1);
  if FindFirst('*.grp',faAnyFile,TS) = 0 then
  begin
    st:=Copy(TS.name,1,Length(TS.name)-4);
    Writeln(f1,st);
    while FindNext(TS) = 0 do
    begin
      st:=Copy(TS.name,1,Length(TS.name)-4);
      Writeln(f1,st);
    end;
  end;
  SysUtils.FindClose(TS);
  CloseFile(f1);
  ListBox1.Items.LoadFromFile('gruppa.dat');
  ListBox1.SetFocus;
  ListBox1.ItemIndex:=0;
end;

procedure TFrmGruppa.Button6Click(Sender: TObject);
begin
  with TFrmStudents.Create(Application) do
  begin
    Caption:='Группа '+ListBox1.Items[ListBox1.ItemIndex];
    FGruppa:=ListBox1.Items[ListBox1.ItemIndex];
    Label2.Caption:='Список учащихся группы ' +
        ListBox1.Items[ListBox1.ItemIndex];
    ListBox2.Items.LoadFromFile(ListBox1.Items[ListBox1.ItemIndex]+'.grp');
    ListBox2.ItemIndex:=0;
    ShowModal;
    Free;
  end;
end;

end.
