-- Minimalistic Core
-- led blink exmaple code
-- author: Lukáš Plevač <lukas@plevac.eu>

library IEEE;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use WORK.core;

entity core_blink is		
    Port (  
			  CLK : in    STD_LOGIC;
			  EN  : out   STD_LOGIC
			);
end core_blink;

architecture Behavioral of core_blink is
type rom_type is array (0 to 17) of std_logic_vector(7 downto 0);
signal addr     : std_logic_vector(9 downto 0);  
signal BINDIROUT: std_logic_vector(7 downto 0); 

-- core program
signal prog_ROM : rom_type := (		 
       "00111010", -- MOV D, B
		 
		 "11000000", -- LDI A, -128
       "11111111",
		 
		 "01111110", -- A xor B => D
		 
		 "01011111", -- BUS[1111111111] D
		 "11111111",
		 
		 "11000000", -- LDI A, 1
       "00000001",
		 
		 "11001000", -- LDI B, 1
       "00000001",
		 
		 
		 "01100000", -- A + B => A
		 
		 "11001000", -- LDI B, 127
       "01111111",
		 
		 "01110010", -- A - B => C
		 
		 "10110000", -- JNZ C, 0x8
		 "00001000",
		 
		 "10000000", -- JMP 0x0
		 "00000000"
);

signal count:  STD_LOGIC_VECTOR(0 downto 0) := (others => '0'); -- inc bits count for slow down CLK (11-12bits for 20MHZ)
signal in_clk: STD_LOGIC := '0';

begin

	-- counter to slow down inner CLK
	process (CLK)
	begin
		if (rising_edge(CLK)) then
			
			if (count = 0) then
				in_clk <= not in_clk;
			end if;
			
			count <= count + 1;
		end if;
	end process;
	
	-- map LED pin to CORE BUS (as bit 0)
	EN <= BINDIROUT(0);

	-- map Core
	core_comp: core
	port map(
			  -- Basic 
			  CLK        => in_clk,
           RESET      => '0',
           EN         => '1',
			  
			  -- BUS
			  BINDIRIN   => "00000000", -- NC
			  BINDIROUT  => BINDIROUT,  -- We use only one bit for led
			  
			  -- Prog mem
			  PROG_DATA  => prog_ROM(to_integer(unsigned(addr))),   -- data from prog mem
			  PROG_ADDR  => addr    -- addr for  prog mem
	);
	
end Behavioral;
