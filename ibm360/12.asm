Recursive start 0
                        ; START OF INIT
STM R14, R12, 12(R13)
BALR R12, R0
using *, R12
ST R13, Reg13
LA R13, RegSaveArea
                        ; END OF INIT
                        ; START OF FUNCTION
L R3, n     ;  put R3 in n
C R3, =F'2'
BL  EXIT_NVALID
LA  R7, stack_array    ; R7 is stack pointer

LOOP:
    C   R3, =F'1'
    BNH OUT
    LA  R2, 0
    D  R2, =F'2'    ; R2 reminder, R3  result
    ST R2, 0(R7)
    A  R7, =F'4'
    B LOOP
OUT:
LA R3, 1     ; store answer in R3
LOOP2:
    S  R7, =F'4'
    LA R9, stack_array  ; why does not V working
    CR R7, R9
    ; C  R7, =V(stack_array)
    BL OUT2
    M  R2, =F'2'
    CLI 3(R7), 1
    BE ODD
    EVEN:
    S  R3, =F'1'
    B LOOP2
    ODD:
    A  R3, =F'1'
    B LOOP2
OUT2:

ST R3, result

                        ; END OF FUNCTION
                        ; START OF EXIT
B EXIT

; why does not MVC working
EXIT_DIVIDE_BY_ZERO:
; MVC     error_message(40), =C'Divide by zero!                        '
B EXIT

EXIT_OVERFLOW:
; MVC     error_message(40), =C'There was an overflow!                 '
B EXIT

EXIT_NVALID:
; MVC     error_message(40), =C'The number n should be more than 1!    '
B EXIT

EXIT:
L  R13, Reg13
LM R14, R12, 12(R13)
BR R14
                        ; END OF EXIT
                        ; START OF DATA
n   DC  F'5'
result  DS F
error_message DS C'OK', 40 C' '

stack_array       DS 100 F

RegSaveArea DS 15 F	
Reg13 DS F
                        ; END OF DATA
end
