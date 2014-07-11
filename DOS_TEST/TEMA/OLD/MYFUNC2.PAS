unit MyFunc2;

interface

uses App,Dialogs,MsgBoxMy,MyLib,Views,Objects,Types,MyFunc;

function SelectGruppa(var gruppa:st8;var kGruppa:integer):boolean;
function SelectTema(var tema:st12;var kTem:byte):boolean;
function EnterDate(var dat:st8):boolean;

implementation

function SelectGruppa(var gruppa:st8;var kGruppa:integer):boolean;
var
  k,kod:byte;
  ft:text;
  cCol:PCollection;
  st:string;
  n:integer;
begin
  k:=0;
  SelectGruppa:=false;
  if not OpenFile('gruppa.dat',pf,2,true) then Exit;
  cCol:=New(PCollection,Init(10,1));
  while not Eof(tft(pf^)) do
  begin
    Inc(k);
    Readln(tft(pf^),st);
    cCol^.Insert(NewStr(st));
    Readln(tft(pf^),kod);
  end;
  Close(tft(pf^));
  if ListDialog(cCol,'Выберите группу',st,n) = cmCancel then exit;
{  Dispose(cCol,Done);}
  gruppa:=st;
  kGruppa:=n+1;
  SelectGruppa:=true;
end;

function SelectTema(var tema:st12;var ktem:byte):boolean;
var
  k:integer;st:st12;
  cHead:PCollection;
  ctem:PStringCollection;
  pf:pointer;
  head:THead;
  HeadPtr:^THead;
  sst:string;
begin
  SelectTema:=false;
  cHead:=New(PCollection,Init(10,1));
  cTem:=New(PStringCollection,Init(10,1));
  if not OpenFile('\TEST\TEMA\temas.dat',pf,3,true) then Exit;
  while not Eof(tfh(pf^)) do
    begin
      Read(tfh(pf^),head);
      New(headPtr);headPtr^:=head;
      cHead^.Insert(headPtr);
      cTem^.Insert(NewStr(headPtr^.tema));
    end;
  Close(tfh(pf^));
  repeat
    if ListDialog(cTem,'Список тем',sst,k)=cmCancel then Exit;
                   {?????ПАМЯТЬ НЕ ОСВОБОЖДАЕТСЯ!!}
    for k:=0 to Pred(cHead^.count) do
    begin
      headPtr:=cHead^.At(k);
      if headPtr^.tema=sst then Break;
    end;
    kTem:=headPtr^.kTem;
    st:=headPtr^.index; st:='tema.'+headPtr^.index;
    if not Verify(st,'\TEST\TEMA') then
        MessageBox(#3'Вопросы по данной теме не обнаружены!',nil,mfOkButton);
  until Verify(st,'\TEST\TEMA');
  tema:=headPtr^.tema;
  cHead^.DeleteAll;
  Dispose(cHead,Done);
  Dispose(cTem,Done);
  SelectTema:=true;
end;

function EnterDate(var dat:st8):boolean;
var
  date:string;
begin
  EnterDate:=false;
  repeat
    dat:='';
    if InputBox('','Введите дату тестирования в формате ММ/ДД/ГГ',date,0)=
      cmCancel then Exit;
  until (date[1] in ['0','1']) and (date[4] in ['0','1','2','3']) and
          (date[7]='0');
  EnterDate:=true
end;

end.