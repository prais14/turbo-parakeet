--
-- VHDL Architecture TOP_lib.TOP.RTL
--
-- Created:
--          by - millsa00.nfsnobody (ewlcad2)
--          at - 10:53:00 09/01/22
--
-- using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

--library unisim;
--use unisim.vcomponents.all;

--LIBRARY TOP_lib;
--LIBRARY RS232_lib;

ENTITY TOP IS 
  port(                       
 
            SYSCLK_100    	: in std_logic;    
            RS232_RX      	: in std_logic;
            RS232_TX      	: out std_logic;
			--  USB_CTS       : out std_logic;
			-- USB_RTS       : in std_logic;
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
END ENTITY TOP;

--
ARCHITECTURE RTL OF TOP IS

signal CLK_50_OUT   : std_logic;
SIGNAL CLK_14_OUT   : std_logic; 
signal RESET_TOP    : std_logic;
signal STROBE_INT   : std_logic;
signal LED_ON  : std_logic;


component CLOCK_GENERATION is
 port(
      clk_out1      : out std_logic;
      clk_out2      : out std_logic;

      clk_in1     : in std_logic
      );
end component;

component ila_0 is
	port(
		CLK			: in std_logic;
		probe0		: in STD_LOGIC_VECTOR(0 DOWNTO 0);
		probe1		: in STD_LOGIC_VECTOR(0 DOWNTO 0);
		probe2		: in STD_LOGIC_VECTOR(31 DOWNTO 0);
		probe3		: in STD_LOGIC_VECTOR(0 downto 0)
	);
end component;

component RESET_GENERATION is
  port(
        CLK       : in std_logic;
        RST       : out std_logic
      );
end component;



component STROBE_GENERATION_L is
 port(
      CLK		       : in  std_logic;
      RST		       : in  std_logic;
	  STROBE_1_TH	   : in  std_logic_vector(31 downto 0); -- std_logic_vector(24 downto 0);
	  STROBE_1	       : out std_logic
     );
end component;


component PULSE_GENERATION is
 port(
      CLK         : in  std_logic;
      RST         : in  std_logic;
      STROBE_IN     : in  std_logic;
      PULSE_OUT     : out std_logic
     );
end component;

component DRIVE_DISPLAY IS
	port 
		(
		CLK		: in std_logic;
		rst 	: in std_logic;
		addy	: in std_logic_vector(31 downto 0);
		rom_data	: in STD_LOGIC_VECTOR (31 downto 0);
		LED_ON	: in std_logic;
		seg		: out std_logic_vector(7 downto 0);
		seg_s 	: out std_logic_vector(7 downto 0)
		);
end component;

component ROM is 
	port(
		CLK			: in std_logic;
		rst			: in std_logic;
		addy		: in std_logic_vector(3 downto 0);
		dout		: out std_logic_vector(31 downto 0)
		);
end component;



component RS232_INTERFACE_TOP IS
   PORT( 
      CLK_100M        : IN     std_logic;
      RESET           : IN     std_logic;
      RX_SERIAL       : IN     std_logic;
      TX_DATA         : IN     std_logic_vector (31 DOWNTO 0);
      TX_DATA_DTACK_N : IN     std_logic;
      RX_ADDRESS      : OUT    std_logic_vector (31 DOWNTO 0);
      RX_CS_N         : OUT    std_logic;
      RX_DATA         : OUT    std_logic_vector (31 DOWNTO 0);
      RX_WE_N         : OUT    std_logic;
      TX_SERIAL       : OUT    std_logic
   );

END component RS232_INTERFACE_TOP ;

component strobe_44100 is
    Port ( clk          : in STD_LOGIC;
           rst          : in std_logic ; 
           strobe_44100 : out STD_LOGIC);
END component strobe_44100;

component pcm_bram is
    generic(
        MEM_SIZE : integer := 15360   -- 15k samples × 4 bytes = 60 KB
    );
    port(
        clk        : in  std_logic;
        reset      : in  std_logic;

        data_in    : in  std_logic_vector(31 downto 0);
        rx_we_n    : in  std_logic;               -- active-low write enable

        mem_full   : out std_logic;                -- LED flag
        
        read_address    : in std_logic_vector(13 downto 0);
        data_out        : out std_logic_vector(7 downto 0)
    );
end component;

component sample_data is
    Port ( clk              : in STD_LOGIC;
           sample_clk       : in STD_LOGIC;
           rst              : in STD_LOGIC;
           start_btn        : in std_logic;
           mem_full         : in std_logic;
           read_address     : out std_logic_vector (13 downto 0);
           read_sample      : in std_logic_vector (7 downto 0);
           pwm_out   : out std_logic
          );
end component;

--signal CLK_100M        : std_logic := '0';
signal TX_DATA         : std_logic_vector (31 DOWNTO 0) := (others => '0');
signal TX_DATA_DTACK_N : std_logic := '0';
signal RX_ADDRESS      : std_logic_vector (31 DOWNTO 0);
signal RX_CS_N         : std_logic;
signal RS232_RX_DATA   : std_logic_vector (31 DOWNTO 0);
signal RX_WE_N         : std_logic := '1';

signal LED_FLASH  : std_logic_vector(31 downto 0):= (others =>'1');

signal REG1 : std_logic_vector(31 downto 0);

signal rom_dout : std_logic_vector(31 downto 0);

signal audio_sample : std_logic_vector(7 downto 0);

signal strobe_44100_sig : std_logic; 

signal pcm_mem_full: std_logic;
signal pcm_read_addr: std_logic_vector (13 downto 0);
signal pcm_data_out : std_logic_vector (7 downto 0); 
signal pwm_out      : std_logic;
 
--for all : RS232_INTERFACE use entity RS232_LIB.RS232_INTERFACE;
 

BEGIN

clock_instance : CLOCK_GENERATION
 port map ( 
            clk_in1 => SYSCLK_100,
            clk_out1 => CLK_50_OUT,
            clk_out2 => CLK_14_OUT
          );



reset_instance : RESET_GENERATION
 port map (
           CLK	    => CLK_50_OUT,
	       RST      =>	RESET_TOP
          );


strobe_instance : STROBE_GENERATION_L
 port map (
           CLK	        =>  CLK_50_OUT,
 	       RST      	=>	RESET_TOP,
 	       STROBE_1_TH	=>  LED_FLASH,--RS232_RX_DATA, --"00000001011111010111100001000000", --"100111000100",
  	       STROBE_1   	=>  STROBE_INT
          );


pulse_instance : PULSE_GENERATION
 port map (
           CLK	      => CLK_50_OUT,
	       RST      	=>	RESET_TOP,
	       STROBE_IN  	=> STROBE_INT,
	       PULSE_OUT  	=> LED_ON
          );
		 
display_instance	: DRIVE_DISPLAY
	port map(
			clk 		=> CLK_50_OUT,
			RST 		=> RESET_TOP,
			led_on 		=> LED_ON,
			ADDY 		=> RX_ADDRESS,
			rom_data 	=> RS232_RX_DATA, --rom_dout, , displaying what is sent 
			seg			=> seg,
			seg_s		=> seg_s
			);

ROM_INSTANCE		: ROM
	port map(
			clk 	=> CLK_50_OUT,
			rst 	=> RESET_TOP,
			addy	=> RX_ADDRESS(3 downto 0),
			dout	=> rom_dout
			);


RS232_INTERFACE_component : RS232_INTERFACE_TOP
   PORT map( 
      CLK_100M        => SYSCLK_100,
      RESET           => RESET_TOP,
      RX_SERIAL       => RS232_RX,
      TX_DATA         => rom_dout, --try to send data back
      TX_DATA_DTACK_N => TX_DATA_DTACK_N,
      RX_ADDRESS      => RX_ADDRESS,
      RX_CS_N         => RX_CS_N,
      RX_DATA         => RS232_RX_DATA,
      RX_WE_N         => RX_WE_N,
      TX_SERIAL       => RS232_TX      
   );

strobe_44100_component  : strobe_44100
    Port map ( clk              => CLK_14_OUT,
               rst              => RESET_TOP,
               strobe_44100     => strobe_44100_sig
    );
    
pcm_bram_component : pcm_bram
    generic map(
        MEM_SIZE => 61440   -- 60 KB BRAM depth
    )
    port map(
        clk         => SYSCLK_100,
        reset       => RESET_TOP,

        data_in     => RS232_RX_DATA,  -- incoming PCM byte (4 bytes in this case)
        rx_we_n     => RX_WE_N,  -- write-enable (active low)

        mem_full    => pcm_mem_full, -- LED indicator

        read_address => pcm_read_addr, -- playback address
        data_out     => pcm_data_out   -- PCM output for DAC/PWM
    );

sample_data_component   : sample_data 
    Port map ( 
                clk             => SYSCLK_100,
                sample_clk      => CLK_14_OUT,
                rst             => RESET_TOP,
                start_btn       => btn_m,
                mem_full        => pcm_mem_full,
                read_address    => pcm_read_addr,
                read_sample     => pcm_data_out,
                pwm_out         => audio_out
          );

process(CLK_50_OUT)
begin
  if rising_edge(CLK_50_OUT) then
    if (RS232_RX_DATA /= x"00000000") then
      LED_FLASH <= RS232_RX_DATA;

    else
	  LED_FLASH <= (others=>'1');
  end if;
end if;
end process;
  
process(CLK_50_OUT)
begin
  if rising_edge(CLK_50_OUT) then
    if (RX_WE_N = '0') then
      REG1 <= RS232_RX_DATA;
   
  end if;
end if;
      
end process;


RGB_0(2) <= pcm_mem_full;
--RGB_0(1) <= switch_1;
--RGB_0(0) <= switch_2;

--RGB_1(2) <= switch_3;
--RGB_1(1) <= switch_4;
--RGB_1(0) <= switch_5;

end architecture RTL;
