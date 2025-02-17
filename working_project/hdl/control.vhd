--------------------------------------------------------------------------------
-- KU Leuven - ESAT/COSIC - Emerging technologies, Systems & Security
--------------------------------------------------------------------------------
-- Module Name:     control - Behavioural
-- Project Name:    HWSWCD
-- Description:     
--
-- Revision     Date       Author     Comments
-- v0.1         20241126   VlJo       Initial version
--
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.NUMERIC_STD.ALL;

entity control is
    port(
        opcode : in std_logic_vector(6 downto 0);
        funct3 : in std_logic_vector(2 downto 0);
        funct7 : in std_logic_vector(6 downto 0);

        ToRegister : out std_logic_vector(2 downto 0);
        mem_we : out std_logic;
        Branch : out std_logic_vector(3 downto 0);
        ALUOp : out std_logic_vector(2 downto 0);
        StoreSel : out std_logic_vector(1 downto 0);
        ALUSrc : out std_logic;
        regfile_we : out std_logic;
        arith_logic_b : out STD_LOGIC;
        signed_unsigned_b : out STD_LOGIC;
        result_filter : out STD_LOGIC_VECTOR(1 downto 0)
    );

end entity control;

architecture Behavioural of control is

    -- (DE-)LOCALISING IN/OUTPUTS
    signal opcode_i : std_logic_vector(6 downto 0);
    signal funct3_i : std_logic_vector(2 downto 0);
    signal funct7_i : std_logic_vector(6 downto 0);

    signal ToRegister_o : std_logic_vector(2 downto 0);
    signal mem_we_o : std_logic;
    signal branch_o : std_logic_vector(3 downto 0);
    signal ALUOp_o : std_logic_vector(2 downto 0);
    signal StoreSel_o : std_logic_vector(1 downto 0);
    signal ALUSrc_o : std_logic;
    signal regfile_we_o : std_logic;
    signal arith_logic_b_o : STD_LOGIC;
    signal signed_unsigned_b_o : STD_LOGIC;
    signal result_filter_o : STD_LOGIC_VECTOR(1 downto 0);

begin

    -------------------------------------------------------------------------------
    -- (DE-)LOCALISING IN/OUTPUTS
    -------------------------------------------------------------------------------
    opcode_i <= opcode;
    funct3_i <= funct3;
    funct7_i <= funct7;

    branch <= branch_o;
    mem_we <= mem_we_o;
    arith_logic_b <= arith_logic_b_o;
    signed_unsigned_b <= signed_unsigned_b_o;
    result_filter <= result_filter_o;
    StoreSel <= StoreSel_o;


    regfile_we <= regfile_we_o;

    process(opcode_i, funct7, funct3)
    begin
        case opcode_i is
-- R TYPE -----------------------------------------------------------------------------
            when "0110011" =>
                branch_o <= "0000";
                mem_we_o <= '0';
                StoreSel_o <= "00";
                arith_logic_b_o <= '0';
                signed_unsigned_b_o <= '0';
                result_filter_o <= "00";

                case funct3 is
                    when "000" =>
                        ToRegister <= "000";
                        case funct7 is
                            when "0000000" =>               --ADD
                                ALUSrc      <= '1';                                
                                ALUOp       <= "100";
                                regfile_we_o    <= '1';
                            when "0100000" =>               --SUB
                                ALUSrc      <= '1';
                                ALUOp       <= "101";
                                regfile_we_o    <= '1';                             
 							when others =>                  --not included instructions
                                ALUSrc      <= '0';
                                ALUOp       <= "000";
                                regfile_we_o    <= '0'; 
                        end case;
                    when "001" =>                    --SLL
                        ToRegister <= "000";
                        ALUSrc      <= '1';
                        ALUOp       <= "110";
                        regfile_we_o    <= '1';	   
                    when "010" =>                    --SLT
                        ToRegister <= "000";
                        ALUSrc      <= '1';
                        ALUOp       <= "011";
                        regfile_we_o    <= '1';
                        signed_unsigned_b_o <= '1';
                    when "011" =>                    --SLTU
                        ToRegister <= "000";
                        ALUSrc      <= '1';
                        ALUOp       <= "011";
                        regfile_we_o    <= '1';
                        signed_unsigned_b_o <= '0';
                    when "100" =>                   --XOR
                        ToRegister <= "000";
                        ALUSrc      <= '1';
                        ALUOp       <= "010";
                        regfile_we_o    <= '1';
                    when "101"  =>                  --SRx
                        ToRegister <= "000";
                        ALUSrc      <= '1';
                        ALUOp       <= "111";
                        regfile_we_o    <= '1';
                        case funct7 is
                            when "0000000" =>               --SRL
                                arith_logic_b_o <= '0';
                            when "0100000" =>               --SRA
                                arith_logic_b_o <= '1';                   
                            when others =>                  --not included instructions
                                arith_logic_b_o <= '0';
                        end case;
                    when "110"  =>                  --OR
                        ToRegister <= "000";
                        ALUSrc      <= '1';
                        ALUOp       <= "001";
                        regfile_we_o    <= '1';
                    when "111"  =>                  --AND
                        ToRegister <= "000";
                        ALUSrc      <= '1';
                        ALUOp       <= "000";
                        regfile_we_o    <= '1';
                    when others =>
                        ToRegister <= "000";
                        ALUSrc      <= '0';
                        ALUOp       <= "000";
                        regfile_we_o    <= '0';
                end case;
