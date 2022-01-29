include 'emu8086.inc'

org 100h      
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
  
  ;mov ax,bx
  ;call print_num
  ;call pthis
  ;db 13,10,0
  
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
  
  ;mov ax,bx
  ;call print_num
  ;call pthis
  ;db 13,10,0
  
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

;mov ax,0
;mov al,sz
;call print_num   
;call pthis
;db 13,10,0
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
        
n db 0
le db 0
ri db 0
sz db 0
s db 100dup(0)

DEFINE_SCAN_NUM; get number in cx
DEFINE_PRINT_NUM; print number in ax
DEFINE_PRINT_NUM_UNS
DEFINE_PRINT_STRING;address in si
DEFINE_GET_STRING;address in di , size dx
DEFINE_PTHIS; call pthis; db 13,10,0
end




