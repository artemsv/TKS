{$o-}
unit UFrmDB;

interface

uses
  Windows, Messages, Classes, SysUtils, Graphics, Controls, StdCtrls, Forms,
  Dialogs, DBCtrls, DB, DBGrids, DBTables, Grids, ExtCtrls, Buttons, Menus;

const
  Arr:array[0..9] of integer=(13,6,6,6,10,7,5,10,100,10);
type
  setB=set of byte;

type
  TFrmDB = class(TForm)
    fioF: TStringField;
    ocF: TSmallintField;
    pravF: TSmallintField;
    colF: TSmallintField;
    temaF: TStringField;
    dateF: TDateField;
    gruppaF: TStringField;
    teacherF: TStringField;
    timeF: TTimeField;
    badstrF: TStringField;
    DBGrid1: TDBGrid;
    DBNavigator: TDBNavigator;
    Panel1: TPanel;
    DataSource1: TDataSource;
    Panel2: TPanel;
    Table1: TTable;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    PrinterSetupDialog1: TPrinterSetupDialog;
    PrintDialog1: TPrintDialog;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Table1FilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure N4Click(Sender: TObject);
  private
    PixelsInInchx: integer;
    LineHeight: Integer;
    AmountPrinted: integer;
    TenthsOfInchPixelsY: integer;

    Modified:boolean;

    OC:integer;
    data1,data2:string;
//    n1,n2,n3,m1,m2,m3:integer;
    time1,time2:string;
    tim1,tim2,dat1,dat2:TDateTime;
    t1,t2,t3,q1,q2,q3:integer;
    tema:string;
    fio:string;
    teacher:string;
    gruppa:string;
    badStr:string;
    badS:setB;
    beginIF:boolean;              // true-поле Имя ищется только с начала
    FindNOT:boolean;              // флаг обратного поиска

    fioBool:boolean;
    ocBool:boolean;
    pravBool:boolean;
    colBool:boolean;
    temaBool:boolean;
    dateBool:boolean;
    gruppaBool:boolean;
    teacherBool:boolean;
    timeBool:boolean;
    badStrBool:boolean;
    function Bad(st:string):boolean;
    procedure PrintColumnNames;
    procedure PrintLine(Items: TStringList);
    { private declarations }
  public
    { public declarations }
  end;

var
  FrmDB: TFrmDB;

implementation

uses UFiltrField, Printers, UFiltfRec, IniFiles, UFrmDesc, DBMain;

{$R *.DFM}

procedure TFrmDB.FormCreate(Sender: TObject);
var Ini:TIniFile;st:string;
begin
  Modified:=false;
  Ini:=TIniFile.Create('test_db.ini');
  Width:=GetSystemMetrics(SM_CXSCREEN);
  fioBool:=Ini.ReadBool('ShowFields','ФИО',true);
  ocBool:=Ini.ReadBool('ShowFields','Оценка',true);
  pravBool:=Ini.ReadBool('ShowFields','Правильных ответов',true);
  colBool:=Ini.ReadBool('ShowFields','Вопросов',true);
  temaBool:=Ini.ReadBool('ShowFields','Тема',true);
  dateBool:=Ini.ReadBool('ShowFields','Дата',true);
  gruppaBool:=Ini.ReadBool('ShowFields','Группа',false);
  teacherBool:=Ini.ReadBool('ShowFields','Преподаватель',false);
  timeBool:=Ini.ReadBool('ShowFields','Время',false);
  badStrBool:=Ini.ReadBool('ShowFields','Неправ',false);

  Table1.DatabaseName := GetCurrentDir;
  st:=Ini.ReadString('Options','main','db01')+'.db';
  if not FileExists(st) then
    raise Exception.Create('Файл базы данных по умолчанию '+
      st+' не найден.');
  Table1.TableName:=st;
  Table1.Open;
  fioF.Visible:=fioBool;
  ocF.Visible:=ocBool;
  pravF.Visible:=pravBool;
  colF.Visible:=colBool;
  temaF.Visible:=temaBool;
  dateF.Visible:=dateBool;
  gruppaF.Visible:=gruppaBool;
  teacherF.Visible:=teacherBool;
  timeF.Visible:=timeBool;
  badstrF.Visible:=badStrBool;
  Ini.Free;

  fioF.ReadOnly:=fioR;
  ocF.ReadOnly:=ocR;
  pravF.ReadOnly:=pravR;
  colF.ReadOnly:=colR;
  temaF.ReadOnly:=temaR;
  dateF.ReadOnly:=dateR;
  gruppaF.ReadOnly:=gruppaR;
  teacherF.ReadOnly:=teacherR;
  timeF.ReadOnly:=timeR;
  badstrF.ReadOnly:=badstrR;

  if InsDelR then
  DBNavigator.VisibleButtons:=DBNavigator.VisibleButtons-[nbDelete,nbInsert];

end;

procedure TFrmDB.SpeedButton1Click(Sender: TObject);
var st1:string;k,b:byte;
begin        
  with TFrmFiltrRec.Create(Application) do
  begin
    if ShowModal = mrOk then
    begin
