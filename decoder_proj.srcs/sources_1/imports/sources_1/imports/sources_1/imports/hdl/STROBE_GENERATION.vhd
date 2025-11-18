--  =================================================================================
--  Identity number     :  P 1559 900xx
--  File Name           :  STROBE_GENRATION.vhd
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

entity STROBE_GENERATION is
   port( 
      CLK          : in     std_logic;
      RESET        : in     std_logic;
      STROBE_540ns : out    std_logic
   );
end STROBE_GENERATION ;

architecture RTL of STROBE_GENERATION is

signal   STROBE_540ns_CNT       : std_logic_vector ( 6 downto 0) := (others => '0');
constant STROBE_540ns_CNT_TH    : std_logic_vector (STROBE_540ns_CNT'length-1 downto 0)  := std_logic_vector(to_unsigned(107,STROBE_540ns_CNT'length));          --107,STROBE_540ns_CNT'length)); -- 115200

begin
-------------------------------------------------------------------------------------
-- Strobe every 540s generation.
-------------------------------------------------------------------------------------
strobe_540ns_cnt_proc : process(RESET,CLK)
begin
   if (RESET = '1') then
       STROBE_540ns <= '0';
       STROBE_540ns_CNT <= (others => '0');
   elsif (CLK'event and CLK = '1') then
      if (STROBE_540ns_CNT >= STROBE_540ns_CNT_TH) then
          STROBE_540ns <= '1';
          STROBE_540ns_CNT <= (others => '0');
      else
          STROBE_540ns <= '0';
          STROBE_540ns_CNT <= std_logic_vector (unsigned(STROBE_540ns_CNT) + 1);
      end if;
   end if;
end process strobe_540ns_cnt_proc;
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
