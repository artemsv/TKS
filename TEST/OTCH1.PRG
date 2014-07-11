set talk off
sele 1
use jun1
sele 3
use jun
asd="jun3"
copy stru to &asd
sele 2
use jun3
if file("otchet.dat")
append from otchet.dat delim with ,
go top
do while .not.eof()
   pr1=substr(field1,1,8)
   pr1=ltrim(pr1)
   pr2=substr(field1,9,15)
   pr2=ltrim(pr2)
   pr3=substr(field1,24,8)
   pr3=ltrim(pr3)
   pr4=substr(field1,32,3)
   pr4=ltrim(pr4)
   pr5=substr(field1,35,4)
   pr5=ltrim(pr5) 
   pr6=substr(field1,39,2)
   pr6=ltrim(pr6) 
   pr7=substr(field1,41,5)
   pr7=ltrim(pr7)
   PR12=VAL(PR7)
   pr10=substr(field1,46,12)
   pr10=ltrim(pr10) 
   pr8=ctod(pr1)
   pr9=substr(field1,58,3)
   pr9=ltrim(pr9)
   pr11=substr(field1,61)  
    sele 1
   append blank
   replace dat with pr8,fio with pr2,gr with pr3,kgr with pr4,bal with pr12,oc with pr6
   replace nv with pr5,tem with pr10,np with pr11,ktem with pr9
   sele 2
   skip 1
enddo
endif
clear
@ 12,12 say "Удалить файл"
close databases
erase jun3.dbf
erase otchet.dat
erase info.dat
use jun1
