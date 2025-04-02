# Create the primary clock (CLOCK_50) with a period of 10 ns (assuming a 100 MHz clock)
#create_clock -name CLOCK_50 -period 20.0 [get_ports {CLOCK_50}]

# Create the generated clock clk_div1, derived from CLOCK_50, divided by 2
#create_generated_clock -name clk_div1 -source [get_ports CLOCK_50] -divide_by 2 [get_nets {clk_div1}]

# Create the generated clock clk_div, derived from clk_div1, divided by 2
#create_generated_clock -name clk_div -source [get_nets {clk_div1}] -divide_by 2 [get_nets {clk_div}]


create_clock -name clk_div -period 80.0 [get_nets {clk_div}]
create_generated_clock -name clk_div1 -source [get_nets {clk_div}] -multiply_by 2 [get_nets {clk_div1}]
create_generated_clock -name CLOCK_50 -source [get_nets {clk_div1}] -multiply_by 2 [get_ports {CLOCK_50}]