library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR(4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( CLK : in STD_LOGIC;
           btn : in STD_LOGIC;
           en : out STD_LOGIC);
end component;

component SSD is
  Port (
   clk: in std_logic;
   digits : in std_logic_vector(31 downto 0);
   an: out std_logic_vector(7 downto 0);
   cat: out std_logic_vector(6 downto 0));
end component;

component IFetch is
    Port ( clk : in STD_LOGIC;
           en : in std_logic;
           jmp : in STD_LOGIC;
           pcsrc : in STD_LOGIC;
           JAddr : in STD_LOGIC_VECTOR (31 downto 0);
           Baddr : in STD_LOGIC_VECTOR (31 downto 0);
           instruction : out STD_LOGIC_VECTOR (31 downto 0);
           pc_1 : out STD_LOGIC_VECTOR(31 downto 0));
end component;

component IDecoder is
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
end component;

-- COMPONENTA NOUA: Main Control
component MainControl is
    Port ( Opcode : in STD_LOGIC_VECTOR (5 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR (2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end component;

component inst_EX is
    Port ( PCinc : in STD_LOGIC_VECTOR (31 downto 0);
           RD1 : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR (31 downto 0);
           func : in STD_LOGIC_VECTOR (5 downto 0);
           sa : in STD_LOGIC_VECTOR(4 downto 0);
           ALUSrc : in STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR (2 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR (31 downto 0);
           ALURes : out STD_LOGIC_VECTOR (31 downto 0);
           Zero : out STD_LOGIC);
end component;

component MEM is
    Port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           MemWrite : in STD_LOGIC;
           MemData : out STD_LOGIC_VECTOR (31 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR (31 downto 0));
end component;

signal enable_cnt0 : std_logic;
signal enable_cnt1 : std_logic;
signal enable_cnt2 : std_logic;

signal cnt:std_logic_vector(7 downto 0) := (others=>'0');
signal digit:std_logic_vector(31 downto 0);
signal rst:std_logic;

signal sig_instruction : std_logic_vector(31 downto 0);
signal sig_pc_1 : std_logic_vector(31 downto 0);

signal sig_RD1, sig_RD2, sig_sum, sig_ext_imm : STD_LOGIC_VECTOR(31 downto 0);
signal sig_func : STD_LOGIC_VECTOR(5 downto 0);
signal sig_sa : STD_LOGIC_VECTOR(4 downto 0);
signal sig_Ext_func, sig_Ext_sa : STD_LOGIC_VECTOR(31 downto 0);

-- SEMNALE NOI DE CONTROL
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);
signal RegWrite_en : STD_LOGIC;


signal ALURes : std_logic_vector(31 downto 0);
signal BranchAddress : std_logic_vector(31 downto 0); 
signal zero : std_logic;

signal memdata : std_logic_vector(31 downto 0);
signal aluresout: std_logic_vector(31 downto 0);

signal sig_PCSrc : STD_LOGIC;
signal sig_JumpAddress : STD_LOGIC_VECTOR(31 downto 0);
signal sig_WD : STD_LOGIC_VECTOR(31 downto 0);

signal core_en : std_logic;

begin

rst <= enable_cnt1;

display: SSD port map(clk => clk,digits => digit,an => an,cat => cat);

mepegeu0: MPG port map(CLK => clk, btn => btn(0), en => enable_cnt0);

--enable_cnt0 <= '1';

mepegeu1: MPG port map(CLK => clk, btn => btn(1), en => enable_cnt1);
mepegeu2: MPG port map(CLK => clk, btn => btn(2), en => enable_cnt2);

core_en <= '1' when sw(15) = '1' else enable_cnt0;

process(clk)
begin
    if rising_edge(clk) then
        if enable_cnt0 = '1' then
            cnt <= cnt + 1;
        end if;  
        if enable_cnt2 = '1' then
            cnt <= "00000000";
        end if; 
    end if;
end process;

inst_IF : IFetch port map(
    clk => clk,
    en => core_en,            
    jmp => Jump,             
    pcsrc => sig_PCSrc,             
    JAddr => sig_JumpAddress,       
    Baddr => BranchAddress,         
    instruction => sig_instruction,
    pc_1 => sig_pc_1
);

-- MAPARE MAIN CONTROL
inst_MC : MainControl port map(
    Opcode => sig_instruction(31 downto 26), -- Primii 6 biti!
    RegDst => RegDst,
    ExtOp => ExtOp,
    ALUSrc => ALUSrc,
    Branch => Branch,
    Jump => Jump,
    ALUOp => ALUOp,
    MemWrite => MemWrite,
    MemtoReg => MemtoReg,
    RegWrite => RegWrite
);

-- Protectie suplimentara ca RF sa nu scrie aiurea, ci doar la activarea butonului
RegWrite_en <= RegWrite and core_en;

inst_DEC : IDecoder port map(
    clk => clk,
    RegWrite => RegWrite_en, 
    Instr => sig_instruction(25 downto 0), 
    RegDst => RegDst, 
    ExtOp => ExtOp, 
    WD => sig_WD,                   
    RD1 => sig_RD1,
    RD2 => sig_RD2,
    ext_imm => sig_ext_imm,
    func => sig_func,
    sa => sig_sa
);

Ex_inst: inst_EX port map(
    PCinc => sig_pc_1,
    RD1 => sig_RD1,
    RD2 => sig_RD2,
    Ext_Imm => sig_ext_imm,
    func => sig_func,
    sa => sig_sa,
    ALUSrc => ALUSrc,
    ALUOp => ALUOp,
    BranchAddress => BranchAddress,
    ALURes => ALURes,
    Zero => zero
);

ram_mem: MEM port map(
    clk => clk,
    en => core_en,
    ALUResIn => ALURes,
    RD2 => sig_RD2,
    MemWrite => MemWrite,
    MemData => memdata,
    ALUResOut => aluresout   
);

sig_sum <= sig_RD1 + sig_RD2;
sig_Ext_func <= "00000000000000000000000000" & sig_func;
sig_Ext_sa <= "000000000000000000000000000" & sig_sa;

-- MUX pentru SSD (la fel ca inainte)
process(sw, sig_instruction, sig_pc_1, sig_RD1, sig_RD2, sig_ext_imm, sig_sum, sig_Ext_func, sig_Ext_sa)
begin
    case sw(7 downto 5) is
        when "000" => digit <= sig_instruction;
        when "001" => digit <= sig_pc_1;
        when "010" => digit <= sig_RD1;
        when "011" => digit <= sig_RD2;
        when "100" => digit <= sig_ext_imm;
        when "101" => digit <= sig_sum;
        when "110" => digit <= sig_Ext_func;
        when "111" => digit <= sig_Ext_sa;
        when others => digit <= (others => '0');
    end case;
end process;

with memtoreg select 
    sig_WD <= memdata when '1',
          aluresout when '0',
          (others => 'X') when others;

-- Logica de Branch (Poza 3)
sig_PCSrc <= (not zero) and branch;

-- Logica de Jump (Poza 3 adaptata la 32 de biti adresati la cuvant)
sig_JumpAddress <= sig_pc_1(31 downto 26) & sig_instruction(25 downto 0);

-- AFISARE SEMNALE CONTROL PE LED-uri (conform instructiunilor din poza)
-- led(10 downto 0) vor arata direct ce a decis Control Unit-ul
led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;

-- Restul LED-urilor le tinem pe 0
led(15 downto 11) <= (others => '0');

end Behavioral;