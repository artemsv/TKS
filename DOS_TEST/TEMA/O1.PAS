program Opros;            {��� ᮧ����� ��砫쭮� ���ᨨ     3.11: 25.10.01}
                          {��� ᮧ����� �����⥫쭮� ���ᨨ 4.3 : 16.11.01}
                          {��� ᮧ����� �����⥫쭮� ���ᨨ 4.31: 21.11.01}
                          {��� ᮧ����� �����⥫쭮� ���ᨨ 4.67: XX.03.02}

uses
  App,Dos,Crt,Drivers,MyFunc,Views,MsgBoxMy,Objects,Types,MyLib,MOpros,
  Indicatr,Dialogs,MPicture,Menus,MyTSet,Strings,Stream,LdFnt;

const
  cmEndtimer = 200;             {ᮮ�饭�� �� ����砭�� �६���}
  ifFirst:boolean=true;         {true-����  ���� ࠧ �� ?????}
  newPalette:string[1]=#2;      {����� ������ ��� ��ப� ����஫� �६���}

var                             {�������� ��६����}
  timer     : word;             {�६� � ᥪ㭤�� �� ���� �����}
  oldSecond : word;             {��砫쭮� �६� ��। ����� ����ᮬ}
  start     : boolean;          {䫠� ��砫� ����� �६��� ��� ����.����.}
  k         : byte;             {���⮩,��祬 �� �ਬ��⥫�� ���稪}
  scan      : byte;             {᪠�-��� ������}
  oldInt09H : pointer;          {㪠��⥫� �� ����� ��楤���}
  info      : RInfo;

{$F+}
procedure IntProc;interrupt;
begin
  scan:=Port[60];
  inline($FF/$1E/>oldInt09H)
end;
{$F-}

type
  POprosWin=^TOprosWin;
  TOprosWin=object(TWindow)
    constructor Init;
  end;

  POpros=^TOpros;
  TOpros=object(TOpr)
    vern,name,badst:string;
    badmas:TBadStr;
    prav,oc:integer;
    code,totalves:integer;
    ves:integer;
    jr3,jr4,jr5,ball:real;
    fch:tfc;
    fst:text;
    neprav:byte;
    mNumvoprs:array[0..255] of integer;      {��砩�� ����� ����ᮢ}
    mTimers:array[1..255] of word;
    count:byte;                             {����� ����� �� ����}
    Hdr:PHdr;
    cBL:PCollection;
    constructor Init(var R:TRect;AIndVopr,AIndVar:PIndicator);
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure StartOpros;                   {�����⮢�� � �����}
    procedure SelectVar;                    {�롮� ��ਠ��}
    procedure GoodAnswer;                   {ॠ��� �� �ࠢ���� �⢥�}
    procedure BadAnswer;                    {ॠ��� �� ���ࠢ���� �⢥�}
    procedure EndOpros;                     {����� ����}
    procedure NextVopr(b,del:boolean);      {true-�����;true-㤠����}
  end;

  TMyApp=object(TApplication)
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure Run;virtual;
    procedure InitStatusLine;virtual;
    procedure InitmenuBar;virtual;
    procedure Idle;virtual;
  end;

  PTimerView=^TTimerView;
  TTimerView=object(TStaticText)
   function GetPalette:PPalette;virtual;
   procedure Clean;                         {������ ��ப� ⠩���}
   procedure UpDate;                        {�������� ��������� ⠩���}
  end;

var
  Opr  : POpros;
  MySet: TSet;

const
  PWin : POprosWin=nil;

procedure ReadInfo(var info:RInfo);
var
  f:text;
  k:byte;
