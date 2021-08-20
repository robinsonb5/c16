set sys_clk {guest|pll_c16|altpll_component|auto_generated|pll1|clk[0]}
set mem_clk {guest|pll_c16|altpll_component|auto_generated|pll1|clk[0]}
set sdram_clk {guest|pll_c16|altpll_component|auto_generated|pll1|clk[1]}

create_generated_clock -name sdram_clk_ext -source [get_pins $sdram_clk] [get_ports $RAM_CLK]

# Decouple asynchronous clocks

set_clock_groups -asynchronous -group [get_clocks {spiclk}] -group [get_clocks guest|pll_c16|altpll_component|auto_generated|pll1|clk[*]]
set_clock_groups -asynchronous -group [get_clocks {spiclk}] -group [get_clocks guest|pll_c1541|altpll_component|auto_generated|pll1|clk[*]]
set_clock_groups -asynchronous -group [get_clocks {guest|pll_c16|altpll_component|auto_generated|pll1|clk[*]}] -group [get_clocks {guest|pll_c1541|altpll_component|auto_generated|pll1|clk[*]}]
set_clock_groups -asynchronous -group [get_clocks ${hostclk}] -group [get_clocks {guest|pll_c16|altpll_component|auto_generated|pll1|clk[*]}]
set_clock_groups -asynchronous -group [get_clocks ${supportclk}] -group [get_clocks {guest|pll_c16|altpll_component|auto_generated|pll1|clk[*]}]
set_clock_groups -asynchronous -group [get_clocks ${supportclk}] -group [get_clocks guest|pll_c1541|altpll_component|auto_generated|pll1|clk[*]]

# Input delays

set_input_delay -clock sdram_clk_ext -max 6.4 [get_ports ${RAM_IN}]
set_input_delay -clock sdram_clk_ext -min 3 [get_ports ${RAM_IN}]

# Output delays


set_output_delay -clock sdram_clk_ext -max 1.5 [get_ports ${RAM_OUT}]
set_output_delay -clock sdram_clk_ext -min -0.8 [get_ports ${RAM_OUT}]

set_output_delay -clock [get_clocks ${sys_clk}] -max 2 [get_ports ${VGA_OUT}]
set_output_delay -clock [get_clocks ${sys_clk}] -min -2 [get_ports ${VGA_OUT}]

# false paths

set_false_path -to [get_ports ${FALSE_OUT}]
set_false_path -from [get_ports ${FALSE_IN}]


#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -from sdram_clk_ext -to [get_clocks $mem_clk] -setup 2

set_multicycle_path -to $VGA_OUT -setup 2
set_multicycle_path -to $VGA_OUT -hold 1

#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************
