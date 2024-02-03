[bits 16]
[org 0x7c00]

CODE_SELECTOR equ 0x08
DATA_SELECTOR equ 0x10


main:
  xor ax, ax
  mov ds, ax
  cld
  mov ah, 2
  mov al, SECTORS_PREKERNEL ; needs to be SECTORS_PREKERNEL
  xor ch, ch
  xor cl, cl
  xor dh, dh
  mov dl, 0x80
  xor es, es
  mov bx, 0x1000
  int 0x13
  jc disk_error
  
  mov sp, 0x7c00
  mov bp, sp ; first stack setup
  call memory_map

  lgdt [gdt_descriptor]
  mov eax, cr0
  or eax, 1
  mov cr0, eax
[bits 32]
  db 0x66
  jmp CODE_SELECTOR:protected_mode

gdt_start:
  dq 0x0
gdt_code:
  dw 0xFFFF
  dw 0x0
  db 0x0
  db 0x9A ; segmento pode ser lido e executado
  db 0XCF
  db 0x0
gdt_data:
  dw 0xFFFF 
  dw 0x0 ; endereço do segmento (bits 0-15)
  db 0x0 ; endereço do segmento (bits 16-23)
  db 0x92
  db 0xCF
  db 0x0 ; endereço do segmento (bits 24-31)
gdt_end:

gdt_descriptor:
  dw gdt_end - gdt_start ; calcula tamanho da gdt
  dd gdt_start

[bits 16]

disk_error:
  cli
  hlt

memory_map:
  pusha

  mov ax, 0xE820
  xor bx, bx
  mov bp, 0 ; we will use 'bp' to count
  memory_map_loop:
    db 0x66
    mov ecx, 0x534D4150 ; SMAP
    add di, bp  
    mov di, 0x500 ; memory addr; will be used in Kernel
    add bp, 20 ; 20 = data size
    int 0x15

  jc memory_map_error
  cmp bx, 0
  jz memory_map_finish
  jmp memory_map_loop
memory_map_finish:
  popa
  ret

memory_map_error:
  

[bits 32]

protected_mode:
  mov esp, (0x7c00 - 0x200)
  mov ebp, esp

  mov ax, DATA_SELECTOR
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov ecx, dword [E820Map]
  jmp CODE_SELECTOR:0x1000 ; prekernel

times 510-($-$$) db 0
dw 0xAA55
