LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

entity cfpga is 
port(
-------------------------------------------	
	CLOCK100M_FPGAC     	: in std_logic;
	M_NRESET           	: in std_logic;  
-------------------------------------------		      
	CLOCK110592					:in std_logic;
-------------------------------------------   
	GPIO_RESET          	: in std_logic;       
	GPIO_CLK            	: in std_logic;
	CLK_25M             	: in std_logic;
	WORK_LED            	: out std_logic;                               
	E_FPGAC_SWITCH_OE0  	: in std_logic;	                    
-------------------------------------------	
--	EXTERNAL_DEVICE_BUS 		: inout std_logic_vector(55 downto 0);
	EXTERNAL_DEVICE_BUS1 	: in std_LOGIC_VECTOR(15 dowNTO 0);
	EXTERNAL_DEVICE_BUS2		: in std_LOGIC_VECTOR(15 dowNTO 0);
	EXTERNAL_DEVICE_BUS3		: in std_LOGIC_VECTOR(15 dowNTO 0);
	EXTERNAL_DEVICE_BUS4		: in std_LOGIC_VECTOR(7 dowNTO 0);
------------------efpga mem----------------
	CE_MEMORY_WE        	: in std_logic;                                
	CE_MEMORY_OE        	: in std_logic;                       
	CE_MEMORY_CE        	: in std_logic;                      
	CE_MEMORY_ADDR      	: in std_logic_vector(19 downto 0);                          
	CE_MEMORY_DATA      	: inout std_logic_vector(31 downto 0);                        
-----------------efpga reg-----------------  
	CE_REG_CS           	: out std_logic;    											--	CE_REG_WE: out std_logic;                       
	CE_REG_OP           	: out std_logic;    											--	CE_REG_OE: out std_logic; 0:read 1:write                 
	CE_REG_ADDR         	: out std_logic_vector(7 downto 0);                           
	CE_REG_DATA         	: inout std_logic_vector(31 downto 0);                       
-----------------memory 1M-----------------                           
	BASERAMWE           	: out std_logic;                       
	BASERAMOE           	: out std_logic;                       
	BASERAMCE           	: out std_logic;
	BASERAMADDR         	: out std_logic_vector(19 downto 0);                                                              
	BASERAMDATA         	: inout std_logic_vector(31 downto 0);                                
-------------------cpu_i2c-----------------                                
	I2C_SDA             	: inout std_logic;                     
	I2C_SCL             	: out std_logic;
-------------------------------------------                              
	RECIVE              	: out std_logic_vector(5 downto 0);                          
	CE_INTERRUPT        	: out std_logic_vector(3 downto 0);                             
	CE_BACKUP           	: out std_logic_vector(3 downto 0); 
	BOARD_ID            	: in std_logic_vector(5 downto 0);                
--------------------cpu_ahb----------------               
	ARM_INT             	: out std_logic_vector(3 downto 0);                                              
	NXDREQ0            	: out std_logic;                            
	NXDACK0             	: out std_logic;            
	NWAIT               	: out std_logic;                     
	NRESET              	: in std_logic;                    
	LNWE                	: in std_logic;                     
	LNOE                	: in std_logic;                   
	LNGCS5              	: in std_logic;                  
	LNGCS3              	: in std_logic;                   
	LNGCS2              	: in std_logic;                  
	LNGCS1              	: in std_logic;                  
	LDATA               	: inout std_logic_vector(31 downto 0);                             
	LADDR               	: in std_logic_vector(24 downto 0)                                                        
	);
end entity ;

architecture logic_top of cfpga is 
---cmd ctl
signal cpu_cmd  :  std_logic_vector(15 downto 0);
signal c_mem_cs :  std_logic;
--- memory control signal 
signal mem_start    	: std_logic;
signal mem_op       	: std_logic;  -- 0:read 1:write
signal mem_addr_in  	: std_logic_vector(19 downto 0);
signal mem_date_in  	: std_logic_vector(31 downto 0);
signal mem_date_out 		: std_logic_vector(31 downto 0);

