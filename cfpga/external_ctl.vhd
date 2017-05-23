LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

entity external_ctl is 
port(
--- clk & reset 
		clk     : in std_logic;
		reset   : in std_logic
--- external device bus 
--		EXTERNAL_DEVICE_BUS : in std_logic_vector(55 downto 0)
);
end entity;
architecture logic_external of external_ctl is  
signal test_cnt: std_logic_vector(31 downto 0);
begin 

process(reset,clk)
begin 
	if reset='0' then 
		test_cnt<=(others=>'0');
	elsif clk'event and clk='1' then 
		if test_cnt=x"ffffffff" then 
			test_cnt<=(others=>'0');
		else 
			test_cnt<=test_cnt+1;
		end if ;
	end if ;
end process;


end; 