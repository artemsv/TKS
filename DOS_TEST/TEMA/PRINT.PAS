program Print;

{$M 8192,8192,655360}
{$X+,S-}

uses Crt,Dos, Objects, Drivers, Memory, Views, Menus, Dialogs,
     StdDlg, MsgBox, App, Editors,Types,MyLib,Printer,MyFunc,M_Dialog;

const
  cmPrint=200;
  ifPrint:boolean=false;

type
  TPrintApp = object(TApplication)
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitStatusLine; virtual;
    procedure Dialog;
  end;

var
  f,out:text;
  st:string;
  filename:st12;
  PrintApp: TPrintApp;

function ExecDialog(P: PDialog; Data: Pointer): Word;
var
  Result: Word;
begin
  Result := cmCancel;
  P := PDialog(Application^.ValidView(P));
  if P <> nil then
  begin
    if Data <> nil then P^.SetData(Data^);
    Result := DeskTop^.ExecView(P);
    if (Result <> cmCancel) and (Data <> nil) then P^.GetData(Data^);
    Dispose(P, Done);
  end;
  ExecDialog := Result;
end;


procedure TPrintApp.Dialog;
var
  FDialog:PFileDialog;
  a:word;
  k,n:word;
  Event:TEvent;
  ft:text;
begin
  filename:='msost.pas';
{  if ExecDialog(New(PFileDialog, Init('*.*', 'Open file',
    '~N~ame', fdOpenButton, 100)), @FileName) = cmCancel then Exit;
  FDialog:=New(PFileDialog, Init('*.*', 'Open file','~N~ame', fdOpenButton,100));
  a:=DeskTop^.ExecView(FDialog);
  if a=cmCancel then Exit;
  FDialog^.GetData(filename);
                                                                   }
  Assign(ft,filename);
  Reset(ft);
    k:=0;
    while not eof(ft) do
    begin
      Readln(ft,st);
      Inc(k);
    end;
    Close(ft);
    n:=k div 62;                        {сколько целых листов}
    if n in[0,1] then n:=1;
    k:=k mod 62;                        {сколько строк в последнем листе}
    if k<>0 then Inc(n);                {если в последнем что-то есть}
{    if MessageBox(#3' '+Sstr(n)+' лист(а,ов)'+',в последнем-'+Sstr(k)+'строк'+
    #13+#13+#3'Распечатать?',nil,mfYesNoCancel) in [cmNo,cmCancel] then Halt
    else}
    begin
      ifPrint:=true;
      Assign(ft,'tmp');
      Rewrite(ft);
      Writeln(ft,filename);
      Close(ft);
      Event.What:=evCommand;
      Event.Command:=cmQuit;
      PutEvent(Event);
    end;
end;

procedure TPrintApp.HandleEvent(var Event: TEvent);
begin
  if (Event.What=evCommand) and (Event.Command=cmPrint) then Dialog;
  inherited HandleEvent(Event);
end;

procedure TPrintApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('Alt~X~ Выход',kbAltX,cmQuit,
      NewStatusKey('            ~F5~ Выбор файлов для печати', kbF5, cmPrint,
      nil)),
    nil)));
end;

begin
  if ifPrint then
  begin
    TextBackGround(0);
    TextColor(7);
    ClrScr;
    if not OpenFile('tmp',pf,2) then Halt;
    Readln(tft(pf^),st);
    Close(tft(pf^));
    if not OpenFile(st,pf,2) then Halt;
    while not eof(tft(pf^)) do
    begin
      Readln(tft(pf^),st);
      Writeln(lst,st);
    end;
  end;
end.