signal BASERAMWE_tmp           	: std_logic;                       
signal BASERAMOE_tmp           	: std_logic;                       
signal BASERAMCE_tmp           	: std_logic;
signal BASERAMADDR_tmp         	: std_logic_vector(19 downto 0);                                                              
signal BASERAMDATA_tmp        		: std_logic_vector(31 downto 0);
--signal EXTERNAL_DEVICE_BUS_in		: std_LOGIC_VECTOR(55 downto 0);
--signal EXTERNAL_DEVICE_BUS_out		: std_LOGIC_VECTOR(55 downto 0);
component cpu_ahb is 
port(
--- clk & reset 
		clk                 	: in std_logic;
		reset               	: in std_logic;
--- cpu_ahb 
		ARM_INT             	: out std_logic_vector(3 downto 0);                                              
		NXDREQ0             	: out std_logic;                            
		NXDACK0             	: out std_logic;            
		NWAIT               	: out std_logic;                     
		NRESET              	: in std_logic;                    
		LNWE                	: in std_logic;                     
		LNOE                	: in std_logic;                   
		LNGCS5              	: in std_logic;                  
		LNGCS3              	: in std_logic;                   
		LNGCS2              	: in std_logic;                  
		LNGCS1              	: in std_logic;                  
		LDATA               	: inout std_logic_vector(31 downto 0);                             
		LADDR               	: in std_logic_vector(24 downto 0) ;
--- cmd ctl 
      cpu_cmd             	: out std_logic_vector(15 downto 0);
--  LED
--		EXTERNAL_DEVICE_BUS_in	:	in 	std_LOGIC_VECTOR(55 downto 0);
--		EXTERNAL_DEVICE_BUS_out	:	out std_LOGIC_VECTOR(55 downto 0);
		EXTERNAL_DEVICE_BUS1 	: in std_LOGIC_VECTOR(15 dowNTO 0);
		EXTERNAL_DEVICE_BUS2		: in std_LOGIC_VECTOR(15 dowNTO 0);
		EXTERNAL_DEVICE_BUS3		: in std_LOGIC_VECTOR(15 dowNTO 0);
		EXTERNAL_DEVICE_BUS4		: in std_LOGIC_VECTOR(7 dowNTO 0);
--- memory control 
		mem_start              	: out std_logic;
	   mem_op               	: out std_logic;  -- 0:read 1:write
	   mem_addr_in           	: out std_logic_vector(19 downto 0);
	   mem_date_in           	: out std_logic_vector(31 downto 0);
	   mem_date_out          	: in std_logic_vector(31 downto 0);
--- efpga reg bus 
		CE_REG_CS         		: out std_logic;    --	CE_REG_WE: out std_logic;                       
	   CE_REG_OP         		: out std_logic;    --	CE_REG_OE: out std_logic;     -- 0:read 1:write                 
	   CE_REG_ADDR       		: out std_logic_vector(7 downto 0);                           
	   CE_REG_DATA        	: inout std_logic_vector(31 downto 0) 
);
end component ;

component cmd_ctl is 
port(
		cpu_cmd  : in std_logic_vector(15 downto 0);
		c_mem_cs : out std_logic

);
end component ;

component memory_1M is 
port(
--- reset & clk 
	clk   		: in std_logic;
	reset 		: in std_logic;
--- cpu 
   start    	: in std_logic;
	mem_op   	: in std_logic;  -- 0:read 1:write
	addr_in  	: in std_logic_vector(19 downto 0);
	date_in  	: in std_logic_vector(31 downto 0);
	date_out 	: out std_logic_vector(31 downto 0);
	c_mem_cs 	: in std_logic;
--- memory 	
	BASERAMWE_tmp           	: out std_logic;                       
	BASERAMOE_tmp           	: out std_logic;                       
	BASERAMCE_tmp           	: out std_logic;
	BASERAMADDR_tmp         	: out std_logic_vector(19 downto 0);                                                              
	BASERAMDATA_tmp         	: inout std_logic_vector(31 downto 0)
);
end component;

--component external_ctl is 
--port(
----- clk & reset 
--		clk     : in std_logic;
--		reset   : in std_logic;
----- external device bus 
--		EXTERNAL_DEVICE_BUS : out std_logic_vector(55 downto 0)
--);
--end component;



begin	
 
