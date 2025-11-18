library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sample_data is
    Port ( 
        clk              : in  STD_LOGIC;
        sample_clk       : in  STD_LOGIC; 
        rst              : in  STD_LOGIC;
        start_btn        : in  STD_LOGIC;
        mem_full         : in  STD_LOGIC;
        read_address     : out STD_LOGIC_VECTOR (13 downto 0);
        read_sample      : in  STD_LOGIC_VECTOR (7 downto 0);
        pwm_out          : out STD_LOGIC
    );
end sample_data;

architecture Behavioral of sample_data is

    constant MEM_DEPTH : integer := 16384;  -- 2^14 depth (fits 14-bit address)
    constant PWM_BITS  : integer := 8;      -- 8-bit audio PWM

    signal addr_cnt        : unsigned(13 downto 0) := (others=>'0');
    signal current_sample  : unsigned(7 downto 0) := (others=>'0');
    signal pwm_counter     : unsigned(7 downto 0) := (others=>'0');
    signal playing         : std_logic := '0';

begin

---------------------------------------------------------
-- SAMPLE FETCH PROCESS
---------------------------------------------------------
process(clk)
begin
    if rising_edge(sample_clk) then
        
        if rst = '1' then
            addr_cnt  <= (others=>'0');
            playing   <= '0';
        
        else
            -- start playback when memory is full
            if start_btn = '1' and mem_full = '1' then
                playing <= '1';
            end if;

            if playing = '1' then
                current_sample <= unsigned(read_sample);

                -- increment sample address
                if addr_cnt = MEM_DEPTH-1 then
                    addr_cnt <= (others=>'0');   -- loop
                else
                    addr_cnt <= addr_cnt + 1;
                end if;
            end if;
        end if;
    end if;
end process;

read_address <= std_logic_vector(addr_cnt);

---------------------------------------------------------
-- PWM GENERATION PROCESS
---------------------------------------------------------
process(clk)
begin
    if rising_edge(clk) then
        
        -- Compare counter to sample value
        if pwm_counter < current_sample then
            pwm_out <= '1';
        else
            pwm_out <= '0';
        end if;

        -- Increment PWM counter
        pwm_counter <= pwm_counter + 1;

    end if;
end process;

end Behavioral;
