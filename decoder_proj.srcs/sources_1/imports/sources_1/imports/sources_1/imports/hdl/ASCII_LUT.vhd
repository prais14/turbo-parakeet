--  =================================================================================
--  Identity number     :  P 1559 900xx
--  File Name           :  ASCII_LUT.vhd
--  ---------------------------------------------------------------------------------
--  Status              :  In development
--  ---------------------------------------------------------------------------------
--  Description         : 
--  ---------------------------------------------------------------------------------
--  Requirements        : 1559-900xx-51 
--  Traceability        : Baseline 0.1
--  ---------------------------------------------------------------------------------
--  Verification        : 1559-900xx-81
--  Traceability        : Baseline 0.1
--  ---------------------------------------------------------------------------------   
--  See Footer for detailed information regarding each revision
--  ---------------------------------------------------------------------------------  
--                       Copyright 2019 Leonardo MW Ltd
--       The copyright in this document is the property of Leonardo MW Ltd
--          and the contents may not be revealed to third parties
--                     without its prior permission.
--  ================================================================================= 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ASCII_LUT is
   port( 
      CLK             : in     std_logic;
      RESET           : in     std_logic;
      RX_BYTE         : in     std_logic_vector (7 downto 0);
      RX_BYTE_READY   : in     std_logic;
      TX_NIBBLE       : in     std_logic_vector (3 downto 0);
      TX_NIBBLE_READY : in     std_logic;
      CHAR_TYPE       : out    std_logic_vector (3 downto 0);
      RX_CHAR         : out    std_logic_vector (3 downto 0);
      RX_CHAR_READY   : out    std_logic;
      TX_BYTE         : out    std_logic_vector (7 downto 0);
      TX_BYTE_READY   : out    std_logic
   );
end ASCII_LUT ;

architecture RTL of ASCII_LUT is

constant NO_OPERATION    : std_logic_vector (3 downto 0)  := std_logic_vector(to_unsigned(0,4));
constant SPACE           : std_logic_vector (3 downto 0)  := std_logic_vector(to_unsigned(1,4));
constant LINE_FEED       : std_logic_vector (3 downto 0)  := std_logic_vector(to_unsigned(2,4));
constant CARRAIGE_RETURN : std_logic_vector (3 downto 0)  := std_logic_vector(to_unsigned(3,4));
constant COMMENT         : std_logic_vector (3 downto 0)  := std_logic_vector(to_unsigned(4,4));
constant READ            : std_logic_vector (3 downto 0)  := std_logic_vector(to_unsigned(5,4));
constant WRITE           : std_logic_vector (3 downto 0)  := std_logic_vector(to_unsigned(6,4));
constant HEX_DATA        : std_logic_vector (3 downto 0)  := std_logic_vector(to_unsigned(7,4));
constant DATA_ERROR      : std_logic_vector (3 downto 0)  := std_logic_vector(to_unsigned(8,4));

