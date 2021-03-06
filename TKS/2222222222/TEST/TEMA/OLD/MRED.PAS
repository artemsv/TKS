unit MRed;                       {��� ��砫쭮� ���ᨨ     : 23.01.02}
                                 {��� �����⠫쭮� ���ᨨ : 01.02.02}

interface

uses
  Dialogs,Medit3,Views,Objects,Types,Indic,Drivers,DrDrop;

     {������� 4. ����� ����㦠�� � ��ᬠ�ਢ��� ,।���஢���,�-
                 �࠭��� ����� ����� ���� ⥬�.}

type                          {��ꥪ�-���� ,� ���஬}
  PEditWin=^TEditWin;       {।��������� � ��ᬠ�ਢ����� ������}
  TEditWin=object(TWindow)
    constructor Init;
  end;

  PEditor=^TEditor;
  TEditor=object(TEdit3)
    edit:boolean;
    ifCurrentEdit:boolean;
    cMacro:PCollection;                        {�������� ���ம�।������}
    macro:boolean;                             {true-MACRO.DAT �����﫨}
    constructor Init(var R:TRect;h:THeader;AIndicator:PIndicator);
    procedure ChangeMacroKey;                  {����� ���ம�।������}
    procedure ShowMacroKey;                    {��ᬮ�� ���ம�।������}
    procedure MacroKey;                        {����㧪� ���ம��.�� 䠩��}
    function  MacroString(cod:word):boolean;   {true-����� MACRO-������}
    procedure SaveMacro;                       {��࠭�� ���ம��.� 렩��}
    procedure CtrlY;virtual;
    procedure CtrlL;virtual;
    function  Minus:boolean;virtual;
    procedure Plus;virtual;
    procedure Up;virtual;
    procedure FromMover(var E:TEvent);virtual;
    procedure HandleEvent(Var Event:TEvent);virtual;
    procedure PageDownUp(n:word);virtual;
    function  SetMarkers:boolean;       {���⠢�.��થ��-ࠧ����⥫�}
    procedure Compressor;               {�८�ࠧ. chars � ����}
    function  ChangeBlocks:boolean;     {������� ���.���� �� ��।����.}
    function  CreateBAKFile:boolean;    {�����. true,�᫨ ᮧ��� BAK-䠩�}
    procedure WriteBlock(p:pointer);    {������ ����� � 䠩�}
    procedure WriteAllBlocks(n:integer;p:pointer);{������஢.������ ������}
    function  SaveEditFile(bak:boolean):boolean;{��࠭�� ��������}
    procedure AltT;virtual;             { ��⠢�� 楫��� ����� �� ����}
    procedure CleanColor;virtual;
    procedure Inscription;virtual;
    function  QuitMessage:word;virtual;
    function  Quit:boolean;virtual;
  end;

implementation

uses
  App,MyFunc,MsgBoxMy,Strings,MEdit2,MyLib;

{$I WinInit.Inc}

constructor TEditor.Init;
begin
  inherited Init(R,h,AIndicator);
  ShowCursor;
  cMacro:=New(PCollection,Init(10,2));
  macro:=false;
  MacroKey;
  SetCursor(1,1);
  oldX:=2;x:=oldX;
  oldY:=1;y:=oldY;
  ifCurrentEdit:=true;
  list:=false;
  edit:=true;
  CleanColor;
  Draw;
end;

{$I SetMarc.Inc  }
{$I ChangeBl.Inc }
{$I Compress.Inc }
{$I WriteBl.Inc  }
{$I WrtAllBl.Inc }

function TEditor.CreateBAKFile;
begin
  CreateBAKFile:=CopyFile(filename,'tema_bak.'+header.index)
end;

{$I SaveEdFl.inc}

procedure TEditor.CtrlY;
var
  k:byte;
begin
  SaveOld;
  if Lo(chars[y,0])<>32 then
    for k:=oldX to x2 do chars[y,k]:=sym32
  else inherited CtrlY;
  if y<line then Dec(line)
end;

procedure TEditor.CtrlL;
var
  k:byte;
begin
  saveOld;
  if (y=y2) or (Lo(chars[y2,0])<>32) then Exit;
  for k:=y2 downto y+1 do
    chars[k]:=chars[k-1];
  for k:=0 to x2 do chars[y,k]:=sym32;
  if y<=line then Inc(line);
end;

