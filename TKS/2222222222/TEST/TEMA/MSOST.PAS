{$X+}                         {��� �।���⥫쭮� ��⮢����  05.11.01}
                              {��᫥���� ����������:            01.02.02}
unit MSost;

interface

uses App,Objects,Drivers,Views,MsgBoxMy,Validate,
     Types,MRed,Indic,MyFunc,Dos,Mylib,Strings,Medit2;

const
  nums:array [1..9] of char =('1','2','3','4','5','6','7','8','9');

type
  PSostWin=^TSostWin;           {��ꥪ�-���� ,� ���஬ ��⠢������}
  TSostWin=object(TWindow)      {।�������� � ��ᬠ�ਢ����� ������}
    constructor Init(n:word);
  end;

  PSost=^TSost;
  TSost=object(TEditor)
    first:boolean;
    count:byte;                  {����� ��⠢�塞��� �⢥� � ⥪��.�����}
    startNumVopr:integer;        {�����,� ���ண� ��稭����� ��⠢�����}
    oldCount,x1,y1:byte;         {��ࠬ���� ��࠭塞��� ��⠢�塞��� ����.}
    oldNumVopr:integer;          {����� ��࠭塞��� ��⠢�塞��� �����}
    oldLine:byte;
    DoubleChars:TChars;
    constructor Init(var R:TRect;AFn:PathStr;AIndicator:PIndicator);
    procedure PutEnter;virtual;
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure WriteSostInvite;   {�뢮��� �ਣ��襭��}
    procedure StartSost;virtual;
    procedure Inscription;virtual;
    procedure AltT;virtual;
    procedure Cls;
    function  QuitMessage:word;virtual;
  end;

implementation

uses
  Stream;

{$I sostwini.inc}

constructor TSost.Init;
begin
  inherited Init(R,AFn,Aindicator);
  if testFile.Hdr^.nn>=testFile.Hdr^.ckolko then
  begin
    MessageBox(#3'���� �����祭!!!',nil,$402);
    Fail;
  end;
  MessageBox(#3'������� '+Sstr(testFile.hdr^.nn)+' �����(a,��)'+
      #13+#13+#3'�ᥣ�-'+Sstr(testFile.Hdr^.ckolko),nil,$402);
  startNumVopr:=testFile.Hdr^.nn+1;
  numVopr:=startNumVopr;
  list:=false;
  ifList:=false;
  first:=true;
  StartSost;
  ifCurrentEdit:=false;                 {�⮡� ����� ����������� ������}
  SetCursor(x,y);
end;

procedure TSost.StartSost;
begin
  count:=0;                                 {��⠢�塞� �����-����}
  Cls;                                      {���⪠ ��࠭� � chars    }
  numVopr:=cBlocks^.count;                  {�� ��᫥���� � ������樨  }
  first:=true;
  WriteSostInvite;
end;

procedure TSost.PutEnter;
var
  k:byte;
  BL:PBlock;
begin
  if not MaxPosition(y2) then Exit;         {��� ����.����樨}
  if count=0 then                           {�᫨ ����� ᠬ �����}
  begin
    y:=maxY+1;
    for k:=0 to x2 do chars[y,k]:=syl+196;  {ࠧ����⥫쭠� ���}
    line:=y;
    x:=0;
    SetCursor(0,y);
  end;
  if count<testFile.Hdr^.d+1 then                  {�᫨ ���� ����� �� �����祭}
    begin
      Inc(count); first:=true;
      CleanInvite;
      WriteSostInvite;
      if count=1 then Inc(y) else y:=maxY+1;oldY:=y;
      chars[y,0]:=syn+byte(nums[count]);
      chars[y,1]:=syn+byte('.');
      x:=oldX;
      SetCursor(x,y)
    end
  else begin                                {�᫨ ����� �ࠢ���� �⢥�}
      first:=true;
      if not SetMarkers then Exit;
      Compressor;
      BL:=New(PBlock,Init(numVopr,StrNew(mChar)));
      cBlocks^.Insert(BL);
      testFile.Hdr^.nn:=BL^.num;
      testFile.AddBlockAndRestore(BL);
      ClearAll;
      CleanColor;
      count:=0;x:=oldX;y:=1;oldY:=1;line:=25;
      Inc(numVopr);
      if numVopr>testFile.Hdr^.ckolko then         {����� ��᫥���� ����� �� ⥬�}
      begin
        MessageBox(#3'���� �����祭!',nil,mfOkButton);
        Message(Owner,evBroadcast,cmclose,nil);
      end;
      WriteSostInvite;
  end;
end;

{$i wsostinv.inc}
{$i sostaltt.inc}

procedure TSost.Inscription;
var
  k:byte;
begin
  {�� �맮�� �� �����뢠���� ��᫥���� ����� �� ��࠭�,�.�. �� �� ��
     ����饭 � ��������}
  if (cBlocks^.count=0) or (cBlocks^.count=startNumVopr) then Exit;{????}
  testFile.Hdr^.nn:=cBlocks^.count-1;
  inherited Inscription;
end;

procedure TSost.Cls;
begin
  ClearAll;
  x:=oldX;oldY:=1;
  y:=oldy;line:=0;paste:=0;
  SetCursor(x,y);
  Draw;
end;

function TSost.Quitmessage:word;
begin
  QuitMessage:=MessageBox(#3'���⢥ত��� ��室?',nil,mfYesNoCancel)
end;

procedure TSost.HandleEvent;
begin
  inherited HandleEvent(Event);
  case Event.What of
    evKeyDown:begin
        case Event.KeyCode of
          kbAltA :if cBlocks^.count>1 then    {�����,�᫨ 㦥 ���� ������}
                  begin
                    ifList:=not ifList;           {०�� ���⠭�� � ����஢����}
                    if ifList then
                    begin
                      oldcount:=count;
                      oldLine:=line;
                      x1:=x;y1:=y;
                      DoubleChars:=chars;
                      oldNumVopr:=numVopr;
                      numVopr:=1;
                      ShowChars;
                      invite:='             ����祭 ०�� ��ᬮ��';
                      WriteInvite;
                    end else
                    begin
                      if not ChangeBlocks then exit;
                      count:=oldCount;
                      x:=x1;y:=y1;
                      line:=oldLine;
                      chars:=DoubleChars;
                      numVopr:=oldNumVopr;
                      first:=true;
                      WriteSostInvite;
                    end;
                 end;
          kbAltQ    :StartSost;{����� ���� ⥪��.����.� ��砫�}
          kbBlock   :
             if ifList or (numVopr<startNumVopr) then Exit
                       else PutEnter;
     end;
   end;
  end;
  UpDate;
end;
end.