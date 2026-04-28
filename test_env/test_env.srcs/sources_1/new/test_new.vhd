library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

entity test_new is
    Port ( sw : in STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC;
           led : out STD_LOGIC_VECTOR (7 downto 0));
end test_new;

architecture Behavioral of test_new is

component  MPG is
    Port ( CLK : in STD_LOGIC;
           btn : in STD_LOGIC;
           en : out STD_LOGIC);
end component;

signal cnt : std_logic_vector(2 downto 0) := (others => '0');
signal t_en : std_logic;

begin

--port map la mpg
mepegeu: MPG port map(
clk => CLK,
btn => btn,
en => t_en
);

--counter cu directie 1 mere pozitiv 0 mere negativ
process(clk)
begin
    if rising_edge(clk) then
        if t_en = '1' then
            if sw = '0' then
            cnt <= cnt + '1';
            end if;
            if sw = '0' then
            cnt <= cnt - '1';
            end if;
            
         end if;
    end if;
end process;

process(cnt)
begin
    case cnt is
        when "000" => led <= "00000001";
        when "001" => led <= "00000010";
        when "010" => led <= "00000100";
        when "011" => led <= "00001000";
        when "100" => led <= "00010000";
        when "101" => led <= "00100000";
        when "110" => led <= "01000000";
        when others => led <="10000000"; 
    end case;
end process;

end Behavioral;
