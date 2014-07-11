unit UPassword;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrmPassword = class(TForm)
    GroupBox1: TGroupBox;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPassword: TFrmPassword;

function GetPassword:boolean;

implementation

var kod:boolean;

{$R *.DFM}
function GetPassword:boolean;
begin
  with TFrmPassword.Create(Application) do
  begin
    if ShowModal=mrOk then Result:=true else Result:=false;
    Free;
  end;
end;

procedure TFrmPassword.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose:=true;
  if kod then
    if Edit1.Text<>'DB-TEST' then
    begin
      MessageBox(Handle,'Пароль не верен!','Turbo Test',0);
      Edit1.SetFocus;
      CanClose:=false;
    end
end;

procedure TFrmPassword.Button1Click(Sender: TObject);
begin
  kod:=true
end;

procedure TFrmPassword.Button2Click(Sender: TObject);
begin
  kod:=false;
end;

end.
