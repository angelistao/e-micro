library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity karatsuba4b is
Port (

A4b : in std_logic_vector(3 downto 0);
B4b : in std_logic_vector(3 downto 0);

S8b : out std_logic_vector(7 downto 0)
);
end karatsuba4b;

architecture behavioral of karatsuba4b is

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

component karatsuba2_bits is
	Port (
	A2b : in STD_LOGIC_VECTOR(1 downto 0);
	B2b : in STD_LOGIC_VECTOR(1 downto 0);
	S4b : out STD_LOGIC_VECTOR(3 downto 0)
);
end component;

component karatsuba3b_aux is
	Port (
	A3b : in STD_LOGIC_VECTOR(2 downto 0);
	B3b : in STD_LOGIC_VECTOR(2 downto 0);
	S5b : out STD_LOGIC_VECTOR(4 downto 0)
);
end component;

component karatsuba3b is
	Port (
	A3b : in STD_LOGIC_VECTOR(2 downto 0);
	B3b : in STD_LOGIC_VECTOR(2 downto 0);
	S6b : out STD_LOGIC_VECTOR(5 downto 0)
);
end component;

	


signal mult1 : STD_LOGIC_vector(3 downto 0); --a*c
signal mult2 : std_logic_vector(5 downto 0); -- (a+b) * (c+d)
signal mult3 : STD_LOGIC_vector(3 downto 0); --b*d

signal ab : std_logic_vector(2 downto 0); --a+b
signal cd : std_logic_vector(2 downto 0); --c+d
-----------------------------------------

signal sub_parcial : std_logic_vector (5 downto 0);
signal subtracao : std_logic_vector(5 downto 0);

------------------------------------------

signal notmult1 : std_logic_vector(5 downto 0);
signal notmult3 : std_logic_vector(5 downto 0);

--------------------------------------------

signal mult1_final : std_logic_vector(7 downto 0);
signal mult2_final : std_logic_vector(7 downto 0);
signal mult3_final : std_logic_vector(7 downto 0);
signal result_parcial : std_logic_vector(7 downto 0);


begin

ADD1: karatsuba2_bits
	port map(
	A2b => A4b(3 downto 2),
	B2b => B4b (3 downto 2),
	S4b => mult1
);

ADD2: karatsuba2_bits
	port map(
	A2b => A4b(1 downto 0),
	B2b => B4b (1 downto 0),
	S4b => mult3
);


ADD3: cla_Xbits
	generic map (x => 3)
	port map(
	a => '0' & A4b(3 downto 2),
	b => '0' & A4b(1 downto 0),
	cin => '0',
	S => ab,
	cout => open --
);
	

ADD4: cla_Xbits
	generic map (x => 3)
	port map(
	a => '0' & B4b(3 downto 2),
	b => '0' & B4b(1 downto 0),
	cin => '0',
	S => cd,
	cout => open --
);

ADD5: karatsuba3b --mult 2
	port map(
	A3b => ab,
	B3b => cd,
	S6b => mult2
);

notmult1 <= "11" & not(mult1);
notmult3 <= "11" & not(mult3);

ADD6: cla_Xbits
	generic map (x => 6)
	port map(
	a => mult2,
	b => notmult1,
	cin => '1',
	S => sub_parcial,
	cout => open --
);

ADD7: cla_Xbits
	generic map (x => 6)
	port map(
	a => sub_parcial,
	b => notmult3,
	cin => '1',
	S => subtracao,
	cout => open --
);

mult1_final <= mult1 & "0000";
mult2_final <= subtracao & "00";
mult3_final <= "0000" & mult3;

ADD8: cla_Xbits
	generic map (x => 8)
	port map(
	a => mult1_final,
	b => mult2_final,
	cin => '0',
	S => result_parcial,
	cout => open --
);

ADD9: cla_Xbits
	generic map (x => 8)
	port map(
	a => result_parcial,
	b => mult3_final,
	cin => '0',
	S => S8b,
	cout => open --
);

end architecture behavioral;