-- Minimalistic Core
-- Full testing component for core
-- author: Lukáš Plevač <lukas@plevac.eu>

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.core;

entity core_test1 is		
    Port ( 
			  -- Basic 
			  CLK        : in    STD_LOGIC;
           RESET      : in    STD_LOGIC;
           EN         : in    STD_LOGIC;
			  BINDIROUT  : out   STD_LOGIC_VECTOR(7 downto 0);
			  BINDIRADDR : out   STD_LOGIC_VECTOR(9 downto 0);   -- 8bit bus adddr
			  BINDIRWE   : out   STD_LOGIC;
			  BINDIRUSE  : out   STD_LOGIC
			);
end core_test1;

architecture Behavioral of core_test1 is

constant NOP_OP  : std_logic_vector(2 downto 0):= "000";
constant MOV_OP  : std_logic_vector(2 downto 0):= "001";
constant BUS_OP  : std_logic_vector(2 downto 0):= "010";
constant ALU_OP  : std_logic_vector(2 downto 0):= "011";
constant JMP_OP  : std_logic_vector(2 downto 0):= "100";
constant JZN_OP  : std_logic_vector(2 downto 0):= "101";
constant LDI_OP  : std_logic_vector(2 downto 0):= "110";
constant HALT_OP : std_logic_vector(2 downto 0):= "111";

type rom_type is array (0 to 15) of std_logic_vector(7 downto 0);

signal addr : std_logic_vector(9 downto 0);  

-- 
-- NOP
-- LDI D, 4
-- LDI A, 1
-- LDI B, 1 (A*)
-- ADD A
-- BUS [write] A 1111 1111 11
-- MOV D, B
-- SUB C
-- JZ B*
-- JMP A*
-- HALT (B*)
--
signal prog_ROM : rom_type := (
		 LDI_OP & "11000", -- LDI D, 00000100
       "00000100", -- CONST
       LDI_OP & "00000", -- LDI A, 00000001
       "00000001", -- CONST
		 LDI_OP & "01000", -- LDI B, 00000001
       "00000001", -- CONST
		 ALU_OP & "00000", -- ALU ADD A, B => A
		 BUS_OP & "10011", -- reg[0] => BUS[others => 1]
		 "11111111",
		 MOV_OP & "11010", -- D => B
		 ALU_OP & "10010", -- ALU SUB A, B => C
		 JZN_OP & "10100", -- JZ C 0xE
		 "00001110", -- ADDR
       JMP_OP & "00000", -- JMP 0x4
       "00000100", -- ADDR
       "11111111" -- HALT
);

begin

	core_comp: core
	port map(
			  -- Basic 
			  CLK        => CLK,
           RESET      => RESET,
           EN         => EN,
			  
			  -- BUS
			  BINDIRIN   => "00000001",
			  BINDIROUT  => BINDIROUT,   -- 8bit bus
			  BINDIRADDR => BINDIRADDR,   -- 8bit bus adddr
			  BINDIRWE   => BINDIRWE,
			  BINDIRUSE  => BINDIRUSE,
			  
			  -- Prog mem
			  PROG_DATA  => prog_ROM(to_integer(unsigned(addr))),   -- data from prog mem
			  PROG_ADDR  => addr    -- addr for  prog mem
	);
	
end Behavioral;
