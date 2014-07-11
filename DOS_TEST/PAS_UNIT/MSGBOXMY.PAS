
{*******************************************************}
{                                                       }
{       Turbo Pascal Version 6.0                        }
{       Turbo Vision Unit                               }
{                                                       }
{       Copyright (c) 1990 Borland International        }
{                                                       }
{*******************************************************}

unit MsgBoxMy;

{$F+,O+,X+,D-}

interface

uses Objects;

const

{ Message box classes }

  mfWarning      = $0000;       { Display a Warning box }
  mfError        = $0001;       { Dispaly a Error box }
  mfInformation  = $0002;       { Display an Information Box }
  mfDialog       = $0003;       { Display a Confirmation Box }

{ Message box button flags }

  mfYesButton    = $0100;       { Put a Yes button into the dialog }
  mfNoButton     = $0200;       { Put a No button into the dialog }
  mfOKButton     = $0400;       { Put an OK button into the dialog }
  mfCancelButton = $0800;       { Put a Cancel button into the dialog }

  mfYesNoCancel  = mfYesButton + mfNoButton + mfCancelButton;
                                { Standard Yes, No, Cancel dialog }
  mfOKCancel     = mfOKButton + mfCancelButton;
                                { Standard OK, Cancel dialog }

{ MessageBox displays the given string in a standard sized      }
{ dialog box. Before the dialog is displayed the Msg and Params }
{ are passed to FormatStr.  The resulting string is displayed   }
{ as a TStaticText view in the dialog.                          }

function MessageBox(Msg: String; Params: Pointer; AOptions: Word): Word;

{ MessageBoxRec allows the specification of a TRect for the     }
{ message box to occupy.                                        }

function MessageBoxRect(var R: TRect; Msg: String; Params: Pointer;
  AOptions: Word): Word;

{ InputBox displays a simple dialog that allows the user to     }
{ type in a string.                                             }

function InputBox(Title: String; ALabel: String; var S: String;
  Limit: Byte;hlp:word): Word;

{ InputBoxRect is like InputBox but allows the specification of }
{ a rectangle.                                                  }

function InputBoxRect(var Bounds: TRect; Title: String; ALabel: String;
  var S: String;  Limit: Byte;hlp:word): Word;

implementation

uses Drivers, Views, Dialogs, App,Validate;

function MessageBox(Msg: String; Params: Pointer;
  AOptions: Word): Word;
var
  R: TRect;
begin
  R.Assign(0, 0, 40, 9);
  R.Move((Desktop^.Size.X - R.B.X) div 2, (Desktop^.Size.Y - R.B.Y) div 2);
  MessageBox := MessageBoxRect(R, Msg, Params, AOptions);
end;

function MessageBoxRect(var R: TRect; Msg: String; Params: Pointer;
  AOptions: Word): Word;
const
  ButtonName: array[0..3] of string[6] =
    ('~Д~а', '~Н~ет', 'O~K~', 'Отмена');
  Commands: array[0..3] of word =
    (cmYes, cmNo, cmOK, cmCancel);
  Titles: array[0..3] of string[11] =
    ('Сообщение','Ошибка','Информация','Диалог');
var
  I, X, ButtonCount: Integer;
  Dialog: PDialog;
  Control: PView;
  T: TRect;
  ButtonList: array[0..4] of PView;
  S: String;
begin
  Dialog := New(PDialog,
    Init(R, Titles[AOptions and $3]));
  with Dialog^ do
  begin
    R.Assign(3, 2, Size.X - 2, Size.Y - 3);
    FormatStr(S, Msg, Params^);
    Control := New(PStaticText, Init(R, S));
    Insert(Control);
    X := -2;
    ButtonCount := 0;
    for I := 0 to 3 do
      if AOptions and ($0100 shl I) <> 0 then
      begin
        R.Assign(0, 0, 10, 2);
        Control := New(PButton, Init(R, ButtonName[I], Commands[i],
          bfNormal));
        Inc(X, Control^.Size.X + 2);
        ButtonList[ButtonCount] := Control;
        Inc(ButtonCount);
      end;
    X := (Size.X - X) shr 1;
    for I := 0 to ButtonCount - 1 do
    begin
      Control := ButtonList[I];
      Insert(Control);
      Control^.MoveTo(X, Size.Y - 3);
      Inc(X, Control^.Size.X + 2);
    end;
    SelectNext(False);
  end;
  MessageBoxRect := DeskTop^.ExecView(Dialog);
  Dispose(Dialog, Done);
end;

function InputBox(Title: String; ALabel: String; var S: String;
  Limit: Byte;hlp:word): Word;
var
  R: TRect;
begin
  R.Assign(0, 0, 50, 8);
  R.Move((Desktop^.Size.X - R.B.X) div 2, (Desktop^.Size.Y - R.B.Y) div 2);
  InputBox := InputBoxRect(R, Title, ALabel, S, Limit,hlp);
end;

function InputBoxRect(var Bounds: TRect; Title: String; ALabel: String;
  var S: String;  Limit: Byte;hlp:word): Word;
var
  Dialog: PDialog;
  Control: PInputLine;
  R: TRect;
  C: Word;
  newLimit:byte;
begin
  Dialog := New(PDialog, Init(Bounds, Title));
  newLimit:=Limit;
  if Limit=0 then Limit:=8;
  with Dialog^ do
  begin
    R.Assign(4 {+CStrLen(ALabel)} ,4, 4+limit+5{Size.X -14}, 5);
    if newLimit=0 then
    begin
      Control := New(PInputLine, Init(R,8));
      Control^.SetValidator(New(PPXPictureValidator,Init('##/##/##',true)));
    end
    else Control := New(PInputLine, Init(R, Limit));
    Insert(Control);
    R.Assign(2, 2, 3 + CStrLen(ALabel), 3);
    Insert(New(PLabel, Init(R, ALabel, Control)));
    R.Assign(Size.X - 15, Size.Y - 7, Size.X - 4, Size.Y - 5);
    Insert(New(PButton, Init(R, 'O~K~', cmOk, bfDefault)));
    Inc(R.A.Y, 2); Inc(R.B.y, 2);
    Insert(New(PButton, Init(R, 'Отмена', cmCancel, bfNormal)));
    Inc(R.A.Y, 2); Inc(R.B.Y, 2);
    Insert(New(PButton, Init(R, 'Справка', cmHelp, bfNormal)));
    SelectNext(False);
  end;
  Dialog^.SetData(S);
  C := DeskTop^.ExecView(Dialog);
  if C <> cmCancel then Dialog^.GetData(S);
  Dispose(Dialog, Done);
  InputBoxRect := C;
end;

end.
