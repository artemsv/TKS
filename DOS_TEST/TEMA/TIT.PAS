function  Titul(var header:THeader):word;
const
  st:string='';
  mmm:byte=0;
  mLin : set of byte=[];
var
  R      : TRect;
  h      : THead;
  code,dd: integer;
begin
  Titul:=cmCancel;
  repeat
    if InputBox('','Введите новую тему',st,12,0)=cmCancel then Exit;
  until st<>'';
  header.tema:=st;st:='';
  repeat
    if InputBox('','Введите расширение',st,3,0)=cmCancel then Exit;
    header.index:=st;
    st:='tema.'+st;
    if Verify(st,GetCurDir) then MessageBox(#3'Данное расширение'+#13+#13+
            #3'уже зарезервировано!',nil,mfOkButton);
  until not Verify(st,GetCurDir) or (length(st)=3);
  header.fName:=st;
  if InputInt(10,maxTime,'время,отводящееся на один вопрос',header.tim,0)=
    cmCancel then Exit;;
  if InputInt(1,maxVoprsInTema,'количество вопросов',header.ckolko,0)=
    cmCancel then Exit;;
  if InputInt(1,maxWrongAnswer,'количество неправильных ответов',dd,0)=
    cmCancel then Exit;;
  st:='';
  if not OpenFile('temas.dat',pf,3,true) then Exit;
  while not Eof(tfh(pf^)) do
  begin                                   {заполнили множество кодами тем}
    Inc(mmm);
    Read(tfh(pf^),h);
    Include (mLin,h.ktem);
  end;
  repeat                        {проверка на оригинальность нового кода}
    if InputBox('','Введите код темы',st,3,0)=cmCancel then Exit;
    Val(st,mmm,code);
    if mmm in mLin then MessageBox(#3'Этот код зарезервирован!',
      nil,mfOkButton) else if code=0 then Break
  until false;
  {ВНИМАНИЕ!!! 04.12.01 обнаружилось странное явление:указатель pf портился и
      при вызове InputInt (файл tfh(pf^) превращался в закрытый!!!}
  with header do
  begin
    d:=mmm*100+dd;                     {уплотнение header.d}
    j3:=55;j4:=70;j5:=85;nn:=0;colv:=0;
  end;
  h.kTem:=mmm;
  header.kTem:=mmm;
  h.tema:=header.tema;
  h.index:=header.index;
  Seek(tfh(pf^),FileSize(tfh(pf^)));
  Write(tfh(pf^),h);
  Close(tfh(pf^));
  WriteHeader(header);                 {количество непр.ответов-младший}
  header.d:=dd;                        {разуплотнение поля header.d}
  Titul:=cmOk;
end;
