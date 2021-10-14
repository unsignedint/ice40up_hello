--
-- iCE40 UP Breakout Board VHDL Hello World example
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- need this for the Lattice hard-IP macros
-- c.f. https://www.latticesemi.com/en/Support/AnswerDatabase/5/6/8/5682
-- and https://stackoverflow.com/a/50652229
library sb_ice40_components_syn;
use sb_ice40_components_syn.components.all;


entity top is
port (
    i_clk_12        : in  std_logic;
    o_heartbeat     : out std_logic;
    o_red_n         : out std_logic;
    o_blue_n        : out std_logic;
    o_green_n       : out std_logic
);
end top;

architecture rtl of top is
    -- signal for free-running counter inferred register
    signal s_freq_counter   : std_logic_vector(28 downto 0);
begin

    -- free running 28-bit counter for debug and heartbeat
    p_freq_count: process(i_clk_12)
    begin
        if rising_edge(i_clk_12) then
            s_freq_counter <= s_freq_counter + 1;
        end if;
    end process;

    -- heartbeat output
    o_heartbeat <= s_freq_counter(23);

    -- instantiate the built-in LED driver macro
    -- see SB_RGBA_DRV macro in Lattice iCE Technology Library document
    u_rgb_drv: SB_RGBA_DRV
    generic map (
        -- force all to 4mA output
        RGB0_CURRENT    => "0b000001",
        RGB1_CURRENT    => "0b000001",
        RGB2_CURRENT    => "0b000001"
    )
    port map (
        CURREN          => '1',
        RGBLEDEN        => '1',
        RGB0PWM         => s_freq_counter(25) and s_freq_counter(24),
        RGB1PWM         => (not s_freq_counter(25)) and s_freq_counter(24),
        RGB2PWM         => s_freq_counter(25) and (not s_freq_counter(24)),
        RGB0            => o_red_n,
        RGB1            => o_blue_n,
        RGB2            => o_green_n
    );

end architecture;
