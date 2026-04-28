library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity MPG is
    Port ( CLK : in STD_LOGIC;
           btn : in STD_LOGIC;
           en : out STD_LOGIC);
end MPG;

architecture Behavioral of MPG is

signal Q1 : std_logic;
signal D1 : std_logic;

signal Q2 : std_logic;
signal D2 : std_logic;

signal Q3 : std_logic;
signal D3 : std_logic;

signal t_en : std_logic;

signal cnt:std_logic_vector(15 downto 0) := (others => '0');


begin

process(clk)
begin
    if rising_edge(clk) then
            cnt <= cnt + '1';
    end if;
end process;

t_en <= '1' when cnt = x"FFFF" else '0';
D1 <= btn;

process(CLK)
    begin
    if rising_edge(CLK) then
        if t_en = '1' then
            Q1 <= D1;
        end if;
    end if;
end process;

D2 <= Q1;

process(CLK)
    begin
        if rising_edge(CLK) then
            Q2 <= D2;
        end if;
end process;

D3 <= Q2;

process(CLK)
    begin
        if rising_edge(CLK) then
            Q3 <= D3;
        end if;
end process;

en <= Q2 and (not Q3);

end Behavioral;
