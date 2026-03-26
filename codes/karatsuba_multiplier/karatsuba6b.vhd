library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity karatsuba6b is
Port (

A6b : in std_logic_vector(5 downto 0);
B6b : in std_logic_vector(5 downto 0);

S12b : out std_logic_vector(11 downto 0)
);
end karatsuba6b;

architecture behavioral of karatsuba6b is

component cla_Xbits is
   generic (x : integer);
   Port (
    a : in STD_LOGIC_VECTOR(x-1 downto 0);
    b : in STD_LOGIC_VECTOR(x-1 downto 0);
    cin : in STD_LOGIC;
    S : out STD_LOGIC_VECTOR(x-1 downto 0);
    cout : out STD_LOGIC
);
end component;

component karatsuba4b is
	Port (
	A4b : in STD_LOGIC_VECTOR(3 downto 0);
	B4b : in STD_LOGIC_VECTOR(3 downto 0);
	S8b : out STD_LOGIC_VECTOR(7 downto 0)
);
end component;

component karatsuba3b is
	Port (
	A3b : in STD_LOGIC_VECTOR(2 downto 0);
	B3b : in STD_LOGIC_VECTOR(2 downto 0);
	S6b : out STD_LOGIC_VECTOR(5 downto 0)
);
end component;

	


signal mult1 : STD_LOGIC_vector(5 downto 0); --a*c
signal mult2 : std_logic_vector(7 downto 0); -- (a+b) * (c+d)
signal mult3 : STD_LOGIC_vector(5 downto 0); --b*d

signal ab : std_logic_vector(3 downto 0); --a+b
signal cd : std_logic_vector(3 downto 0); --c+d
-----------------------------------------

signal sub_parcial : std_logic_vector (7 downto 0);
signal subtracao : std_logic_vector(7 downto 0);

------------------------------------------

signal result_parcial : std_logic_vector (11 downto 0);


begin

ADD1: karatsuba3b
	port map(
	A3b => A6b(5 downto 3),
	B3b => B6b (5 downto 3),
	S6b => mult1
);

ADD2: karatsuba3b
	port map(
	A3b => A6b(2 downto 0),
	B3b => B6b (2 downto 0),
	S6b => mult3
);


ADD3: cla_Xbits
	generic map (x => 4)
	port map(
	a => '0' & A6b(5 downto 3),
	b => '0' & A6b(2 downto 0),
	cin => '0',
	S => ab,
	cout => open --
);
	

ADD4: cla_Xbits
	generic map (x => 4)
	port map(
	a => '0' & B6b(5 downto 3),
	b => '0' & B6b(2 downto 0),
	cin => '0',
	S => cd,
	cout => open --
);

ADD5: karatsuba4b --mult 2
	port map(
	A4b => ab,
	B4b => cd,
	S8b => mult2
);

ADD6: cla_Xbits
	generic map (x => 8)
	port map(
	a => mult2,
	b => "11" & not(mult1),
	cin => '1',
	S => sub_parcial,
	cout => open --
);

ADD7: cla_Xbits
	generic map (x => 8)
	port map(
	a => sub_parcial,
	b => "11" & not(mult3),
	cin => '1',
	S => subtracao,
	cout => open --
);

ADD8: cla_Xbits
	generic map (x => 12)
	port map(
	a => mult1 & "000000",
	b => "0" & subtracao & "000",
	cin => '0',
	S => result_parcial,
	cout => open --
);

ADD9: cla_Xbits
	generic map (x => 12)
	port map(
	a => result_parcial,
	b => "000000" & mult3,
	cin => '0',
	S => S12b,
	cout => open --
);

end architecture behavioral;