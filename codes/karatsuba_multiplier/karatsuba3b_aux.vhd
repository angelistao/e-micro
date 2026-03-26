library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity karatsuba3b_aux is
Port (

A3b : in std_logic_vector(2 downto 0);
B3b : in std_logic_vector(2 downto 0);

S5b : out std_logic_vector(4 downto 0)
);
end karatsuba3b_aux;

architecture behavioral of karatsuba3b_aux is

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
	


signal mult1 : STD_LOGIC; --a*c
signal mult2 : std_logic_vector(3 downto 0); -- (a+b) * (c+d)
signal mult3 : STD_LOGIC_vector(3 downto 0); --b*d

signal ab : std_logic_vector(1 downto 0); --a+b
signal cd : std_logic_vector(1 downto 0); --c+d
-----------------------------------------

signal result_parcial : std_logic_vector(4 downto 0);
signal sub_parcial : std_logic_vector (3 downto 0);
signal subtracao : std_logic_vector(3 downto 0);

------------------------------------------

signal add3a :std_logic_vector(4 downto 0);
signal add3b :std_logic_vector(4 downto 0);

signal add9b :std_logic_vector(4 downto 0);
signal notmult1 : std_logic_vector(3 downto 0);
signal notmult3 : std_logic_vector(3 downto 0);

begin

mult1 <= A3b(2) and B3b(2);

ADD1: karatsuba2_bits --mult3
	port map(
	A2b => A3b (1 downto 0),
	B2b => B3b (1 downto 0),
	S4b => mult3
);



ab <=  A3b(1) & (((not(A3b(0))) and A3b(2)) or A3b(0));

cd <= B3b(1) & (((not(B3b(0))) and B3b(2)) or B3b(0));

ADD2: karatsuba2_bits--mult 2
	port map(
	A2b => ab,
	B2b => cd,
	S4b => mult2
);


notmult1 <= "111" & not(mult1);

ADD3: cla_Xbits --subtraindo mult2 - mult 1
generic map (x => 4)
port map (
    a => mult2, 
    b => notmult1,
    cin => '1',
    S => sub_parcial,
    cout => open --
);

notmult3 <= not(mult3);

ADD4: cla_Xbits --subtraindo sub_parcial - mult 3
generic map (x => 4)
port map (
    a => sub_parcial,
    b => notmult3,
    cin => '1',
    S => subtracao,
    cout => open --
);

add3a <= mult1 & "0000";
add3b <= subtracao(2 downto 0) & "00";


ADD5: cla_Xbits
generic map (x => 5)
port map(
    a => add3a,
    b => add3b,
    cin => '0',
    S => result_parcial,
    cout => open --
);

add9b <= '0' & mult3;
ADD6: cla_Xbits
generic map (x=>5)
port map(
	a=> result_parcial(4 downto 0),
	b =>add9b,
	cin => '0',
	S =>S5b,
	cout => open --
);

end architecture behavioral;
