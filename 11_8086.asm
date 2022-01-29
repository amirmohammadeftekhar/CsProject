include 'emu8086.inc'

org 100h      
lea di,s
mov dx,200
call get_string

call pthis
db 13,10,0

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
    
    cmp dh,dl
    je chk
  ;dec bx
  
  mov ax,bx
  call print_num
  call pthis
  db 13,10,0
  
  mov ax,bx
  add ax,bx
  inc ax
  mov di,cx
  cmp sz,al
  jp pass
  
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

mov ax,0
mov al,le
call print_num   
call pthis
db ' ',0
mov al,ri
call print_num
call pthis
db 13,10,0    
    
               
ret
s db 200dup(0)        
n db 0
le db 0
ri db 0
sz db 0


DEFINE_SCAN_NUM; get number in cx
DEFINE_PRINT_NUM; print number in ax
DEFINE_PRINT_NUM_UNS
DEFINE_PRINT_STRING;address in si
DEFINE_GET_STRING;address in di , size dx
DEFINE_PTHIS; call pthis; db 13,10,0
end




