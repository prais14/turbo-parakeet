----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/17/2025 01:28:00 PM
-- Design Name: 
-- Module Name: drive_display - Behavioral
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

entity drive_display is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           led_on : in STD_LOGIC;
           addy : in STD_LOGIC_VECTOR (31 downto 0);
		   rom_data	: in STD_LOGIC_VECTOR (31 downto 0);
           seg : out STD_LOGIC_VECTOR (7 downto 0);
           seg_s : out STD_LOGIC_VECTOR (7 downto 0));
end drive_display;

architecture Behavioral of drive_display is

signal cnt			: integer := 0;
signal addy_curr	: STD_LOGIC_VECTOR(3 downto 0);
signal addy_cnt		: integer := 0;
signal addy_test	: STD_LOGIC_VECTOR(31 downto 0) := x"124abcde";
signal disp_data 	: STD_LOGIC_VECTOR(31 downto 0):= x"124abcde";

signal scan_tick	: STD_LOGIC := '0';

begin

process(scan_tick)
begin
	if rising_edge(scan_tick) then
		if rst = '1' then
			addy_cnt <= 0;
		else
			if addy_cnt = 7 then
				addy_cnt <= 0;
			else
				addy_cnt <= addy_cnt + 1;
			end if;
				
		end if;
	end if;
end process;

process(clk)
begin
	if rising_edge(clk) then
		if cnt >= 500 then
			scan_tick <= not scan_tick;
			cnt <= 0;
		else
			cnt <= cnt + 1;
		end if;
	end if;
end process;


disp_data <= rom_data;

with addy_cnt select addy_curr <=
	disp_data(31 downto 28) when 0,
	disp_data(27 downto 24) when 1,
	disp_data(23 downto 20) when 2,
	disp_data(19 downto 16) when 3,
	disp_data(15 downto 12) when 4,
	disp_data(11 downto 8)  when 5,
	disp_data(7 downto 4)   when 6,
	disp_data(3 downto 0)   when others;
	
with addy_cnt select seg_s <=
	"11111110" when 7,
	"11111101" when 6,
	"11111011" when 5,
	"11110111" when 4,
	"11101111" when 3,
	"11011111" when 2,
	"10111111" when 1,
	"01111111" when 0,
	"00000000" when others;
	
with addy_curr select seg <=
	"00000011" when "0000", -- 0                    
	"11110011" when "0001", -- 1
	"00100101" when "0010", -- 2
	"00001101" when "0011", -- 3
	"10011001" when "0100", -- 4
	"01001001" when "0101", -- 5
	"01000001" when "0110", -- 6
	"00011111" when "0111", -- 7
	"00000001" when "1000", -- 8
	"00001001" when "1001", -- 9
	"00010001" when "1010", -- A
	"00000000" when "1011", -- B
	"01100011" when "1100", -- C
	"00000010" when "1101", -- D
	"01100001" when "1110", -- E
	"01110001" when "1111", -- F
	"11111111" when others; -- Blank


end Behavioral;
