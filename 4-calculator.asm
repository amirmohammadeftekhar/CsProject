.DATA
    welcome_message db 'Enter a string to evaluate!', 10, 13, '$'
    return_message db 10, 13, 'Result: $' 
    base dw 10
    ; cr is stored in al
    ; answer is stored in dx
    ; bx is used as temp
.STACK
    stack_array dw 100h dup(0)


.CODE
    SPACE EQU 32
    ENTER EQU 13
    P_OPEN EQU 40
    P_CLOSE EQU 41
    ZERO EQU 48
    PLUS EQU 43
    MINUS EQU 45
    STAR EQU 42
    SLASH EQU 47

    al_to_int MACRO label_to_escape
        mov ah, al
        sub ah, ZERO
        jl label_to_escape
        cmp ah, 9
        jg label_to_escape   
    ENDM

    multiply_word_integer MACRO b, overflow_label ; ax * b
        ; lets assume that we do not encounter overflow for now
        push dx
        imul b
        jo overflow_label
        pop dx
    ENDM

    divide_word_integer MACRO b, overflow_label ; ax * b
        ; lets assume that we do not encounter overflow for now
        push dx
        xor dx, dx
        idiv b
        jo overflow_label
        pop dx
    ENDM

    get_char PROC ; inputs a char in al; changes ax
        mov ah,1
        int 21h
        ret
    get_char ENDP

    puts PROC ; outputs the string in [dx]
        push ax
        mov ah,9
        int 21h
        pop ax
        ret
    puts ENDP

    get_string PROC; delimiter is '\n'  writes the result in [di], changes di
        push ax
        LOOP_GET_STRING:
        call get_char
        cmp al, 0dh
        je END_LOOP_GET_STRING
        mov byte ptr di, al
        inc di
        jmp LOOP_GET_STRING
        END_LOOP_GET_STRING:
        pop ax
        ret
    get_string ENDP

    read_blank PROC
        LOOP_READ_BLANK:
        call get_char
        cmp al, SPACE
        je LOOP_READ_BLANK
        ret
    read_blank ENDP    

    read_number PROC ; returns in ax
        push bx

        mov bx, 0

        LOOP_READ_NUMBER:
        cmp al, SPACE
        je REMOVE_SPACES
        al_to_int END_LOOP_READ_NUMBER
        xchg ax,bx
        multiply_word_integer base, EXIT_OVERFLOW
        mov bl, 0
        xchg bl,bh
        add ax, bx
        jo EXIT_OVERFLOW
        xchg ax, bx
        add al, ZERO
        
        call get_char
        jmp LOOP_READ_NUMBER
        REMOVE_SPACES:
        call read_blank
        END_LOOP_READ_NUMBER:

        mov dx, bx
        pop bx
        ret
    read_number ENDP

    read_cr PROC ; returns in ax
        mov CS:is_minus, 0
        cmp al, MINUS
        jne READ_CR_NOT_MINUS
        mov CS:is_minus, 1
        call read_blank
        READ_CR_NOT_MINUS:

        cmp al, P_OPEN
        jne END_IF_1_READ_CR
        call read_blank
        call read_expr
        cmp al, P_CLOSE
        jne EXIT_NVALID
        call read_blank
        jmp RETURN_RESULT
        END_IF_1_READ_CR:
        al_to_int END_IF_2_READ_CR
        call read_number
        jmp RETURN_RESULT
        END_IF_2_READ_CR:        
        jmp EXIT_NVALID

        RETURN_RESULT:
        cmp CS:is_minus, 1
        jne REALLY_RETURN_RESULT
        neg dx
        REALLY_RETURN_RESULT:
        ret
        is_minus DB ?
    read_cr ENDP

    read_md PROC
        push bx

        call read_cr
        mov bx, dx

        LOOP_READ_MD:

        cmp al, STAR 
        jne END_STAR
        call read_blank
        call read_cr
        xchg dx, ax
        xchg ax,bx
        multiply_word_integer bx, EXIT_OVERFLOW
        xchg ax,bx
        xchg dx, ax
        jmp LOOP_READ_MD

        END_STAR:   
        cmp al, SLASH     
        jne END_SLASH
        call read_blank
        call read_cr
        xchg dx, ax
        xchg ax,bx
        divide_word_integer bx, EXIT_OVERFLOW
        xchg ax,bx
        xchg dx, ax
        jmp LOOP_READ_MD
        END_SLASH:

        mov dx, bx
        pop bx
        ret
    read_md ENDP

    PROC read_expr
        push bx

        call read_md
        mov bx, dx

        LOOP_READ_EXPR:

        cmp al, PLUS 
        jne END_PLUS
        call read_blank
        call read_expr
        xchg dx, ax
        xchg ax,bx
        add ax, bx
        jo EXIT_OVERFLOW
        xchg ax,bx
        xchg dx, ax
        jmp LOOP_READ_EXPR

        END_PLUS:
        cmp al, MINUS        
        jne END_MINUS
        call read_blank
        call read_expr
        xchg dx, ax
        xchg ax,bx
        sub ax, bx
        jo EXIT_OVERFLOW
        xchg ax,bx
        xchg dx, ax
        jmp LOOP_READ_EXPR
        END_MINUS:

        mov dx, bx
        pop bx
        ret
    read_expr ENDP
    
    MAIN PROC
        mov ax,DATA
        mov ds,ax

        mov ax,STACK
        mov ss,ax

        lea sp,stack_array + 200h

        ; welcome message
        lea dx, welcome_message
        call puts

        ; calculate
        call read_blank
        call read_expr
        cmp al,ENTER
        jne EXIT_NVALID
        jmp EXIT
            
        EXIT_OVERFLOW:
        jmp EXIT

        EXIT_NVALID:
        jmp EXIT

        EXIT:    
        ; output message
        mov ax, dx
        lea dx,return_message
        mov di,dx
        call puts
        call PRINT_NUM
        mov ah,4ch
        int 21h

    MAIN ENDP

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; these functions are copied from emu8086.inc ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    putc    macro   char
            push    ax
            mov     al, char
            mov     ah, 0eh
            int     10h     
            pop     ax
    endm

    ; this procedure prints number in AX,
    ; used with PRINT_NUM_UNS to print signed numbers:
    PRINT_NUM       PROC    NEAR
            PUSH    DX
            PUSH    AX

            CMP     AX, 0
            JNZ     not_zero

            PUTC    '0'
            JMP     printed

    not_zero:
            ; the check SIGN of AX,
            ; make absolute if it's negative:
            CMP     AX, 0
            JNS     positive
            NEG     AX

            PUTC    '-'

    positive:
            CALL    PRINT_NUM_UNS
    printed:
            POP     AX
            POP     DX
            RET
    PRINT_NUM       ENDP



    ; this procedure prints out an unsigned
    ; number in AX (not just a single digit)
    ; allowed values are from 0 to 65535 (FFFF)
    PRINT_NUM_UNS   PROC    NEAR
            PUSH    AX
            PUSH    BX
            PUSH    CX
            PUSH    DX

            ; flag to prevent printing zeros before number:
            MOV     CX, 1

            ; (result of "/ 10000" is always less or equal to 9).
            MOV     BX, 10000       ; 2710h - divider.

            ; AX is zero?
            CMP     AX, 0
            JZ      print_zero

    begin_print:

            ; check divider (if zero go to end_print):
            CMP     BX,0
            JZ      end_print

            ; avoid printing zeros before number:
            CMP     CX, 0
            JE      calc
            ; if AX<BX then result of DIV will be zero:
            CMP     AX, BX
            JB      skip
    calc:
            MOV     CX, 0   ; set flag.

            MOV     DX, 0
            DIV     BX      ; AX = DX:AX / BX   (DX=remainder).

            ; print last digit
            ; AH is always ZERO, so it's ignored
            ADD     AL, 30h    ; convert to ASCII code.
            PUTC    AL


            MOV     AX, DX  ; get remainder from last div.

    skip:
            ; calculate BX=BX/10
            PUSH    AX
            MOV     DX, 0
            MOV     AX, BX
            DIV     CS:ten  ; AX = DX:AX / 10   (DX=remainder).
            MOV     BX, AX
            POP     AX

            JMP     begin_print
            
    print_zero:
            PUTC    '0'
    end_print:

            POP     DX
            POP     CX
            POP     BX
            POP     AX
            RET
    PRINT_NUM_UNS   ENDP



    ten             DW      10      ; used as multiplier/divider by SCAN_NUM & PRINT_NUM_UNS.

END MAIN