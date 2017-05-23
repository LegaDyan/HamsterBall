LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

entity cpu_ahb is 
port(
--- clk & reset 
		clk                		: in std_logic;
		reset               	: in std_logic;
--- cpu_ahb 
		ARM_INT             	: out std_logic_vector(3 downto 0);                                              
		NXDREQ0             	: out std_logic; 								--����û���幦��                           
		NXDACK0             	: out std_logic; 								--����û���幦��
		NWAIT               	: out std_logic;    							--����û���幦��
		NRESET              	: in std_logic;                    
		LNWE                	: in std_logic;                     
		LNOE                	: in std_logic;                   
		LNGCS5              	: in std_logic;                  
		LNGCS3              	: in std_logic;                   
		LNGCS2              	: in std_logic;                  
		LNGCS1              	: in std_logic;                  
		LDATA               	: inout std_logic_vector(31 downto 0);                             
		LADDR               	: in std_logic_vector(24 downto 0);
--- cmd ctl 
      cpu_cmd             	: out std_logic_vector(15 downto 0);
--  LED
--		EXTERNAL_DEVICE_BUS_in 		: 	in std_logic_vector(55 downto 0);
--		EXTERNAL_DEVICE_BUS_out		:	out std_logic_vector(55 downto 0);
		EXTERNAL_DEVICE_BUS1 	: in std_LOGIC_VECTOR(15 dowNTO 0);
		EXTERNAL_DEVICE_BUS2		: in std_LOGIC_VECTOR(15 dowNTO 0);
		EXTERNAL_DEVICE_BUS3		: in std_LOGIC_VECTOR(15 dowNTO 0);
		EXTERNAL_DEVICE_BUS4		: in std_LOGIC_VECTOR(7 dowNTO 0);
--- memory control 
		mem_start              	: out std_logic;
	   mem_op              	: out std_logic;  						-- 0:read 1:write
	   mem_addr_in          	: out std_logic_vector(19 downto 0);
	   mem_date_in          	: out std_logic_vector(31 downto 0);
	   mem_date_out          	: in std_logic_vector(31 downto 0);
--- efpga reg bus 
		CE_REG_CS           	: buffer std_logic;    						--	CE_REG_WE: out std_logic;                       
	   CE_REG_OP           	: buffer std_logic;    						--	CE_REG_OE: out std_logic;     -- 0:read 1:write                 
	   CE_REG_ADDR         	: out std_logic_vector(7 downto 0);                           
	   CE_REG_DATA         	: inout std_logic_vector(31 downto 0)  	
);
end entity ;
architecture logic_ahb of cpu_ahb is 

--component Reg_256 is
--port(
--		clock		: IN STD_LOGIC  := '1';
--		data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
--		rdaddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--		wraddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--		wren		: IN STD_LOGIC  := '0';
--		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
--);
--end component;

---------------------------------------------------------------------------Reg_Ram
signal Write_reg_data : std_logic_vector( 31 downto 0);
signal Read_reg_data : std_logic_vector( 31 downto 0);
signal rdaddress		: STD_LOGIC_VECTOR (7 DOWNTO 0);
signal wraddress		: STD_LOGIC_VECTOR (7 DOWNTO 0);
----------------------------------------------------------------------------
signal reg_select 	: std_logic_vector(7 downto 0);
signal read_reg   	: std_logic_vector(15 downto 0);
signal write_reg  	: std_logic_vector(15 downto 0);
signal epld_cs    	: std_logic;
signal mem_cs     	: std_logic;
signal efpga_cs   	: std_logic;

signal ahb_ver     	: std_logic_vector(15 downto 0);   --- 0x0   R
signal test_reg    	: std_logic_vector(15 downto 0);   --- 0x1   R+W
signal memin_Hdate 	: std_logic_vector(15 downto 0);   --- 0x2   R+W
signal memout_Hdate : std_logic_vector(15 downto 0);   --- 0x3   R
signal memout_Ldate 	: std_logic_vector(15 downto 0);   --- 0x4   R
signal cpu_cmdreg  	: std_logic_vector(15 downto 0);   --- 0x5   R+W
signal efpga_regH   	: std_logic_vector(15 downto 0);   --- 0x6   R+W
signal efpga_dageH  	: std_logic_vector(15 downto 0);   --- 0x7   R
-------------------------------------------------------------------------------------------------
signal EXTERNAL_DEVICE_BUS1_BUFF : std_LOGIC_VECTOR(15 downto 0);

begin 

--Reg_512 : Reg_256
--port map(
--		clock		=>clk,
--		data			=>Write_reg_data,
--		rdaddress	=>rdaddress,
--		wraddress	=>wraddress,
--		wren		=>wren,
--		q			=>Read_reg_data
--);

NXDREQ0<='Z';                                       
NXDACK0<='Z';                         
NWAIT<='Z';  
reg_select<=LADDR(9 downto 2 );

