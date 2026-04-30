section .text
global _start

_start:
    ; Inițializări
    mov eax, 4       ; n = 14
    mov ebx, 0       ; s = 0
    mov ecx, 1       ; i = 1

loop_ext:
    ; while (i <= n)
    cmp eax, ecx     ; compară n (eax) cu i (ecx)
    jl end_prog      ; dacă n < i (adică i > n), sari la final

    ; int rest = n;
    mov edx, eax     ; rest = n

loop_int:
    ; while (rest >= i)
    cmp edx, ecx     ; compară rest (edx) cu i (ecx)
    jl check         ; dacă rest < i, am terminat scăderile

    ; rest = rest - i;
    sub edx, ecx     ; rest = rest - i
    jmp loop_int     ; repetă bucla de scădere

check:
    ; if (rest == 0)
    cmp edx, 0       ; verificăm dacă restul e 0
    jne next_i       ; dacă nu e 0, sărim peste adunare

    ; s = s + i;
    add ebx, ecx     ; adăugăm i la suma s

next_i:
    ; i = i + 1;
    add ecx, 1       ; incrementăm i
    jmp loop_ext     ; ne întoarcem la verificarea buclei mari

end_prog:
    ; Buclă infinită de final (echivalentul lui j end)
    jmp end_prog