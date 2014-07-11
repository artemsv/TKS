unit BDWindow;                {дата создания начальной версии: 02.01.02}

interface

uses App,Dialogs,Drivers,MsgBoxMy,MyFunc,Objects,Views,Types,Consts,MyLib,
     BaseWin,Validate,MyFunc2,Printer,BdDialog,Menus,Colors,Crt,StdDlg,Dos;

const
  defaultFileBD     =  'bd.dat';
  defaultFilters    =  3;
  otchetFile        =  'otchet.dat';
  ifDelOtchetFile:boolean=true;         {удалять OTCHET.DAT после добавл.}

type
  PBDWindow=^TBDWindow;
  TBDWindow=object(TBaseWindow)
    max:byte;                       {максим.кол-во показываемых записей}
    cur:ShortInt;                   {текущая подсвеченая запись в chars}
    ifWasEdit:boolean;              {true,если хоть один раз вошли в режим
                                      редактирования}
    ifAnyField:boolean;             {true-выбирать все записи}
    ifTema,ifGruppa,ifdate:boolean; {флаги поиска}
    ifEdit:boolean;                 {включен режим редактирования}
    Filters:word;                   {фильтр поиска:его знач.соотв.флагам}
    zTema:st12;                     {zXXXX-образцы для поиска}
    zGruppa,zDate:st8;
    kGr:integer;
    kTem:byte;
    why:byte;                       {0-источник-otchet.dat,1-другой файл}
    forma:byte;
    total:word;                     {общее количество записей}
    start:word;                     {первая показываемая запись в colBD}
    colBD:PCollection;              {коллекция найденых записей}
    sredn:real;
    fileBD:PathStr;
    curBD:ResultData;               {текущая редактируемая запись}
    constructor Init(ACommand:word);
    procedure HandleEvent(var Event:TEvent);virtual;
    procedure FiltersDialog;
    function  GetFilter:boolean;
    function  LoadBD:boolean;        {заполняет colBD нужными записями}
    procedure InitConfiguration;     {установка конфигурации}
    procedure SetFlags;              {преобразует Filter в флаги}
    procedure Form;                  {в соотв. с forma выз.проц.заполнения}
    procedure Forma1;                {заполняет всю форму записями}
    function  Equal(bd:ResultData):boolean;{проверка эквивалентности фильтру}
    procedure OtchetToBD;            {добавляет OTCHET.DAT к базе}
    procedure Print;                 {распечатка записей}
    procedure InitEdit;              {инициализация режима редактирования}
    procedure Edit;                  {окно редактирования}
    procedure Delet;                 {удаление текущей записи}
    procedure Save;                  {сохранение изменений}
  end;

implementation

constructor TBDWindow.Init;
var
  R:TRect;D:PFileDialog;
begin
  R.Assign(0,0,80,23);
  TWindow.Init(R,'Форма '+Sstr(forma),0);
  D:=New(PFileDialog,Init('*.dat','Найдите','stFileBD',fdOkButton,100));
  if DeskTop^.ExecView(D)=cmCancel then Fail;
  D^.GetFileName(fileBD);
  Dispose(D,Done);
  if fileBD='' then Fail;
  ifAnyField:=fileBD=FExpand(otchetFile);
  ifEdit:=false;ifWasEdit:=false;ifGruppa:=false;ifdate:=false;
  start:=0;
  cur:=-1;
  CleanAll;                             {очистка chars}
  InitConfiguration;                    {устанавливает Filters из BD.CFG}
  if not ifAnyField then FiltersDialog;
  SetFlags;                             {уст.флаги поиска в соотв.с Filters}
  if not ifAnyField then
    if not GetFilter then Fail;         {уст.шаблон поиска в соотв.с флагами}
  if not LoadBD then Fail;              {загрузка пакета записей}
  if total<14 then max:=total else max:=14;
  forma:=ACommand mod 10;
  Form;
end;

