`timescale 1ns/10ps

module tb_gold_nic ();
	
	// signals
	reg 		clk, reset;
	reg 		nicEn, nicEnWr;
	reg [0:1] 	addr;
	reg [0:63] 	d_in, net_di;
	reg			net_si, net_polarity, net_ro;
	
	wire [0:63] d_out, net_do;
	wire		net_ri, net_so;
	
	reg [31:0] payload_data = 0;
	integer testnum = 0;
	
	// constants
	localparam CLK_PERIOD = 4;
	
	// instantiate NIC
	Gold_nic uut(clk, reset, addr, d_in, d_out, nicEn, nicEnWr, net_si, net_ri, net_di, net_so, net_ro, net_do, net_polarity);

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
	
	always @(posedge clk, posedge reset)
	begin 	: POLARITY_GEN
		if(reset) begin
			net_polarity <= 0;
		end else begin
			//#1;
			net_polarity <= ~net_polarity;
		end
	end 
	
	initial
	begin
		// reset all signals
		addr = 0;
		d_in = 0;
		net_di = 0;
		
		nicEn = 0;
		nicEnWr = 0;
		net_si = 0;
		net_ro = 1;
		
		repeat(3) @(negedge clk);
		
		//----------------------------------------------------------------
		// test flow - 1
		// receive data from processor
		// send data to router
		//----------------------------------------------------------------
		testnum = 1;
		
		// read output channel status register
		nicEn = 1;
		addr = 2'h1;	
		
		// write to output channel buffer
		@(negedge clk);
		nicEn = 0;
		@(negedge clk);
		nicEn = 1;
		nicEnWr = 1;
		addr = 2'h0;
		d_in = form_packet(0, 0, 1);
		@(negedge clk);
		reset_proc_signals;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h1; // read output channel status register
		
		@(negedge clk);
		reset_proc_signals;
		
		repeat(3) @(negedge clk);
		
		//----------------------------------------------------------------
		
		
		//----------------------------------------------------------------
		// test flow - 2
		// receive data from processor
		// send data to router
		// blocking router
		//----------------------------------------------------------------
		testnum = 2;
		
		// read output channel status register
		nicEn = 1;
		addr = 2'h1;	
		
		// write to output channel buffer
		@(negedge clk);
		nicEn = 0;
		net_ro = 0;
		@(negedge clk);
		nicEn = 1;
		nicEnWr = 1;
		addr = 2'h0;
		d_in = form_packet(1, 0, 1);
		@(negedge clk);
		reset_proc_signals;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h1; // read output channel status register
		
		@(negedge clk);
		reset_proc_signals;
		
		repeat(3) @(negedge clk);	// router busy for 3 clocks
		net_ro = 1;
		
		repeat(3) @(negedge clk);
		//----------------------------------------------------------------
		
		//----------------------------------------------------------------
		// test flow - 3
		// receive data from processor
		// send data to router
		// blocking router - processor tries to send multiple packets
		//----------------------------------------------------------------
		testnum = 3;
		
		// read output channel status register
		nicEn = 1;
		addr = 2'h1;	
		
		// write to output channel buffer - packet 1
		@(negedge clk);
		nicEn = 0;
		net_ro = 0;
		@(negedge clk);
		nicEn = 1;
		nicEnWr = 1;
		addr = 2'h0;
		d_in = form_packet(1, 0, 1);
		@(negedge clk);
		reset_proc_signals;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h1; // read output channel status register
		
		// write to output channel buffer - packet 2
		@(negedge clk);
		nicEn = 0;
		@(negedge clk);
		nicEn = 1;
		nicEnWr = 1;
		addr = 2'h0;
		d_in = form_packet(0, 0, 1);
		@(negedge clk);
		reset_proc_signals;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h1; // read output channel status register
		
		// write to output channel buffer - packet 3
		@(negedge clk);
		nicEn = 0;
		@(negedge clk);
		nicEn = 1;
		nicEnWr = 1;
		addr = 2'h0;
		d_in = form_packet(1, 0, 1);
		@(negedge clk);
		reset_proc_signals;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h1; // read output channel status register
		
		@(negedge clk);
		nicEn = 0;
		
		// router ready to receive now
		repeat(2) @(negedge clk);
		net_ro = 1;
		reset_proc_signals;
		
		repeat(3) @(negedge clk);
		//----------------------------------------------------------------

		
		//----------------------------------------------------------------
		// test flow - 4
		// receive data from router (odd polarity)
		// send data to processor
		//----------------------------------------------------------------
		testnum = 4;
		
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		wait(~clk && net_ri == 1 && net_polarity == 0);
		net_si = 1;
		net_di = form_packet(1, 0, 0);
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		reset_router_signals;
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h2;	// read input buffer register
		
		@(negedge clk);
		addr = 2'h3;	// read input buffer status register
		
		@(negedge clk);
		reset_proc_signals;
		
		repeat(3) @(negedge clk);
		//----------------------------------------------------------------
		
		//----------------------------------------------------------------
		// test flow - 5
		// receive data from router (even polarity)
		// send data to processor
		//----------------------------------------------------------------
		testnum = 5;
		
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		wait(~clk && net_ri == 1 && net_polarity == 1);
		net_si = 1;
		net_di = form_packet(0, 0, 0);
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		#1;
		reset_router_signals;
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h2;	// read input buffer register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		
		@(negedge clk);
		reset_proc_signals;
		
		repeat(3) @(negedge clk);
		//----------------------------------------------------------------
		
		//----------------------------------------------------------------
		// test flow - 6
		// receive data from router (even polarity)
		// send data to processor
		// processor blocking 
		//----------------------------------------------------------------
		testnum = 6;
		
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		wait(~clk && net_ri == 1 && net_polarity == 1);
		net_si = 1;
		net_di = form_packet(0, 0, 0);
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		#1;
		reset_router_signals;
		
		@(negedge clk);
		nicEn = 0;
		
		repeat(3) @(negedge clk); // processor busy for three cycles
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h2;	// read input buffer register
		
		@(negedge clk);
		reset_proc_signals;
		
		repeat(3) @(negedge clk);
		//----------------------------------------------------------------
		
		//----------------------------------------------------------------
		// test flow - 7
		// receive data from router (even polarity)
		// send data to processor
		// processor blocking - router tries to send multiple packets
		//----------------------------------------------------------------
		testnum = 7;
		
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		//#1;
		wait(~clk && net_ri == 1 && net_polarity == 1);
		net_si = 1;
		net_di = form_packet(0, 0, 0);	// send packet 1 
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		#1;
		reset_router_signals;
		
		@(negedge clk);
		reset_proc_signals;
		//#1;
		wait(~clk && net_polarity == 0);
		net_si = 1;
		net_di = form_packet(1, 0, 0);	// send packet 2 - assuming that router doesn't wait for ri
		
		@(negedge clk);
		#1;
		reset_router_signals;
		wait(~clk && net_polarity == 1);
		net_si = 1;
		net_di = form_packet(0, 0, 0);	// send packet 3 - assuming that router doesn't wait for ri
		
		@(negedge clk);
		#1;
		reset_router_signals;
		
		repeat(3) @(negedge clk);	// processor busy for three cycles
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h2;	// read input buffer register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		
		@(negedge clk);
		addr = 2'h2;	// read input buffer register
		
		@(negedge clk);
		reset_proc_signals;
		
		repeat(3) @(negedge clk);
		//----------------------------------------------------------------
		
		//----------------------------------------------------------------
		// test flow - 8
		// two-way communication
		// router to processor
		// processor to router
		//----------------------------------------------------------------
		testnum = 8;
		
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		
		@(negedge clk);
		addr = 2'h1;	// read output channel status register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		nicEn = 1;
		nicEnWr = 1;	// write to output buffer register
		addr = 2'h0;
		d_in = form_packet(0, 0, 1);	
		//#1;
		wait(~clk && net_ri == 1 && net_polarity == 1);
		net_si = 1;
		net_di = form_packet(0, 0, 0);
		
		@(negedge clk);
		reset_proc_signals;
		#1;
		reset_router_signals;
	
		@(negedge clk);
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register

		@(negedge clk);
		addr = 2'h1; 	// read output channel status register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h2;	// read input buffer register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		
		@(negedge clk);
		reset_proc_signals;
		
		repeat(3) @(negedge clk);
		//----------------------------------------------------------------

		
		//----------------------------------------------------------------
		// test flow - 9
		// two-way communication (blocking)
		// router to processor (multiple packets)
		// processor to router (blocking)
		//----------------------------------------------------------------
		testnum = 9;
		
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		
		@(negedge clk);
		addr = 2'h1;	// read output channel status register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		net_ro = 0;
		
		nicEn = 1;
		nicEnWr = 1;	// write to output buffer register
		addr = 2'h0;
		d_in = form_packet(0, 0, 1);	

		net_si = 1;
		net_di = form_packet(0, 0, 0);
		
		@(negedge clk);
		d_in = form_packet(0, 0, 1);
		net_di = form_packet(0, 0, 0);
		
		@(negedge clk);
		net_ro = 1;		
		
		reset_proc_signals;
		#1;
		reset_router_signals;
	
		@(negedge clk);
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register

		@(negedge clk);
		addr = 2'h1; 	// read output channel status register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h2;	// read input buffer register
		
		@(negedge clk);
		nicEn = 0;
		
		@(negedge clk);
		nicEn = 1;
		addr = 2'h3;	// read input buffer status register
		
		@(negedge clk);
		reset_proc_signals;
		
		repeat(3) @(negedge clk);
		//----------------------------------------------------------------
		
		$finish;
	end 
	
	
	//----------------------------------------------------------------
	// Tasks & functions
	//----------------------------------------------------------------
	
	// to form data packet
	function [63:0] form_packet;
		input vc;
		input dir;
		input [7:0] hopcnt;
		reg [31:0] data;
	begin
		payload_data = payload_data + 1;
		data = payload_data;
		form_packet = {vc, dir, 6'h00, hopcnt, 16'h00, data};
	end
	endfunction
	
	// to reset processor-related input signals
	task reset_proc_signals;
	begin	
		addr = 0;
		d_in = 0;
		nicEn = 0;
		nicEnWr = 0;
	end
	endtask 
	
	// to reset router-related input signals
	task reset_router_signals;
	begin	
		net_di = 0;
		net_si = 0;
		net_ro = 1;
	end
	endtask 
	
	//----------------------------------------------------------------
	
endmodule