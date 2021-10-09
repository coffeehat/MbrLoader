; Memory layout
; FFFFF (inclusive) -----
;           ROM-BIOS
; F0000 -----------------
;         Device-Mapping
; A0000 -----------------
;         Memory for
;          Kernel
; 10000 -----------------
;         Memory for
;          Mbr loader
; 07c00-> Mbr load addr/entry
; 00000 -----------------

os_lba       EQU 100d
os_load_addr EQU 0x10000

section mbr_loader vstart=0x7c00
  ; set stack
  xor ax, ax
  mov ss, ax
  mov sp, ax

  ; set data
  mov ax, cs
  mov ds, ax

  ; set data segment (the memory space to save the loaded program)
  mov ax, [cs:program_load_addr]
  mov dx, [cs:program_load_addr + 0x02]
  mov bx, 0x10
  div bx
  mov es, ax
  mov di, dx ; assign in-segment offset

  ; load os from disk to memory
  mov cl, 1
  mov bx, program_lba_addr
  call disk.read_blocks_from_master

  ; parse location header
  mov bx, di
  call header.read_length
  mov bx, 512
  div bx
  ; now ax saves the quotient, which is the number of blocks need to be read from disk

  ; calculate the remaining blocks needed to be loaded
  cmp dx, 0x00
  jnz @1
  dec ax

@1:
  cmp ax, 0x00
  jz @2

  ; load the remaining blocks
  mov bx, program_lba_addr
  mov cl, 1
  mov si, ax

  push es
loop:
  ; update memory loc
  mov ax, es
  add ax, 512 / 16
  mov es, ax

  ; update lba loc
  add word [cs:program_lba_addr], 1
  adc word [cs:program_lba_addr + 2], 0

  ; read block
  call disk.read_blocks_from_master

  ; loop
  dec si
  jnz loop

  pop es
@2:
  ; now the program is loaded at es:di
  ; we need to handle the relocate table

  ; relocate entry
  mov bx, di
  call header.read_entry_addr
  call calc_relocated_addr
  mov cx, ax
  call header.read_entry_offset
  add ax, cx
  ; TODO: overflow judgement
  call header.write_entry_addr

  call header.read_relocate_table_size
  mov cx, ax
loop2:
  mov si, cx
  dec si
  call header.read_relocate_table_item
  call calc_relocated_addr
  mov di, si
  call header.write_relocate_table_item
  loop loop2

  call header.get_addr_of_entry_addr

  ; restore ds register
  mov ax, es
  mov ds, ax

  jmp far [es:bx]
  
; calculate reloated address
; params in
;   dx,ax - program inner offset addr relative to program header
; params out
;   dx,ax - segment addr and offset
calc_relocated_addr:
  push bx
  add ax, [cs:program_load_addr]
  adc dx, [cs:program_load_addr + 2]
  
  mov bx, 0x10
  div bx

  xchg ax, dx

  pop bx
  ret

  ; procedures for disk io
  %include "disk.s"

  ; procedures for parsing relocateble executable header
  %include "header.s"


  ; program lba addr
  program_lba_addr  dd os_lba
  program_load_addr dd os_load_addr

  times 510 - ($ - $$) db 0

  db 0x55, 0xAA