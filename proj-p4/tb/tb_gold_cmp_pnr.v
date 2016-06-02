`timescale 1ns/10ps

// Define Clock cycle
`define CYCLE_TIME 20.0

// Include Files
`include "../netlist/gold_cmp.vo.v"
`include "/home/scf-22/ee577/NCSU45PDK/FreePDK45/osu_soc/lib/files/gscl45nm.v"

// Memory Files
`include "include/dmem.v"
`include "include/imem.v"

module tb_gold_cmp_pnr;
	reg clk, reset;
	
	wire	[0:31]	node0_inst_in;
	wire	[0:63]	node0_d_in;
	wire	[0:31]	node0_pc_out;
	wire	[0:63]	node0_d_out;
	wire	[0:31]	node0_addr_out;
	wire			node0_memWrEn;
	wire			node0_memEn;
	
	wire	[0:31]	node1_inst_in;
	wire	[0:63]	node1_d_in;
	wire	[0:31]	node1_pc_out;
	wire	[0:63]	node1_d_out;
	wire	[0:31]	node1_addr_out;
	wire			node1_memEn;
	wire			node1_memWrEn;
	
	wire	[0:31]	node2_inst_in;
	wire	[0:63]	node2_d_in;
	wire	[0:31]	node2_pc_out;
	wire	[0:63]	node2_d_out;
	wire	[0:31]	node2_addr_out;
	wire			node2_memEn;
	wire			node2_memWrEn;
	
	wire	[0:31]	node3_inst_in;
	wire	[0:63]	node3_d_in;
	wire	[0:31]	node3_pc_out;
	wire	[0:63]	node3_d_out;
	wire	[0:31]	node3_addr_out;
	wire			node3_memEn;
	wire			node3_memWrEn;
	
	integer CycleNum;            // Counter to count number of cycles for program exec.	
	
	integer i;
	integer dmem0_dump_file, dmem1_dump_file, dmem2_dump_file, dmem3_dump_file;
	integer fp_out; 
	
	// Instruction Memory Instances
	imem IM0 (
		.memAddr (node0_pc_out[22:29]),  // Memory Read Address (8-bit)
		.dataOut (node0_inst_in)	     // Memory READ Output data
	);
	imem IM1 (
		.memAddr (node1_pc_out[22:29]),  // Memory Read Address (8-bit)
		.dataOut (node1_inst_in)	     // Memory READ Output data
	);
	imem IM2 (
		.memAddr (node2_pc_out[22:29]),  // Memory Read Address (8-bit)
		.dataOut (node2_inst_in)	     // Memory READ Output data
	);
	imem IM3 (
		.memAddr (node3_pc_out[22:29]),  // Memory Read Address (8-bit)
		.dataOut (node3_inst_in)	     // Memory READ Output data
	);
	
	// Data Memory Instances
	dmem DM0 (
		.clk      (clk),					// System Clock
        .reset    (reset),					// System Reset
		.memEn    (node0_memEn),			// Memory Enable
		.memWrEn  (node0_memWrEn),			// Memory Write Enable
		.memAddr  (node0_addr_out[24:31]),	// Memory Address (8-bit)
		.dataIn   (node0_d_out),			// Memory WRITE Data  (input to data-memory)
		.dataOut  (node0_d_in)				// Memory READ Data (output from data-memory)
	);
	dmem DM1 (
		.clk      (clk),					// System Clock
        .reset    (reset),					// System Reset
		.memEn    (node1_memEn),			// Memory Enable
		.memWrEn  (node1_memWrEn),			// Memory Write Enable
		.memAddr  (node1_addr_out[24:31]),	// Memory Address (8-bit)
		.dataIn   (node1_d_out),			// Memory WRITE Data  (input to data-memory)
		.dataOut  (node1_d_in)				// Memory READ Data (output from data-memory)
	);
	dmem DM2 (
		.clk      (clk),					// System Clock
        .reset    (reset),					// System Reset
		.memEn    (node2_memEn),			// Memory Enable
		.memWrEn  (node2_memWrEn),			// Memory Write Enable
		.memAddr  (node2_addr_out[24:31]),	// Memory Address (8-bit)
		.dataIn   (node2_d_out),			// Memory WRITE Data  (input to data-memory)
		.dataOut  (node2_d_in)				// Memory READ Data (output from data-memory)
	);
	dmem DM3 (
		.clk      (clk),					// System Clock
        .reset    (reset),					// System Reset
		.memEn    (node3_memEn),			// Memory Enable
		.memWrEn  (node3_memWrEn),			// Memory Write Enable
		.memAddr  (node3_addr_out[24:31]),	// Memory Address (8-bit)
		.dataIn   (node3_d_out),			// Memory WRITE Data  (input to data-memory)
		.dataOut  (node3_d_in)				// Memory READ Data (output from data-memory)
	);

	// Gold CMP Instance
	gold_cmp UUT(clk, reset, 
		node0_inst_in, node0_d_in, node0_pc_out, node0_d_out, node0_addr_out, node0_memWrEn, node0_memEn,
		node1_inst_in, node1_d_in, node1_pc_out, node1_d_out, node1_addr_out, node1_memWrEn, node1_memEn,
		node2_inst_in, node2_d_in, node2_pc_out, node2_d_out, node2_addr_out, node2_memWrEn, node2_memEn,
		node3_inst_in, node3_d_in, node3_pc_out, node3_d_out, node3_addr_out, node3_memWrEn, node3_memEn);

	// Clock Generation
	always #(`CYCLE_TIME*0.5) clk <= ~clk;

	// Cycle Counter
	always @(posedge clk) begin
		if(reset) 
			CycleNum <= 'd0;
		else 
			CycleNum <= CycleNum + 'd1;
	end
	
	reg [0:3] node_done;
	
	always @(negedge clk) begin
		if(reset) begin
			node_done[0] <= 'd0;
			node_done[1] <= 'd0;
			node_done[2] <= 'd0;
			node_done[3] <= 'd0;
		end else begin
			if(node_done[0] == 0)
				node_done[0] <= node0_inst_in == 32'h00000000;
			if(node_done[1] == 0)
				node_done[1] <= node1_inst_in == 32'h00000000;
			if(node_done[2] == 0)
				node_done[2] <= node2_inst_in == 32'h00000000;
			if(node_done[3] == 0)
				node_done[3] <= node3_inst_in == 32'h00000000;
		end
	end
	
	// Initial
	initial begin
		$sdf_annotate("sdf/gold_cmp_pnr.sdf", UUT ,,,"TYPICAL","1.0:1.0:1.0","FROM_MTM");
		$readmemh("cmp_test.imem.0.fill", IM0.MEM);    // Loading Instruction Memory
		$readmemh("cmp_test.imem.1.fill", IM1.MEM);    // Loading Instruction Memory
		$readmemh("cmp_test.imem.2.fill", IM2.MEM);    // Loading Instruction Memory
		$readmemh("cmp_test.imem.3.fill", IM3.MEM);    // Loading Instruction Memory
		
		$readmemh("cmp_test.dmem.0.fill", DM0.MEM);    // Loading Data Memory
		$readmemh("cmp_test.dmem.1.fill", DM1.MEM);    // Loading Data Memory
		$readmemh("cmp_test.dmem.2.fill", DM2.MEM);    // Loading Data Memory
		$readmemh("cmp_test.dmem.3.fill", DM3.MEM);    // Loading Data Memory
		clk <= 0;                          // Initialize Clock
		CycleNum <= 0;                     // Initialize				
		reset <= 1'b1;                     // Reset the CPU
		repeat (5) @(negedge clk);         // Wait for CPU
		reset <= 1'b0;                     // de-activate reset signal
		
		// Convention for LAST INSTRUCTION
		// We would have a last Instruction NOP  => 32'h00000000
		wait( |node_done );
		//Let us see how many cycles your program took
		$display ("The Program Completed in %d cycles", CycleNum);
		// Let us now flush the pipeline
		repeat(10) @(negedge clk);
		// Open file to copy contents of data-memory
		dmem0_dump_file = $fopen("cmp_test.dmem.0.dump");
		dmem1_dump_file = $fopen("cmp_test.dmem.1.dump");
		dmem2_dump_file = $fopen("cmp_test.dmem.2.dump");
		dmem3_dump_file = $fopen("cmp_test.dmem.3.dump");
		// Dump all locations of data-memory to output file
		for (i=0; i<128;i=i+1) begin
			$fdisplay(dmem0_dump_file, "Memory Location #%3d: %h" , i, DM0.MEM[i]);
			$fdisplay(dmem1_dump_file, "Memory Location #%3d: %h" , i, DM1.MEM[i]);
			$fdisplay(dmem2_dump_file, "Memory Location #%3d: %h" , i, DM2.MEM[i]);
			$fdisplay(dmem3_dump_file, "Memory Location #%3d: %h" , i, DM3.MEM[i]);
		end
		$fclose(dmem0_dump_file);
		$fclose(dmem1_dump_file);
		$fclose(dmem2_dump_file);
		$fclose(dmem3_dump_file);
		$stop;
		
	end	// initial block ends here
	
	// Failsafe Exit from Simulation
	initial begin
		#(1000*`CYCLE_TIME) $finish;
	end	
	
	
	// file handling - out
	/*
	initial 
	begin
    	fp_out = $fopen("gather.log"); 
		if (fp_out == 0) 
		begin
			$display("Couldn't open output file.");
			$stop;
		end
		else
		begin
			$fmonitor(fp_out, "At time %g ns, polarity %b", $time, UUT.node0_polarity,
				"\nPROC0 incoming packet - %h, NIC0 outgoing packet - %h", UUT.node0_din_nic, UUT.node0_pedi, 
				"\nPROC1 incoming packet - %h, NIC1 outgoing packet - %h", UUT.node1_din_nic, UUT.node0_pedi, 
				"\nPROC2 incoming packet - %h, NIC2 outgoing packet - %h", UUT.node2_din_nic, UUT.node0_pedi, 
				"\nPROC3 incoming packet - %h, NIC3 outgoing packet - %h\n", UUT.node3_din_nic, UUT.node0_pedi);
		end
	end
	*/	
	
endmodule


