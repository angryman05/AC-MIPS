library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity MEM is
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           MemWrite : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR (31 downto 0));
end MEM;

architecture Behavioral of MEM is

type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
signal ram_mem : ram_type := (
    others => X"00000000"
);

begin

process(clk)
begin
    if rising_edge(clk) then
        if en = '1' and memwrite = '1' then
            ram_mem(conv_integer(ALUResIn(5 downto 0))) <= RD2;
        end if;
    end if;
end process;

ALUResOut <= ALUResIn;
memdata <= ram_mem(conv_integer(ALUResIn(5 downto 0)));

end Behavioral;
