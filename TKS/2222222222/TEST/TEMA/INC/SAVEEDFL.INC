function TEditor.SaveEditFile(bak:boolean):boolean;
begin
  SaveEditFile:=false;
  if bak then
    if not CreateBAKFile then
     if MessageBox(#3'�� 㤠���� ᮧ���� BAK-䠩�!'+#13+#13+#3'�த������?',
        nil,mfYesButton+mfNoButton)=cmNo then Exit;
 { OpenFile(filename,pf,0,false);}
  DiskReadWriteMsg('���� ������ �� ���!');
  {WriteAllBlocks(0,pf);}
  Close(tfc(pf^));
end;
