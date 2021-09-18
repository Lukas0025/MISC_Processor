-- Minimalistic Core
-- counter exmaple code
-- author: Lukáš Plevač <lukas@plevac.eu>

library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use WORK.core;

entity core_counter is		
Port (  
	CLK   : in    STD_LOGIC;
	COUNT : out   STD_LOGIC_VECTOR(7 downto 0)
);
end core_counter;

architecture Behavioral of core_counter is
type rom_type is array (0 to 8) of std_logic_vector(7 downto 0);
signal addr     : std_logic_vector(9 downto 0);  -- ADDR for prog mem

-- core program
signal prog_ROM : rom_type := (		 
	"11000000", -- LDI A, 0
    "00000000",
		 
	"11001000", -- LDI B, 1
    "00000001",
		 
	"01100000", -- A + B => A

    "01010011", -- BUS(1111 1111 11) <= A
    "11111111",
		 
	"10000000", -- JMP 0x4
	"00000100"
);

begin
	-- map Core
	core_comp: core
	port map(
		-- Basic 
		CLK        => CLK,
        RESET      => '0',
        EN         => '1',
			  
		-- BUS
		BINDIRIN   => "00000000", -- NC
		BINDIROUT  => COUNT,      -- out BUS from core
			  
		-- Prog mem
		PROG_DATA  => prog_ROM(to_integer(unsigned(addr))),   -- data from prog mem
		PROG_ADDR  => addr    -- addr for  prog mem
	);
	
end Behavioral;