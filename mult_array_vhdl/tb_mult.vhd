library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_mult is
end tb_mult;

architecture Behavioral of tb_mult is
    signal A, B : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal P    : STD_LOGIC_VECTOR(31 downto 0);
begin
    uut: entity work.mult_array_16x16 port map (A => A, B => B, P => P);

    process
    begin
        A <= x"0002"; B <= x"0003"; wait for 10 ns; -- 2 * 3 = 6
        A <= x"000A"; B <= x"0005"; wait for 10 ns; -- 10 * 5 = 50
        A <= x"FFFF"; B <= x"0002"; wait for 10 ns;
        wait;
    end process;
end Behavioral;