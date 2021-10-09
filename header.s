%ifndef __HEADER_S__
%define __HEADER_S__

; methods for read header info of relocateble executable


; read program length
; 
; input parameters:
; es - segment who contains header
; bx - header offset
; 
; returns
; dx:ax - the length of the program read from header
header.read_length:
  mov ax, [es:bx+0x00]
  mov dx, [es:bx+0x02]
  ret


; read program entry offset
; 
; input parameters
; es - segment who contains header
; bx - header offset
; 
; returns
; ax - the in-segment offset entry of the program
header.read_entry_offset:
  mov ax, [es:bx+0x04]
  ret

; read full in-program addr of entry
;
; input parameters
; es - segment who contains header
; bx - header offset
; 
; returns
; dx:ax, the in-program addr
header.read_entry_addr:
  mov ax, [es:bx+0x06]
  mov dx, [es:bx+0x08]
  ret

; write full in-program addr of entry
;
; input parameters
; es - segment who contains header
; bx - header offset
; dx:ax - segment addr:offset
; 
;
; return none
header.write_entry_addr:
  mov [es:bx+0x06], ax
  mov [es:bx+0x08], dx
  ret

; get full in-program addr of entry
;
; input parameters
; es - segment who contains header
; bx - header offset
;
; returns
; es, the segment of entry addr
; bx, the addr of entry addr
header.get_addr_of_entry_addr:
  lea bx, [es:bx+0x06]
  ret

; read number of items in relocate table
;
; input parameters
; es - segment who contains header
; bx - header offset
; 
; returns
; ax, the number of items in relocate table
header.read_relocate_table_size:
  mov ax, [es:bx+0x0A]
  ret

; read number of items in relocate table
;
; input parameters
; es - segment who contains header
; bx - header offset
; si - item index
; 
; returns
; dx:ax, the in-program addr
header.read_relocate_table_item:
  push si
  shl si, 2
  mov ax, [es:bx+si+0x0C]
  mov dx, [es:bx+si+0x0E]
  pop si
  ret

; write full in-program addr of relocate table item
;
; input parameters
; es - segment who contains header
; bx - header offset
; dx:ax - segment addr:offset
; di - item index
; 
;
; return none
header.write_relocate_table_item:
  push di
  shl di, 2
  mov [es:bx+di+0x0C], dx
  ; mov [es:bx+di+0x0E], dx
  pop di
  ret


%endif ; __HEADER_S__