//      Modified:=true;     // А то запарил - сохранить да сохранить...
      FindNOT:=CBFindNot.Checked;

      if CBOc.Checked then OC:=StrToInt(EOc.Text) else OC:=0;
      if CBDate.Checked then
      begin
        dat1:=StrToDate(EDate1.Text);
        dat2:=StrToDate(EDate2.Text);

        data1:=EDate1.Text;
        data2:=EDate2.Text;

{        // цифры первой даты
        n1:=StrToInt(Copy(data1,1,2));
        n2:=StrToInt(Copy(data1,4,2));
        n3:=StrToInt(Copy(data1,7,2));
        //  цифры второй даты
        m1:=StrToInt(Copy(data2,1,2));
        m2:=StrToInt(Copy(data2,4,2));
        m3:=StrToInt(Copy(data2,7,2));

 }     end else
      begin
        data1:='';
        data2:='';
      end;

      if CBTime.Checked then
      begin
        time1:=ETime1.Text;
        time2:=ETime2.Text;

        tim1:=StrToTime(ETime1.Text);
        tim2:=StrToTime(ETime2.Text);

        // цифры первого времени
        t1:=StrToInt(Copy(time1,1,2));
        t2:=StrToInt(Copy(time1,4,2));
        t3:=StrToInt(Copy(time1,7,2));
        //  цифры второго времени
        q1:=StrToInt(Copy(time2,1,2));
        q2:=StrToInt(Copy(time2,4,2));
        q3:=StrToInt(Copy(time2,7,2));

      end else
      begin
        time1:='';
        time2:='';
      end;

      if CBTema.Checked then tema:=CBoxTema.Text else tema:='';
      if CBGruppa.Checked then gruppa:=CBoxGruppa.Text else gruppa:='';
      if CBName.Checked then fio:=CBoxName.Text else fio:='';
      if CBTeacher.Checked then teacher:=CBoxTeacher.Text else teacher:='';
      if CBNeprav.Checked then Badstr:=ENeprav.Text else Badstr:='';
      if CBNeprav.Checked then Bads:=BadSet else BadS:=[];
      if CBBegin.Checked then beginIF:=true else beginIF:=false;

      Table1.Filtered:=true;

    end else Table1.Filtered:=false ;

    Free;
  end;
end;

procedure TFrmDB.Table1FilterRecord(DataSet: TDataSet;
  var Accept: Boolean);
var st:string;a1,a2,a3:integer;
    dat3,tim3:TDateTime;
begin
  Accept:=true;
  if OC<>0 then Accept:=DataSet['Оценка']=OC;
  if data1<>'' then
  begin
    if data2='00.00.00' then
      Accept:=Accept and (DataSet.Fields.Fields[5].AsString=data1) else
    begin
      dat3:=StrToDate(DataSet.Fields.Fields[5].AsString);
      if (dat3>=dat1) and (dat3<=dat2) then
         Accept:=Accept and true else Accept:=false;
    end;
  end;
  if time1<>'' then
  begin
    if time2='00.00.00' then
      Accept:=Accept and (DataSet.Fields.Fields[8].AsString=data1) else
    begin
      tim3:=StrToTime(DataSet.Fields.Fields[8].AsString);
      if (tim3>=tim1) and (tim3<=tim2) then
         Accept:=Accept and true else Accept:=false;
    end;
  end;
  if tema<>'' then Accept:=Accept and (DataSet['Тема']=tema);
  if gruppa<>'' then Accept:=Accept and (DataSet['Группа']=gruppa);
  if fio<>'' then if beginIF then
     Accept:=Accept and (Pos(fio,DataSet.Fields.Fields[0].AsString)=1) else
     Accept:=Accept and (Pos(fio,DataSet.Fields.Fields[0].AsString)<>0);

  if teacher<>'' then Accept:=Accept and (DataSet['Преподаватель']=teacher);
  if Badstr<>'' then Accept:=Accept and Bad(DataSet.Fields.Fields[9].AsString);
  if FindNOT then Accept:=not Accept;
end;

procedure TFrmDB.FormClose(Sender: TObject; var Action: TCloseAction);
var Ini:TIniFile;
begin
  if Modified then 
  begin
    Ini:=TIniFile.Create('test_db.ini');
    Ini.WriteBool('ShowFields','ФИО',fioBool);
    Ini.WriteBool('ShowFields','Оценка',ocBool);
    Ini.WriteBool('ShowFields','Правильных ответов',pravBool);
    Ini.WriteBool('ShowFields','Вопросов',colBool);
    Ini.WriteBool('ShowFields','Тема',temaBool);
    Ini.WriteBool('ShowFields','Дата',dateBool);
    Ini.WriteBool('ShowFields','Группа',gruppaBool);
    Ini.WriteBool('ShowFields','Преподаватель',teacherBool);
    Ini.WriteBool('ShowFields','Время',timeBool);
    Ini.WriteBool('ShowFields','Неправ',badStrBool);
    Ini.Free;
  end;

  Table1.Close
end;

procedure TFrmDB.SpeedButton2Click(Sender: TObject);
begin
  OC:=0;
  data1:='';
  data2:='';
  time1:='';
  time2:='';
  tema:='';
  gruppa:='';
  fio:='';
  teacher:='';

  Table1.Close;
  Table1.Open;
  Table1.Filtered:=false;
  Table1.Refresh;
