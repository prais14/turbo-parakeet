----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/16/2025 12:02:34 PM
-- Design Name: 
-- Module Name: ROM
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ROM is
    port(
		clk		: in std_logic;
		rst		: in std_logic;
        addy 	: in  std_logic_vector(3 downto 0);
        dout    : out std_logic_vector(31 downto 0)
    );
end entity ROM;

architecture RTL of ROM is
    type MEMORY is array (0 to 15) of std_logic_vector(31 downto 0);
    constant ROM : MEMORY := (
        x"68697961",
        x"76543210",
        x"AAAABBBB",
        x"CCCCDDDD",
        x"4A4A4A4A",
        x"5C5C5C5C",
        x"ABCDEFAB",
        x"00000000",
        x"B0000000",
        x"75136495",
        x"A1B2C3D4",
        x"A0B1C2D3",
        x"BAABAA11",
        x"5F8456DA",
        x"EE33EE33",
        x"FEDCBABC"
    );
begin
    main : process(clk)
    begin
		if rising_edge(clk) then
			if rst = '1' then
				dout <= (others => '0');
			else
				dout <= ROM(to_integer(unsigned(addy)));
			end if;
		end if;
    end process main;

end RTL;