epld_cs<=	'0' 	when LADDR(22 downto 21)=b"00" and LNGCS5='0' -- 0x000000 ~ 0x03ffff 	片选控制FPGA
				else        
			'1';
efpga_cs<=	'0' 	when LADDR(22 downto 21)=b"01" and LNGCS5='0' -- 0x080000 ~ 0x0800ff 	片选实验FPGA
				else       
			'1';
mem_cs<=	'0' 	when LADDR(22)='1' and LNGCS5='0'				 -- 0x100000 ~ 0x1fffff 	片选内存	
				else    		 
			'1';
-------------------------------------------------------------------------------LED 

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
		if LNGCS5='0' and LNOE='0' and epld_cs='0' then 											--Read
			case reg_select is 
					when x"00" 	=> read_reg		<=ahb_ver;
					when x"01" 	=> read_reg		<=test_reg;									--	调试用的寄存器
					when x"02" 	=> read_reg		<=memin_Hdate;
					when x"03" 	=> read_reg		<=memout_Hdate;
					when x"04" 	=> read_reg		<=memout_Ldate;
					when x"05" 	=> read_reg		<=cpu_cmdreg;	
					when x"06" 	=> read_reg		<=efpga_regH;
					when x"07" 	=> read_reg		<=efpga_dageH;
					when x"08"	=> read_reg		<=EXTERNAL_DEVICE_BUS1_BUFF;
					when x"09" 	=> read_reg 	<=EXTERNAL_DEVICE_BUS2;	-- 	读LED值
					when x"0A" 	=> read_reg 	<=EXTERNAL_DEVICE_BUS3;	--	读LED值
					when x"0B" 	=> read_reg 	<=x"FF" & EXTERNAL_DEVICE_BUS4;
					when others	=> read_reg		<=(others=>'0');
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
		test_reg		<=(others=>'0');
		memin_Hdate	<=(others=>'0');
		cpu_cmdreg	<=(others=>'0');
		efpga_regH	<=(others=>'0');
	elsif clk'event and clk='1' then
		if LNGCS5='0' and LNWE='0' and epld_cs='0'  then 
			case reg_select is 
				when x"01" 	=> 	test_reg									<=write_reg;
				when x"02" 	=> 	memin_Hdate								<=write_reg;
				when x"03" 	=>	Null;
				when x"04" 	=>	Null;
				when x"05" 	=> 	cpu_cmdreg								<=write_reg;
				when x"06" 	=> 	efpga_regH								<=write_reg;
				when x"07" 	=>	Null;
				--when x"08" 	=> 	EXTERNAL_DEVICE_BUS1					<=write_reg;
								--EXTERNAL_DEVICE_BUS1_BUFF			<=write_reg;
--				when x"FC" 	=> 	EXTERNAL_DEVICE_BUS_out(31 downto 16)	<=write_reg;
--				when x"FD" 	=> 	EXTERNAL_DEVICE_BUS_out(47 downto 32)	<=write_reg;	--	写LED  
--				when x"FE" 	=> 	EXTERNAL_DEVICE_BUS_out(55 downto 48)	<=write_reg(7 downto 0);	--	写LED
				when others	=> 	null;
			end case;
		end if ;
	end if ;
end process;
--- memory control
mem_start<=not(mem_cs or LNGCS5 ); 
  
mem_op<=	'1' 	when LNWE='0' and LNOE='1'  												-- 0:read 1:write
				else  
			'0';
mem_addr_in		<=	LADDR(21 downto 2);
mem_date_in		<=	memin_Hdate & LDATA(15 downto 0);
memout_Hdate	<=	mem_date_out(31 downto 16);
memout_Ldate	<=	mem_date_out(15 downto 0);				
--- cmd ctl 
cpu_cmd<=cpu_cmdreg; 
--- efpga bus 
CE_REG_CS<=	'0' 	when efpga_cs='0' and LNGCS5='0' and (LNWE='0' or LNOE='0')
					else 
				'1';                                    
CE_REG_OP<=	'1' 	when LNWE='0' and LNOE='1' 
					else   -- 0:read 1:write
				'0';         
				
CE_REG_ADDR<=LADDR(9 downto 2); 
                                  
CE_REG_DATA<=	efpga_regH & LDATA(15 downto 0) 	when  	CE_REG_OP ='1' and CE_REG_CS='0' 
													else 
				(others=>'Z');
 
LDATA(15 downto 0)<=	CE_REG_DATA(15 downto 0) when 	CE_REG_OP ='0' and CE_REG_CS='0' 
													else 
				(others=>'Z');

process(CE_REG_OP,CE_REG_CS)
begin 
	if CE_REG_OP='0' and CE_REG_CS='0' then 
		efpga_dageH<=CE_REG_DATA(31 downto 16)	;	
	end if ;
end process;

end ;
