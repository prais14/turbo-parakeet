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

entity PULSE_GENERATION is
  Port ( 
        clk         : in std_logic;
        rst         : in std_logic;
        strobe_in   : in std_logic;
        pulse_out   : out std_logic
  );
end PULSE_GENERATION;

architecture Behavioral of PULSE_GENERATION is

signal pulse_int	: std_logic := '0';

begin

    pulse_gen   : process(clk)
    begin
        if rising_edge(clk) then
            if strobe_in = '1' then
                pulse_int <= not pulse_int;
				pulse_out <= pulse_int;
            end if;
        end if;
    end process pulse_gen;

end Behavioral;
