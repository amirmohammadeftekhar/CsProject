.MODEL SMALL

.DATA
    welcome_message db 'Enter a string to evaluate!', 10, '$'
    return_message db 10, 13, 100 dup(0),'$'

.STACK
    stack_array dw 100h dup(0)    
                           

.CODE

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

    MAIN PROC
        mov ax,DATA
        mov ds,ax
        
        mov ax,STACK
        mov ss,ax
        
        lea sp,stack_array + 200h

        lea dx,return_message + 2
        mov di,dx
        call get_string        
        
        lea dx,return_message
        call puts
    
        EXIT:    
            mov ah,4ch
            int 21h
    
    MAIN ENDP


END MAIN
