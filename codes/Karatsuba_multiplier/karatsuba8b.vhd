library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity karatsuba8_bits is
Port (

A8b : in std_logic_vector(7 downto 0);
B8b : in std_logic_vector(7 downto 0);

S16b : out std_logic_vector(15 downto 0)
);
end karatsuba8_bits;

architecture behavioral of karatsuba8_bits is

    component cla_Xbits is
    	generic ( x : integer := 16 );
        Port (
        a : in STD_LOGIC_VECTOR(x-1 downto 0);
        b : in STD_LOGIC_VECTOR(x-1 downto 0);
        cin : in STD_LOGIC;
        S : out STD_LOGIC_VECTOR(x-1 downto 0);
        cout : out STD_LOGIC
        );
    end component;

    component karatsuba4_bits is
        Port (
            A4b : in std_logic_vector(3 downto 0);
            B4b : in std_logic_vector(3 downto 0);

            S8b : out std_logic_vector(7 downto 0)
        );
    end component;

signal aux_a_d : std_logic_vector(7 downto 0);
signal aux_b_c : std_logic_vector(7 downto 0);

signal a_d : std_logic_vector(15 downto 0);
signal b_c : std_logic_vector(15 downto 0);

signal aux_s1 : std_logic_vector(7 downto 0);
signal aux_s3 : std_logic_vector(7 downto 0);

signal soma1 : std_logic_vector(15 downto 0);
signal soma3 : std_logic_vector(15 downto 0);

signal soma2 : std_logic_vector(15 downto 0);

signal soma_final : std_logic_vector(15 downto 0);

begin

A_C1: karatsuba4_bits 
    port map (
        A4b => A8b(7 downto 4),
        B4b => B8b(7 downto 4),
        S8b => aux_s1
    );

    soma1 <= aux_s1 & "00000000";

BB_D3: karatsuba4_bits    port map (
        A4b => A8b(3 downto 0),
        B4b => B8b(3 downto 0),
        S8b => aux_s3
    );

    soma3 <= "00000000" & aux_s3;

A_D2: karatsuba4_bits
    port map (
        A4b => A8b(7 downto 4),
        B4b => B8b(3 downto 0),
        S8b => aux_a_d
    );

a_d <= "0000" & aux_a_d & "0000";


B_C2: karatsuba4_bits
    port map (
        A4b => A8b(3 downto 0),
        B4b => B8b(7 downto 4),
        S8b => aux_b_c
    );

b_c <= "0000" & aux_b_c & "0000";

ADD1: cla_Xbits
    generic map ( x => 16 )
    port map (
        a => a_d,
        b => b_c,
        cin => '0',
        S => soma2,
        cout => open
    );

ADD2: cla_Xbits
    generic map ( x => 16 )
    port map (
        a => soma2,
        b => soma1,
        cin => '0',
        S => soma_final,
        cout => open
    ); 

ADD3: cla_Xbits
    generic map ( x => 16 )
    port map (
        a => soma_final,
        b => soma3,
        cin => '0',
        S => S16b,
        cout => open
    );

end architecture behavioral;
