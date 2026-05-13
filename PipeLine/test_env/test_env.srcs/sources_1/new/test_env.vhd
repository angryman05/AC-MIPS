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
  Port ( clk: in std_logic; 
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
           WA : in STD_LOGIC_VECTOR(4 downto 0); 
           ExtOp : in STD_LOGIC;
           WD : in STD_LOGIC_VECTOR (31 downto 0);
           RD1 : out STD_LOGIC_VECTOR (31 downto 0);
           RD2 : out STD_LOGIC_VECTOR (31 downto 0);
           ext_imm : out STD_LOGIC_VECTOR (31 downto 0);
           func : out STD_LOGIC_VECTOR (5 downto 0);
           sa : out std_logic_vector(4 downto 0));
end component;

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

signal enable_cnt0, core_en : std_logic;
signal cnt:std_logic_vector(7 downto 0) := (others=>'0');
signal digit:std_logic_vector(31 downto 0);

signal sig_instruction, sig_pc_1 : std_logic_vector(31 downto 0);
signal sig_RD1, sig_RD2, sig_ext_imm : STD_LOGIC_VECTOR(31 downto 0);
signal sig_func : STD_LOGIC_VECTOR(5 downto 0);
signal sig_sa : STD_LOGIC_VECTOR(4 downto 0);

signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp : STD_LOGIC_VECTOR(2 downto 0);
signal ALURes, BranchAddress, memdata, aluresout : std_logic_vector(31 downto 0);
signal zero : std_logic;

signal sig_PCSrc : STD_LOGIC;
signal sig_JumpAddress : STD_LOGIC_VECTOR(31 downto 0);
signal sig_WD : STD_LOGIC_VECTOR(31 downto 0);

-- IF_ID
signal PCInc_IF_ID, Instruction_IF_ID: STD_LOGIC_VECTOR(31 downto 0);

-- ID_EX
signal PCInc_ID_EX, RD1_ID_EX, RD2_ID_EX, Ext_imm_ID_EX : STD_LOGIC_VECTOR(31 downto 0);
signal func_ID_EX : std_logic_vector(5 downto 0);
signal sa_ID_EX, rt_ID_EX, rd_ID_EX : std_logic_vector(4 downto 0);
signal ALUOp_ID_EX : std_logic_vector(2 downto 0);
-- AICI ERA EROAREA TA: Semnalele astea sunt de 1 bit!
signal MemtoReg_ID_EX, RegWrite_ID_EX, MemWrite_ID_EX, Branch_ID_EX, ALUSrc_ID_EX, RegDst_ID_EX : STD_LOGIC;

-- EX_MEM
signal BranchAddress_EX_MEM, ALURes_EX_MEM, RD2_EX_MEM : STD_LOGIC_VECTOR(31 downto 0);
signal wa_EX_MEM : std_logic_vector(4 downto 0); -- Write Address calculat
signal zero_EX_MEM, MemtoReg_EX_MEM, RegWrite_EX_MEM, MemWrite_EX_MEM, Branch_EX_MEM : STD_LOGIC;

-- MEM_WB
signal MemData_MEM_WB, ALURes_MEM_WB : std_logic_vector(31 downto 0);
signal wa_MEM_WB : std_logic_vector(4 downto 0);
signal MemtoReg_MEM_WB, RegWrite_MEM_WB : STD_LOGIC;

begin

display: SSD port map(clk => clk, digits => digit, an => an, cat => cat);
mepegeu0: MPG port map(CLK => clk, btn => btn(0), en => enable_cnt0);

core_en <= '1' when sw(15) = '1' else enable_cnt0;

inst_IF : IFetch port map(
    clk => clk, en => core_en, jmp => Jump, pcsrc => sig_PCSrc, 
    JAddr => sig_JumpAddress, Baddr => BranchAddress_EX_MEM, 
    instruction => sig_instruction, pc_1 => sig_pc_1
);


sig_JumpAddress <= PCInc_IF_ID(31 downto 26) & Instruction_IF_ID(25 downto 0);

inst_MC : MainControl port map(
    Opcode => Instruction_IF_ID(31 downto 26), 
    RegDst => RegDst, ExtOp => ExtOp, ALUSrc => ALUSrc, Branch => Branch, Jump => Jump, 
    ALUOp => ALUOp, MemWrite => MemWrite, MemtoReg => MemtoReg, RegWrite => RegWrite
);

