unit MVarian2;                     {дата окончательной версии: 17.01.01}

interface

uses Dos,Crt,MRed,Drivers,MyFunc,Views,MsgBoxMy,Objects,Types,MyLib,MHelp;

type
  PVariant=^TVariant;
  TVariant=object(TEditor)
    nQ:integer;                           {количество вопросов в варианте}
    nV:integer;                           {количество вариантов}
    mismach:boolean;                      {true-в варианте случайные вопросы}
    oneTema:boolean;                      {true-варианты однотемные}
    cBaseBlocks:PCollection;              {коллекция с блоками из баз. файла}
    ntem:integer;                         {количество тем в варианте}
    total,summa:integer;
    constructor Init;
  end;

implementation

constructor TVariant.Init;
const
  mCBlocks:array[1..10] of PCollection=
        (nil,nil,nil,nil,nil,nil,nil,nil,nil,nil);
var
  mHeader:array[1..10] of THeader;      {массив заголовков тем в варианте}
  k,i:byte;
  numVar:byte;
  mas:array[0..20] of integer;          {массив случайных номеров вопросов}
  p:PChar;
  newIndex:string;                      {новое расширение сборной темы}
begin
  mismach:=true;
  if InputInt(1,maxVoprsInVar,'количество вопросов в варианте',nQ,hcVarNq)=
      cmCancel then  Exit;
  if InputInt(1,maxTemInVar,'количество тем в варианте',ntem,hcVarNTem)=
      cmCancel then Exit;
  total:=0;summa:=0;
  for k:=1 to nTem do
  begin
    if SelectTema(mHeader[k])=cmCancel then Fail;
    total:=total+summa;
    repeat
      if InputInt(1,nQ-total,'количество вопросов по теме '+
        mHeader[k].tema,summa,hcVarSumma)=cmCancel then exit;
    until nQ-total>=ntem-k;
    mHeader[k].colv:=summa;
  end;
  if nTem=1 then
  begin
    newIndex:=mHeader[1].index;
    w:=MessageBox(#3'Вопросы перемешивать?',nil,mfYesNoCancel);
    if w=cmCancel then Exit;
    mismach:=w=cmYes;
    if not mismach then
    begin
      nV:=mHeader[1].nn div nQ;
      k:=mHeader[1].nn mod nQ;
      if k<>0 then
      begin
        MessageBox(#3'Количество вопросов('+Sstr(mHeader[1].nn)+
          ')  по этой теме не делится нацело на требуемое число вопросов('+
          Sstr(nQ)+')',nil,mfOkButton);
        Exit;
      end else
      if MessageBox(#3+'Получится '+Sstr(nV)+' вариант(a,ов)'+#13+#13+
      #3'Устраивает?',nil,mfYesButton+mfNoButton)=cmNo then Exit;
    end else
      if InputInt(1,maxVarInTema,'требуемое количество вариантов',nV,hcVarNv)
          =cmCancel then Exit;
  end else
  begin
    if InputInt(1,maxVarInTema,'требуемое количество вариантов',nV,hcVarNv)=
      cmCancel then Exit;
    if Inputbox('','Введите новое расширение',newIndex,hcVarNewIndex,0)=
      cmCancel then Exit;
  end;
  for k:=1 to nTem do
  begin
    filename:=mHeader[k].fName;                    {базовый файл темы}
    if not LoadEditFile(mCBlocks[k]) then
    begin
      Dispose(cBlocks,Done);
      Fail
    end;
  end;
  lines:=mCBlocks[1]^.At(0);                     {получаем заголовок темы}
  Four(0,nV,mChar);Four(4,nQ,mChar);Four(8,nQ,mChar);
  for k:=0 to 11 do lines[k]:=mChar[k];      {изменяем lines(т.е. заголовок}
  cBlocks^.AtPut(0,lines);                   {вставляем измененный заголовок}
  p:=lines;                                  {p-указатель на заголовок}
  {$I-}                                      {переходим в каталог VAR}
  ChDir('\TEST\VAR');
  if IOResult<>0 then
  begin
    MessageBox(#3'Каталог VAR не найден!',nil,mfOkButton);
    cBlocks^.DeleteAll;
    Dispose(cBlocks,Done);
    Exit
  end;
  cBlocks:=New(PCollection,Init(50,5));
                                        {цикл записи на диск одного варианта}
  for numVar:=1 to nV do
  begin
    filename:=MakeVarFileName(newIndex,numVar);       {сляпали имя файла}
    cBlocks^.Insert(p);                               {вставили заголовок}
    for k:=1 to nTem do
    begin
      if mismach                                      {случайные вопросы}
        then Duplet(mHeader[k].nn,mHeader[k].colv,mas)
                                                      {по порядку}
        else for k:=1 to mHeader[k].colv do mas[k]:=k+(numVar-1)*nQ;
      for i:=1 to mHeader[k].colv do    {заполняем случайными блоками}
        cBlocks^.Insert(mCBlocks[k]^.At(mas[i]));
    end;
    SaveEditFile(false);
    cBlocks^.DeleteAll;
  end;
  Sound(1000);
  MessageBox(#3'Cоставлено: '+Sstr(nV)+' вариантов.',nil,mfOkButton);
  Nosound;
  ChDir('\TEST\TEMA');
  filename:='tema.'+header.index;
  if not OpenFile(filename,pf,0,true) then
  begin
    MessageBox(#3'Безобразие!!!',nil,mfOkButton);
    Exit;                                               {??????????}
  end;
  Four(0,nV,mChar);         {запис.в базовый файл кол-во составл.вариантов}
  for k:=0 to 3 do Write(tfc(pf^),mChar[k]);
  Close(tfc(pf^));
end;
end.
