//---------------------------------------------------------------------------------------
//  Project - Phase 1 - Gold 4-Router Ring Connection - Testbench
// 	
//	Details: 
// 	-------- 	
//	- There are 3 categories of tests run:
//		- the first category is the required gather test bench
//			- send/receive info is ony logged in this category of tests
// 		- the second category is the gather test bench cases with the output request 
//			blocked for some cycles
//		- the third category consists of multiple sends from nodes 1, 2, 3 to node 0 with
//			output request blocked for a few cycles
//	- A proc_element module is defined to simulate the send/receive behavior of a
//		processing element attached to a router node 
//---------------------------------------------------------------------------------------

`timescale 1ns/100ps 

`define EVEN 1'b0
`define ODD  1'b1
`define CW   1'b0
`define CCW  1'b1

module tb_gold_ring;
	
	// variables
	reg clk, reset;
	wire node0_polarity, node1_polarity, node2_polarity, node3_polarity;
	wire node0_pesi, node1_pesi, node2_pesi, node3_pesi;
	wire node0_peri, node1_peri, node2_peri, node3_peri;
	wire node0_peso, node1_peso, node2_peso, node3_peso;
	wire node0_pero, node1_pero, node2_pero, node3_pero;
	wire [63:0] node0_pedi, node1_pedi, node2_pedi, node3_pedi;
	wire [63:0] node0_pedo, node1_pedo, node2_pedo, node3_pedo;
	wire [3:0] received;
		
	real start_time [3:0] , end_time [3:0];
	integer loop;
	integer test_cat;
	
	// constants
	localparam CLK_PERIOD = 4;
	reg [1:0] id0 = 2'h0;
	reg [1:0] id1 = 2'h1;
	reg [1:0] id2 = 2'h2;
	reg [1:0] id3 = 2'h3;

	// instantiate design
	gold_ring	DUT (clk, reset, node0_pesi, node0_peri, node0_pedi, node0_peso, node0_pero, node0_pedo, 
								node1_pesi, node1_peri, node1_pedi, node1_peso, node1_pero, node1_pedo, 
								node2_pesi, node2_peri, node2_pedi, node2_peso, node2_pero, node2_pedo, 
								node3_pesi, node3_peri, node3_pedi, node3_peso, node3_pero, node3_pedo, 
								node0_polarity, node1_polarity, node2_polarity, node3_polarity);
								
	proc_element PE0 (.clk(clk), .reset(reset), .polarity(node0_polarity), 
						.pesi(node0_pesi), .peri(node0_peri), .pedi(node0_pedi), 
						.peso(node0_peso), .pero(node0_pero), .pedo(node0_pedo), .id(id0), .recv_done(received[0]));
						
	proc_element PE1 (.clk(clk), .reset(reset), .polarity(node1_polarity), 
						.pesi(node1_pesi), .peri(node1_peri), .pedi(node1_pedi), 
						.peso(node1_peso), .pero(node1_pero), .pedo(node1_pedo), .id(id1), .recv_done(received[1]));
						
	proc_element PE2 (.clk(clk), .reset(reset), .polarity(node2_polarity), 
						.pesi(node2_pesi), .peri(node2_peri), .pedi(node2_pedi), 
						.peso(node2_peso), .pero(node2_pero), .pedo(node2_pedo), .id(id2), .recv_done(received[2]));
						
	proc_element PE3 (.clk(clk), .reset(reset), .polarity(node3_polarity), 
						.pesi(node3_pesi), .peri(node3_peri), .pedi(node3_pedi), 
						.peso(node3_peso), .pero(node3_pero), .pedo(node3_pedo), .id(id3), .recv_done(received[3]));
						
	// file IO
	integer fp_se;
	initial 
	begin
    	fp_se = $fopen("reports/start_end_time.out"); 
		if (fp_se == 0) 
		begin
			$display("data_file handle was NULL");
			$finish;
		end
	end
								
	// stimulus
	initial
	begin	: CLK_GENERATOR
		clk = 1'b0;
		forever #(CLK_PERIOD/2) clk = ~clk;
	end

	initial
	begin	: RESET_GENERATOR
		reset = 1'b1;
		#(2*CLK_PERIOD)	reset = ~reset;
	end				


	initial
	begin
		
		// init 
		PE0.reset_signals;
		PE1.reset_signals;
		PE2.reset_signals;
		PE3.reset_signals;
		test_cat = 0;
		
		//----------------------------------------------------------------
		// 1 - gather test bench cases 
		//----------------------------------------------------------------
		repeat (3) @(posedge clk);
		test_cat = 1;
		
		// gather - phase 0
		// node 1 - node 0 [EVEN, CCW, 1]
		// node 2 - node 0 [ODD, CW, 2]
		// node 3 - node 0 [ODD, CW, 1]
		start_time[0] = $time;
		fork
			PE0.receive;
			PE1.send(`CCW, 1, 0);
			PE2.send(`CW, 2, 0);
			PE3.send(`CW, 1, 0);
		join
		
		// gather - phase 1
		// node 0 - node 1 [EVEN, CW, 1]
		// node 2 - node 1 [ODD, CCW, 1]
		// node 3 - node 1 [ODD, CW, 2]
		wait(received[0]);
		end_time[0] = $time-1;
		start_time[1] = $time;
		fork
			PE1.receive;
			PE0.send(`CW, 1, 1);
			PE2.send(`CCW, 1, 1);
			PE3.send(`CW, 2, 1);
		join
		
		// gather - phase 2
		// node 0 - node 2 [EVEN, CW, 2]
		// node 1 - node 2 [EVEN, CW, 1]
		// node 3 - node 2 [ODD, CCW, 1]
		wait(received[1]);
		end_time[1] = $time-1;
		start_time[2] = $time;
		fork
			PE2.receive;
			PE0.send(`CW, 2, 2);
			PE1.send(`CW, 1, 2);
			PE3.send(`CCW, 1, 2);
		join
		
		// gather - phase 3
		// node 0 - node 3 [EVEN, CCW, 1]
		// node 1 - node 3 [EVEN, CW, 2]
		// node 2 - node 3 [ODD, CW, 1]		
		wait(received[2]);
		end_time[2] = $time-1;
		start_time[3] = $time;
		fork
			PE3.receive;
			PE0.send(`CCW, 1, 3);
			PE1.send(`CW, 2, 3);
			PE2.send(`CW, 1, 3);
		join
		
		wait(received[3]);
		end_time[3] = $time-1;
		
		
		for (loop = 0; loop < 4; loop = loop + 1)
		begin
			$fdisplay(fp_se, "\nPhase=%0d,\tStart Time=%g", loop, start_time[loop]);
			$fdisplay(fp_se, "Phase=%0d,\tCompletion Time=%g\n", loop, end_time[loop]);
		end 
		
		repeat(2) @(posedge clk);
			
		//----------------------------------------------------------------
		// 2 - gather test bench cases with output req blocked for few cycles
		//----------------------------------------------------------------
		// init 
		PE0.reset_signals;
		PE1.reset_signals;
		PE2.reset_signals;
		PE3.reset_signals;
		
		repeat (1) @(posedge clk);
		test_cat = 2;
		
		// gather - phase 0
		// node 1 - node 0 [EVEN, CCW, 1]
		// node 2 - node 0 [ODD, CW, 2]
		// node 3 - node 0 [ODD, CW, 1]
		start_time[0] = $time;
		fork
			PE0.receive_blocking(3);
			PE1.send(`CCW, 1, 0);
			PE2.send(`CW, 2, 0);
			PE3.send(`CW, 1, 0);
		join
		
		// gather - phase 1
		// node 0 - node 1 [EVEN, CW, 1]
		// node 2 - node 1 [ODD, CCW, 1]
		// node 3 - node 1 [ODD, CW, 2]
		wait(received[0]);
		end_time[0] = $time-1;
		start_time[1] = $time;
		fork
			PE1.receive_blocking(3);
			PE0.send(`CW, 1, 1);
			PE2.send(`CCW, 1, 1);
			PE3.send(`CW, 2, 1);
		join
		
		// gather - phase 2
		// node 0 - node 2 [EVEN, CW, 2]
		// node 1 - node 2 [EVEN, CW, 1]
		// node 3 - node 2 [ODD, CCW, 1]
		wait(received[1]);
		end_time[1] = $time-1;
		start_time[2] = $time;
		fork
			PE2.receive_blocking(3);
			PE0.send(`CW, 2, 2);
			PE1.send(`CW, 1, 2);
			PE3.send(`CCW, 1, 2);
		join
		
		// gather - phase 3
		// node 0 - node 3 [EVEN, CCW, 1]
		// node 1 - node 3 [EVEN, CW, 2]
		// node 2 - node 3 [ODD, CW, 1]		
		wait(received[2]);
		end_time[2] = $time-1;
		start_time[3] = $time;
		fork
			PE3.receive_blocking(3);
			PE0.send(`CCW, 1, 3);
			PE1.send(`CW, 2, 3);
			PE2.send(`CW, 1, 3);
		join
		
		wait(received[3]);
		end_time[3] = $time-1;
		
		for (loop = 0; loop < 4; loop = loop + 1)
		begin
			$display("\nPhase=%0d,\tStart Time=%g", loop, start_time[loop]);
			$display("Phase=%0d,\tCompletion Time=%g\n", loop, end_time[loop]);
		end 
		
		repeat(2) @(posedge clk);
		
		//----------------------------------------------------------------
		// 3 - multiple sends from nodes 1,2,3 to node 0, with blocking
		//----------------------------------------------------------------
		PE0.reset_signals;
		PE1.reset_signals;
		PE2.reset_signals;
		PE3.reset_signals;
		
		repeat (1) @(posedge clk);
		test_cat = 3;
		
		// gather - phase 0 - repeated sends from all channels
		// node 1 - node 0 [EVEN, CCW, 1]
		// node 2 - node 0 [ODD, CW, 2]
		// node 3 - node 0 [ODD, CW, 1]
		start_time[0] = $time;
		
		fork
			PE1.send(`CCW, 1, 0);
			PE2.send(`CW, 2, 0);
			PE3.send(`CW, 1, 0);
		join
		repeat (1) @(posedge clk);
		fork
			PE1.send(`CCW, 1, 0);
			PE2.send(`CW, 2, 0);
			PE3.send(`CW, 1, 0);
		join
		repeat (1) @(posedge clk);
		fork
			PE1.send(`CCW, 1, 0);
			PE2.send(`CW, 2, 0);
			PE3.send(`CW, 1, 0);
		join
		PE0.receive_blocking(9);
		repeat (1) @(posedge clk);
		wait(received[0]);
		end_time[0] = $time;
		
		//----------------------------------------------------------------
		
		repeat(2) @(posedge clk);
		$finish;
		
	end 			
