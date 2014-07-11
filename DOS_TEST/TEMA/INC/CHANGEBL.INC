function TEditor.ChangeBlocks;
begin
  ChangeBlocks:=false;
  if not SetMarkers then Exit;         {если не окончен или неверный формат}
  Compressor;
  cBlocks^.AtPut(numVopr,New(PBlock,Init(numVopr,StrNew(mChar))));      {замена старого на отредактир.}
  ChangeBlocks:=true;
end;
