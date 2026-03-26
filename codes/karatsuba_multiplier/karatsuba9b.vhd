
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity karatsuba9b is
Port (

A9b : in std_logic_vector(8 downto 0);
B9b : in std_logic_vector(8 downto 0);

S18b : out std_logic_vector(17 downto 0)
);
end karatsuba9b;

architecture behavioral of karatsuba9b is

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

component karatsuba6b is
	Port (
	A6b : in STD_LOGIC_VECTOR(5 downto 0);
	B6b : in STD_LOGIC_VECTOR(5 downto 0);
	S12b : out STD_LOGIC_VECTOR(11 downto 0)
);
end component;

	


signal mult1 : STD_LOGIC_vector(7 downto 0); --a*c
signal mult2 : std_logic_vector(11 downto 0); -- (a+b) * (c+d)
signal mult3 : STD_LOGIC_vector(11 downto 0); --b*d

signal ab : std_logic_vector(5 downto 0); --a+b
signal cd : std_logic_vector(5 downto 0); --c+d
-----------------------------------------

signal sub_parcial : std_logic_vector (11 downto 0);
signal subtracao : std_logic_vector(11 downto 0);

------------------------------------------

signal result_parcial : std_logic_vector (17 downto 0);


begin

ADD1: karatsuba4b
	port map(
	A4b => A9b(8 downto 5),
	B4b => B9b (8 downto 5),
	S8b => mult1
);

ADD2: karatsuba6b
	port map(
	A6b => '0' & A9b(4 downto 0),
	B6b => '0' & B9b (4 downto 0),
	S12b => mult3
);


ADD3: cla_Xbits
	generic map (x => 6)
	port map(
	a => "00" & A9b(8 downto 5),
	b => '0' & A9b(4 downto 0),
	cin => '0',
	S => ab,
	cout => open --
);
	

ADD4: cla_Xbits
	generic map (x => 6)
	port map(
	a => "00" & B9b(8 downto 5),
	b => '0' & B9b(4 downto 0),
	cin => '0',
	S => cd,
	cout => open --
);

ADD5: karatsuba6b --mult 2
	port map(
	A6b => ab,
	B6b => cd,
	S12b => mult2
);

ADD6: cla_Xbits
	generic map (x => 12)
	port map(
	a => mult2,
	b => "1111" & not(mult1),
	cin => '1',
	S => sub_parcial,
	cout => open --
);

ADD7: cla_Xbits
	generic map (x => 12)
	port map(
	a => sub_parcial,
	b => not(mult3),
	cin => '1',
	S => subtracao,
	cout => open --
);

ADD8: cla_Xbits
	generic map (x => 18)
	port map(
	a => mult1 & "0000000000",
	b => "0" & subtracao & "00000",
	cin => '0',
	S => result_parcial,
	cout => open --
);

ADD9: cla_Xbits
	generic map (x => 18)
	port map(
	a => result_parcial,
	b => "000000" & mult3,
	cin => '0',
	S => S18b,
	cout => open --
);

end architecture behavioral;