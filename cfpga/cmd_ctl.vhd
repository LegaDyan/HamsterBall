LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

entity cmd_ctl is 
port(
		cpu_cmd  : in std_logic_vector(15 downto 0);
		c_mem_cs : out std_logic

);
end entity ;

architecture logic_cmd of cmd_ctl is 
begin 
		c_mem_cs<='1';--cpu_cmd(0);  -- valued 0 enable control fpga access memory mode  valued 1 enable experiment fpga access memory mode  
end ;