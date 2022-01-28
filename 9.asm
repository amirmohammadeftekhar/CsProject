.MODEL SMALL

.DATA
    CR EQU 13
    LF EQU 10
    inBuf Label BYTE
    Bsize DB 100
    Rsize DB ?
    inStr DB 100 DUP(0)

    _n  DW 4
    _rt DW 0
    _tmp1 DW ?
    _tmp2 DW ?
    _cells DW 100 DUP(-1)

.STACK
    stack_array dw 100h dup(0)

func_intro MACRO
        push	bp
        mov	bp,sp
        push	di
        push	si
ENDM
func_outro MACRO
        pop	si
        pop	di
        pop	bp
ENDM

.CODE

    input PROC
        func_intro
        lea dx,inBuf
        mov ah,0AH
        int 21h
        lea bx,inStr
        mov cl,Rsize
        sub ch,ch
        mov si,cx
        mov byte ptr[bx+si],'$'
        func_outro
        ret
    input ENDP

    new_line PROC
        func_intro
        mov dl,CR
        mov ah,02
        int 21h
        mov dl,LF
        mov ah,02
        int 21H
        func_outro
        ret
    new_line ENDP

    output PROC
        func_intro
        call new_line
        lea dx,si
        mov ah,09
        int 21h
        func_outro
        ret



    input_num PROC
        func_intro
        xor bx,bx
        loop:
        lodsb
        cmp al,'0'
        jb noascii
        cmp al,'9'
        ja noascii
        sub al,30h
        cbw
        push ax
        mov ax,bx
        mov cx,10
        mul cx
        mov bx,ax
        pop ax
        add bx,ax
        jmp loop
        noascii:
        func_outro
        ret

    input_num ENDP

    output_num PROC
        func_intro
        call new_line
        mov cx, 0
        mov bx, 10
        mov	ax,4[bp]
        loophere:
        mov dx, 0
        div bx
        push ax
        add dl, '0'
        pop ax
        push dx
        inc cx
        cmp ax, 0
        jnz loophere
        mov ah, 2
        loophere2:
        pop dx
        int 21h
        loop loophere2
        func_outro
        ret
    output_num ENDP



    _solve PROC
        func_intro
        dec	sp
        dec	sp
        mov	ax,4[bp]
        inc	ax
        mov	-6[bp],ax
        jmp .3
        .4:
        mov	bx,4[bp]
        shl	bx,1
        mov	si,-6[bp]
        shl	si,1
        mov	ax,_cells[si]
        sub	ax,_cells[bx]
        mov	[_tmp1],ax
        mov	ax,-6[bp]
        sub	ax,4[bp]
        mov	[_tmp2],ax
        mov	ax,[_tmp1]
        test	ax,ax
        jg .5
        .6:
        mov	ax,[_tmp1]
        mov	cx,-1
        imul	cx
        mov	[_tmp1],ax
        .5:
        mov	ax,[_tmp1]
        test	ax,ax
        jne .7
        .8:
        inc	sp
        inc	sp
        func_outro
        ret
        .7:
        mov	ax,[_tmp1]
        cmp	ax,[_tmp2]
        jne .9
        .A:
        inc	sp
        inc	sp
        func_outro
        ret
        .9:
        mov	ax,-6[bp]
        inc	ax
        mov	-6[bp],ax
        .3:
        mov	ax,-6[bp]
        cmp	ax,[_n]
        jl .4
        .1:
        mov	ax,4[bp]
        test	ax,ax
        jne .C
        .D:
        mov	ax,[_rt]
        inc	ax
        mov	[_rt],ax
        inc	sp
        inc	sp
        func_outro
        ret
        .C:
        xor	ax,ax
        mov	-6[bp],ax
        jmp .10
        .11:
        mov	ax,4[bp]
        dec	ax
        shl	ax,1
        mov	bx,ax
        mov	ax,-6[bp]
        mov	_cells[bx],ax
        mov	ax,4[bp]
        dec	ax
        push	ax
        call	_solve
        inc	sp
        inc	sp
        .F:
        mov	ax,-6[bp]
        inc	ax
        mov	-6[bp],ax
        .10:
        mov	ax,-6[bp]
        cmp	ax,[_n]
        jl .11
        .E:
        inc	sp
        inc	sp
        func_outro
        ret





    _solve ENDP



    MAIN PROC
        mov ax,DATA
        mov ds,ax

        mov ax,STACK
        mov ss,ax

        lea sp,stack_array + 200h
        push bp

        push [_n]
        call _solve
        push [_rt]
        call output_num




        EXIT:
            mov ah,4ch
            int 21h

    MAIN ENDP


END MAIN

