include 'emu8086.inc'
.MODEL SMALL


.DATA
    _n dw ?
    _n2 dw ?
    _2n2 dw ?
    _2n dw ?
    _i dw ?
    _j dw ?
    _ii dw ?
    _jj dw ?
    _kk dw ?
    _ratioa dw ?
    _ratiob dw ?
    _flag dw 1
    _sia dw ?
    _sib dw ?
    _m1 dw ?


.STACK
    stack_array dw 200h dup(0)

func_intro MACRO
        push	bp
        push cx
        push bx
        push dx
        push di
        push si
        mov	bp,sp
ENDM
func_outro MACRO
        pop	si
        pop	di
        pop dx
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

    get_a_index PROC
        func_intro
        push ax
        mov ax,[_i]
        mov cx,[_2n]
        mul cx
        add ax,[_j]
        mov cx,-2
        mul cx
        mov [_sia],ax
        pop ax
        func_outro
        ret
    get_a_index ENDP

    get_b_index PROC
        func_intro
        push ax
        mov ax,[_i]
        mov cx,[_2n]
        mul cx
        add ax,[_j]
        add ax,[_2n2]
        mov cx,-2
        mul cx
        mov [_sib],ax
        pop ax
        func_outro
        ret
    get_b_index ENDP




    solve PROC
        func_intro

        ini:
        mov ax,[_2n2]
        mov cx,2
        mul cx
        mov cx,ax
        loop_fill:
        mov ax,1
        push ax
        loop loop_fill


        get_matrix:
        mov [_i],0

        loop_i:
        mov [_j],0

        loop_j:
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        call get_num
        mov -2[bp][si],ax

        add [_j],1
        mov ax,[_n]
        cmp [_j],ax
        jl loop_j
        add [_i],1
        cmp [_i],ax
        jl loop_i



        chunk1:
        mov [_i],0

        loop_i_c1:
        mov [_j],0

        loop_j_c1:
        mov ax,[_j]
        cmp ax,[_i]
        je continue_c1
        add ax,[_n]
        mov [_j],ax
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        mov ax,0
        mov -2[bp][si],ax  ; a[i][j+n]=0
        continue_c1:
        add [_j],1
        mov ax,[_n]
        cmp [_j],ax
        jl loop_j_c1
        add [_i],1
        cmp [_i],ax
        jl loop_i_c1


        chunk2:
        mov [_ii],0

        loop_ii_c2:
        mov ax,[_ii]
        mov [_i],ax
        mov [_j],ax
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        mov ax,word ptr -2[bp][si]
        cmp ax,0
        jne not_done
        mov [_flag],0      ; a[i][j] == 0
        jmp delete_matrix
        not_done:
        mov [_jj],0

        loop_jj_c2:

        mov ax,[_ii]
        cmp ax,[_jj]
        je continue_c2
        mov bx,[_ii]
        mov cx,[_jj]

        mov [_i],cx
        mov [_j],bx
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        mov ax,word ptr -2[bp][si]  ; ax = a[j][i]


        mov [_i],bx
        mov [_j],bx
        call get_b_index
        mov dx,[_sib]
        mov si,dx
        mov dx,word ptr -2[bp][si]   ; dx = b[i][i]
        mul dx                       ; ax = a[j][i] * b[i][i]
        mov [_ratioa],ax

        mov ax,[_ratioa]


        mov [_i],bx
        mov [_j],bx
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        mov ax,word ptr -2[bp][si]   ; ax = a[i][i]

        mov [_i],cx
        mov [_j],bx
        call get_b_index
        mov dx,[_sib]
        mov si,dx
        mov dx,word ptr -2[bp][si]  ; dx = b[j][i]

        mul dx                      ; ax = a[i][i] * b[j][i]
        mov [_ratiob],ax


        mov [_kk],0

        loop_kk_c2:





        mov [_i],bx
        mov dx,[_kk]
        mov [_j],dx
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        mov ax,word ptr -2[bp][si]  ; ax = a[i][k]
        mov [_i],cx
        mov dx,[_kk]
        mov [_j],dx
        call get_b_index
        mov dx,[_sib]
        mov si,dx
        mov dx,word ptr -2[bp][si]  ; dx = b[j][k]
        mul dx                      ; ax = a[i][k] * b[j][k]
        mov dx,[_ratioa]
        mul dx                      ; ax = a[i][k] * b[j][k] * ratioa



        push ax


        mov [_i],cx
        mov dx,[_kk]
        mov [_j],dx
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        mov ax,word ptr -2[bp][si]  ; ax = a[j][k]
        mov dx,[_ratiob]
        mul dx                      ; ax = a[j][k] * ratiob
        mov [_i],bx
        mov dx,[_kk]
        mov [_j],dx
        call get_b_index
        mov dx,[_sib]
        mov si,dx
        mov dx,word ptr -2[bp][si]  ; dx = b[i][k]
        mul dx                      ; ax = a[j][k] * ratiob * b[i][k]

        pop dx
        sub ax,dx                   ; ax = a[j][k]*ratiob*b[i][k] - ratioa*a[i][k]*b[j][k];

        mov [_i],cx
        mov dx,[_kk]
        mov [_j],dx
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        mov -2[bp][si],ax         ; a[j][k] = ...




        mov [_i],cx
        mov dx,[_kk]
        mov [_j],dx
        call get_b_index
        mov dx,[_sib]
        mov si,dx
        mov ax,word ptr -2[bp][si]  ; ax = b[j][k]

        mov [_i],bx
        mov dx,[_kk]
        mov [_j],dx
        call get_b_index
        mov dx,[_sib]
        mov si,dx
        mov dx,word ptr -2[bp][si]  ; dx = b[i][k]

        mul dx                      ; ax = b[j][k] * b[i][k]
        mov dx,[_ratiob]


        mul dx                      ; ax = b[j][k] * b[i][k] * ratiob


        mov [_i],cx
        mov dx,[_kk]
        mov [_j],dx
        call get_b_index
        mov dx,[_sib]
        mov si,dx
        mov -2[bp][si],ax           ; b[j][k] = ....





        add [_kk],1
        mov ax,[_2n]
        cmp [_kk],ax
        jl loop_kk_c2
        continue_c2:
        add [_jj],1
        mov ax,[_n]
        cmp [_jj],ax
        jl loop_jj_c2

        add [_ii],1
        mov ax,[_n]
        cmp [_ii],ax
        jl loop_ii_c2


        chunk3:

        mov [_ii],0
        loop_ii_c3:
        mov ax,[_n]
        mov [_jj],ax
        loop_jj_c3:
        mov bx,[_ii]
        mov cx,[_jj]

        mov [_i],bx
        mov [_j],bx
        call get_b_index
        mov dx,[_sib]
        mov si,dx
        mov dx,word ptr -2[bp][si]  ; dx = b[i][i]

        mov [_i],bx
        mov [_j],cx
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        mov ax,word ptr -2[bp][si]  ; ax = a[i][j]
        mul dx
        mov -2[bp][si],ax           ; a[i][j] = ...

        mov [_i],bx
        mov [_j],bx
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        mov dx,word ptr -2[bp][si]  ; dx = a[i][i]

        mov [_i],bx
        mov [_j],cx
        call get_b_index
        mov dx,[_sib]
        mov si,dx
        mov ax,word ptr -2[bp][si]  ; ax = b[i][j]
        mul dx
        mov -2[bp][si],ax           ; b[i][j] = ...
        add [_jj],1
        mov ax,[_2n]
        cmp [_jj],ax
        jl loop_jj_c3
        add [_ii],1
        mov ax,[_n]
        cmp [_ii],ax
        jl loop_ii_c3









        print_matrix:
        printn ''
        mov ax,[_2n2]
        mov cx,2
        mul cx
        mov cx,ax
        mov dx,0
        mov si,dx
        loop_print_matrix:


        mov ax,word ptr -2[bp][si]
        call print_num
        sub si,2
        loop loop_print_matrix







        delete_matrix:
        mov ax,[_2n2]
        mov cx,2
        mul cx
        mov cx,ax
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

        lea sp,stack_array + 400h

        get_n:
        call get_num
        mov [_n], ax
        mul ax
        mov [_n2], ax
        add ax,ax
        mov [_2n2],ax
        mov ax,[_n]
        add ax,ax
        mov [_2n],ax


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
