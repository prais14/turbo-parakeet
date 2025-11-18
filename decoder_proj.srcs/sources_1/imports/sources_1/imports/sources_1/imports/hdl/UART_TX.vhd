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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity UART_TX is
   port( 
      CLK          : in     std_logic;
      TX_DATA      : in     std_logic_vector (7 downto 0);
      TX_STROBE    : in     std_logic;
      RESET        : in     std_logic;
      STROBE_153K8 : in     std_logic;
      TX           : out    std_logic;
      TX_READY     : out    std_logic
   );
end UART_TX ;

architecture RTL of UART_TX is

type TX_STATE_T IS (tx_wait_state, 
                    TX_WAIT_TX_STROBE, 
                    tx_sync, 
                    TX_IDLE_BIT, 
                    TX_START_BIT, 
                    TX_DATA_STATE, 
                    TX_STOP_BIT);

signal TX_STATE        : TX_STATE_T;
signal TX_BIT_COUNT    : integer range 0 to 7;
signal TX_BAUD_CNT     : integer range 0 to 7;
signal LATCHED_TX_DATA : std_logic_vector(7 downto 0);
signal TX_SIG          : std_logic;
signal TX_READY_SIG    : std_logic;



begin
---------------------------------------------------------------------------------------------------
--  Generate baud rate counter. Strobe frequency is 8 times the required buad rate.
---------------------------------------------------------------------------------------------------
uart_baud_counter : process
begin
    wait until RISING_EDGE(clk);
    if ((RESET = '1') or 
        ((TX_BAUD_CNT = 7) and 
         (STROBE_153K8 = '1')) or 
         (TX_STATE = tx_wait_state) or 
         (TX_STATE = tx_sync)) then
        TX_BAUD_CNT <= 0;
    elsif (STROBE_153K8 = '1') then
        TX_BAUD_CNT <= TX_BAUD_CNT + 1; 
    else
        TX_BAUD_CNT <= TX_BAUD_CNT;
    end if;
end process uart_baud_counter;
---------------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------------
transmitter_sm : process (clk)
begin
  if (rising_edge(clk)) then
    if (RESET = '1') then
        TX_STATE        <= TX_WAIT_TX_STROBE;
        TX_BIT_COUNT    <= 0;
        TX_READY_SIG    <= '1';
        TX_SIG          <= '1'; 
        LATCHED_TX_DATA <= "00000000";
    else
        TX_BIT_COUNT    <= 0;
        TX_SIG          <= '1';
        TX_READY_SIG    <= '0';
        case TX_STATE is
-- /////////////////////////////////////////////////////////////////////////////////////////////
            when TX_WAIT_TX_STROBE =>
                LATCHED_TX_DATA <= (others => '0');
                if (TX_STROBE = '1') then
                    LATCHED_TX_DATA <= tx_data;
                    TX_STATE        <= tx_sync;
                else
                    TX_STATE        <= TX_WAIT_TX_STROBE;
                end if;
-- /////////////////////////////////////////////////////////////////////////////////////////////
            when tx_sync =>    
                if (STROBE_153K8 = '1') then
                    TX_STATE <= TX_IDLE_BIT;
                else
                    TX_STATE <= tx_sync;
                end if;
-- /////////////////////////////////////////////////////////////////////////////////////////////
            when TX_IDLE_BIT =>    
                if ((STROBE_153K8 = '1') and 
                    (TX_BAUD_CNT  = 7))  then
                    TX_STATE <= TX_START_BIT;
                else
                    TX_STATE <= TX_IDLE_BIT;
                end if;
-- /////////////////////////////////////////////////////////////////////////////////////////////
            when TX_START_BIT =>   
                TX_SIG <= '0';
                if ((STROBE_153K8 = '1') and 
                    (TX_BAUD_CNT  = 7))  then
                    TX_STATE <= TX_DATA_STATE;
                else
                    TX_STATE <= TX_START_BIT;
                end if;
-- /////////////////////////////////////////////////////////////////////////////////////////////
            when TX_DATA_STATE =>    
                TX_SIG <= LATCHED_TX_DATA(TX_BIT_COUNT);
                if ((STROBE_153K8 = '1') and 
                    (TX_BAUD_CNT = 7)) then
                    if (TX_BIT_COUNT = 7) then
                        TX_STATE <= TX_STOP_BIT;
                    else
                        TX_BIT_COUNT <= TX_BIT_COUNT + 1;
                        TX_STATE     <= TX_DATA_STATE;
                    end if;
                else
                    TX_BIT_COUNT     <= TX_BIT_COUNT;
                    TX_STATE         <= TX_DATA_STATE;
                end if;
-- /////////////////////////////////////////////////////////////////////////////////////////////
            when TX_STOP_BIT =>    
                if ((STROBE_153K8 = '1') and 
                    (TX_BAUD_CNT = 7)) then
                     TX_READY_SIG <= '1';
                     TX_STATE     <= TX_WAIT_TX_STROBE;
                else
                    TX_STATE      <= TX_STOP_BIT;
                end if;
-- /////////////////////////////////////////////////////////////////////////////////////////////
-- coverage off
            when others => 
                TX_READY_SIG <= '1';   
                TX_STATE     <= TX_WAIT_TX_STROBE;
-- coverage on
        end case;
   end if;
    end if;
end process transmitter_sm;
---------------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------------
output_reg_proc : process (clk)
begin
  if (rising_edge(clk)) then
    if (RESET = '1') then
        TX_READY    <= '1';
        TX          <= '1'; 
    else
        TX       <= TX_SIG;
        TX_READY <= TX_READY_SIG;
    end if;
  end if;
end process output_reg_proc;
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
