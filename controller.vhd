LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Controller is
    port(
        clk, rst: in std_logic;
        skey, dkey, wkey, akey: in std_logic;
        vX, vY: out std_logic_vector(3 downto 0)
    );
end Controller;

architecture arch of Controller is
    signal accX, accY: in std_logic;
begin
    V : process(clk, rst)
    begin
        if (rst) then
            vX <= others => '0';
            vY <= others => '0';
        elsif (clk'event and clk = '1') then
            if (vX + accX < 5) then
                vX <= vX + accX - accXm;
            else
                vX <= 5;
            end if;
            if (vY + accY < 5) then
                vY <= vY + accY - accYm;
            else
                vY <= 5;
            end if;
        end if;
    end process;

    accX <= skey;
    accY <= dkey;
    accXm <= wkey;
    accYm <= akey;

end architecture;
