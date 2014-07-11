unit MyFunc;                            {дата создания модуля:     09.10.01}
                                        {дата последних изменений: 17.01.02}

interface

uses
  App,Objects,Dialogsr,Dos,Views,Types,Validatr,MsgBoxMy,MyObject,MyLib,
  Crt,Stream;

function OpenStream(fileName:PathStr;var S:PStream;mode:word):boolean;
function SelectTem(var fn:PathStr):boolean;
procedure WriteError;
procedure MsgHalt(st:string);
function  OpenFile(fileName:st79;var p:pointer;vid:byte;b:boolean):boolean;
function  InputInt(min,max:word;st:string;var chislo:integer;hlp:word):word;
function  SelectTema(var header:tHeader):word;
function  ReadFour(p:pointer):word;
function  ReadHeader(var header:tHeader):boolean;
procedure WriteHeader(header:THeader);
procedure HeaderEdit;
function  ReadHelpFile(var collection:PCollection;fn:st79):boolean;
procedure WatchWindow(var cCol:PCollection;a1,b1,a2,b2:byte);
function  Titul(var HD:PHdr):boolean;
function  MakeVarFileName(index:string;numvar:integer):st79;
function  GetFilesList(shablon:st79):PCollection;
function  EnterDate:st8;
function  ExecDialog(P: PDialog; Data: Pointer): Word;
function  ListDialog(cStr:PCollection;s:string;
                    var st:string;var n:integer;hlpCtx:word):word;

implementation

uses
  Strings;

var          {глобальная переменная модуля.равна true,если возникла ошибка}
  error:boolean;

function OpenStream(fileName:PathStr;var S:PStream;mode:word):boolean;
begin
  OpenStream:=false;
  S:=New(PDosStream,Init(fileName,mode));
  if S^.status<>stOk then Exit;
  OpenStream:=true
end;

function SelectTem;
var
  SS:SearchRec;
  cCol:PCollection;
  sst:string;
  k:integer;
begin
  SelectTem:=false;
  FindFirst('*.tem',AnyFile,SS);
  cCol:=New(PCollection,Init(10,1));
  while DosError=0 do
  begin
    cCol^.Insert(NewStr(SS.name));
    FindNext(SS);
  end;
  if cCol^.count=0 then
  begin
    MessageBox(#3'Не найдены файлы *.tem'+#13+#13+#3'в каталоге TEST/TEMA',
    nil,mfOkButton);
    Exit;
  end;
  if ListDialog(cCol,'Список тем',sst,k,7)=cmCancel then Exit;
                   {?????ПАМЯТЬ НЕ ОСВОБОЖДАЕТСЯ!!}
  cCol^.DeleteAll;
  Dispose(cCol,Done);
  fn:=sst;
  SelectTem:=true;
end;

