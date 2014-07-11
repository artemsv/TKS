set talk off
set status off
set exact on
store 0 to k,l
store "           " to otvet1,m
     store 2 to st,stl
     use qtem
     do while .not.eof()
         @ st,stl say ktem picture '@z 999'
         @ st,stl+5 say tem
         st=st+1
         skip 1
     enddo
    @ 23,10 say 'Введите тему' get otvet1 picture '@z xxxxxxxxxxx'
    read
    clear
    use jun1
    sort to jun2 on gr,fio,tem/d
    sele 1
    use jun3
    sele 2
    use jun2
    t=fio
    do while .not.eof()
       do ot9
       if t=fio 
          m=gr
          k=k+1
          skip 1
          else 
               l=l+1
               go top
               average bal for tem=otvet1.and.t=fio to cred
               sele 1
               go top
               replace record l fio with t,gr with m,cr with cred
               sele 2
               go top
               skip k+2
               t=fio
        endif
     enddo
    kdat=dat
    go top
    if kgr=val(pr12)
       do while k<28.and..not.eof()
           k=k+1
           average bal for kgr=pr12.and.tem=ktem1 to sred(k)
          skip 1
       enddo
    endif
   
do otch5
    
