----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/08/2025 02:13:03 PM
-- Design Name: 
-- Module Name: PULSE_GENERATION - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RESET_GENERATION is
  Port ( 
        clk         : in std_logic;
        rst         : out std_logic := '1'
  );
end RESET_GENERATION;

architecture Behavioral of RESET_GENERATION is

begin

reset_gen   : process (clk)
begin
	if rising_edge(clk) then
		rst <= '0';
    end if;
end process;

end Behavioral;
