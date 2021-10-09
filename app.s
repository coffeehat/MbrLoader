section header vstart=0
  program_length  dd program_end
  code_entry      dw start_
                  dd section.code.start

  realloc_tbl_len dw (header_end - code_segment) / 4

  code_segment    dd section.code.start
  data_segment    dd section.data.start
  stack_segment   dd section.stack.start
header_end:


section code align=16 vstart=0
start_:
  ; Initialize stack
  mov ax, [stack_segment]
  mov ss, ax
  mov sp, [stack_segment]
  add sp, stack_bottom
  inc sp

  ; Initialize data
  mov ax, [data_segment]
  mov ds, ax

  ; Initialize video buffer
  mov ax, 0xB800
  mov es, ax

  ; Clear screen
  call near clear_screen

  ; Print
  mov si, greetings
  xor di, di
  mov ah, 0x07
  call near print_string

  ; Loop current
  jmp near $

; Function clear screen
clear_screen:
  push ax
  push bx
  push cx
  push dx

  mov ax, 0x0600
  mov bx, 0x0700
  mov cx, 0x0000
  mov dx, 0x184f
  int 0x10

  pop ax
  pop bx
  pop cx
  pop dx
  ret

; Function print_string
; es as video buffer segment reg
; ds as data buffer segment reg
; di as video buffer offset
; si as string address
; ah as format string
print_string:
  push ax
  pushf
string_looper:
  cmp [ds:si], byte 0
  je string_looper_exit
  mov al, [ds:si]
  mov [es:di], al
  inc di
  mov [es:di], ah ; write format string
  inc di
  inc si
  jmp string_looper
string_looper_exit:
  popf
  pop ax
  ret

section data align=16 vstart=0
  greetings db "Greetings, my customers", 0x0A, 0

section stack align=16 vstart=0
  times 512 db 1
stack_bottom:

section tail align=16
program_end: