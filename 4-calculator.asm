.DATA
    welcome_message db 'Enter a string to evaluate!', 10, 13, '$'
    overflow_message db 10, 13, 'There was an overflow!', '$'
    nvalid_message db 10, 13, 'The expression is invalid!', '$'
    divide_by_zero_message db 10, 13, 'Divide by zero!', '$'
    return_message db 10, 13, 'Result: $' 
    one dw 1
    base dw 10
    precision dw 10
    precision_count dw 1
    ten dw 10
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

    get_string PROC; delimiter is '\n'  writes the result in [di], changes di
        push ax
        LOOP_GET_STRING:
        call read_char
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
        call read_char
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
        push ax

        xchg ax,bx

        push bx
        mov bx, 10
        call mul_float_int
        pop bx

        mov bl, 0
        xchg bl,bh
        xchg ax, bx
        call int_to_float
        xchg ax, bx
        call add_float
        xchg ax, bx

        pop ax 

        call read_char
        jmp LOOP_READ_NUMBER
        REMOVE_SPACES:
        call read_blank
        END_LOOP_READ_NUMBER:

        mov dx, bx
        pop bx
        ret
    read_number ENDP

    read_cr PROC ; returns in ax
        push cx
        xor cx, cx
        cmp al, MINUS
        jne READ_CR_NOT_MINUS
        mov cx, 1
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
        cmp cx, 1
        jne REALLY_RETURN_RESULT
        neg dx
        REALLY_RETURN_RESULT:
        pop cx
        ret
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
        call mul_float
        xchg ax,bx
        xchg dx,ax
        jmp LOOP_READ_MD

        END_STAR:   
        cmp al, SLASH     
        jne END_SLASH
        call read_blank
        call read_cr
        xchg dx, ax
        xchg ax,bx
        call div_float
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
        call add_float
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
        call sub_float
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

        ; output message
        mov ax, dx
        lea dx,return_message
        call puts
        call print_float
        jmp EXIT

        EXIT_DIVIDE_BY_ZERO:
        lea dx, divide_by_zero_message
        call puts
        jmp EXIT 

        EXIT_OVERFLOW:
        lea dx,overflow_message
        call puts
        jmp EXIT

        EXIT_NVALID:
        lea dx,nvalid_message
        call puts
        jmp EXIT

        EXIT:    
        mov ah,4ch
        int 21h
    MAIN ENDP


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; these are utility functions                 ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
        ; ax
    int_to_float  PROC    NEAR
        push dx

        imul precision

        cmp dx, 0
        jne  EXIT_OVERFLOW
        pop dx
        ret
    int_to_float ENDP

    ; ax
    float_to_int  PROC    NEAR
        push dx

        imul one
        idiv precision

        pop dx
        ret
    float_to_int  ENDP

    ; ax += bx
    add_float   PROC    NEAR
        add ax, bx
        jo EXIT_OVERFLOW
        ret
    add_float   ENDP

    ; ax -= bx
    sub_float   PROC    NEAR
        sub ax, bx
        jo EXIT_OVERFLOW
        ret
    sub_float   ENDP

    ; ax *= bx
    mul_float PROC
        push dx

        imul bx
        jo EXIT_OVERFLOW

        idiv precision

        ; check overflow
        cmp dx, 0
        je END_MULF
        neg dx
        cmp dx, 0
        je END_MULF
        jmp EXIT_OVERFLOW
        END_MULF:
        pop dx
        ret
    mul_float   ENDP

    ; ax *= bx
    mul_float_int PROC
        push dx

        imul bx
        jo EXIT_OVERFLOW

        pop dx
        ret
    mul_float_int   ENDP


    ; ax /= bx
    div_float_int PROC
        cmp bx, 0
        je EXIT_DIVIDE_BY_ZERO

        push dx
        imul one
        idiv bx

        pop dx
        ret
    div_float_int   ENDP

    ; ax /= bx
    div_float   PROC    NEAR
        cmp bx, 0
        je EXIT_DIVIDE_BY_ZERO

        push cx    
        push dx

        xor dx, dx
        xor cx, cx

        cmp ax, 0        
        jge F1_POSITIVE
        inc cx
        neg ax
        F1_POSITIVE:
        cmp bx, 0        
        jge F2_POSITIVE
        inc cx
        neg bx
        F2_POSITIVE:

        idiv bx    
        ; the answer is 100 * ax + 100 * dx / bx
        push dx
        imul precision
        cmp dx, 0
        jne EXIT_OVERFLOW
        pop dx

        push ax
        xchg ax, dx
        imul precision
        idiv bx
        pop dx
        add ax, dx

        ; number of negatives is in cx
        add cx, 2
        SIGN_LOOP: 
        neg ax
        loop SIGN_LOOP
        
        pop dx
        pop cx
        ret
    div_float  ENDP

    putc    macro   char
            push    ax
            mov     al, char
            mov     ah, 0eh
            int     10h     
            pop     ax
    endm

    ;  cin in cx
    scan_float        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        PUSH    BX

        MOV     BX, precision_count
        MOV     CX, 0

        ; reset flag:
        MOV     CS:make_minus, 0
        MOV     CS:is_first_iteration, 1
        MOV     CS:is_pressed_dot, 0
        f_next_digit:
                ; get char from keyboard
                ; into AL:
                MOV     AH, 00h
                INT     16h
                ; and print it:
                MOV     AH, 0Eh
                INT     10h

                ; check for MINUS:
                CMP     AL, '-'
                JE      set_minus

                CMP     AL, '.'
                JE      set_dot

                MOV     CS:is_first_iteration, 0
                ; check for ENTER key:
                CMP     AL, 0Dh  ; carriage return?
                JNE     not_cr
                JMP     stop_input
        not_cr:
                CMP     AL, 8                   ; 'BACKSPACE' pressed?
                JNE     backspace_checked
                MOV     DX, 0                   ; remove last digit by
                MOV     AX, CX                  ; division:
                DIV     ten                  ; AX = DX:AX / 10 (DX-rem).
                MOV     CX, AX
                PUTC    ' '                     ; clear position.
                PUTC    8                       ; backspace again.
                JMP     f_next_digit
        backspace_checked:


                ; allow only digits:
                CMP     AL, '0'
                JAE     ok_AE_0
                JMP     remove_not_digit
        ok_AE_0:        
                CMP     AL, '9'
                JBE     ok_digit
        remove_not_digit:       
                PUTC    8       ; backspace.
                PUTC    ' '     ; clear last entered not digit.
                PUTC    8       ; backspace again.        
                JMP     f_next_digit ; wait for next input.       
        ok_digit:
                CMP     CS:is_pressed_dot, 1
                jne     NOT_PRESSED_DOT
                cmp     BX, 0
                je      remove_not_digit
                dec     BX            
                NOT_PRESSED_DOT:

                ; multiply CX by 10 (first time the result is zero)
                PUSH    AX
                MOV     AX, CX
                MUL     ten                  ; DX:AX = AX*10
                MOV     CX, AX
                POP     AX

                ; check if the number is too big
                ; (result should be 16 bits)

                CMP     DX, 0
                JNZ     too_big
                ;;;;;;;;;;;;;;;;; CHECKING FOR TOO BIG
                PUSH AX
                PUSH CX
                PUSH DX
                PUSH BX
                MOV AX, CX
                MOV CX, BX
                    CHECK_TOO_BIG_1:
                    IMUL ten
                    CMP DX, 0
                    JNZ too_big
                    LOOP CHECK_TOO_BIG_1
                POP BX            
                POP DX
                POP CX
                POP AX            
                ;;;;;;;;;;;;;;;;;            

                ; convert from ASCII code:
                SUB     AL, 30h

                ; add AL to CX:
                MOV     AH, 0
                MOV     DX, CX      ; backup, in case the result will be too big.
                ADD     CX, AX
                JC      too_big2    ; jump if the number is too big.
                ;;;;;;;;;;;;;;;;; CHECKING FOR TOO BIG
                PUSH AX
                PUSH CX
                PUSH DX
                PUSH BX
                MOV AX, CX
                MOV CX, BX
                    CHECK_TOO_BIG_2:
                    IMUL ten
                    CMP DX, 0
                    JNZ too_big2
                    LOOP CHECK_TOO_BIG_2
                POP BX            
                POP DX
                POP CX
                POP AX            
                ;;;;;;;;;;;;;;;;;
                JMP     f_next_digit

        set_minus:
                cmp     CS:is_first_iteration, 0
                je      not_cr
                MOV     CS:make_minus, 1
                JMP     f_next_digit

        set_dot:
                cmp     CS:is_pressed_dot, 1
                je      not_cr
                mov     CS:is_pressed_dot, 1
                jmp     f_next_digit                       
        too_big2:
                MOV     CX, DX      ; restore the backuped value before add.
                MOV     DX, 0       ; DX was zero before backup!
        too_big:
                MOV     AX, CX
                DIV     ten  ; reverse last DX:AX = AX*10, make AX = DX:AX / 10
                MOV     CX, AX
                PUTC    8       ; backspace.
                PUTC    ' '     ; clear last entered digit.
                PUTC    8       ; backspace again.        
                JMP     f_next_digit ; wait for Enter/Backspace.
                
                
        stop_input:
                ; check flag:
                
                ;;;;;;;;;;;;;;;;; MULTIPLYING BY POWER OF 10
                MOV AX, CX
                MOV CX, BX
                    PRODUCE_RESULT:
                    IMUL ten
                    LOOP PRODUCE_RESULT
                MOV CX, AX
                ;;;;;;;;;;;;;;;;;


                CMP     CS:make_minus, 0
                JE      not_minus
                NEG     CX
        not_minus:
                POP     BX
                POP     SI
                POP     AX
                POP     DX
                RET
        make_minus      DB      ?       ; used as a flag.
        is_first_iteration   DB   ?
        is_pressed_dot      DB     ?
    scan_float       ENDP

    ;  prints ax/100
    print_float     proc    near
            push    cx
            push    dx
            push    bx
            mov     bx, precision

            imul    one
            idiv    bx
            ; because the remainder takes the sign of divident
            ; its sign should be inverted when divider is negative
            ; (-) / (-) = (+)
            ; (+) / (-) = (-)
            cmp     bx, 0
            jns     div_not_signed
            neg     dx              ; make remainder positive.
    div_not_signed:

            ; print_num procedure does not print the '-'
            ; when the whole part is '0' (even if the remainder is
            ; negative) this code fixes it:
            cmp     ax, 0
            jne     checked         ; ax<>0
            cmp     dx, 0
            jns     checked         ; ax=0 and dx>=0
            push    dx
            mov     dl, '-'
            call    write_char      ; print '-'
            pop     dx
    checked:

            ; print whole part:
            call    print_num

            ; if remainder=0, then no need to print it:
            cmp     dx, 0
            je      done

            push    dx
            ; print dot after the number:
            mov     dl, '.'
            call    write_char
            pop     dx

            ; print digits after the dot:
            mov     cx, precision_count
            call    print_fraction
    done:
            pop     bx
            pop     dx
            pop     cx
            ret
    print_float     endp

    ;***************************************************************

    ; prints dx as fraction of division by bx.
    ; dx - remainder.
    ; bx - divider.
    ; cx - maximum number of digits after the dot.
    print_fraction  proc    near
            push    ax
            push    dx
    next_fraction:
            ; check if all digits are already printed:
            cmp     cx, 0
            jz      end_rem
            dec     cx      ; decrease digit counter.

            ; when remainder is '0' no need to continue:
            cmp     dx, 0
            je      end_rem

            mov     ax, dx
            xor     dx, dx
            cmp     ax, 0
            jns     not_sig1
            not     dx
    not_sig1:

            imul    ten             ; dx:ax = ax * 10

            idiv    bx              ; ax = dx:ax / bx   (dx - remainder)

            push    dx              ; store remainder.
            mov     dx, ax
            cmp     dx, 0
            jns     not_sig2
            neg     dx
    not_sig2:
            add     dl, 30h         ; convert to ascii code.
            call    write_char      ; print dl.
            pop     dx

            jmp     next_fraction
    end_rem:
            pop     dx
            pop     ax
            ret
    print_fraction  endp

    ;***************************************************************

    ; this procedure prints number in ax,
    ; used with print_numx to print "0" and sign.
    ; this procedure also stores the original ax,
    ; that is modified by print_numx.
    print_num       proc    near
            push    dx
            push    ax

            cmp     ax, 0
            jnz     not_zero

            mov     dl, '0'
            call    write_char
            jmp     printed

    not_zero:
            ; the check sign of ax,
            ; make absolute if it's negative:
            cmp     ax, 0
            jns     positive
            neg     ax

            mov     dl, '-'
            call    write_char
    positive:
            call    print_numx
    printed:
            pop     ax
            pop     dx
            ret
    print_num       endp

    ;***************************************************************

    ; prints out a number in ax (not just a single digit)
    ; allowed values from 1 to 65535 (ffff)
    ; (result of /10000 should be the left digit or "0").
    ; modifies ax (after the procedure ax=0)
    print_numx      proc    near
            push    bx
            push    cx
            push    dx

            ; flag to prevent printing zeros before number:
            mov     cx, 1

            mov     bx, 10000       ; 2710h - divider.

            ; check if ax is zero, if zero go to end_show
            cmp     ax, 0
            jz      end_show

    begin_print:

            ; check divider (if zero go to end_show):
            cmp     bx,0
            jz      end_show

            ; avoid printing zeros before number:
            cmp     cx, 0
            je      calc
            ; if ax<bx then result of div will be zero:
            cmp     ax, bx
            jb      skip
    calc:
            xor     cx, cx  ; set flag.

            xor     dx, dx
            div     bx      ; ax = dx:ax / bx   (dx=remainder).

            ; print last digit
            ; ah is always zero, so it's ignored
            push    dx
            mov     dl, al
            add     dl, 30h    ; convert to ascii code.
            call    write_char
            pop     dx

            mov     ax, dx  ; get remainder from last div.

    skip:
            ; calculate bx=bx/10
            push    ax
            xor     dx, dx
            mov     ax, bx
            div     ten     ; ax = dx:ax / 10   (dx=remainder).
            mov     bx, ax
            pop     ax

            jmp     begin_print

    end_show:

            pop     dx
            pop     cx
            pop     bx
            ret
    print_numx      endp

    ;***************************************************************

    ; displays the message (dx-address)
    puts    proc    near
            push    ax
            mov     ah, 09h
            int     21h
            pop     ax
            ret
    puts    endp

    ;*******************************************************************

    ; reads char from the keyboard into al
    ; (modifies ax!!!)
    read_char       proc    near
            mov     ah, 01h
            int     21h
            ret
    read_char       endp

    ;***************************************************************

    ; gets the multi-digit signed number from the keyboard,
    ; result is stored in cx. backspace is not supported, for backspace
    ; enabled input function see c:\emu8086\inc\emu8086.inc
    ; scan_num        proc    near
    ;         push    dx
    ;         push    ax

    ;         xor     cx, cx

    ;         ; reset flag:
    ;         mov     make_minus, 0

    ; next_digit:

    ;         call    read_char

    ;         ; check for minus:
    ;         cmp     al, '-'
    ;         je      set_minus

    ;         ; check for enter key:
    ;         cmp     al, cr
    ;         je      stop_input

    ;         ; multiply cx by 10 (first time the result is zero)
    ;         push    ax
    ;         mov     ax, cx
    ;         mul     ten                     ; dx:ax = ax*10
    ;         mov     cx, ax
    ;         pop     ax

    ;         ; check if the number is too big
    ;         ; (result should be 16 bits)
    ;         cmp     dx, 0
    ;         jne     out_of_range

    ;         ; convert from ascii code:
    ;         sub     al, 30h

    ;         ; add al to cx:
    ;         xor     ah, ah
    ;         add     cx, ax
    ;         jc      out_of_range    ; jump if the number is too big.

    ;         jmp     next_digit

    ; set_minus:
    ;         mov     make_minus, 1
    ;         jmp     next_digit

    ; out_of_range:
    ;         lea     dx, error
    ;         call    puts

    ; stop_input:
    ;         ; check flag:
    ;         cmp     make_minus, 0
    ;         je      not_minus
    ;         neg     cx
    ; not_minus:

    ;         pop     ax
    ;         pop     dx
    ;         ret
    ; scan_num        endp

    ;***************************************************************

    ; prints out single char (ascii code should be in dl)
    write_char      proc    near
            push    ax
            mov     ah, 02h
            int     21h
            pop     ax
            ret
    write_char      endp

    ;***************************************************************

END MAIN