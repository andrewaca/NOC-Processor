//---------------------------------------------------------------------------------------
//	Project - Phase 2 - Gold Processor Implementation - CPU Module
// 	
//	Details: 
//	-------- 
//		- Three modules in this file - program_counter, register_file, and gold_processor
//---------------------------------------------------------------------------------------

module gold_processor (clk, reset, pc, instruction, memAddr, memEn, memWrEn, dataIn, dataOut,
						addr, d_in, d_out, nicEn, nicEnWr);
						
	input         		clk;            // System Clock
	input         		reset;          // System Reset
	input  		[0:31] 	instruction;    // Instruction from Instruction Memory
	input  		[0:63] 	dataIn;         // Data from Data Memory
	output 		[0:31] 	pc;             // Program Counter
	output reg 	[0:63] 	dataOut;        // Write Data to Data Memory
	output reg 	[0:31] 	memAddr;        // Write Address for Data Memory
	output reg       	memEn;          // Data Memory Enable
	output reg       	memWrEn;        // Data Memory Write Enable
	
	output reg	[0:1]	addr;			// NIC register select
	output reg 	[0:63]	d_in;			// NIC output buffer data 
	input 		[0:63]  d_out;			// NIC input buffer output
	output reg			nicEn;			// NIC enable signal 
	output reg			nicEnWr;		// NIC write enable signal 
	
	// stage register variables
	reg [0:31]	IF_instruction;
	
	reg [0:31] 	ID_instruction;
	reg [0:15]	ID_immediate;
	reg [0:4]	ID_regA, ID_regB, ID_regD;
	reg [0:4]	ID_rf_rd1_addr;
	reg [0:2]	ID_PPP;
	reg [0:1]	ID_WW;
	reg [0:5] 	ID_alu_func;
	reg			ID_branch;
	reg 		ID_is_store, ID_is_load, ID_reg_write, ID_is_mul32;
	reg 		ID_is_bnez, ID_is_bez;
	reg 		ID_flush_ff;
	wire [0:63]	ID_oprA, ID_oprB;
	reg [0:4]	ID_shift_amt;
	reg 		ID_is_rtype, ID_is_mem_ld, ID_is_mem_sd, ID_is_branch_bn, ID_is_branch_bz, ID_is_nop;
	reg 		ID_is_illegal, ID_is_illegal_PPP, ID_is_illegal_func, ID_is_illegal_opcode, ID_is_illegal_unary, ID_is_illegal_mul;
	reg 		ID_is_nic_type;
	reg 		ID_is_nic_store;
	
	reg [0:63] 	EX_oprA, EX_oprB, EX_alu_A, EX_alu_B;
	reg [0:2] 	EX_PPP;
	reg [0:1] 	EX_WW;
	reg [0:4] 	EX_dest_reg, EX_regA, EX_regB;
	reg [0:4] 	EX_shift_amt;
	reg 		EX_reg_write;
	reg 		EX_is_load;
	reg 		EX_is_mul32;
	reg [0:5] 	EX_alu_func;
	wire [0:63]	EX_alu_result;
	reg 		EX_is_nic_load;
	
	reg [0:63]	WB_alu_result;
	wire [0:63]	WB_mult32_result;
	reg [0:63] 	WB_data;
	reg [0:4] 	WB_dest_reg;
	reg [0:2] 	WB_PPP;
	reg [0:1] 	WB_WW;
	reg 		WB_reg_write;
	reg 		WB_is_load;
	reg 		WB_reg_write_load;
	reg 		WB_is_mul32;
	reg 		WB_is_nic_load;
	reg [0:63]	WB_nic_ld_data;
	
	reg STALL, PREVIOUS_STALL, PREVIOUS_2_STALL;
	reg store_dependency, branch_dependency, mult_dependency;
	
	// Program Counter
	program_counter PC(.clk(clk), .reset(reset), .stall(STALL), .pc_load(ID_branch), .data_in(ID_immediate), .data_out(pc));
	
	// Reg file 
	register_file reg_file(.clk(clk), .reset(reset), .write_en(WB_reg_write_load), .read1_addr(ID_rf_rd1_addr),
	.read2_addr(ID_regB), .write_addr(WB_dest_reg), .Din(WB_data),
	.Dout1(ID_oprA), .Dout2(ID_oprB), .PPP(WB_PPP));
	
	// ALU
	alu ALU(.clk(clk), .oprA(EX_alu_A), .oprB(EX_alu_B), .op(EX_alu_func), .shift_amount(EX_shift_amt),.ww(EX_WW), 
			.result(EX_alu_result), .mult32_result(WB_mult32_result));
	
	// registers
	always@(posedge clk)
	begin
		if (reset) begin
			// ID
			ID_instruction 	<= 32'hF0000000;	// VNOP
			ID_flush_ff		<= 0;
			
			// EX
			EX_PPP 			<= 0;
			EX_WW 			<= 0;
			EX_oprA 		<= 0;
			EX_oprB 		<= 0;
			EX_alu_func 	<= 0;
			EX_is_load	 	<= 0;
			EX_reg_write 	<= 0;
			EX_is_mul32		<= 0;
			EX_dest_reg 	<= 0;
			EX_shift_amt	<= 0;
			EX_is_nic_load	<= 0;
				
			// WB
			WB_PPP 			<= 0;
			WB_WW			<= 0;
			WB_dest_reg		<= 0;
			WB_reg_write	<= 0;
			WB_alu_result	<= 0;
			WB_is_load		<= 0;
			WB_is_mul32		<= 0;
			WB_is_nic_load	<= 0;
			WB_nic_ld_data	<= 0;
			
			PREVIOUS_STALL <= 0;
			PREVIOUS_2_STALL <= 0;
		end 
		else begin
			PREVIOUS_2_STALL <= PREVIOUS_STALL;
			if (!STALL) begin
				//----------------------------------------------------------------------
				// ID
				//----------------------------------------------------------------------
				ID_instruction 	<= IF_instruction;
				ID_flush_ff		<= ID_branch;
				//----------------------------------------------------------------------
				
				//----------------------------------------------------------------------
				// EX
				//----------------------------------------------------------------------
				EX_PPP 			<= ID_PPP;
				EX_WW 			<= ID_WW;
				EX_oprA 		<= ID_oprA;
				EX_oprB 		<= ID_oprB;
				EX_alu_func 	<= ID_alu_func;
				EX_is_load	 	<= ID_is_load;
				EX_reg_write 	<= ID_reg_write & (~STALL);
				EX_is_mul32		<= ID_is_mul32;
				EX_dest_reg 	<= ID_regD;
				EX_regA			<= ID_regA;
				EX_regB			<= ID_regB;
				EX_shift_amt	<= ID_shift_amt;
				EX_is_nic_load	<= (ID_is_nic_type && ID_is_load);
				
				//----------------------------------------------------------------------
				PREVIOUS_STALL <= 0;
			end
			else begin
				PREVIOUS_STALL <= 1;
			end
			
			
			//----------------------------------------------------------------------
			// WB
			//----------------------------------------------------------------------
			WB_PPP 			<= EX_PPP;
			WB_WW			<= EX_WW;
			WB_dest_reg		<= EX_dest_reg;
			WB_reg_write	<= EX_reg_write;
			WB_alu_result	<= EX_alu_result;
			WB_is_load		<= EX_is_load; 
			WB_is_mul32		<= EX_is_mul32;
			WB_is_nic_load	<= EX_is_nic_load;
			WB_nic_ld_data	<= d_out;
			//----------------------------------------------------------------------
		end 
	end 
	
	// combinational logic and OFL
	always@(*)
	begin
		//----------------------------------------------------------------------
		// IF
		//----------------------------------------------------------------------
		IF_instruction = instruction;
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		// ID 
		//----------------------------------------------------------------------
		ID_immediate 	= ID_instruction[16:31];
		ID_regD 		= ID_instruction[6:10];
		ID_regA 		= ID_instruction[11:15];
		ID_regB 		= ID_instruction[16:20];
		ID_shift_amt	= ID_instruction[16:20];
		ID_alu_func 	= ID_instruction[26:31];
		
		ID_is_rtype 	= (ID_instruction[0:5] == 6'b101010);
		ID_PPP 			= ID_is_rtype ? ID_instruction[21:23] : 3'd0;
		ID_WW 			= ID_is_rtype ? ID_instruction[24:25] : 2'b11;
		ID_is_mem_ld 	= (ID_instruction[0:5] == 6'b100000) && (ID_regA == 0);
		ID_is_mem_sd 	= (ID_instruction[0:5] == 6'b100001) && (ID_regA == 0);
		ID_is_branch_bz	= (ID_instruction[0:5] == 6'b100010) && (ID_regA == 0);
		ID_is_branch_bn	= (ID_instruction[0:5] == 6'b100011) && (ID_regA == 0);
		ID_is_nop		= (ID_instruction == 32'hF0000000);
		ID_is_mul32 	= (ID_is_rtype && ID_instruction[26:29] == 4'b0010 && ID_WW == 2'b10) ? 1'b1 : 1'b0;
		
		// if r-type and PPP = 101, 110, 111
		ID_is_illegal_PPP 	= ID_is_rtype && (ID_PPP > 3'b100);
		// if r-type and ALU function = 0, 19, 20, ...
		ID_is_illegal_func 	= ID_is_rtype && (ID_alu_func == 0 || ID_alu_func > 6'b010010);
		// if NOT, MOV, RTTH and instr[16:20] =/= 0 
		ID_is_illegal_unary = ID_is_rtype && (ID_alu_func == 6'b001100 || ID_alu_func == 6'b00100 || ID_alu_func == 6'b00101) && (ID_shift_amt != 0);
		// if illegal opcode
		ID_is_illegal_opcode=  ~(ID_is_rtype || ID_is_branch_bz || ID_is_branch_bn || ID_is_mem_sd || ID_is_mem_ld || ID_is_nop);
		// if 64-bit mul 
		ID_is_illegal_mul 	= (ID_is_rtype && ID_instruction[26:29] == 4'b0010 && ID_WW == 2'b11) ? 1'b1 : 1'b0;
		
		ID_is_illegal	= ID_is_illegal_PPP || ID_is_illegal_func || ID_is_illegal_opcode || ID_is_illegal_unary || ID_is_illegal_mul;
		
		ID_reg_write 	= (!ID_is_illegal && ID_is_rtype && !ID_flush_ff) ? 1'b1 : 1'b0;
		ID_is_load 		= (!ID_is_illegal && ID_is_mem_ld && !ID_flush_ff) ? 1'b1 : 1'b0;
		ID_is_store 	= (!ID_is_illegal && ID_is_mem_sd && !ID_flush_ff) ? 1'b1 : 1'b0;
		ID_is_bez 		= (!ID_is_illegal && ID_is_branch_bz && !ID_flush_ff) ? 1'b1 : 1'b0;
		ID_is_bnez 		= (!ID_is_illegal && ID_is_branch_bn && !ID_flush_ff) ? 1'b1 : 1'b0;
		ID_rf_rd1_addr 	= (ID_reg_write) ? ID_regA : ID_regD;
		
		// determine if branch condition successful
		ID_branch		= (ID_oprA == 0 && ID_is_bez) || (ID_oprA != 0 && ID_is_bnez) ? 1'b1 : 1'b0;
		
		// determine if NIC instruction
		ID_is_nic_type	 = (ID_is_load || ID_is_store) && (ID_immediate[0:1] == 2'b11);
		ID_is_nic_store	 = ID_is_store && (ID_immediate[0:1] == 2'b11);
			
		// generate stall signal
		store_dependency =	(EX_dest_reg != 0) && (EX_dest_reg == ID_regD)
						&&	(EX_reg_write || EX_is_load) && (ID_is_store || ID_is_nic_store);
		branch_dependency = (EX_dest_reg != 0) && (EX_dest_reg == ID_regD) && (ID_is_bez || ID_is_bnez);
		mult_dependency	  = (EX_dest_reg != 0) && ((EX_dest_reg == ID_regA) || (EX_dest_reg == ID_regB)) && (ID_reg_write && (EX_is_mul32));
		
		if ( (store_dependency || branch_dependency || mult_dependency) & (~PREVIOUS_STALL) )
			STALL = 1'b1;
		else
			STALL = 1'b0;

		// handle NIC interface signals
		nicEn = ID_is_nic_type & (~STALL) ;
		nicEnWr = ID_is_nic_store & (~STALL);
		addr = ID_immediate[14:15];
		d_in = ID_oprA;
			
		// generate memory signals
		memEn 			= (ID_is_load | ID_is_store) & (~STALL) & (~ID_is_nic_type);
		memWrEn 		= (ID_is_store) & (~STALL) & (~ID_is_nic_type);
		memAddr 		= {16'b0, ID_immediate};
		dataOut 		= ID_oprA;
		
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		// WB
		//----------------------------------------------------------------------
		// WB multiplexer
		if (WB_is_mul32) begin
			WB_data = WB_mult32_result;
		end
		else if (WB_is_nic_load) begin
			WB_data = WB_nic_ld_data;
		end 
		else if (WB_is_load) begin
			WB_data = dataIn;
		end 
		else begin
			WB_data = WB_alu_result;
		end 
		
		WB_reg_write_load = (WB_is_nic_load | WB_is_load | WB_reg_write) & (~PREVIOUS_2_STALL) & (WB_dest_reg != 0);
		//----------------------------------------------------------------------
		
		//----------------------------------------------------------------------
		// EX
		//----------------------------------------------------------------------
		// forwarding - when both junior and senior instructions are r-type or load
		// also consider PPP value while forwarding 
		if ((WB_reg_write_load && EX_reg_write && (WB_dest_reg == EX_regA))& ~PREVIOUS_STALL ) begin
			case (WB_PPP)
				3'b000: // All bytes participate
					EX_alu_A = WB_data;
				3'b001: // Upper 32-bits participate
					EX_alu_A = {WB_data[0:31], EX_oprA[32:63]} ;
				3'b010: // Lower 32-bits participate
					EX_alu_A = {EX_oprA[0:31], WB_data[32:63]} ;
				3'b011: // Bytes with even index participate
					EX_alu_A = {WB_data[0:7],   EX_oprA[8:15], WB_data[16:23], EX_oprA[24:31],
								WB_data[32:39], EX_oprA[40:47], WB_data[48:55], EX_oprA[56:63]};
				3'b100: // Bytes with odd index participate
					EX_alu_A = {EX_oprA[0:7],   WB_data[8:15], EX_oprA[16:23], WB_data[24:31],
								EX_oprA[32:39], WB_data[40:47], EX_oprA[48:55], WB_data[56:63]};
				default: EX_alu_A = EX_oprA;	// illegal PPP - don't forward 
			endcase 
		end
		else begin 
			EX_alu_A = EX_oprA;
		end 
		
		if ((WB_reg_write_load && EX_reg_write && (WB_dest_reg == EX_regB))& ~PREVIOUS_STALL )begin
			case (WB_PPP)
				3'b000: // All bytes participate
					EX_alu_B = WB_data;
				3'b001: // Upper 32-bits participate
					EX_alu_B = {WB_data[0:31], EX_oprB[32:63]} ;
				3'b010: // Lower 32-bits participate
					EX_alu_B = {EX_oprB[0:31], WB_data[32:63]} ;
				3'b011: // Bytes with even index participate
					EX_alu_B = {WB_data[0:7],   EX_oprB[8:15], WB_data[16:23], EX_oprB[24:31],
								WB_data[32:39], EX_oprB[40:47], WB_data[48:55], EX_oprB[56:63]};
				3'b100: // Bytes with odd index participate
					EX_alu_B = {EX_oprB[0:7],   WB_data[8:15], EX_oprB[16:23], WB_data[24:31],
								EX_oprB[32:39], WB_data[40:47], EX_oprB[48:55], WB_data[56:63]};
				default: EX_alu_B = EX_oprB;	// illegal PPP - don't forward 
			endcase 
		end
		else begin 
			EX_alu_B = EX_oprB;	
		end
		//----------------------------------------------------------------------
		
	end 
endmodule

module register_file(clk, reset, write_en, read1_addr, read2_addr, write_addr, Din, Dout1, Dout2, PPP);
	localparam data_width = 64; // Width of Din and data_out buses
	localparam depth = 32;
	localparam addr_width = 5; // number of bits in address bus

	input clk, reset, write_en;

	input [0:addr_width-1] read1_addr;
	input [0:addr_width-1] read2_addr;
	input [0:addr_width-1] write_addr;

	input [0:data_width-1] Din;
	output reg [0:data_width-1] Dout1;
	output reg [0:data_width-1] Dout2;

	input [0:2] PPP;

	reg [0:data_width-1] ram [0:depth-1];
	reg [0:data_width-1] current_ram, next_ram_value;
	reg [0:5] i;
	
	always @(*) begin
		current_ram = ram[write_addr];
		next_ram_value = calc_ram_value(current_ram, Din , PPP);
		
		// Internally forward Din to Dout if address is the same
		if( (write_addr == read1_addr) && write_en && (write_addr != 5'd0) )
			Dout1 = next_ram_value;
		else
			Dout1 = ram[read1_addr];
			
		if( (write_addr == read2_addr) && write_en && (write_addr != 5'd0) )
			Dout2 = next_ram_value;
		else
			Dout2 = ram[read2_addr];		
	end
	
	always @(posedge clk) begin
		if(reset == 1'b1) begin
			for (i=0; i < depth; i=i+1)
				ram[i] <= {data_width{1'b0}};
		end else begin
			if( (write_en == 1'b1) && (write_addr != 5'd0) ) begin // Ignore writing to register 0
				ram[write_addr] <= next_ram_value;
			end
		end
	end
	
	function [0:data_width-1] calc_ram_value;
		input [0:data_width-1] current_ram;
		input [0:data_width-1] Din;
		input [0:2] PPP;
		reg [0:data_width-1] next_ram;
		begin
			case(PPP)
				3'b000: // All bytes participate
					next_ram = Din;
				3'b001: // Upper 32-bits participate
					next_ram = {Din[0:31], current_ram[32:63]};
				3'b010: // Lower 32-bits participate
					next_ram = {current_ram[0:31], Din[32:63]};
				3'b011: // Bytes with even index participate
					next_ram = {Din[0:7],   current_ram[8:15], Din[16:23], current_ram[24:31],
								Din[32:39], current_ram[40:47], Din[48:55], current_ram[56:63]};
				3'b100: // Bytes with odd index participate
					next_ram = {current_ram[0:7],   Din[8:15], current_ram[16:23], Din[24:31],
								current_ram[32:39], Din[40:47], current_ram[48:55], Din[56:63]};
				default: next_ram = current_ram;
			endcase
			calc_ram_value = next_ram;
		end
	endfunction
endmodule

module program_counter(clk, reset, stall, pc_load, data_in, data_out);
	input clk, reset;
	input pc_load; // Active high load enable for branch
	input stall; // Stop fetching instructions when stall is active
	input [0:15] data_in; // Branch address to load = instruction[16:31]
	output reg [0:31] data_out;

	always@(posedge clk) begin
		if(reset)
			data_out <= 0;
		else if(stall == 1'b0) begin
			if(pc_load)
				data_out <= {16'b0, data_in};
			else
				data_out <= data_out + 3'd4;
		end
	end
endmodule
