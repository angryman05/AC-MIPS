# 🚀 MIPS32 Single-Cycle Processor - Suma Divizorilor

![VHDL](https://img.shields.io/badge/Language-VHDL-blue.svg)
![FPGA](https://img.shields.io/badge/Platform-Basys%203-orange.svg)
![Software](https://img.shields.io/badge/Software-Xilinx%20Vivado-green.svg)
![Status](https://img.shields.io/badge/Status-Completed-success.svg)

> **Proiect pentru laboratorul de Arhitectura Calculatoarelor (UTCN)**  
> Implementarea unui procesor MIPS pe 32 de biți (Single-Cycle) pe un FPGA, capabil să ruleze un algoritm hardware pentru calcularea sumei divizorilor unui număr folosind scăderi repetate.

---

## 📑 Cuprins
- [Despre Proiect](#-despre-proiect)
- [Arhitectura și Datapath-ul](#-arhitectura-și-datapath-ul)
- [Setul de Instrucțiuni (ISA)](#-setul-de-instrucțiuni-isa)
- [Algoritmul Implementat](#-algoritmul-implementat)
- [Simulare și Rulare](#-simulare-și-rulare)
- [Autor](#-autor)

---

## 💡 Despre Proiect

Acest proiect reprezintă o implementare de la zero a unui procesor **MIPS pe 32 de biți** într-un singur ciclu de ceas (Single-Cycle Datapath). Design-ul include memorie de instrucțiuni (ROM), memorie de date (RAM), banc de regiștri, o unitate aritmetico-logică (ALU) și o unitate de control.

Sistemul interacționează cu perifericele de pe placa FPGA (butoane și afișajul cu 7 segmente) pentru a permite executarea pas cu pas a instrucțiunilor și vizualizarea stării interne a procesorului.

---

## ⚙️ Arhitectura și Datapath-ul

Arhitectura respectă modelul standard MIPS Single-Cycle, cu modificări specifice aduse pentru a susține instrucțiunea `bne` (Branch Not Equal), necesară algoritmului curent.

*<Aici poți adăuga imaginea cu schema desenată de tine>*
<!-- Decomenteaza linia de mai jos si pune calea catre poza ta -->
<!-- ![Datapath MIPS](./imagini/datapath.png) -->

**Module principale:**
* `IFetch.vhd` - Extragerea instrucțiunilor (Include memoria ROM cu programul).
* `IDecoder.vhd` - Decodificarea instrucțiunilor și Bancul de Regiștri.
* `inst_EX.vhd` - Unitatea de execuție (ALU) și calculul adreselor de salt.
* `MainControl.vhd` - Unitatea centrală de control.
* `MEM.vhd` - Memoria de date (RAM).

---

## 🛠️ Setul de Instrucțiuni (ISA)

Procesorul suportă un subset personalizat de 10 instrucțiuni, optimizat pentru algoritmul rulat:

| Tip | Instrucțiuni Implementate |
|:---:|:---|
| **R-Type** | `add`, `sub`, `slt`, `and`, `or`, `xor` |
| **I-Type** | `addi`, `beq`, `bne` |
| **J-Type** | `j` |

<details>
<summary><b>Click aici pentru a vedea Tabelul Semnalelor de Control</b></summary>
<br>

| Instrucțiune | RegDst | ExtOp | ALUSrc | Branch | Jump | RegWrite | ALUOp |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `add`  | 1 | 0 | 0 | 0 | 0 | 1 | 000 |
| `sub`  | 1 | 0 | 0 | 0 | 0 | 1 | 000 |
| `slt`  | 1 | 0 | 0 | 0 | 0 | 1 | 000 |
| `addi` | 0 | 1 | 1 | 0 | 0 | 1 | 001 |
| `bne`  | 0 | 1 | 0 | 1 | 0 | 0 | 010 |
| `j`    | 0 | 0 | 0 | 0 | 1 | 0 | 000 |

*(Tabel simplificat. Toate operațiile de memorie MemWrite/MemtoReg sunt 0 pentru acest proiect).*
</details>

---

## 🧮 Algoritmul Implementat

Algoritmul calculează **suma divizorilor** unui număr dat (setat hardcoded în ROM: `n=4`). Pentru a evita utilizarea operatorului modulo (`%`), restul împărțirii este calculat prin **scăderi repetate**.
```mips
# Fragment din bucla principala (calcul rest)
loop_int:
    slt  $5, $4, $3     # Verifica daca rest < i
    bne  $5, $0, check  # Daca da, iesim din scaderi
    sub  $4, $4, $3     # rest = rest - i
    j    loop_int       # Repeta
```
*(Rezultatul final este stocat în registrul `$2`)*

---

## 💻 Simulare și Rulare

Proiectul a fost dezvoltat și simulat folosind **Xilinx Vivado**.

### Rularea Simulării (Testbench)
1. Deschide proiectul în Vivado.
2. Rulează `Run Behavioral Simulation`.
3. Adaugă semnalul `mem` din componenta `IDecoder` în fereastra de forme de undă (Waveform).
4. Setează `sw(15) = '1'` pentru a permite rularea continuă a procesorului.
5. Verifică registrul `mem[2]` (sau `$2`) la finalul execuției pentru a vedea rezultatul matematic corect.

*<Aici poți adăuga un screenshot cu simularea din Vivado (Waveform-ul) unde se vede rezultatul pe mem[2]>*
<!-- ![Simulare Vivado](./imagini/simulare.png) -->

---

## 👨‍💻 Autor

**Simionescu Robert Alexandru**  
*Universitatea Tehnică din Cluj-Napoca (UTCN)*  
*Facultatea de Automatică și Calculatoare (CTI)*

[![GitHub](https://img.shields.io/badge/GitHub-Profile-black?logo=github)](https://github.com/numele-tau-de-utilizator)
