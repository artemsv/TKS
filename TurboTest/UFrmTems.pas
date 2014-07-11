unit UFrmTems;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Dialogs;

type
  TFrmTems = class(TForm)
    GroupBox1: TGroupBox;
    btnSave: TButton;
    btnCancel: TButton;
    ListBox1: TListBox;
    btnDelete: TButton;
    btnAdd: TButton;
    btnRefresh: TButton;
    Label1: TLabel;
    ListBox2: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox2Click(Sender: TObject);
  end;

var
  FrmTems: TFrmTems;

implementation

uses Streams, UFrmAddTema;

{$R *.DFM}

procedure TFrmTems.FormCreate(Sender: TObject);
begin
  try
    ListBox1.Items.LoadFromFile('temas.dat');
  except
    On E:Exception do
      MessageBox(Handle,PChar(E.Message),'Turbo Test',0);
  end;
  ListBox1.ItemIndex:=0;
  try
    ListBox2.Items.LoadFromFile('file_tem.dat');
  except
    On E:Exception do
      MessageBox(Handle,PChar(E.Message),'Turbo Test',0);
  end;
  ListBox2.ItemIndex:=0;
end;

procedure TFrmTems.btnDeleteClick(Sender: TObject);
begin
  ListBox1.Items.Delete(ListBox1.ItemIndex);
  ListBox2.Items.Delete(ListBox2.ItemIndex);
  ListBox1.SetFocus;
  ListBox1.ItemIndex:=0;
  ListBox2.ItemIndex:=0;
end;

procedure TFrmTems.btnAddClick(Sender: TObject);
var tema,filename:string;
label erd;
begin
erd:
  if not GetTema(tema,filename) then Exit;
  if ListBox2.Items.IndexOf(ExtractFileName(fileName))<>-1 then
  begin
    MessageBox(Handle,'Такая тема уже имеется!!!','Turbo Test',0);
    goto erd
  end;
  ListBox1.Items.Add(tema);
  ListBox2.Items.Add(fileName);
end;

procedure TFrmTems.btnSaveClick(Sender: TObject);
begin
  ListBox1.Items.SaveToFile('temas.dat');
  ListBox2.Items.SaveToFile('file_tem.dat');
end;

procedure TFrmTems.btnRefreshClick(Sender: TObject);
var TS:TSearchRec;TF:TTestFile;TH:THeader;f1,F2:textFile;st:string;
begin
  AssignFile(f1,'temas.dat');
  Rewrite(f1);
  AssignFile(f2,'file_tem.dat');
  Rewrite(f2);
  if FindFirst('*.tem',faAnyFile,TS) = 0 then
  begin
    TF:=TTestFile.Create(TS.Name);
    TH:=TF.GetHeader;
    Writeln(f2,TS.Name);
    st:=TH.tema;
    WRiteln(f1,st);
    TF.Free;
    while FindNext(TS) = 0 do
    begin
      TF:=TTestFile.Create(TS.Name);
      TH:=TF.GetHeader;
      Writeln(f2,TS.Name);
      st:=TH.tema;
      WRiteln(f1,st);
      TF.Free;
    end;
  end;
  SysUtils.FindClose(TS);
  CloseFile(f1);
  CLoseFile(f2);
  ListBox1.Items.LoadFromFile('temas.dat');
  ListBox2.Items.LoadFromFile('file_tem.dat');
  ListBox1.SetFocus;
  ListBox1.ItemIndex:=0;
  ListBox2.ItemIndex:=0;
end;

procedure TFrmTems.ListBox1Click(Sender: TObject);
begin
  ListBox2.ItemIndex:=ListBox1.ItemIndex
end;

procedure TFrmTems.ListBox2Click(Sender: TObject);
begin
  ListBox1.ItemIndex:=ListBox2.ItemIndex
end;

end.
