library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity karatsuba_mult is
    Generic (N : integer := 16);
    Port (
	A : in unsigned(N-1 downto 0);
	B : in unsigned(N-1 downto 0);
	P : out unsigned((2*N)-1 downto 0)
    );
end entity karatsuba_mult;

architecture recursive of karatsuba_mult is
    constant HALF_L : integer := N / 2;
    constant HALF_H : integer := N - HALF_L;
    constant MULT2_N : integer := HALF_H + 1;
    constant N_MIN : integer := 4;

begin
    KT_basic: if N <= N_MIN generate
	signal mult1 : unsigned(((2*HALF_H)-1) downto 0); -- (ah * bh)
    	signal mult2 : unsigned(((2*(HALF_H+1))-1) downto 0); -- (ah + al) * (bh + bl)
    	signal mult3 : unsigned(((2*HALF_L)-1) downto 0); -- (al * bl)

    	signal sum_a : unsigned(MULT2_N downto 0);
    	signal sum_b : unsigned(MULT2_N downto 0);

    	signal a_h : unsigned(HALF_H-1 downto 0);
    	signal a_l : unsigned(HALF_L-1 downto 0);
    	signal b_h : unsigned(HALF_H-1 downto 0);
    	signal b_l : unsigned(HALF_L-1 downto 0);

    	signal termo_medio : unsigned(mult3'length-1 downto 0);
    begin
	a_h <= A(3 downto 2);
    	a_l <= A(1 downto 0);
    	b_h <= B(3 downto 2);
    	b_l <= B(1 downto 0);

	mult1 <= (a_h * b_h);
	mult3 <= (a_l * b_l);
	
        sum_a <= resize(a_h, 3) + resize(a_l, 3);
        sum_b <= resize(b_h, 3) + resize(b_l, 3);
	mult2 <= (sum_a * sum_b);

	termo_medio <= mult2 - resize(mult1, 6) - resize(mult3, 6);

	process(mult1, mult3, termo_medio)
        	variable v_p : unsigned(7 downto 0);
    	begin
        	v_p := (others => '0');
        	v_p(7 downto 4) := mult1;
        	v_p := v_p + v_p + resize(mult3, 8);
        	v_p := v_p + shift_left(resize(termo_medio, 8), 2);
        	P <= v_p;
    	end process;

    end generate KT_basic;

    KT_recursive: if N > N_MIN generate
	signal mult1 : unsigned(((2*HALF_H)-1) downto 0); -- (ah * bh)
	signal mult2 : unsigned(((2*(HALF_H+1))-1) downto 0); -- (ah + al) * (bh + bl)
    	signal mult3 : unsigned(((2*HALF_L)-1) downto 0); -- (al * bl)

    	signal sum_a : unsigned(MULT2_N downto 0);
    	signal sum_b : unsigned(MULT2_N downto 0);

    	signal a_h : unsigned(HALF_H-1 downto 0);
    	signal a_l : unsigned(HALF_L-1 downto 0);
    	signal b_h : unsigned(HALF_H-1 downto 0);
    	signal b_l : unsigned(HALF_L-1 downto 0);

    	signal termo_medio : unsigned(mult3'length-1 downto 0);

    begin
	a_h <= A(N-1 downto HALF_L);
	a_l <= A(HALF_L-1 downto 0);
	b_h <= B(N-1 downto HALF_L);
	b_l <= B(HALF_L-1 downto 0);

    	Mult_m1: entity work.karatsuba_mult
	    Generic map (N => HALF_H)
	    Port map (
		A => a_h,
		B => b_h,
		P => mult1
		); 

    	Mult_m3: entity work.karatsuba_mult
	    Generic map (N => HALF_L)
	    Port map (
		A => a_l,
		B => b_l,
		P => mult3
		); 

	sum_a <= resize(a_h, MULT2_N) + resize(a_l, MULT2_N);
        sum_b <= resize(b_h, MULT2_N) + resize(b_l, MULT2_N);

	Mult_m2: entity work.karatsuba_mult
	    Generic map (N => MULT2_N)
	    Port map (
		A => sum_a,
		B => sum_b,
		P => mult2
		);

	termo_medio <= mult2 - resize(mult3, mult2'length) - resize(mult1, mult2'length);
	process(mult1, mult3, termo_medio)
        	variable v_p : unsigned(7 downto 0);
    	begin
        	v_p := (others => '0');
		v_p(2*N-1 downto 2*HALF_L) := mult1;
            	v_p := v_p + resize(mult3, 2*N);
            	v_p := v_p + shift_left(resize(termo_medio, 2*N), HALF_L);
        	P <= v_p;
    	end process;
	
    end generate KT_recursive;

end architecture recursive;