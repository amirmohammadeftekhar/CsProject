include 'emu8086.inc'
.MODEL SMALL

precision = 30

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
    ten             dw      10


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

    print_float     proc    near
        push    cx
        push    dx

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
        mov     cx, precision
        call    print_fraction
done:
        pop     dx
        pop     cx
        ret
print_float     endp

write_char      proc    near
        push    ax
        mov     ah, 02h
        int     21h
        pop     ax
        ret
write_char      endp




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
        printn 'No Answer'
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
        push dx

        mov [_i],bx
        mov [_j],cx
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        mov ax,word ptr -2[bp][si]  ; ax = a[i][j]
        pop dx
        mul dx
        mov -2[bp][si],ax           ; a[i][j] = ...

        mov [_i],bx
        mov [_j],bx
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        mov dx,word ptr -2[bp][si]  ; dx = a[i][i]
        push dx

        mov [_i],bx
        mov [_j],cx
        call get_b_index
        mov dx,[_sib]
        mov si,dx
        mov ax,word ptr -2[bp][si]  ; ax = b[i][j]
        pop dx
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
        mov [_i],0

        loop_i_print:
        mov ax,[_n]
        mov [_j],ax

        loop_j_print:
        call get_a_index
        mov dx,[_sia]
        mov si,dx
        mov ax,word ptr -2[bp][si]
        call get_b_index
        mov dx,[_sib]
        mov si,dx
        mov bx,word ptr -2[bp][si]
        cwd
        idiv bx
        printn ''
        call print_float


        add [_j],1
        mov ax,[_2n]
        cmp [_j],ax
        jl loop_j_print
        mov ax,[_n]
        add [_i],1
        cmp [_i],ax
        jl loop_i_print







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
