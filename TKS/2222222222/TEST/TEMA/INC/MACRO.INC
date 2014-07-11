procedure TEditor.ChangeMacroKey;
var
  DD:PDialog;
  R:TRect;
  st:string;
  p:PString;
  k:integer;
begin
  if ListDialog(cMacro,'Выберите нужное макроопределение',st,k,9)=cmCancel
   then Exit;
  st:=Copy(st,12,Length(st)-10);
  repeat
    if InputBox('','Введите новое макроопределение',st,30,0)=cmCancel
     then Exit;
  until Length(st)>=1;
  p:=cmacro^.At(k);
  st:=Copy(p^,1,11)+st;
  cMacro^.AtPut(k,NewStr(st));                  {замена на новое}
  macro:=true;                                  {true-значит cMacro изменяли}
end;

procedure TEditor.ShowMacroKey;
begin
  WatchWindow(cMacro,8,4,72,14);
end;

procedure TEditor.MacroKey;
var
  k:byte;
  st:string;
begin
  cMacro:=New(PCollection,Init(27,1));
  if not Verify('macro.dat',GetCurDir) and (@Self<>ClipBoard) then
  begin
    MessageBox(#3'Не найден файл MACRO.DAT.',nil,mfOkButton);
    for k:=1 to 27 do
    cMacro^.Insert(NewStr('Нет данных!!  Нет данных!!  Нет данных!!'));
    Exit;
  end;
  if not OpenFile('macro.dat',pf,2,true) then Exit;  {?????????????}
  while not Eof(tft(pf^)) do
  begin
    Readln(tft(pf^),st);
    cMacro^.Insert(NewStr(st));
  end;
  Close(tft(pf^));
end;

function TEditor.MacroString(cod:word):boolean;
const
  ps:PString=nil;
var
  k:byte;
begin
  Macrostring:=false;
  k:=cod div 256;
  if k in macroShift then Dec(k,$55) else
  if k in macroCtrl  then Dec(k,$56) else
  if k in macroAlt   then Dec(k,$57) else Exit;
  if k > cMacro^.count-1 then
  begin
    MessageBox('Выход за границу!!!',nil,mfOkButton);
    Exit;
  end;
  ps:=cMacro^.At(k);
  k:=12;
  while k<=Length(ps^) do
  begin
    chars[y,x]:=sym+byte(ps^[k]);
    Plus;
    Inc(k);
  end;
  MacroString:=true;
end;

procedure TEditor.SaveMacro;
var
  k:byte;
  ps:PString;
begin
  if MessageBox(#3'Сохранить возможные изменения'+#13+#3'в файле MACRO.DAT?',
   nil,mfYesButton+mfNoButton)<>cmYes then Exit;
  if not OpenFile('Macro.dat',pf,2,false) then Exit;
  for k:=0 to cMacro^.count-1 do
  begin
    ps:=PString(cMacro^.At(k));
    Writeln(tft(pf^),ps^);
  end;
  Close(tft(pf^));
end;

