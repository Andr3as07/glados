BITS 32


; BEGIN - Multiboot Header
section .multiboot               ;according to multiboot spec
        dd 0x1BADB002            ;set magic number for
                                 ;bootloader
        dd 0x0                   ;set flags
        dd - (0x1BADB002 + 0x0)  ;set checksum

; END - Multiboot Header

SECTION .text
	
; BEGIN - Kernel stack space allocation
Kernel_Stack_End:
	TIMES 65535 db 0
Kernel_Stack_Start:
; END - Kernel stack space allocation

	
; BEGIN - GDT allocations
; This is the GDT table pre-filled with the entries we want
GDT_Contents:
; I have a suspicion that the order of the items in the GDT matters
;	Code and data selectors first then TSS
db 0, 0, 0, 0, 0, 0, 0, 0			; Offset: 0  - Null selector - required 
db 255, 255, 0, 0, 0, 0x9A, 0xCF, 0	; Offset: 8  - KM Code selector - covers the entire 4GiB address range
db 255, 255, 0, 0, 0, 0x92, 0xCF, 0	; Offset: 16 - KM Data selector - covers the entire 4GiB address range
db 255, 255, 0, 0, 0, 0xFA, 0xCF, 0	; Offset: 24 - UM Code selector - covers the entire 4GiB address range
db 255, 255, 0, 0, 0, 0xF2, 0xCF, 0	; Offset: 32 - UM Data selector - covers the entire 4GiB address range

;					   Size - Change iff adding/removing rows from GDT contents
;					   Size = Total bytes in GDT - 1
GDT_Pointer db 39, 0, 0, 0, 0, 0
; END - GDT allocations

	
GLOBAL _Kernel_Start:function
extern main		     	; Main entry point is defined in kernel.c

_Kernel_Start:

	cli

	;; TODO: Handle multiboot info structure
	
	; BEGIN - Switch to protected mode 
	mov dword EAX, CR0
	or EAX, 1
	mov dword CR0, EAX
	; END - Switch to protected mode

	; BEGIN - Set stack pointer
	mov dword ESP, Kernel_Stack_Start
	; END - Set stack pointer

	; BEGIN - Tell CPU about GDT
	mov dword [GDT_Pointer + 2], GDT_Contents
	mov dword EAX, GDT_Pointer
	lgdt [EAX]
	; Set data segments
	mov dword EAX, 0x10
	mov word DS, EAX
	mov word ES, EAX
	mov word FS, EAX
	mov word GS, EAX
	mov word SS, EAX
	; Force reload of code segment
	jmp 8:Boot_FlushCsGDT
Boot_FlushCsGDT:
	; END - Tell CPU about GDT

	;; Jump to kernel main function
	call main

	;; Halt the cpu (We should never end up here)
.Halt:
	cli		   	; Stop maskable interrupts
	hlt			; Halt the cpu
	jmp .Halt		; if non-maskable interrupt accurs, re-halt

section .bss
resb 8192
stack_space:	
