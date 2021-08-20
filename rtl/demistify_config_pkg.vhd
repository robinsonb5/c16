-- DeMiSTifyConfig_pkg.vhd
-- Copyright 2021 by Alastair M. Robinson

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package demistify_config_pkg is
constant demistify_romspace : integer := 14; -- 32k address space to accommodate 8k + 8K of ROM
constant demistify_romsize1 : integer := 13; -- 16k for the first chunk
constant demistify_romsize2 : integer := 12; -- 8k for the second chunk

-- Core-specific button mapping.
-- Joysticks are (currently) 8 bits width, with the directions in the lower four bits.
-- Button 1 is the main fire button, Button 2 is the secondary fire button to the right of button 1
-- Button 3 is a third (possibly less conveniently placed) button 
-- Button 4 is mapped as a "start" or "run" button.

-- By adjusting the following constants you can assign each button a place in the joystick bitmap.
-- The Megadrive core, for instance, expects the following bitmap:
-- start(7) C(6) B(5) A(4) directions(3:0)
-- Since Megadrive button B is the most important, we map button 1 -> B, button 2 -> C, button 3 -> A
-- and button 4 -> Start, hence button1 = 5, button2 = 6, button3 = 4 and button4 = 7,

constant demistify_button1 : integer := 4;
constant demistify_button2 : integer := 5;
constant demistify_button3 : integer := 6;
constant demistify_button4 : integer := 7;

constant demistify_serialdebug : std_logic := '0';

-- Declare guest component

	COMPONENT c16_guest
		PORT
		(
			CLOCK_27 :	IN STD_LOGIC;
	--		RESET_N :   IN std_logic;
			SDRAM_DQ		:	 INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			SDRAM_A		:	 OUT STD_LOGIC_VECTOR(12 DOWNTO 0);
			SDRAM_DQML		:	 OUT STD_LOGIC;
			SDRAM_DQMH		:	 OUT STD_LOGIC;
			SDRAM_nWE		:	 OUT STD_LOGIC;
			SDRAM_nCAS		:	 OUT STD_LOGIC;
			SDRAM_nRAS		:	 OUT STD_LOGIC;
			SDRAM_nCS		:	 OUT STD_LOGIC;
			SDRAM_BA		:	 OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
			SDRAM_CLK		:	 OUT STD_LOGIC;
			SDRAM_CKE		:	 OUT STD_LOGIC;
			SPI_DO		:	 OUT STD_LOGIC;
--			SPI_SD_DI	:	 IN STD_LOGIC;
			SPI_DI		:	 IN STD_LOGIC;
			SPI_SCK		:	 IN STD_LOGIC;
			SPI_SS2		:	 IN STD_LOGIC;
			SPI_SS3		:	 IN STD_LOGIC;
			SPI_SS4		:	 IN STD_LOGIC;
			CONF_DATA0		:	 IN STD_LOGIC;
			VGA_HS		:	 OUT STD_LOGIC;
			VGA_VS		:	 OUT STD_LOGIC;
			VGA_R		:	 OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
			VGA_G		:	 OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
			VGA_B		:	 OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
			AUDIO_L  : out std_logic;
			AUDIO_R  : out std_logic;
			PS2DAT : in std_logic;
			PS2CLK : in std_logic;
			c64_keys : in unsigned(64 downto 0);
			tape_button_n : in std_logic;
			iec_atn_i : in std_logic := '1';
			iec_data_i : in std_logic := '1';
			iec_clk_i : in std_logic := '1';
			iec_atn_o : out std_logic;
			iec_data_o : out std_logic;
			iec_clk_o : out std_logic
		);
	END COMPONENT;
	
end package;