inst_DEC : IDecoder port map(
    clk => clk, 
    RegWrite => RegWrite_MEM_WB, 
    Instr => Instruction_IF_ID(25 downto 0), 
    WA => wa_MEM_WB,             
    ExtOp => ExtOp, WD => sig_WD, RD1 => sig_RD1, RD2 => sig_RD2, 
    ext_imm => sig_ext_imm, func => sig_func, sa => sig_sa
);

Ex_inst: inst_EX port map(
    PCinc => PCInc_ID_EX, RD1 => RD1_ID_EX, RD2 => RD2_ID_EX, 
    Ext_Imm => Ext_imm_ID_EX, func => func_ID_EX, sa => sa_ID_EX, 
    ALUSrc => ALUSrc_ID_EX, ALUOp => ALUOp_ID_EX, 
    BranchAddress => BranchAddress, ALURes => ALURes, Zero => zero
);

ram_mem: MEM port map(
    clk => clk, en => core_en, 
    ALUResIn => ALURes_EX_MEM, RD2 => RD2_EX_MEM, MemWrite => MemWrite_EX_MEM, 
    MemData => memdata, ALUResOut => aluresout   
);

sig_PCSrc <= (not zero_EX_MEM) and Branch_EX_MEM;

with MemtoReg_MEM_WB select 
    sig_WD <= MemData_MEM_WB when '1',
              ALURes_MEM_WB when '0',
              (others => 'X') when others;

process(clk)
begin
    if rising_edge(clk) and core_en = '1' then
        PCInc_IF_ID <= sig_pc_1;
        Instruction_IF_ID <= sig_instruction;
        
        PCInc_ID_EX <= PCInc_IF_ID;
        RD1_ID_EX <= sig_RD1;
        RD2_ID_EX <= sig_RD2;
        Ext_imm_ID_EX <= sig_ext_imm;
        sa_ID_EX <= sig_sa;
        func_ID_EX <= sig_func;
        
        rt_ID_EX <= Instruction_IF_ID(20 downto 16);
        rd_ID_EX <= Instruction_IF_ID(15 downto 11);
        
        RegDst_ID_EX <= RegDst;
        ALUSrc_ID_EX <= ALUSrc;
        ALUOp_ID_EX <= ALUOp;
        Branch_ID_EX <= Branch;
        MemWrite_ID_EX <= MemWrite;
        MemtoReg_ID_EX <= MemtoReg;
        RegWrite_ID_EX <= RegWrite;

        BranchAddress_EX_MEM <= BranchAddress;
        ALURes_EX_MEM <= ALURes;
        RD2_EX_MEM <= RD2_ID_EX; 
        zero_EX_MEM <= zero;
        
        if RegDst_ID_EX = '1' then
            wa_EX_MEM <= rd_ID_EX;
        else
            wa_EX_MEM <= rt_ID_EX;
        end if;

        Branch_EX_MEM <= Branch_ID_EX;
        MemWrite_EX_MEM <= MemWrite_ID_EX;
        MemtoReg_EX_MEM <= MemtoReg_ID_EX;
        RegWrite_EX_MEM <= RegWrite_ID_EX;

        MemData_MEM_WB <= memdata;
        ALURes_MEM_WB <= aluresout;
        wa_MEM_WB <= wa_EX_MEM; 
        
        MemtoReg_MEM_WB <= MemtoReg_EX_MEM;
        RegWrite_MEM_WB <= RegWrite_EX_MEM;
    end if;
end process;

process(sw, sig_instruction, PCInc_IF_ID, sig_RD1, sig_RD2, sig_ext_imm, ALURes_EX_MEM, memdata)
begin
    case sw(7 downto 5) is
        when "000" => digit <= sig_instruction;
        when "001" => digit <= PCInc_IF_ID;
        when "010" => digit <= sig_RD1;
        when "011" => digit <= sig_RD2;
        when "100" => digit <= sig_ext_imm;
        when "101" => digit <= ALURes_EX_MEM;
        when "110" => digit <= memdata;
        when "111" => digit <= sig_WD;
        when others => digit <= (others => '0');
    end case;
end process;

led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;
led(15 downto 11) <= (others => '0');

end Behavioral;