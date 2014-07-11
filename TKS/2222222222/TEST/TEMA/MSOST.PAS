{$X+}                         {дата предварительной готовности  05.11.01}
                              {последнее обновление:            01.02.02}
unit MSost;

interface

uses App,Objects,Drivers,Views,MsgBoxMy,Validate,
     Types,MRed,Indic,MyFunc,Dos,Mylib,Strings,Medit2;

const
  nums:array [1..9] of char =('1','2','3','4','5','6','7','8','9');

type
  PSostWin=^TSostWin;           {объект-окно ,в котором составляются}
  TSostWin=object(TWindow)      {редактируютс и просматриваются вопросы}
    constructor Init(n:word);
  end;

  PSost=^TSost;
  TSost=object(TEditor)
    first:boolean;
    count:byte;                  {номер составляемого ответа в текущ.вопросе}
    startNumVopr:integer;        {вопрос,с которого начиниется составление}
    oldCount,x1,y1:byte;         {параметры сохраняемого составляемого вопр.}
    oldNumVopr:integer;          {номер сохраняемого составляемого вопроса}
    oldLine:byte;
    DoubleChars:TChars;
    constructor Init(var R:TRect;AFn:PathStr;AIndicator:PIndicator);
    procedure PutEnter;virtual;
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure WriteSostInvite;   {выводит приглашение}
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
    MessageBox(#3'Ввод закончен!!!',nil,$402);
    Fail;
  end;
  MessageBox(#3'Введено '+Sstr(testFile.hdr^.nn)+' вопрос(a,ов)'+
      #13+#13+#3'Всего-'+Sstr(testFile.Hdr^.ckolko),nil,$402);
  startNumVopr:=testFile.Hdr^.nn+1;
  numVopr:=startNumVopr;
  list:=false;
  ifList:=false;
  first:=true;
  StartSost;
  ifCurrentEdit:=false;                 {чтобы иметь возможность листать}
  SetCursor(x,y);
end;

procedure TSost.StartSost;
begin
  count:=0;                                 {составляемый вопрос-первый}
  Cls;                                      {очистка экрана и chars    }
  numVopr:=cBlocks^.count;                  {за последним в коллекции  }
  first:=true;
  WriteSostInvite;
end;

procedure TSost.PutEnter;
var
  k:byte;
  BL:PBlock;
begin
  if not MaxPosition(y2) then Exit;         {нет макс.позиции}
  if count=0 then                           {если ввели сам вопрос}
  begin
    y:=maxY+1;
    for k:=0 to x2 do chars[y,k]:=syl+196;  {разделительная черта}
    line:=y;
    x:=0;
    SetCursor(0,y);
  end;
  if count<testFile.Hdr^.d+1 then                  {если ввод вопроса не закончен}
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
  else begin                                {если ввели правильный ответ}
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
      if numVopr>testFile.Hdr^.ckolko then         {ввели последний вопрос по теме}
      begin
        MessageBox(#3'Ввод закончен!',nil,mfOkButton);
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
  {при вызове не записывается последний вопрос на экране,т.к. он еще не
     помещен в коллекцию}
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
  QuitMessage:=MessageBox(#3'Подтверждаете выход?',nil,mfYesNoCancel)
end;

procedure TSost.HandleEvent;
begin
  inherited HandleEvent(Event);
  case Event.What of
    evKeyDown:begin
        case Event.KeyCode of
          kbAltA :if cBlocks^.count>1 then    {можно,если уже есть вопросы}
                  begin
                    ifList:=not ifList;           {режим листания и копирования}
                    if ifList then
                    begin
                      oldcount:=count;
                      oldLine:=line;
                      x1:=x;y1:=y;
                      DoubleChars:=chars;
                      oldNumVopr:=numVopr;
                      numVopr:=1;
                      ShowChars;
                      invite:='             Включен режим просмотра';
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
          kbAltQ    :StartSost;{начать ввод текущ.вопр.с начала}
          kbBlock   :
             if ifList or (numVopr<startNumVopr) then Exit
                       else PutEnter;
     end;
   end;
  end;
  UpDate;
end;
end.