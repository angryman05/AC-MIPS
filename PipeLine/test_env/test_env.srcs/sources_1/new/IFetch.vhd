library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity IFetch is
    Port ( clk : in STD_LOGIC;
           en : in std_logic;
           jmp : in STD_LOGIC;
           pcsrc : in STD_LOGIC;
           JAddr : in STD_LOGIC_VECTOR (31 downto 0);
           Baddr : in STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0);
           pc_1 : out STD_LOGIC_VECTOR(31 downto 0));
end IFetch;

architecture Behavioral of IFetch is

--rom
type tRom is array(0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
signal rom : tRom := 
(
-- suma divizorilor unui numar, se calculeaza cu teorema impartirii cu rest
B"001000_00000_00001_0000000000000100",-- 0:  addi $1, $0, 4 | x"20010004" | init n = 4
B"000000_00000_00000_00010_00000_100000", -- 1:  add  $2, $0, $0 | x"00001020" | init s = 0
B"001000_00000_00011_0000000000000001", -- 2:  addi $3, $0, 1 | x"20030001" | init i = 1
B"000000_00001_00011_00101_00000_101010", -- 3:  slt  $5, $1, $3   (Eticheta loop_ext) | x"0023282A" | vericam n < i
B"000101_00101_00000_0000000000010100", -- 4:  bne  $5, $0, end  (offset = 20) | x"14A00014" | daca i > n ii gata
B"000000_00000_00000_00000_00000_000000", -- 5:  NOP (delay slot bne 1)
B"000000_00000_00000_00000_00000_000000", -- 6:  NOP (delay slot bne 2)
B"000000_00000_00000_00000_00000_000000", -- 7:  NOP (delay slot bne 3)
B"000000_00001_00000_00100_00000_100000", -- 8:  add  $4, $1, $0 | x"00202020" | setam rest = n ca pregatim impartirea
B"000000_00100_00011_00101_00000_101010", -- 9:  slt  $5, $4, $3   (Eticheta loop_int) | x"0083282A" | verificam daca rest < i
B"000101_00101_00000_0000000000000110", -- 10:  bne  $5, $0, check (offset = 6) | x"14A00006" | daca rest < i,am terminat cu scaderile si sarim la verificare
B"000000_00000_00000_00000_00000_000000", -- 11:  NOP (delay slot bne 1)
B"000000_00000_00000_00000_00000_000000", -- 12:  NOP (delay slot bne 1)
B"000000_00000_00000_00000_00000_000000", -- 13:  NOP (delay slot bne 1)
B"000000_00100_00011_00100_00000_100010", -- 14:  sub  $4, $4, $3 | x"00832022" | rest = rest - i
B"000010_00000000000000000000001001", -- 15:  j    loop_int (target = 9) | x"08000009" | repeta scaderea pt a gasi restul
B"000000_00000_00000_00000_00000_000000", -- 16:  NOP (delay slot j 1)
B"000101_00100_00000_0000000000000100", -- 17: bne  $4, $0, next_i(offset = 4)   (Eticheta check) | x"14800004" |  daca rest != 0, i nu e divizor
B"000000_00000_00000_00000_00000_000000", -- 18:  NOP (delay slot bne 1)
B"000000_00000_00000_00000_00000_000000", -- 19:  NOP (delay slot bne 2)
B"000000_00000_00000_00000_00000_000000", -- 20:  NOP (delay slot bne 3)
B"000000_00010_00011_00010_00000_100000", -- 21: add  $2, $2, $3 | x"00431020" | daca rest == 0 i e divizor si se face s = s + i
B"001000_00011_00011_0000000000000001", -- 22: addi $3, $3, 1    (Eticheta next_i) | x"20630001" | trecem la urmatorul divizor cu i = i + 1
B"000010_00000000000000000000000011", -- 23: j    loop_ext     (target = 3) | x"08000003" | reluam bucla principala pt noul i
B"000000_00000_00000_00000_00000_000000", -- 24:  NOP (delay slot j 1)
B"000000_00010_00000_00000_00000_100000", -- 25: add $0, $2, $0 | x"00400020" | punem suma finala din $2 pe iesirea RD1 sa se vada faain pe ssd
B"000010_00000000000000000000011010", -- 26: j 26 | x"0800001A" | bucla infinita ca sa se vada cum trebuie pe ssd
B"000000_00000_00000_00000_00000_000000", -- 27:  NOP (delay slot j 1)
others => x"00000000"
);

signal pc : std_logic_vector(31 downto 0) := (others => '0');

signal m1 : std_logic_vector(31 downto 0);
signal m2 : std_logic_vector(31 downto 0);
signal x0 : std_logic_vector(31 downto 0);

begin

x0 <= pc + 1;
pc_1 <= x0;


process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then
            pc <= m2;
        end if;
    end if;
end process;

process(pcsrc,Baddr,x0)
begin
    case pcsrc is
        when '0' => m1 <= x0;
        when '1' => m1 <= Baddr;
        when others => m1 <= x0;
    end case;
end process;

process(jmp,Jaddr,m1)
begin
    case jmp is
        when '0' => m2 <= m1;
        when '1' => m2 <= Jaddr;
        when others => m2 <= m1;
    end case;
end process;

instruction <= rom(conv_integer(pc));

end Behavioral;
