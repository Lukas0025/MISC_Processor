# MISC_Processor
VHDL Minimal instruction set computer Processor

### Iscruction set

| ASM         | Pseudo code                       | OP Code |   Binary               |
| ----------- | --------------------------------- |---------|------------------------|
| NOP         |                                   |   000   | `000X XXXX`            |
| MOV         | REG(S) => REG(D)                  |   001   | `001S SDDX`            |
| BUS         | BUS(A) <=> REG(R) (w=1 for write) |   010   | `010W RRAA AAAA AAAA`  |
| ALU         | REG(D) <= ALU(REG(0), REG(1), O)  |   011   | `011R ROOO`            |
| JMP         | PC <= A                           |   100   | `100X XXAA AAAA AAAA`  |
| JZ/JNZ      | PC <= if REG(R) == 0 (I=1 -> not) |   101   | `101R RIAA AAAA AAAA`  |
| LDI         | REG(D) <= C                       |   110   | `110R RXXX CCCC CCCC`  |
| HALT        | PC <= PC                          |   111   | `111X XXXX`            |

### Use in your poroject

#### files to copy
```
vhdl/*
```

#### core ports
```vhdl
-- Basic 
CLK        : in    STD_LOGIC; -- clock
RESET      : in    STD_LOGIC; -- reset signal, sync with CLK
EN         : in    STD_LOGIC; -- enable signal if 1 core working 
			  
-- BUS
BINDIRIN   : in    STD_LOGIC_VECTOR(7 downto 0);   -- 8bit bus (input form BUS)
BINDIROUT  : out   STD_LOGIC_VECTOR(7 downto 0);   -- 8bit bus (output to BUS)
BINDIRADDR : out   STD_LOGIC_VECTOR(9 downto 0);   -- 8bit bus adddr
BINDIRWE   : out   STD_LOGIC;                      -- bus write (write data to bus)
BINDIRUSE  : out   STD_LOGIC;                      -- use bus (read or write)
			  
-- Prog mem
PROG_DATA  : in    STD_LOGIC_VECTOR(7 downto 0);   -- data from prog mem
PROG_ADDR  : out   STD_LOGIC_VECTOR(9 downto 0)    -- addr for  prog mem
```

#### vhdl example
```vhdl
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
```

### Makefile

```sh
make project    # make quartus project dir with quartus simulations for edit code
make clean      # remove project dir with quartus project
```