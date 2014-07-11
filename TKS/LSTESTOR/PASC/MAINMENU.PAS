Unit Mainmenu;

Interface

uses menutest,ramatest;

Var
w:men;
k:byte;

Procedure Clea;
Procedure Mm(var r:byte);
Procedure Mm2(var r:byte);
Procedure Mm3(var r:byte);

Implementation

Procedure Clea;

Var
b:byte;

Begin
for b:= 1 to 100 do
  w.vop[b]:='';
end;

Procedure Mm(var r:byte);

Begin
clea;
cleaall;
rama1;
w.vop[1]:='Тестирование';
w.vop[2]:='Редактирование тестов';
w.vop[3]:='Настройка редактора';
w.vop[4]:='NIL';
menu(w,r);
end;

Procedure Mm2(var r:byte);

Begin
clea;
cleaall;
rama1;
w.vop[1]:='Изменение вопроса';
w.vop[2]:='Изменение ответов';
w.vop[3]:='Изменение веса вопроса';
w.vop[4]:='Добавить новый тест';
w.vop[5]:='Удалить тест';
w.vop[6]:='NIL';
menu(w,r);
end;

Procedure Mm3(var r:byte);

Begin
clea;
cleaall;
rama1;
w.vop[1]:='Редактирование групп и фамилий учащихся';
w.vop[2]:='Изменение паролей системы';
w.vop[3]:='Изменение ставок на выставление оценки';
w.vop[4]:='Изменение параметра таймера';
w.vop[5]:='Удаление учащихся';
w.vop[6]:='Изменения файла тестирования (по умолчанию)';
w.vop[7]:='Изменение файла отчета (по умолчанию)';
w.vop[8]:='Изменение файла групп (по умолчанию)';
w.vop[9]:='Просмотр установок';
w.vop[10]:='NIL';
menu(w,r);
end;

Procedure Mm4(var r:byte);

Begin
clea;
cleaall;
rama1;
w.vop[1]:='Добавить учащегося';
w.vop[2]:='Удалить учащегося';
w.vop[3]:='NIL';
menu(w,r);
end;
end.

