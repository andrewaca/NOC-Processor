`timescale 1ns/1ps

`include "../netlist/alu.syn.v"
`include "/home/scf-22/ee577/NCSU45PDK/FreePDK45/osu_soc/lib/files/gscl45nm.v"

module alu_tb;
	reg [0:63] oprA, oprB;
	reg [0:4] shift_amount;
	reg [0:5] op;
	reg [0:1] ww;
	wire [0:63] result;
	//alu DUT(oprA, oprB, shift_amount, op, ww, result);
	alu_syn DUT(oprA, oprB, shift_amount, op, ww, result);
	
	localparam CLK_PERIOD = 5;
	
	reg clk, reset;
	initial
	begin : CLK_GENERATOR
		clk = 0;
		forever
		begin
		  #(CLK_PERIOD*0.5) clk = ~clk;
		end 
	end
	
	initial
	begin : RESET_GENERATOR
		reset = 1;
		#(2.0 * CLK_PERIOD) reset = 0;
	end
	
	integer i;
	reg[0:5] oprB_select;
	
	initial begin
		$sdf_annotate("sdf/alu.sdf", DUT,,,"TYPICAL","1.0:1.0:1.0","FROM_MTM");
		wait (!reset);
		
		oprA[0:31] <= 'h8080_8080;
		oprA[32:63] <= 'h8080_8080;
		oprB[0:31] <= 'h0101_0101;
		oprB[32:63] <= 'h0101_0101;
		shift_amount <= 4;
		
		for(i=0; i <= 18; i = i+1) begin
			@(posedge clk);
			op <= i;
			ww <= 3;
			oprB_select <= oprB[58:63];
			@(posedge clk);
			ww <= 2;
			oprB_select <= oprB[59:63];
		end
		
		#(2*CLK_PERIOD);
		$finish;
	end
endmodule
