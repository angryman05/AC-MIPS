library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity inst_EX is
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
end inst_EX;

architecture Behavioral of inst_EX is

signal ALUin2 : std_logic_vector(31 downto 0);
signal ALUCtrl : std_logic_vector(2 downto 0);
signal C : std_logic_vector(31 downto 0);

signal x1 : std_logic_vector(31 downto 0);
signal x2 : std_logic_vector(31 downto 0);


begin 

with alusrc select 
    ALUin2 <= RD2 when '0', Ext_Imm when '1',(others => 'X') when others;

process(ALUOp,func)
begin
    case ALUOp is
        when "000" => -- R-Type
            case func is
                when "100000" => ALUCtrl <= "000"; -- add (MIPS standard)
                when "100010" => ALUCtrl <= "001"; -- sub (MIPS standard)
                when "000000" => ALUCtrl <= "010"; -- sll (MIPS standard)
                when "000010" => ALUCtrl <= "011"; -- srl (MIPS standard)
                when "100100" => ALUCtrl <= "100"; -- and (MIPS standard)
                when "100101" => ALUCtrl <= "101"; -- or  (MIPS standard)
                when "100110" => ALUCtrl <= "110"; -- xor (MIPS standard)
                when "101010" => ALUCtrl <= "111"; -- slt (MIPS standard)
                when others => ALUCtrl <= (others => '0'); -- Siguranta
            end case;
        
        when "001" => ALUCtrl <= "000"; -- + (Pentru ADDI, LW, SW)
        when "010" => ALUCtrl <= "001"; -- - (Pentru BEQ, BNE)
        when "101" => ALUCtrl <= "100"; -- & (And Imediat)
        when "110" => ALUCtrl <= "101"; -- | (Or Imediat)
        when others => ALUCtrl <= (others => '0'); 
    end case;
end process;

process(ALUCtrl, RD1, ALUin2, sa)
begin
    case ALUCtrl is
        when "000" => C <= RD1 + ALUin2;
        when "001" => C <= RD1 - ALUin2;
        when "010" => C <= to_stdlogicvector(to_bitvector(ALUin2) sll conv_integer(sa));
        when "011" => C <= to_stdlogicvector(to_bitvector(ALUin2) srl conv_integer(sa));
        when "100" => C <= RD1 and ALUin2;
        when "101" => C <= RD1 or ALUin2;
        when "110" => C <= RD1 xor ALUin2;
        when "111" => 
                if signed(RD1) < signed(ALUin2) then
                    C <= x"00000001";
                else
                    C <= x"00000000";
                end if;
        when others => C <= (others => 'X');
    end case;
end process;

ALURes <= C;
Zero <= '1' when C = x"00000000" else '0';
BranchAddress <= PCinc + Ext_Imm;

end Behavioral;
