--  =================================================================================
--  Identity number     :  P 1559 900xx
--  File Name           :  UART_RX.vhd
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
use IEEE.std_logic_unsigned.ALL;

entity UART_RX is
   port( 
      CLK          : in     std_logic;
      RESET        : in     std_logic;
      STROBE_153K8 : in     std_logic;
      RX           : in     std_logic;
      RX_STROBE    : out    std_logic;
      RX_DATA      : out    std_logic_vector (7 downto 0)
   );
end UART_RX ;


architecture RTL of UART_RX is

type RX_STATE_T is (RX_WAIT_STATE, 
                    RX_START_BIT, 
                    RX_DATA_STATE, 
                    RX_STOP_BIT,
                    COMPLETE_STOP);

signal RX_STATE                : RX_STATE_T;
signal RX_OLD                  : std_logic;
signal rx_sync                 : std_logic;
signal RX_BIT_COUNT            : integer range 0 to 7;
signal RX_BAUD_CNT             : integer range 0 to 7;
signal RX_HIGH_TO_LOW_DETECTED : std_logic;
signal VALID_STOP              : std_logic;
signal RX_STROBE_SIG           : std_logic;
signal TX_DATA_SIG             : std_logic_vector(7 downto 0);



begin
---------------------------------------------------------------------------------------------------
--  Set 'RX_HIGH_TO_LOW_DETECTED' high when a high to low transition is detected on rx otherwise set low.
RX_HIGH_TO_LOW_DETECTED <= (RX_OLD and NOT rx_sync);
---------------------------------------------------------------------------------------------------
--  Generate baud rate counter. Strobe frequency is 8 times the required baud rate.
---------------------------------------------------------------------------------------------------
uart_baud_counter : process (RESET,CLK)
BEGIN
  if (RESET = '1') then
      RX_BAUD_CNT <= 0;
  elsif (CLK'event and CLK = '1') then
    if    ((RX_BAUD_CNT  = 7)   and 
           (STROBE_153K8 = '1')) then 
            RX_BAUD_CNT <= 0;
    elsif ((RX_STATE                = RX_WAIT_STATE) and 
           (RX_HIGH_TO_LOW_DETECTED = '1')) then
            RX_BAUD_CNT <= 0;
    elsif (STROBE_153K8 = '1') then
           RX_BAUD_CNT <= RX_BAUD_CNT + 1; 
    else
           RX_BAUD_CNT <= RX_BAUD_CNT;
    end if;
  end if;
end process uart_baud_counter;
---------------------------------------------------------------------------------------------------
--  Generate synchronised and old values of rx input.
---------------------------------------------------------------------------------------------------
sync_rx : process (RESET,CLK)
BEGIN
  if (RESET = '1') then
        RX_SYNC <= '0';
        RX_OLD  <= '0';
  elsif (CLK'event and CLK = '1') then
        RX_SYNC <= rx;
        RX_OLD  <= RX_SYNC;
  end if;
end process sync_rx;
---------------------------------------------------------------------------------------------------
--  Reciever state machine (sm) function.
--  After detecting a falling edge on the input (RX_HIGH_TO_LOW_DETECTED = '1') the start bit is then
--  sampled in the middle of the bit.  if a valid '0' start bit is detected then the sm proceeds to read in the data.
--  In the middle of the last bit the sm checks that it is a valid stop bit ('1') and if so flags reception of the
--  byte (rx_strobe).
--  Default asignal assignments are provided so that there is no need for assignment in all branches
---------------------------------------------------------------------------------------------------
receiver_sm : process (RESET,CLK)
BEGIN
  if (RESET = '1') then
        RX_STATE        <= RX_WAIT_STATE;
        RX_BIT_COUNT    <= 0;
        RX_STROBE_SIG   <= '0';
        TX_DATA_SIG     <= "00000000";
        VALID_STOP      <= '0';
  elsif (CLK'event and CLK = '1') then
        TX_DATA_SIG     <= TX_DATA_SIG;
        RX_STROBE_SIG   <= '0';
        RX_BIT_COUNT    <= 0;
        VALID_STOP      <= VALID_STOP;
        CASE RX_STATE IS
    -- /////////////////////////////////////////////////////////////////////////////////////////////
            when RX_WAIT_STATE =>    
                VALID_STOP <= '0';
                if (RX_HIGH_TO_LOW_DETECTED = '1') then
                    RX_STATE <= RX_START_BIT;
                else
                    RX_STATE <= RX_WAIT_STATE;
                end if;
    -- /////////////////////////////////////////////////////////////////////////////////////////////
            when RX_START_BIT =>    
                if ((RX_BAUD_CNT  = 4)    and 
                    (STROBE_153K8 = '1')  and 
                    (RX_OLD       = '0')) then
                    RX_STATE    <= RX_DATA_STATE;
                    TX_DATA_SIG <= (others => '0');
                else
                    RX_STATE    <= RX_START_BIT;
                end if;
    -- /////////////////////////////////////////////////////////////////////////////////////////////
            when RX_DATA_STATE    =>    
                TX_DATA_SIG(RX_BIT_COUNT) <= RX_OLD;
                if ((RX_BAUD_CNT  = 4)    and 
                    (STROBE_153K8 = '1')) then 
                    if (RX_BIT_COUNT = 7) then
                        RX_STATE     <= RX_STOP_BIT;
                    else
                        RX_STATE     <= RX_DATA_STATE;
                        RX_BIT_COUNT <= RX_BIT_COUNT + 1;
                    end if;
                else
                    RX_STATE     <= RX_DATA_STATE;
                    RX_BIT_COUNT <= RX_BIT_COUNT;
                end if;
    -- /////////////////////////////////////////////////////////////////////////////////////////////
            when RX_STOP_BIT =>    
                if ((RX_BAUD_CNT  = 4)    and 
                    (STROBE_153K8 = '1')) then
                     RX_STATE     <= COMPLETE_STOP;
                     VALID_STOP   <= RX_OLD;
                else
                     RX_STATE     <= RX_STOP_BIT;
                     RX_BIT_COUNT <= RX_BIT_COUNT;
                end if;
    -- /////////////////////////////////////////////////////////////////////////////////////////////
            when COMPLETE_STOP =>    
                if ((RX_BAUD_CNT  = 7)    and 
                    (STROBE_153K8 = '1')) then
                     RX_STATE      <= RX_WAIT_STATE;
                     RX_STROBE_SIG <= VALID_STOP;
                else
                     RX_STATE      <= COMPLETE_STOP;
                end if;
    -- /////////////////////////////////////////////////////////////////////////////////////////////
-- coverage off
            when others =>    
                RX_STATE <= RX_WAIT_STATE;
-- coverage on
        end case;
    end if;
end process receiver_sm;
---------------------------------------------------------------------------------------------------
-- Concurrent Assignments
---------------------------------------------------------------------------------------------------
RX_STROBE <= RX_STROBE_SIG;
RX_DATA   <= TX_DATA_SIG;
---------------------------------------------------------------------------------------------------
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
