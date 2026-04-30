0:  addi $1, $0, 15     # Inițializare n = 15
1:  add  $2, $0, $0     # Inițializare s = 0 (suma)
2:  addi $3, $0, 1      # Inițializare i = 1

loop_ext:
3:  slt  $5, $1, $3     # $5 = 1 dacă n < i
4:  bne  $5, $0, end    # Dacă i > n, ieși din program (sari la 'end')
5:  add  $4, $1, $0     # rest = n

loop_int:
6:  slt  $5, $4, $3     # $5 = 1 dacă rest < i
7:  bne  $5, $0, check  # Dacă rest < i, am terminat scăderile, verificăm restul
8:  sub  $4, $4, $3     # rest = rest - i
9:  j    loop_int       # Repetăm scăderea

check:
10: bne  $4, $0, next_i # Dacă rest != 0, nu e divizor, sărim la următorul i
11: add  $2, $2, $3     # Dacă rest == 0, s = s + i

next_i:
12: addi $3, $3, 1      # i = i + 1
13: j    loop_ext       # Ne întoarcem la începutul buclei mari

end:
14: j    end            # Buclă infinită pentru a opri programul la final