LIBRARY ieee;
use ieee.std_logic_1164.all;

entity SS4Bit is
	port(
		input 	: in 	std_logic_vector(3 downto 0); --3 = MSB
		HexOut 	: out std_logic_vector(6 downto 0) --sa = HexOut(0)
	);
end SS4Bit;

-- U ovom kodu su svi izrazi negirani jer na DE0-CV ploci 7seg display je active ground
architecture SS4Bit_rtl of SS4Bit is

	alias A : std_logic is input(3); --A = MSB
	alias B : std_logic is input(2);
	alias C : std_logic is input(1);
	alias D : std_logic is input(0);
	
	alias sa : std_logic is HexOut(0);
	alias sb : std_logic is HexOut(1);
	alias sc : std_logic is HexOut(2);
	alias sd : std_logic is HexOut(3);
	alias se : std_logic is HexOut(4);
	alias sf : std_logic is HexOut(5);
	alias sg : std_logic is HexOut(6);
	
	
	begin
		sa <= not ((not A and B and D) or (A and not B and not C) or (not B and not D) or (not A and C) or (A and not D) or (B and C));
		sb <= (B and not D) xor (not A and B and not C) xor (A and C and D);
		sc <= not ((not B and not C) or (not B and D) or (not C and D) or (not A and B) or (A and not B));
		sd <= not ((not B and not C and not D) or (not B and C and D) or (not A and C and not D) or (B and not C and D) or (A and not C) or (A and B and not D));
		se <= not ((not B and not D) or (C and not D) or (A and B) or (A and C));
		sf <= not ((not A and B and not C) or (not C and not D) or (B and not D) or (A and C) or (A and not B));
		sg <= not ((not A and B and not D) or (B and not C and D) or (not B and C) or (A and C) or (A and not B));
end SS4Bit_rtl;