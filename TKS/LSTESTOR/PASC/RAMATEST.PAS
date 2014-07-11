Unit Ramatest;

Interface

Procedure Rama1;
Procedure Rama2;
Procedure Cleaall;

Implementation

Uses dos,crt;

Var
c:integer;

Procedure Rama2;

Var
x1,x2,k:integer;

Begin
window(2,2,78,7);
textbackground(7);
textcolor(0);
for k:=1 to 77 do
   begin
     gotoxy(k,6);
     write('Í');
   end;
textbackground(7);
window(2,2,78,5);
clrscr;
End;

Procedure rama1;

Begin
clrscr;
textbackground(7);
clrscr;
textcolor(0);
gotoxy(1,1);
write('É');
for c:= 1 to 78 do
  write('Í');
write('»');
for c:=2 to 24 do
  begin
    gotoxy(1,c);
    write('º');
    gotoxy(80,c);
    write('º');
  end;
write('È');
for c:=1 to 64 do
  write('Í');
  write('Test processor');
window(3,2,78,24);
end;

Procedure Cleaall;
Begin
window(1,1,80,25);
textcolor(7);
clrscr;
end;
end.