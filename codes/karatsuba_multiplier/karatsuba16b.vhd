library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multiplier is
generic (
        N : integer := 16
    );
Port (

A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);

P : out std_logic_vector(31 downto 0)
);
end multiplier;

architecture behavioral of multiplier is

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


component karatsuba9b is
	Port (
	A9b : in STD_LOGIC_VECTOR(8 downto 0);
	B9b : in STD_LOGIC_VECTOR(8 downto 0);
	S18b : out STD_LOGIC_VECTOR(17 downto 0)
);
end component;

	


signal mult1 : STD_LOGIC_vector(17 downto 0); --a*c
signal mult2 : std_logic_vector(17 downto 0); -- (a+b) * (c+d)
signal mult3 : STD_LOGIC_vector(17 downto 0); --b*d

signal ab : std_logic_vector(8 downto 0); --a+b
signal cd : std_logic_vector(8 downto 0); --c+d
-----------------------------------------

signal sub_parcial : std_logic_vector (17 downto 0);
signal subtracao : std_logic_vector(17 downto 0);

------------------------------------------

signal result_parcial : std_logic_vector (31 downto 0);


begin

ADD1: karatsuba9b
	port map(
	A9b => '0' & A(15 downto 8),
	B9b => '0' & B (15 downto 8),
	S18b => mult1
);

ADD2: karatsuba9b
	port map(
	A9b => '0' & A(7 downto 0),
	B9b => '0' & B (7 downto 0),
	S18b => mult3
);


ADD3: cla_Xbits
	generic map (x => 9)
	port map(
	a => '0' & A(15 downto 8),
	b => '0' & A(7 downto 0),
	cin => '0',
	S => ab,
	cout => open --
);
	

ADD4: cla_Xbits
	generic map (x => 9)
	port map(
	a => '0' & B(15 downto 8),
	b => '0' & B(7 downto 0),
	cin => '0',
	S => cd,
	cout => open --
);

ADD5: karatsuba9b --mult 2
	port map(
	A9b => ab,
	B9b => cd,
	S18b => mult2
);

ADD6: cla_Xbits
	generic map (x => 18)
	port map(
	a => mult2,
	b => not(mult1),
	cin => '1',
	S => sub_parcial,
	cout => open --
);

ADD7: cla_Xbits
	generic map (x => 18)
	port map(
	a => sub_parcial,
	b => not(mult3),
	cin => '1',
	S => subtracao,
	cout => open --
);

ADD8: cla_Xbits
	generic map (x => 32)
	port map(
	a => mult1(15 downto 0) & "0000000000000000",
	b => "000000" & subtracao & "00000000",
	cin => '0',
	S => result_parcial,
	cout => open --
);

ADD9: cla_Xbits
	generic map (x => 32)
	port map(
	a => result_parcial,
	b => "00000000000000" & mult3,
	cin => '0',
	S => P,
	cout => open --
);

end architecture behavioral;