end;

procedure TFrmDB.SpeedButton3Click(Sender: TObject);
begin
  with TFrmFiltrField.Create(Application) do
  begin
    CheckBox1.Checked:=fioBool;
    CheckBox2.Checked:=ocBool;
    CheckBox3.Checked:=pravBool;
    CheckBox4.Checked:=colBool;
    CheckBox5.Checked:=temaBool;
    CheckBox6.Checked:=dateBool;
    CheckBox7.Checked:=gruppaBool;
    CheckBox8.Checked:=teacherBool;
    CheckBox9.Checked:=timeBool;
    CheckBox10.Checked:=badStrBool;
    if ShowModal = mrOk then
    begin
      Modified:=true;

      fioBool:=CheckBox1.Checked;
      ocBool:=CheckBox2.Checked;
      pravBool:=CheckBox3.Checked;
      colBool:=CheckBox4.Checked;
      temaBool:=CheckBox5.Checked;
      dateBool:=CheckBox6.Checked;
      gruppaBool:=CheckBox7.Checked;
      teacherBool:=CheckBox8.Checked;
      timeBool:=CheckBox9.Checked;
      badStrBool:=CheckBox10.Checked;

      fioF.Visible:=fioBool;
      ocF.Visible:=ocBool;
      pravF.Visible:=pravBool;
      colF.Visible:=colBool;
      temaF.Visible:=temaBool;
      dateF.Visible:=dateBool;
      gruppaF.Visible:=gruppaBool;
      teacherF.Visible:=teacherBool;
      timeF.Visible:=timeBool;
      badstrF.Visible:=badStrBool;
    end;
    Free;
  end;
end;

procedure TFrmDB.SpeedButton4Click(Sender: TObject);
var k:integer;
    Items,desc:TstringList;
begin
  if MessageBox(Handle,PChar('Будет распечатано '+IntToStr(Table1.RecordCount)+
          ' записей.Подтверждаете?'),'Монитор БД',MB_YESNO)=ID_NO then Exit;
  if not GetDescript(Desc) then Exit; // необязатльный заголовок при печати
  if  not PrintDialog1.Execute then Exit;
  Table1.First;
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
      if Desc<>nil then
      begin
        for k:=0 to Desc.Count-1 do
        begin

          Items.AddObject(Desc[k],pointer(80));
          PrintLine(Items);
          Items.Clear;
        end;
        Items.AddObject('           ',pointer(20));
        PrintLine(Items);
        Items.Clear;
      end;
      
      PrintColumnNames;
      { Store each field value in the TStringList as well as its
        column width }
      Table1.First;
      while (not Table1.Eof) or Printer.Aborted do
      begin
        Application.ProcessMessages;
        for k:=0 to Table1.FieldCount-1 do
         if Table1.FieldList.Fields[k].Visible then
           Items.AddObject(Table1.FieldList.Fields[k].AsString,pointer(Arr[k]));
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
        Table1.Next;
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

procedure TFrmDB.PrintColumnNames;
var
  ColNames: TStringList;
  k:integer;
begin
  { Create a TStringList to hold the column names and the
    positions where the width of each column is based on values
    in the TEdit controls. }
  ColNames := TStringList.Create;
  try
    // Print the column headers using a bold/underline style
    Printer.Canvas.Font.Style := [fsBold, fsUnderline];
    for k:=0 to Table1.FieldCount-1 do
     if Table1.FieldList.Fields[k].Visible then
       ColNames.AddObject(Table1.FieldList.Fields[k].FieldName,pointer(Arr[k]));

    PrintLine(ColNames);
    ColNames.Clear;
    Printer.Canvas.Font.Style := [];
    ColNames.AddObject('          ',pointer(10));
    PrintLine(ColNames);
  finally
    ColNames.Free;   // Free the column name TStringList instance
  end;
end;

procedure TFrmDB.PrintLine(Items: TStringList);
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

procedure TFrmDB.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose:=true;
  if Modified then
    case  MessageBox(Handle,'Сохранить настройки?','Turbo Test',
       MB_ICONQUESTION or MB_YESNOCANCEL) of
      ID_CANCEL:CanClose:=false;
      ID_NO:Modified:=false;
    end;
end;

function TFrmDB.Bad(st: string): boolean;
var bad:setB;st1:string;b,k:byte;
begin
  Result:=false;
  if st='' then
  begin
    if badstr='0' then Result:=true;
    Exit;
  end;
  bad:=[];
  // Преобразуем строку st в множество
  k:=0;
  st1:='';
  while k<Length(st) do
  begin
    inc(k);
    if (k=Length(st1))or (st[k]=',') then
    begin
      b:=byte(StrToInt(st1));
      st1:='';
      include(bad,b);
    end else
    st1:=st1+st[k];
  end;
  b:=byte(StrToInt(st1));
  include(bad,b);
  Result:=badS<=bad;

end;

procedure TFrmDB.N4Click(Sender: TObject);
begin
  Close
end;

end.
