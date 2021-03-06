unit MEdit3;                     {��� ��砫쭮� ���ᨨ     : 22.01.02}
                                 {��� �����⠫쭮� ���ᨨ : 30.01.02}

interface

uses
  App,Views,Objects,Drivers,Types,MEdit2,Indic,MyFunc,Mylib,MsgBoxMy,
  Strings,Menus,Stream,Dos;

     {������� 3. ����� ����㦠�� � ��ᬠ�ਢ��� ����� ����� ���� ⥬�.
                 ��ࠡ��뢠�� ᠬ ⮫쪮 PgDn,PgUp,AltR.}

const
  inv='             ����祭 ०�� ��ᬮ��';

type                          {��ꥪ�-���� ,� ���஬}
  PWorkWin3=^TWorkWin3;       {।�������� � ��ᬠ�ਢ����� ������}
  TWorkWin3=object(TWindow)
    constructor Init;
  end;

  PEdit3=^TEdit3;
  TEdit3=object(TEdit2)
    testFile:TTestFile;
    ifList:boolean;                     {true-��ࠡ��뢠���� PgUp,PgDown}
    line:shortInt;                      {true-०�� ���⠭��}
    numVopr:integer;
    list:boolean;                       {०�� ���⠭��}
    cBlocks:PCollection;                {�������� ������}
    invite:string;                      {������ ����������!!!!!!!!!!!!}
    lines:PChar;
    mChar:tm1;                                 {����-���ᨢ ᨬ�����}
    constructor Init(var R:TRect;AFn:PathStr;AIndicator:PIndicator);
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure ShowChars;virtual;
    procedure PageDownUp(n:word);virtual;
    procedure WriteInvite;                     {�뢮� �ਣ��襭��}
    procedure CleanInvite;                     {��ࠥ� �ਣ��襭��}
    procedure GoTonewNumber;
  end;

implementation

constructor TWorkWin3.Init;
var
  R         : TRect;
  Indicator : PINdicator;
  Pw        : PView;
  fn        : PathStr;
begin
  if not SelectTem(fn) then Fail;
  R.Assign(0,0,80,23);
  TWindow.Init(R,'������஢����',0);
  R.Assign(2, Size.Y - 1, 16, Size.Y);
  Indicator := New(PIndicator, Init(R));
  Insert(Indicator);
  Options:=Options or ofTileable;
  GetClipRect(R);
  R.Grow(-1,-1);
  Pw:=Application^.ValidView(New(PEdit3,Init(R,fn,Indicator)));
  if Pw=nil then Fail;
  Insert(Pw);
end;

constructor TEdit3.Init;
begin
  inherited Init(R,AIndicator);
  FillChar(mChar,SizeOf(mChar),32);
  if not testFile.Init(AFn,stOpen,nil) then Fail;
  HideCursor;
  CleanInvite;
  endX:=x2-1;
  list:=true;                               {०�� ���⠭�� �� ।���.}
  ifList:=true;
  numVopr:=1;
  cBlocks:=testFile.GetAllBlocks;
  invite:=inv;
  ShowChars;
  Draw;
  HelpCtx:=2;
end;

{$I showchar.inc}

procedure TEdit3.WriteInvite;
var
  k:byte;
begin
  for k:=1 to Length(invite) do
    chars[0,k+2]:=syl+byte(invite[k]);
end;

procedure TEdit3.CleanInvite;
var
  k:byte;
begin
  for k:=1 to x2 do chars[0,k]:=syl+32;
end;

procedure TEDit3.PageDownUp(n:word);
begin
  Inc(numVopr,n);
  if numVopr>cBlocks^.count-1 then numVopr:=1;
  if numVopr=0 then numVopr:=cBlocks^.count-1;
  ClearAll;
  ShowChars;
end;

procedure TEdit3.GoToNewNumber;
var
  m:integer;
begin
  if InputInt(1,testFile.Hdr^.nn,'����� �����     ',m,9)=cmCancel then Exit;
  numVopr:=0;
  PageDownUp(m);
end;

procedure TEdit3.HandleEvent;
var
  R:TRect;
  PM:PMenuPopup;
  k,i:byte;
begin
  if not list then Inherited HandleEvent(Event);
  case Event.What of
    evBroadCast :Exit;
    evMouseDown :Exit;
    evCommand   :Exit;
    evKeyDown   :
       case Event.KeyCode of
         kbAltK  : begin R.Assign(10,10,30,17);
                   PM:=New(PMenuPopup,Init(R,NewMenu(StdWindowMenuItems(nil))));
                    w:=DeskTop^.ExecView(PM);
                    if w<>cmCancel then begin
                      Event.What:=evCommand;
                      Event.Command:=w;
                      PutEvent(Event);
                    end;
                   end;
                                            {��⠢�� 楫��� ����� � ����}
         kbAltR    :if ClipBoard<>nil then
                    begin
                      ClipBoard^.chars:=chars;
                      ClipBoard^.paste:=line;    {� paste �࠭���� line}
                      ClipBoard^.Draw;
                     end;
         kbAltS    :GoToNewNumber;
         kbPgDn,
         kbPgUp    :if ifList then
                       PageDownUp((Event.KeyCode div 256-1)div 4-19);
       else
         Exit;
       end;
  else
    Exit;
  end;
  ClearEvent(Event);
  UpDate;
end;
end.

