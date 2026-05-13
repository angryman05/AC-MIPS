library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_mips is
-- Entitatea de testbench este goala
end tb_mips;

architecture Behavioral of tb_mips is

    -- Declaram componenta pe care o testam (Top level-ul tau)
    component test_env is
        Port ( clk : in STD_LOGIC;
               btn : in STD_LOGIC_VECTOR(4 downto 0);
               sw : in STD_LOGIC_VECTOR (15 downto 0);
               led : out STD_LOGIC_VECTOR (15 downto 0);
               an : out STD_LOGIC_VECTOR (7 downto 0);
               cat : out STD_LOGIC_VECTOR (6 downto 0));
    end component;

    -- Semnale interne pentru a le conecta la placa virtuala
    signal clk : std_logic := '0';
    signal btn : std_logic_vector(4 downto 0) := (others => '0');
    signal sw : std_logic_vector(15 downto 0) := (others => '0');
    signal led : std_logic_vector(15 downto 0);
    signal an : std_logic_vector(7 downto 0);
    signal cat : std_logic_vector(6 downto 0);

    -- Constanta pentru perioada ceasului (100 MHz ca pe Nexys)
    constant clk_period : time := 10 ns;

begin

    -- Instantiem mediul tau de test
    uut: test_env port map (
        clk => clk,
        btn => btn,
        sw => sw,
        led => led,
        an => an,
        cat => cat
    );

    -- Generarea ceasului la infinit
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Aici scriem scenariul testului
    stim_proc: process
    begin
        -- Setam switch-ul 6 pe 1 ca sa vedem RD1 pe display
        sw(6) <= '1';
        sw(15) <= '1';
        -- Daca ai inlocuit enable_cnt0 <= '1' in test_env, 
        -- procesorul ruleaza acum la viteza maxima!
        -- 300 de instructiuni * 10 ns = 3000 ns (3 microsecunde)
        -- Asteptam 5 microsecunde ca sa fim 100% siguri ca termina algoritmul.
        wait for 5 us;
        
        -- Oprim simularea (assert false este o metoda eleganta de a opri Vivado din loop)
        assert false report "Simulare terminata cu succes!" severity failure;
    end process;

end Behavioral;