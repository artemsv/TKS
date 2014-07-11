set talk off
set status off
set menu off
clear all
use jun1
stl=1
@ stl,2 clear
@ stl+1,2 say gr
@ stl+1,12 say tem
@ stl+2,2 say "---------------------------------------------------"
@ stl+3,2 say "! Фамилия И. O.       !Группа  !  Тема      ! Бал  !"
@ stl+4,2 say "---------------------------------------------------"
store "!" to rt
go top
do while stl<12 .and..not.eof()
   stl=stl+1
   @ stl+4,2 say rt
   @ stl+4,5 say fio
   @ stl+4, 24 say rt
   @ stl+4, 26 say gr
   @ stl+4,33 say rt
   @ stl+4,35 say tem
   @ stl+4,46 say rt
   @ stl+4,49 say sum
   @ stl+4,53 say rt
skip 1
enddo 
stl=1
strr=stl
do stuk
set device to screen 