endmodule

// proc_element is a dummy processing element module 
// with tasks to receieve and send packets  
module proc_element (clk, reset, polarity, pesi, peri, pedi, peso, pero, pedo, id, recv_done);
	input clk, reset, polarity;
	input [1:0] id;
	input peri, peso;
	input [63:0] pedo;
	output reg pesi, pero;
	output reg [63:0] pedi;
	
	output reg recv_done;
	
	// file IO 
	integer fp;
	initial 
	begin
		@(posedge clk)
		case (id)
			0: fp = $fopen("reports/gather_phase0.out"); 
			1: fp = $fopen("reports/gather_phase1.out"); 
			2: fp = $fopen("reports/gather_phase2.out"); 
			3: fp = $fopen("reports/gather_phase3.out"); 
			default: fp = $fopen("reports/gather_phase0.out"); 
		endcase

		if (fp == 0) 
		begin
			$display("data_file handle was NULL");
			$finish;
		end
	end
	
	initial
	begin
		recv_done = 0;
		reset_signals;
	end 
	
	//----------------------------------------------------------------
	// Tasks & functions
	//----------------------------------------------------------------
	
	// to form data packet
	function [63:0] form_packet;
		input vc;
		input dir;
		input [7:0] hopcnt;
		input [1:0] dest;
	begin
		form_packet = {vc, dir, 6'h00, hopcnt, 14'h0, id, 30'h0, dest};
	end
	endfunction
	
	
	// to send data packets
	task send;
		input dir;
		input [7:0] hopcnt;
		input [1:0] destination;
		reg polar;
	begin
		
		// determine polarity to send on
		case (id)
			0: polar = `EVEN;
			1: polar = `EVEN;
			2: polar = `ODD;
			3: polar = `ODD;
			default: polar = `EVEN;
		endcase 
		
		// set signals
		#1;
		wait((polarity == ~polar) && peri);
		@(negedge clk); #1; // Next posedge will be polar
		pesi = 1;
		pedi = form_packet(polar, dir, hopcnt, destination);
		
		// reset signals on next clock
		@(negedge clk); #1;		
		pesi =  0;
		pedi = 0;
	end 
	endtask
	
	// to recieve data packet -- non-blocking case
	// receieve information is logged into file 
	task receive;
		reg [63:0] incoming_packet;
		integer num_packets;
	begin
		// init 
		num_packets = 1;
		recv_done = 0;
		
		// set signals
		pero = 1;
		
		while (num_packets < 4)
		begin
			@(posedge clk); #1;
			// detect incoming packet
			if(peso) begin
				incoming_packet = pedo;			
				// write to log 
				$fdisplay(fp, "Phase=%d, Time=%g,\tDestination=%0d, Source=%0d, Packet=0x%h", id, $time-1, incoming_packet[31:0], incoming_packet[47:32], incoming_packet);
				num_packets = num_packets + 1;
			end
		end 
		
		recv_done = 1;
		$fclose(fp);
	end 
	endtask
	
	// to recieve data packet -- blocking case
	// output req signal is blocked for 6 clocks 
	// receieve information is NOT logged into any file
	task receive_blocking;
		reg [63:0] incoming_packet;
		input [3:0] target_num_packets;
		integer num_packets;
	begin
		// init 
		num_packets = 1;
		recv_done = 0;
		
		// set signals
		pero = 0;
		repeat(6) @(posedge clk);
		pero = 1;
		
		while (num_packets <= target_num_packets)
		begin 
			// detect incoming packet
			@(posedge clk);
			wait(peso);
			incoming_packet = pedo;
			
			num_packets = num_packets + 1;
		end 
		
		recv_done = 1;
	end 
	endtask
	
	// reset output signals
	task reset_signals;
	begin
		pesi = 0;
		pedi = 0;
		pero = 0;
	end 
	endtask 
		
endmodule