unit Unit13;

interface

uses
  Windows, Messages, Classes, SysUtils, Graphics, Controls, StdCtrls, Forms,
  Dialogs, DBCtrls, DB, DBGrids, DBTables, Grids, ExtCtrls;

type
  TForm1 = class(TForm)
    Table1StringField: TStringField;
    Table1FloatField: TFloatField;
    Table1FloatField2: TFloatField;
    Table1FloatField3: TFloatField;
    Table1StringField2: TStringField;
    Table1DateField: TDateField;
    Table1StringField3: TStringField;
    Table1StringField4: TStringField;
    Table1StringField5: TStringField;
    Table1StringField6: TStringField;
    DBGrid1: TDBGrid;
    DBNavigator: TDBNavigator;
    Panel1: TPanel;
    DataSource1: TDataSource;
    Panel2: TPanel;
    Table1: TTable;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Table1.Open;
end;

end.