-- I TYPE - ALU ----------------------------------------------------------------
            when "0010011" =>
                branch_o <= "0000";
                mem_we_o <= '0';
                StoreSel_o <= "00";
                ToRegister <= "000";
                ALUSrc      <= '0';
                result_filter_o <= "00";

                case funct3 is
                    when "000" =>                   --ADDI
                        arith_logic_b_o <= '0';
                        signed_unsigned_b_o <= '0';
                        ALUOp       <= "100";
                        regfile_we_o    <= '1';
                    when "001" =>                   -- SSLI
                        arith_logic_b_o <= '0';
                        signed_unsigned_b_o <= '0';
                        ALUOp       <= "110";
                        regfile_we_o    <= '1';	   
                    when "010" =>                   --SLTI
                        arith_logic_b_o <= '0';
                        ALUOp       <= "011";
                        regfile_we_o    <= '1';
                        signed_unsigned_b_o <= '1';
                    when "011" =>                   --SLTIU
                        arith_logic_b_o <= '0';
                        ALUOp       <= "011";
                        regfile_we_o    <= '1';
                        signed_unsigned_b_o <= '0';
                    when "101"  =>                  --SRxI
                        signed_unsigned_b_o <= '0';
                        ALUOp       <= "111";
                        regfile_we_o    <= '1';
                        case funct7 is
                            when "0000000" =>               --SRLI
                                arith_logic_b_o <= '0';
                            when "0100000" =>               --SRAI
                                arith_logic_b_o <= '1';                   
                            when others =>                  --not included instructions
                                arith_logic_b_o <= '0';
                        end case;
                    when "111" =>                   --ANDI
                        arith_logic_b_o <= '0';
                        signed_unsigned_b_o <= '0';
                        ALUOp       <= "000";
                        regfile_we_o    <= '1';
                    when "100" =>                   --XORI
                        arith_logic_b_o <= '0';
                        signed_unsigned_b_o <= '0';
                        ALUOp       <= "010";
                        regfile_we_o    <= '1';
                    when "110" =>                   --ORI
                        arith_logic_b_o <= '0';
                        signed_unsigned_b_o <= '0';
                        ALUOp       <= "001";
                        regfile_we_o    <= '1';
                    when others =>
                        arith_logic_b_o <= '0';
                        signed_unsigned_b_o <= '0';
                        ALUOp       <= "000";
                        regfile_we_o    <= '0';                                      
                end case;
-- I TYPE - LOAD ---------------------------------------------------------------
            when "0000011" =>
                ALUSrc <= '0'; -- zorgt voor immediate
                branch_o <= "0000";
                mem_we_o <= '0'; -- zorgt voor Rd from Mem
                arith_logic_b_o <= '0';
                signed_unsigned_b_o <= '0';
                StoreSel_o <= "00";
                case funct3 is
                        when "000" =>                   --LB
                            ToRegister <= "010";
                            result_filter_o <= "01";
                            ALUOp       <= "100";
                            regfile_we_o    <= '1';
                        when "001" =>                   --LH
                            ToRegister <= "010";
                            result_filter_o <= "11";
                            ALUOp       <= "100";
                            regfile_we_o    <= '1';
                        when "010" =>                   --LW
                            ToRegister <= "001";
                            result_filter_o <= "01";
                            ALUOp       <= "100";
                            regfile_we_o    <= '1';
                        when "100" =>                   --LBU
                            ToRegister <= "010";
                            result_filter_o <= "00";
                            ALUOp       <= "100";
                            regfile_we_o    <= '1';
                        when "101" =>                   --LHU
                            ToRegister <= "010";
                            result_filter_o <= "10";
                            ALUOp       <= "100";
                            regfile_we_o    <= '1';
                        when others =>
                            ToRegister <= "000";
                            result_filter_o <= "00";
                            ALUOp       <= "000";
                            regfile_we_o    <= '0';   
                end case;
