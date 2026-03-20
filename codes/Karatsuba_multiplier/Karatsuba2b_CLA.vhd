
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

signal a_d : STD_LOGIC;
signal b_c : STD_LOGIC;

signal soma1 : std_logic_vector(3 downto 0);
signal soma2 : std_logic_vector(3 downto 0);
signal soma3 : STD_LOGIC;
begin

a_d <= A2b(1) and B2b(0);
b_c <= A2b(0) and B2b(1);

soma1 <= "0" & (A2b(1) and B2b(1)) & "00";

soma2 <= "0" & (a_d and b_c) & (a_d xor b_c) & "0";

soma3 <= B2b(0) and A2b(0);

ADD1: cla_Xbits 
generic map (x => 4)
port map (
    a => soma1,
    b => soma2,
    cin => soma3,
    S => S4b,
    cout => open --
);


end architecture behavioral;

