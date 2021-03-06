program Opros;            {��� ᮧ����� ��砫쭮� ���ᨨ     3.11: 25.10.01}
                          {��� ᮧ����� �����⥫쭮� ���ᨨ 4.3 : 16.11.01}
                          {��� ᮧ����� �����⥫쭮� ���ᨨ 4.31: 21.11.01}

uses
  App,Dos,Crt,Drivers,MyFunc,Views,MsgBoxMy,Objects,Types,MyLib,MOpros,
  Indicatr,Dialogs,MPicture,Menus,MyTSet;

const
  cmEndtimer = 200;             {ᮮ�饭�� �� ����砭�� �६���}
  ifFirst:boolean=true;         {true-����  ���� ࠧ �� ?????}
  newPalette:string[1]=#2;      {����� ������ ��� ��ப� ����஫� �६���}

var                             {�������� ��६����}
  timer     : word;             {�६� � ᥪ㭤�� �� ���� �����}
  oldSecond : word;             {��砫쭮� �६� ��। ����� ����ᮬ}
  start     : boolean;          {䫠� ��砫� ����� �६��� ��� ����.����.}
  k         : byte;             {���⮩,��祬 �� �ਬ��⥫�� ���稪}
  scan:byte;                    {᪠�-��� ������}
  oldInt09H:pointer;            {㪠��⥫� �� ����� ��楤���}

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
    mNumvoprs:array[0..20] of integer;      {��砩�� ����� ����ᮢ}
    mTimers:array[1..20] of word;
    count:byte;                             {����� ����� �� ����}
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
  TMyApp.Insert(New(PTimerView,Init(R,'Turbo Test 4.32')));
  TMyApp.Insert(T);
  R.Assign(2,24,38,25);
  Q:=New(PTimerView,Init(R,'��५�� '+#24+','+#25+' - ��ᬮ�� ����ᮢ.'));
  Q^.Hide;
  TMyApp.Insert(Q);
  PWin:=POprosWin(Application^.ValidView(New(POprosWin,Init)));
  if PWin=nil then MsgHalt('���� � ���������!!!');
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
  if not OpenFile('\TEST\TEMA\tema.'+header.index,pf,0,true) then Halt;
  n:=ReadFour(pf);
  Close(tfc(pf^));
  InputInt(1,n,'����� ��ਠ��(�� 1 �� '+Sstr(n)+')',numVar);
end;

constructor TOpros.Init;
begin
  inherited Init(R,nil);
  IndVopr:=AIndVopr;
  IndVar:=AIndVar;
{  if not Verify('info.dat',GetCurDir) then      {����⠭���� ������}
 { begin                                         {��ࠡ��稪� ���뢠���}
  {  GetIntVec($09,oldInt09H);
   { SetIntVec($09,Addr(IntProc));
{  end;}
  Inp;
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
  if (code=0) and ((key>0) and (key<header.d+2)) then
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
   filename:=MakeVarFileName(header.index,numVar);
   Val(Copy(filename,Pos('.',filename)-3,3),numVar,code);
   {$I-}
   ChDir('\TEST\VAR');
   if IOResult<>0 then MsgHalt('�訡�� ���室� � ��⠫��'+#13#13#3'VAR');
   Assign(fch,filename);
   Reset(fch);
   if (IOResult<>0) then MsgHalt('�訡�� �⥭�� 䠩�� '+header.fName);
   {$I+}
   header.fName:=filename;
   if (not ReadHeader(header)) or (IOResult<>0) then
     MsgHalt('�� 㤠���� ����� ���������!'+#13#13#3'䠩�� '+filename);
   Close(fch);
   cBlocks:=New(PCollection,Init(10,1));
   if not LoadEditFile then Halt;
   {$I-}
   ChDir('\TEST');
   if (IOResult<>0) then
     MsgHalt('�訡�� �� ������ � '+#13#13#3'��⠫�� TEST');
   {$I+}
   jr3:=header.j3/100;jr4:=header.j4/100;jr5:=header.j5/100;
   if not mySet.Init(1,header.nn) then MsgHalt('���� � ��������� mySet');
   Duplet(header.nn,header.nn,mNumVoprs);
   for k:=1 to header.nn do mTimers[k]:=header.tim+1;
   count:=1;
   numVopr:=mNumVoprs[count];
   timer:=header.tim;
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
  lines:=cBlocks^.At(numVopr);              {㪠��⥫� PChar �� ����}
  for k:=0 to 3 do name:=name+lines[k];
  Val(name,k,code);                         {�८��.��� � �᫮}
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
  if (numVopr>cBlocks^.count-1) or (count>header.nn) then EndOpros
  else InterMixLines;
  if IndVopr<>nil then IndVopr^.SetValue(count,1);
  timer:=mTimers[count]                     {��砫쭮� ���祭�� }
end;

procedure TOpros.EndOpros;
var
  ballStr:string;
  russ:boolean;                              {true-�᫨ �� �㪢�-���᪨�}
  RData:ResultData;
  fbd:tfr;
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
  ves:=total div header.nn;                  {��� � ������ ������ �����}
  ball:=ves*prav;                            {������뢠�� ��� �����}
  k:=trunc(ball);                            {�८�ࠧ㥬 � 楫��}
  Str(k,ballStr);
  if ball<total*jr3 then oc:=2;
  if (ball=total*jr3) or (ball>total*jr3) and (ball<total*jr4) then oc:=3;
  if (ball=total*jr4) or (ball>total*jr4) and (ball<total*jr5) then oc:=4;
  if (ball=total*jr5) or (ball>total*jr5) then oc:=5;
  repeat
    name:='';
    russ:=true;
    while Length(name)<4 do
      InputBox('','������ ��� ����㥬���:',name,15);
    for k:=1 to Length(name) do if (Ord(name[k])<128)and
      not(name[k] in[' ','.']) then russ:=false;
    if not russ then MessageBox(#3'���쪮 ���᪨� �㪢�!!!',nil,mfOkButton);
  until russ;
  Assign(fst,'otchet.dat');
  {$I-}
  if not Verify('otchet.dat',GetCurDir) then Rewrite(fst) else Append(fst);
  {$I+}
  if IOResult<>0 then                          {������ � 䠩� *.err}
  begin
    Assign(fst,Copy(name,1,5)+'.err');
    Rewrite(fst);
  end;
  Writeln(fst,date:8,name:15,gruppa:8,kodgr:3,numvar:4,oc:2,ballStr:5,
     header.tema:12,header.kTem:3,' ',badst);
  Close(fst);
  RData.date:=date;
  RData.name:=name;
  RData.gruppa:=gruppa;
  RData.kodGr:=kodGr;
  RData.handle:=219;
  RData.flag:=Ord('�');
  RData.numVar:=numVar;
  RData.oc:=oc;
  RData.ball:=trunc(ball);
  RData.tema:=header.tema;
  RData.kTem:=header.kTem;
  Fillchar(RData.badM,SizeOf(RData.badM),0);
  for k:=1 to neprav-1 do RData.badM[k]:=badMas[k];
  Assign(fbd,'bd.dat');
  if not Verify('bd.dat',GetCurDir) then Rewrite(fbd) else Reset(fbd);
  Seek(fbd,FileSize(fbd));
  Write(fbd,RData);
  Close(fbd);
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

