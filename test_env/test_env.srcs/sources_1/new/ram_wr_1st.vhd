library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ram_wr_1st is
    port ( clk : in std_logic;
        we : in std_logic; -- comanda Write Enable
        en : in std_logic; -- opțional
        addr : in std_logic_vector(5 downto 0); -- Read/Write Address
        di : in std_logic_vector(31 downto 0); -- Data In
        do : out std_logic_vector(31 downto 0)); -- Data Out
end ram_wr_1st ;

architecture Behavioral of ram_wr_1st is

type ram_type is array (0 to 63) of std_logic_vector(31 downto 0);
signal mem : ram_type := (
    X"000000FF",
    X"00000FAB",
    X"00000122",
    X"00012000",
    others => X"00000000"
);

begin

process(clk)
begin
    if rising_edge(clk) then
        if en = '1' then -- opțional
            if we = '1' then -- scriere sincronă
                mem(conv_integer(addr)) <= di;
                do <= di;
            else -- citire sincronă
                do <= mem(conv_integer(addr));
            end if;
         end if;
    end if;
end process;

end Behavioral;