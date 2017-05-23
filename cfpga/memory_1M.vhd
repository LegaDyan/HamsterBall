LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

entity memory_1M is 
port(
--- reset & clk 
	clk      : in std_logic;
	reset    : in std_logic;
--- cpu 
	start    : in std_logic;
	mem_op   : in std_logic;  -- 0:read 1:write
	addr_in  : in std_logic_vector(19 downto 0);
	date_in  : in std_logic_vector(31 downto 0);
	date_out : out std_logic_vector(31 downto 0);
	c_mem_cs : in std_logic;
--- memory 	
	BASERAMWE_tmp           : out std_logic;                       
	BASERAMOE_tmp           : out std_logic;                       
	BASERAMCE_tmp           : out std_logic;
	BASERAMADDR_tmp         : out std_logic_vector(19 downto 0);                                                              
	BASERAMDATA_tmp         : inout std_logic_vector(31 downto 0)
);
end memory_1M;
architecture logic_memy of memory_1M is 

type memory_state is  (idle,mem_read,mem_write,mem_end);
signal state : memory_state;
signal mem_cnt : integer range 0 to 4;

signal start_op : std_logic;

 
begin         

start_op<='1' when start='1' and c_mem_cs='0' else 
			 '0';

process(reset,clk)
begin 
	if reset='0' then 
		state<=idle;
		mem_cnt<=0;
	elsif clk'event and clk='1' then 
		case state is 
			when idle      => if start_op='1' and mem_op='0' then 
										state<=mem_read;
									elsif start_op='1' and mem_op='1' then 
										state<=mem_write;
									else 
										state<=idle;
									end if ;
			when mem_read  => if mem_cnt=2 then 
										state<=mem_end;
									else 
										mem_cnt<=mem_cnt+1;
									end if ;
			when mem_write => if mem_cnt=2 then 
										state<=mem_end;
									else 
										mem_cnt<=mem_cnt+1;
									end if ;
			when mem_end   => if start_op='0' then 
										state<=idle;
										mem_cnt<=0;
									end if ;
			when others    => state<=idle;
		end case ;
	end if ;
end process;


process(reset,clk)
begin 
	if reset='0' then 
		BASERAMCE_tmp<='1';                                 
		BASERAMOE_tmp<='1';  
		BASERAMWE_tmp<='1';								
		BASERAMADDR_tmp<=(others=>'Z');                                                                    
		BASERAMDATA_tmp<=(others=>'Z'); 		
	elsif clk'event and clk='1' then 
		case state is 
			when idle      => BASERAMCE_tmp<='1';                                 
		                     BASERAMOE_tmp<='1';  
		                     BASERAMWE_tmp<='1';								
		                     BASERAMADDR_tmp<=(others=>'Z');                                                                    
		                     BASERAMDATA_tmp<=(others=>'Z');

									
			when mem_read  => BASERAMCE_tmp<='0';                                 
		                     BASERAMOE_tmp<='0';  
		                     BASERAMWE_tmp<='1';								
		                     BASERAMADDR_tmp<=addr_in;                                                                    
		                     date_out<=BASERAMDATA_tmp;
									
		   when mem_write => BASERAMCE_tmp<='0';                                 
		                     BASERAMOE_tmp<='1';  
		                     BASERAMWE_tmp<='0';								
		                     BASERAMADDR_tmp<=addr_in;                                                                    
		                     BASERAMDATA_tmp<=date_in;

									
			when mem_end   => BASERAMCE_tmp<='1';                                 
		                     BASERAMOE_tmp<='1';  
		                     BASERAMWE_tmp<='1';								
		                     BASERAMADDR_tmp<=(others=>'Z');                                                                    
		                     BASERAMDATA_tmp<=(others=>'Z');
	
									
			when others    => BASERAMCE_tmp<='1';                                 
		                     BASERAMOE_tmp<='1';  
		                     BASERAMWE_tmp<='1';								
		                     BASERAMADDR_tmp<=(others=>'Z');                                                                    
		                     BASERAMDATA_tmp<=(others=>'Z');
									
		end case ;
	end if ;
end process;

end ;