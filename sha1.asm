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

            mov     rcx, rsi
            mov     rbx, rcx
            and     rcx, 63
            sub     rsi, rcx

            push    rdi
            push    rsi
            push    rcx

            add     rsi, rdi
            lea     rdi, [rel tail]

            rep     movsb
            mov     al, 0x80
            stosb

            pop     rax                         ; size - (size % 64)
            inc     rax
            mov     rcx, 64
            mov     r15, rcx
            sub     rcx, rax
            cmp     rcx, 8
            jae     .size_ok
            add     rcx, 64
            add     r15, 64
.size_ok:   sub     rcx, 8
            xor     al, al
            rep     stosb
            mov     rax, rbx
            shl     rax, 3
            bswap   eax
            mov     dword [rdi+4], eax
            shr     rax, 32
            bswap   eax
            stosd
            pop     r9                          ; r9 = size - (size % 64)
            pop     rsi                         ; rsi = data
                                                ; r15 = tail size (64 or 128)
            mov     r10, 0x67452301
            mov     r11, 0xefcdab89
            mov     r12, 0x98badcfe
            mov     r13, 0x10325476
            mov     r14, 0xc3d2e1f0

.loop:
            test    r9, r9
            jnz     .chunk
            test    r15, r15
            jz      .done
            xchg    r9, r15
            lea     rsi, [rel tail]

.chunk:
            push    r10
            push    r11
            push    r12
            push    r13
            push    r14

            mov     rcx, 16
            sub     r9, 64
            lea     rdi, [rel buf]
            push    rdi

.byteswap_copy:
            lodsd
            bswap   eax
            stosd
            loop    .byteswap_copy

            mov     rcx, 64
.extend:
            mov     eax, dword [rdi-12]
            xor     eax, dword [rdi-32]
            xor     eax, dword [rdi-56]
            xor     eax, dword [rdi-64]
            rol     eax, 1
            stosd
            loop    .extend
            pop     rdi                         ; rdi = buf

.step_1:
            cmp     rcx, 19
            ja      .step_2
            mov     rax, r11
            mov     rdx, rax
            not     rax
            and     rax, r13
            and     rdx, r12
            or      rax, rdx
            mov     edx, 0x5a827999
            jmp     .funnel
.step_2:
            cmp     rcx, 39
            ja      .step_3
            mov     rax, r11
            xor     rax, r12
            xor     rax, r13
            mov     edx, 0x6ed9eba1
            jmp     .funnel
.step_3:
            cmp     rcx, 59
            ja      .step_4
            mov     rax, r11
            mov     rdx, rax
            and     rax, r12
            and     rdx, r13
            or      rax, rdx
            mov     rdx, r12
            and     rdx, r13
            or      rax, rdx
            mov     edx, 0x8f1bbcdc
            jmp     .funnel
.step_4:
            mov     rax, r11
            xor     rax, r12
            xor     rax, r13
            mov     edx, 0xca62c1d6
.funnel:
            mov     ebx, r10d
            rol     ebx, 5
            add     eax, ebx
            add     eax, r14d
            add     eax, edx
            add     eax, dword [rdi + rcx*4]
            mov     r14, r13
            mov     r13, r12
            mov     r12, r11
            rol     r12d, 30
            mov     r11, r10
            mov     r10, rax
            inc     rcx
            cmp     rcx, 80
            jl      .step_1

            mov     rax, r14
            pop     r14
            add     r14, rax

            mov     rax, r13
            pop     r13
            add     r13, rax

            mov     rax, r12
            pop     r12
            add     r12, rax

            mov     rax, r11
            pop     r11
            add     r11, rax

            mov     rax, r10
            pop     r10
            add     r10, rax

            jmp     .loop

.done:
            lea     rax, [rel result]

            mov     dword [rax], r10d
            mov     dword [rax + 4], r11d
            mov     dword [rax + 8], r12d
            mov     dword [rax + 12], r13d
            mov     dword [rax + 16], r14d

            pop     r15
            pop     r14
            pop     r13
            pop     r12
            pop     rbx

            ret

section .data

result      times 5 dd 0
tail        times 128 db 0
buf         times 320 db 0
