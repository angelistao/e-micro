library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity karatsuba2_bits is
Port (

A2b : in std_logic_vector(1 downto 0);
B2b : in std_logic_vector(1 downto 0);

S4b : out std_logic_vector(3 downto 0)
);
end karatsuba2_bits;

architecture behavioral of karatsuba2_bits is

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


signal mult1 : STD_LOGIC;
signal mult2 : std_logic_vector(2 downto 0);
signal mult3 : STD_LOGIC;

signal ab : std_logic_vector(1 downto 0);
signal cd : std_logic_vector(1 downto 0);
-----------------------------------------

signal result_parcial : std_logic_vector(2 downto 0);
signal subtracao : std_logic_vector(2 downto 0);

------------------------------------------

signal add1b : std_logic_vector(2 downto 0);
signal add2b : std_logic_vector(2 downto 0);

signal add3a :std_logic_vector(3 downto 0);
signal add3b :std_logic_vector(3 downto 0);


begin


mult1 <=  (A2b(1) and B2b(1)); --A*C

mult3 <= B2b(0) and A2b(0); -- B*D

ab <= (A2b(1) and A2b(0)) & (A2b(1) xor A2b(0));
cd <= (B2b(1) and B2b(0)) & (B2b(1) xor B2b(0));

mult2 <= (ab(1) and cd(1)) &
         ((ab(1) and (not(ab(0))) and (not(cd(1))) and cd(0) ) or (ab(0) and (not(ab(1))) and (not(cd(0))) and cd(1) )) &
         (ab(0) and cd(0));

add1b <= "11" & (not(mult1));

ADD1: cla_Xbits --subtraindo mult2 - mult 1
generic map (x => 3)
port map (
    a => mult2,
    b => add1b,
    cin => '1',
    S => result_parcial,
    cout => open --
);

add2b <= "11" & (not(mult3));

ADD2: cla_Xbits --subtraindo result_parcial - mult 3
generic map (x => 3)
port map (
    a => result_parcial,
    b => add2b,
    cin => '1',
    S => subtracao,
    cout => open --
);

add3a <= subtracao & '0';
add3b <= '0' & mult1 & "00";

ADD3: cla_Xbits
generic map (x => 4)
port map(
    a => add3a,
    b => add3b,
    cin => mult3,
    S => S4b,
    cout => open --
);

end architecture behavioral;

