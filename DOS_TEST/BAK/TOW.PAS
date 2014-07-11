uses M_Global,M_Dialog,Crt;{дата создания начальной версии     3.11: 25.10.01}
type tsm=string[10];
var  sm:array[1..3] of tsm;
procedure Draw;
var i,k,len:byte;code:integer;
begin
  ClrScr;
  for i:=1 to 3 do if sm[i]<>'' then
    for k:=20 downto 20-Length(sm[i]) do
    begin
      Val(sm[i][21-k],len,code);
      GotoXY(12*i-len,k);
      TextColor(len+6);
      for code:=1 to 2*len do Write(#219)
    end;
  TextColor(0);
end;

function Free(s1,s2:tsm):byte;
var k:byte;
begin
  for k:=1 to 2 do                      {овзвращает свободный штырь}
    if (sm[k]<>s1) and (sm[k]<>s2) then
    begin
      Free:=k;
      Exit
    end;
  Free:=3;
end;

function Last(var sm:tsm):char;
begin                                {возвращает верхний диск с штыря sm}
  Last:=sm[Length(sm)];              {и снимает его с sm}
  sm:=Copy(sm,1,length(sm)-1);
end;

procedure Two(var s1,s2:tsm);        {снимает два верхних диска с s1 и }
begin                                {надевает их на s2}
  sm[Free(s1,s2)]:=Last(s1);         {вызывается,если на s1 осталоь два }
  s2:=s2+Last(s1);
  s2:=s2+Last(sm[Free(s1,s2)])
end;

procedure Move(var s1,s2:tsm);
var t:tsm;b:byte;old:tsm;
begin
  if Length(s1)=2 then Two(s1,s2)
  else begin
    t:=Copy(s1,2,Length(t)-1);
    old:=s1[1];
    b:=Free(s1,s2);
    Move(t,sm[b]);
    s1:=old+t;
    s2:=Last(s1)+s2;
    Move(sm[Free(s1,s2)],s2);
  end;
end;
begin
  sm[1]:='321';  sm[2]:='';sm[3]:='';Move(sm[1],sm[2]);Draw;Readkey;end.