--Lógica karatsuba 4 bits

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity karatsuba4_bits is
Port (

A4b : in std_logic_vector(3 downto 0);
B4b : in std_logic_vector(3 downto 0);

S8b : out std_logic_vector(7 downto 0)
);
end karatsuba4_bits;

architecture behavioral of karatsuba4_bits is

    component cla_Xbits is
    	generic ( x : integer := 8 );
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
            A2b : in std_logic_vector(1 downto 0);
            B2b : in std_logic_vector(1 downto 0);

            S : out std_logic_vector(3 downto 0)
        );
    end component;
        
signal aux_a_d : std_logic_vector(3 downto 0);
signal aux_b_c : std_logic_vector(3 downto 0);

signal a_d : std_logic_vector(7 downto 0);
signal b_c : std_logic_vector(7 downto 0);

signal aux_s1 : std_logic_vector(3 downto 0);
signal aux_s3 : std_logic_vector(3 downto 0);

signal soma1 : std_logic_vector(7 downto 0);
signal soma3 : std_logic_vector(7 downto 0);

signal soma2 : std_logic_vector(7 downto 0);

signal soma_final : std_logic_vector(7 downto 0);
begin

A_C1: karatsuba2_bits 
    port map (
        A2b => A4b(3 downto 2),
        B2b => B4b(3 downto 2),
        S4b => aux_s1
    );

    soma1 <= aux_s1 & "0000";

B_D3: karatsuba2_bits
    port map (
        A2b => A4b(1 downto 0),
        B2b => B4b(1 downto 0),
        S4b => aux_s3
    );

    soma3 <= "0000" & aux_s3;

A_D2: karatsuba2_bits
    port map (
        A2b => A4b(3 downto 2),
        B2b => B4b(1 downto 0),
        S4b => aux_a_d
    );

a_d <= "00" & aux_a_d & "00";


B_C2: karatsuba2_bits
    port map (
        A2b => A4b(1 downto 0),
        B2b => B4b(3 downto 2),
        S4b => aux_b_c
    );

b_c <= "00" & aux_b_c & "00";

ADD1: cla_Xbits
    generic map ( x => 8 )
    port map (
        a => a_d,
        b => b_c,
        cin => '0',
        S => soma2,
        cout => open
    );

ADD2: cla_Xbits
    generic map ( x => 8 )
    port map (
        a => soma2,
        b => soma1,
        cin => '0',
        S => soma_final,
        cout => open
    ); 

ADD3: cla_Xbits
    generic map ( x => 8 )
    port map (
        a => soma_final,
        b => soma3,
        cin => '0',
        S => S8b,
        cout => open
    );

end architecture behavioral;
