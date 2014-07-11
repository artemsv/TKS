unit UFrmAddGr;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms;

type
  TFrmAddGr = class(TForm)
    GroupBox1: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  end;

var
  FrmAddGr: TFrmAddGr;


implementation

var kod:boolean;
{$R *.DFM}

procedure TFrmAddGr.Button1Click(Sender: TObject);
begin
  kod:=true;
end;

procedure TFrmAddGr.Button2Click(Sender: TObject);
begin
  kod:=false
end;

procedure TFrmAddGr.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=false;
  if kod then
  begin
    if FileExists(Edit1.Text+'.grp') then
    begin
      case MessageBox(Handle,'Такая группа уже существует.Перезаписать?',
         'Монитор БД',MB_ICONWARNING or MB_YESNO) of
        ID_NO:Exit;
      end
    end;
    FileClose(FileCreate(Edit1.Text+'.grp'))
  end;
  CanClose:=true;
end;

end.
