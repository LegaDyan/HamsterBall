LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

entity sram is 
port(
--- reset & clk 
	clk      : in std_logic;
	reset    : in std_logic;

	read_en	: in std_logic;	--1:write;0:read
	--button3	: in std_logic;
	--button4	: in std_logic;
	--LEDBUS	: out std_logic_vector(31 downto 0);-- 32 LED
--- memory 	to CFPGA
	BASERAMWE           : out std_logic;   --write                    
	BASERAMOE           : out std_logic;    --read                   
	BASERAMCE           : out std_logic;		--cs
	BASERAMADDR         : out std_logic_vector(19 downto 0);  --address                                                            
	BASERAMDATA         : inout std_logic_vector(31 downto 0)	--data
);
end SRAM;

architecture logic_memy of SRAM is 

type memory_state is  (idle,mem_read,mem_write,mem_end);
signal state : memory_state;	--cur_state
signal mem_cnt : integer range 0 to 4;
signal addr_in : std_logic_vector(19 downto 0);
signal data_out : std_logic_vector(31 downto 0);


begin         
process(reset,clk)
begin 
	if reset='0' then 
		state<=idle;
		mem_cnt<=0;
	elsif clk'event and clk='1' then 
		case state is 
			when idle      => if read_en='0' then 
										state<=mem_read;
									else 
										state<=mem_write;
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
			when mem_end   =>
										state<=idle;
										mem_cnt<=0;
			when others    => state<=idle;
		end case ;
	end if ;
end process;

process(reset,clk)
begin 
	if reset='0' then 
		BASERAMCE<='1';                                 
		BASERAMOE<='1';  
		BASERAMWE<='1';								
		BASERAMADDR<=(others=>'Z');                                                                    
		BASERAMDATA<=(others=>'Z'); 		
	elsif clk'event and clk='1' then 
		case state is 
			when idle      => BASERAMCE<='1';                                 
		                     BASERAMOE<='1';  
		                     BASERAMWE<='1';								
		                     BASERAMADDR<=(others=>'Z');                                                                    
		                     BASERAMDATA<=(others=>'Z');

									
			when mem_read  => BASERAMCE<='0';                                 
		                     BASERAMOE<='0';  
		                     BASERAMWE<='1';
									if button4 ='0' then
		                     BASERAMADDR<=x"00000";                                                                    
		                     data_out<=BASERAMDATA;
									else 
									BASERAMADDR<=x"00001";                                                                    
		                     data_out<=BASERAMDATA;
									end if;
		   when mem_write => BASERAMCE<='0';                                 
		                     BASERAMOE<='1';  
		                     BASERAMWE<='0';
									if button3 ='0' then
		                     BASERAMADDR<=x"00000";--addr_in;                                                                    
		                     BASERAMDATA<=x"FFFFFFFF";--date_in;
									else
									BASERAMADDR<=x"00001";--addr_in;                                                                    
		                     BASERAMDATA<="01010101010101010101010101010101";--date_in;
									end if;
			when mem_end   => BASERAMCE<='1';                                 
		                     BASERAMOE<='1';  
		                     BASERAMWE<='1';								
		                     BASERAMADDR<=(others=>'Z');                                                                    
		                     BASERAMDATA<=(others=>'Z');
	
									
			when others    => BASERAMCE<='1';                                 
		                     BASERAMOE<='1';  
		                     BASERAMWE<='1';								
		                     BASERAMADDR<=(others=>'Z');                                                                    
		                     BASERAMDATA<=(others=>'Z');
									
		end case ;
	end if ;
end process;

process(reset)
begin
		if reset = '0' then
		LEDBUS<=x"FFFF0000";
		else
		LEDBUS<=data_out;
		end if;
end process;


end ;