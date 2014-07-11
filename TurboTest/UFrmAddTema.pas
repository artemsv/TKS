unit UFrmAddTema;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TFrmAddTema = class(TForm)
    GroupBox1: TGroupBox;
    ListBox1: TListBox;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
  private

    { Private declarations }
  public
    Files:TStringLIst;
    { Public declarations }
  end;

var
  FrmAddTema: TFrmAddTema;

function GetTema(var tema,fileName:string):boolean;

implementation

uses Streams;

{$R *.DFM}

function GetTema(var tema,fileName:string):boolean;
begin
  Result:=false;
  with TFrmAddTema.Create(Application) do
  begin
    if ShowModal=mrOk then
    begin
      tema:=ListBox1.Items[ListBox1.ItemIndex];
      fileName:=Files[ListBox1.ItemIndex];
      Result:=true;
    end;
    Free;
  end;
end;

procedure TFrmAddTema.FormCreate(Sender: TObject);
var TF:TTestFile;TH:THeader;TS:TSearchRec;tema:string;
begin
  Files:=TStringList.Create;
  if FindFirst('*.tem',faAnyFile,TS) = 0 then
  begin
    TF:=TTestFile.Create(TS.Name);
    TH:=TF.GetHeader;
    tema:=TH.tema;
    TH.Free;
    TF.Free;
    ListBox1.Items.Add(tema);
    Files.Add(TS.Name);
    while FindNext(TS) = 0 do
    begin
      TF:=TTestFile.Create(TS.Name);
      TH:=TF.GetHeader;
      tema:=TH.tema;
      TH.Free;
      TF.Free;
      ListBox1.Items.Add(tema);
      Files.Add(TS.Name);
    end;
  end;
  SysUtils.FindClose(TS);
  ListBox1.ItemIndex:=0;
end;

end.
