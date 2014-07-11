unit UErr;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrmError = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmError: TFrmError;

function Err:integer;

implementation

function Err:integer;
begin
  with TFrmError.Create(Application) do
  begin
    Result:=ShowModal;
    Free;
  end;
end;

{$R *.DFM}

procedure TFrmError.FormCreate(Sender: TObject);
begin
  Label1.Left:=(Width-Label1.Width) div 2
end;

end.
