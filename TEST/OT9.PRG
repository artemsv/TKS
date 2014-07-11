set talk off
c="               "    
if len(t)<len(fio)
    c=t
    t=fio
    fio=c
endif
if abs(asc(t)-asc(fio))=63
   t=stuff(t,1,1,left(fio,1))
endif