begin
  Assign(f,'info.opr');
  {$I-}
  Reset(f);
  if IOresult<>0 then begin
    MessageBox(#3'�訡�� �⥭�� 䠩�� INFO.DAT !',nil,mfOkButton);
    Halt;
  end;
  Readln(f,info.date);
  Readln(f,info.gr);
  Readln(f,info.kGr);
  Readln(f,info.fnt);
  Readln(f,info.kolTem);
  for k:=1 to info.kolTem do
  begin
    Readln(f,info.tems[k].t);
    Readln(f,info.tems[k].n);
  end;
  Readln(f,info.total);
  Readln(f,info.tim);
  Readln(f,info.j5);
  Readln(f,info.j4);
  Readln(f,info.j3);
  Close(f);
  if IOresult<>0 then begin
    MessageBox(#3'������ �ଠ� 䠩�� INFO.DAT !',nil,mfOkButton);
    Halt;
  end;
end;

procedure TTimerView.UpDate;
begin
  if not start then Exit;
  if GetSecond<>oldSecond then
  begin
    Dec(timer);
    if timer=0 then Message(Opr,evBroadCast,cmEndtimer,nil);
     oldSecond:=GetSecond;
  end;
  DisposeStr(text);
  text:=NewStr(#3'��� �६�:'+Sstr(timer));
  Draw;
end;

procedure TTimerView.Clean;
begin
  DisposeStr(text);
  text:=NewStr('   ');
  Draw
end;

function TTimerView.GetPalette;
begin
  GetPalette:=@newPalette
end;

var
  T,Q:PTimerView;

procedure TMyApp.Idle;
begin
  T^.UpDate
end;

procedure TMyApp.HandleEvent;
begin
  if (Event.What=evCommand) and (Event.Command=cmQuit) then if
    MessageBox(#3'���⢥ত��� ��室?',nil,mfYesButton+mfNoButton) in
      [cmNo,cmCancel] then ClearEvent(Event) else SetIntVec($09,oldInt09H);
  inherited HandleEvent(Event);
end;

procedure TMyApp.Run;
var
  R:TRect;
begin
  R.Assign(62,24,80,25);
  New(T,Init(R,''));
  R.Assign(65,0,80,1);
  TMyApp.Insert(New(PTimerView,Init(R,'Turbo Test 4.67')));
  TMyApp.Insert(T);
  R.Assign(2,24,38,25);
  Q:=New(PTimerView,Init(R,'��५�� '+#24+','+#25+' - ��ᬮ�� ����ᮢ.'));
  Q^.Hide;
  TMyApp.Insert(Q);
  PWin:=POprosWin(Application^.ValidView(New(POprosWin,Init)));
  if PWin=nil then MsgHalt('���� � ���������!!!'+#13+#13+
     #3'�맮� �� TApplication.Run');
  DeskTop^.Insert(PWin);
  ifFirst:=false;
  inherited Run;
end;

procedure TMyApp.InitStatusLine;
var
  R:TRect;
begin
  GetExtent(R);
  R.a.y:=Pred(R.b.y);
  StatusLine:=New(PStatusLine,Init(R,
  NewStatusDef(0,$FFFF,NewStatusKey('',kbAltX,cmQuit,nil),nil)))
end;

procedure TMyApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);R.B.Y := R.A.Y + 1;
  MenuBar :=New(PMenuBar,Init(R,nil))
end;

constructor TOprosWin.Init;
var
  R:TRect;
  IndVopr,IndVar:PIndicator;
begin
  start:=false;
  R.Assign(0,0,80,23);
  TWindow.Init(R,'����-����',0);
  R.Assign(2, Origin.Y , 20, Origin.Y+1);
  IndVopr:= New(PIndicator, Init(R));Insert(IndVopr);
  R.Assign(57, Origin.Y , 75, Origin.Y+1);
  IndVar:= New(PIndicator, Init(R));Insert(IndVar);
  GetClipRect(R);R.Grow(-1,-1);
  Opr:=New(POpros,Init(R,IndVopr,IndVar));
  if Opr=nil then Fail
  else Insert(Opr);
end;

procedure TOpros.SelectVar;
var
  n:integer;
begin
{  if not OpenFile('\TEST\TEMA\tema.'+header.index,pf,0,true) then Halt;
  n:=ReadFour(pf);
  Close(tfc(pf^));
  InputInt(1,n,'����� ��ਠ��(�� 1 �� '+Sstr(n)+')',numVar,0);}
  numVar:=1;
end;

constructor TOpros.Init;
var
  fn:PathStr;
begin
  ReadInfo(info);
  fn:=info.tems[1].t;
  if not inherited Init(R,fn,nil) then Fail;
  Hdr:=New(PHdr,Init(TestFile.Hdr^.nn,TestFile.Hdr^.ckolko,TestFile.Hdr^.kTem,
    TestFile.Hdr^.d,TestFile.Hdr^.Tema,TestFile.Hdr^.fName,TestFile.Hdr^.pch));
  IndVopr:=AIndVopr;
  IndVar:=AIndVar;
  StartOpros;
  HideCursor;
end;

procedure TOpros.HandleEvent;
var
  key:integer;
begin                                                        {�६� ��諮}
  if (Event.What=evBroadCast) and (Event.Command=cmEndTimer) then
    BadAnswer;
  if Event.What=evKeyDown then Val(Event.CharCode,key,code);
  if (code=0) and ((key>0) and (key<testFile.Hdr^.d+2)) then
  begin
    ClrKeyBuf;
    ClearEvent(Event);
    if key=right then GoodAnswer else BadAnswer;
  end;
  if (Event.What=evKeyDown) then
    case Event.KeyCode of
      kbUp:if timer>10 then NextVopr(false,false);
      kbDown:if timer>10 then NextVopr(true,false)
    end;
end;

procedure TOpros.StartOpros;
begin
   prav:=0;
   ball:=0;
   neprav:=0;
   T^.Clean;                                    {���⪠ ����஫��� �६���}
   numvar:=0;                                   {���� ����� ��ਠ��=0}
   w:=DeskTop^.ExecView(New(PPicture,Init));
   case w of
     cmOk:SelectVar;
     cmCancel:Halt;
   end;
   jr3:=info.j3 /100;jr4:=info.j4/100;jr5:=info.j5/100;
   if not mySet.Init(1,info.tems[1].n) then MsgHalt('���� � ��������� mySet');
   Duplet(testFile.Hdr^.nn,info.tems[1].n,mNumVoprs);
   for k:=1 to colVopr do mTimers[k]:=info.tim+1;
   count:=1;
   numVopr:=mNumVoprs[count];
   timer:=info.tim;
   CleanChars;
   InterMixLines;
   IndVopr^.SetValue(1,1);
   IndVar^.SetValue(numVar,2);
   if not ifFirst and (PWin<>nil) then PWin^.Show;
   Draw;
   Q^.Show;
   start:=true;
end;

procedure TOpros.BadAnswer;
begin
  name:='';
  k:=PBlock(cBlocks^.At(numVopr))^.num;
  Inc(neprav);	                            {��饥 ���-�� ���ࠢ.�⢥⮢}
  badmas[neprav]:=k;                        {� ����.����.��.-���.����.}
  NextVopr(true,true);
end;

procedure TOpros.GoodAnswer;
begin
  Inc(prav);
  NextVopr(true,true);
end;

procedure TOpros.NextVopr;
var
  oldCount:byte;
begin
  oldCount:=count;
  mTimers[count]:=timer;                    {��������� ��⠢襥�� �६�}
  if b then count:=mySet.NextPlus(count)    {����砥� ᫥���騩}
  else count:=mySet.NextMinus(count);
  if del then myset.Delete(oldCount);       {�᪫��.ᥩ ����.�� �� ���������}
  if mySet.IsEmpty then EndOpros;           {�����,�᫨ ��� ���������}
  numVopr:=mNumVoprs[count];
  if (numVopr>cBlocks^.count-1) or (count>info.tems[1].n)
  then EndOpros
  else InterMixLines;
  if IndVopr<>nil then IndVopr^.SetValue(count,1);
  timer:=mTimers[count]                     {��砫쭮� ���祭�� }
end;

procedure TOpros.EndOpros;
var
  st,ballStr:string;
  russ:boolean;                              {true-�᫨ �� �㪢�-���᪨�}
begin
  T^.Clean;                                  {���⪠ ����஫�� �६���}
  PWin^.Hide;                                {���⠫� ����}
  Q^.Hide;                                   {��ப� ���᪠���}
  start:=false;
 { Sort(badmas);                              {���஢�� �� �����⠭��}
  name:='';
  for k:=1 to neprav do name:=name+'.'+Sstr(badmas[k]);            {name}
  badst:=Copy(name,2,Length(name)-1);        {㡨ࠥ� ��� � name}
  Str(prav,vern);                            {���_�� �ࠢ.�⢥⮢ � ��ப�}
  ves:=info.total div info.tems[1].n;             {��� � ������ ������ �����}
  ball:=ves*prav;                            {������뢠�� ��� �����}
  k:=trunc(ball);                            {�८�ࠧ㥬 � 楫��}
  Str(k,ballStr);
  if ball<info.total*jr3 then oc:=2;
  if (ball=info.total*jr3) or (ball>info.total*jr3) and
    (ball<info.total*jr4) then oc:=3;
  if (ball=info.total*jr4) or (ball>info.total*jr4) and
    (ball<info.total*jr5) then oc:=4;
  if (ball=info.total*jr5) or (ball>info.total*jr5) then oc:=5;
  repeat
    name:='';
    russ:=true;
    while Length(name)<4 do
      InputBox('','������ ��� ����㥬���:',name,15,0);
    for k:=1 to Length(name) do if (Ord(name[k])<128)and
      not(name[k] in[' ','.']) then russ:=false;
    if not russ then MessageBox(#3'���쪮 ���᪨� �㪢�!!!',nil,mfOkButton);
  until russ;
  Assign(fst,'otchet.dat');
  {$I-}
  if not Verify('otchet.dat',GetCurDir) then Rewrite(fst) else Append(fst);
  {$I+}
  st:=StrPas(testFile.Hdr^.tema);
  Writeln(fst,info.date:8,name:15,info.gr:8,info.kgr:3,numvar:4,oc:2,ballStr:5,
     st:12,testFile.Hdr^.kTem:3,' ',badst);
  Close(fst);
  CleanChars;
  Draw;
  StartOpros;
end;

var
  MyApp:TMyApp;
begin
  Myapp.Init;
  Myapp.Run;
  MyApp.Done
end.

