function TEditor.SaveEditFile(bak:boolean):boolean;
begin
  SaveEditFile:=false;
  if bak then
    if not CreateBAKFile then
     if MessageBox(#3'Не удалось создать BAK-файл!'+#13+#13+#3'Продолжить?',
        nil,mfYesButton+mfNoButton)=cmNo then Exit;
 { OpenFile(filename,pf,0,false);}
  DiskReadWriteMsg('Идет запись на диск!');
  {WriteAllBlocks(0,pf);}
  Close(tfc(pf^));
end;
