set talk off
use jun1 
average bal to cred for gr=grup1.and.tem=ktem1
index on bal to junbal
use jun1 index junbal
pp=0
pw=0 
   i=0
   clear
   @ 5,10 prompt '1.На печать'
   @ 6,10 prompt '2.На дисплей'
   menu to pp
   clear
    if pp=1     
      set device to print
      str1=prow()+1  
    endif
     str1=1
     store "!" to rt
     @ 2,0 say " "
     @ str1+2,3 say "Итоги опроса по группе:"
     @ str1+2,27 say grup1 
     @ str1+3,3 say "Тема:"
     @ str1+3,9 say kTEM1 
     @ str1+4,3 say "Дата:"
     @ str1+4,9 say KDAT 
     @ str1+5,3 say "---------------------------------------"
     @ str1+6,3 say "!     Ф.И.О.         ! Оценка ! Баллы !"
     @ str1+7,3 say "---------------------------------------"
     if pp=1
       go top
       strr=6
        do while.not.eof()
          pr10=val(kgr)
          pr23=val(ktem)         
          if (val(kgr)=val(otvet).and.dtoc(dat)=dtoc(kdat)).and.pr11=pr23
             store strr+1 to strr
             strr=prow()+1
             do stuk
           endif        
           skip 1 
         enddo     
         @ strr+1,3 say "--------------------------------------"
         @ strr+2,10 say "Средний балл:"
         @ strr+2,24 say cred
         eject
         strr=8
         set device to screen      
      endif 
     str1=8
     go top 
     j=1
     pw=reccount()
     i=1
      p1=0     
      j=reccount()
     do while p1=0
        do while str1<21 .and..not.eof()
           if str1<22
              pr10=val(kgr)
              pr23=val(ktem)
              if pr10=pr12.and.pr23=pr11 
                 str1=str1+1
                 @ str1,3 say rt picture '@z X'
                 @ str1,5 say fio picture '@z XXXXXXXXXXXXXXX'
                 @ str1,24 say rt picture '@z X'
                 @ str1,28 say oc picture '@z XXX'
                 @ str1,33 say rt picture '@z X'         
                 @ str1,35 say bal picture '@z 9999'
                 @ str1,41 say rt  picture '@z X'
               endif  
                 else        
                   str1=8
                   skip -1
               endif
               skip 1       
             enddo
              str1=8
          read
         if readkey()=12
            p1=1
            exit
         endif 
      if readkey()=7.or.readkey()=263
          if .not.eof()
              @ 9,2 clear to 22,79
          endif
        endif
       if readkey()=6 .or. readkey()=264
          @ 9,2 clear to 22,79
          if recno()<=j
             go top
           endif
           if recno()>j          
              skip -j
           endif        
        endif
    enddo
    str1=str1+1
    @ str1,1 say '-------------------------------------------'
    @ str1+1,3 say" "
    @ str1+1,3 say "Средний балл:"
    @ str1+1,28 say cred
    @ 23,10 say" "
    wait
    
  
