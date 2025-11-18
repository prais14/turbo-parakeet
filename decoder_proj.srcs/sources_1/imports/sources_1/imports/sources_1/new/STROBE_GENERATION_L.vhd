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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity STROBE_GENERATION_L is
  Port ( 
        clk         : in std_logic;
        rst         : in std_logic;
        strobe_1_th : in std_logic_vector(31 downto 0);
        strobe_1    : out std_logic
  );
end STROBE_GENERATION_L;

architecture Behavioral of STROBE_GENERATION_L is

signal clk_counter  : std_logic_vector(31 downto 0) := (others=> '0');
--signal clk_cycle_threshold_selection	: std_logic_vector (2 downto 0) := "001";
--signal clk_cycle_threshold 				: integer;

begin

	strobe_out : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                strobe_1 <= '0';
                clk_counter <= (others => '0');
            else
				--if clk_counter = 5 then -- use 5 clock cycles for simulation instead of 25 million
				--case clk_cycle_threshold_selection is
				--	  when "000" => clk_cycle_threshold <= 5-1; -- 5cc for testing
				--	  when "001" => clk_cycle_threshold <= 10-1; -- 10cc for testing
				--	  when "010" => clk_cycle_threshold <= 25_000_000-1; -- half a second flash cycle
				--	  when "011" => clk_cycle_threshold <= 12_500_000-1; -- quarter second flash cycle
				--	  when others => clk_cycle_threshold <= 50_000_000-1; -- 1 sec default
				--end case;
                if (Unsigned(clk_counter) >= unsigned(strobe_1_th)) then 
                    strobe_1 <= '1';
                    clk_counter <= (others => '0');
                else
                    strobe_1 <= '0';
                    clk_counter <= std_logic_vector(Unsigned(clk_counter) + 1);
                end if;
            end if;
        end if;
    end process strobe_out;
 

end Behavioral;
