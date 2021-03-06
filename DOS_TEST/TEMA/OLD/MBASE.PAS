{$X+}
                         {????????????????                      }
unit MBase;  {                 MessageBox � Run �� ࠡ�⠥�!!!!!}

interface

uses App,Dialogs,Drivers,Objects,MsgBoxMy,Menus,Views,Types,Validate,
     MyFunc,Dos,Calc,Mylib,MHelp,HelpFile,Colors;

type                                            {��ꥪ�-�ணࠬ��}
  TMyApplication=object(TApplication)
    constructor Init;
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure Idle;virtual;
    procedure Run;virtual;
    procedure InitStatusLine;virtual;
    procedure InitMenuBar;virtual;
    procedure CreateTemasDat;
    procedure DeleteVar;
    procedure ShowBuffer;
{    procedure ShowDirTree;}
    procedure ChangeBAK;
    procedure OutOfMemory;virtual;
    procedure GetEvent(var Event: TEvent);virtual;
    procedure About;
    function  GetPalette: PPalette;virtual;
  end;

implementation


uses Crt,MRed,MEdit2,MEdit3,MyObject,MSost,MakeFont;
{     OutDir1,Tools;}
var
  H:PHeapView;
{  Variant:TVariant;}
  ClipWindow:PWorkWin2;                  {���� ���� ������}
  EXEName:PathStr;

function CalcHelpName: String;
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  FSplit(EXEName, Dir, Name, Ext);
  if Dir[Length(Dir)] = '\' then Dec(Dir[0]);
  CalcHelpName := FSearch(path+'\TEMA\MHELP.HLP', Dir);
end;

procedure GetPath;
var
  f:text;
