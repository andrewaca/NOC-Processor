#################################################
#
# This script synthesize sequential logic
#
#################################################

## Setting variables for synthesis
set design_name gold_router ; # design_name is the name of the module
set clk_period 4;  # unit = ns
set posedge 0.0 ;
set negedge [expr $clk_period * 0.5] ;

## Reading source verilog file
analyze -f verilog ./design/$design_name.v ;

elaborate $design_name ;

## Setting $design_name as current working design.
## Use this command before setting any constraints.
current_design design_name ;

## If you have multiple instances of the same module,
## use this so that DesignCompiler optimizea each instance separately
uniquify ;

## Linking your design into the cells in standard cell libraries.
## This command checks whether your design can be compiled
## with the target libraries specified in the .synopsys_dc.setup file.
link ;

#### Create and setup system clock
create_clock -name clk -period $clk_period -waveform [list $posedge $negedge] [get_ports clk] ;
set_dont_touch_network clk ; #module with dont_touch will not be optimized
set_ideal_network clk ;

#### Set I/O timing constrains
set_input_delay 0.05 -clock clk [all_inputs] ; # input arrives 0.1ns after posedge of clk
set_output_delay 0.1 -clock clk [all_outputs] ;  # output should arrive 0.1ns before posedge of clk

#### Set comb logic timing constrain
### set_max_delay 0.50 -from [list A B Cin] -to [list S Cout];
### set_min_delay 0.01 -from [list A B Cin] -to [list S Cout];

## Detect timing loops
report_timing -loops ;

## "check_design" checks the internal representation of the
## current design for consistency and issues error and
## warning messages as appropriate.
check_design > reports/$design_name.log; # reports/$design_name.&timestamp.check_design;

## Perforing synthesis and optimization on the current_design.
compile ;

## Output synthesis result
#write -xg_force_db -format db -hierarchy -out db/$design_name.db ;
report_timing > reports/$design_name.timing ;
report_area > reports/$design_name.area ;
report_power > reports/$design_name.power ;

change_names -rules verilog -hierarchy ;
write -format verilog -hierarchy -out netlist/$design_name.syn.v ;
write_sdf sdf/$design_name.sdf ;

## Quit DC
# quit ;
