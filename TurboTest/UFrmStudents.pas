unit UFrmStudents;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrmStudents = class(TForm)
    GroupBox1: TGroupBox;
    ListBox2: TListBox;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  public
    FGruppa:string;
  end;

var
  FrmStudents: TFrmStudents;

implementation

uses UFrmAddStudent;

{$R *.DFM}

procedure TFrmStudents.Button4Click(Sender: TObject);
var n:integer;
begin
  n:=ListBox2.ItemIndex;
  ListBox2.Items.Delete(ListBox2.ItemIndex);
  if n=ListBox2.Items.Count then Dec(n);
  listBox2.ItemIndex:=n;
end;

procedure TFrmStudents.Button2Click(Sender: TObject);
begin
  ListBox2.Items.SaveToFile(FGruppa+'.grp')
end;

procedure TFrmStudents.Button3Click(Sender: TObject);
begin
  with TFrmAddStudent.Create(Application) do
  begin
    if ShowModal=mrOk then
    begin
      ListBox2.Items.AddStrings(TempListBox.Items);
      ListBox2.Items.Add(Edit1.Text);
    end else
      ListBox2.Items.AddStrings(TempListBox.Items);
    TempListBox.Free;    
    Free;
  end;
end;

end.
