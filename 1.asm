include 'emu8086.inc'
.MODEL SMALL


.DATA
    _n dw ?
    _n2 dw ?
    _n2n2 dw ?
    _nn dw ?
    _m1 dw ?


.STACK
    stack_array dw 100h dup(0)

func_intro MACRO
        push	bp
        push cx
        push bx
        push di
        push si
        mov	bp,sp
ENDM
func_outro MACRO
        pop	si
        pop	di
        pop bx
        pop cx
        pop	bp
ENDM


.CODE
    get_num PROC
        func_intro
        printn ''
        call scan_num
        mov al, cl
        cbw
        func_outro
        ret
    get_num ENDP



    solve PROC
        func_intro

        get_matrix:
        mov cx,[_n2]

        mov [_m1],sp


        loop_get_matrix:
        call get_num
        push ax
        loop loop_get_matrix

        mov cx,[_n2]
        mov dx,0
        mov si,dx
        loop_print_matrix:
        mov ax,word ptr -2[bp][si]
        call print_num
        sub si,2
        loop loop_print_matrix

        delete_matrix:
        mov cx,[_n2]
        loop_delete_matrix:
        pop ax
        loop loop_delete_matrix


        func_outro

        ret
    solve endp

    MAIN PROC
        mov ax,DATA
        mov ds,ax

        mov ax,STACK
        mov ss,ax

        lea sp,stack_array + 200h

        get_n:
        call get_num
        mov [_n], ax
        mul ax
        mov [_n2], ax
        add ax,ax
        mov [_n2n2],ax
        mov ax,[_n]
        add ax,ax
        mov [_nn],ax


        main_label:
        call solve




        EXIT:
            mov ah,4ch
            int 21h

    MAIN ENDP

    DEFINE_SCAN_NUM
    DEFINE_PRINT_NUM

    DEFINE_PRINT_NUM_UNS
    DEFINE_CLEAR_SCREEN


END MAIN

