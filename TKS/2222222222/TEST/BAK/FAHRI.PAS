program matrf;
uses crt;
CONST
  dim=10; dim3=3*dim;{N=1;}
TYPE
  MAT3=ARRAY[1..dim,1..dim] OF REAL;
  MAT9=ARRAY[1..dim3,1..dim3] OF REAL;
VAR
  n,i,j:INTEGER;
  BB11,BB12,BB13,BB21,BB22,BB23,BB31,BB32,BB33:MAT3;
  BB:MAT9;
{**********************************************************}
PROCEDURE FORMBBB(NN{SKM}:INTEGER;B11,B12,B13,B21,B22,B23,B31,
                  B32,B33:MAT3; VAR B:MAT9);
VAR
  I,J,I2,J2,I3,J3:INTEGER;
BEGIN
  FILLCHAR(B,SIZEOF(B),0);
  FOR I:=1 TO NN DO begin
  FOR j:=1 TO NN DO begin
  I2:=TRUNC(NN+I); I3:=TRUNC(2*NN+I);
  J2:=TRUNC(NN+J); J3:=TRUNC(2*NN+J);
  B[I,J]:=B11[I,J]; B[I,J2{N+J}]:=B12[I,J];
  B[I,J3{2*N+J}]:=B13[I,J];
  B[I2{N+I},J]:=B21[I,J]; B[I2{N+I},J2{N+J}]:=B22[I,J];
  B[I2{N+I},J3{2*N+J}]:=B23[I,J];
  B[I3{2*N+I},J]:=B31[I,J]; B[I3{2*N+I},J2{N+J}]:=B32[I,J];
  B[I3{2*N+I},J3{2*N+J}]:=B33[I,J]; end; end;
END;{FORNBBB}
PROCEDURE VVODBB(NN:INTEGER;var B:MAT3);
VAR
  I,J:INTEGER;
BEGIN
  writeln;
  for i:=1 to nn do
  for j:=1 to nn do begin
  WRITE('b[',i,',',j,']=');
  read(b[i,j]); end;
END;{VVODBB}
PROCEDURE PECHBB(NN:INTEGER;B:MAT3);
VAR
  I,J:INTEGER;
BEGIN
  for i:=1 to nn do begin writeln;
  for j:=1 to nn do begin
  WRITE(' b[',i,',',j,']=',B[I,J]:8:4);end;end;
END;{PECHBB}


{**********************************************************}
BEGIN
ClrScr;
 n:=2;
FILLCHAR(BB11,SIZEOF(BB11),0);BB12:=BB11;BB13:=BB11;
BB21:=BB11;BB22:=BB11;BB23:=BB11;
BB31:=BB11;BB32:=BB11;BB33:=BB11;
FILLCHAR(BB,SIZEOF(BB),0);
(*VVODBB(N:INTEGER;B:MAT3);*)
(*PECHBB(N:INTEGER;B:MAT3);*)
WRITELN('BB11'); VVODBB(N,BB11); PECHBB(N,BB11); READLN;
WRITELN('BB12'); VVODBB(N,BB12); PECHBB(N,BB12); READLN;
WRITELN('BB13'); VVODBB(N,BB13); PECHBB(N,BB13); READLN;
WRITELN('BB21'); VVODBB(N,BB21); PECHBB(N,BB21); READLN;
WRITELN('BB22'); VVODBB(N,BB22); PECHBB(N,BB22); READLN;
WRITELN('BB23'); VVODBB(N,BB23); PECHBB(N,BB23); READLN;
WRITELN('BB31'); VVODBB(N,BB31); PECHBB(N,BB31); READLN;
WRITELN('BB32'); VVODBB(N,BB32); PECHBB(N,BB32); READLN;
WRITELN('BB33'); VVODBB(N,BB33); PECHBB(N,BB33); READLN;
(*FORMBBB(N{SKM}:INTEGER;B11,B12,B13,B21,B22,B23,B31,
                  B32,B33:MAT3; VAR B:MAT9);*)
FORMBBB(N{SKM},BB11,BB12,BB13,BB21,BB22,BB23,BB31,
        BB32,BB33,BB);
  for i:=1 to 3*n do begin writeln;
  for j:=1 to 3*n do begin
  WRITE(' B',i,j,'=',BB[I,J]:8:4);end; end; readln;
  WRITELN(' OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK OK ');
   READLN;
END.




