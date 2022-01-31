.DATA
    enter_x_message db 'Enter first the number X: ', '$'
    enter_b_message db 10,13,'Enter base of X:', '$'
    enter_a_message db 10,13,'Enter the base of transformation: ', '$'
    base_error_message db 10, 13, 'Bases should be from 2 to 16', '$'
    overflow_message db 10, 13, 'There was an overflow!', '$'
    nvalid_message db 10, 13, 'The X is invalid!', '$'
    divide_by_zero_message db 10, 13, 'Divide by zero!', '$'
    big_number_message db 10, 13, 'The number is bigger than a word!', '$'
    return_message db 10, 13, 'Result: $' 
    make_minus  db ?
    ten dw 10
    base_a dw ?
    base_b dw ?
    num_str db 50 dup(?), '$'
.STACK
    stack_array dw 100h dup(0)


.CODE    

    putc    macro   char
            push    ax
            mov     al, char
            mov     ah, 0eh
            int     10h     
            pop     ax
    endm

    MAIN PROC
        mov ax,DATA
        mov ds,ax

        mov ax,STACK
        mov ss,ax

        lea sp,stack_array + 200h

        ; input
        lea dx, enter_x_message
        call puts
        PUTC ' '
        lea dx, num_str
        mov di, dx
        call get_string

        ; input
        lea dx, enter_b_message
        call puts
        PUTC ' '
        call scan_num
        mov base_b, cx
        cmp cx, 2
        jl EXIT_BASE_ERROR 
        cmp cx, 16
        jg EXIT_BASE_ERROR       

        ; input
        lea dx, enter_a_message
        call puts
        PUTC ' '
        call scan_num
        mov base_a, cx 
        cmp cx, 2
        jl EXIT_BASE_ERROR 
        cmp cx, 16
        jg EXIT_BASE_ERROR       


        ; output message
        mov ax, base_b
        mov ten, ax
        lea di, num_str
        call scan_num_from_str
        
        mov ax, base_a
        mov ten, ax
        mov ax, cx

        lea dx, return_message
        call puts
        call print_num        
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

        EXIT_BASE_ERROR:
        lea dx, base_error_message
        call puts
        jmp EXIT

        EXIT_BIG_NUMBER:
        lea dx, big_number_message
        call puts
        jmp EXIT

        EXIT:    
        mov ah,4ch
        int 21h
    MAIN ENDP


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; these are utility functions                 ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;    
    from_ascii PROC
        cmp al, '0'
        jl NOT_NUMBER
        cmp al, '9'
        jg NOT_NUMBER
        sub al, '0'
        ret
        NOT_NUMBER:

        cmp al, 'a'
        jl NOT_SMALL
        cmp al, 'f'
        jg NOT_SMALL
        sub al, 'a'
        add al, 10
        ret
        NOT_SMALL:

        cmp al, 'A'
        jl NOT_CAP
        cmp al, 'Z'
        jg NOT_CAP
        sub al, 'A'
        add al, 10
        ret
        NOT_CAP:
        jmp EXIT_NVALID
        ret
    from_ascii ENDP

    to_ascii PROC
        cmp al, 0
        jl _NOT_NUMBER
        cmp al, 9
        jg _NOT_NUMBER
        add al, '0'
        ret
        _NOT_NUMBER:

        cmp al, 15
        jg _NOT_SMALL
        add al, 'A'
        sub al, 10
        ret
        _NOT_SMALL:

        jmp EXIT_NVALID
        ret
    to_ascii ENDP    

    get_string PROC; delimiter is '\n'  writes the result in [di], changes di
        push ax
        LOOP_GET_STRING:
        call read_char
        mov byte ptr di, al
        inc di
        cmp al, 0dh
        je END_LOOP_GET_STRING
        jmp LOOP_GET_STRING
        END_LOOP_GET_STRING:
        pop ax
        ret
    get_string ENDP

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
            mov     bx, 1

            push ax
            push dx
            push cx
            xchg ax, bx
            MULTIPLY_MORE:
            mul ten
            jo EXIT_MULTIPLY
            cmp dx, 0
            jnz EXIT_MULTIPLY
            cmp ax, bx
            jg EXIT_MULTIPLY
            mov cx, ax
            jmp MULTIPLY_MORE
            EXIT_MULTIPLY:
            mov bx, cx
            pop cx
            pop dx            
            pop ax

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

            xchg    al, dl
            call    to_ascii
            xchg    al, dl

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
    scan_num_from_str        proc    near
            push    dx
            push    ax

            xor     cx, cx

            ; reset flag:
            mov     make_minus, 0

    next_digit:

            mov al, byte ptr di
            inc di
            ; check for minus:
            cmp     al, '-'
            je      set_minus

            ; check for enter key:
            cmp     al, 0Dh
            je      stop_input

            ; multiply cx by 10 (first time the result is zero)
            push    ax
            mov     ax, cx
            mul     ten                     ; dx:ax = ax*10
            mov     cx, ax
            pop     ax

            ; check if the number is too big
            ; (result should be 16 bits)
            cmp     dx, 0
            jne     EXIT_BIG_NUMBER

            ; convert from ascii code:
            call from_ascii

            ; add al to cx:
            xor     ah, ah
            add     cx, ax
            jc      EXIT_BIG_NUMBER    ; jump if the number is too big.

            jmp     next_digit

    set_minus:
            mov     make_minus, 1
            jmp     next_digit

    out_of_range:
            jmp EXIT_BIG_NUMBER
    stop_input:
            ; check flag:
            cmp     make_minus, 0
            je      not_minus
            neg     cx
    not_minus:

            pop     ax
            pop     dx
            ret
    scan_num_from_str        endp

    ; ***************************************************************

    ; gets the multi-digit signed number from the keyboard,
    ; result is stored in cx. backspace is not supported, for backspace
    ; enabled input function see c:\emu8086\inc\emu8086.inc
    scan_num        proc    near
            push    dx
            push    ax

            xor     cx, cx

            ; reset flag:
            mov     make_minus, 0

    f_next_digit:

            call    read_char

            ; check for minus:
            cmp     al, '-'
            je      f_set_minus

            ; check for enter key:
            cmp     al, 0Dh
            je      f_stop_input

            ; multiply cx by 10 (first time the result is zero)
            push    ax
            mov     ax, cx
            mul     ten                     ; dx:ax = ax*10
            mov     cx, ax
            pop     ax

            ; check if the number is too big
            ; (result should be 16 bits)
            cmp     dx, 0
            jne     EXIT_BIG_NUMBER

            ; convert from ascii code:
            call    from_ascii

            ; add al to cx:
            xor     ah, ah
            add     cx, ax
            jc      EXIT_BIG_NUMBER    ; jump if the number is too big.

            jmp     f_next_digit

    f_set_minus:
            mov     make_minus, 1
            jmp     f_next_digit

    f_stop_input:
            ; check flag:
            cmp     make_minus, 0
            je      f_not_minus
            neg     cx
    f_not_minus:

            pop     ax
            pop     dx
            ret
    scan_num        endp

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