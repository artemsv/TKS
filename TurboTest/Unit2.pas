{$o-}
unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ShellApi, UFrame1, UFrame2, UFrame3;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Splitter1: TSplitter;
    Panel1: TPanel;
    Image3: TImage;
    Button3: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    Memo5: TMemo;
    Memo6: TMemo;
    Memo7: TMemo;
    Memo8: TMemo;
    Memo9: TMemo;
    Memo10: TMemo;
    Memo11: TMemo;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    Frame1:TFrame1;
    Frame2:TFrame2;
    Frame3:TFrame3;
    FStep:integer;
    function Setup:boolean;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;
  Dir:string;
  DestDir:string;                  //  каталог-приемник
  Compact:boolean;                 //  вариант установки
  Icons:boolean;                   //  нужны-ли иконки

implementation

uses Unit3, IniFiles, FileCtrl,ShlObj,ActiveX,ComObj,UFrmProgress, WinShell,
  UThread, Unit1, UErr;

{$R *.DFM}
{$R Files.Res}

procedure TForm2.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  with TForm3.Create(Application) do
  begin
    CanClose:=not (ShowModal=mrCancel);
    Free;
  end
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  FStep:=1;
  DestDir:='C:\Program Files\Test';
  Dir:=DestDir;
  Compact:=false;
  Icons:=true;

  Frame1:=TFrame1.Create(Application);
  Frame1.Parent:=Self;
  Frame1.Left:=138;

  Frame2:=TFrame2.Create(Application);
  Frame2.Parent:=Self;
  Frame2.Left:=138;
  Frame2.Visible:=false;

  Frame3:=TFrame3.Create(Application);
  Frame3.Parent:=Self;
  Frame3.Left:=138;
  Frame3.Visible:=false;

end;

procedure TForm2.Button2Click(Sender: TObject);
var b:boolean;
begin
  Inc(FStep);
  if FStep=2 then
  begin
    Button3.Visible:=true;
    Caption:='Тип установки';
    Frame1.Visible:=false;
    Frame2.Visible:=true;
    Frame2.Label7.Caption:=Dir;
    DestDir:=Dir;
    Frame2.RadioButton1.Checked:=false;
    Frame2.RadioButton2.Checked:=true;
    Frame2.CheckBox1.Checked:=true;
  end;
  if FStep=3 then
  begin
    Caption:='Проверка регистрационного номера';
    Frame2.Visible:=false;
    Frame3.Visible:=true;
    Frame3.Edit1.Text:='';
    Frame3.Edit2.Text:='';
    Frame3.Edit1.SetFocus;
    if Frame2.RadioButton1.Checked then Compact:=true else Compact:=false;
    Icons:=Frame2.CheckBox1.Checked;
  end;
  if FStep=4 then
  begin
    if (Frame3.Edit1.Text<>'123TEST') or (Frame3.Edit2.Text<>'TKS')
     then
    begin
      MessageBox(Handle,'Неверный регистрационный номер!','Setup',MB_ICONERROR);
      Dec(FStep);
      Frame3.Edit1.Text:='';
      Frame3.Edit2.Text:='';
      Frame3.Edit1.SetFocus;
      Exit;
    end;
    Hide;
    OnCloseQuery:=nil;
    if Setup then MessageBox(Application.Handle,'Установка завершена успешно.','Setup',0)
               else MessageBox(Application.Handle,'Установка не завершена.','Setup',0);
    OnCloseQuery:=nil;
    Close;
  end;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
  Dec(FStep);
  if FStep=1 then
  begin
    Caption:='Добро пожаловать';
    Button3.Visible:=false;
    Frame2.Visible:=false;
    Frame1.Visible:=true;
  end;
  if FStep=2 then
  begin
    Caption:='Тип установки';
    Frame3.Visible:=false;
    Frame2.Visible:=true;
    Frame2.Label7.Caption:=DestDir;
//    DestDir:=Dir;
    Frame2.RadioButton1.Checked:=Compact;
    Frame2.RadioButton2.Checked:=not Compact;
    Frame2.CheckBox1.Checked:=Icons;
  end;
end;

var buf:array[1..1000] of byte;

