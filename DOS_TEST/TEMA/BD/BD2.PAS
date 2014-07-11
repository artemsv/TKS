
{$X+,S-}
{$M 16384,8192,655360}

uses
  Dos, Objects, Drivers, Memory, Views, Menus, Dialogs, StdDlg, MsgBox, App,
  DemoCmds, HelpFile,
  Calc,Colors,
  Types,MsgBoxMy,BDWindow,MyFunc,GadGets,BDHelp;

const
  cmForma1       =  401;
  cmForma2       =  402;
  cmForma3       =  403;

type
  PTVDemo = ^TTVDemo;
  TTVDemo = object(TApplication)
   collection:PCollection;
    Clock: PClockView;
    Heap: PHeapView;
    constructor Init;
    procedure GetEvent(var Event: TEvent); virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Idle; virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
  end;

var
  EXEName: PathStr;

function CalcHelpName: String;
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  FSplit(EXEName, Dir, Name, Ext);
  if Dir[Length(Dir)] = '\' then Dec(Dir[0]);
  CalcHelpName := FSearch('BDHELP.HLP', Dir);
end;

{ TTVDemo }
constructor TTVDemo.Init;
var R:Trect;
begin
  RegisterHelpFile;
  TApplication.Init;
  DisableCommands([cmPrint]);
  GetExtent(R);
  R.A.X := R.B.X - 9; R.B.Y := R.A.Y + 1;
  Clock := New(PClockView, Init(R));
  Insert(Clock);

  GetExtent(R);
  Dec(R.B.X);
  R.A.X := R.B.X - 9; R.A.Y := R.B.Y - 1;
  Heap := New(PHeapView, Init(R));
  Insert(Heap);

end;

procedure TTVdemo.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);R.B.Y := R.A.Y + 1;
        MenuBar := New(PMenuBar, Init(R, NewMenu(
             NewSubMenu('~Ф~айл', 0, NewMenu(
               NewSubMenu('~О~ткрыть', 0, NewMenu(
                 NewItem('~Ф~орма 1      ', '   ', 0, cmForma1, 0,
                 NewItem('~Ф~орма 2      ', '   ', 0, cmForma2, 0,
                 NewItem('~Ф~орма 3      ', '   ', 0, cmForma3, 0,
                 nil)))),
                 NewItem('~П~ечать','', 0, cmPrint, hcPrint,
                 NewItem('~К~алькулятор','', 0, cmCalc, hcCalculator,
                 NewItem('~П~алитра','', 0,cmColor, hcPalette,
                   NewLine(
                   NewItem('~В~ызов DOS','',0,cmDOSShell,0,
                   NewItem('~К~онец работы','Alt-X',kbAltX,cmQuit,0,
                   NewLine(
                   NewItem('~О~ программе...','',0,cmAbout,0,
                 nil)))))))))),
             NewSubMenu('~O~кно', 0, NewMenu(StdWindowMenuItems(nil)),
             nil)))));

end;

procedure TTVdemo.InitStatusLine;
var
  R:TRect;
begin
  GetExtent(R);
  R.a.y:=Pred(R.b.y);
  StatusLine:=New(PStatusLine,Init(R,
  NewStatusDef(0,$FFFF,
    NewStatusKey('~Alt-X~ Выход',kbAltX,cmQuit,
    NewStatusKey('~F1~ Справка',kbF1,cmHelp,
    NewStatusKey('~F2~ Поиск',kbF2,cmForma1,
    NewStatusKey('~Alt-W~ Закрыть',kbAltW,cmClose,
    NewStatusKey('~F5~ Печать',kbF5,cmPrint,
    NewStatusKey('~F10~ Меню',kbF10,cmMenu,nil)))))),nil)))
end;


procedure TTVDemo.GetEvent(var Event: TEvent);
var
  W: PWindow;
  HFile: PHelpFile;
  HelpStrm: PDosStream;
const
  HelpInUse: Boolean = False;
begin
  TApplication.GetEvent(Event);
  case Event.What of
    evCommand:
      if (Event.Command = cmHelp) and not HelpInUse then
      begin
        HelpInUse := True;
        HelpStrm := New(PDosStream, Init(CalcHelpName, stOpenRead));
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

function TTVDemo.GetPalette: PPalette;
const
  CNewColor = CColor + CHelpColor;
  CNewBlackWhite = CBlackWhite + CHelpBlackWhite;
  CNewMonochrome = CMonochrome + CHelpMonochrome;
  P: array[apColor..apMonochrome] of string[Length(CNewColor)] =
    (CNewColor, CNewBlackWhite, CNewMonochrome);
begin
  GetPalette := @P[AppPalette];
end;

var d:PFileDialog;

procedure TTVDemo.HandleEvent(var Event: TEvent);
begin
 TApplication.HandleEvent(Event);
 if (Event.What=evCommand) then
   case Event.Command of
     cmOpen:InsertWindow(New(PBDWindow,Init(Event.Command)));
     cmCalc:DeskTop^.Insert(New(PCalculator, Init));
     cmForma1,
     cmForma2,
     cmForma3  :InsertWindow(New(PBDWindow,Init(Event.Command)));
     cmColor :SelectNewColors;
     else
      Exit;
   end;
  ClearEvent(Event);
end;

procedure TTVDemo.Idle;

function IsTileable(P: PView): Boolean; far;
begin
  IsTileable := P^.Options and ofTileable <> 0;
end;

begin
  TApplication.Idle;
  Clock^.Update;
  Heap^.Update;
  if Desktop^.FirstThat(@IsTileable) <> nil then
    EnableCommands([cmTile, cmCascade])
  else
    DisableCommands([cmTile, cmCascade]);
end;

procedure TTVDemo.OutOfMemory;
begin
  MessageBox('Not enough memory available to complete operation.',
    nil, mfError + mfOkButton);
end;

var
  Demo: TTVDemo;
begin
  Demo.Init;
  Demo.Run;
  Demo.Done;
end.
