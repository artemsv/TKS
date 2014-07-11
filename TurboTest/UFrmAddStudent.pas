unit UFrmAddStudent;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrmAddStudent = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  public
    TempListBox:TListBox;
  end;

var
  FrmAddStudent: TFrmAddStudent;

implementation

{$R *.DFM}

procedure TFrmAddStudent.FormCreate(Sender: TObject);
begin
  TempListBox:=TListBox.Create(Self);
  TempListBox.Parent:=Self;
  TempListBox.Visible:=false;
end;

procedure TFrmAddStudent.Button1Click(Sender: TObject);
begin
  if Edit1.Text='' then Exit;
  TempListBox.Items.Add(Edit1.Text);
  Edit1.Text:='';
  Edit1.SetFocus;
end;

end.
