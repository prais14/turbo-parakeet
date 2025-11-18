--  =================================================================================
--  Identity number     :  P 1559 900xx
--  File Name           :  UART_CONTROL.vhd
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

entity UART_CONTROL is
   port( 
      CHAR_TYPE       : in     std_logic_vector (3 downto 0);
      CLK             : in     std_logic;
      RESET           : in     std_logic;
      RX_CHAR         : in     std_logic_vector (3 downto 0);
      RX_CHAR_READY   : in     std_logic;
      TX_DATA         : in     std_logic_vector (31 downto 0);
      TX_DATA_DTACK_N : in     std_logic;
      TX_DATA_READY   : in     std_logic;
      RX_ADDRESS      : out    std_logic_vector (31 downto 0);
      RX_CS_N         : out    std_logic;
      RX_DATA         : out    std_logic_vector (31 downto 0);
      RX_WE_N         : out    std_logic;
      TX_NIBBLE       : out    std_logic_vector (3 downto 0);
      TX_NIBBLE_READY : out    std_logic
   );

end UART_CONTROL ;

architecture RTL of UART_CONTROL is

type     UART_STATE_TYPE is   (IDLE_STATE,
                               SPACE_1_STATE, 
                               ADDRESS_STATE,
                               WAIT_FOR_DTACK_N,
                               SETUP_SEND_DATA_STATE,
                               WAIT_FOR_TX_CHAR);

constant SPACE                : std_logic_vector ( 3 downto 0)  := std_logic_vector(to_unsigned(1,4));
constant CARRAIGE_RETURN      : std_logic_vector ( 3 downto 0)  := std_logic_vector(to_unsigned(3,4));
constant READ                 : std_logic_vector ( 3 downto 0)  := std_logic_vector(to_unsigned(5,4));
constant WRITE                : std_logic_vector ( 3 downto 0)  := std_logic_vector(to_unsigned(6,4));
constant HEX_DATA             : std_logic_vector ( 3 downto 0)  := std_logic_vector(to_unsigned(7,4));
constant BYTE_COUNT_TH        : std_logic_vector ( 4 downto 0)  := std_logic_vector(to_unsigned(16,5));
constant NIBBLE_COUNT_SEND_TH : std_logic_vector ( 4 downto 0)  := std_logic_vector(to_unsigned(7,5));

signal   UART_STATE           : UART_STATE_TYPE;
signal   ADDRESS_SIG          : std_logic_vector (31 downto 0);
signal   DATA_SIG             : std_logic_vector (31 downto 0);
signal   BYTE_COUNT           : std_logic_vector ( 4 downto 0);
signal   READ_CYCLE           : std_logic;

signal   RX_ADDRESS_SIG       : std_logic_vector (31 downto 0);
signal   RX_CS_N_SIG          : std_logic;
signal   RX_DATA_SIG          : std_logic_vector (31 downto 0);
signal   RX_WE_N_SIG          : std_logic;

