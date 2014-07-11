{$O-}
unit OprChild;                       //  дата создани€ 6.0:  15.11.02

interface

uses
  Windows,Sysutils,MRed,OprTypes,UOleRTF,Streams,WinApp,MConst;

type
  TOprosChild=class(TRed)
  private
    FRandomVoprs:array[0..100] of integer;//  массив случ.номеров кадров
    Fprav:integer;               //  кол-во "угаданных" ответов учащегос€
    FTim:Cardinal;               //  врем€???
    Info:RInfo;                  //  запись с параметрами опроса
    FFrame:TFrame;               //  текущий кадр
    FRight:integer;              //  номер правильного ответа в тек.кадре
    FFio:string;                 //  им€ тестируемого
    BadStr:string;               //  строка с номерами непр.вопросов
    BadArr:array[0..255] of integer;  //  массив с номерами непр.вопросов
    BadNum:integer;              //  номер неправильного ответа в массиве
    Total:integer;               //  общее затраченное врем€ на все вопросы
    Names:array[0..100] of string;
    procedure EndTime;              //   ваше врем€ истекло
    procedure GoodAnswer;           //   реакци€ на правильный ответ
    procedure BadAnswer;            //   реакци€ на неправильный ответ
    procedure NextVopr;             //   показать следующий вопрос
    procedure EndOpros;
  protected
    procedure DoTimer(Wparam,LParam:DWORD);override;
    procedure DoSetFocus(WParam:DWORD);override;
    function DoCommand(Wparam,LParam:DWORD):DWORD;override;
    function CloseQuery:boolean;override;
    function Init:boolean;override;
    function GetRTF:TOleRTF;override;         //  получить объект редактора
  public
    constructor Create(AParent:TMDIWindow;AClient:TMDIClient;AInfo:RInfo;fio:string);
  end;


implementation

{$R 'RES\oc.res' }

uses OprMain,Messages,WinFunc,OprRTF,RichEdit,MListName,QSort,Macro,MMark;

{ TOprosChild }

procedure TOprosChild.BadAnswer;
begin
  BadArr[BadNum]:=FrandomVoprs[NumFRame]; //  запомнили номер непр.вопроса
  Inc(BadNum);                            //  счЄтчик неправильных ответов
  NextVopr;                               //  перейти к следующему кадру
end;

function GetTim1(Tim:integer):string;
begin
  Result:='ќсталось: '+GetTim(Tim);
end;

