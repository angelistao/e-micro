library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bloco_basico_mult_array is
    Port ( 
        a    : in  STD_LOGIC;
        b    : in  STD_LOGIC;
        cin  : in  STD_LOGIC;
        sin  : in  STD_LOGIC;
        cout : out STD_LOGIC;
        sout : out STD_LOGIC
    );
end bloco_basico_mult_array;

architecture Behavioral of bloco_basico_mult_array is
begin
    sout <= (a and b) xor sin xor cin;
    cout <= ((a and b) and sin) or (cin and ((a and b) xor sin));
end Behavioral;