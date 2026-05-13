# Inițializări
0:  addi $1, $0, 15     # Inițializare n = 15 (Schimbă în 4 pt testul rapid la laborator)
1:  add  $2, $0, $0     # Inițializare s = 0 (aici se va aduna suma divizorilor)
2:  addi $3, $0, 1      # Inițializare i = 1

loop_ext:
3:  slt  $5, $1, $3     # $5 = 1 dacă n < i
4:  bne  $5, $0, end    # Dacă i > n (adică n < i e adevărat), sărim la 'end'
5:  add  $4, $1, $0     # rest = n

loop_int:
6:  slt  $5, $4, $3     # $5 = 1 dacă rest < i
7:  bne  $5, $0, check  # Dacă rest < i, am terminat scăderile, mergem să verificăm restul
8:  sub  $4, $4, $3     # rest = rest - i
9:  j    loop_int       # Repetăm scăderea

check:
10: bne  $4, $0, next_i # Dacă rest != 0, i nu e divizor, deci sărim la următorul i
11: add  $2, $2, $3     # Dacă rest == 0, am găsit un divizor! s = s + i

next_i:
12: addi $3, $3, 1      # i = i + 1
13: j    loop_ext       # Ne întoarcem la verificarea buclei mari

end:
14: add  $0, $2, $0     # Hack pentru display: Punem $2 pe RD1 (rs = $2)
15: j    15             # Buclă infinită - îngheață procesorul la final pentru a citi rezultatul