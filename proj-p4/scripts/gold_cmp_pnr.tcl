## Setting variables for synthesis
set design_name gold_cmp; # design_name is the name of the module
set verilog_files [list ./design/alu.v ./design/cpu.v ./design/gold_router.v ./design/gold_ring.v ./design/gold_nic.v ./design/gold_cmp.v]
set clkname clk

## Reading source verilog file
analyze -f verilog $verilog_files;
elaborate $design_name;

## Setting $design_name as current working design.
## Use this command before setting any constraints.
current_design $design_name ;

## Linking your design into the cells in standard cell libraries.
## This command checks whether your design can be compiled
## with the target libraries specified in the .synopsys_dc.setup file.
link ;

## If you have multiple instances of the same module,
## use this so that DesignCompiler optimizea each instance separately
## uniquify ;

## Detect timing loops
report_timing -loops ;

## "check_design" checks the internal representation of the
## current design for consistency and issues error and
## warning messages as appropriate.
check_design > reports/${design_name}_sdc.log; # reports/$design_name.&timestamp.check_design;


set i 14.00
set clk_period $i;  # unit = ns

#### Create and setup system clock
create_clock -name $clkname -period $clk_period -waveform "0 [expr $clk_period / 2]" $clkname
set_dont_touch_network clk ; #module with dont_touch will not be optimized
set_ideal_network clk ;
set_clock_latency 0.5 [get_clocks clk]

#### Set I/O timing constrains
set_input_delay 1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]] ;
set_output_delay 1.0 -clock clk [all_outputs] ;

report_timing > reports/${design_name}_sdc.timing ;

write_sdc sdc/${design_name}.sdc;

## Quit DC
#quit ;
