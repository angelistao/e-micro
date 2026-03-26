library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity cla_Xbits is
    generic ( x : integer := 8 );

    Port(
        a : in STD_LOGIC_VECTOR (x-1 downto 0);
        b : in STD_LOGIC_VECTOR (x - 1 downto 0);
        cin : in STD_LOGIC;
        S : out STD_LOGIC_VECTOR(x - 1 downto 0);
        cout : out STD_LOGIC
    );
end cla_Xbits;

architecture behavioral of cla_Xbits is
    signal p,g : STD_LOGIC_VECTOR(x-1 downto 0);
    signal c : STD_LOGIC_VECTOR(x downto 0);
begin 

    p <= a xor b;
    g <= a and b;
    c(0) <= cin;


    process(p, g, cin)
        variable c_backup : STD_LOGIC;
    begin
        c_backup := cin;
        c(0)<= cin;
        
        for i in 0 to x - 1 loop
            c_backup := g(i) or (p(i) and c_backup);
            c(i+1) <= c_backup;
        end loop;
    end process;

    S<= p xor c(x-1 downto 0);
    cout<= c(x);
end architecture;