function TEditor.Minus;
begin
  Minus:=inherited Minus;
  if y=line then        { �᫨ ������ �� ࠧ����⥫��� ����� }
  begin
    if line>1 then Dec(y) else
    begin
      Inc(y);           {��᫥ ��� ��릪�� ����� ��⠥��� �� ����!!!}
      x:=oldX;
    end;
    if ifShift then     { �� "���㬭�" ������� �㦭� ��� ⮣�,       }
    begin               { �⮡� �᪫���� �뤥����� ࠧ����⥫쭮� ����� }
      CleanColor;
      chars[y,x]:=syv+Lo(chars[y,x]);
      paste:=y;
    end;
  end;
end;

procedure TEditor.Plus;
begin
  inherited Plus;
  if y=line then Inc(y)
end;

procedure TEditor.Up;
begin
  if y>1 then Dec(y)
end;

procedure TEditor.CleanColor;
var
  k,i:byte;
begin
  for k:=0 to x2 do chars[0,k]:=syl+Lo(chars[0,k]);
  for k:=1 to y2 do for i:=oldX to endX do chars[k,i]:=sym+Lo(chars[k,i]);
  for k:=0 to x2 do chars[line,k]:=syl+Lo(chars[line,k]);
  for k:=line+1 to y2 do for i:=0 to oldX-1 do
     chars[k,i]:=syn+Lo(chars[k,i])
end;

procedure TEditor.FromMover(var E:TEvent);
var
  tp:TPoint;
begin
  MakeLocal(MouseWhere,tp);
  if ((tp.x<oldX) or (tp.y=0) or (tp.x=x2) or (tp.y=line)) then Exit;
  inherited FromMover(E);
end;

{$I Macro.inc }

procedure TEditor.PageDownUp(n:word);
begin
  if not ChangeBlocks then Exit;
  inherited PageDownUp(n)
end;

procedure TEditor.Inscription;
begin
  ChangeBlocks;       {�� ��直� ��砩 �����塞 ��᫥���� ����,}
  SaveEditFile(true); {����� �� �� ��࠭� � ������ ������ AltX}
end;

procedure TEditor.AltT;
begin
  chars:=ClipBoard^.chars;
  line:=ClipBoard^.paste;  {� paste �࠭���� line}
  invite:=inv+GetStr(21,' ')+'����� � '+Sstr(numVopr);
  WriteInvite;
end;

function TEditor.QuitMessage:word;
begin
  QuitMessage:=MessageBox(#3'���࠭��� �� ���������?',nil,mfYesNoCancel)
end;

function TEditor.Quit:boolean;
begin
  Quit:=false;
  w:=QuitMessage;
  if w=cmCancel then Exit;
  if w=cmYes then Inscription;
  for w:=1 to cBlocks^.count-1 do
  begin
    lines:=cBlocks^.At(w);
    StrDispose(lines);
  end;
  cBlocks^.DeleteAll;
  Dispose(cBlocks,Done);
  if macro then SaveMacro;        {���. ��������� � MACRO.DAT}
  Quit:=true;
end;

procedure TEditor.HandleEvent;
begin
  if (Event.What=evKeyDown) then if (y=line) and
     not (Event.KeyCode div $100 in [20,30,19,$48,$49,$50,$51]) and
        (Event.KeyCode<>9740) then ClearEvent(Event);
  inherited HandleEvent(Event);
  case Event.What of
    evBroadCast :if Event.Command in [cmClose,cmQuit] then
                 begin
                   Event.What:=evCommand;
                   PutEvent(Event);
                 end else Exit;
    evMouseDown :Exit;
    evCommand   :if Event.Command in [cmQuit,cmClose] then
                 begin
                   if not Quit then ClearEvent(Event);
                   Exit;                   {��� �� TWindow.HandleEvent}
                 end else Exit;
    evKeyDown   :
       case Event.KeyCode of
          kbAltF1   :ChangeMacroKey;
          kbAltT    :if (ClipBoard<>nil) then  AltT; {�᫨ �� ⠬ ����}
          kbCtrlF1  :ShowMacroKey;
       else                               {���,�᫨ �� �� MACRO-������}
         if Event.CharCode=#0 then begin
           if not MacroString(Event.KeyCode) then Exit end else Exit;
       end;
  else
    Exit;
  end;
  ClearEvent(Event);
  UpDate;
end;
end.










