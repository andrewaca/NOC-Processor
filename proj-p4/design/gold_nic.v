module Gold_nic(clk, reset, addr, d_in, d_out, nicEn, nicEnWr, net_si, net_ri, net_di, net_so, net_ro, net_do, net_polarity);

	input [0:1] addr;
	input [0:63] d_in;
	output reg [0:63] d_out;
	input nicEn;
	input nicEnWr;
	input net_si;
	output reg net_ri;
	input [0:63] net_di;
	output reg net_so;
	input net_ro;
	output reg [0:63] net_do;
	input net_polarity;
	input clk;
	input reset;
	
	reg [0:1] r_addr;
	reg r_nicEn, r_nicEnWr;
	reg [0:63] input_buffer;
	
	// Status reg is high when buffer is full
	reg output_status_reg, input_status_reg;
	
	reg input_buffer_RdEn, input_buffer_WrEn;
	reg output_buffer_RdEn, output_buffer_WrEn;
	
	reg packet_polarity;
	localparam addr_output_buffer = 2'b00;
	localparam addr_input_buffer = 2'b10;
	
	always @(posedge clk) begin
		if(reset) begin
			net_do <= 0;
			input_buffer <= 0;
			output_status_reg <= 0;
			input_status_reg <= 0;
			
			r_addr <= 0;
			r_nicEn <= 0;
			r_nicEnWr <= 0;
		end else begin
			r_addr <= addr;
			r_nicEn <= nicEn;
			r_nicEnWr <= nicEnWr;
		
			/// Output Channel Logic: ///
			// Reading and writing to output buffer simultaneously -> output_status_reg can stay 0
			if( output_buffer_RdEn && output_buffer_WrEn ) begin
				net_do <= d_in;
				output_status_reg <= 0;
			end
			
			// Not reading but writing -> output_status_reg = 1 (full)
			else if( !output_buffer_RdEn && output_buffer_WrEn ) begin
				net_do <= d_in;
				output_status_reg <= 1;
			end
			
			// Reading but not writing -> output_status_reg = 0 (empty)
			else if( output_buffer_RdEn && !output_buffer_WrEn ) begin
				output_status_reg <= 0;
			end
			
			// Not reading or writing -> no change

			/// End Output Channel Logic ///
			
			
			/// Input Channel Logic: ///
			// Reading and writing to input buffer simultaneously -> input_status_reg can stay 0
			if( input_buffer_RdEn && input_buffer_WrEn ) begin
				input_buffer <= net_di;
				input_status_reg <= 0;
			end
			
			// Not reading but writing -> input_status_reg = 1 (full)
			else if( !input_buffer_RdEn && input_buffer_WrEn ) begin
				input_buffer <= net_di;
				input_status_reg <= 1;
			end
			
			// Reading but not writing -> input_status_reg = 0 (empty)
			else if( input_buffer_RdEn && !input_buffer_WrEn ) begin
				input_status_reg <= 0;
			end
			
			// Not reading or writing -> no change
			
			/// End Input Channel Logic ///		
		end
	end
	
	always @(*) begin
		if( (r_nicEn == 1'b0) | ( (r_nicEn == 1'b1) && (r_nicEnWr == 1'b1) ) ) begin
			d_out = 64'd0;
		end else begin
			case(r_addr)
				2'b00: d_out = 64'd0;
				2'b01: d_out = {63'd0, output_status_reg};
				2'b10: d_out = input_buffer;
				2'b11: d_out = {63'd0, input_status_reg};
			endcase
		end
		
		// ready when buffer is not full
		net_ri = (input_status_reg == 1'b0);
		packet_polarity = net_do[0];
		
		// Send from nic to ring when buffer full, net ready, and opposite polarity external to router
		net_so = (output_status_reg == 1'b1) & net_ro & (net_polarity != packet_polarity);
		
		input_buffer_RdEn = (addr == addr_input_buffer) && nicEn;
		input_buffer_WrEn = net_si && (input_status_reg == 1'b0);
		output_buffer_RdEn = net_so;
		output_buffer_WrEn = nicEn && nicEnWr && (output_status_reg == 1'b0) && (addr == addr_output_buffer);
	end		
endmodule