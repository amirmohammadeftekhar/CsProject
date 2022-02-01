include 'emu8086.inc'

stackseg segment STACK 'STACK'
  db 100 dup(?)
stackseg ends

dataseg segment
  a db 100 dup(0)
  b db 100 dup(0)
  x db 100 dup(0)
  ans db 100 dup(0)
  cnt db 0
  sza db 0
dataseg ends  

codeseg segment
    
assume ss:stackseg, cs:codeseg, ds:dataseg

start:
mov ax, dataseg
mov ds, ax

call pthis
db 'input string x: ',0
mov dx,100
lea di,x
call get_string
call pthis
db 13,10,0

call pthis
db 'input string a: ',0
mov dx,100
lea di,a
call get_string
call pthis
db 13,10,0

call pthis
db 'input string b: ',0
mov dx,100
lea di,b
call get_string
call pthis
db 13,10,0

mov dx,32
mov di,0
lop_x:
  mov cl,x[di]
  mov ch,91
  cmp cl,ch
  jge dont_x
  add cl,dl
  mov x[di],cl
  dont_x:
  inc di
  mov cl,x[di]
  cmp cl,0
  jnz lop_x
  
mov dx,32
mov di,0
lop_a:
  mov cl,a[di]
  mov ch,91
  cmp cl,ch
  jge dont_a
  add cl,dl
  mov a[di],cl
  dont_a:
  inc di
  mov cl,a[di]
  cmp cl,0
  jnz lop_a

mov dx,32
mov di,0
lop_b:
  mov cl,b[di]
  mov ch,91
  cmp cl,ch
  jge dont_b
  add cl,dl
  mov b[di],cl
  dont_b:
  inc di
  mov cl,b[di]
  cmp cl,0
  jnz lop_b

mov di,0
lop1:
  call check
  jnz pass1
  add cnt,1
  pass1:
  inc di
  mov cl,x[di]
  cmp cl,0
  jnz lop1

lea di,a
call length
mov sza,bl

mov ah,0
mov al,cnt
call pthis
db 'count of a in x as a substring: ',0
call print_num
call pthis
db 13,10,0

cmp ax,0
jz finish


mov di,0
mov ax,0
lop2:
  call check
  jnz pass2
  mov si,0
  insert:
    mov bx,ax
    mov dl,b[si]
    mov ans[bx],dl
    inc ax
    inc si
    mov dl,b[si]
    cmp dl,0
    jnz insert
  mov dl,sza
  mov dh,0 
  add di,dx
  mov cl,x[di]
  cmp cl,0
  jnz lop2
  pass2:
  mov dl,x[di]
  mov bx,ax
  mov ans[bx],dl
  inc ax
  inc di
  mov cl,x[di]
  cmp cl,0
  jnz lop2

call pthis
db 'replaced string: ',0
lea si,ans
call print_string

call pthis
db 13,10,0



finish:
mov ah,4CH  ; DOS: terminate program
mov al,0    ; return code will be 0
int 21H     


check proc ; check equality of x starting from index di and a -- uses cx,bx -- if equal call jz after else call jnz
mov bx,0
lop_check:
  mov cl,x[di+bx]
  mov ch,a[bx]
  cmp cl,ch
  jz pass_check
  mov cl,0
  cmp cl,1
  ret 
  pass_check:
    inc bx
    mov cl,a[bx]
    cmp cl,0
    jnz lop_check
mov cl,0
cmp cl,0
ret
check endp

length proc ; put first index after memory location di which contains 0 and put in bx
mov bx,0
length_check:
  mov cl,[di+bx]
  cmp cl,0
  jz length_after
  inc bx
  jmp length_check 
length_after:
ret
length endp


DEFINE_SCAN_NUM; get number in cx
DEFINE_PRINT_NUM; print number in ax
DEFINE_PRINT_NUM_UNS
DEFINE_PRINT_STRING;address in si
DEFINE_GET_STRING;address in di , size dx
DEFINE_PTHIS; call pthis; db 13,10,0

codeseg ends
end start


