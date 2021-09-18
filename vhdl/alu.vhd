-- Minimalistic ALU implemenation
-- opeartions:
-- 000 ADD
-- 010 SUB
-- 100 AND
-- 110 XOR
-- author: Lukáš Plevač <lukas@plevac.eu>

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity alu is		
    Port (
		OP     : in  STD_LOGIC_VECTOR(2 downto 0);
      A      : in  STD_LOGIC_VECTOR(7 downto 0);
		B      : in  STD_LOGIC_VECTOR(7 downto 0);
		OUTPUT : out STD_LOGIC_VECTOR(7 downto 0)
	 );
end alu;

architecture Behavioral of alu is
begin
	OUTPUT <= A + B   when OP = "000" else 
	          A - B   when OP = "010" else 
	          A AND B when OP = "100" else 
	          A XOR B when OP = "110" else
				 (others => '0'); --HERE is free space for other operations free OP is (001, 011, 101, 111)
end Behavioral;
