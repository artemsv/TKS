{$o-}
unit UFrmDesc;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrmDesc = class(TForm)
    GroupBox1: TGroupBox;
    Memo1: TMemo;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmDesc: TFrmDesc;

function GetDescript(var Items:TStringList):boolean;

implementation

{$R *.DFM}
function GetDescript(var Items:TStringList):boolean;
var k:integer;
begin
  Result:=false;
  Items:=nil;
  with TFrmDesc.Create(Application) do
  begin
    if ShowModal=mrOk then
    begin
      Items:=TStringList.Create;
      for k:=0 to Memo1.Lines.Count-1 do
       Items.Add(Memo1.Lines[k]);
      Result:=true;
    end;
    Free;
  end;
end;

end.
