[bits 16]
[org 0x7c00]

; FIXME como eu vou descobrir o endereço desse core_entrypoint?
; posso fazer sem depender de endereço, ou talvez o LD ja arrume os endereços sem o [org]
; ou talvez eu sobrescreva o bootloader