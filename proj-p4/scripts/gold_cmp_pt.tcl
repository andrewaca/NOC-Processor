#################################################
#
# PrimeTime Anlysis Script for Gold CMP
#
#################################################

# Setting variables for synthesis
set design_name gold_cmp ; # design_name is the name of the module
set CLK_period 2.7;  # unit = ns
set posedge 0.0 ;
set negedge [expr $CLK_period * 0.5] ;

# Reading source verilog file
read_verilog ./netlist/gold_cmp.syn.v ;

# Setting $design_name as current working design.
# Use this command before setting any constraints.
current_design gold_cmp ;

# Linking your design into the cells in standard cell libraries.
# This command checks whether your design can be compiled
# with the target libraries specified in the .synopsys_dc.setup file.
link_design ;

# Create and setup system clock
create_clock -name CLK -period $CLK_period [get_ports clk] ;
set_clock_latency 0.5 CLK 

# Set I/O timing constrains
#set_input_delay 0.05 -clock CLK [all_inputs] ; # input arrives 0.1ns after posedge of CLK
set_input_delay 1.0 -clock CLK [remove_from_collection [all_inputs] [get_ports "clk"]];
set_output_delay 1.0 -clock CLK [all_outputs] ;  # output should arrive 0.1ns before posedge of CLK

# check timing
check_timing > reports/$design_name.check_timing_pt;

# reports
report_timing  > reports/$design_name.report_timing_pt
report_clock -skew > reports/$design_name.report_clock_pt
report_port -input_delay > reports/$design_name.report_port.inp_pt
report_port -output_delay > reports/$design_name.report_port.outp_pt

# Quit DC
#remove_design -all;
#remove_lib -all;
quit  
