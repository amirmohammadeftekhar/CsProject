.MODEL SMALL
.MODEL SMALL

include 'emu8086.inc'


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




    _solve PROC
        func_intro
        dec	sp
        dec	sp
        mov	ax,4[bp]
        inc	ax
        mov	-6[bp],ax
        jmp loop_condition_1
        preprocess:
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
        jg first_condition_check
        make_positive:
        mov	ax,[_tmp1]
        mov	cx,-1
        imul	cx
        mov	[_tmp1],ax
        first_condition_check:
        mov	ax,[_tmp1]
        test	ax,ax
        jne second_condition_check
        inc	sp
        inc	sp
        func_outro
        ret
        second_condition_check:
        mov	ax,[_tmp1]
        cmp	ax,[_tmp2]
        jne i_update_1
        inc	sp
        inc	sp
        func_outro
        ret
        i_update_1:
        mov	ax,-6[bp]
        inc	ax
        mov	-6[bp],ax
        loop_condition_1:
        mov	ax,-6[bp]
        cmp	ax,[_n]
        jl preprocess
        check_t_is_0:
        mov	ax,4[bp]
        test	ax,ax
        jne calling_functions
        catching_a_result:
        mov	ax,[_rt]
        inc	ax
        mov	[_rt],ax
        inc	sp
        inc	sp
        func_outro
        ret
        calling_functions:
        xor	ax,ax
        mov	-6[bp],ax
        jmp loop_condition_2
        body_loop_2:
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
        i_update_2:
        mov	ax,-6[bp]
        inc	ax
        mov	-6[bp],ax
        loop_condition_2:
        mov	ax,-6[bp]
        cmp	ax,[_n]
        jl body_loop_2
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

        call scan_num
        mov al, cl
        cbw
        mov [_n],ax

        push [_n]
        call _solve

        mov ax,[_rt]
        call print_num




        EXIT:
            mov ah,4ch
            int 21h

    MAIN ENDP

    DEFINE_SCAN_NUM
    DEFINE_PRINT_NUM

    DEFINE_PRINT_NUM_UNS
    DEFINE_CLEAR_SCREEN



END MAIN
