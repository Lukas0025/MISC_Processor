-- Minimalistic Core implemenation
-- opeartions:
-- NOP
-- MOV
-- BUS
-- ALU
-- JMP
-- JZ/JNZ
-- LDI
-- HALT
--
-- author: Lukáš Plevač <lukas@plevac.eu>

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.ALL;
use WORK.alu;

entity core is		
    Port ( 
			  -- Basic 
			  CLK        : in    STD_LOGIC;
           RESET      : in    STD_LOGIC;
           EN         : in    STD_LOGIC;
			  
			  -- BUS
			  BINDIRIN   : in    STD_LOGIC_VECTOR(7 downto 0);   -- 8bit bus
			  BINDIROUT  : out   STD_LOGIC_VECTOR(7 downto 0);   -- 8bit bus
			  BINDIRADDR : out   STD_LOGIC_VECTOR(9 downto 0);   -- 8bit bus adddr
			  BINDIRWE   : out   STD_LOGIC;
			  BINDIRUSE  : out   STD_LOGIC;
			  
			  -- Prog mem
			  PROG_DATA  : in    STD_LOGIC_VECTOR(7 downto 0);   -- data from prog mem
			  PROG_ADDR  : out   STD_LOGIC_VECTOR(9 downto 0)    -- addr for  prog mem
			);
end core;

architecture Behavioral of core is

-- OP codes
constant NOP_OP  : std_logic_vector(2 downto 0):= "000";
constant MOV_OP  : std_logic_vector(2 downto 0):= "001";
constant BUS_OP  : std_logic_vector(2 downto 0):= "010";
constant ALU_OP  : std_logic_vector(2 downto 0):= "011";
constant JMP_OP  : std_logic_vector(2 downto 0):= "100";
constant JZN_OP  : std_logic_vector(2 downto 0):= "101";
constant LDI_OP  : std_logic_vector(2 downto 0):= "110";
constant HALT_OP : std_logic_vector(2 downto 0):= "111";

-- types
type states is (S_FETCH, S_DECODE, S_WRITE_BACK, S_HALT);
type reg_file is array (0 to 3) of std_logic_vector(7 downto 0);

-- inner signals
signal pc         : std_logic_vector(9 downto 0)  := (others => '0');
signal ir         : std_logic_vector(7 downto 0);
signal alu_op_sig : std_logic_vector(2 downto 0);
signal alu_out    : std_logic_vector(7 downto 0);
signal regs       : reg_file;

signal state: states := S_FETCH;

begin
	
	process (CLK, RESET)
	begin
		if (RESET = '1') then
			pc        <= (others => '0');
			state     <= S_FETCH;
			BINDIRUSE <= '0';
		elsif (rising_edge(CLK) and EN = '1') then
			
			if (state = S_FETCH) then
				ir    <= PROG_DATA;
				state <= S_DECODE;
				pc    <= pc + 1;
			elsif (state = S_DECODE) then
				case ir(7 downto 5) is
					when NOP_OP =>
							state                                       <= S_FETCH;
							
					when MOV_OP =>
							regs(to_integer(unsigned(ir(2 downto 1))))  <= regs(to_integer(unsigned(ir(4 downto 3))));
							state                                       <= S_FETCH;
							
					when BUS_OP =>
							BINDIROUT                                   <= regs(to_integer(unsigned(ir(3 downto 2))));
							BINDIRWE                                    <= ir(4);
							BINDIRUSE                                   <= '1';
							BINDIRADDR                                  <= ir(1 downto 0) & PROG_DATA;
							pc                                          <= pc + 1;
							state                                       <= S_FETCH;
							
							if (ir(4) = '0') then
								state                                    <= S_WRITE_BACK;
							end if;
							
					when ALU_OP =>
							alu_op_sig                                  <= ir(2 downto 0);
							state                                       <= S_WRITE_BACK;
							
					when JMP_OP =>
							pc                                          <= ir(1 downto 0) & PROG_DATA;
							state                                       <= S_FETCH;
							
					when JZN_OP =>
							if (regs(to_integer(unsigned(ir(4 downto 3)))) = 0) then
								if (ir(2) = '1') then
									pc                                    <= ir(1 downto 0) & PROG_DATA;
								else
									pc                                    <= pc + 1;
								end if;
							else
								if (ir(2) = '0') then
									pc                                    <= ir(1 downto 0) & PROG_DATA;
								else
									pc                                    <= pc + 1;
								end if;
							end if;
							
							state                                       <= S_FETCH;
							
					when LDI_OP =>
							regs(to_integer(unsigned(ir(4 downto 3))))  <= PROG_DATA;
							pc                                          <= pc + 1;
							state                                       <= S_FETCH;   
							
					when HALT_OP =>
							state                                       <= S_HALT;
							
				end case;
			elsif (state = S_WRITE_BACK) then
				case ir(7 downto 5) is
					when BUS_OP =>
							BINDIRUSE                                  <= '0';
							regs(to_integer(unsigned(ir(3 downto 2)))) <= BINDIRIN;
							state                                      <= S_FETCH;
							
					when ALU_OP =>
							regs(to_integer(unsigned(ir(4 downto 3)))) <= alu_out;
							state                                      <= S_FETCH;
					when others =>
							state                                      <= S_FETCH;
				end case;
			end if;
		end if;
	end process;
	
	in_alu: alu
	port map(
		OP     => alu_op_sig,
		A      => regs(0),
		B      => regs(1),
		OUTPUT => alu_out
	);
	
	PROG_ADDR <= pc;
	
end Behavioral;
