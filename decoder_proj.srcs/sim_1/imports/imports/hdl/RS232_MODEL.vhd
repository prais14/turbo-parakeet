--  =================================================================================
--  Identity number     :  P_1510_30103
--  File Name           :  RS232_MODEL_c_RTL.vhd
--  Author              :  powerm00
--  Department          :  Device Design Group
--  Division            :  EWD - Capability Green
--  Design library      :  ORB_TEST_CHIP_TB_TOP_lib
--  ---------------------------------------------------------------------------------
--  Status              :  In development
--  ---------------------------------------------------------------------------------
--  Description         :  ORB_TEST_CHIP
--                      :          
--                      :          
--  ---------------------------------------------------------------------------------
--  Analysis            :
--  Dependencies        :
--  ---------------------------------------------------------------------------------
--  VHDL Version        :  VHDL 2002
--  ---------------------------------------------------------------------------------
--  Assumptions         :
--  ---------------------------------------------------------------------------------
--  Known limitations   :  None
--  ---------------------------------------------------------------------------------
--  Requirements        :
--  Traceability        :  
--  ---------------------------------------------------------------------------------
--  Verification        :
--  Traceability        :  N/A
--  =================================================================================
--  Revision            : $Revision: 40 $    $Date: 2024-08-05 09:21:41 +0100 (Mon, 05 Aug 2024) $
--     
--                      See Footer for detailed information regarding each rev
--  ---------------------------------------------------------------------------------
--  
--  ---------------------------------------------------------------------------------
--  Created             :  by - powerm00.nogroup (ewlcad1.des.grplnk.net)
--                      :  at - 08:04:51 08/03/12
--                      :  using Mentor Graphics HDL Designer(TM) 2011.1 (Build 18)
--
--  =================================================================================
--  =================================================================================
--       The copyright in this document is the property of SELEX S&AS
--          and the contents may not be revealed to third parties
--                     without its prior permission.
--  =================================================================================
--  =================================================================================
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RS232_MODEL is
   port( 
      ADDRESS_IN    : in     std_logic_vector (31 downto 0);
      CLK           : in     std_logic;
      DATA_IN       : in     std_logic_vector (31 downto 0);
      READ          : in     std_logic;
      RESET         : in     std_logic;
      RX_SERIAL     : in     std_logic;
      STROBE_153K8  : in     std_logic;
      WRITE         : in     std_logic;
      RX_DATA       : out    std_logic_vector (31 downto 0);
      RX_DATA_READY : out    std_logic;
      TX_SERIAL     : out    std_logic
   );

-- Declarations

end RS232_MODEL ;



architecture RTL of RS232_MODEL is


component UART_TX is
   port( 
      CLK          : in     std_logic;
      TX_DATA      : in     std_logic_vector (7 downto 0);
      TX_STROBE    : in     std_logic;
      RESET        : in     std_logic;
      STROBE_153K8 : in     std_logic;
      TX           : out    std_logic;
      TX_READY     : out std_logic
   );
end component ;



signal   RX_STROBE           : std_logic := '0';
signal   TX_DATA             : std_logic_vector (7 downto 0) := (others => '0');
signal   TX_STROBE           : std_logic := '0';
signal   CPU_RESET           : std_logic := '1';
signal   STROBE_540ns_CNT    : std_logic_vector ( 9 downto 0) := "0000000000";
constant STROBE_540ns_CNT_TH : std_logic_vector (STROBE_540ns_CNT'length-1 downto 0)  := std_logic_vector(to_unsigned(270,STROBE_540ns_CNT'length));
signal   STROBE_540ns        : std_logic;
signal   CLK_250             : std_logic := '0';
signal   RX_DATA_SIG         : std_logic_vector (31 downto 0) := (others => '0');
signal   RX_DATA_READY_SIG   : std_logic := '0';



procedure SEND(
    signal RX_STROBE : out std_logic;
    signal TX_DATA   : out std_logic_vector(7 downto 0);
    signal TX_STROBE : out std_logic;
    constant BYTE    : std_logic_vector(7 downto 0)
) is
begin
    RX_STROBE <= '1';
    wait for 16 ns;
    RX_STROBE <= '0';
    wait for 160 ns;

    TX_DATA <= BYTE;
    TX_STROBE <= '1';
    wait for 16 ns;
    TX_STROBE <= '0';
    wait for 120 us;
end procedure;



begin

