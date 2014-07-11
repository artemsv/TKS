unit MyCol;                      {дата начальной версии     : 28.01.02}
                                 {дата окончатальной версии : 28.01.02}

interface

uses
   Objects;


{ Объект TCicleCollection реализует циклический стек в виде кольца

   start-индекс первого вставленного элемсента;
   last-индекс последнего вставленного элемсента;

  После заполнения всего "кольца" вставка каждого последующего элемента
  производится в позицию элемента,вставленного раньше "всех присутствующих",
  то есть в позицию start.Start становится равным last,который в свою очередь
  увеличивается на еденицу.Если start или last достигли значения Limit(то есть
  максиимального значения коллекции),они принимают значение 0.При выдаче
  элементов с функциями GetNext и GetPrev используется поле current,в котором
  хранится последний выданный элемент.Эти функции ничего не "знают" о "кольце-
  вой природе стека и выдачу элементов производят линейно.Функция GetNext может
  выдать элементы  от current+1 до last,а GetPrev от current до start
}

type
  PCicleCollection=^TCicleCollection;
  TCicleCollection=object(TCollection)
    start:integer;
    last:integer;
    current:integer;
    constructor Init(ALimit,ADelta:integer);
    procedure Insert(Item:pointer);virtual;
    function GetPrev:pointer;
    function GetNext:pointer;
  end;

  PMyCicleCollection=^TMyCicleCollection;
  TMyCicleCollection=object(TCicleCollection)
    procedure FreeItem(item:pointer);virtual;
  end;

implementation

constructor TCicleCollection.Init(ALimit,ADelta:integer);
begin
  inherited Init(ALimit,ADelta);
  start:=-1;
  last:=-1;
  current:=-1
end;

procedure TCicleCollection.Insert(item:pointer);
begin
  if count < limit then  {заполнение "кольца" только началось}
  begin
    if start=-1 then start:=0;    {самый первый элемент}
    if last=-1 then last:=0
      else Inc(last);
    inherited Insert(item)
  end
  else
  begin
    Inc(last);
    if last>limit-1 then last:=0;
    AtFree(start);
    AtInsert(start,item);
    Inc(start);
    if start>limit-1 then start:=0;
  end;
end;

function TCicleCollection.GetPrev:pointer;
begin
  GetPrev:=nil;
  if count=0 then Exit;                 {нет элементов}
  if current=-1 then                    {первое обращение к функции}
  begin
    current:=start;                     {т.к. выдачи не было,выдается}
    GetPrev:=At(current);               {самый "старый" элемент}
    Exit
  end;
  if current=start then Exit;           {самый "старый" уже выдавали}
  Dec(current);
  if current=-1 then current:=count-1;
  GetPrev:=At(current)
end;

function TCicleCollection.GetNext:pointer;
begin
  GetNext:=nil;
  if count=0 then Exit;                 {нет элементов}
  if current=-1 then                    {первое обращение к функции}
  begin
    current:=start;
    GetNext:=At(current);
    Exit
  end;
  if current=last then Exit;            {самый "свежий" уже выдавали}
  Inc(current);
  if current>count-1 then current:=0;
  GetNext:=At(current)
end;

procedure TMyCicleCollection.FreeItem(Item:pointer);
begin
  Dispose(item)
end;

end.