uut_ahb: cpu_ahb
port map (
--- clk & reset 
		clk        		=> CLOCK100M_FPGAC,             
		reset      		=> M_NRESET,       
--- cpu_ahb 
		ARM_INT    		=> ARM_INT,                                                       
		NXDREQ0    		=> NXDREQ0,                                   
		NXDACK0    		=> NXDACK0,                     
		NWAIT      		=> NWAIT,                            
		NRESET     		=> NRESET,                             
		LNWE       		=> LNWE,                            
		LNOE       		=> LNOE,                          
		LNGCS5     		=> LNGCS5,                        
		LNGCS3     		=> LNGCS3,                          
		LNGCS2     		=> LNGCS2,                         
		LNGCS1     		=> LNGCS1,                           
		LDATA      		=> LDATA,                                     
		LADDR      		=> LADDR,
--- cmd ctl 
		cpu_cmd    		=> cpu_cmd,
--  LED
		EXTERNAL_DEVICE_BUS1 	=>EXTERNAL_DEVICE_BUS1,
		EXTERNAL_DEVICE_BUS2		=>EXTERNAL_DEVICE_BUS2,
		EXTERNAL_DEVICE_BUS3		=>EXTERNAL_DEVICE_BUS3,
		EXTERNAL_DEVICE_BUS4		=>EXTERNAL_DEVICE_BUS4,
--- memory control
		mem_start     		=> mem_start,               
	   mem_op       	=> mem_op,         
	   mem_addr_in    	=> mem_addr_in,         
	   mem_date_in    	=> mem_date_in,        
	   mem_date_out   	=> mem_date_out,
--- efpga reg bus 
		CE_REG_CS      	=> CE_REG_CS,                             
	   CE_REG_OP      	=> CE_REG_OP,                   
	   CE_REG_ADDR    	=> CE_REG_ADDR,                                
	   CE_REG_DATA    	=> CE_REG_DATA     
);


uut_cmd: cmd_ctl 
port map (
		cpu_cmd  => cpu_cmd,
		c_mem_cs => c_mem_cs

);

uut_memy: memory_1M
port map 
(
--- reset & clk 
	clk         	=> CLOCK100M_FPGAC,
	reset       	=> M_NRESET,
--- cpu
	start       	=> mem_start,
	mem_op      	=> mem_op,
	addr_in     	=> mem_addr_in,
	date_in     	=> mem_date_in,
	date_out    	=> mem_date_out,
	c_mem_cs    	=> c_mem_cs,
--- memory 	
	BASERAMWE_tmp   	=> BASERAMWE_tmp,                             
	BASERAMOE_tmp   	=> BASERAMOE_tmp,                             
	BASERAMCE_tmp   		=> BASERAMCE_tmp,     
	BASERAMADDR_tmp 		=> BASERAMADDR_tmp,                                                                 
	BASERAMDATA_tmp 		=> BASERAMDATA_tmp       
);

-------------------------memory access port select--------------------
BASERAMWE 	<= BASERAMWE_tmp   when c_mem_cs='0' else
             CE_MEMORY_WE;   
				 
BASERAMOE 	<= BASERAMOE_tmp   when c_mem_cs='0' else 
             CE_MEMORY_OE;
				 
BASERAMCE 	<= BASERAMCE_tmp   when c_mem_cs='0' else 
             CE_MEMORY_CE;
				 
BASERAMADDR 	<= BASERAMADDR_tmp when c_mem_cs='0' else 
               CE_MEMORY_ADDR;
					
BASERAMDATA 	<= BASERAMDATA_tmp when c_mem_cs='0' and mem_op='1'  else      
               (others=>'Z');
					
BASERAMDATA_tmp	<=	BASERAMDATA when c_mem_cs='0' and mem_op='0' else      
               (others=>'Z'); 					

BASERAMDATA		<= CE_MEMORY_DATA when c_mem_cs='1'  and CE_MEMORY_WE='0' else      
               (others=>'Z');
					

CE_MEMORY_DATA	<=	BASERAMDATA when c_mem_cs='1' and CE_MEMORY_OE='0' else      
               (others=>'Z'); 

-----------------------------------------------------------------------			
--uut_external_bus : external_ctl 
--port map (
----- clk & reset 
--		clk                 => CLOCK100M_FPGAC, 
--		reset               => M_NRESET,
----- external device bus 
--		EXTERNAL_DEVICE_BUS => EXTERNAL_DEVICE_BUS
--);
--process(CLOCK100M_FPGAC,LNOE,LNWE,EXTERNAL_DEVICE_BUS)
--begin
--	if CLOCK100M_FPGAC'event and CLOCK100M_FPGAC='0' then
--		if 	LNOE='0' then 
--			EXTERNAL_DEVICE_BUS_in	<=	EXTERNAL_DEVICE_BUS;
--		elsif LNWE='0' then
--			EXTERNAL_DEVICE_BUS	<=(others=>'0');
--			EXTERNAL_DEVICE_BUS	<=	EXTERNAL_DEVICE_BUS_out;
--		end if;
--	end if;
--end process;
WORK_LED<='0';

end ;