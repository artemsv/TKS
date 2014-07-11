procedure TEdit3.ShowChars;
var
  position:integer;
  k:byte;
  atribut:word;
  ch:char;
  ifFirst:boolean;
  BL:PBlock;
begin
  CleanChars;
  invite:=inv+GetStr(27,' ')+'Вопрос № '+Sstr(numVopr);
  WriteInvite;
  if numVopr>cBlocks^.count-1 then Exit;          {аварийный выход}
  BL:=PBlock(cBlocks^.At(numVopr));
  lines:=BL^.block;
  x:=0;y:=1;ch:=lines[0];
  position:=0;ifFirst:=true;
  repeat
    if ch=#221 then begin
      if x>0 then Inc(y);
      x:=0;
      if ifFirst then begin
        for k:=0 to x2 do chars[y,k]:=syl+196;
        ifFirst:=false;
        line:=y;
        Inc(y);
      end;
    end else begin
      if x<oldX then atribut:=syn else atribut:=sym;
      k:=byte(ch);
      chars[y,x]:=atribut+k;
      Inc(x);
      if x>endX then begin
        x:=0;
        Inc(y);
      end;
      if y>y2 then Break;
    end;
    Inc(position);
    ch:=lines[position];
  until ch=#219;
end;
