function TEditor.ChangeBlocks;
begin
  ChangeBlocks:=false;
  if not SetMarkers then Exit;         {�᫨ �� ����祭 ��� ������ �ଠ�}
  Compressor;
  cBlocks^.AtPut(numVopr,New(PBlock,Init(numVopr,StrNew(mChar))));      {������ ��ண� �� ��।����.}
  ChangeBlocks:=true;
end;