function TBDWindow.LoadBD:boolean;
var
  BD:ResultData;pBD:^ResultData;
begin
  LoadBD:=false;
  colBD:=New(PCollection,Init(10,1));
  if not OpenFile(fileBD,pf,4,true) then Halt;
  total:=0;
  while not Eof(tfr(pf^)) do
  begin
    Read(tfr(pf^),BD);
    if ifAnyField or Equal(BD) then
    begin New(pBD);pBD^:=BD;colBD^.Insert(pBD);end;
  end;
  if colBD^.count=0 then begin
    System.Close(tfr(pf^));
    MessageBox(#3'Информация не обнаружена!',nil,mfOkButton);
    Dispose(colBD,Done);
    Exit;
  end;
  total:=colBD^.count-1;
  System.Close(tfr(pf^));
  LoadBD:=true;
end;

procedure TBDWindow.InitConfiguration;
var
  s:string;
begin
  if not OpenFile('bd.cfg',pf,2,true) then
  begin
    if MessageBox(#3'Создать его?',nil,mfYesButton+mfNoButton)=cmYes then
    begin
      OpenFile('bd.cfg',pf,2,false);
      s:=defaultFileBD;Writeln(tft(pf^),s);
      s:=Sstr(defaultFilters);Writeln(tft(pf^),s);
      System.Close(tft(pf^));
    end;
    fileBD:=defaultFileBD;
    filters:=defaultFilters;
    Exit;
  end;
  Readln(tft(pf^),s{fileBD});
  Readln(tft(pf^),s);
  System.Close(tft(pf^));
  filters:=Vval(s);
  SetFlags;
  forma:=1;
end;

function  TBDWindow.GetFilter:boolean;
begin
  GetFilter:=false;
  if ifTema   then if not SelectTema(zTema,kTem) then Exit;
  if ifGruppa then if not SelectGruppa(zGruppa,kGr) then Exit;
  if ifDate   then if not EnterDate(zDate) then Exit;
  GetFilter:=true;
end;

procedure TBDWindow.HandleEvent;
begin
  if Event.What=evKeyDown then begin
    case Event.KeyCode of
      kbAltE : InitEdit;
      kbDown : if ifEdit and (cur=max+3) or not ifEdit then begin
                if start+max<total then Inc(start) end
                else begin FillLine(15,25,cur,sym);Inc(cur);
                FillLine(15,25,cur,syv);end;
      kbUp   :  if ifEdit and (cur<>4) then begin FillLine(15,25,cur,sym);
                          Dec(cur);FillLine(15,25,cur,syv);end else
                          if start<>0 then Dec(start);
      kbPgDn :  if (start+2*max)<total then Inc(start,max-1)
                  else start:=total-max;
      kbPgUp :  if start>max then Dec(start,max-1) else start:=0;
      kbEnter: if ifEdit then Edit;
      kbDel  : if ifEdit then Delet;
    else Exit;
    end;
    Form;
  end;
  if Event.What=evCommand then begin
    case Event.Command of
      cmFilter:Filtersdialog;
      cmPrint:Print;
      cmEdit:InitEdit;
      cmClose,
      cmQuit:begin
              if ifWasEdit then begin w:= MessageBox(#3'Сохранить изменения?'
              ,nil,mfYesNoCancel);
              case w of cmYes:Save;cmCancel:ClearEvent(Event);end;end;
              if fileBD=FExpand('otchet.dat') then
                if Messagebox(#3'присоеденить файл отчета к базе?',nil,
                mfYesButton+mfNoButton)=cmYes then OtchetToBD
             end;
    end;
  end;
  inherited HandleEvent(Event);
end;

procedure TBDWindow.Forma1;
var
  k,i:byte; m:word;
  st:string;p:pRd;
begin
  CleanSymbols;
  sredn:=0;
  for k:=1 to 3 do
    for i:=1 to 78 do chars[k,i]:=256*Hi(chars[k,i])+byte(form1[k,i]);
  k:=4;                 {номер заполняемой строки в chars}
  m:=start+k-4;         {индекс записи в colBD}
  while k<max+4 do
  begin
    for i:=0 to 78 do chars[k,i]:=256*Hi(chars[k,i])+byte(form1[4,i]);
    if m>total then Break;
    p:=colBD^.At(m);
    if p^.flag=253 then begin Inc(m); Continue; end;
    InsM(p^.name,chars[k],15);
    InsM(Sstr(p^.handle),chars[k],30);
    InsM(Sstr(p^.flag),chars[k],45);
    sredn:=sredn+p^.ball;
    Inc(k);Inc(m);
  end;
  for k:=1 to 78 do chars[max+4,k]:=256*Hi(chars[max+4,k])+byte(form1[5,k]);
  if start+max<total then chars[max+5,55]:=sym+25
    else chars[max+5,55]:=sym+32;
  InsM('Средний балл: '+Rstr(sredn/total),chars[max+6],15);
end;

function  TBDWindow.Equal(bd:ResultData):boolean;
begin
  Equal:=false;
  if bd.flag=253 then Exit;                             {удаленная запись}
  if iftema   then if bd.tema   <>  ztema   then Exit;
  if ifGruppa then if bd.gruppa <>  zGruppa then Exit;
  if ifDate   then if bd.date   <>  zDate   then Exit;
  Equal:=true
end;

procedure TBDwindow.FiltersDialog;
var
  DD: PDialog;
  R: TRect;
  DataRec: Word;
begin
  R.Assign(10,6,40,20);
  DD := New(PDialog, Init(R, 'Фильтр поиска'));
  with DD^ do
  begin
    R.Assign(2,2,25,10);
    Insert(New(PCheckBoxes, Init(R,
      NewSItem('Поиск по теме',
      NewSItem('Поиск по группе',
      NewSItem('Поиск по имени',nil))))));
    R.Assign(1,11,15,13);
    Insert(New(PButton, Init(R, 'Установить', cmOk, bfDefault)));
    R.Assign(15,11,28,13);
    Insert(New(PButton, Init(R, 'Отменить', cmCancel, bfNormal)));
    SelectNext(False);
  end;
  DataRec := 0;
  DataRec := Filters and (evMouse or evKeyDown);
  DataRec := DataRec or ((Filters - DataRec) shr 3);
  if Application^.ExecuteDialog(DD, @DataRec) <> cmCancel then
  begin
    Filters := 0;
    Filters := DataRec and (evMouse or evKeyDown);
    Filters := Filters or ((DataRec - Filters) shl 3);
  end;
end;

procedure TBDWindow.Print;
var
  k:byte;p:pRD;
  D:PDialog;
  R:TRect;
begin
  R.Assign(20,8,60,15);
  D:=New(PDialog,Init(R,'Внимание!'));
  R.Assign(9,3,31,4);
  D^.Insert(New(PStaticText,Init(R,'Внимание! Идет печать!')));
  Application^.InsertWindow(D);
  for k:=0 to colBD^.count-1 do
  begin
    p:=colBD^.At(k);
    Writeln(LST,p^.name:12,p^.oc:5,p^.ball:5)
  end;
  Delay(11000);
  Dispose(D,Done)
end;

procedure TBDWindow.Initedit;
var k:byte;
begin
  if ifEdit then begin ifEdit:=false;SetNormalColor;cur:=-1;Exit;end;
  cur:=4;
  ifEdit:=true;
  ifWasEdit:=true;
  for k:=15 to 25 do chars[cur,k]:=syv+Lo(chars[7,k]);
  Draw;
end;

procedure TBDWindow.Edit;
var
  R:TRect; D:PDialog;
  P:PInputLine;pp:pRD;
  EditBD:record
    dat:st8;
    name:st15;
    gr:st8;
    tem:st12;
  end; st:string;
begin
  pp:=colBD^.At(cur-4+start);
  curBD:=pp^;
  FillChar(editBD,SizeOf(editBD),' ');
  editBD.dat:=curBD.date;
  editBD.name:=curBD.name;
  editBD.GR:=curBD.gruppa;
  editBD.tem:=curBD.tema;
  R.Assign(10,5,60,20);
  D:=New(PDialog,Init(R,'ssssssseditBD'));

  R.Assign(3,2,15,3);P:=New(PInputLine, Init(R, 8));
  D^.Insert(P);
  P^.SetValidator(New(PPXPictureValidator,Init('##/##/##',true)));
  R.Assign(2,1,10,2);D^.Insert(New(PLabel,Init(R,'Дата',P)));

  R.Assign(3,4,22,5);P:=New(PInputLine, Init(R, 15));D^.Insert(P);
  R.Assign(2,3,8,4);D^.Insert(New(PLabel,Init(R,'Ф.И.О.',P)));

  R.Assign(3,6,15,7);P:=New(PInputLine, Init(R, 8));D^.Insert(P);
  R.Assign(2,5,9,6);
  D^.Insert(New(PLabel,Init(R,'Группа',P)));

  R.Assign(3,8,19,9);P:=New(PInputLine, Init(R, 12));D^.Insert(P);
  R.Assign(2,7,9,8); D^.Insert(New(PLabel,Init(R,'Тема',P)));

  R.Assign(1,11,15,13);
  D^.Insert(New(PButton, Init(R, 'Установить', cmOk, bfDefault)));
  R.Assign(15,11,28,13);
  D^.Insert(New(PButton, Init(R, 'Отменить', cmCancel, bfNormal)));
  SelectNext(false);
  if Application^.ExecuteDialog(D,@editBD)<>cmCancel then
  begin
    curBD.date:=editBD.dat;
    curBD.name:=editBD.name;
    curBD.gruppa:=editBD.GR;
    curBD.tema:=editBD.tem;
    New(pp);pp^:=curBD;
    colBD^.AtPut(cur-4+start,pp);
  end;
end;

procedure TBDWindow.Delet;
var
  p:pRD;
begin
  w:=MessageBox(#3'Удалить текущую запись?',nil,mfYesButton+mfNoButton);
  if w in [cmNo,cmCancel] then Exit;
  p:=colBD^.At(cur-4+start);
  p^.flag:=253;
  Dec(total);
  if max>total then Dec(max);
end;

procedure TBDWindow.SetFlags;
begin
  case Filters of
    1:ifTema:=true;
    3:begin ifTema:=true;ifGruppa:=true;end;
    7:begin ifTema:=true;ifGruppa:=true;iftema:=true;end;
  end;
end;

procedure TBDWindow.Form;
begin
  case forma of
    1:Forma1;
  end;
  Draw;
end;

procedure TBDWindow.Save;
var
  k:word;p:pRD;
begin
  ifEdit:=false;
  ifWasEdit:=false;
  if not OpenFile(fileBD,pf,4,true) then exit;
  for k:=0 to colBD^.count-1 do
  begin
    p:=colBD^.At(k);
    if p^.flag=253 then
    begin
      Seek(tfr(pf^),p^.handle-1);
      Write(tfr(pf^),p^);
    end;
  end;
  System.Close(tfr(pf^));
end;

procedure TBDWindow.OtchetToBD;
var
  bd:ResultData;fbd:tfr;len:longint;
begin
  if not OpenFile(otchetFile,pf,4,true) then Halt;
  Assign(fbd,'bd.dat');
  Reset(fbd);
  len:=FileSize(fbd);
  Seek(fbd,FileSize(fbd));
  while not Eof(tfr(pf^)) do
  begin
    Inc(len);
    Read(tfr(pf^),bd);
    bd.handle:=len;
    Write(fbd,bd);
  end;
  System.Close(fbd);
  System.Close(tfr(pf^));
end;
end.
