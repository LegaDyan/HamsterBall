library ieee;
use ieee.std_logic_1164.all;

entity vga_rom is
port(
	clk_0,reset,datain,clkin: in std_logic;
	hs,vs: out STD_LOGIC; 
	r,g,b: out STD_LOGIC_vector(2 downto 0)
);
end vga_rom;

architecture vga_rom of vga_rom is

component vga640480 is
	 port(
			address		:		  out	STD_LOGIC_VECTOR(15 DOWNTO 0);
			reset       :         in  STD_LOGIC;
			clk50       :		  out std_logic; 
			qr, qg, qb	:		  in STD_LOGIC_vector(2 downto 0);
			clk_0       :         in  STD_LOGIC; --100M时钟输入
			hs,vs       :         out STD_LOGIC; --行同步、场同步信号
			r,g,b       :         out STD_LOGIC_vector(2 downto 0);
			wkey		:		  in STD_LOGIC
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

component top is
port(
	datain,clkin,fclk,rst_in: in std_logic;
	wkey:out std_logic
);
END component;

signal address_tmp: std_logic_vector(15 downto 0);
signal clk50: std_logic;
signal q_red, q_green, q_blue: std_logic_vector(2 downto 0);
signal wkey: std_logic;


begin

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
						wkey => wkey
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
u5: top port map(datain,clkin,clk_0,reset,wkey);
end vga_rom;