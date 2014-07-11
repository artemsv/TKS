{$X+,S-}
{$M 16384,8192,655360}

program BaseData;         {дата создания начальной версии 1.0: 02.01.02}

uses
  App,Views,Objects,Menus,Types,Drivers,MsgBoxMy,BDWindow,MyFunc,Calc,Colors,
  StdDlg,Dos,Puzzle,HelpFile,DemoHelp,DemoCmds;

const
  cmOtchetForm1  =  401;
  cmOtchetForm2  =  402;
  cmOtchetForm3  =  403;
  cmBaseBDForm1  =  411;
  cmBaseBDForm2  =  412;
  cmBaseBDForm3  =  413;

type
  TMyApplication=object(TApplication)
   collection:PCollection;
   D:PFileDialog;
   stFileBD:PathStr;
   procedure Init;
   procedure InitMenuBar;virtual;
   procedure InitStatusLine;virtual;
   procedure HandleEvent(var Event:TEvent);virtual;
   procedure GetEvent(var Event: TEvent);virtual;
   procedure About;
  end;

var
  EXEName: PathStr;
  RezFile: TResourceFile;
  RezStream: PStream;

procedure TMYApplication.Init;
begin
  RegisterHelpFile;
  TApplication.Init;
end;


procedure TMyApplication.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);R.B.Y := R.A.Y + 1;
  MenuBar :=New(PMenuBar,Init(R,
      NewMenu(
         NewSubMenu('~C~ервис',0,
           NewMenu(NewItem('~П~ечать','',0,cmPrint,0,
                   NewItem('~Ф~ильтр','',kbf8,cmFilter,0,
                   NewLine(
                   NewItem('~K~алькулятор','',0,cmCalc,0,
                   NewItem('~П~алитра','',0,cmColor,0,
                   NewLine(
                   NewItem('~В~ызов DOS','',0,cmDOSShell,0,
                   NewItem('~К~онец работы','Alt-X',kbAltX,cmQuit,0,
                   NewLine(
                   NewItem('~О~ программе...','',0,cmAbout,0,
                    nil))))))))))),
         NewSubMenu('~Ф~айл отчета',0,
           NewMenu(NewItem('~Ф~орма 1','',0,cmOtchetForm1,0,
                   NewItem('~Ф~орма 2','',0,cmOtchetForm2,0,
                   NewItem('~Ф~орма 3','',0,cmOtchetForm3,0,
                   NewItem('~К~ак есть...','',0,cmNature,0,
                   nil))))),
         NewSubMenu('~Б~аза данных',0,
           NewMenu(NewItem('~Ф~орма 1','',0,cmBaseBDForm1,0,
                   NewItem('~Ф~орма 2','',0,cmBaseBDForm2,0,
                   NewItem('~Ф~орма 3','',0,cmBaseBDForm3,0,
                   NewItem('~К~ак есть...','',0,cmNature,0,
                   nil))))),

         NewSubMenu('~O~кно',0,
           NewMenu(NewItem('~T~ile','',0,cmTile,0,
                   NewItem('~C~ascade','',0,cmCascade,0,
                   NewItem('~З~акрыть','Alt-W',kbAltW,cmClose,0,
                   NewItem('~C~ледующее','F6',kbF6,cmNext,0,
                    nil))))),
         NewItem('~P~едактирование','F7',kbF7,cmEdit,0,nil))))))));
end;

procedure TMyApplication.InitStatusLine;
var
  R:TRect;
begin
  GetExtent(R);
  R.a.y:=Pred(R.b.y);
  StatusLine:=New(PStatusLine,Init(R,
  NewStatusDef(0,$FFFF,
    NewStatusKey('~Alt-X~ Выход',kbAltX,cmQuit,
    NewStatusKey('~F1~ Справка',kbF1,cmHelp,
    NewStatusKey('~F9~ Поиск',kbF9,cmForm1,
    NewStatusKey('',kbF2,cmForm1,
    NewStatusKey('~Alt-W~ Закрыть',kbAltW,cmClose,
    NewStatusKey('~F5~ Печать',kbF5,cmPrint,
    NewStatusKey('~F10~ Меню',kbF10,cmMenu,nil))))))),nil)))
end;

procedure TMyApplication.About;
var
  R:TRect;
begin
  R.Assign(16,4,64,19);
  MessageBoxRect(R,#3'TurboTest Service''s DataBase Control '+#13+#13+
    #3'Version 1.0'+
   #13++#13+#3'Copyright (c),2002 by'+#13+#13+#3'Sokol International,Inc'+
   #13+#13+#3'(последнее обновление: 02.01.02)',
   nil,mfOkButton+mfInformation);
end;

{ CalcHelpName }

function CalcHelpName: String;
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  FSplit(EXEName, Dir, Name, Ext);
  if Dir[Length(Dir)] = '\' then Dec(Dir[0]);
  CalcHelpName := FSearch('DEMOHELP.HLP', Dir);
end;


procedure TMyApplication.GetEvent(var Event: TEvent);
var
  W: PWindow;
  HFile: PHelpFile;
  HelpStrm: PDosStream;
  st:string;
const
  HelpInUse: Boolean = False;
begin
  TApplication.GetEvent(Event);
  case Event.What of
    evCommand:
      if (Event.Command = cmHelp) and not HelpInUse then
      begin
        HelpInUse := True;
        st:=CalcHelpName;
        HelpStrm := New(PDosStream, Init(st, stOpenRead));
        HFile := New(PHelpFile, Init(HelpStrm));
        if HelpStrm^.Status <> stOk then
        begin
          MessageBox('Could not open help file.', nil, mfError + mfOkButton);
          Dispose(HFile, Done);
        end
        else
        begin
          W := New(PHelpWindow,Init(HFile, GetHelpCtx));
          if ValidView(W) <> nil then
          begin
            ExecView(W);
            Dispose(W, Done);
          end;
          ClearEvent(Event);
        end;
        HelpInUse := False;
      end;
    evMouseDown:
      if Event.Buttons <> 1 then Event.What := evNothing;
  end;
end;


procedure TMyApplication.HandleEvent;
begin
  Inherited HandleEvent(Event);
  if Event.What=evCommand then
  case Event.Command of
{    cmHelp:
    begin
               if collection=nil then
               if not ReadHelpFile(collection,'bd.hlp') then Exit;
               WatchWindow(collection,10,4,70,18);
             end;}
    cmCalc:DeskTop^.Insert(New(PCalculator, Init));
    cmOtchetForm1 :InsertWindow(New(PBDWindow,Init(otchetFile,1)));
    cmBaseBDForm1,
    cmBaseBDForm2,
    cmBaseBDForm3  :
      begin
        D:=New(PFileDialog,Init('*.dat','Найдите','stFileBD',fdOkButton,100));
        if DeskTop^.ExecView(D)=cmCancel then begin ClearEvent(Event);Exit;end;
        D^.GetFileName(stFileBD);
        Dispose(D,Done);
        InsertWindow(New(PBDWindow,Init(stFileBD,1)));
      end;
    cmColor :SelectNewColors;
    cmAbout :DeskTop^.Insert(New(PPuzzleWindow,Init));
  else Exit
  end;
  ClearEvent(Event);
end;


var Applic:TMyApplication;

begin
  Applic.Init;
  Applic.Run;
  Applic.Done;
end.