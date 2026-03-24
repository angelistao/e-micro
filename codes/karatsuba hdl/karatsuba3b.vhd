library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity karatsuba3b is
Port (

A3b : in std_logic_vector(2 downto 0);
B3b : in std_logic_vector(2 downto 0);

S6b : out std_logic_vector(5 downto 0)
);
end karatsuba3b;

architecture behavioral of karatsuba3b is

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

	


signal mult1 : STD_LOGIC_vector(4 downto 0); --a*c
signal mult2 : std_logic_vector(4 downto 0); -- (a+b) * (c+d)
signal mult3 : STD_LOGIC_vector(3 downto 0); --b*d

signal ab : std_logic_vector(2 downto 0); --a+b
signal cd : std_logic_vector(2 downto 0); --c+d
-----------------------------------------

signal sub_parcial : std_logic_vector (4 downto 0);
signal subtracao : std_logic_vector(4 downto 0);

------------------------------------------

signal notmult1 : std_logic_vector(4 downto 0);
signal notmult3 : std_logic_vector(4 downto 0);

--------------------------------------------

signal mult1_final : std_logic_vector(5 downto 0);
signal mult2_final : std_logic_vector(5 downto 0);
signal mult3_final : std_logic_vector(5 downto 0);
signal result_parcial : std_logic_vector(5 downto 0);


begin

mult1 <= "0000" & (B3b(2) and A3b(2));

ADD2: karatsuba2_bits -- mult3
	port map(
	A2b => A3b(1 downto 0),
	B2b => B3b (1 downto 0),
	S4b => mult3
);

ab <= (A3b(2) and A3b(1) and A3b(0)) &
      (A3b(1) xor (A3b(0) and A3b(2))) &
      (A3b(2) xor A3b(0));

cd <= (B3b(2) and B3b(1) and B3b(0)) &
      (B3b(1) xor (B3b(0) and B3b(2))) &
      (B3b(2) xor B3b(0)); 

ADD3: karatsuba3b_aux --mult 2
	port map(
	A3b => ab,
	B3b => cd,
	S5b => mult2
);

notmult1 <= not(mult1);
ADD4: cla_Xbits
	generic map (x => 5)
	port map(
	a => mult2,
	b => notmult1,
	cin => '1',
	S => sub_parcial,
	cout => open --
);

notmult3 <= '1' & not(mult3);

ADD5: cla_Xbits
	generic map (x => 5)
	port map(
	a => sub_parcial,
	b => notmult3,
	cin => '1',
	S => subtracao,
	cout => open --
);

mult1_final <= '0' & mult1(0) & "0000";
mult2_final <= subtracao(3 downto 0) & "00";
mult3_final <= "00" & mult3;


ADD6: cla_Xbits
	generic map (x => 6)
	port map(
	a => mult1_final,
	b => mult2_final,
	cin => '0',
	S => result_parcial,
	cout => open --
);

ADD7: cla_Xbits
	generic map (x => 6)
	port map(
	a => result_parcial,
	b => mult3_final,
	cin => '0',
	S => S6b,
	cout => open --
);




end architecture behavioral;
