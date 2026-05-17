library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity IDecoder is
    port ( clk : in std_logic;
           RegWrite : in STD_LOGIC;
           Instr : in STD_LOGIC_VECTOR (25 downto 0);
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           WD : in STD_LOGIC_VECTOR (31 downto 0);
           RD1 : out STD_LOGIC_VECTOR (31 downto 0);
           RD2 : out STD_LOGIC_VECTOR (31 downto 0);
           ext_imm : out STD_LOGIC_VECTOR (31 downto 0);
           func : out STD_LOGIC_VECTOR (5 downto 0);
           sa : out std_logic_vector(4 downto 0));
end IDecoder;

architecture Behavioral of IDecoder is

type rf_type is array(0 to 31) of std_logic_vector(31 downto 0);
signal mem : rf_type:= (others => X"00000000");

signal ra1 : std_logic_vector(4 downto 0); 
signal ra2 : std_logic_vector(4 downto 0); 
signal wa : std_logic_vector(4 downto 0); 
signal regwr : std_logic; 
signal ExtUnit : std_logic_vector(31 downto 0);
signal x1 : std_logic_vector(4 downto 0);
signal x2 : std_logic_vector(4 downto 0);


begin

ra1 <= instr(25 downto 21);
ra2 <=instr(20 downto 16);
func <= instr(5 downto 0);
sa <= instr(10 downto 6);
x2 <= instr(15 downto 11);
x1 <= instr(20 downto 16);

process(ExtOp,instr)
begin
    if ExtOp = '0' then
        ext_imm <= x"0000" & instr(15 downto 0);
    else
        if instr(15) = '1' then 
            ext_imm <= x"FFFF" & instr(15 downto 0);
        else
            ext_imm <= x"0000" & instr(15 downto 0);
        end if;
    end if;
end process;

process(RegDst, x1, x2)
begin
    if RegDst = '1' then
        wa <= x2;
    else
        wa <= x1;
    end if;
end process;

process(clk)
begin
     if rising_edge(clk) then
        if RegWrite = '1' then
            mem(conv_integer(wa)) <= WD;
        end if;
     end if;
end process;

rd1 <= mem(conv_integer(ra1)); 
rd2 <= mem(conv_integer(ra2)); 

end Behavioral;
