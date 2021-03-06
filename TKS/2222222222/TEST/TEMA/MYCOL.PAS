unit MyCol;                      {��� ��砫쭮� ���ᨨ     : 28.01.02}
                                 {��� �����⠫쭮� ���ᨨ : 30.01.02}

interface

uses
   Objects;


{ ��ꥪ� TCicleCollection ॠ����� 横���᪨� �⥪ � ���� �����

 start-������ ��ࢮ�� ��⠢������� ����ᥭ�
 last-������ ��᫥����� ��⠢������� ����ᥭ�
 current-������ �������,����� �� �뤠� �� �।��饬 �����

 ��᫥ ���������� �ᥣ� "�����" ��⠢�� ������� ��᫥���饣� �������
 �ந�������� � ������ �������,��⠢������� ࠭�� "��� �����������",
 � ���� � ������ start.Start �⠭������ ࠢ�� last,����� � ᢮� ��।�
 㢥��稢����� �� �������.�᫨ start ��� last ���⨣�� ���祭�� Limit(� ����
 ���ᨨ���쭮�� ���祭�� ������樨),��� �ਭ����� ���祭�� 0.�� �뤠�
 ������⮢ � �㭪�ﬨ GetNext � GetPrev �ᯮ������ ���� current,� ���஬
 �࠭���� ��᫥���� �뤠��� �������.�� �㭪樨 ��祣� �� "�����" � "�����-
 ��� ��த� �⥪� � �뤠�� ������⮢ �ந������ �������.�㭪�� GetNext ��-
 ��� �뤠�� ��������  �� current �� last,� GetPrev �� current �� start
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
  current:=-1;
end;

procedure TCicleCollection.Insert(item:pointer);
begin
  if count < limit then  {���������� "�����" ⮫쪮 ��砫���}
  begin
    if start=-1 then start:=0;    {ᠬ� ���� �������}
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
  if current=start then Exit;           {�᫨ ᠬ� ���� 㦥 �뤠����}
  if count=0 then Exit;                 {��� ������⮢}
  if current=-1 then                    {�᫨ �� �� �뤠����,��୥� }
   current:=last                        {��᫥���� ��⠢�����}
  else begin
    Dec(current);
    if current =-1 then current:=count-1;
  end;
  GetPrev:=At(current);
end;

function TCicleCollection.GetNext:pointer;
begin
  GetNext:=nil;
  if count=0 then Exit;                 {��� ������⮢}
  if current=-1 then Exit;              {����� �뤠�� ᫥���騩}
  if current=last then Exit;            {��᫥���� 㦥 �뤠����}
  Inc(current);
  if current>count-1 then current:=0;
  GetNext:=At(current);
end;

procedure TMyCicleCollection.FreeItem(Item:pointer);
begin
  Dispose(item)
end;

end.
