unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Label2: TLabel;
    Label1: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormPaint(Sender: TObject);
  private
    FTim:integer;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Unit2;

{$R *.DFM}

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  inc(FTim);
  Timer1.Enabled:=false;
  with TForm2.Create(Application) do
  begin
   ShowModal;
   Free;
  end;
  Close;
end;

procedure TForm1.FormPaint(Sender: TObject);
var k:integer;
begin
  for k:=0 to Height do
  begin
    Canvas.MoveTo(0,k);
    Canvas.Pen.Color:=(255 - k div 3);
    Canvas.LineTo(Width,k);
  end;

end;

end.
