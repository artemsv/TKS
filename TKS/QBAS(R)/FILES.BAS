10 CLS
LOCATE 10, 30
PRINT "-"; "/"; "|"
GOSUB zad:
CLS
LOCATE 10, 30
PRINT "\"; "|"; "/"
GOSUB zad:
CLS
LOCATE 10, 30
PRINT "|"; "\"; "-"
GOSUB zad:
CLS
LOCATE 10, 30
PRINT "/"; "-"; "\"
GOSUB zad:
GOTO 10
zad:
FOR i = 1 TO 100
NEXT i
RETURN