constructor TOprosChild.Create(AParent:TMDIWindow;AClient:TMDIClient;AInfo:RInfo;fio:string);
begin
  inherited Create(AParent,AClient,PChar(Path+'\'+AInfo.fnt));
  FFio:=fio;                                 //  им€ тестируемого
  NumFrame:=1;
  TOprosMainWindow(Parent).StatusBar.SetText(0,'¬опрос номер 1');
  Info:=AInfo;                               //  запись с параметрами опроса
  FTim:=Info.tim;
  Total:=0;
  FPrav:=0;
  BadNum:=1;
  TOprosMainWindow(Parent).StatusBar.SetText(2,PChar(GetTim1(FTim)));
  try
    Duplet(Header.nn,Info.colVopr,FRandomVoprs);
  except
    on E:Exception do MessageBox(Handle,PChar(E.Message),nil,$10);
  end;
  FFrame:=TFrame(Frames.Items[FRandomVoprs[NumFrame]-1]);
  RTF.SetFrame(FFrame);
  Perform(WM_SETREDRAW,0,0);
  RTF.SetFrame(FFrame);                      //  устанавливаем кадр
  FRight:=TOprosRTF(RTF).Shuffle(Header.d);  //  перемеш. и получ.прав.ответ
  SetTimer(Handle, 222, 1000,nil);           //  запускаем системный таймер
  Perform(WM_SETREDRAW,1,0);
end;

function TOprosChild.CloseQuery: boolean;
begin
  Result:=true;
  TOprosMainWindow(Parent).FTitle:=Title;  //  восстанавливаем заголовок
end;

function TOprosChild.DoCommand(WParam, LParam: DWORD):DWORD;
begin
  Result:=inherited DoCommand(WParam,LParam);
  case Wparam of
    CM_QUESTION:                    //  от всплывающего меню
     if LParam in [1..Header.d+1,$FF] then
       if FRight=Lparam then GoodAnswer else BadAnswer;
  end;
end;

procedure TOprosChild.DoTimer(Wparam, LParam: DWORD);
begin                                 // обработка очередного тика от таймера
  if FTim=0 then EndTime else
  begin
    Dec(FTim);                        //  счЄтчик времени текущего вопроса
    inc(Total);                       //  счЄтчик затраченного общего времени
    TOprosMainWindow(Parent).StatusBar.SetText(2,PChar(GetTim1(FTim)));
  end;
end;

procedure TOprosChild.EndOpros;
var
  f:text;
  pch:PChar;
  a3,a4,a5,Size,k,OC:integer;
  st:string;
begin                     // очистка строки статуса
  SendMessage(Parent.Handle,WM_COMMAND,CM_STATUSTEXTCLEAR,0);
  KillTimer(Handle,222);                     //  вырубили таймер
  a3:=trunc(info.ColVopr * (info.j3/100)+0.5);//  столько правильных на тройку
  a4:=trunc(info.ColVopr * (info.j4/100)+0.5);
  a5:=trunc(info.ColVopr * (info.j5/100)+0.5);
  if FPrav<a3 then OC:=2 else
  if (FPrav>=a3) and (FPrav<a4) then OC:=3 else
  if (FPrav>=a4) and (FPrav<a5) then OC:=4 else OC:=5;
  QuickSort(BadArr,1,info.colVopr-FPrav);//  сортировка массива непр.вопросов
  BadStr:='';
  for k:=1 to info.colVopr-Fprav do      //  формируем строку непр.вопросов
    Badstr:=Badstr+IntToStr(BadArr[k])+',';
  SetLength(BadStr,Length(BadStr)-1);        //  отрезаемпоследнюю зап€тую
  st:=GetTim(Total);                         //  преоб.общее врем€ в строку
  if Info.addToOtchetFile then
  begin
    AssignFile(f,Path+'\'+OtchetFile);
    if not FileExists(Path+'\'+OtchetFile) then Rewrite(f) else Append(f);
    Writeln(f,FFio);
    Writeln(f,oc);
    Writeln(f,FPrav);
    Writeln(f,info.colVopr);
    Writeln(f,info.date);
    Writeln(f,info.tema);
    Writeln(f,info.gr);
    Writeln(f,info.teacher);
    Writeln(f,Badstr);
    Writeln(f,st);
    CloseFile(f);
  end;
{  AssignFile(f,Path+'\temp.grp');
  Reset(f);
  k:=0;
  while not eof(f) do                        //  считываем имена в массив
  begin
    Readln(f,Names[k]);
    Inc(k);
  end;
  Size:=k;                                 //  количество считанных имЄн
  CloseFile(f);
  Erase(f);

  AssignFile(f,Path+'\temp.grp');
  Rewrite(f);
  for k:=0 to Size-1 do
    if Names[k]<> FFio then Writeln(f,Names[k]);
  CLoseFile(f);}
  Hide;                                      // пр€чем окно с вопросом
  if Info.showOC then ShowOC(Self,oc,info.colVopr,FPrav,Total,badstr);
  Close;                                     // уничтожаем окно с вопросами
  TOprosMainWindow(Parent).StatusBar.SetText(0,Invite1); //  станд.прглашение
  TOprosMainWindow(Parent).StatusBar.SetText(1,Invite2);
  TOprosMainWindow(Parent).StatusBar.SetText(2,Invite3)
end;

procedure TOprosChild.EndTime;              //  врем€ на тек.вопрос истекло
begin
  BadArr[BadNum]:=FrandomVoprs[NumFRame];   //  очередной в массив неправ.
  Inc(BadNum);                              //  счЄтчик неправ.ответов
  FTim:=info.tim;                           //  обновление счЄтчика времени
  NextVopr;                                 //  перейти к следующему вопросу
end;

function TOprosChild.GetRTF: TOleRTF;
begin
  Result:=TOprosRTF.Create(Self,ES_MULTILINE or ES_AUTOVSCROLL or
    ES_AUTOHSCROLL or ES_NOOLEDRAGDROP or WS_VSCROLL or WS_HSCROLL,
      WS_EX_ACCEPTFILES );
end;

procedure TOprosChild.GoodAnswer;
begin
  Inc(FPrav);                             //  счетчик правильных ответов
  NextVopr;                               //  перейти к следующему вопросу
end;

function TOprosChild.Init: boolean;
begin
  Result:=false;
  if not LoadTema then Exit;
  Result:=true;
end;

procedure TOprosChild.NextVopr;
begin
  Inc(NumFrame);
  if NumFrame>info.colVopr then EndOpros else
  begin
    FFrame:=TFrame(Frames.Items[FRandomVoprs[NumFrame]-1]);
    RTF.Perform(WM_SETREDRAW,0,0);       // сбросить флаг перерисовки
    RTF.SetFrame(FFrame);
    FRight:=TOprosRTF(RTF).Shuffle(Header.d);
    TOprosMainWindow(Parent).StatusBar.SetText(0,PChar('¬опрос номер '+
           IntToStr(NumFrame)));
    FTim:=info.tim;                      //  восстановить счетчик времени
    RTF.Perform(WM_SETREDRAW,1,0);
  end;
end;

procedure TOprosChild.DoSetFocus(WParam:DWORD);
begin
  RTF.SetFocus;
  TOprosMainWindow(parent).StatusBar.SetText(0,PChar('¬опрос 1'));  
end;

end.
