var
ff,f:text;
st:string;
k:word;
begin
assign(f,'z.pas');
reset(f);
assign(ff,'s');
rewrite(ff);
while not Eof(f) do
begin
  Readln(f,st);
 if st='' then continue;
  if (st[1]='f') or (st[1]='p') then writeln(ff,st);
  if st='implementation' then Break;
end;
close(ff);
close(f);

end.