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
B"001000_00000_00001_0000000000001111",-- 0:  addi $1, $0, 15
B"000000_00000_00000_00010_00000_100000", -- 1:  add  $2, $0, $0
B"001000_00000_00011_0000000000000001", -- 2:  addi $3, $0, 1
B"000000_00001_00011_00101_00000_101010", -- 3:  slt  $5, $1, $3   (Eticheta loop_ext)
B"000101_00101_00000_0000000000001001", -- 4:  bne  $5, $0, end  (offset = 9)
B"000000_00001_00000_00100_00000_100000", -- 5:  add  $4, $1, $0
B"000000_00100_00011_00101_00000_101010", -- 6:  slt  $5, $4, $3   (Eticheta loop_int)
B"000101_00101_00000_0000000000000010", -- 7:  bne  $5, $0, check (offset = 2)
B"000000_00100_00011_00100_00000_100010", -- 8:  sub  $4, $4, $3
B"000010_00000000000000000000000110", -- 9:  j    loop_int     (target = 6)
B"000101_00100_00000_0000000000000001", -- 10: bne  $4, $0, next_i (offset = 1)   (Eticheta check)
B"000000_00010_00011_00010_00000_100000", -- 11: add  $2, $2, $3
B"001000_00011_00011_0000000000000001", -- 12: addi $3, $3, 1    (Eticheta next_i)
B"000010_00000000000000000000000011", -- 13: j    loop_ext     (target = 3)
B"000000_00010_00000_00000_00000_100000", -- 14: add $0, $2, $0 (Pune $2 pe iesirea RD1)
B"000010_00000000000000000000001111", -- 15: j 15 (Acum are 32 de biți)
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
