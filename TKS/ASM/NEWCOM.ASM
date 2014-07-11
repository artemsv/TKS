;com dummy (C) by O Love & Tels - please modify for your own purposes

;This file is part of ASM Edit. Copyright (c) by O Love & Tels, 1996.
;It may be freely copied, used, distributed or mentioned as long as this
;message remains. Please add your name if you modify or add something.

.286c
SEG_A           SEGMENT
                ASSUME CS:SEG_A, DS:SEG_A
                ORG     100H

COMDUMMY        PROC FAR
        INIT:   JMP     START

;insert your data here like this one:

                a       DW      0

;insert your macros and procedures here like this one:

        DUMMY MACRO
                NOP
        ENDM

        START:  
; insert your main program code here:

                RETN
COMDUMMY        ENDP

SEG_A           ENDS
                END     INIT
