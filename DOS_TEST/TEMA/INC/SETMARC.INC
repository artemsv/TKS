function TEditor.SetMarkers;                      {���⠢��� ࠧ����⥫� }
var
  k:byte;
  pDoubleChars:^TChars;
begin
  SetMarkers:=false;
  New(pDoubleChars);
  pDoubleChars^:=chars;                         {���ᨢ-�����}
  if not MaxPosition(y2) then Exit;             {������ ��� ��થ� #219}
  chars[maxY,maxX]:=sym+219;
  for k:=0 to x2 do chars[line,k]:=sym32;
  oldY:=0;
  k:=maxY;
  while Lo(chars[k,0])=32 do Dec(k);
  repeat
    if Lo(chars[k,0])<>32 then
    begin
      MaxPosition(k-1);
      if maxY=0 then                        {�᫨ �� ����祭}
      begin                                 {����⠭�������� chars}
        ClearAll;
        MessageBox(#3'����� �� ����祭!',nil,mfOkButton);
        Move(pDoubleChars^,chars,y2*(x2));
        Dispose(pDoubleChars);
        Exit;
      end;
      chars[maxY,maxX]:=sym+221;             {��થ� ���� �����}
    end;
    Dec(k);
  until k=1;
  Dispose(pDoubleChars);
  SetMarkers:=true;
end;