procedure WriteError;
var st:string[20];
begin
  if DosError=0 then Exit;
  case DosError of
    2 : st:= 'File not found';
    3 : st:= 'Path not found';
    5 : st:= 'Access denied';
    6 : st:= 'Invalid handle';
    8 : st:= 'Not enough memory';
   10 : st:= 'Invalid environment';
   11 : st:= 'Invalid format';
   18 : st:= 'No more files';
  end;
  MessageBox(#3+st,nil,mfOkButton);
  Halt;
end;

procedure MsgHalt(st:string);
begin
  MessageBox(#3+st,nil,mfOkButton);
  Halt
end;

function  OpenFile(fileName:st79;var p:pointer;vid:byte;b:boolean):boolean;
var
  fc : tfc;
  fb : tfb;
  ft : tft;
  fh : tfh;
begin
  OpenFile:=false;
  {$I-}
  case vid of
    0:begin Assign(fc,fileName);if b then Reset(fc) else Rewrite(fc);
       p:=@fc;end;  {vid=0 tfch         }
    1:begin Assign(fb,fileName);if b then Reset(fb) else Rewrite(fb);
       p:=@fb;end;  {vid=1 file of byte }
    2:begin Assign(ft,fileName);if b then Reset(ft) else Rewrite(ft);
       p:=@ft;end;  {vid=2 text         }
    3:begin Assign(fh,fileName);if b then Reset(fh) else Rewrite(fh);
       p:=@fh;end;  {vid=3 tfh          }
  end;
  if (IOResult<>0) and b then
  begin
    MessageBox(#3'Ошибка чтения файла '+fileName,nil,mfOkButton);
    {$I+}Exit;
  end;
  OpenFile:=true{$I+}
end;

function InputInt;
var
  R:TRect;
  a,m:word;D:
  PDialog;
  Inp:PInputLine;
  x,y:byte;
  V:PRangeValidator;
  code:integer;
begin
  m:=Length(st);
  x:=(78-m) div 2-7;
  y:=x+m+15;
  R.Assign(x,5,y,13);
  V:=New(PRangeValidator,Init(min,max));
  D:=New(PDialog,Init(R,'Диалог:'));
  code:=(y-x) div 3;                        {часть длины приглашения}
  with D^ do
    begin
      R.Assign(3,3,16,4);
      Inp:=New(PInputLine,Init(R,45));
      Inp^.SetValidator(V);
      Insert(Inp);
      R.Assign(2,2,11+m,3);
      Insert(New(PLabel,Init(R,'Введите '+st,Inp)));
      R.Assign((y-x) div 2-code,5,(y-x) div 2-code+10,7);
      Insert(New(PButton,Init(R,'Ввести',cmOk,bfDefault)));
      R.Assign((y-x) div 2+code-10,5,(y-x) div 2+code,7);
      Insert(New(PButton,Init(R,'Справка',cmHelp,bfNormal)));
      HelpCtx:=hlp;
      SelectNext(false);
    end;
    repeat
      a:=DeskTop^.ExecView(D);
      st:=Inp^.Data^;
      Val(st,chislo,code);
    until (a=cmCancel) or (code=0);
    InputInt:=a;
end;

function SelectTema(var header:tHeader):word;
var
  k:integer;st:string[12];
  f:tfh;cHead:PCollection;
  head:tHead;cTem:PStringCollection;
  headPtr:pHead;sst:string;
begin
  SelectTema:=cmCancel;
  cHead:=New(PCollection,Init(10,1));
  cTem:=New(PStringCollection,Init(10,1));
  if not OpenFile(path+'TEMA\temas.dat',pf,3,true) then Exit;
  while not Eof(tfh(pf^)) do
    begin
      Read(tfh(pf^),head);
      New(headPtr);headPtr^:=head;
      cHead^.Insert(headPtr);
      cTem^.Insert(NewStr(headPtr^.tema));
    end;
  Close(tfh(pf^));
  repeat
    if ListDialog(cTem,'Список тем',sst,k,7)=cmCancel then Exit;
                   {?????ПАМЯТЬ НЕ ОСВОБОЖДАЕТСЯ!!}
    for k:=0 to Pred(cHead^.count) do
    begin
      headPtr:=cHead^.At(k);
      if headPtr^.tema=sst then Break;
    end;
    header.kTem:=headPtr^.kTem;
    st:=headPtr^.index; st:='tema.'+headPtr^.index;
    if not Verify(st,path+'TEMA') then
        MessageBox(#3'Вопросы по данной теме не обнаружены!',nil,mfOkButton);
  until Verify(st,path);
  header.fName:=path+'TEMA\'+st;                         {заполняем поле}
  if not ReadHeader(header) then Exit;
  cHead^.DeleteAll;
  Dispose(cHead,Done);
  Dispose(cTem,Done);
  SelectTema:=cmOk;
end;

function ReadFour;
var
  num,k:integer;
  ch:char;
  st:string;
begin
  st:='';
  for k:=0 TO 3 do
    begin
      Read(tfc(p^),ch);
      ST:=ConCat(st,ch);
    end;
  Val(st,num,k);
  if (k<>0) and (error=true) then     {сообщение об ошибке дается один раз}
  begin
    MessageBox(#3'Ошибка в заголовке файла!',nil,mfOkButton);
    error:=false
  end;
  ReadFour:=num;
end;

function ReadHeader(var header:tHeader):boolean;
var
  ch:char;
  fch:tfc;
  w:word;
  s:string;
begin
  error:=true;                           {признак ошибки в заголовке}
  ReadHeader:=false;
  if not OpenFile(header.fName,pf,0,true) then Exit;
  header.index:=GetExt(header.fName);
  header.colv:=ReadFour(pf);
  header.nn:=ReadFour(pf);
  header.ckolko:=ReadFour(pf);
  header.tim:=ReadFour(pf);
  header.J5:=ReadFour(pf);
  header.J4:=ReadFour(pf);
  header.J3:=ReadFour(pf);
  w:=ReadFour(pf);
  header.d:=w mod 10;
  header.ktem:=w div 100;
  header.tema:='';
  while not Eof(tfc(pf^)) do
  begin
    Read(tfc(pf^),ch);
    if(ch=#219) or (ch=#221) then Break
    else header.tema:=Concat(header.tema,ch);
  end;
  Close(tfc(pf^));
  ReadHeader:=true;
end;

procedure WriteHeader(header:THeader);
var
  p1   :  tm1;
  k    :  byte;
  fch  :  tfc;
  st   :  string;
begin
  for k:=0 to 200 do p1[k]:=#32;
  with header do
  begin
    Assign(fch,fName);
    Four(0,0,p1);Four(4,0,p1);Four(8,ckolko,p1);Four(12,tim,p1);
    Four(16,j5,p1);Four(20,j4,p1);Four(24,j3,p1);Four(28,d,p1);
    for k:=1 to Length(tema) do p1[31+k]:=tema[k];
    p1[32+Length(tema)]:=#219;
  end;
  Rewrite(fch);
  k:=0;
  repeat
    Write(fch,p1[k]);
    Inc(k)
  until p1[k-1]=#219;
  Close(fch);
end;

procedure HeaderEdit;
var
  f  : tfc;
  k  : byte;
  hd : THeader;
  m1 : tm1;
begin
  if SelectTema(hd)=cmCancel then exit;
  if MessageBox(#3'Изменить количество вопросов?',nil,$300)=cmYes then
   begin
     if InputInt(1,999,'новое количество:',hd.ckolko,0)=cmCancel then Exit;
     Assign(f,hd.fName);Reset(f);Four(0,hd.ckolko,m1);
     Seek(f,8);for k:=0 to 3 do Write(f,m1[k]);Close(f);
   end;
  if MessageBox(#3'Изменить время но обдумывание?',nil,$300)=cmYes then
  begin
   InputInt(1,300,'новое время(в секундах):',hd.tim,0);
   Assign(f,hd.fName);Reset(f);
   Four(0,hd.tim,m1);Seek(f,12);
   for k:=0 to 3 do Write(f,m1[k]);Close(f)
  end;
end;

function  ReadHelpFile(var collection:PCollection;fn:st79):boolean;
var
  f : text;
  s : string;
begin
  ReadHelpFile:=false;
  collection:=New(Pcollection,Init(20,5));
  if not Openfile(fn,pf,2,true) then Exit;
  with collection^ do
    while not Eof(tft(pf^)) do
      begin
        Readln(tft(pf^),s);
        Insert(NewStr(s));
      end;
  Close(tft(pf^));
  ReadHelpFile:=true;
end;

procedure WatchWindow(var cCol:PCollection;a1,b1,a2,b2:byte);
var
  R  : TRect;
  a  : word;
  Ww : PWatchWindow;
begin
  R.Assign(a1, b1, a2, b2);
  Ww:=New(PWatchWindow, Init(R, 'Справка',cCol));;
  DeskTop^.ExecView(Ww);
  Dispose(Ww,Done);
end;

function  Titul(var HD:PHdr):boolean;
const
  st:string='';
  mmm:byte=0;
  mLin : set of byte=[];
var
  R      : TRect;
  ft     : text;
  TT     : TTestFile;
  ff,tem,pch : PChar;
  ckolko,code,dd,kTem: integer;
  SS     : SearchRec;
begin
  Titul:=false;
  repeat
    if InputBox('','Введите новую тему',st,12,0)=cmCancel then Exit;
  until st<>'';
  StrPCopy(tem,st);
  Inputbox('','Введите заголовок файла(до 100 символов)',st,100,0);
  StrPCopy(pch,st);
  if InputInt(1,maxVoprsInTema,'количество вопросов',ckolko,0)=
    cmCancel then Exit;;
  if InputInt(1,maxWrongAnswer,'количество неправильных ответов',dd,0)=
    cmCancel then Exit;;
  Assign(ft,'redactor.cfg');
  Reset(ft);
  Readln(ft,st);
  Val(st,ktem,code);
  Close(ft);
  mmm:=ktem+1;
  st:='';
  repeat
    if InputBox('','Введите имя файла темы',st,8,0)=cmCancel then Exit;
    st:=st+'.tem';
    if Verify(st,GetCurDir) then MessageBox(#3'Данное имя '+#13+#13+
            #3'уже зарезервировано!',nil,mfOkButton);
  until not Verify(st,GetCurDir);
  StrPCopy(ff,st);
  HD:=New(PHdr,Init(0,ckolko,mmm,dd,tem,ff,pch));
  TT.Init(st,stCreate,Hd);
  TT.Done;
  Titul:=true
end;

function  GetFilesList(shablon:st79):PCollection;
var
  cCol : PCollection;
  Sr   : SearchRec;
begin
  FindFirst(shablon,AnyFile,Sr);
  if DosError<>0 then
    begin
      MessageBox(#3'Не найдены файлы '+shablon+' в каталоге '+#13+#13+#3+
        +GetCurDir,nil,mfOkButton);
      GetFilesList:=nil;
      Exit;
    end;
  cCol:=New(PCollection,Init(3,1));
  while DosError=0 do
    begin
      cCol^.Insert(NewStr(Sr.name));
      FindNext(Sr);
    end;
  GetFileslIst:=cCol
end;

function EnterDate:st8;
const
  date:string='';
begin
  repeat
    date:='';
    if InputBox('','Введите дату тестирования в формате ММ/ДД/ГГ',date,0,0)=
      cmCancel then Break;
  until (date[1] in ['0','1']) and (date[4] in ['0','1','2','3']) and
          (date[7]='0');
  EnterDate:=date
end;

function ExecDialog(P: PDialog; Data: Pointer): Word;
var
  Result: Word;
begin
  Result := cmCancel;
  P := PDialog(Application^.ValidView(P));
  if P <> nil then
  begin
    if Data <> nil then P^.SetData(Data^);
    Result := DeskTop^.ExecView(P);
    if (Result <> cmCancel) and (Data <> nil) then P^.GetData(Data^);
    Dispose(P, Done);
  end;
  ExecDialog := Result;
end;

function  ListDialog(cStr:PCollection;s:string;
                    var st:string;var n:integer;hlpCtx:word):word;
var
  R       : TRect;
  ListBox : PListBox;
  D       : PMyDialog;
begin
  R.Assign(17,4,63,15);
  D:=New(PMyDialog,Init(R,s));
  with D^ do
    begin
      R.Assign(1,1,44,7);
      ListBox:=New(PListBox,Init(R,1,nil));
      ListBox^.NewList(cStr);
      Insert(ListBox);
      R.Assign(4,8,14,10);
      Insert(New(PButton,Init(R,'Выбор',cmOk,bfDefault)));
      R.Assign(18,8,28,10);
      Insert(New(PButton,Init(R,'Отмена',cmCancel,bfNormal)));
      R.Assign(32,8,42,10);
      Insert(New(PButton,Init(R,'Справка',cmHelp,bfNormal)));
      SelectNext(false);
      HelpCtx:=hlpCtx;
    end;
  ListDialog:=DeskTop^.ExecView(D);
  n:=ListBox^.focused;
  st:=PString(cStr^.At(n))^;
  Dispose(D,Done);
end;

function MakeVarFileName(index:String;numvar:integer):st79;
var
  colvar   : integer;
  filename : st79;
  fch      : tfc;
  sa       : string[10];
begin
  MakeVarFileName:='';
  if numvar=0 then
    begin
      filename:='tema.'+index;
      {$I-}
      ChDir('\TEST\TEMA');
      if IOResult<>0 then
      begin
        MessageBox(#3'Не удалось перейти в каталог'+#3'VAR',nil,mfOkButton);
        Exit;
      end;
      if not OpenFile(filename,pf,0,true) then Halt;
      colvar:=ReadFour(pf);		{colvar-сколько вариантов по этой теме}
      Close(tfc(pf^));
      ChDir('\TEST');
      Randomize;
      numvar:=Random(colvar)+1;
    end;
  Str(numvar,sa);
  if Length(sa)<3 then
     case Length(sa) of
       1:sa:='00'+sa;
       2:sa:='0'+sa;
     end;
  filename:='VAR'+sa+'.'+index;
  MakeVarFileName:=filename;
end;
end.