unit UFrame2;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  FileCtrl, StdCtrls;

type
  TFrame2 = class(TFrame)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Label5: TLabel;
    CheckBox1: TCheckBox;
    GroupBox1: TGroupBox;
    Label6: TLabel;
    Button1: TButton;
    Label7: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses Unit2;

{$R *.DFM}

procedure TFrame2.Button1Click(Sender: TObject);
var st:string;
begin
  if SelectDirectory('Выберите папку, в которую будет установлена'#13'папка Test тестовой системы.','',st) then
  begin
    if st[Length(st)]<>'\' then st:=st+'\Test' else st:=st+'Test';
    DestDir:=st;
    Label7.Caption:=st;
  end;

end;

end.
