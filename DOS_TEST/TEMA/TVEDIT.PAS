{************************************************}
{                                                }
{   Turbo Vision Editor Demo                     }
{   Copyright (c) 1992 by Borland International  }
{                                                }
{************************************************}

program TVEdit;

{$M 8192,8192,655360}
{$X+,S-}

{ This program demonstrates the use of the Editors units.
  See EDITORS.DOC in the \DOC directory.
}

uses Dos, Objects, Drivers, Memory, Views, Menus, Dialogs,
  StdDlg, MsgBox, App, Calc, Editors;

const
  HeapSize = 32 * (1024 div 16);

const
  cmCalculator = 101;
  cmShowClip   = 102;

type
  PEditorApp = ^TEditorApp;
  TEditorApp = object(TApplication)
    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
  end;

var
  EditorApp: TEditorApp;
  ClipWindow: PEditWindow;

function OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
var
  P: PWindow;
  R: TRect;
begin
  DeskTop^.GetExtent(R);
  P := New(PEditWindow, Init(R, FileName, wnNoNumber));
  if not Visible then P^.Hide;
  OpenEditor := PEditWindow(Application^.InsertWindow(P));
end;

constructor TEditorApp.Init;
var
  H: Word;
  R: TRect;
begin
  MaxHeapSize := HeapSize;
  inherited Init;
  DisableCommands([cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmFind, cmReplace, cmSearchAgain]);
  EditorDialog := StdEditorDialog;
  ClipWindow := OpenEditor('', False);
  if ClipWindow <> nil then
  begin
    Clipboard := ClipWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
end;

procedure TEditorApp.HandleEvent(var Event: TEvent);
var R:TRect;

procedure FileOpen;
var
  FileName: FNameStr;
begin
  FileName := '*.*';
  if ExecuteDialog(New(PFileDialog, Init('*.*', 'Открытие файла',
    '~И~мя файла', fdOpenButton, 100)), @FileName) <> cmCancel then
    OpenEditor(FileName, True);
end;

procedure FileNew;
begin
  OpenEditor(ParamStr(1), True);
end;

procedure ChangeDir;
begin
  ExecuteDialog(New(PChDirDialog, Init(cdNormal, 0)), nil);
end;

procedure ShowClip;
begin
  ClipWindow^.Select;
  ClipWindow^.Show;
end;

procedure Calculator;
begin
  InsertWindow(New(PCalculator, Init));
end;

begin
  inherited HandleEvent(Event);
  case Event.What of
    evCommand:
      case Event.Command of
        cmOpen: FileOpen;
        cmNew: FileNew;
        cmChangeDir: ChangeDir;
        cmCalculator: Calculator;
        cmShowClip: ShowClip;
        567:begin
              R.Assign(22,5,58,18);
              MessageBoxRect(R,#3'Turbo Edit'+#13#13#3'Version 1.0 '+
                 #13#13#3'Copyright (c) 2002 by'+
                  #13#13#3'Sokol Software Inc.',nil,mfOkButton);
            end;
      else
        Exit;
      end;
  else
    Exit;
  end;
  ClearEvent(Event);
end;

procedure TEditorApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~Ф~айл', hcNoContext, NewMenu(
      StdFileMenuItems(
      nil)),
    NewSubMenu('~Р~едактирование', hcNoContext, NewMenu(
      StdEditMenuItems(
      nil)),
    NewSubMenu('~П~оиск', hcNoContext, NewMenu(
      NewItem('~Н~айти...', '', kbNoKey, cmFind, hcNoContext,
      NewItem('~З~аменить...', '', kbNoKey, cmReplace, hcNoContext,
      NewItem('~И~скать дальше', '', kbNoKey, cmSearchAgain, hcNoContext,
      nil)))),
    NewSubMenu('~О~кна', hcNoContext, NewMenu(
      StdWindowMenuItems(
      NewLine(
      NewItem('~К~алькулятор', '', kbNoKey, cmCalculator, hcNoContext,
      nil)))),
    NewItem('~C~правка', '',kbNoKey,567,hcNoContext,nil)
      )))))));
end;

procedure TEditorApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  New(StatusLine, Init(R,
    NewStatusDef(0, $FFFF,
      NewStatusKey('~F2~ Сохранить', kbF2, cmSave,
      NewStatusKey('~F3~ Открыть', kbF3, cmOpen,
      NewStatusKey('~Alt-F3~ Закрыть', kbAltF3, cmClose,
      NewStatusKey('~F5~ Распахнуть', kbF5, cmZoom,
      NewStatusKey('~F6~ Следующие', kbF6, cmNext,
      NewStatusKey('~F10~ Меню', kbF10, cmMenu,
      NewStatusKey('', kbCtrlF5, cmResize,
      nil))))))),
    nil)));
end;

procedure TEditorApp.OutOfMemory;
begin
  MessageBox('Not enough memory for this operation.',
    nil, mfError + mfOkButton);
end;

begin
  EditorApp.Init;
  EditorApp.Run;
  EditorApp.Done;
end.
