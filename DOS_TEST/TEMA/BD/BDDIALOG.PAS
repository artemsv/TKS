unit BdDialog;

interface

uses Types,Objects,Dialogs,Views,Validate;

type
  PEditDialog=^TEditDialog;
  TEditDialog=object(TDialog)
    constructor Init(var rec);
  end;

implementation

constructor TEditDialog.Init;
var
    R:TRect;
    P:PInputLine;
    pp:pRD;
begin
  R.Assign(10,5,60,20);
  inherited Init(R, 'Фильтр поиска');
  R.Assign(1,11,15,13);
  Insert(New(PButton, Init(R, 'Установить', cmOk, bfNormal)));
  R.Assign(15,11,28,13);
  Insert(New(PButton, Init(R, 'Отменить', cmCancel, bfNormal)));

  R.Assign(3,2,15,3);P:=New(PInputLine, Init(R, 8));
  Insert(P);
  P^.SetValidator(New(PPXPictureValidator,Init('##/##/##',true)));
  R.Assign(2,1,10,2);Insert(New(PLabel,Init(R,'Дата',P)));

  R.Assign(3,4,15,5);P:=New(PInputLine, Init(R, 12));Insert(P);
  R.Assign(2,3,8,4);Insert(New(PLabel,Init(R,'Ф.И.О.',P)));

  R.Assign(3,6,11,7);P:=New(PInputLine, Init(R, 8));Insert(P);
  R.Assign(2,5,9,6);Insert(New(PLabel,Init(R,'Группа',P)));

  R.Assign(3,8,19,9);P:=New(PInputLine, Init(R, 12));Insert(P);
  R.Assign(2,7,9,8);
  Insert(New(PLabel,Init(R,'Тема',P)));
{  SetData(rec);}
end;
end.