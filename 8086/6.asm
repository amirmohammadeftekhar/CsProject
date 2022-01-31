
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt
include 'emu8086.inc'
stackseg segment STACK 'STACK'
  db 100 dup (?)
stackseg ends
dataseg segment
  ans  dw 0
dataseg ends
segment codeseg
    
assume ss: stackseg, cs: codeseg, ds: dataseg
start:
  mov ax, dataseg
  mov ds, ax
  call scan_num
  mov dx, cx
  call pthis
  db 13, 10, 0
  call scan_num
  call pthis
  db 13, 10, 0
  xor bx, bx
  mov bl, dl
  mov bh, cl
  add bh, bl
  call cal
  mov ax, ans
  call print_num
  int 21h
    
    
cal:
  cmp bh, bl
  je ret1
  cmp bl, 0
  je ret1
  dec bh
  push ax
  push bx
  call cal
  pop bx
  pop ax
  dec bl
  push ax
  push bx
  call cal
  pop bx
  pop ax
  ret
  
ret1:
  add ans, 1
  ret
  
     
  
  
      
DEFINE_SCAN_NUM  
DEFINE_PRINT_STRING
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
DEFINE_PTHIS
ret
codeseg ends
end start



