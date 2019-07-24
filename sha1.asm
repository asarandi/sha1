bits 64
default rel
section .text

%ifidn __OUTPUT_FORMAT__, macho64
 global _sha1
 _sha1:
%elifidn __OUTPUT_FORMAT__, elf64
 global sha1
 sha1:
%endif

            push    rbx
            push    r12
            push    r13
            push    r14
            push    r15

            mov     r10  0x67452301
            mov     r11  0xefcdab89
            mov     r12, 0x98badcfe
            mov     r13, 0x10325476
            mov     r14, 0xc3d2e1f0


            lea     rax, [rel result]

            bswap   r10d
            mov     dword [rax], r10d
            bswap   r11d
            mov     dword [rax + 4], r11d
            bswap   r12d
            mov     dword [rax + 8], r12d
            bswap   r13d
            mov     dword [rax + 12], r13d
            bswap   r14d
            mov     dword [rax + 16], r14d

            pop     r15
            pop     r14
            pop     r13
            pop     r12
            pop     rbx

            ret


section .data

result      times 5 dd 0

buf         times 320 db 0
