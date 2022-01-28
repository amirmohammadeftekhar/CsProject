

.DATA
    welcome_message db 'Enter a string to evaluate!', 10, '$'
    return_message db 10, 13, 'Result =                 $' 
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
        cmp al, P_OPEN
        jne END_IF_1_READ_CR
        call read_blank
        call read_expr
        cmp al, P_CLOSE
        jne EXIT_NVALID
        call read_blank
        ret
        END_IF_1_READ_CR:
        al_to_int END_IF_2_READ_CR
        call read_number
        ret
        END_IF_2_READ_CR:        
        jmp EXIT_NVALID
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

        call read_blank
        call read_expr
        cmp al,ENTER
        jne EXIT_NVALID
        jmp EXIT
        ; lea dx,return_message + 2
        ; mov di,dx
        ; call get_string        
        
        ; lea dx,return_message
        ; call puts
    
        EXIT_OVERFLOW:
        jmp EXIT

        EXIT_NVALID:
        jmp EXIT

        EXIT:    
        mov ah,4ch
        int 21h

    MAIN ENDP


END MAIN