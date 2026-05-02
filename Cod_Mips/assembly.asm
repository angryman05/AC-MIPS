section .text
global _start
_start:
    mov eax, 4       ; n = 14
    mov ebx, 0       ; s = 0
    mov ecx, 1       ; i = 1

loop_ext: ; while(i <= n)
    cmp eax, ecx
    jl end_prog
    mov edx, eax     ; rest = n
loop_int:
    ; while (rest >= i)
    cmp edx, ecx     ; comparam rest (edx) cu i (ecx)
    jl check         ; daca rest < i, am terminat de scazut
    sub edx, ecx     ; rest = rest - i
    jmp loop_int
check:
    ; if (rest == 0)
    cmp edx, 0
    jne next_i
    ; s = s + i;
    add ebx, ecx     ; il bagam pe i la suma s
next_i:
    add ecx, 1  ; i = i + 1
    jmp loop_ext
end_prog:
    jmp end_prog