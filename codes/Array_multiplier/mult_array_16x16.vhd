library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; -- Necessário para as operações de unsigned e soma

entity multiplier is
    generic (
        N : integer := 16
    );
    Port ( 
        A : in  STD_LOGIC_VECTOR (N-1 downto 0);
        B : in  STD_LOGIC_VECTOR (N-1 downto 0);
        P : out STD_LOGIC_VECTOR (2*N-1 downto 0)
    );
end multiplier;

architecture structural of multiplier is
    -- barramentos p/ para conectar as linhas
    type matriz is array (0 to N-1) of std_logic_vector(N-1 downto 0);
    signal soma_parcial   : matriz := (others => (others => '0'));
    signal carry_net : matriz := (others => (others => '0'));
begin

    -- matriz de blocos básicos
    rows: for j in 0 to N-1 generate
        cols: for i in 0 to N-1 generate
            
            -- primeira linha (j=0): a entrada de soma (sin) é sempre '0'
            first_row: if j = 0 generate
                cell: entity work.bloco_basico_mult_array
                    port map (
                        a    => A(i),
                        b    => B(j),
                        cin  => '0',
                        sin  => '0',
                        cout => carry_net(j)(i),
                        sout => soma_parcial(j)(i)
                    );
            end generate;

            -- linhas seguintes (j > 0)
            other_rows: if j > 0 generate
                
                -- colunas intermediárias e iniciais
                inner_cols: if i < N-1 generate
                    cell: entity work.bloco_basico_mult_array
                        port map (
                            a    => A(i),
                            b    => B(j),
                            cin  => carry_net(j-1)(i),   -- carry vem da célula acima
                            sin  => soma_parcial(j-1)(i+1),   -- soma vem da diagonal superior direita
                            cout => carry_net(j)(i),
                            sout => soma_parcial(j)(i)
                        );
                end generate;

                -- Última coluna de cada linha (não tem vizinho à direita para dar sin)
                last_col: if i = N-1 generate
                    cell: entity work.bloco_basico_mult_array
                        port map (
                            a    => A(i),
                            b    => B(j),
                            cin  => carry_net(j-1)(i),
                            sin  => '0', 
                            cout => carry_net(j)(i),
                            sout => soma_parcial(j)(i)
                        );
                end generate;
            end generate;
        end generate;
    end generate;

    -- COLETA DOS RESULTADOS
    -- Os bits menos significativos saem pela primeira coluna de cada estágio
    lsb: for j in 0 to N-1 generate
        P(j) <= soma_parcial(j)(0);
    end generate;

    -- SOMADOR FINAL (Vector Merge) para os bits N a 2*N-1
    process(soma_parcial, carry_net)
        variable vetor_a, vetor_b : unsigned(N-1 downto 0);
        variable resultado_final    : unsigned(N-1 downto 0);
    begin
        -- Prepara os vetores para a soma final na base da grade
        for k in 0 to N-2 loop
            vetor_a(k) := soma_parcial(N-1)(k+1);
            vetor_b(k) := carry_net(N-1)(k);
        end loop;
        vetor_a(N-1) := carry_net(N-1)(N-1); -- último carry
        vetor_b(N-1) := '0';
        
        resultado_final := vetor_a + vetor_b;
        P(2*N-1 downto N) <= std_logic_vector(resultado_final);
    end process;

end architecture;