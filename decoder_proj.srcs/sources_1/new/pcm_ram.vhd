library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pcm_bram is
    generic(
        MEM_SIZE : integer := 60_000   -- 60k samples × 8 bits = 480 Kb 
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
end entity;

architecture rtl of pcm_bram is

    type ram_type is array(0 to MEM_SIZE-1) of std_logic_vector(7 downto 0);
    signal ram : ram_type := (others => (others => '0'));

    signal write_ptr : integer range 0 to MEM_SIZE := 0;

begin

    process(clk)
    begin
        if rising_edge(clk) then

            if reset = '1' then
                write_ptr <= 0;
                mem_full <= '0';

            else
                -- Check if BRAM is full
                if write_ptr + 3 >= MEM_SIZE then
                    mem_full <= '1';

                -- Write only when rx_we_n is 0 (active-low)
                elsif rx_we_n = '0' then
                    ram(write_ptr) <= data_in(31 downto 24);
                    ram(write_ptr+1) <= data_in(23 downto 16);
                    ram(write_ptr+2) <= data_in(15 downto 8);
                    ram(write_ptr+3) <= data_in(7 downto 0);
                    write_ptr <= write_ptr + 4;
                end if;

            end if;

        end if;
    end process;

end architecture;
