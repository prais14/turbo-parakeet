----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/08/2025 11:20:13 AM
-- Design Name: 
-- Module Name: TESTBENCH_TOP - Behavioral
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

entity TESTBENCH_TOP is
--  Port ( );
end TESTBENCH_TOP;

architecture TB of TESTBENCH_TOP is

component TOP is
	port(
		SYSCLK_100	: in std_logic;
		RS232_RX	: in std_logic := '0';
		--USB_RTS		: in std_logic := '0';
		RS232_TX	: out std_logic;
		--USB_CTS		: out std_logic;
		LED_ID        	: out std_logic_vector(15 downto 0);
			
        switch_0		: in std_logic;
        switch_1		: in std_logic;
        switch_2		: in std_logic;
        switch_3		: in std_logic;
        switch_4		: in std_logic;
        switch_5		: in std_logic;
        switch_6		: in std_logic;
        switch_7		: in std_logic;
        
        btn_m           : in std_logic;
        
        RGB_0			: out std_logic_vector(2 downto 0);
        RGB_1			: out std_logic_vector(2 downto 0);
		
		seg				: out std_logic_vector(7 downto 0);
		seg_s			: out std_logic_vector(7 downto 0);
		
		audio_out       : out std_logic 
		
	);
end component TOP;

component RS232_MODEL is
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
end component RS232_MODEL;

signal ADDRESS_IN    : std_logic_vector (31 downto 0) := (others => '0');
signal DATA_IN       : std_logic_vector (31 downto 0):= (others => '0');
signal READ          : std_logic                      := '0';
signal RESET         : std_logic                      := '0';
signal RS232_TX     : std_logic                      := '0';
signal WRITE         : std_logic                      := '0';
signal RX_DATA       : std_logic_vector (31 downto 0);
signal RX_DATA_READY : std_logic;
signal RS232_RX     : std_logic;

signal SYSCLK_100	: std_logic := '0';
signal LED_ID      : std_logic_vector(15 downto 0);

signal switch_0      : std_logic;
signal switch_1      : std_logic;
signal switch_2      : std_logic;
signal switch_3      : std_logic;
signal switch_4      : std_logic;
signal switch_5      : std_logic;

signal btn_m         : std_logic;

signal audio_out     : std_logic;


signal seg		    : std_logic_vector (7 downto 0);
signal seg_s		: std_logic_vector (7 downto 0);
signal LED_ON		: std_logic_vector (15 DOWNTO 0) := "0000000000000000";

signal STROBE_540ns : std_logic;
		

begin

	TOP_component	: TOP 
	port map(
		SYSCLK_100	=> SYSCLK_100,
		RS232_RX	=> RS232_RX,
		--USB_RTS		=> USB_RTS,
		RS232_TX	=> RS232_TX,
		--USB_CTS		=> USB_CTS,
		LED_ID      => LED_ID,  
		
		switch_0	=> switch_0,
		switch_1	=> switch_0,
		switch_2	=> switch_0,
		switch_3	=> switch_0,
		switch_4	=> switch_0,
		switch_5	=> switch_0,
		switch_6	=> switch_0,
		switch_7	=> switch_0,
		btn_m       => btn_m,
		seg			=> seg,	
		seg_s		=> seg_s,
		audio_out   => audio_out

	);
	
	RS232_MODEL_component : RS232_MODEL
      port map (
         ADDRESS_IN    => ADDRESS_IN,
         CLK           => SYSCLK_100,
         DATA_IN       => DATA_IN,
         READ          => READ,
         RESET         => RESET,
         RX_SERIAL     => RS232_TX, -- from FPGA
         STROBE_153K8  => STROBE_540ns,
         WRITE         => WRITE,
         RX_DATA       => RX_DATA,
         RX_DATA_READY => RX_DATA_READY,
         TX_SERIAL     => RS232_RX -- To FPGA
      );
	  
	
	  
	  


	
	SYSCLK_100 <= NOT SYSCLK_100 AFTER 5NS;
	
end architecture TB;
