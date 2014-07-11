set talk off
set status off
set menu off
clear all
use jun1
k=0
stl=1
@ stl,2 clear
@ stl+2,2 say "------------------------------------------------------"
@ stl+3,2 say "! N  !   Фамилия И. O.       ! Группа  ! Cредний бал !"
@ stl+4,2 say "------------------------------------------------------"
store "!" to rt
go top
do while stl<12 .and..not.eof()
   k=k+1
   nc=str(k,2)
   stl=stl+1
   @ stl+4,2 say rt
   @ stl+4,3 say trim(nc)
   @ stl+4,7 say rt
   @ stl+4,9 say trim(fio)
   @ stl+4,31 say rt
   @ stl+4,33 say trim(gr)
   @ stl+4,41 say rt
   @ stl+4,42 say sred
   @ stl+4,55 say rt
   skip 1
enddo 