procedure DeleteDir(st:string);
var TS:TSearchRec;
begin
  if FindFirst(st+'\*.*',faAnyFile,TS) = 0 then
  begin
    DeleteFile(st+'\'+TS.Name);
    while FindNext(TS) = 0 do
      DeleteFile(st+'\'+TS.Name);
  end;
  RemoveDir(st);
  SysUtils.FindClose(TS);
end;

function TForm2.Setup: boolean;
var SLI:TShellLinkInfo;k:integer;st:string;
    WinDir:array [0..127] of char;Win:string;
    Ini:TIniFile;
    h:HFILE;
    f,f2:file;
    h1,h2:THandle;
    sizr:longint;
    TurboOprosH:HRSRC;
    TurboOpros:HGLOBAL;
    n,TurboOprosL:DWORD;
    TurboOprosP:Pointer;
    Thread:TTestThread;
    wq:array [1..7] of byte;
label erf;
begin
  h1:=FileOpen('0001.cab',fmOpenRead);
  FileRead(h1,buf,1240);
  FileRead(h1,wq,7);
  wq[4]:=wq[4]+1;                     //  очередная попытка инсталляции
  FileClose(h1);

  h1:=FileOpen('0001.cab',fmOpenWrite);
  FileWrite(h1,buf,1240);
  FileWrite(h1,wq,7);
  FileClose(h1);

  if wq[4]>6 then
  begin
    MessageBox(Handle,'Вы превысили максимально допустимое число установок'#13'Свяжитесь с разработчиком для получения новой инсталляционной дискеты.','Setup',0);
    Halt;
  end;
  FileClose(h1);

  Result:=false;
  if not CreateDir(DestDir) then
  begin
    MessageBox(Handle,PChar('Невозможно создать каталог '+DestDir),'Setup',0);
    Exit;
  end;
                                   //  обязательные файлы

                                                //  TurboOpros.exe
  TurboOprosH:=FindResource(MainInstance,'TurboOpros',PChar(19000));
  TurboOpros:=LoadResource(MainInstance,TurboOprosH);
  TurboOprosP:=LockResource(TurboOpros);
  TurboOprosL:=SizeOfResource(MainInstance,TurboOprosH);
  h:=FIleCreate(DestDir+'\Тестирование.exe');
  FileWrite(h,TurboOprosP^,TurboOprosL);
  FileClose(h);                                  //  TurboTest.exe

  TurboOprosH:=FindResource(MainInstance,'TurboTest',PChar(19000));
  TurboOpros:=LoadResource(MainInstance,TurboOprosH);
  TurboOprosP:=LockResource(TurboOpros);
  TurboOprosL:=SizeOfResource(MainInstance,TurboOprosH);
  h:=FIleCreate(DestDir+'\Редактор тестов.exe');
  FileWrite(h,TurboOprosP^,TurboOprosL);
  FileClose(h);                                   //  Macros.dat

  TurboOprosH:=FindResource(MainInstance,'Macros',PChar(19000));
  TurboOpros:=LoadResource(MainInstance,TurboOprosH);
  TurboOprosP:=LockResource(TurboOpros);
  TurboOprosL:=SizeOfResource(MainInstance,TurboOprosH);
  h:=FIleCreate(DestDir+'\Macros.dat');
  FileWrite(h,TurboOprosP^,TurboOprosL);
  FileClose(h);

     //  test_db.ini В C:\Windows\

  GetWindowsDirectory(WinDir,127);
  Win:=WinDir;
  Memo10.Lines[1]:='path='+DestDir;
  Memo10.Lines.SaveToFile(Win+'\test_db.ini');

  if not Compact then                //  He обязательные файлы
  begin
    Memo1.Lines.SaveToFile(DestDir+'\as-11.grp');
    Memo2.Lines.SaveToFile(DestDir+'\ep-12.grp');
    Memo3.Lines.SaveToFile(DestDir+'\ms-14.grp');
    Memo4.Lines.SaveToFile(DestDir+'\as-42.grp');

    Memo5.Lines.SaveToFile(DestDir+'\gruppa.dat');
    Memo6.Lines.SaveToFile(DestDir+'\file_tem.dat');
    Memo7.Lines.SaveToFile(DestDir+'\file_db.dat');
    Memo8.Lines.SaveToFile(DestDir+'\teachers.dat');
    Memo9.Lines.SaveToFile(DestDir+'\temas.dat');

    TurboOprosH:=FindResource(MainInstance,'Matem',PChar(19000));
    TurboOpros:=LoadResource(MainInstance,TurboOprosH);
    TurboOprosP:=LockResource(TurboOpros);
    TurboOprosL:=SizeOfResource(MainInstance,TurboOprosH);
    h:=FIleCreate(DestDir+'\matem01.tem');
    FileWrite(h,TurboOprosP^,TurboOprosL);
    FileClose(h);

    TurboOprosH:=FindResource(MainInstance,'Var',PChar(19000));
    TurboOpros:=LoadResource(MainInstance,TurboOprosH);
    TurboOprosP:=LockResource(TurboOpros);
    TurboOprosL:=SizeOfResource(MainInstance,TurboOprosH);
    h:=FIleCreate(DestDir+'\var.tem');
    FileWrite(h,TurboOprosP^,TurboOprosL);
    FileClose(h);

    TurboOprosH:=FindResource(MainInstance,'Hist',PChar(19000));
    TurboOpros:=LoadResource(MainInstance,TurboOprosH);
    TurboOprosP:=LockResource(TurboOpros);
    TurboOprosL:=SizeOfResource(MainInstance,TurboOprosH);
    h:=FIleCreate(DestDir+'\hist01.tem');
    FileWrite(h,TurboOprosP^,TurboOprosL);
    FileClose(h);

    TurboOprosH:=FindResource(MainInstance,'DB01',PChar(19000));
    TurboOpros:=LoadResource(MainInstance,TurboOprosH);
    TurboOprosP:=LockResource(TurboOpros);
    TurboOprosL:=SizeOfResource(MainInstance,TurboOprosH);
    h:=FIleCreate(DestDir+'\db01.db');
    FileWrite(h,TurboOprosP^,TurboOprosL);
    FileClose(h);

  end else
  begin          // создаем пустые файлы
    Memo11.Lines.SaveToFile(DestDir+'\gruppa.dat');
    Memo11.Lines.SaveToFile(DestDir+'\teachers.dat');
    Memo11.Lines.SaveToFile(DestDir+'\temas.dat');
    Memo11.Lines.SaveToFile(DestDir+'\file_db.dat');
    Memo11.Lines.SaveToFile(DestDir+'\file_tem.dat');    
  end;

erf:
  MessageBox(Handle,'Вставьте в дисковод дискету номер два и нжмите <Ок>','Setup',0);
  h1:=FileOpen('A:\DB2.exe',fmOpenReadWrite);
  if h1=INVALID_HANDLE_VALUE then
    case Err of
      mrOk:goto erf;
      mrCancel:
        begin
          DeleteDir(DestDir);  // удалили все файлы каталога и сам каталог
          Exit;
        end;
    end
    else FileClose(h1);

  FrmProgress:=TFrmProgress.Create(Application);
  FrmProgress.Show;
  FrmProgress.Label1.Caption:='Копирование файлов в '+DestDir;

  h1:=FileOpen('A:\DB2.exe',fmOpenReadWrite);
  h2:=FileCreate(DestDir+'\Монитор БД.exe');
  FileWrite(h2,buf,1240);
  n:=SetFilePointer(h2,1240,nil,FILE_BEGIN);
  Sizr:=GetFileSize(h1,nil);
  Sizr:=Sizr+1000;
  n:=1000;
  while true do
  begin
    dec(n);
    if (n mod 100 =0 ) and (n <1200000) then
      FrmProgress.Label2.Caption:='Осталось: '+IntToStr(n div 100)+' сек.';
    FrmProgress.ProgressBar1.StepIt;
    Application.ProcessMessages;
    Sizr:=Sizr-1000;
    if Sizr<1000 then
    begin
      FileRead(h1,buf,Sizr);
      FileWrite(h2,buf,Sizr);
      Break;
    end else
    begin
      FileRead(h1,buf,1000);
      FileWrite(h2,buf,1000);
    end;
  end;
  with FrmProgress.ProgressBar1 do
  while Position<Max do StepIt;

  if Icons then
  begin
    st:=CreateShellLink('Редактор тестов.exe','',CSIDL_DESKTOP);
    SLI.PathName:=DestDir+'\Редактор тестов.exe';
    SLI.Arguments:='';
    SLI.Description:='Тест-редактор';
    SLI.WorkingDirectory:=DestDir;
    SLI.IconLocation:=SLI.PathName;
    SLI.IconIndex:=0;
    SLI.ShowCmd:=SW_NORMAL;
    SLI.HotKey:=0;
    SetShellLinkInfo(st,SLI);

    st:=CreateShellLink('Тестирование.exe','',CSIDL_DESKTOP);
    SLI.PathName:=DestDir+'\Тестирование.exe';
    SLI.Arguments:='';
    SLI.Description:='Программа тестирования';
    SLI.WorkingDirectory:=DestDir;
    SLI.IconLocation:=SLI.PathName;
    SLI.IconIndex:=1;
    SLI.ShowCmd:=SW_NORMAL;
    SLI.HotKey:=0;
    SetShellLinkInfo(st,SLI);

    st:=CreateShellLink('Монитор БД.exe','',CSIDL_DESKTOP);
    SLI.PathName:=DestDir+'\Монитор БД.exe';
    SLI.Arguments:='';
    SLI.Description:='Монитор базы данных';
    SLI.WorkingDirectory:=DestDir;
    SLI.IconLocation:=SLI.PathName;
    SLI.IconIndex:=0;
    SLI.ShowCmd:=SW_NORMAL;
    SLI.HotKey:=0;
    SetShellLinkInfo(st,SLI);

  end;
  FrmProgress.Free;
  Result:=true;
end;

end.
