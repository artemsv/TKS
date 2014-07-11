unit UFrmDB1;

interface

uses
  Windows, Messages, Classes, SysUtils, Graphics, Controls, StdCtrls, Forms,
  Dialogs, DBCtrls, DB, DBGrids, DBTables, Grids, ExtCtrls;

type
  TForm1 = class(TForm)
    Table1StringField: TStringField;
    Table1SmallintField: TSmallintField;
    Table1SmallintField2: TSmallintField;
    Table1SmallintField3: TSmallintField;
    Table1StringField2: TStringField;
    Table1DateField: TDateField;
    Table1StringField3: TStringField;
    Table1StringField4: TStringField;
    Table1TimeField: TTimeField;
    Table1StringField5: TStringField;
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