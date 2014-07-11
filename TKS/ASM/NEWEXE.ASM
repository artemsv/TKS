;exe dummy (C) by O Love & Tels - please modify for your own purposes

;This file is part of ASM Edit. Copyright (c) by O Love & Tels, 1996.
;It may be freely copied, used, distributed or mentioned as long as this
;message remains. Please add your name if you modify or add something.

.286c
;-------------------------------------------------------------- SEG_A  ----

SEG_A           SEGMENT BYTE PUBLIC
                ASSUME CS:SEG_A, DS:SEG_B, SS:STACK_SEG_C

EXEDUMMY        PROC    FAR

;insert your macros and procedures here like this one:

        DUMMYM  MACRO
                NOP
        ENDM
        
        DUMMYP  PROC NEAR
                RET
        ENDP

START:          PUSH    SEG_B           ;set DS to seg_B; needed, since
                POP     DS              ;ASSUME doesn't work (TASM/MASM: why??)
;insert your main program code here:

                MOV     AX,4C00H
                INT     21H                     ;DOS service: terminate
EXEDUMMY        ENDP
SEG_A           ENDS

;-------------------------------------------------------------- SEG_B  ----

SEG_B           SEGMENT BYTE PUBLIC
                ASSUME CS:SEG_B, DS:SEG_B, SS:STACK_SEG_C

;insert your data here like this one:

        a       DB 0
SEG_B           ENDS

;--------------------------------------------------------- STACK_SEG_C  ---

STACK_SEG_C     SEGMENT WORD STACK 'STACK'
                DB 32 DUP (0)           ;stack size, please modify for
                                        ;your purposes
STACK_SEG_C     ENDS

                END     START
