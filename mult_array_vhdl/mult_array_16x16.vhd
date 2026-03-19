library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- setup das portas
entity mult_array_16x16 is
    Port ( 
        A : in  STD_LOGIC_VECTOR (15 downto 0);
        B : in  STD_LOGIC_VECTOR (15 downto 0);
        P : out STD_LOGIC_VECTOR (31 downto 0)
    );
end mult_array_16x16;

architecture Structural of mult_array_16x16 is
    -- Matrizes 17x17 para cobrir todas as propagações i+1 e j+1
    type matrix is array (0 to 16, 0 to 16) of STD_LOGIC;
    signal s : matrix := (others => (others => '0')); 
    signal c : matrix := (others => (others => '0')); 
begin

    setup: for k in 0 to 16 generate
        s(0, k)  <= '0'; -- Topo: sem soma vindo de cima
        c(0, k)  <= '0'; -- Esquerda: sem carry vindo da esquerda
        s(k, 16) <= '0'; -- Direita: evita que a última coluna leia 'U'
    end generate;

    -- 2. GERAÇÃO DA GRADE (Lógica de Braun: Soma desce, Carry vai para a esquerda)
    rows: for j in 0 to 15 generate
        cols: for i in 0 to 15 generate
            cell_inst: entity work.bloco_basico_mult_array
                port map (
                    a    => A(i),
                    b    => B(j),
                    cin  => c(i, j),      -- Carry vem da coluna anterior
                    sin  => s(j, i+1),    -- Soma vem da linha de cima, deslocada
                    cout => c(i+1, j),    -- Carry vai para a próxima coluna
                    sout => s(j+1, i)     -- Soma desce para a próxima linha
                );
        end generate;
    end generate;

    -- 3. COLETA DOS BITS (P(0) = A(0)*B(0), P(1) = ..., etc)
    -- Os bits 0 a 15 saem pela "coluna 0" conforme a soma desce as linhas
    output_low: for k in 0 to 15 generate
        P(k) <= s(k+1, 0); 
    end generate;

    -- Os bits 16 a 30 saem da base da última linha (j=16)
    output_high: for k in 1 to 15 generate
        P(k+15) <= s(16, k);
    end generate;
    
    -- O bit 31 é o carry final do último estágio
    P(31) <= c(16, 15);

end Structural;