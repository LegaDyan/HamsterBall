library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity top is
port(
datain,clkin,fclk,rst_in: in std_logic;
seg0,seg1:out std_logic_vector(6 downto 0);
wkey, fok, breako,f0o, do:out std_logic
);
end top;

architecture behave of top is
component Keyboard is
port (
	datain, clkin : in std_logic ; -- PS2 clk and data
	fclk, rst : in std_logic ;  -- filter clock
	wkey : out std_logic ;  -- data output enable signal
	scancode : out std_logic_vector(7 downto 0) -- scan code signal output
	) ;
end component ;

component seg7 is
port(
code: in std_logic_vector(3 downto 0);
seg_out : out std_logic_vector(6 downto 0)
);
end component;

signal scancode : std_logic_vector(7 downto 0);
signal rst : std_logic;
signal clk_f: std_logic;
type state is (s0, s1);
signal q: state;
--signal foko : std_logic;
--signal break: std_logic;
--signal f00, d0: std_logic;
begin
rst<=not rst_in;
--fok <= foko;
u0: Keyboard port map(datain,clkin,fclk,rst,wkey,scancode);
u1: seg7 port map(scancode(3 downto 0),seg0);
u2: seg7 port map(scancode(7 downto 4),seg1);

--process(foko)
--begin
--	if (foko'event and foko = '1') then
----		if q = s0 then
----			if scancode = "11110000" then
----				q <= s1;
----			elsif scancode = "00011101" then
----				wkey <= '1';
----			end if;
----		else
----			q <= s0;
----			if scancode = "00011101" then
----				wkey <= '0';
----			end if;
----		end if;
--		case scancode is
--			when x"F0" => 
--				break <= '0';
--				if (f00 = '0') then
--					f00 <= '1';
--				else f00 <= '0';
--				end if;
--			when x"1D" => 
--				if (d0 = '0') then
--					d0 <= '1';
--				else d0 <= '0';
--				end if;
--				wkey <= break; 
--				break <= '1';
--			when others => break <= '1';
--		end case;
--	end if;
--end process;
--
--breako <= break;
--f0o <= f00;
--do <= d0;

end behave;