begin
-------------------------------------------------------------------------------------
--
-------------------------------------------------------------------------------------
transmit_decode_proc : process (RESET,CLK)
begin
  if (RESET = '1') then
      TX_BYTE         <= (others => '0');
      TX_BYTE_READY   <= '0';
  elsif (CLK'event and CLK = '1') then
    TX_BYTE_READY <= '0';
    if (TX_NIBBLE_READY = '1') then
        TX_BYTE_READY <= '1';
        case TX_NIBBLE is
          when "0000" => TX_BYTE <= x"30"; -- 0
          when "0001" => TX_BYTE <= x"31"; -- 1
          when "0010" => TX_BYTE <= x"32"; -- 2
          when "0011" => TX_BYTE <= x"33"; -- 3
          when "0100" => TX_BYTE <= x"34"; -- 4
          when "0101" => TX_BYTE <= x"35"; -- 5
          when "0110" => TX_BYTE <= x"36"; -- 6
          when "0111" => TX_BYTE <= x"37"; -- 7
          when "1000" => TX_BYTE <= x"38"; -- 8
          when "1001" => TX_BYTE <= x"39"; -- 9
          when "1010" => TX_BYTE <= x"41"; -- A
          when "1011" => TX_BYTE <= x"42"; -- B
          when "1100" => TX_BYTE <= x"43"; -- C
          when "1101" => TX_BYTE <= x"44"; -- D
          when "1110" => TX_BYTE <= x"45"; -- E
          when "1111" => TX_BYTE <= x"46"; -- F
          when others => null;
        end case;
    end if;
  end if;
end process  transmit_decode_proc;
-------------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------------
receive_decode_proc : process (RESET,CLK)
begin
    if (RESET = '1') then
        RX_CHAR       <= NO_OPERATION;
        RX_CHAR_READY <= '0';
        CHAR_TYPE     <= (others => '0');
    elsif (CLK'event and CLK = '1') then
      RX_CHAR_READY <= '0';
      if (RX_BYTE_READY = '1') then
          RX_CHAR_READY <= '1';
      case to_integer(unsigned(RX_BYTE)) is
        when   9 => RX_CHAR   <= "0000"; 
                    CHAR_TYPE <= SPACE;           -- ^I = TAB
        when  10 => RX_CHAR   <= "0000"; 
                    CHAR_TYPE <= LINE_FEED;       -- ^N = LF
        when  13 => RX_CHAR   <= "0000"; 
                    CHAR_TYPE <= CARRAIGE_RETURN; -- ^M = CR
        when  17 => RX_CHAR   <= "0000"; 
                    CHAR_TYPE <= NO_OPERATION;    -- ^Q = XON
        when  19 => RX_CHAR   <= "0000"; 
                    CHAR_TYPE <= NO_OPERATION;    -- ^S = XOFF
        when  32 => RX_CHAR   <= "0000"; 
                    CHAR_TYPE <= SPACE;           -- SP
        when  35 => RX_CHAR   <= "0000"; 
                    CHAR_TYPE <= COMMENT;         -- #
        when  48 => RX_CHAR   <= "0000"; 
                    CHAR_TYPE <= HEX_DATA;        -- 0
        when  49 => RX_CHAR   <= "0001"; 
                    CHAR_TYPE <= HEX_DATA;        -- 1
        when  50 => RX_CHAR   <= "0010"; 
                    CHAR_TYPE <= HEX_DATA;        -- 2
        when  51 => RX_CHAR   <= "0011"; 
                    CHAR_TYPE <= HEX_DATA;        -- 3
        when  52 => RX_CHAR   <= "0100"; 
                    CHAR_TYPE <= HEX_DATA;        -- 4
        when  53 => RX_CHAR   <= "0101"; 
                    CHAR_TYPE <= HEX_DATA;        -- 5
        when  54 => RX_CHAR   <= "0110"; 
                    CHAR_TYPE <= HEX_DATA;        -- 6
        when  55 => RX_CHAR   <= "0111"; 
                    CHAR_TYPE <= HEX_DATA;        -- 7
        when  56 => RX_CHAR   <= "1000"; 
                    CHAR_TYPE <= HEX_DATA;        -- 8
        when  57 => RX_CHAR   <= "1001"; 
                    CHAR_TYPE <= HEX_DATA;        -- 9
        when  65 => RX_CHAR   <= "1010"; 
                    CHAR_TYPE <= HEX_DATA;        -- A
        when  66 => RX_CHAR   <= "1011"; 
                    CHAR_TYPE <= HEX_DATA;        -- B
        when  67 => RX_CHAR   <= "1100"; 
                    CHAR_TYPE <= HEX_DATA;        -- C
        when  68 => RX_CHAR   <= "1101"; 
                    CHAR_TYPE <= HEX_DATA;        -- D
        when  69 => RX_CHAR   <= "1110"; 
                    CHAR_TYPE <= HEX_DATA;        -- E
        when  70 => RX_CHAR   <= "1111"; 
                    CHAR_TYPE <= HEX_DATA;        -- F
        when  82 => RX_CHAR   <= "0000"; 
                    CHAR_TYPE <= READ;            -- R
        when  87 => RX_CHAR   <= "0000"; 
                    CHAR_TYPE <= WRITE;           -- W
        when  95 => RX_CHAR  <= "0000"; 
                    CHAR_TYPE <= NO_OPERATION;    -- _
        when  97 => RX_CHAR   <= "1010"; 
                    CHAR_TYPE <= HEX_DATA;        -- a
        when  98 => RX_CHAR   <= "1011"; 
                    CHAR_TYPE <= HEX_DATA;        -- b
        when  99 => RX_CHAR   <= "1100"; 
                    CHAR_TYPE <= HEX_DATA;        -- c
        when 100 => RX_CHAR   <= "1101"; 
                    CHAR_TYPE <= HEX_DATA;        -- d
        when 101 => RX_CHAR   <= "1110"; 
                    CHAR_TYPE <= HEX_DATA;        -- e
        when 102 => RX_CHAR   <= "1111"; 
                    CHAR_TYPE <= HEX_DATA;        -- f
        when 114 => RX_CHAR   <= "0000"; 
                    CHAR_TYPE <= READ;            -- r
        when 119 => RX_CHAR   <= "0000"; 
                    CHAR_TYPE <= WRITE;           -- w
        when others => RX_CHAR   <= "0000"; 
                       CHAR_TYPE <= DATA_ERROR;
      end case;
      end if;
    end if;
end process;
-------------------------------------------------------------------------------------
end architecture RTL;

-- ==================================================================================
--                           Revision History Footer
-- Revision 1.0 : 18/02/2109
-- ==================================================================================
-- Revision History
-- ----------------------------------------------------------------------------------
-- Issue : 1.0
-- Date : 18/02/2019
-- Author : M Power
-- Modification : Initial Version
--  ---------------------------------------------------------------------------------
-- ==================================================================================
