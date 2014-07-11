{$o-}
unit UFrmReport;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBCtrls, ExtCtrls, Grids, DBGrids, Db, DBTables, Buttons, Menus;

type
  TFrmReport = class(TForm)
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    Panel1: TPanel;
    DBNavigator1: TDBNavigator;
    SpeedButton1: TSpeedButton;
    SpeedButton4: TSpeedButton;
    PrinterSetupDialog1: TPrinterSetupDialog;
    SpeedButton2: TSpeedButton;
    PrintDialog1: TPrintDialog;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
  private
    data,gruppa,tema,teacher:string;
    colVopr:integer;
    FTable:TTable;
    WasAdded:boolean;
    PixelsInInchx: integer;
    LineHeight: Integer;
   { Keeps track of vertical space in pixels, printed on a page }
    AmountPrinted: integer;
   { Number of pixels in 1/10 of an inch. This is used for line spacing }
    TenthsOfInchPixelsY: integer;
    procedure PrintLine(Items: TStringList);
    procedure PrintColumnNames;
    procedure PrintHeader;
  public
    { Public declarations }
  end;

var
  FrmReport: TFrmReport;

implementation

uses Printers, IniFiles, DBMain, AbortFrm;

{$R *.DFM}

procedure TFrmReport.FormCreate(Sender: TObject);
var f:textFile;date,gruppa,teacher:string;k:integer;
    tema,name,badstr,time:string;oc,colVopr,prav:integer;
begin
  if not FileExists('report.dat') then Close;
  Width:=GetSystemMetrics(SM_CXSCREEN);
  WasAdded:=false;
  FTable:=TTable.Create(Application);
  DataSource1.DataSet:=FTable;
  FTable.DatabaseName:=GetCurrentDir;
  FTable.TableName:='temp.db';
  FTable.TableType:=ttParadox;
  With FTable.FieldDefs do begin
    Add('ФИО',ftString,25,false);
    Add('Оценка',ftSmallInt,0,false);
    Add('Прав',ftSmallInt,0,false);
    Add('Вопросов',ftSmallInt,0,false);
    Add('Тема',ftString,20,false);
    Add('Дата',ftDate,0,false);
    Add('Группа',ftString,7,false);
    Add('Преподаватель',ftString,20,false);
    Add('Время',ftTime,0,false);
    Add('Неправ',ftString,100,false);
  end;
  FTable.CreateTable;
  FTable.Open;
  AssignFile(f,'report.dat');
  try
    try
      Reset(f);
    except
      MessageBox(Handle,'Ошибка доступа к файлу REPORT.DAT!','Turbo Test',
        MB_ICONERROR);
      Close;
      Exit
    end;
    while not eof(f) do
    begin
      Readln(f,name);
      Readln(f,oc);
      Readln(f,prav);
      Readln(f,colVopr);
      Readln(f,date);
      Readln(f,tema);
      Readln(f,gruppa);
      Readln(f,teacher);
      Readln(f,badstr);
      Readln(f,time);

      FTable.Insert;
      FTable['ФИО']:=name;
      FTable['Оценка']:=oc;
      FTable['Прав']:=prav;
      FTable['Вопросов']:=colVopr;
      FTable['Тема']:=tema;
      FTable.Fields.Fields[5].AsString:=date;
      FTable['Группа']:=gruppa;
      FTable['Преподаватель']:=teacher;
      FTable.Fields.Fields[8].AsString:=time;
      FTable['Неправ']:=badstr;
      FTable.Post;
    end;
  finally
    CloseFile(f);
  end;
  for k:=0 to FTable.FieldCount-1 do
    FTable.Fields.Fields[k].ReadOnly:=true;
end;

procedure TFrmReport.SpeedButton1Click(Sender: TObject);
var Ini:TIniFile;MainDB,Path:string;MainTable:TTable;k:integer;
begin
  MainTable:=TTable.Create(Application);
  Ini:=TIniFile.Create('test_db.ini');
  MainTable.TableName:=Ini.ReadString('Options','main','default.db')+'.db';
  MainTable.DatabaseName:=GetCurrentDir;//Ini.ReadString('RootDir','path','C:\');
  Ini.Free;
  MainTable.TableType:=ttDefault;
  try
    MainTable.Open;
  except
    On E:EXception do
    begin
      MessageBox(Handle,PChar('Ошибка при открытии файла базы данных'+#13+
             string(MainTable.TableName)),'Монитор ДБ',16);
      Exit;
    end;
  end;
  MainTable.BatchMove(FTable,batAppend);
  MainTable.Close;
  MessageBox(Handle,'Операция завершена успешно.','Turbo Test',MB_ICONINFORMATION);
  WasAdded:=true;
end;

procedure TFrmReport.FormClose(Sender: TObject; var Action: TCloseAction);
var Ini:TIniFile;
begin
   FTable.Close;
//   DeleteFile('temp.dbf');
   if not WasAdded then Exit;          // файл отчета не доьавили в базу
   Ini:=TIniFile.Create('test_db.ini');
   if Ini.ReadBool('Options','deleteReport',true) then
   begin
     DeleteFile('report.dat');
     FrmMain.ToolButton1.Enabled:=false;
     FrmMain.N6.Enabled:=false;
   end;
   Ini.Free;
end;

