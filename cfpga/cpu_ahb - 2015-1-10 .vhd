LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

entity cpu_ahb is 
port(
--- clk & reset 
		clk                 : in std_logic;
		reset               : in std_logic;
--- cpu_ahb 
		ARM_INT             : out std_logic_vector(3 downto 0);                                              
		NXDREQ0             : out std_logic;                            
		NXDACK0             : out std_logic;            
		NWAIT               : out std_logic;                     
		NRESET              : in std_logic;                    
		LNWE                : in std_logic;                     
		LNOE                : in std_logic;                   
		LNGCS5              : in std_logic;                  
		LNGCS3              : in std_logic;                   
		LNGCS2              : in std_logic;                  
		LNGCS1              : in std_logic;                  
		LDATA               : inout std_logic_vector(31 downto 0);                             
		LADDR               : in std_logic_vector(24 downto 0);
--- cmd ctl 
      cpu_cmd             : out std_logic_vector(15 downto 0);
--- memory control 
		mem_start               : out std_logic;
	   mem_op                  : out std_logic;  -- 0:read 1:write
	   mem_addr_in             : out std_logic_vector(19 downto 0);
	   mem_date_in             : out std_logic_vector(31 downto 0);
	   mem_date_out            : in std_logic_vector(31 downto 0) 	
);
end entity ;
architecture logic_ahb of cpu_ahb is 

signal reg_select : std_logic_vector(3 downto 0);
signal read_reg   : std_logic_vector(15 downto 0);
signal write_reg  : std_logic_vector(15 downto 0);
signal epld_cs    : std_logic;
signal mem_cs     : std_logic;

signal ahb_ver       : std_logic_vector(15 downto 0);   --- 0x0   R
signal test_reg      : std_logic_vector(15 downto 0);   --- 0x1   R+W
signal memin_Hdate   : std_logic_vector(15 downto 0);   --- 0x2   R+W
signal memout_Hdate  : std_logic_vector(15 downto 0);   --- 0x3   R
signal memout_Ldate  : std_logic_vector(15 downto 0);   --- 0x4   R
signal cpu_cmdreg    : std_logic_vector(15 downto 0);   --- 0x5   R+W

begin 

NXDREQ0<='Z';                                       
NXDACK0<='Z';                         
NWAIT<='Z';  
reg_select<=LADDR(5 downto 2 );

epld_cs<='0' when LADDR(22)='0' else 
			'1';
mem_cs<='0' when LADDR(22)='1' else 
			'1';

--rd 
process(reset,clk)
begin 
	if reset='0' then 
		LDATA<=(others=>'Z');
	elsif clk'event and clk='1' then
		if LNGCS5='0' and LNOE='0' and epld_cs='0' then 
			LDATA<=x"0000" & read_reg;
		else 
			LDATA<=(others=>'Z');
		end if ;
	end if ;
end process;

process(reset,clk)
begin 
	if reset='0' then 
		read_reg<=(others=>'0');
		ahb_ver<=x"0472";
	elsif clk'event and clk='1' then
		if LNGCS5='0' and LNOE='0' and epld_cs='0' then 
			case reg_select is 
				when x"0" => read_reg<=ahb_ver;
				when x"1" => read_reg<=test_reg;
				when x"2" => read_reg<=memin_Hdate;
				when x"3" => read_reg<=memout_Hdate;
			   when x"4" => read_reg<=memout_Ldate;
			   when x"5" => read_reg<=cpu_cmdreg;	
				when others=> read_reg<=(others=>'0');
			end case ;
		else 
			read_reg<=(others=>'0');
		end if ;
	end if ;
end process;
---wr 
process(reset,clk)
begin 
	if reset='0' then 
		write_reg<=(others=>'0');
	elsif clk'event and clk='1' then
		if LNGCS5='0' and LNWE='0' and epld_cs='0' then 
			write_reg<=LDATA(15 downto 0);
		else 
			write_reg<=(others=>'0');
		end if ;
	end if ;
end process;

process(reset,clk)
begin 
	if reset='0' then 
		test_reg<=(others=>'0');
		memin_Hdate<=(others=>'0');
		cpu_cmdreg<=(others=>'0');
	elsif clk'event and clk='1' then
		if LNGCS5='0' and LNWE='0' and epld_cs='0'  then 
			case reg_select is 
				when x"1" => test_reg<=write_reg;
				when x"2" => memin_Hdate<=write_reg;
				when x"5" => cpu_cmdreg<=write_reg;
				when others=> null;
			end case;
		end if ;
	end if ;
end process;

--- memory control
mem_start<=not(mem_cs or LNGCS5 );   
mem_op<='1' when LNWE='0' and LNOE='1' else   -- 0:read 1:write
			'0';
mem_addr_in<=LADDR(21 downto 2);
mem_date_in<=memin_Hdate & LDATA(15 downto 0);
memout_Hdate<=mem_date_out(31 downto 16);
memout_Ldate<=mem_date_out(15 downto 0);				
--- cmd ctl 
cpu_cmd<=cpu_cmdreg; 
            
 

end ;
