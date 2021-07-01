library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.numeric_std.ALL;

entity debounce is
	generic(
		default : std_logic :='1';
		bits : integer := 12
	);
	port(
		clk : in std_logic;
		d : in std_logic;
		q : out std_logic
	);
end debounce;

architecture RTL of debounce is
signal counter : unsigned(bits-1 downto 0);
signal d_d : std_logic := default;
signal d_s : std_logic := default;
signal d_s_d : std_logic := default;
begin

	process(clk)
	begin
		if rising_edge(clk) then
			d_d <= d;
			d_s <= d_d;	-- Synchronised input
			d_s_d <= d_s; -- Previous value of synchronised input

			if counter(bits-1)='1' then
				q<=d_s_d;
			else
				counter<=counter+1;
			end if;

			if d_s/=d_s_d then -- Has input settled yet?
				counter(bits-1)<='0'; -- No?  Restart the counter.
			end if;
		end if;
	end process;

end architecture;
