----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.11.2025 10:09:11
-- Design Name: 
-- Module Name: strobe_44100 - Behavioral
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

entity strobe_44100 is
    Port ( clk          : in STD_LOGIC;
           rst          : in std_logic ; 
           strobe_44100 : out STD_LOGIC);
end strobe_44100;

architecture Behavioral of strobe_44100 is
    
    signal cnt : integer := 0;
    signal temp_strobe : std_logic := '0';
    
begin

process (clk)
begin
    if rising_edge (clk) then
        if rst = '1' then
             cnt <= 0;
             temp_strobe <= '0';
        else
            if cnt >= 159 then
                temp_strobe <= not temp_strobe;
                cnt <= 0;
            else
                cnt <= cnt + 1;
            end if;
        end if;
    end if;
end process;

strobe_44100 <= temp_strobe;

end Behavioral;
