BaseChange start 0
                        ; START OF INIT
STM R14, R12, 12(R13)
BALR R12, R0
using *, R12
ST R13, Reg13
LA R13, RegSaveArea
                        ; END OF INIT
                        ; START OF FUNCTION
XR R2, R2       ; index on number
XR R5, R5       ; the value of number
LOOP_EXT:
    M   R4, b_base  ; multiply R5 * b_base
    C   R4, =F'0'
    BNZ EXIT_OVERFLOW

    XR R4, R4
    IC  R4, number(R2) ; store character
    LA  R2, 1(R2)

    XR R9, R9
    IC R9, =C'0'
    CR  R9, R4
    BE CASE0
    IC R9, =C'1'
    CR  R9, R4
    BE CASE1
    IC R9, =C'2'
    CR  R9, R4
    BE CASE2
    IC R9, =C'3'
    CR  R9, R4
    BE CASE3
    IC R9, =C'4'
    CR  R9, R4
    BE CASE4
    IC R9, =C'5'
    CR  R9, R4
    BE CASE5
    IC R9, =C'6'
    CR  R9, R4
    BE CASE6
    IC R9, =C'7'
    CR  R9, R4
    BE CASE7
    IC R9, =C'8'
    CR  R9, R4
    BE CASE8
    IC R9, =C'9'
    CR  R9, R4
    BE CASE9
    IC R9, =C'A'
    CR  R9, R4
    BE CASEA
    IC R9, =C'B'
    CR  R9, R4
    BE CASEB
    IC R9, =C'C'
    CR  R9, R4
    BE CASEC
    IC R9, =C'D'
    CR  R9, R4
    BE CASED
    IC R9, =C'E'
    CR  R9, R4
    BE CASEE
    IC R9, =C'F'
    CR  R9, R4
    BE CASEF
    IC R9, =C'$'
    CR  R9, R4
    BNE EXIT_NVALID
    XR  R4, R4
    D   R4, b_base
    B   END_LOOP_EXT

    CASEF:
    LA R5, 1(R5)
    CASEE:
    LA R5, 1(R5)
    CASED:
    LA R5, 1(R5)
    CASEC:
    LA R5, 1(R5)
    CASEB:
    LA R5, 1(R5)
    CASEA:
    LA R5, 1(R5)
    CASE9:
    LA R5, 1(R5)
    CASE8:
    LA R5, 1(R5)
    CASE7:
    LA R5, 1(R5)
    CASE6:
    LA R5, 1(R5)
    CASE5:
    LA R5, 1(R5)
    CASE4:
    LA R5, 1(R5)
    CASE3:
    LA R5, 1(R5)
    CASE2:
    LA R5, 1(R5)
    CASE1:
    LA R5, 1(R5)
    CASE0:
    B LOOP_EXT
END_LOOP_EXT:

LA R2, result     ; pointer
LA R2, 7(R2)
XR  R3, R3          ; parity

LOOP_WRITE:
    NR  R5, R5
    BZ  END_LOOP_WRITE

    XR  R4, R4
    D   R4, a_base  ; divide R5 / a_base, reminder is in R4

    ; C   R4, =F'0'
    ; BE  WCASE0
    ; C   R4, =F'1'
    ; BE  WCASE1
    ; C   R4, =F'2'
    ; BE  WCASE2
    ; C   R4, =F'3'
    ; BE  WCASE3
    ; C   R4, =F'4'
    ; BE  WCASE4
    ; C   R4, =F'5'
    ; BE  WCASE5
    ; C   R4, =F'6'
    ; BE  WCASE6
    ; C   R4, =F'7'
    ; BE  WCASE7
    ; C   R4, =F'8'
    ; BE  WCASE8
    ; C   R4, =F'9'
    ; BE  WCASE9
    ; C   R4, =F'10'
    ; BE  WCASEA
    ; C   R4, =F'11'
    ; BE  WCASEB
    ; C   R4, =F'12'
    ; BE  WCASEC
    ; C   R4, =F'13'
    ; BE  WCASED
    ; C   R4, =F'14'
    ; BE  WCASEE
    ; C   R4, =F'15'
    ; BE  WCASEF

    ; B   EXIT_OVERFLOW

    ; WCASE0:
    ; IC R9, =C'0'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASE1:
    ; IC R9, =C'1'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASE2:
    ; IC R9, =C'2'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASE3:
    ; IC R9, =C'3'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASE4:
    ; IC R9, =C'4'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASE5:
    ; IC R9, =C'5'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASE6:
    ; IC R9, =C'6'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASE7:
    ; IC R9, =C'7'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASE8:
    ; IC R9, =C'8'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASE9:
    ; IC R9, =C'9'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASEA:
    ; IC R9, =C'A'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASEB:
    ; IC R9, =C'B'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASEC:
    ; IC R9, =C'C'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASED:
    ; IC R9, =C'D'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASEE:
    ; IC R9, =C'E'
    ; STC R9, 0(R2)
    ; B DOWN
    ; WCASEF:
    ; IC R9, =C'F'
    ; STC R9, 0(R2)
    ; B DOWN

    NR R3, R3
    BZ DOWN

    SLL R4, 4
    IC R9, 0(R2)
    OR R4, R9
    STC R4, 0(R2)
    X  R3, =F'1'
    S  R2, =F'-1'
    B  LOOP_WRITE 

    DOWN:
    STC R4, 0(R2)
    X  R3, =F'1'
    B   LOOP_WRITE
END_LOOP_WRITE:

XR R2,R2 ; fill ans

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
; MVC     error_message(40), =C'invalid base or number!                '
B EXIT

EXIT:
L  R13, Reg13
LM R14, R12, 12(R13)
BR R14
                        ; END OF EXIT
                        ; START OF DATA
number   DC  C'12815$'
b_base   DC  F'10'
a_base   DC  F'16'
; result   DS  C'0', 31 C' ' ; to handle case that input is 0
result   DS   2 F'0' ; remove this for string

error_message DS C'OK', 40 C' '

stack_array       DS 100 F

RegSaveArea DS 15 F	
Reg13 DS F
                        ; END OF DATA
end
