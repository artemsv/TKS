uses Dos,Crt;

var
  scan:byte;
  k:longint;
  oldint09h:pointer;
  s:real;

{$F+}
procedure IntProc;interrupt;
begin
  scan:=Port[60];
  inline($FF/$1E/>oldInt09H)
end;

{$F-}
begin
    GetIntVec($09,oldInt09H);
    SetIntVec($09,@IntProc);
      writeln('qqqqqqqqqq');
      Readkey;
end.