begin
-------------------------------------------------------------------------------------
-- Rx State Machine
-------------------------------------------------------------------------------------
uart_control_state_sm : process (RESET,CLK)
begin
  if (RESET = '1') then
      UART_STATE      <= IDLE_STATE;
      ADDRESS_SIG     <= (others => '0');
      DATA_SIG        <= (others => '0');
      RX_ADDRESS_SIG      <= (others => '0');
      RX_DATA_SIG         <= (others => '0');
      RX_CS_N_SIG         <= '1';
      RX_WE_N_SIG         <= '1';
      BYTE_COUNT      <= (others => '0');
      READ_CYCLE      <= '0';
      TX_NIBBLE       <= (others => '0');
      TX_NIBBLE_READY <= '0';
  elsif (CLK'event and CLK = '1') then
     RX_CS_N_SIG         <= '1';
     RX_WE_N_SIG         <= '1';
     TX_NIBBLE_READY <= '0';
     case UART_STATE is
    -- /////////////////////////////////////////////////////////////////////////////////////////////
       when IDLE_STATE =>         
         BYTE_COUNT <= (others => '0');
         READ_CYCLE <= '0';
         if (RX_CHAR_READY = '1') then
           if (CHAR_TYPE = READ)  or
              (CHAR_TYPE = WRITE) then
               ADDRESS_SIG <= (others => '0');
               DATA_SIG    <= (others => '0');
               BYTE_COUNT  <= (others => '0');
               UART_STATE  <= SPACE_1_STATE;
               if (CHAR_TYPE = READ) then
                   READ_CYCLE <= '1';
               else
                   READ_CYCLE <= '0';
               end if;
           end if;
         end if;
    -- /////////////////////////////////////////////////////////////////////////////////////////////
       when SPACE_1_STATE =>
         if (RX_CHAR_READY = '1')      and
            ((CHAR_TYPE = SPACE)            or
            (CHAR_TYPE  = CARRAIGE_RETURN)) then
             ADDRESS_SIG <= (others => '0');
             DATA_SIG    <= (others => '0');
             BYTE_COUNT  <= (others => '0');
             UART_STATE  <= ADDRESS_STATE;
         end if;
    -- /////////////////////////////////////////////////////////////////////////////////////////////
       when ADDRESS_STATE =>
         if (RX_CHAR_READY = '1') then
           if (CHAR_TYPE = CARRAIGE_RETURN) then
               RX_ADDRESS_SIG <= ADDRESS_SIG;
               RX_DATA_SIG    <= DATA_SIG;
               RX_CS_N_SIG    <= '0';
               RX_WE_N_SIG    <= READ_CYCLE;
               UART_STATE <= WAIT_FOR_DTACK_N;
           elsif (CHAR_TYPE = HEX_DATA) and
              (BYTE_COUNT <= BYTE_COUNT_TH) then -- stops overwriting of data if more than 8 nibbles
               BYTE_COUNT <= std_logic_vector(unsigned(BYTE_COUNT) + 1);
               if    (BYTE_COUNT = "00000") then 
                      ADDRESS_SIG(31 downto 28) <= RX_CHAR;
               elsif (BYTE_COUNT = "00001") then 
                      ADDRESS_SIG(27 downto 24) <= RX_CHAR;
               elsif (BYTE_COUNT = "00010") then 
                      ADDRESS_SIG(23 downto 20) <= RX_CHAR;
               elsif (BYTE_COUNT = "00011") then 
                      ADDRESS_SIG(19 downto 16) <= RX_CHAR;
               elsif (BYTE_COUNT = "00100") then 
                      ADDRESS_SIG(15 downto 12) <= RX_CHAR;
               elsif (BYTE_COUNT = "00101") then 
                      ADDRESS_SIG(11 downto  8) <= RX_CHAR;
               elsif (BYTE_COUNT = "00110") then 
                      ADDRESS_SIG( 7 downto  4) <= RX_CHAR;
               elsif (BYTE_COUNT = "00111") then 
                      ADDRESS_SIG( 3 downto  0) <= RX_CHAR;
               elsif (BYTE_COUNT = "01000") then 
                      DATA_SIG   (31 downto 28) <= RX_CHAR;
               elsif (BYTE_COUNT = "01001") then 
                      DATA_SIG   (27 downto 24) <= RX_CHAR;
               elsif (BYTE_COUNT = "01010") then 
                      DATA_SIG   (23 downto 20) <= RX_CHAR;
               elsif (BYTE_COUNT = "01011") then 
                      DATA_SIG   (19 downto 16) <= RX_CHAR;
               elsif (BYTE_COUNT = "01100") then 
                      DATA_SIG   (15 downto 12) <= RX_CHAR;
               elsif (BYTE_COUNT = "01101") then 
                      DATA_SIG   (11 downto  8) <= RX_CHAR;
               elsif (BYTE_COUNT = "01110") then 
                      DATA_SIG   ( 7 downto  4) <= RX_CHAR;
               elsif (BYTE_COUNT = "01111") then 
                      DATA_SIG   ( 3 downto  0) <= RX_CHAR;
               end if;
           end if;
         end if;
    -- /////////////////////////////////////////////////////////////////////////////////////////////
       when WAIT_FOR_DTACK_N =>
         RX_CS_N_SIG    <= '0';
         RX_WE_N_SIG    <= READ_CYCLE;
         if (TX_DATA_DTACK_N = '0') then
             RX_CS_N_SIG    <= '1';
             RX_WE_N_SIG    <= '1';
             if (READ_CYCLE = '0') then
                 UART_STATE <= IDLE_STATE;
             else
                 DATA_SIG   <= TX_DATA;
                 BYTE_COUNT <= (others => '0');
                 UART_STATE <= SETUP_SEND_DATA_STATE;
             end if;
         end if;
    -- /////////////////////////////////////////////////////////////////////////////////////////////
       when SETUP_SEND_DATA_STATE =>
         if (BYTE_COUNT <= NIBBLE_COUNT_SEND_TH) then
             BYTE_COUNT      <= std_logic_vector(unsigned(BYTE_COUNT) + 1);
             TX_NIBBLE       <= DATA_SIG(31 downto 28);
             DATA_SIG        <= DATA_SIG(27 downto 0) & "0000";
             TX_NIBBLE_READY <= '1';
             UART_STATE      <= WAIT_FOR_TX_CHAR;
         else
             UART_STATE      <= IDLE_STATE;
         end if;
    -- /////////////////////////////////////////////////////////////////////////////////////////////
       when WAIT_FOR_TX_CHAR =>
         if (TX_DATA_READY = '1') then
             UART_STATE <= SETUP_SEND_DATA_STATE;
         end if;
    -- /////////////////////////////////////////////////////////////////////////////////////////////
-- coverage off
       when others =>
         UART_STATE      <= IDLE_STATE;
         ADDRESS_SIG     <= (others => '0');
         DATA_SIG        <= (others => '0');
         RX_ADDRESS_SIG      <= (others => '0');
         RX_DATA_SIG         <= (others => '0');
         RX_CS_N_SIG         <= '1';
         RX_WE_N_SIG         <= '1';
         BYTE_COUNT      <= (others => '0');
         READ_CYCLE      <= '0';
         TX_NIBBLE       <= (others => '0');
         TX_NIBBLE_READY <= '0';
-- coverage on
     end case;
  end if;
end process uart_control_state_sm;
-------------------------------------------------------------------------------------

RX_ADDRESS  <= RX_ADDRESS_SIG;
RX_CS_N     <= RX_CS_N_SIG   ;  
RX_DATA     <= RX_DATA_SIG   ;  
RX_WE_N     <= RX_WE_N_SIG   ; 


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
