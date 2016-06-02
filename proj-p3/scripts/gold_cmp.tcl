#################################################
#
# This script synthesize sequential logic
#
#################################################

## Setting variables for synthesis
set design_name gold_cmp; # design_name is the name of the module
set verilog_files [list ./design/alu.v ./design/cpu.v ./design/gold_router.v ./design/gold_ring.v ./design/gold_nic.v ./design/gold_cmp.v]

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
uniquify ;

## Detect timing loops
report_timing -loops ;

## "check_design" checks the internal representation of the
## current design for consistency and issues error and
## warning messages as appropriate.
check_design > reports/$design_name.log; # reports/$design_name.&timestamp.check_design;

for {set i 3.7} {$i <= 6} {set i [expr {$i+0.1}]} {
	set clk_period $i;  # unit = ns
	
	#### Create and setup system clock
	create_clock -name clk -period $clk_period [get_ports clk] ;
	set_dont_touch_network clk ; #module with dont_touch will not be optimized
	set_ideal_network clk ;
	set_clock_latency -source 0.5 [get_clocks clk]

	#### Set I/O timing constrains
	set_input_delay 1.0 -clock clk [remove_from_collection [all_inputs] [get_ports clk]] ;
	set_output_delay 1.0 -clock clk [all_outputs] ;
	
	# set_max_area 680000
	# compile -ungroup_all -map_effort high -area_effort high
	compile -map_effort high -area_effort high
	
	report_timing > reports/{$design_name}_syn.{$i}.timing ;
	report_area > reports/{$design_name}_syn.{$i}.area ;
	report_cell > reports/{$design_name}_syn.{$i}.cell ;
	report_power > reports/{$design_name}_syn.{$i}.power ;
}

## Output synthesis result
#write -xg_force_db -format db -hierarchy -out db/$design_name.db ;

change_names -rules verilog -hierarchy ;
write -format verilog -hierarchy -out netlist/$design_name.syn.v ;
write_sdf sdf/dc_$design_name.sdf;
write_sdc sdc/$design_name.sdc;

## Quit DC
# quit ;
