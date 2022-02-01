
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

include 'emu8086.inc'


stackseg segment STACK 'STACK'
    
stackseg ends



dataseg segment
    xs db 100 dup (?)
    ys db 100 dup (?)
    labels db 100 dup (?)
    n db ?
    best_err db 0
    best_ans db 0
    cur_ans db 0
    pivot db ?    
dataseg ends


codeseg segment
    assume cs: codeseg, ds: dataseg, ss: stackseg
    
start:
    mov ax, dataseg
    mov ds, ax
    
    call scan_num
    mov n, cl
    
    call pthis
    db 13, 10, 0
    
    push bx
    mov bx, 0
    call get_array
    pop bx
    
    
    push bx
    mov bl, n
    mov best_ans, bl
    mov bx, 0
    call solve1
    
    
    
    mov AH,4cH
    mov AL, 0
    int 21H 
    
    

get_array:
    cmp bl, n
    jne get_num
    ret
     
get_num:
    call scan_num
    call pthis
    db 13, 10, 0
    mov  xs [bx], cl
    call scan_num
    call pthis
    db 13, 10, 0
    mov  ys [bx], cl
    call scan_num
    call pthis
    db 13, 10, 0
    mov  labels [bx], cl
    inc bx
    call get_array
    
    
solve1:
    cmp bx, n
    jne csolve1
    ret 
    
csolve1:
    push ax
    push cx
    mov cx, 0
    mov cur_ans, 0
    mov al, xs [bx]
loop1:
    cmp cx, n
    jne calc
    push bx
    mov bl, cur_ans
    cmp bl, best_err
    jl update
    pop bx
    pop cx
    pop ax
    inc bx
    call solve1
    ret
update:
    mov best_err, bl
    pop bx
    pop cx
    pop ax
    mov best_ans, bl
    inc bx
    call solve1
    ret
    
calc:
    cmp al, xs [cx]
    jl case1
    
case1:
    push dx
    mov dx, labels [cx]
    
    
    
    
    
    
       
    





DEFINE_SCAN_NUM
DEFINE_PRINT_STRING
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS 
DEFINE_PTHIS
ret
codeseg ends
end start






