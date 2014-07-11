unit UFrame3;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TFrame3 = class(TFrame)
    Image1: TImage;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
  private
    FLen1:integer;
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TFrame3.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key in ['0'..'9','A'..'Z','a'..'z'] then
  if Length(TEdit(Sender).Text)=TEdit(Sender).MaxLength-1 then
    Edit2.SetFocus

end;

procedure TFrame3.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
  if Key in ['0'..'9','A'..'Z','a'..'z'] then
  if Length(TEdit(Sender).Text)=TEdit(Sender).MaxLength then Key:=#0
end;

end.
