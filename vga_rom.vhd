library ieee;
use ieee.std_logic_1164.all;

entity HamsterBall is
port(
	clk_0,reset,datain,clkin: in std_logic;
	hs,vs, seg, segf, breako, f0o, do: out STD_LOGIC; 
	seg0,seg1:out std_logic_vector(6 downto 0);
	r,g,b: out STD_LOGIC_vector(2 downto 0)
);
end HamsterBall;

architecture arc of HamsterBall is

component vga640480 is
	 port(
			address		:		  out	STD_LOGIC_VECTOR(15 DOWNTO 0);
			reset       :         in  STD_LOGIC;
			clk50       :		  out std_logic; 
			qr, qg, qb	:		  in STD_LOGIC_vector(2 downto 0);
			clk_0       :         in  STD_LOGIC; --100M时钟输入
			hs,vs       :         out STD_LOGIC; --行同步、场同步信号
			r,g,b       :         out STD_LOGIC_vector(2 downto 0);
			vX, vY		:         in STD_LOGIC_VECTOR(2 downto 0);
			mX, mY		:		  in STD_LOGIC;
			clk_v	    :         out std_logic
	  );
end component;

component red IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;
component green IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
END component;
component blue IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		clock		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
end component;

component controller is
port(
	datain,clkin,fclk,rst_in: in std_logic;
	clk_v: in std_logic;
	vXout, vYout: out std_logic_vector(2 downto 0);
	mX, mY: out std_logic
);
END component;

signal address_tmp: std_logic_vector(15 downto 0);
signal clk50, clkf: std_logic;
signal q_red, q_green, q_blue: std_logic_vector(2 downto 0);
signal vx, vy: std_logic_vector(2 downto 0);
signal mx, my: std_logic;
signal clkv: std_logic;
signal count: integer range 0 to 10000 := 0;


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
						reset=>reset, 
						clk50=>clk50, 
						qr=>q_red,
						qg=>q_green,
						qb=>q_blue,
						clk_0=>clk_0, 
						hs=>hs, vs=>vs, 
						r=>r, g=>g, b=>b,
						vX=>vx, vY=>vy,
						mX=>mx, mY=>my,
						clk_v=>clkv
					);
u2: red port map(	
						address=>address_tmp, 
						clock=>clk50, 
						q=>q_red
					);
u3: green port map(	
						address=>address_tmp, 
						clock=>clk50, 
						q=>q_green
					);
u4: blue port map(	
						address=>address_tmp, 
						clock=>clk50, 
						q=>q_blue
					);
u5: controller port map(datain,clkin,clkf,reset,clkv,vx,vy,mx,my);

end arc;