begin
  if not OpenFile('redactor.cfg',pf,2,true) then
  begin
    MessageBox(#3'�� ������ ���� � ��⠫��� TEST',nil,mfOkButton);
    Exit
  end;
  Readln(tft(pf^),path);
  Close(tft(pf^))
end;                                                { TMyApplication }

constructor TMyApplication.Init;
begin
  RegisterHelpFile;
  inherited Init;
end;

procedure TMyApplication.HandleEvent;
var
  R:TRect;
begin
  Inherited HandleEvent(Event);
  if Event.What=evCommand then
  case Event.Command of
    cmAbout :About;
    cmNewColor :SelectNewColors;
    cmTemasDat:CreateTemasDat;
    cmRed:DeskTop^.Insert(New(PEditWin,Init));
    cmOld,cmNew:DeskTop^.Insert(New(PSostWin,Init(Event.Command)));
{    cmVar:Variant.Init;                                            }
    cmVar:DeskTop^.Insert(New(PEditWin,Init));
    cmHeaderEdit:DeskTop^.Insert(New(PWorkWin2,Init(';;;;')));
    cmFont:DeskTop^.ExecView(New(PFontWindow,Init));
    cmList:DeskTop^.Insert(New(PWorkWin3,Init));
{    cmBAK :DeskTop^.Insert(New(PListWin,Init(2)));}
    cmTile:begin DeskTop^.GetExtent(R);DeskTop^.Tile(R);end;
    cmCascade:begin DeskTop^.GetExtent(R);DeskTop^.Cascade(R);end;
    cmCalk:DeskTop^.Insert(New(PCalculator, Init));
    cmDelVar:DeleteVar;
    cmShowBuf:ShowBuffer;
    cmChangeBAK:ChangeBAK;
  else Exit
  end;
  ClearEvent(Event);
end;

procedure TMyApplication.Idle;
begin
  H^.UpDate
end;

procedure TMyApplication.Run;
var
  a:word;R:TRect;
begin
  Getpath;
  if path='' then Done;
  R.Assign(68,0,80,1);New(h,Init(R));TMyApplication.Insert(H);
{  About;}
  ClipWindow:=New(PWorkWin2,Init('���� ������'));          {���� ����}
  if ClipWindow<>nil then ClipBoard:=ClipWindow^.Editor;
  ClipWindow^.Hide;
  DeskTop^.Insert(ClipWindow);
  inherited Run;
end;

procedure TMyApplication.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);R.B.Y := R.A.Y + 1;
  MenuBar :=New(PMenuBar,Init(R,
    NewMenu(
       NewSubMenu('~�~���',0,
         NewMenu(NewItem('~T~emas.dat','',0,cmTemasDat,0,
                 NewItem('~�~������� ��ਠ�⮢','',0,cmDelVar,hcDelVar,
                 NewItem('~�~����� �� BAK-䠩�','',0,cmChangeBAK,hcChangeBAK,
                 NewLine(
                 NewItem('~K~�������','',0,cmCalk,hcCalk,
                 NewItem('~C~���� �������','',0,cmNewColor,hcOColors,
                 NewLine(
                 NewItem('~�~맮� DOS','',0,cmDOSShell,hcDOSShell,
                 NewItem('~�~�ॢ� ��⠫����','',0,cmDirTree,0,
                 NewItem('~�~���� ࠡ���','Alt-X',kbAltX,cmQuit,0,
                 NewLine(
                 NewItem('~�~ �ணࠬ��...','',0,cmAbout,0,
                  nil))))))))))))),
         NewSubMenu('~C~��⠢�����',0,
           NewMenu(NewItem('~�~த������','',0,cmOld,hcOld,
                   NewItem('~O~����� ����� ⥬�','',0,cmNew,hcNew,nil))),
         NewItem('~B~�ਠ���','',0,cmVar,hcVar,
         NewSubMenu('~P~�����஢����',0,
           NewMenu(NewItem('~B~�����','',0,cmRed,hcRed,
                   NewItem('~�~��������','',0,cmHeaderEdit,hcHeaderEdit,
                   NewItem('~�~���','',0,cmFont,hcFont,nil)))),
         NewSubMenu('~�~�ᬮ��',0,
           NewMenu(NewItem('~�~����� 䠩��','',0,cmList,hcList,
                    NewItem('~B~AK-䠩��','',0,cmBAK,hcBAK,nil))),
         NewSubMenu('~O~���',0,
           NewMenu(NewItem('~T~ile','',0,cmTile,hcWTile,
                   NewItem('~C~ascade','',0,cmCascade,hcWCascade,
                   NewItem('~�~������','Alt-W',kbAltW,cmClose,hcWClose,
                   NewItem('~�~�ᯠ����','F5',kbF5,cmZoom,hcWZoom,
                   NewItem('~C~�����饥','F6',kbF6,cmNext,hcWNext,
                   NewLine(
                   NewItem('~�~������� ����','Shift-F1',kbShiftF1,cmShowBuf,
                    0,
                    nil)))))))),
          nil)))))))));
end;

procedure TMyApplication.InitStatusLine;
var
  R:TRect;
begin
  GetExtent(R);
  R.a.y:=Pred(R.b.y);
  StatusLine:=New(PStatusLine,Init(R,
  NewStatusDef(0,$FFFF,
    NewStatusKey('~Alt-X~ ��室',kbAltX,cmQuit,
    NewStatusKey('~F1~ ��ࠢ��',kbF1,cmHelp,
    NewStatusKey('',kbF2,cmHeaderEdit,
    NewStatusKey('~F6~ ������饥',kbF6,cmNext,
    NewStatusKey('~Alt-W~ �������',kbAltW,cmClose,
    NewStatusKey('~F5~ ��ᯠ����',kbF5,cmZoom,
    NewStatusKey('~F10~ ����',kbF10,cmMenu,nil))))))),nil)))
end;

procedure TMyApplication.CreateTemasDat;
var
  h  : THead;
  hd : THeader;
  s  : SearchRec;
  fh : tfh;
  fc : tfc;
