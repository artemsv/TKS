procedure Teditor.Compressor;
var
  k,i:byte;
  j:integer;
  position:integer;
  ch:char;
begin i:=1;position:=-1;
  repeat
    j:=-1;
    repeat
      Inc(position);
      Inc(j);
      mChar[position]:=char(Lo(chars[i,j]));
      ch:=char(Lo(chars[i,j]));
      if j=x2 then
      begin
        j:=0;
        Inc(i);
      end;
    until (ch=#221) or (ch=#219);
    if j>0 then Inc(i);
    while Lo(chars[i,0])=32 do Inc(i);
  until mChar[position]=#219;
  mChar[position+1]:=#0;
end;