-- S TYPE ----------------------------------------------------------------------
            when "0100011" =>
                branch_o <= "0000";
                ToRegister <= "000";
                ALUSrc      <= '0';
                regfile_we_o    <= '0';
                arith_logic_b_o <= '0';
                signed_unsigned_b_o <= '0';
                result_filter_o <= "00";
                case funct3 is
                    when "000" =>                   --SB
                        mem_we_o <= '1';
                        StoreSel_o <= "01";
                        ALUOp       <= "100";
                    when "001" =>                   --SH
                        mem_we_o <= '1';
                        StoreSel_o <= "10";
                        ALUOp       <= "100";
                    when "010" =>                   --SW
                        mem_we_o <= '1';
                        StoreSel_o <= "00";
                        ALUOp       <= "100";
                    when others =>
                        mem_we_o <= '0';
                        StoreSel_o <= "00";
                        ALUOp       <= "000";
                end case;
-- B TYPE ----------------------------------------------------------------------
            when "1100011" =>
                ToRegister <= "000";
                mem_we_o <= '0';
                StoreSel_o <= "00";
                regfile_we_o    <= '0';
                arith_logic_b_o <= '0';
                signed_unsigned_b_o <= '0';
                result_filter_o <= "00";
                case funct3 is
                    when "000" =>                   --BEQ
                        branch_o <= "1001";
                        ALUSrc      <= '1';
                        ALUOp       <= "101";
                    when "001" =>                   --BNQ
                        branch_o <= "1010";
                        ALUSrc      <= '1';
                        ALUOp       <= "101";
                    when "100" =>                  --BLT
                        branch_o <= "1011";
                        ALUSrc      <= '1';
                        ALUOp       <= "101";
                    when "101" =>                  --BGE
                        branch_o <= "1100";
                        ALUSrc      <= '1';
                        ALUOp       <= "101";
                    when "110" =>                  --BLTU
                        branch_o <= "1000";
                        ALUSrc      <= '1';
                        ALUOp       <= "101";
                    when "111" =>                  --BGEU
                        branch_o <= "1111";
                        ALUSrc      <= '1';
                        ALUOp       <= "101";
                    when others =>
                        branch_o <= "1000";
                        ALUSrc      <= '0';
                        ALUOp       <= "000";
                end case;
-- J TYPE ----------------------------------------------------------------------
            when "1101111" =>                  --JAL
                branch_o <= "1101";
                ToRegister <= "101";
                mem_we_o <= '0';
                StoreSel_o <= "00";
                ALUSrc <= '1';
                ALUOp <= "101";
                regfile_we_o <= '1';
                arith_logic_b_o <= '0';
                signed_unsigned_b_o <= '0';
                result_filter_o <= "00";
-- remaining -------------------------------------------------------------------
            when "1100111" =>
                mem_we_o <= '0';
                StoreSel_o <= "00";
                arith_logic_b_o <= '0';
                signed_unsigned_b_o <= '0';
                result_filter_o <= "00";
                if funct3 = "000" then                   --JALR
                    branch_o <= "1110";
                    ToRegister <= "011";           --PC
                    ALUSrc <= '1';
                    ALUOp <= "101";
                    regfile_we_o <= '1';
                else
                    ToRegister <= "000";
                    regfile_we_o <= '0';
                    branch_o <= "0000";
                    ALUSrc <= '0';
                    ALUOp <= "000";
                end if;
-- U TYPE ----------------------------------------------------------------------
            when "0110111" =>                               -- LUI
                mem_we_o <= '0';
                StoreSel_o <= "00";
                arith_logic_b_o <= '0';
                signed_unsigned_b_o <= '0';
                result_filter_o <= "00";
                ToRegister <= "100";
                regfile_we_o <= '1';
                branch_o <= "0000";
                ALUSrc <= '0';
                ALUOp <= "000";

            when "0010111" =>
                mem_we_o <= '0';
                StoreSel_o <= "00";
                arith_logic_b_o <= '0';
                signed_unsigned_b_o <= '0';
                result_filter_o <= "00";
                ToRegister <= "111";
                regfile_we_o <= '1';
                branch_o <= "0000";
                ALUSrc <= '0';
                ALUOp <= "000";                
--------------------------------------------------------------------------------
            when others =>                  
                branch_o <= "0000";
                ToRegister <= "000";           
                mem_we_o <= '0';
                StoreSel_o <= "00";
                ALUSrc <= '0';
                ALUOp <= "000";
                regfile_we_o <= '0';
                arith_logic_b_o <= '0';
                signed_unsigned_b_o <= '0';
                result_filter_o <= "00";
        end case;    
    end process;
end Behavioural;
