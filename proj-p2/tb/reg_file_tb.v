`timescale 1ns/1ps

module reg_file_tb;
	reg clk, reset, write_en;
	reg [0:4] read1_addr, read2_addr, write_addr;
	reg [0:63] Din;
	wire [0:63] Dout1, Dout2;
	reg [0:2] PPP;
	reg [0:1] WW;
	
	wire [0:63] Dout2_test;
	register_file reg_file(.clk(clk), .reset(reset), .write_en(write_en), .read1_addr(read1_addr),
	.read2_addr(read2_addr), .write_addr(write_addr), .Din(Din),
	.Dout1(Dout1), .Dout2(Dout2), .PPP(PPP), .WW(WW));
	
	localparam CLK_PERIOD = 4;
	
	initial
	begin : CLK_GENERATOR
		clk = 0;
		forever
		begin
		  #(CLK_PERIOD/2) clk = ~clk;
		end 
	end
	
	initial
	begin : RESET_GENERATOR
		reset = 1;
		#(2.0 * CLK_PERIOD) reset = 0;
	end
	
	integer i, j;
	
	initial begin
		read1_addr <= 0; read2_addr <= 0; write_addr <= 0; Din <= 0; PPP <= 0; WW <= 2'b11; write_en <= 0;
		
		wait (!reset);
		
		// Write sequence
		for(i=0; i < 32; i = i+1) begin
			@(negedge clk);
			write_en <= 1;
			write_addr <= i;
			if(i>0) begin
				read1_addr <= i-1;
				read2_addr <= i; // Test internal forwarding
			end
			Din <= (Din + 1) | 64'h8000000000000000;
		end
		@(negedge clk);
		
		write_en <= 0;
		
		// Read sequence
		for(i=0; i < 32; i = i+1) begin
			@(posedge clk);
			read1_addr <= i;
			read2_addr <= i;
		end
		
		// Write test PPP and WW
		@(posedge clk);
		read1_addr <= 0; read2_addr <= 0; write_addr <= 0;
		@(posedge clk);
		for(i=0; i <= 5; i = i+1) begin
			for(j=0; j <= 3; j = j+1) begin
				@(negedge clk);
				// Write all zeros and then use PPP and WW to selectively write ones
				write_addr <= write_addr + 1;
				read1_addr <= write_addr + 1; // Test internal forwarding
				PPP <= 0; WW <= 2'b11; Din <= 0; write_en <= 1;
				@(negedge clk);
				PPP <= i; WW <= j;
				Din <= 64'hFFFF_FFFF_FFFF_FFFF;	
			end
		end
		
		@(negedge clk);
		write_en <= 0;
		
		// Read test PPP and WW
		@(posedge clk);
		read1_addr <= 0;
		for(i=0; i <= 5; i = i+1) begin
			for(j=0; j <= 3; j = j+1) begin
				@(posedge clk);
				read1_addr <= read1_addr + 1;
				PPP <= i; WW <= j;
			end
		end
		
		#(2*CLK_PERIOD);
		$finish;
	end
endmodule
