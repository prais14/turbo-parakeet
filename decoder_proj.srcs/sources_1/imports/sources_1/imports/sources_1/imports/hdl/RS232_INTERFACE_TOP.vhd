--  =================================================================================
--  Identity number     :  P 1559 900xx
--  File Name           :  RS232_INTERFACE_TOP.vhd
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

--library RS232_LIB;

entity RS232_INTERFACE_TOP is
   port( 
      CLK_100M        : in     std_logic;
      RESET           : in     std_logic;
      RX_SERIAL       : in     std_logic;
      TX_DATA         : in     std_logic_vector (31 downto 0);
      TX_DATA_DTACK_N : in     std_logic;
      RX_ADDRESS      : out    std_logic_vector (31 downto 0);
      RX_CS_N         : out    std_logic;
      RX_DATA         : out    std_logic_vector (31 downto 0);
      RX_WE_N         : out    std_logic;
      TX_SERIAL       : out    std_logic
   );
end RS232_INTERFACE_TOP ;

architecture RTL of RS232_INTERFACE_TOP is
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------


component STROBE_GENERATION is
 port( 
      CLK          : in  std_logic;
      RESET        : in  std_logic;
      STROBE_540ns : out std_logic
     );
end component STROBE_GENERATION ;
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
component ASCII_LUT
  port (
   CLK             : in  std_logic;
   RESET           : in  std_logic;
   RX_BYTE         : in  std_logic_vector ( 7 downto 0);
   RX_BYTE_READY   : in  std_logic;
   TX_NIBBLE       : in  std_logic_vector ( 3 downto 0);
   TX_NIBBLE_READY : in  std_logic;
   CHAR_TYPE       : out std_logic_vector ( 3 downto 0);
   RX_CHAR         : out std_logic_vector ( 3 downto 0);
   RX_CHAR_READY   : out std_logic;
   TX_BYTE         : out std_logic_vector ( 7 downto 0);
   TX_BYTE_READY   : out std_logic 
  );
end component ASCII_LUT;
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
component UART_CONTROL
  port (
   CHAR_TYPE       : in  std_logic_vector ( 3 downto 0);
   CLK             : in  std_logic;
   RESET           : in  std_logic;
   RX_CHAR         : in  std_logic_vector ( 3 downto 0);
   RX_CHAR_READY   : in  std_logic;
   TX_DATA         : in  std_logic_vector (31 downto 0);
   TX_DATA_DTACK_N : in  std_logic;
   TX_DATA_READY   : in  std_logic;
   RX_ADDRESS      : out std_logic_vector (31 downto 0);
   RX_CS_N         : out std_logic;
   RX_DATA         : out std_logic_vector (31 downto 0);
   RX_WE_N         : out std_logic;
   TX_NIBBLE       : out std_logic_vector ( 3 downto 0);
   TX_NIBBLE_READY : out std_logic 
  );
end component UART_CONTROL;
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
component UART_RX
  port (
   CLK             : in  std_logic;
   RESET           : in  std_logic;
   STROBE_153K8    : in  std_logic;
   RX              : in  std_logic;
   RX_STROBE       : out std_logic;
   RX_DATA         : out std_logic_vector ( 7 downto 0)
  );
end component UART_RX;
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
component UART_TX
port (
   CLK             : in  std_logic;
   TX_DATA         : in  std_logic_vector ( 7 downto 0);
   TX_STROBE       : in  std_logic;
   RESET           : in  std_logic;
   STROBE_153K8    : in  std_logic;
   TX              : out std_logic;
   TX_READY        : out std_logic 
  );
end component UART_TX;
----------------------------------------------------------------------------
-- Signal Declarations
----------------------------------------------------------------------------
signal STROBE_540ns    : std_logic;
signal CHAR_TYPE       : std_logic_vector( 3 downto 0);
signal TX_READY        : std_logic;
signal RX_BYTE         : std_logic_vector( 7 downto 0);
signal RX_CHAR         : std_logic_vector( 3 downto 0);
signal RX_CHAR_READY   : std_logic;
signal TX_BYTE         : std_logic_vector( 7 downto 0);
signal TX_BYTE_READY   : std_logic;
signal TX_NIBBLE       : std_logic_vector( 3 downto 0);
signal TX_NIBBLE_READY : std_logic;
signal RX_STROBE       : std_logic;

--for all : ASCII_LUT         use entity RS232_LIB.ASCII_LUT;
--for all : UART_CONTROL      use entity RS232_LIB.UART_CONTROL;
--for all : UART_RX           use entity RS232_LIB.UART_RX;
--for all : UART_TX           use entity RS232_LIB.UART_TX;
--for all : STROBE_GENERATION use entity RS232_LIB.STROBE_GENERATION;

begin
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
STROBE_GENERATION_component : STROBE_GENERATION port map                   ( 
         CLK             => CLK_100M                                       ,
         RESET           => RESET                                          ,
         STROBE_540ns    => STROBE_540ns                                  );
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
ASCII_LUT_component : ASCII_LUT port map                                   (
         CLK             => CLK_100M                                       ,
         RESET           => RESET                                          ,
         RX_BYTE         => RX_BYTE                                        ,
         RX_BYTE_READY   => RX_STROBE                                      ,
         TX_NIBBLE       => TX_NIBBLE                                      ,
         TX_NIBBLE_READY => TX_NIBBLE_READY                                ,
         CHAR_TYPE       => CHAR_TYPE                                      ,
         RX_CHAR         => RX_CHAR                                        ,
         RX_CHAR_READY   => RX_CHAR_READY                                  ,
         TX_BYTE         => TX_BYTE                                        ,
         TX_BYTE_READY   => TX_BYTE_READY                                 );
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
UART_CONTROL_component : UART_CONTROL port map                             (
         CHAR_TYPE       => CHAR_TYPE                                      ,
         CLK             => CLK_100M                                       ,
         RESET           => RESET                                          ,
         RX_CHAR         => RX_CHAR                                        ,
         RX_CHAR_READY   => RX_CHAR_READY                                  ,
         TX_DATA         => TX_DATA                                        ,
         TX_DATA_DTACK_N => TX_DATA_DTACK_N                                ,
         TX_DATA_READY   => TX_READY                                       ,
         RX_ADDRESS      => RX_ADDRESS                                     ,
         RX_CS_N         => RX_CS_N                                        ,
         RX_DATA         => RX_DATA                                        ,
         RX_WE_N         => RX_WE_N                                        ,
         TX_NIBBLE       => TX_NIBBLE                                      ,
         TX_NIBBLE_READY => TX_NIBBLE_READY                               );
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
UART_RX_component : UART_RX port map                                       (
         CLK             => CLK_100M                                       ,
         RESET           => RESET                                          ,
         STROBE_153K8    => STROBE_540ns                                   ,
         RX              => RX_SERIAL                                      ,
         RX_STROBE       => RX_STROBE                                      ,
         RX_DATA         => RX_BYTE                                       );
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
UART_TX_component : UART_TX port map                                       (
         CLK             => CLK_100M                                       ,
         TX_DATA         => TX_BYTE                                        ,
         TX_STROBE       => TX_BYTE_READY                                  ,
         RESET           => RESET                                          ,
         STROBE_153K8    => STROBE_540ns                                   ,
         TX              => TX_SERIAL                                      ,
         TX_READY        => TX_READY                                      );
----------------------------------------------------------------------------
--
----------------------------------------------------------------------------
end RTL;

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
