unit MVariant;

interface

uses Dos,Crt,MRed,Drivers,MyFunc,Views,MsgBoxMy,Objects,Types,MyLib;

type
  PVariant=^TVariant;
  TVariant=object(TEditor)
    nQ:integer;                           {количество вопросов в варианте}
    nV:integer;                           {количество вариантов}
    mismach:boolean;                      {true-в варианте случайные вопросы}
    oneTema:boolean;                      {true-варианты однотемные}
    cBaseBlocks:PCollection;              {коллекция с блоками из баз. файла}
    constructor Init;
  end;

implementation

constructor TVariant.Init;
var
  a:word;
  k:byte;
  numVar:byte;
  mas:array[0..20]of integer;
  p:PChar;
begin
  a:=MessageBox(#3'Вопросы перемешивать?',nil,mfYesNoCancel);
  mismach:=a=cmYes;
  if a=cmCancel then Exit
  else if mismach then
  if InputInt(1,100,'требуемое количество вариантов',nV)=cmCancel then Exit;
  if InputInt(1,20,'количество вопросов в варианте',nQ)=cmCancel then  Exit;
  a:=MessageBox(#3'Вопросы в варианте однотемные?',nil,mfYesNoCancel);
  if a=cmCancel then Exit else oneTema:=a=cmYes;
  if SelectTema(header)=cmCancel then Exit;
  if not mismach then
    begin
      k:=header.nn div nQ;
      nV:=k;
      if MessageBox(#3+'Получится '+Sstr(k)+' вариант(a,ов)'+#13+#13+
      #3'Устраивает?',nil,mfYesButton+mfNoButton)=cmNo then Exit;
    end;
  filename:=header.fName;                    {базовый файл темы}
  if not LoadEditFile then
  begin
    Dispose(cBlocks,Done);
    Fail
  end;
  cBaseBlocks:=New(PCollection,Init(50,5));
  lines:=cblocks^.At(0);                     {получаем заголовок темы}
  Four(0,nV,mChar);Four(4,nQ,mChar);Four(8,nQ,mChar);
  for k:=0 to 11 do lines[k]:=mChar[k];      {изменяем lines(т.е. заголовок}
  cBlocks^.AtPut(0,lines);                   {вставляем измененный заголовок}
  for k:=0 to cBlocks^.count-1 do            {создаем коллекцию-дубликат}
    begin
      p:=cBlocks^.At(k);
      cBaseBlocks^.Insert(p);
    end;
  p:=lines;                                  {p-указатель на заголовок}
  cBlocks^.DeleteAll;                        {обнуляем рабочую коллекцию}

  {$I-}                                      {переходим в каталог VAR}
  ChDir('\TEST\VAR');
  if IOResult<>0 then
  begin
    MessageBox(#3'Каталог VAR не найден!',nil,mfOkButton);
    cBlocks^.DeleteAll;
    Dispose(cBlocks,Done);
    Exit
  end;
                                        {цикл записи на диск одного варианта}
  for numVar:=1 to nV do
    begin
      filename:=MakeVarFileName(header.index,numVar);
      if mismach
        then Duplet(header.nn,nQ,mas)                    {случайные вопросы}
        else for k:=1 to nQ do mas[k]:=k+(numVar-1)*nQ;  {по порядку}
      cBlocks^.Insert(p);                                {вставили заголовок}
      for k:=1 to nQ do                       {заполняем случайными блоками}
          cBlocks^.Insert(cBaseBlocks^.At(mas[k]));
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