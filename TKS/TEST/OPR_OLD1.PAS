PROGRAM Opros;
USES Graph,Dos,Crt;
CONST up=100;y1=2;y2=23;x1=1;x2=77;
TYPE
  tmint=ARRAY[1..30] OF INTEGER;
  tsm=array[1..10] of string;
  tpsm=ARRAY[1..up]OF ^STRING;
  tm2=ARRAY[1..25,1..80]OF CHAR;
  tp2=^tm2;
  tpm2=ARRAY[1..up] OF tp2;
  tfch=FILE OF char;
  st7=STRING[7];
  st8=STRING[8];
  st12=STRING[12];
CONST
   cfst=1;         {�⠭����� 梥� 䮭�}
   cvst=14;        {�⠭����� 梥� ᨬ�����}
   cf1=47;         {梥� ������.����}
   cf2=2; {梥� ��⨢��� ������}
  nums=['0','1','2','3','4','5','6','7','8','9'];
VAR
  catalog:STRING;
  yes:boolean;
  fst:text;
  sa:STRING;
  fch:tfch;
  filename:st12;
  colv,nn,ckolko,tim,j5,j4,j3,d:integer;
  tema:STRING;
PROCEDURE Picture(VAR ch:char);
CONST
  h=160;s=25;w=80;d=40;x=80;y=120;t=15;z=TopOn;
VAR
  gd,gm,i,j:integer;
BEGIN
  gd:=detect;
  InitGraph(GD,GM,'');

  bar3d(x,y,x+w,y+s,t,z);
  bar3d(x+(w-s)DIV 2,y+s,x+(w+s)DIV 2,y+h,t,z);

  bar3d(x+w+d,y,x+2*w+d,y+s,t,z);
  bar3d(x+w+d,y+s,x+w+d+s,y+(h-s)DIV 2,t,z);
  bar(x+w+d,y+(h-s)DIV 2,x+w+d+s,y+(h+s)DIV 2);
  bar3d(x+w+d+s,y+(h-s)DIV 2,x+2*w+d-s,y+(h+s)DIV 2,t,z);
  bar3d(x+w+d,y+(h+s)DIV 2,x+w+d+s,y+h-s,t,z);
  bar(x+w+d,y+h-s,x+w+d+s,y+h);
  bar3d(x+w+d+s,y+h-s,x+2*w+d,y+h,t,z);

  bar3d(x+2*w+2*d,y,x+3*w+2*d,y+s,t,z);
  bar3d(x+2*w+2*d,y+s,x+2*w+2*d+s,y+h-s,t,z);
  bar3d(x+2*w+2*d+s,y+h-s,x+3*w+2*d,y+h,t,z);
  bar(x+2*w+2*d,y+h-s,x+2*w+2*d+s,y+h);

  bar3d(x+3*(w+d),y,x+3*(w+d)+w,y+s,t,z);
  bar3d(x+3*(w+d)+(w-s)DIV 2,y+s,x+3*(w+d)+(w+s)DIV 2,y+h,t,z);

  SetWriteMode(0);
  SetFillStyle(1,3);
  FloodFill(x+3,y+3,0);
  FloodFill(x+w+d+2,y+2,0);
  FloodFill(x+2*w+2*d+2,y+2,0);
  FloodFill(x+3*(w+d)+2,y+2,0);
  j:=62;
