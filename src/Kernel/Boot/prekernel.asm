[bits 32]
[org 0x1000]

jmp main

main:
    cli
    call check_cpuid
    call load_kernel
    call configure_pagination
    call long_mode

disk_error:
  hlt

load_kernel:
  mov ecx, 0 ; contador
  mov dx, 0x1F6
  mov al, 0xE0
  out dx, al ; cabeçote de disco e numero do drive
  mov dx, 0x1F2
  mov al, (SECTORS_KERNEL)
  out dx, al ; numero de setores a ler

  mov dx, 0x1F3
  mov al, 100
  out dx, al ; setor pra começar a ler
  
  ; Cilindro e cabeçote
  xor al, al
  mov dx, 0x1F4
  out dx, al
  mov dx, 0x1F5
  out dx, al

  ; Comando de leitura
  mov dx, 0x1F7
  mov al, 0x20
  out dx, al

  read_loop:
   mov dx, 0x1F7
   wait_for_disk: 
     in al, dx
     test al, 0x80
     jnz wait_for_disk
     test al, 0x01
     jnz disk_error

   mov dx, 0x1F0
   in ax, dx
 
   mov edi, 10485760
   add edi, ecx
   mov [edi], ax
   add ecx, 2
   cmp ecx, (SECTORS_KERNEL * 512)
   je read_finish
   jmp read_loop

  read_finish:
   mov byte [0xB8000], 'L'

   ret

check_cpuid:
    pushfd
    pop eax

    mov ecx, eax
    xor eax, 1 << 21

    push eax
    popfd

    pushfd
    pop eax

    push ecx
    popfd
    cmp eax, ecx
    je err
    ret
err:
    mov BYTE [0x8b000], 'e'
    halt

configure_pagination:
    ; temporary pagination
    ; just to make "long mode" work.
    mov eax, cr4
    or eax, 1 << 5 ; PAE
    mov cr4, eax

    mov eax, cr4
    or eax, 1 << 4 ; PSE
    mov cr4, eax

    mov eax, page_table_l3
    or eax, 0b11 ; P and W
    mov [page_table_l4], eax

    mov eax, page_table_l2
    or eax, 0b11
    mov [page_table_l3], eax

    mov ecx, 0
    .loop: ; flag every single page
        mov eax, 0x200000 ; 2MB
        mul ecx
        or eax, 0b10000011
        mov [page_table_l2 + ecx * 8], eax
    inc ecx
    cmp ecx, 512
    jne .loop
    ret
    jmp err

long_mode:
    mov eax, cr0
    and eax, 0x9FFFFFFF
    mov cr0, eax
    mov eax, page_table_l4
    mov cr3, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8 ; enabling long mode
    wrmsr

    mov eax, cr0
    or eax, 1 << 31 ; pagination
    mov cr0, eax

    mov dword [0xb8000], 0x2f4b2f4f
    lgdt [gdt64.pointer]
    jmp gdt64.code_segment:pkmain
[bits 64]
pkmain:
    mov ax, 0
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov rsp, 6291456 ; page four
    mov rbp, rsp
    cli

    jmp 10485760
    cli
    hlt

gdt64:
  dq 0
.code_segment: equ $ - gdt64
  dq (1<<43) | (1<<44) | (1<<47) | (1<<53)
.pointer:
  dw $ - gdt64 - 1
  dq gdt64

align 4096
page_table_l4:
  resb 4096
page_table_l3:
  resb 4096
page_table_l2:
  resb 4096

boot_info_struct:
  dd 0 ;  BIOS

times 512*50-($-$$) db 0