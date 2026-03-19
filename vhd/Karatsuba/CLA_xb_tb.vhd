library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Necessário para fazer somas fáceis no teste

entity tb_cla_Xbits is
-- Testbench não tem portas
end tb_cla_Xbits;

architecture sim of tb_cla_Xbits is
    -- 1. Parâmetro de largura
    constant W : integer := 8;

    -- 2. Sinais para conectar ao somador
    signal t_a    : std_logic_vector(W-1 downto 0) := (others => '0');
    signal t_b    : std_logic_vector(W-1 downto 0) := (others => '0');
    signal t_cin  : std_logic := '0';
    signal t_S    : std_logic_vector(W-1 downto 0);
    signal t_cout : std_logic;

begin
    -- 3. Instanciação do seu somador (UUT - Unit Under Test)
    UUT: entity work.cla_Xbits
        generic map (x => W)
        port map (
            a    => t_a,
            b    => t_b,
            cin  => t_cin,
            S    => t_S,
            cout => t_cout
        );

    -- 4. Processo de Estímulo
    process
    begin
        -- Caso 1: 10 + 20 = 30
        t_a <= std_logic_vector(to_unsigned(10, W));
        t_b <= std_logic_vector(to_unsigned(20, W));
        t_cin <= '0';
        wait for 10 ns;
        
        -- Caso 2: 255 + 1 = 256 (Gera Carry Out e S=0 em 8 bits)
        t_a <= "11111111"; 
        t_b <= "00000001";
        t_cin <= '0';
        wait for 10 ns;

        -- Caso 3: Soma com Carry In (5 + 5 + 1 = 11)
        t_a <= std_logic_vector(to_unsigned(5, W));
        t_b <= std_logic_vector(to_unsigned(5, W));
        t_cin <= '1';
        wait for 10 ns;

        -- Caso 4: Valores aleatórios grandes
        t_a <= "10101010"; -- 170
        t_b <= "01010101"; -- 85
        t_cin <= '0';      -- Total 255
        wait for 10 ns;

        wait; -- Para a simulação
    end process;
end sim;