REPEAT
  FOR i:=63 DOWNTO 10 DO
   BEGIN
    SetRGBPalette(3,78,i,8*j-1);
    SetRGBPalette(5,73-i,73-i,63-8*j);
    IF KeyPressed THEN BEGIN
                         ch:=ReadKey;
                         IF ch=#0 THEN IF ReadKey=#68 THEN Halt;
                         IF (ch=#10) OR (ch=#27) THEN BEGIN
                                                        CloseGraph;
                                                        Exit;END;
                       END;

    Delay(105)
  END;
FOR i:=10 TO 63 DO
  BEGIN
    SetRGBPalette(3,78,i,8*j-1);
    SetRGBPalette(5,73-i,73-i,63-8*j);
    IF KeyPressed THEN BEGIN
                         ch:=ReadKey;
                         IF ch=#0 THEN IF ReadKey=#68 THEN Halt;
                         IF (ch=#10) OR (ch=#27) THEN BEGIN
                                                        CloseGraph;
                                                        Exit;END;
                       END;
    Delay(105)
  END;
UNTIL KeyPressed;
CloseGraph;
END;
{--------------------------------Show-------------------------------------}
PROCEDURE Show(p2:tp2);
VAR I,J:BYTE;
BEGIN
  CLRSCR;
  Gotoxy(1,2);
  FOR I:=1 TO 22 DO
    FOR J:=1 TO x2+1 DO BEGIN
                        Gotoxy(J,I);
                        IF p2^[i,j]<>#221 THEN Write(p2^[I,J]);
                        IF p2^[i,j]=#219  THEN Exit;
                      END;
END;

{--------------------ClearBuf-------------------���⪠ ����-------------}
PROCEDURE ClearBuf;
VAR ch:char;
BEGIN
  WHILE KeyPressed DO
     ch:=ReadKey
END;

{--------------Where-------------�����頥� ���न���� �����-----------}
PROCEDURE Where(VAR Y,X:byte);
BEGIN
  Y:=WHEREY;X:=WHEREX;
END;


{---------------------------------Sleep----------------------------------}
PROCEDURE Sleep;
VAR ch:char;
BEGIN REPEAT ch:=ReadKey UNTIL ch=#27;END;
{----------------------------Verify----------------------------------------}
FUNCTION Verify(FileName:st12):boolean;
BEGIN
  IF FSearch(FileName,'tEST')='' THEN Verify:=False
                                 ELSE Verify:=True;
END;

{--------------------------------Cls--------------------------------------}
PROCEDURE Cls;
BEGIN
  Window(2,2,78,24);  TextBackGround(cfst);TextColor(cvst);Clrscr;
END;
{--------------------------------Control---------------------------------}
PROCEDURE Control(limit:integer;VAR chislo:integer);
VAR
  st:STRING[7];
  code:integer;
  x,y:byte;
BEGIN
  Where(x,y);
  WHILE true DO
    BEGIN
      Readln(st);
      IF st='0' THEN Halt;
      Val(st,chislo,code);
      IF (code=0) AND (chislo>=1) AND (chislo<=limit) THEN Break
      ELSE BEGIN Gotoxy(X,Y);Clreol;END;
    END;
END;
{----------------------------ControlST-------------------------------------
         ������ ��ப� ������ �� min �� max,�᫨ min = max,⮣�� �����
                       䨪�஢�����,� ࠢ�� max}
PROCEDURE ControlST(min,max:byte;VAR st:STRING);
VAR
  mst:ARRAY[1..30] OF char;
  k,m:byte;
  ch:char;
BEGIN
  IF min=max THEN min:=max-1;                   {����� 䨪�஢�����}
  FOR k:=Low(mst) TO High(mst) DO mst[k]:=#0;    {����塞 �஬����.���ᨢ}
  m:=1;
  REPEAT
    REPEAT
      ClearBuf;
      ch:=ReadKey;
      IF ch=#8 THEN IF m>=1 THEN BEGIN
                                  Clrscr;
                                  Dec(m);
                                  mst[m]:=#0;
                                  FOR k:=1 TO m-1 DO Write(mst[k]);
                                END;
    UNTIL (ch=#13) OR (ch<>#0);
    IF (Ord(ch)>=32) AND (m<=max) THEN
                                    BEGIN
                                      Write(ch);
                                      mst[m]:=ch;
                                      Inc(m);
                                    END;
  UNTIL (ch=#13)and(m>min) and (m<max);
  k:=1;
  WHILE mst[k]<>#0 DO BEGIN                     {�८�ࠧ.���ᨢ� � ��ப�}
                        ch:=mst[k];
                        st:=ConCat(st,ch);
                        Inc(k)
                      END;
  st:=Copy(st,1,k-1);                           {��१��� ��ப�}
END;

{-------------------------------Box-----------------------------------------}
PROCEDURE Box(a1,b1,a2,b2:byte;fon,cvet:integer;
              bool:boolean;boool:boolean);
VAR i,j:byte;
BEGIN
  IF bool THEN Clrscr;
  TextBackGround(fon);
  TextColor(cvet);
  IF b2=25 THEN                                {�᫨ ࠬ�� �� ���� ��࠭}
    BEGIN
      Gotoxy(a1,b1);Write(#201); {218}         {����-����}
      Gotoxy(a2,b1);Write(#187); {191}         {�ࠢ�-����}
      Gotoxy(a1,b2-1);Write(#200); {192}       {����-����}
      Gotoxy(a2,b2-1);Write(#188); {217}       {�ࠢ�-���}
      Gotoxy(a1+1,b2-1);
      FOR i:=a1+1 TO a2-1 DO Write(#205);      {���}
      Gotoxy(a1+4,b2-3);
      Insline;
      Gotoxy(a1+1,b1);
      FOR i:=a1+1 TO a2-1 DO Write(#205);      {#196}
      Gotoxy(a1+1,b2);
      FOR i:=b1+1 TO b2-1 DO BEGIN Gotoxy(a1,i);Write(#186)END;  {#179}
      FOR i:=b1+1 TO b2-1 DO BEGIN Gotoxy(a2,i);Write(#186)END;
    END
  ELSE BEGIN
         Gotoxy(a1+1,b1);
         FOR i:=a1+1 TO a2-1 DO Write(#205);   {#196}
         Gotoxy(a1+1,b2);
         FOR i:=a1+1 TO a2-1 DO Write(#205);
         FOR i:=b1+1 TO b2-1 DO BEGIN Gotoxy(a1,i);Write(#186);END; {#179}
         FOR i:=b1+1 TO b2-1 DO BEGIN Gotoxy(a2,i);Write(#186);END;
         Gotoxy(a1,b1);Write(#201);            {218}
         Gotoxy(a2,b1);Write(#187);            {191}
         Gotoxy(a2,b2);Write(#188);            {217}
         Gotoxy(a1,b2);Write(#200);            {192}
      END;
      IF boool THEN BEGIN
                  Window(A1+1,B1+1,A2-1,B2-1);
                  TextBackGround(FON);CLRSCR;
                END;
  TextColor(7);
END;

{--------------------------ReadFour-------------------------------------}
FUNCTION ReadFour:integer;
VAR
  num,i:integer;
  ch:char;
  st:STRING;
BEGIN
  st:='';
  FOR i:=0 TO 3 DO
    BEGIN
      Read(fch,ch);
      st:=ConCat(st,ch)
    END;
  VAL(ST,num,i);
  ReadFour:=num
END;
{----------------------ReadTitul-����㦠�� ���   --------------------}
PROCEDURE ReadTitul(VAR olvar,nn,ckolko,tim,j5,j4,j3,d:integer;tema:STRING);
VAR ch:char;
BEGIN
    colv:=ReadFour;
    nn:=ReadFour;
    ckolko:=ReadFour;
    tim:=ReadFour;
    J5:=ReadFour;
    J4:=ReadFour;
    J3:=ReadFour;
    d:=ReadFour;
    tema:='';
    WHILE NOT Eof(fch) DO
      BEGIN
        Read(fch,ch);
        IF(ch=#219) OR (ch=#221) THEN Break
                                 ELSE tema:=Concat(tema,ch);
      END;
END;
{------------------------------Clean2m-----------------------------------}
PROCEDURE Clean2m(VAR p:tpm2);
VAR k:integer;
BEGIN FOR k:=Low(p) TO High(p) DO p[k]:=NIL END;

{-------------------------------Clean2--------------------------------------}
PROCEDURE Clean2(VAR P:tp2);
VAR i,j:BYTE;
BEGIN
  FOR i:=y2 DOWNTO y1-1 DO
    FOR j:=x2+1 DOWNTO x1 DO
      P^[i,j]:=#32
END;
{----------------------------Ignored-----------------------------------}
PROCEDURE Ignored(st:STRING);
VAR a1,a2:byte;
BEGIN
  a1:=(78-Length(st))DIV 2-2;
  a2:=a1+5+Length(st);
  Window(2,2,79,24);
  Box(a1,8,a2,12,red,15,false,false);TextColor(15);
  Gotoxy(a1+(a2-a1)DIV 2-6,8);Write(' ����������! ');
  Gotoxy(a1+(a2-a1)DIV 2-4,12);Write(' [�⬥��] ');
  Window(a1+2,10,a1+5+Length(st),12);Clrscr;
  Gotoxy(3,2);Write(st);Gotoxy(Wherex-Length(st),Wherey);
  TextBackGround(1);TextColor(14);
  Sleep;Cls;
END;
{--------------------------------Fill-----------------------------------}
PROCEDURE Fill(VAR pm2:tpm2);                  {�������� ���ᨢ 㪠�. pm2}
VAR					       {������� �� �����.䠩��}
  i,j,count,k:BYTE;
  ch:CHAR;
  p2:tp2;
BEGIN
  Clean2m(pm2);
  New(p2);                                     {�஬������ ���ᨢ}
  j:=1;k:=1;
  WHILE NOT EOF(fch) DO
    BEGIN
      i:=1;
      count:=0;                                     {���稪 ����� � �����}
      Clean2(p2);                                {���⪠ �஬��.���ᨢ�}
      FOR j:=1 TO 4 DO READ(fch,p2^[i,j]);       {��⠫� ����� � 1-� ���}
      i:=2;j:=1;
      WHILE NOT EOF(fch) DO
        BEGIN
          READ(fch,ch);
          p2^[i,j]:=ch;                        {����ᠫ� ᨬ��� � ���ᨢ}
          IF ch=#219 THEN Break;	       {�᫨ ��થ�-����� �����}
          IF ch=#221 THEN                         {�᫨ ���� ࠧ����⥫�}
                       BEGIN
                         IF count =0 THEN BEGIN   {�᫨ �� �����}
                                            Inc(i);
                                            FOR j:=1 TO 78 DO p2^[i,j]:=#196;
                                            j:=0;Inc(i);
                                          END
                                     ELSE BEGIN j:=0;Inc(i);END;
                         Inc(count);
                       END;
          Inc(j);

          IF j=78 THEN IF count=0 THEN BEGIN j:=1;Inc(i);END;	{�᫨ �����}
          IF j=80 THEN IF count>0 THEN BEGIN j:=3;Inc(i);END;   {�᫨ �⢥�}
        END;
      NEW(pm2[k]);pm2[k]^:=p2^;Inc(k);           {����ᠫ� ������ � ����.}
      IF MaxAvail<4000 THEN BEGIN Ignored('�� 墠⠥� �����!');Exit;END;
  END;                                              {㪠��⥫��}
END;
{-------------------------------Sstr----------------------------------------
           �����頥� ��ப���� �।�⠢����� �᫠                         }

FUNCTION Sstr(n:integer):STRING;
BEGIN
  Str(n,sa);
  Sstr:=sa;
END;
{------------------------------Time-----------------------------------------}
FUNCTION Time:word;
VAR
    hour,minute,second,sec100:word;
BEGIN
  GetTime(hour,minute,second,sec100);
  Time:=(hour*3600+minute*60+second)
END;

{-----------------------------PrintTime-------------------------------------}
PROCEDURE PrintTime;
VAR
   hour,minute,second,sec100:word;
BEGIN
  GetTime(hour,minute,second,sec100);
  sa:=Sstr(hour)+':'+Sstr(minute)+':'+Sstr(second);
  Write(sa)
END;

{------------------------------Screen-------------------------------------}
PROCEDURE Screen(n:byte);
VAR st:STRING[24];
BEGIN
  CASE n OF
    0:st:='';
    1:ST:='���⠢����� ����oᮢ ';
    2:ST:='   ����஢����      ';
    3:st:='  ������஢����     ' ;
    4:st:=' ���⠢����� ��ਠ�⮢ ';
    5:st:='    ��ᬮ��         '
  END;
  Window(1,1,80,25);
  Box(1,1,80,25,cfst,cvst,true,false);TextColor(cvst);
  Gotoxy(29,1);Write(ST);
  Gotoxy(24,25);Write('F1-��ࠢ��');
  Window(2,2,79,24);Clrscr;
END;
{-----------------------------Dialog-----------------------------------}

PROCEDURE Dialog(st:STRING;mn:byte;VAR yes:boolean;bol:boolean);
VAR cv,cv1,cv2,a,a1,a2:byte;ch:char;
BEGIN
  Cls;
  a1:=(78-Length(st))DIV 2-2;
  a2:=a1+5+Length(st);
  Box(a1,7,a2,13,cf1,0,false,false);TextColor(0);
  Gotoxy(a1+(a2-a1)DIV 2-4,7);Write(' ������ ');
  Window(a1+2,9,a1+5+Length(st),13);Clrscr;
  Gotoxy(3,2);Writeln(st);
  IF bol THEN BEGIN Sleep;Exit;END;
  IF mn<>0 THEN BEGIN                        {�᫨ ०�� �����}
                  Window(a1+3,13,a1+4+mn,13);
                  TextBackGround(lightgreen);
                  Clrscr;Window(a1+4,13,a1+4+mn,13);Exit;END;
  cv1:=cf2;cv2:=cf1;
  a:=a1;                                   {��������� ����.������}
  a1:=(a2-a1)DIV 4-1;
  a2:=(a2-a)DIV 2+(a2-a)DIV 4-2;
  a:=a1;                                   {a-��砫쭠� ����.��⨢�.������}
  REPEAT
    TextBackGround(cv1);Gotoxy(a1,5);Write('[��]');
    TextBackGround(cv2);Gotoxy(a2,5);
    Write('[���]');Gotoxy(a,5);
    ch:=ReadKey;
    IF ch=#27 THEN BEGIN yes:=false;Exit;END;
    IF ch=#9  THEN BEGIN
                     Gotoxy(a1,5);TextBackGround(cf1);Clreol;
                     cv:=cv1;cv1:=cv2;cv2:=cv;  {�����﫨 梥� ������}
                     IF a=a2 THEN a:=a1
                             ELSE a:=a2 END;    {� ����.�����}
  UNTIL ch=#13;
  IF cv1=cf1 THEN yes:=false
             ELSE yes:=true;
  Cls;
END;

{-------------------------------SelectTemGr---------------------------------}
PROCEDURE SelectTemGr(VAR temgr,index:String;VAR kod,numvar:
                          integer;bool:boolean);
				                 {bol-���� SelectVar(#10)}
VAR                                              {bool=true-SelectTema}
  colvar,colvopr:tmint;                          {bool=false-SelectGruppa}
  s:searchrec;
  names:tsm;    {���ᨢ 㪠�.�� ��ப� ��� ���.Scan}
  tems,ind:tpsm;
  col,fon:tmint;
  c,n,m,max,k,punct:integer;
  ch:char;
  mkod:tmint;
{---------------------------------------------------------------------}
PROCEDURE Scan;                     {cxb}
BEGIN
  k:=0;
  FindFirst('tema.*',anyfile,s);
  WHILE DosError=0 DO
    BEGIN
      Inc(k);
      Assign(fch,s.name);
      {$I-}
      Reset(fch);
      IF IOResult<>0 THEN BEGIN Ignored('�訡��.������� ��������.�.!');
      				Exit;END;
      {$I+}
      names[k]:=s.name;
      colvar[k]:=ReadFour;
      colvopr[k]:=ReadFour;
      Close(fch);
      FindNext(s)
    END;
END;
{--------------------------------------------------}
PROCEDURE PutColor;
VAR k:integer;
BEGIN
  FOR k:=1 TO max DO
    BEGIN
      IF k=punct THEN Begin COL[k]:=0;
                            fon[k]:=2;End
                 ELSE Begin COL[k]:=0;
                            fon[k]:=47;END;
    END;
END;
{--------------------------------------------------------------}
PROCEDURE Print;
VAR c,k:integer;
BEGIN
  TextBackGround(47);
  Clrscr;k:=n;
  WHILE k<n+7 DO BEGIN
                 Gotoxy(2,k-n+1);
                 TextBackGround(fon[k]);
                 TextColor(col[k]);
                 Write(tems[k]^);
                 IF k=max THEN Break;
                 Inc(k);
               END;
  Gotoxy(1,wherey+1);

END;
{-----------------------------------------------------------------}
PROCEDURE SelectWin;                      {��.���� �롮� ⥬}
VAR k:integer;
BEGIN
{  Cls;}
  Box(14,7,67,19,47,0,false,false);
  Textcolor(0);
  IF Bool THEN BEGIN Gotoxy(33,7);Write(' �롮� ⥬� ');END
          ELSE BEGIN Gotoxy(32,7);Write(' �롮� ��㯯� ');END;
  Gotoxy(37,19);Write('[Enter]');
  Window(16,9,67,19);Clrscr;
  Gotoxy(1,9);FOR k:=1 TO 52 DO Write(#205);
  Window(16,9,67,16);Clrscr;
END;

{----------------����७���----Inform--------------------------------------}
PROCEDURE Inform;
VAR k:integer;
BEGIN
  filename:='tema.'+ind[punct]^;
  IF NOT Verify(filename) THEN BEGIN
  				 Ignored('������ �� �⮩ ⥬� �� �������!');
                                 SelectWin;Exit;END;
  Assign(fch,filename);
  {$I-}
  Reset(fch);
  IF IOResult<>0 THEN BEGIN Ignored('�訡�� �� �⥭�� � ��᪠!');Exit;END;
  {$I+}
  Window(16,9,67,19);
  ReadTitul(colv,nn,ckolko,tim,j5,j4,j3,d,tema);
  Close(fch);
  Clrscr;Writeln;
  Writeln('������ 䠩�:',filename);
    Writeln('����:',tema);
    Writeln;
    Writeln('��ਠ�⮢:':10,colv:4);
    Writeln('�������:':10,nn:4);
    Writeln('�ᥣ�:':10,ckolko:4);
    Writeln('�⢥⮢:':10,d+1:4);
    Writeln('�६�:':10,tim:4);
    Gotoxy(30,5);
    Writeln('���ਨ ����.�業��':10);
    Gotoxy(30,7);Writeln('����:':10,j5:4);
    Gotoxy(30,8);Writeln('�����:':10,j4:4);
    Gotoxy(30,9);Write('��:':10,j3:4);
    Sleep;Clrscr;Gotoxy(1,9);
    FOR k:=1 TO 52 DO Write(#205);
    Window(16,9,67,16);
  END;

BEGIN                   {    Selecttema                     }
  numvar:=0;
  IF bool THEN filename:='temas.dat'
          ELSE filename:='gruppa.dat';
  IF NOT Verify(filename) THEN BEGIN
  	Ignored('��� ࠡ��� ����室�� 䠩� '+filename);Halt;END;
  Textbackground(cfst);
  max:=1;
  IF bool THEN Scan;
  Assign(fst,filename);
  {$I-}
  Reset(fst);k:=1;
  IF IOResult<>0 THEN BEGIN
  	Ignored('�������,�� ᥣ���� ��ࠡ���� �� ���������!');Halt;END;
  {$I+}
  WHILE NOT EOF(fst) DO
    BEGIN
      New(tems[max]);New(ind[max]);
      ReadLn(fst,TEMS[max]^);
      IF bool THEN ReadLn(fst,ind[max]^);
      Readln(fst,mkod[max]);
      Inc(max);
    END;
  Close(fst);
  Dec(max);
  SelectWin;
  punct:=1; {����� ��⨢��� ��ப� �� ��饬� ᯨ�� }
  PutColor;
  n:=1; {� ����� ��ப� �� ��饬� ᯨ�� ���.�뢮�}
  m:=1; {����� (� ����) ��⨢��� 诠��}
  REPEAT
    Print;
    REPEAT
	{��頥� � �����.������ ���� ���⥪��.�ࠢ�� � �뤥������ 䠩��}
      TextBackGround(47);Window(16,18,67,19);Clrscr;Window(16,9,67,16);
                             {�८��.� ����.�㪢�,�.�. s.name-��������}
      IF bool THEN BEGIN
        FOR c:=1 to 3 do ind[punct]^[c]:=UpCase(ind[punct]^[c]);
        FOR c:=1 to 30 DO
          BEGIN
            Window(16,18,67,19);
            sa:='TEMA.'+ind[punct]^;
	    IF names[c]=sa THEN
	                     BEGIN  write(names[c]);
        		        Write('  ��ਠ�⮢-',colvar[c],' ����ᮢ-',
				colvopr[c]);Window(16,9,67,16);Break;
			     END
                           ELSE Write('�� �⮩ ⥬� ������ �� �������');
            Window(16,9,67,16);END;
          END;
      ch:=ReadKey;
      CASE ch OF
        #13:BEGIN temgr:=tems[punct]^;index:=ind[punct]^;
                  kod:=mkod[punct];Cls;Exit;END;
        #0 :BEGIN
             ch:=ReadKey;
             CASE ch OF
               #59:IF bool THEN BEGIN Inform;Print;END;
               #68:Halt;
               #80:IF punct<max THEN BEGIN
                                       Inc(punct);
                                       IF m=7 THEN Inc(n);
                                       IF m<7 THEN Inc(m);
                                       END;
               #72:IF punct>1 THEN BEGIN
               			     IF m=1 THEN BEGIN Dec(n);dec(punct);END
                                     	    ELSE BEGIN Dec(punct);Dec(m);END;
                                   END;

              END;{case}
             END;{#0}
      END;{case}
       PutColor;
    UNTIL (ch=#72) OR (ch=#80) OR (ch=#13);
  UNTIL ch=#13;
  Cls;
  FOR k:=1 TO max DO BEGIN
                       Dispose(tems[k]);Dispose(ind[k]);
  		       tems[k]:=NIL;
                       IF bool THEN ind[k]:=NIL;END;
END;
{------------------------------------------------------------}
PROCEDURE SelectVar(tema,index:STRING;VAR numvar:integer);
VAR n:integer;yes:boolean;
BEGIN
 Clrscr;Writeln('Tema:');
 Writeln(tema);
 filename:='tema.'+index;
 Assign(fch,filename);
 Reset(fch);
 n:=ReadFour;
 Close(fch);
 Str(n,index);
 index:='������ ����� ��ਠ��(�� 1 �� '+index;
 Dialog(index,4,yes,false);
 Control(n,numvar);
 Cls;
END;

{------------------------------Input--------------------------------------}

PROCEDURE Input(VAR date:st8;VAR gruppa,tema,index:STRING;VAR kodgr,
                    kodtem,total:integer);
VAR numvar:integer;      {��᮫�⭮ �� �㦭�� ��६�����!}
BEGIN
  IF NOT Verify('info.dat') THEN
    BEGIN
      Screen(2);
      {Dialog('������ �������� ��㯯�:',8,yes,false);}
        SelectTemGr(gruppa,index,kodtem,numvar,false); {��ࠫ� ��㯯�}
        Assign(fst,'gruppa.dat');
        Reset(fst);
        WHILE NOT Eof(fst) DO BEGIN
          Readln(fst,sa);
          IF sa=gruppa THEN BEGIN
                              Readln(fst,kodgr);
                              Break;END;
        END;{while}
      Clrscr;
      Dialog('������ ���� ���� � �ଠ�: MM/��/��',9,yes,false);
      REPEAT
        Readln(date);
        Gotoxy(Wherex,Wherey-1);
        Clreol;
      UNTIL (Length(date)=8) AND (date[3]='/') AND (date[6]='/')
  	AND (date[1] IN nums) AND (date[2] IN nums) AND (date[4] IN nums)
        AND (date[5] IN nums) AND (date[7] IN nums) AND (date[8] IN nums);
      Cls;
      REPEAT
        SelectTemGr(tema,index,kodtem,numvar,true); {��ࠫ� ⥬�}
        filename:='var001.'+index;
        ChDir(catalog+'\var');
        IF NOT Verify(filename) THEN BEGIN
		Ignored('������ �� ������ ⥬� �� �� ��⠢����!');
                ChDir(catalog);END;
      UNTIL Verify(filename);
      GetDir(0,sa);    {�஢��塞 ,����� ��⠫�� ⥪�騩 �� ��室� �� 横��}
      IF sa<>catalog THEN ChDir(catalog);  {�᫨ VAR, � ���塞}
      Dialog('����쪮 ������ �⢮����� �� ��� ����?',3,yes,false);
      REPEAT Readln(total);UNTIL (total<1000) AND (total>0);
      Assign(fst,'info.dat');
      Rewrite(fst);
      Writeln(fst,date);
      Writeln(fst,gruppa);
      Writeln(fst,kodgr);
      Writeln(fst,tema);
      Writeln(fst,index);
      Writeln(fst,kodtem);
      Writeln(fst,total);
      Close(fst);
      SetTime(0,0,0,0);
    END       {info.dat ���������}
  ELSE BEGIN
         Assign(fst,'info.dat');
      	 Reset(fst);
      	 Readln(fst,date);                     {��⠫� ����,��㯯�,⥬�}
      	 Readln(fst,gruppa);
         Readln(fst,kodgr);
      	 Readln(fst,tema);
         Readln(fst,index);
         Readln(fst,kodtem);
         Readln(fst,total);
      	 Close(fst);
       END;
END;
{------------------------------Duplet--------------------------------------}
PROCEDURE Duplet(interval,ckolko:integer;VAR a:tmint);
VAR
  n,k,r : integer;
  dupl  : boolean;
BEGIN
   FOR k:=Low(a) TO High(a) DO a[k]:=0;
   Randomize;
   n:=1;
   REPEAT
     r:=Random(interval)+1;
     dupl:=false;
     FOR k:=1 TO n DO IF r=a[k] THEN dupl:=true;
     IF dupl THEN Continue;			{�᫨ ����������,� ᭮��}
     a[n]:=r;Inc(n)
   UNTIL n=ckolko+1;
END;
{------------------------------FindNum------------------------------------}
PROCEDURE FindNum(P:tp2;count:BYTE;VAR Y:BYTE);
VAR i:BYTE;ch:CHAR;
BEGIN
  i:=48+count;ch:=CHR(i);
  FOR i:=2 TO 23 DO IF P^[i,1]=ch THEN BEGIN
                                                     Y:=i;Break
                                                   END;
END;

{------------------------------Intermix-----------------------------------}
PROCEDURE Intermix(p2:tp2;d:integer;VAR right:integer);
VAR
  iold:byte;
  me:tmint;
  k:integer;
  i1,count,i,j:byte;
  ch:char;
  chars:tm2;
BEGIN
      i:=2;j:=1;
      Duplet(d+1,d+1,me);                         {���ᨢ ���.�⢥⮢}
      FOR k:=1 TO d+1 DO IF me[k]=d+1 THEN right:=k;
      Clrscr;
      REPEAT               {�뢮� �����}
        Gotoxy(j,i);
         ch:=p2^[i,j];
        IF ch=#221 THEN Break;
        Write(ch);Inc(j);IF j=78 THEN BEGIN Inc(i);j:=1;END;
      UNTIL ch=#221;
       Where(i,j);IF j<>1 THEN Inc(i);
       Gotoxy(1,i);FOR i:=1 TO 78 DO Write(#196);
       count:=1;
       REPEAT                                   {�뢮� �⢥�}
         Write(count,'.');
         iold:=Wherey;				{����.��࠭���� ���-� ����.}
         FindNum(p2,me[count],i1);              {��諨 ���. � �㦭.�⢥⮬}
         j:=3;
         REPEAT
           Where(i,j);
           ch:=p2^[i1,j];
           IF ch=#221 THEN Break;
           IF ch=#219 THEN Continue;
           Where(i,j); Write(ch);
           Inc(j);
           IF j=78 THEN BEGIN                   {���.����.� ���.᫥�}
	   		j:=3;Inc(i);Inc(i1);Gotoxy(1,i);END;
         UNTIL ch=#219;
         Inc(count);                            {���.����.� ���.᫥�}
         Where(i,j);IF j<>3 THEN Inc(i);Gotoxy(1,i);
         {i-�����६���� ���न���� ����� ��ப� � 㦥 �뢥������ ������⢮
                         ��ப;�᫨ ���-�� ��ப ����� ��� � }
{         if (i-iold=1) or (i-iold=2) then
             begin GotoXY(1,iold);Write(count-1,'.');end;
         if (i-iold=3) then begin GotoXY(1,iold+1);Write(count-1,'.');end;
         {Gotoxy(1,i-1);Write(count-1,'.')};Gotoxy(1,i);
       UNTIL count=d+2;
END;

{-----------------------------Rezultat------------------------------------}
PROCEDURE Rezultat(oc:integer);
BEGIN
  TextMode(co40);
  TextBackGround(0);
  TextColor(15);Gotoxy(14,10);
  Write('�� ����稫� ',oc);
  Sleep;
  TextMode(co80);
END;
{--------------------------MakeFileName------------------------------------}
PROCEDURE MakeFileName(index:String;numvar:integer;VAR filename:st12);
VAR
  S:SearchRec;
  colvar:integer;
BEGIN
  IF numvar=0 THEN
    BEGIN
      filename:='tema.'+index;
      Assign(fch,filename);
      {$I-}
      Reset(fch);
      IF IOResult<>0 THEN BEGIN
      		Ignored('�������,�� ᥣ���� ��ࠡ���� �� ���������!');
                Exit;END;
      colvar:=ReadFour;		{colvar-᪮�쪮 ��ਠ�⮢ �� �⮩ ⥬�}
      Close(fch);
      Randomize;
      numvar:=Random(colvar)+1;
    END;
  Str(numvar,sa);
  IF Length(sa)<3 THEN
     CASE Length(sa) OF
       1:sa:='00'+sa;
       2:sa:='0'+sa;
     END;
  filename:='VAR'+sa+'.'+index
END;
{-------------------------------Sort-------------------------------------}
PROCEDURE Sort(VAR c:tmint);
VAR
  max,buff,i,k:integer;
BEGIN
  FOR k:=1 TO High(c) DO IF c[k]=0 THEN BEGIN max:=k-1;Break;END;
  FOR i:=1 TO max-1 DO
    FOR k:=i+1 TO max DO
      IF c[i]>c[k] THEN
         BEGIN
           buff:=c[i];
           c[i]:=c[k];
           c[k]:=buff
         END;
END;

{-----------------------------TESTING-------------------------------------}
VAR
  date:st8;
  i,J,count:byte;
  ch:char;
  gruppa,index,vern,name,badst:STRING;
  badmas,sluch:tmint;
  otv,right,num,numvar,NumVopr,prav,neprav,oc:integer;
  k,code,totalves,totaltim:integer;
  firsttim,oldtim,newtim:word;
  pm2:tpm2;
  kodgr,kodtem,ves,total:integer;
  jr3,jr4,jr5,ball:real;
BEGIN
  GetDir(0,catalog);                           {��।��塞 ⥪�騩 ��⠫��}
  Input(date,gruppa,tema,index,kodgr,kodtem,total);
  REPEAT
    Picture(ch);
    Screen(2);
    numvar:=0;                                  {���� ����� ��ਠ��=0}
    IF ch=#10 THEN SelectVar(tema,index,numvar)
              ELSE IF ch=#0 THEN IF ReadKey=#68 THEN Halt;
    MakeFileName(index,numvar,filename);        {�ﯠ�� ��� 䠩��}
    ChDir(catalog+'\VAR');                      {� ��⠫�� � ����ᠬ�}
    Assign(fch,filename);
    {$I-}
    Reset(fch);
    IF IOResult<>0 THEN BEGIN
         Ignored('����� ����� ������ �� ⥬� '+tema+'(䠩� '+filename+')');
         Exit;END;
    {$I+}
    ReadTitul(colv,nn,ckolko,tim,j5,j4,j3,d,tema);
    jr3:=j3/100;jr4:=j4/100;jr5:=J5/100;
    FOR k:=Low(pm2) TO High(pm2) DO pm2[k]:=NIL;{���㫥��� ���ᨢ� 㪠�.}
    Fill(pm2);                                  {��������� ���ᨢ 㪠��⥫��}
    Close(fch);
    ChDir(catalog);                            {���㫨�� � ��⠫�� TEST}
    Clrscr;				        {�����ﬨ �� 䠩��}
    Duplet(ckolko,ckolko,sluch);                {���ᨢ ��� ���.����ᮢ}
    FOR k:=1 TO ckolko do sluch[k]:=k;
    name:=Copy(filename,4,3);                   {�뤥���� �� ����� 䠩�� ��-}
    Val(name,numvar,code);		        {��� �����}
    {---------------------------------------------------------------------
                         ������ ������				}

    prav:=0;ball:=0;neprav:=0;
    ves:=total div ckolko;                          {��� � ������ ������ �����}
    FOR k:=1 TO High(badmas) DO badmas[k]:=0;   {���㫥��� ���ᨢ� ����.��}
    firsttim:=Time;
    FOR num:=1 TO ckolko DO
      BEGIN
        Window(1,1,80,25);Gotoxy(3,1);TextColor(lightred);
        Write(' ����� ����� ',num,' ');Gotoxy(65,1);
	Write(' ��ਠ��: ',numvar,' ');TextColor(yellow);
        Window(2,2,79,24);
        Intermix(pm2[sluch[num]],d,right);;     {��६��.� ��.�� ��࠭}
        oldtim:=Time;
	Gotoxy(63,23);TextColor(white);
	Write('��� �६�: ');
	Window(75,24,78,24);
        REPEAT
          WHILE NOT KeyPressed DO
            BEGIN
              newtim:=oldtim+tim-Time;;Gotoxy(50,23);TextColor(white);
              Delay(1000);Clrscr;Write(newtim);
              IF (newtim>tim) THEN Break
            END;
            IF NOT(newtim>tim) THEN
                                 BEGIN
                                   ch:=ReadKey;
                                   Val(ch,otv,code);
				 END;
        UNTIL(newtim>tim) OR ((otv>0) AND (otv<=d+1));
        Cls;
        TextColor(yellow);
        val(ch,otv,code);
        IF otv=right THEN Inc(prav);            {��饥 ���-�� �ࠢ.�⢥⮢}
        IF otv<>right THEN
                        BEGIN
                          name:='';             {����祭�� ����� ����.��.}
                          FOR k:=1 TO 4 DO name:=name+pm2[sluch[num]]^[1,k];
                          Val(name,k,code);     {�८��.��� � �᫮}
                          Inc(neprav);	        {��饥 ���-�� ���ࠢ.�⢥⮢}
                          badmas[neprav]:=k;    {� ����.����.��.-���.����.}
                        END;

      END; 				        {横� �� 1 �� ckolko}
      Sort(badmas);
      totaltim:=Time-firsttim;                  {��饥 �६� �� �� ������}
      name:='';                                 {�८�ࠧ㥬 badmas � ��ப�}
      FOR k:=1 TO neprav DO name:=name+'.'+Sstr(badmas[k]);            {name}
      badst:=Copy(name,2,Length(name)-1);       {㡨ࠥ� ��� � name}
      Str(prav,vern);                           {���_�� �ࠢ.�⢥⮢ � ��ப�}
      ball:=ves*prav;                           {������뢠�� ��� �����}
      k:=trunc(ball);
      Str(k,sa);
      {IF ball>=10 THEN sa:=Copy(sa,2,1)+Copy(sa,4,1)
                  ELSE
                        IF ball>1 THEN sa:=Copy(sa,2,3)
                        ELSE sa:='0.'+Copy(sa,2,1)+Copy(sa,4,1);}
      total:=ves*ckolko;
      IF ball<total*jr3 THEN oc:=2;
      IF (ball=total*jr3) OR (ball>total*jr3) AND (ball<total*jr4) THEN oc:=3;
      IF (ball=total*jr4) OR (ball>total*jr4) AND (ball<total*jr5) THEN oc:=4;
      IF (ball=total*jr5) OR (ball>total*jr5) THEN oc:=5;
    Clrscr;
    Dialog('������ ��� ����㥬���',20,yes,false);
    ClearBuf;name:='';
    ControlST(3,15,name);                      {���� �����}
    {$I-}
    Assign(fst,'otchet.dat');
    IF NOT Verify('otchet.dat') THEN Rewrite(fst)
    				ELSE Append(fst);
                                {$I+}
    IF IOResult<>0 then begin
              Assign(fst,Copy(name,1,5)+'.err');
              Rewrite(fst);end;
{              Ignored('��⥢�� �訡��!��१���㧨� �ࢥ�.');Halt;end;}
    Writeln(fst,date:8,name:15,gruppa:8,kodgr:3,numvar:4,oc:2,sa:5,tema:12,
            kodtem:3,' ',badst);
    Close(fst);
    {$I+}
    FOR k:=Low(pm2) TO High(pm2) DO IF Assigned(pm2[k]) THEN Dispose(pm2[k]);
  UNTIL ch=#68;
END.




