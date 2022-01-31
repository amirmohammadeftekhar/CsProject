include 'emu8086.inc'

stackseg segment STACK 'STACK'
  db 100 dup(?)
stackseg ends

dataseg segment
  s db 100 dup(0)
  le db 0
  ri db 0
  sz db 0
dataseg ends  

codeseg segment
    
assume ss:stackseg, cs:codeseg, ds:dataseg

start:
mov ax, dataseg
mov ds, ax

call pthis
db 'enter input string: ',0

lea di,s
mov dx,100
call get_string

call pthis
db 13,10,0
; odd start
mov cx,0

lop:
  mov bh,0
  mov bl,0
  chk:
    inc bl
    mov di,cx
    add di,bx
    mov dl,s[di]
    
    mov di,cx
    sub di,bx   
    mov dh,s[di]
    
    cmp cx,bx
    jl pass_
    
    cmp dh,dl
    jz chk
  pass_:
  dec bx
  
  mov al,bl
  add al,bl
  inc al
  mov di,cx
  cmp sz,al
  jg pass
  
  mov sz,al
  mov le,cl
  sub le,bl
  mov ri,cl
  add ri,bl
  pass:
  
  inc cx
  mov di,cx
  mov dl,s[di]
  cmp dl,0
  jne lop
; odd end
; even start
mov cx,0

lop2:
  mov bh,0
  mov bl,-1
  chk2:
    inc bl
    mov di,cx
    add di,bx
    add di,1
    mov dl,s[di]
    
    mov di,cx
    sub di,bx   
    mov dh,s[di]
    
    cmp cx,bx
    jl pass_2
    
    cmp dh,dl
    jz chk2
  pass_2:
  dec bx
  
  mov al,bl
  add al,bl
  add al,2
  mov di,cx
  cmp sz,al
  jg pass2
  
  mov sz,al
  mov le,cl
  sub le,bl
  mov ri,cl
  add ri,bl
  add ri,1
  pass2:  
  inc cx
  mov di,cx
  add di,1
  mov dl,s[di]
  cmp dl,0
  jne lop2

call pthis
db 'left index: ',0

mov ax,0
mov al,le
call print_num   
call pthis
db ' right index: ',0
mov al,ri
call print_num
call pthis
db 13,10,0

mov ah,4CH  ; DOS: terminate program
mov al,0    ; return code will be 0
int 21H     ; terminate the program 

DEFINE_SCAN_NUM; get number in cx
DEFINE_PRINT_NUM; print number in ax
DEFINE_PRINT_NUM_UNS
DEFINE_PRINT_STRING;address in si
DEFINE_GET_STRING;address in di , size dx
DEFINE_PTHIS; call pthis; db 13,10,0

codeseg ends
end start


