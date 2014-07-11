set talk off
set status off
pr=0
m1=0
i=1
use jun1
m1=val(oc)
sum m1 to m8
store "!" to rt
@ 2,3 say "Итоги опроса по группе:"
@ 2,27 say gr
@ 3,3 say "Тема:"
@ 3,9 say tem
@ 4,3 say "Дата:"
@ 4,9 say dat
@ 5,3 say "---------------------------------------"
@ 6,3 say "!     Ф.И.О.         ! Оценка ! Баллы !"
@ 7,3 say "---------------------------------------"
do while pr=0 
  do while i<15.and..not.eof()
     m8=val(sum)
     i=i+1
     @ i+6,3 say rt
     @ i+6,5 say fio
     @ i+6,24 say rt
     @ i+6,28 say oc
     @ i+6,33 say rt
     @ i+6,37 say sum
     @ i+6,41 say rt
     skip 1
  enddo
  average m8 to p
  @ 23,3 say "Средний балл:"
  @ 23,15 say p
  read  
  if readkey()=12
    clear
    exit
  endif
enddo

