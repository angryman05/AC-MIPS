library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MainControl is
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
end MainControl;

architecture Behavioral of MainControl is
begin

    process(Opcode)
    begin
        -- Initializare default (pentru a preveni crearea de Latch-uri)
        RegDst <= '0'; ExtOp <= '0'; ALUSrc <= '0';
        Branch <= '0'; Jump <= '0'; MemWrite <= '0';
        MemtoReg <= '0'; RegWrite <= '0'; ALUOp <= "000";

        case Opcode is
            when "000000" => -- R-Type (add, sub, slt)
                RegDst <= '1';
                RegWrite <= '1';
                ALUOp <= "000"; 

            when "001000" => -- ADDI
                ExtOp <= '1';    -- Sign extend
                ALUSrc <= '1';   -- Imediatul intra in ALU
                RegWrite <= '1'; -- Se scrie in registru
                ALUOp <= "001";  -- Operatie de +

            when "100011" => -- LW (Load Word) - adaugat preventiv
                ExtOp <= '1';
                ALUSrc <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
                ALUOp <= "001";

            when "101011" => -- SW (Store Word) - adaugat preventiv
                ExtOp <= '1';
                ALUSrc <= '1';
                MemWrite <= '1';
                ALUOp <= "001";

            when "000100" => -- BEQ
                ExtOp <= '1';
                Branch <= '1';
                ALUOp <= "010"; -- Operatie de - (scadere pentru comparatie)
                
            when "000101" => -- BNE (folosita in ROM-ul tau)
                ExtOp <= '1';
                Branch <= '1';
                ALUOp <= "010";

            when "000010" => -- JUMP (J)
                Jump <= '1';

            when others =>
                null;
        end case;
    end process;

end Behavioral;