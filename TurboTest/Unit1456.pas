unit Unit1456;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask;

type
  TForm1 = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    CBOc: TCheckBox;
    CBDate: TCheckBox;
    CBTime: TCheckBox;
    CBTema: TCheckBox;
    CBGruppa: TCheckBox;
    CBName: TCheckBox;
    CBTeacher: TCheckBox;
    CBNeprav: TCheckBox;
    CBFindNOT: TCheckBox;
    Label1: TLabel;
    EDate1: TMaskEdit;
    EDate2: TMaskEdit;
    ETime1: TMaskEdit;
    ETime2: TMaskEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    CBoxTema: TComboBox;
    Label8: TLabel;
    CBoxGruppa: TComboBox;
    Label9: TLabel;
    EOc: TEdit;
    Label10: TLabel;
    ENeprav: TEdit;
    Label11: TLabel;
    CboxName: TComboBox;
    CBBegin: TCheckBox;
    Label12: TLabel;
    CBoxTeacher: TComboBox;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

end.
