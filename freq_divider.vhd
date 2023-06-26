--------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity freq_divider is
    port (
        clk   : in std_logic;
        out1  : buffer std_logic;
        out2  : buffer std_logic
    );
end entity;

architecture example of freq_divider is
    signal count1 : integer range 0 to 50000000;
    signal count2 : integer range 0 to 50000000;
begin
    process (clk)
    begin
        if rising_edge(clk) then
            count1 <= count1 + 1;
            count2 <= count2 + 1;

            if count1 = 24999999 then
                out1 <= not out1;
                count1 <= 1;
            end if;

            if count2 = 25000000 then
                out2 <= not out2;
                count2 <= 1;
            end if;
        end if;
    end process;
end example;