CLS
DIM a(5)
FOR i = 1 TO 5
a(i) = INT(RND * 5) + 1
20 FOR e = 1 TO i
IF e = i THEN 10
IF a(i) <> a(e) THEN 10
a(i) = INT(RND * 5) + 1
GOTO 20
10 NEXT e
NEXT i
FOR u = 1 TO 5
PRINT a(u)
NEXT u