RX_DATA       <= RX_DATA_SIG;
RX_DATA_READY <= RX_DATA_READY_SIG;
CPU_RESET     <= '1', '0' after 16 ns;
CLK_250       <= not CLK_250 after 2 ns;
-------------------------------------------------------------------------------------
-- As used by the design itself
-------------------------------------------------------------------------------------
RS232_0 : UART_TX
   port map( 
      CLK           => CLK_250,
      TX_DATA       => TX_DATA,
      TX_STROBE     => TX_STROBE,
      RESET         => CPU_RESET,
      STROBE_153K8  => STROBE_540ns,
      TX            => TX_SERIAL,
      TX_READY      => open);
---------------------------------------------------------------------------------------------------
-- Strobe every 540s generation.
---------------------------------------------------------------------------------------------------
strobe_540ns_cnt_proc : process(CPU_RESET,CLK_250)
begin
   if (CPU_RESET = '1') then
       STROBE_540ns <= '0';
       STROBE_540ns_CNT <= (others => '0');
   elsif (CLK_250'event and CLK_250 = '1') then
      STROBE_540ns <= '0';
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
--
-------------------------------------------------------------------------------------
stim_proc : process
begin
  wait for 1 us;
  SEND(RX_STROBE, TX_DATA, TX_STROBE, x"57"); -- W
  SEND(RX_STROBE, TX_DATA, TX_STROBE, x"20"); -- SP

-- send an 8 bit address

  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"46"; -- F
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;
  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"46"; -- F
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;
  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"46"; -- F
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;
  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"46"; -- F
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;



  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"46"; -- F
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;


  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"46"; -- F
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;


  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"46"; -- F
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;


  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"30"; -- 0
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;


-- send a space
  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"20"; -- SP
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;


-- Now lets stuff in some serial data
  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"30"; -- 0
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;

  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"30"; -- 0
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;


  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"30"; -- 0
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;



  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"30"; -- 0
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;



  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"30"; -- 0
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;




  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"39"; -- 9
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;




  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"43"; -- C
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;


  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"34"; -- 4
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;

-- now do a line feed
  RX_STROBE <= '1';
  wait for 16 ns;
  RX_STROBE <= '0';
  wait for 160 ns;
  TX_DATA <= x"0D"; -- CR
  TX_STROBE <= '1';
  wait for 16 ns;
  TX_STROBE <= '0';
  wait for 120 us;
-----------------------------------------------------------------------------------------------------------------------------

wait for 500 ns;


 wait for 1 us;
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"57"; -- W
 --TX_DATA <= x"52"; -- R
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;

-- send a space
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"20"; -- SP
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;

-- send an 8 bit address

 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;



 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"31"; -- 1
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


-- send a space
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"20"; -- SP
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


-- Now lets stuff in some serial data
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"30"; -- 0
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;

 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"30"; -- 0
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"30"; -- 0
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;



 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"30"; -- 0
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;



 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"31"; -- 1
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;




 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"33"; -- 3
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;




 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"38"; -- 8
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"38"; -- 8
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;

-- now do a line feed
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"0D"; -- CR
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;
 
 wait for 500 ns;


 wait for 1 us;
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"57"; -- W
 --TX_DATA <= x"52"; -- R
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;

-- send a space
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"20"; -- SP
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;

-- send an 8 bit address

 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;



 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"46"; -- F
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"31"; -- 1
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


-- send a space
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"20"; -- SP
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


-- Now lets stuff in some serial data
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"33"; -- 3
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;

 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"30"; -- 0
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"33"; -- 3
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;



 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"30"; -- 0
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;



 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"31"; -- 1
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;




 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"33"; -- 3
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;




 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"38"; -- 8
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"38"; -- 8
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;

-- now do a line feed
 RX_STROBE <= '1';
 wait for 16 ns;
 RX_STROBE <= '0';
 wait for 160 ns;
 TX_DATA <= x"0D"; -- CR
 TX_STROBE <= '1';
 wait for 16 ns;
 TX_STROBE <= '0';
 wait for 120 us;


  wait;
end process stim_proc;

















end architecture RTL;


-- ==================================================================================
--                           Revision History Footer
-- $Log: RS232_MODEL_c_RTL.vhd,v $
-- Revision 1.3  2013/10/03 09:18:42  powerm00
-- *** empty log message ***
--
-- Revision 1.2  2013/10/03 06:05:15  powerm00
-- *** empty log message ***
--
-- Revision 1.1  2013/02/26 10:57:31  powerm00
-- *** empty log message ***
--
--
-- ==================================================================================