procedure TFrmReport.SpeedButton2Click(Sender: TObject);
begin
  PrinterSetupDialog1.Execute
end;

procedure TFrmReport.PrintColumnNames;
var
  ColNames: TStringList;
begin
  { Create a TStringList to hold the column names and the
    positions where the width of each column is based on values
    in the TEdit controls. }
  ColNames := TStringList.Create;
  try
    // Print the column headers using a bold/underline style
    Printer.Canvas.Font.Style := [fsBold, fsUnderline];

    with ColNames do
    begin
      // Store the column headers and widths in the TStringList object
      AddObject('Ф.И.О.',  pointer((30)));
      AddObject('Оценка', pointer(19));
      AddObject('Прав',pointer(30));
//      AddObject('CITY',       pointer(10));
  //    AddObject('STATE',      pointer(10));
    //  AddObject('ZIP',        pointer(StrToInt(edtZip.Text)));
    end;

    PrintLine(ColNames);
    ColNames.Clear;
    Printer.Canvas.Font.Style := [];
    ColNames.AddObject('          ',pointer(10));
    PrintLine(ColNames);
  finally
    ColNames.Free;   // Free the column name TStringList instance
  end;
end;

procedure TFrmReport.PrintLine(Items: TStringList);
var
  OutRect: TRect;
  Inches: double;
  i: integer;
begin
  // First position the print rect on the print canvas
  OutRect.Left := 0;
  OutRect.Top := AmountPrinted;
  OutRect.Bottom := OutRect.Top + LineHeight;
  With Printer.Canvas do
    for i := 0 to Items.Count - 1 do
    begin
      Inches := longint(Items.Objects[i]) * 0.1;
      // Determine Right edge
      OutRect.Right := OutRect.Left + round(PixelsInInchx*Inches);
      if not Printer.Aborted then
       // Print the line
        TextRect(OutRect, OutRect.Left, OutRect.Top, Items[i]);
      // Adjust right edge
      OutRect.Left := OutRect.Right;
    end;
 { As each line prints, AmountPrinted must increase to reflect how
   much of a page has been printed on based on the line height. }
  AmountPrinted := AmountPrinted + TenthsOfInchPixelsY*2;
end;

procedure TFrmReport.SpeedButton3Click(Sender: TObject);
var
  Items: TStringList;
begin
  if  not PrintDialog1.Execute then Exit;
  FTable.First;
  Printer.Canvas.Font.Size:=12;
  Items := TStringList.Create;
  try
    PixelsInInchx := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
    TenthsOfInchPixelsY := GetDeviceCaps(Printer.Handle,LOGPIXELSY) div 10;
    AmountPrinted := 0;
    Enabled := false; // Disable the parent form
    try
      Printer.BeginDoc;
//      AbortForm:=TAbortForm.Create(Application);
  //    AbortForm.Show;
      Application.ProcessMessages;
      { Calculate the line height based on text height using the
        currently rendered font }
      LineHeight := Printer.Canvas.TextHeight('X')+4*TenthsOfInchPixelsY;
      PrintHeader;
      PrintColumnNames;
      { Store each field value in the TStringList as well as its
        column width }
      Ftable.First;
      while (not FTable.Eof) or Printer.Aborted do
      begin
        Application.ProcessMessages;
        with Items do
        begin
          AddObject(FTable.FieldByName('ФИО').AsString,pointer(33));
          AddObject(FTable.FieldByName('Оценка').AsString,pointer(18));
          AddObject(FTable.FieldByName('Прав').AsString,
                        pointer(27));
        end;
        PrintLine(Items);
        { Force print job to begin a new page if printed output has
          exceeded page height }
        if AmountPrinted + LineHeight > Printer.PageHeight then
        begin
          AmountPrinted := 0;
          if not Printer.Aborted then
            Printer.NewPage;
          PrintColumnNames;
        end;
        Items.Clear;
        FTable.Next;
      end;
    //  AbortForm.Hide;
      if not Printer.Aborted then
        Printer.EndDoc;
    finally
      Enabled := true;
    end;
  finally
    Items.Free;
  end;
end;

procedure TFrmReport.PrintHeader;
var Items:TStringList;
begin
  Items:=TStringList.Create;
  Items.AddObject('Дата:   ',pointer(20));
  Items.AddObject(FTable.Fields.Fields[5].AsString,pointer(10));
  PrintLine(Items);
  Items.Clear;

  Items.AddObject('Группа:   ',pointer(20));
  Items.AddObject(FTable.Fields.Fields[6].AsString,pointer(10));
  PrintLine(Items);
  Items.Clear;

  Items.AddObject('Преподаватель:   ',pointer(20));
  Items.AddObject(FTable.Fields.Fields[7].AsString,pointer(30));
  PrintLine(Items);
  Items.Clear;

  Items.AddObject('Тема:',pointer(20));
  Items.AddObject(FTable.Fields.Fields[4].AsString,pointer(30));
  PrintLine(Items);
  Items.Clear;

  Items.AddObject('Всего вопросов:   ',pointer(20));
  Items.AddObject(FTable.Fields.Fields[3].AsString,pointer(10));
  PrintLine(Items);
  Items.Clear;

  Items.AddObject('         ',pointer(20));
  PrintLine(Items);
  Items.Clear;
end;
procedure TFrmReport.N4Click(Sender: TObject);
begin
  Close;
end;

end.

