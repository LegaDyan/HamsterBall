library ieee;
use ieee.std_logic_1164.all;

entity HamsterBall is
generic(
	depth	:	integer:= 1048576
	);
port(
	clk_0,reset,datain,clkin: in std_logic;
	hs,vs, seg, segf, breako, f0o, do: out STD_LOGIC; 
	r,g,b: out STD_LOGIC_vector(2 downto 0)
);
end HamsterBall;

architecture arc of HamsterBall is

---------------------------------signals----------------------------------------------

signal address_tmp	: std_logic_vector(15 downto 0);
signal address_ball	: std_logic_vector(11 downto 0);
signal clk50, clkf	: std_logic;
signal q_rgb		: std_logic_vector(8 downto 0);
signal q_ball		: std_logic_vector(2 downto 0);
signal vx, vy		: std_logic_vector(2 downto 0);
signal mx, my		: std_logic;
signal clkv			: std_logic;
signal count		: integer range 0 to 10000 := 0;

--------------------------------components-----------------------------------------

component sram is 
port(
--- reset & clk 
	clk      : in std_logic;
	reset    : in std_logic;
	wr		: in std_logic;		--1:write 0:read
	addr_e	: in std_logic_vector(19 downto 0);   
	--button3	: in std_logic;
	--button4	: in std_logic;
	--LEDBUS	: out std_logic_vector(31 downto 0);-- 32 LED
--- memory 	to CFPGA
	BASERAMWE           : out std_logic;   --write                    
	BASERAMOE           : out std_logic;    --read                   
	BASERAMCE           : out std_logic;		--cs
	BASERAMADDR         : out std_logic_vector(19 downto 0);                                                              
	BASERAMDATA         : inout std_logic_vector(8 downto 0)
);
end component sram;

component vga640480 is
	 port(
			address		:		  out	STD_LOGIC_VECTOR(15 DOWNTO 0);
			addressBall :         out STD_LOGIC_VECTOR(11 downto 0);
			reset       :         in  STD_LOGIC;
			clk50       :		  out std_logic; 
			qr, qg, qb, qball	:		  in STD_LOGIC_vector(2 downto 0);
			clk_0       :         in  STD_LOGIC; --100M时钟输入
			hs,vs       :         out STD_LOGIC; --行同步、场同步信号
			r,g,b       :         out STD_LOGIC_vector(2 downto 0);
			vX, vY		:         in STD_LOGIC_VECTOR(2 downto 0);
			mX, mY		:		  in STD_LOGIC;
			clk_v	    :         out std_logic
	  );
end component;

component mymap is
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);	--20 bits
		clock		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
end component mymap;

component ball IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q			: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
end component;

component controller is
port(
	datain,clkin,fclk,rst_in	: in std_logic;
	clk_v						: in std_logic;
	vXout, vYout				: out std_logic_vector(2 downto 0);
	mX, mY						: out std_logic
);
END component;

---------------------------------------process-------------------------------------------

begin

process (clk_0)
begin
	if (clk_0'event and clk_0 = '1') then
		count <= count + 1;
		if (count = 750) then
			if clkf = '0' then
				clkf <= '1';
			else
				clkf <= '0';
			end if;
			count <= 0;
		end if;
	end if;
	
end process;

u1: vga640480 port map(
						address=>address_tmp, 
						addressBall=>address_ball,
						reset=>reset, 
						clk50=>clk50, 
						qr=>q_rgb(8) & q_rgb(7) & q_rgb(6),
						qg=>q_rgb(5) & q_rgb(4) & q_rgb(3),
						qb=>q_rgb(2) & q_rgb(1) & q_rgb(0),
						qball=>q_ball,
						clk_0=>clk_0, 
						hs=>hs, vs=>vs, 
						r=>r, g=>g, b=>b,
						vX=>vx, vY=>vy,
						mX=>mx, mY=>my,
						clk_v=>clkv
					);
u2: mymap port map(	
						address=>address_tmp, 
						clock=>clk50, 
						q=>q_rgb
					);

u5: ball port map(	
						address=>address_ball, 
						clock=>clk50, 
						q=>q_ball
					);
u6: controller port map(datain,clkin,clkf,reset,clkv,vx,vy,mx,my);

end arc;