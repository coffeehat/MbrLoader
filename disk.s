%ifndef __DISK_S__
%define __DISK_S__

; read disk (io)
; description:
; Disk io port contains regs at addr 0x1f0-0x1f7
; In which:
disk_data_port              equ 0x1f0  ; 16 data io reg
disk_error_port             equ 0x1f1  ; 8  data error reg
disk_num_block_port         equ 0x1f2  ; 8  number of blocks
disk_addr_port_0_7          equ 0x1f3  ; 8  block addr 0-7
disk_addr_port_8_15         equ 0x1f4  ; 8  block addr 8-15
disk_addr_port_16_23        equ 0x1f5  ; 8  block addr 16-23
disk_addr_port_24_27_format equ 0x1f6  ; 8  block addr 24-27 and addr format
disk_command_port           equ 0x1f7  ; 8  block addr

; TODO: Add a reg to select a disk
; parameters
; cl - number of blocks to read
; bx - base addr to the memory where save the block addr (lba 28 bits)
; ds - segment of block addr
; di - base addr to the memory where to save the readed results
; es - segment of memory to write
disk.read_blocks_from_master:
  push ax
  push cx
  push dx
  push di

  ; Write number of blocks to read
  mov al, cl
  mov dx, disk_num_block_port
  out dx, al

  ; Write head block address
  mov al, [ds:bx]
  mov dx, disk_addr_port_0_7
  out dx, al

  mov al, [ds:bx+1]
  mov dx, disk_addr_port_8_15
  out dx, al

  mov al, [ds:bx+2]
  mov dx, disk_addr_port_16_23
  out dx, al

  ; Write the last head block address, and the addr format
  mov al, [ds:bx+3]
  and al, 0x0F
  or  al, 0xE0  ; Use LBA addr, read master disk
  mov dx, disk_addr_port_24_27_format
  out dx, al

  ; Send read command
  mov al, 0x20
  mov dx, disk_command_port
  out dx, al

  ; Waiting for io
.wait:
  in al, dx
  test al, 0x80
  jnz .wait

  ; Read io data
  mov ch, cl   ; mul cl by 256
  xor cl, cl
  mov dx, disk_data_port
.read:
  in  ax, dx
  mov [es:di], ax
  add di, 2
  loop .read

  pop di
  pop dx
  pop cx
  pop ax
  ret

%endif ; __DISK_S__