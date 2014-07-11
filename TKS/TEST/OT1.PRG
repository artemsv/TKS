set talk off
sele 4
use jun4
sele 1
use jun1
store space(8) to f1,f4
f2=0
f=0
go top
i=0
j=0
do while .not.eof()
   j=j+1
      @ 2,15 say fio
      f1=trim(gr)
      if kgr=0
      sele 4
      i=1
     go top
     do while .not.eof()
         i=i+1   
         sele 4
         f2=kgr1
         @ i,34 say f2
          @ i,2 say f1
          @ i,72 say kgr1 
          @ i,57 say gr1
             if f1=trim(gr1)
               sele 1 
               replace kgr with f2
             exit
             endif
          skip 1 
       enddo
     endif
    sele 1
skip 1 
  enddo