begin
  Assign(fh,'Temas.dat');
  Rewrite(fh);
  FindFirst('tema.*',AnyFile,s);
  while DosError=0 do
    begin
      Assign(fc,s.name);
      Reset(fc);
      hd.fName:=s.name;
      ReadHeader(hd);
      Close(fc);
      h.tema:=hd.tema;h.index:=hd.index;h.kTem:=hd.kTem;
      Write(fh,h);
      FindNext(s);
    end;
  Close(fh)
end;

procedure TMyApplication.DeleteVar;
var
  h   : THeader;
  S   : SearchRec;
  k   : integer;
  ch  : char;
  fch : tfc;
  st  : string;
begin
  if SelectTema(h)=cmCancel then Exit;
  {$I-}
  ChDir('\TEST\VAR');
  {$I+}
  if IOResult<>0 then
  begin
    MessageBox(#3'�஢���� ����稥 ��⠫��� VAR!',nil,mfOkButton);
    Exit;
  end;
  FindFirst('var???.'+h.index,AnyFile,S);
  k:=0;ch:='0';
  while DosError =0 do
  begin
    Assign(fch,S.name);
    Erase(fch);
    inc(k);
    FindNext(S);
  end;
  MessageBox(#3'�������: '+Sstr(k)+' 䠩���.',nil,mfOkButton);
  ChDir('\TEST\TEMA');
  if not OpenFile('tema.'+h.index,pf,0,true) then
    MessageBox(#3'�� 㤠���� �������� ���������'+#13+#13+#3'䠩�� '+
      'tema.'+h.index,nil,mfOkButton)
  else
  begin
    for k:=0 to 3 do Write(tfc(pf^),ch);
    Close(tfc(pf^))
  end;
end;

procedure TMyApplication.ShowBuffer;
begin
  if Clipboard=nil then Exit;    {�������� ���� ����}
  ClipWindow^.Select;
  ClipWindow^.Show;
end;

{procedure TMyApplication.ShowDirTree;
var
  ch:char;
begin
  ch:=SelectDrive;
  DirTree := GetDirs(ch+':\');
  InsertWindow(New(PDirDlg, Init(DirTree)));
end;}

procedure TMyApplication.ChangeBAK;
var
  cCol:PCollection;
  st:string;
  n:integer;
begin
  cCol:=GetFilesList('tema_bak.*');
  if ListDialog(cCol,'�롥�� 䠩� ��� ������',st,n,4)=cmCancel then Exit;
  if MessageBox(#3'��९���� 䠩� '+st+#13+#13+#3'� 䠩� TEMA.'+
       GetExt(st)+'?',nil,mfYesButton+mfNoButton)=cmCancel then Exit;
  if not CopyFile(st,'tema.'+GetExt(st)) then
    MessageBox(#3'������ �� 㤠����!!!',nil,mfOkButton)
end;

procedure TMyApplication.OutOfMemory;
begin
  MessageBox(#3'��� ����� ��� �⮩ ����樨',nil,mfError+mfOkButton)
end;

procedure TMyApplication.About;
var
  R:TRect;
begin
  R.Assign(16,4,64,19);
  MessageBoxRect(R,#3'TurboTest Service '+#13+#13+#3'Version 4.43'+#13+
   #13+#3'Copyright (c) 1999,2001 by'+#13+#13+#3'Sokol International,Inc'+
   #13+#13+#3'(��᫥���� ����������: 05.02.02)',
   nil,mfOkButton+mfInformation);
end;

procedure TMyApplication.GetEvent(var Event: TEvent);
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

function TMyApplication.GetPalette: PPalette;
const
  CNewColor = CColor + CHelpColor;
  CNewBlackWhite = CBlackWhite + CHelpBlackWhite;
  CNewMonochrome = CMonochrome + CHelpMonochrome;
  P: array[apColor..apMonochrome] of string[Length(CNewColor)] =
    (CNewColor, CNewBlackWhite, CNewMonochrome);
begin
  GetPalette := @P[AppPalette];
end;

end.
