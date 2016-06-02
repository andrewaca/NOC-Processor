//---------------------------------------------------------------------------------------
//	Project - Phase 2 - Gold Processor Implementation - ALU Module
// 	
//	Details: 
//	-------- 
//		- alu is the module containing the behavioral model of the ALU 
//		- WW field determines the operand width	
//		- a 2-stage multiplier from the Synopsys DesignWare library is used
//			for 32-bit multiplication operations 
//---------------------------------------------------------------------------------------

//`include "/usr/local/synopsys/2011.09/dw/sim_ver/DW02_mult_2_stage.v"

`define WW_B 0
`define WW_H 1
`define WW_W 2
`define WW_D 3

`define NIBBLE0 	0:3
`define NIBBLE1 	4:7
`define NIBBLE2 	8:11
`define NIBBLE3 	12:15
`define NIBBLE4 	16:19
`define NIBBLE5 	20:23
`define NIBBLE6 	24:27
`define NIBBLE7 	28:31
`define NIBBLE8 	32:35
`define NIBBLE9 	36:39
`define NIBBLE10 	40:43
`define NIBBLE11 	44:47
`define NIBBLE12 	48:51
`define NIBBLE13 	52:55
`define NIBBLE14 	56:59
`define NIBBLE15 	60:63

`define BYTE0 0:7
`define BYTE1 8:15
`define BYTE2 16:23
`define BYTE3 24:31
`define BYTE4 32:39
`define BYTE5 40:47
`define BYTE6 48:55
`define BYTE7 56:63

`define HW0 0:15
`define HW1 16:31
`define HW2 32:47
`define HW3 48:63

`define WORD0 0:31
`define WORD1 32:63

`define DW 0:63

module alu (clk, oprA, oprB, shift_amount, op, ww, result, mult32_result);
	
	input clk;
	input [0:63] oprA, oprB;
	input [0:4] shift_amount;
	input [0:5] op;
	input [0:1] ww;
	output reg [0:63] result;
	output reg [0:63] mult32_result;
	
	parameter A32_width = 32;
	parameter B32_width = 32;
	
	reg [0:A32_width-1] mult32_A, mult32_A_reg; 
	reg [0:B32_width-1] mult32_B, mult32_B_reg;
	
	wire [0:A32_width+B32_width-1] mult32_res;

	
	parameter TC_ZERO = 1'b0;
	
	// instantiate two-stage pipelined multipliers from DesignWare library
	DW02_mult_2_stage #(A32_width, B32_width) ALU_MUL32(.A(mult32_A), .B(mult32_B), .TC(TC_ZERO), .CLK(clk), .PRODUCT(mult32_res));
	
	always @(*)
	begin
		mult32_A = 0;
		mult32_B = 0;
		mult32_result = mult32_res;
		
		case (op)
			// VAND
			1:
				begin
					result = oprA & oprB;
				end
			// VOR
			2:
				begin
					result = oprA | oprB;
				end
			// VXOR
			3:
				begin
					result = oprA ^ oprB;
				end
			// VNOT
			4:
				begin
					result = ~oprA;
				end
			// VMOV
			5:
				begin
					result = oprA;
				end
			// VADD
			6:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`BYTE0] 	= oprA[`BYTE0] + oprB[`BYTE0];
								result[`BYTE1] 	= oprA[`BYTE1] + oprB[`BYTE1];
								result[`BYTE2] 	= oprA[`BYTE2] + oprB[`BYTE2];
								result[`BYTE3] 	= oprA[`BYTE3] + oprB[`BYTE3];
								result[`BYTE4] 	= oprA[`BYTE4] + oprB[`BYTE4];
								result[`BYTE5] 	= oprA[`BYTE5] + oprB[`BYTE5];
								result[`BYTE6] 	= oprA[`BYTE6] + oprB[`BYTE6];
								result[`BYTE7] 	= oprA[`BYTE7] + oprB[`BYTE7];
							end
						`WW_H: 
							begin
								result[`HW0] 	= oprA[`HW0] + oprB[`HW0];
								result[`HW1] 	= oprA[`HW1] + oprB[`HW1];
								result[`HW2] 	= oprA[`HW2] + oprB[`HW2];
								result[`HW3] 	= oprA[`HW3] + oprB[`HW3];
							end
						`WW_W: 
							begin
								result[`WORD0] 	= oprA[`WORD0] + oprB[`WORD0];
								result[`WORD1] 	= oprA[`WORD1] + oprB[`WORD1];
							end
						`WW_D: 
							begin
								result = oprA + oprB;
							end
						default: result = 0;
					endcase 
				end
			// VSUB
			7:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`BYTE0] 	= oprA[`BYTE0] - oprB[`BYTE0];
								result[`BYTE1] 	= oprA[`BYTE1] - oprB[`BYTE1];
								result[`BYTE2] 	= oprA[`BYTE2] - oprB[`BYTE2];
								result[`BYTE3] 	= oprA[`BYTE3] - oprB[`BYTE3];
								result[`BYTE4] 	= oprA[`BYTE4] - oprB[`BYTE4];
								result[`BYTE5] 	= oprA[`BYTE5] - oprB[`BYTE5];
								result[`BYTE6] 	= oprA[`BYTE6] - oprB[`BYTE6];
								result[`BYTE7] 	= oprA[`BYTE7] - oprB[`BYTE7];
							end
						`WW_H: 
							begin
								result[`HW0] 	= oprA[`HW0] - oprB[`HW0];
								result[`HW1] 	= oprA[`HW1] - oprB[`HW1];
								result[`HW2] 	= oprA[`HW2] - oprB[`HW2];
								result[`HW3] 	= oprA[`HW3] - oprB[`HW3];
							end
						`WW_W: 
							begin
								result[`WORD0] 	= oprA[`WORD0] - oprB[`WORD0];
								result[`WORD1] 	= oprA[`WORD1] - oprB[`WORD1];
							end
						`WW_D: 
							begin
								result = oprA - oprB;
							end
						default: result = 0;
					endcase 
				end
			// VMULEU
			8:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`HW0] 	= oprA[`BYTE0] * oprB[`BYTE0];
								result[`HW1] 	= oprA[`BYTE2] * oprB[`BYTE2];
								result[`HW2] 	= oprA[`BYTE4] * oprB[`BYTE4];
								result[`HW3] 	= oprA[`BYTE6] * oprB[`BYTE6];
							end
						`WW_H: 
							begin
								result[`WORD0] 	= oprA[`HW0] * oprB[`HW0];
								result[`WORD1] 	= oprA[`HW2] * oprB[`HW2];
							end
						`WW_W: 
							begin
								mult32_A = oprA[`WORD0];
								mult32_B = oprB[`WORD0];
								//result[`DW] = oprA[`WORD0] * oprB[`WORD0];
								result = 0;
							end
						default: result = 0;
					endcase 
				end
			// VMULOU
			9:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`HW0] 	= oprA[`BYTE1] * oprB[`BYTE1];
								result[`HW1] 	= oprA[`BYTE3] * oprB[`BYTE3];
								result[`HW2] 	= oprA[`BYTE5] * oprB[`BYTE5];
								result[`HW3] 	= oprA[`BYTE7] * oprB[`BYTE7];
							end
						`WW_H: 
							begin
								result[`WORD0] 	= oprA[`HW1] * oprB[`HW1];
								result[`WORD1] 	= oprA[`HW3] * oprB[`HW3];
							end
						`WW_W: 
							begin
								//result[`DW] 	= oprA[`WORD1] * oprB[`WORD1];
								mult32_A = oprA[`WORD1];
								mult32_B = oprB[`WORD1];
								result = 0;
							end
						default: result = 0;
					endcase 
				end
			// VSEQEU
			10:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`HW0] 	= oprA[`BYTE0] * oprA[`BYTE0];
								result[`HW1] 	= oprA[`BYTE2] * oprA[`BYTE2];
								result[`HW2] 	= oprA[`BYTE4] * oprA[`BYTE4];
								result[`HW3] 	= oprA[`BYTE6] * oprA[`BYTE6];
							end
						`WW_H: 
							begin
								result[`WORD0] 	= oprA[`HW0] * oprA[`HW0];
								result[`WORD1] 	= oprA[`HW2] * oprA[`HW2];
							end
						`WW_W: 
							begin
								//result[`DW] 	= oprA[`WORD0] * oprA[`WORD0];
								mult32_A = oprA[`WORD0];
								mult32_B = oprA[`WORD0];
								result = 0;
							end
						default: result = 0;
					endcase 
				end
			// VSQOU
			11:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`HW0] 	= oprA[`BYTE1] * oprA[`BYTE1];
								result[`HW1] 	= oprA[`BYTE3] * oprA[`BYTE3];
								result[`HW2] 	= oprA[`BYTE5] * oprA[`BYTE5];
								result[`HW3] 	= oprA[`BYTE7] * oprA[`BYTE7];
							end
						`WW_H: 
							begin
								result[`WORD0] 	= oprA[`HW1] * oprA[`HW1];
								result[`WORD1] 	= oprA[`HW3] * oprA[`HW3];
							end
						`WW_W: 
							begin
								//result[`DW] 	= oprA[`WORD1] * oprA[`WORD1];
								mult32_A = oprA[`WORD1];
								mult32_B = oprA[`WORD1];
								result = 0;
							end
						default: result = 0;
					endcase  
				end
			// VRTTH
			12:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`BYTE0] 	= {oprA[`NIBBLE1], oprA[`NIBBLE0]};
								result[`BYTE1] 	= {oprA[`NIBBLE3], oprA[`NIBBLE2]};
								result[`BYTE2] 	= {oprA[`NIBBLE5], oprA[`NIBBLE4]};
								result[`BYTE3] 	= {oprA[`NIBBLE7], oprA[`NIBBLE6]};
								result[`BYTE4] 	= {oprA[`NIBBLE9], oprA[`NIBBLE8]};
								result[`BYTE5] 	= {oprA[`NIBBLE11], oprA[`NIBBLE10]};
								result[`BYTE6] 	= {oprA[`NIBBLE13], oprA[`NIBBLE12]};
								result[`BYTE7] 	= {oprA[`NIBBLE15], oprA[`NIBBLE14]};
							end
						`WW_H: 
							begin
								result[`HW0] 	= {oprA[`BYTE1], oprA[`BYTE0]};
								result[`HW1] 	= {oprA[`BYTE3], oprA[`BYTE2]};
								result[`HW2] 	= {oprA[`BYTE5], oprA[`BYTE4]};
								result[`HW3] 	= {oprA[`BYTE7], oprA[`BYTE6]};
							end
						`WW_W: 
							begin
								result[`WORD0] 	= {oprA[`HW1], oprA[`HW0]};
								result[`WORD1] 	= {oprA[`HW3], oprA[`HW2]};
							end
						`WW_D:
							begin
								result = {oprA[`WORD1], oprA[`WORD0]};
							end 
						default: result = 0;
					endcase
				end
			// VSLL
			13:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`BYTE0] 	= oprA[`BYTE0] << oprB[5:7];
								result[`BYTE1] 	= oprA[`BYTE1] << oprB[13:15];
								result[`BYTE2] 	= oprA[`BYTE2] << oprB[21:23];
								result[`BYTE3] 	= oprA[`BYTE3] << oprB[29:31];
								result[`BYTE4] 	= oprA[`BYTE4] << oprB[37:39];
								result[`BYTE5] 	= oprA[`BYTE5] << oprB[45:47];
								result[`BYTE6] 	= oprA[`BYTE6] << oprB[53:55];
								result[`BYTE7] 	= oprA[`BYTE7] << oprB[61:63];
							end
						`WW_H: 
							begin
								result[`HW0] 	= oprA[`HW0] << oprB[12:15];
								result[`HW1] 	= oprA[`HW1] << oprB[28:31];
								result[`HW2] 	= oprA[`HW2] << oprB[44:47];
								result[`HW3] 	= oprA[`HW3] << oprB[60:63];
							end
						`WW_W: 
							begin
								result[`WORD0] 	= oprA[`WORD0] << oprB[27:31];
								result[`WORD1] 	= oprA[`WORD1] << oprB[59:63];
							end
						`WW_D:
							begin
								result = oprA << oprB[58:63];
							end 
						default: result = 0;
					endcase
				end
			// VSLLI
			14:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`BYTE0] 	= oprA[`BYTE0] << shift_amount[2:4];
								result[`BYTE1] 	= oprA[`BYTE1] << shift_amount[2:4];
								result[`BYTE2] 	= oprA[`BYTE2] << shift_amount[2:4];
								result[`BYTE3] 	= oprA[`BYTE3] << shift_amount[2:4];
								result[`BYTE4] 	= oprA[`BYTE4] << shift_amount[2:4];
								result[`BYTE5] 	= oprA[`BYTE5] << shift_amount[2:4];
								result[`BYTE6] 	= oprA[`BYTE6] << shift_amount[2:4];
								result[`BYTE7] 	= oprA[`BYTE7] << shift_amount[2:4];
							end
						`WW_H: 
							begin
								result[`HW0] 	= oprA[`HW0] << shift_amount[1:4];
								result[`HW1] 	= oprA[`HW1] << shift_amount[1:4];
								result[`HW2] 	= oprA[`HW2] << shift_amount[1:4];
								result[`HW3] 	= oprA[`HW3] << shift_amount[1:4];
							end
						`WW_W: 
							begin
								result[`WORD0] 	= oprA[`WORD0] << shift_amount[0:4];
								result[`WORD1] 	= oprA[`WORD1] << shift_amount[0:4];
							end
						`WW_D:
							begin
								result = oprA << shift_amount[0:4];
							end 
						default: result = 0;
					endcase
				end
			// VSRL
			15:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`BYTE0] 	= oprA[`BYTE0] >> oprB[5:7];
								result[`BYTE1] 	= oprA[`BYTE1] >> oprB[13:15];
								result[`BYTE2] 	= oprA[`BYTE2] >> oprB[21:23];
								result[`BYTE3] 	= oprA[`BYTE3] >> oprB[29:31];
								result[`BYTE4] 	= oprA[`BYTE4] >> oprB[37:39];
								result[`BYTE5] 	= oprA[`BYTE5] >> oprB[45:47];
								result[`BYTE6] 	= oprA[`BYTE6] >> oprB[53:55];
								result[`BYTE7] 	= oprA[`BYTE7] >> oprB[61:63];
							end
						`WW_H: 
							begin
								result[`HW0] 	= oprA[`HW0] >> oprB[12:15];
								result[`HW1] 	= oprA[`HW1] >> oprB[28:31];
								result[`HW2] 	= oprA[`HW2] >> oprB[44:47];
								result[`HW3] 	= oprA[`HW3] >> oprB[60:63];
							end
						`WW_W: 
							begin
								result[`WORD0] 	= oprA[`WORD0] >> oprB[27:31];
								result[`WORD1] 	= oprA[`WORD1] >> oprB[59:63];
							end
						`WW_D:
							begin
								result = oprA >> oprB[58:63];
							end 
						default: result = 0;
					endcase
				end
			// VSRLI
			16:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`BYTE0] 	= oprA[`BYTE0] >> shift_amount[2:4];
								result[`BYTE1] 	= oprA[`BYTE1] >> shift_amount[2:4];
								result[`BYTE2] 	= oprA[`BYTE2] >> shift_amount[2:4];
								result[`BYTE3] 	= oprA[`BYTE3] >> shift_amount[2:4];
								result[`BYTE4] 	= oprA[`BYTE4] >> shift_amount[2:4];
								result[`BYTE5] 	= oprA[`BYTE5] >> shift_amount[2:4];
								result[`BYTE6] 	= oprA[`BYTE6] >> shift_amount[2:4];
								result[`BYTE7] 	= oprA[`BYTE7] >> shift_amount[2:4];
							end
						`WW_H: 
							begin
								result[`HW0] 	= oprA[`HW0] >> shift_amount[1:4];
								result[`HW1] 	= oprA[`HW1] >> shift_amount[1:4];
								result[`HW2] 	= oprA[`HW2] >> shift_amount[1:4];
								result[`HW3] 	= oprA[`HW3] >> shift_amount[1:4];
							end
						`WW_W: 
							begin
								result[`WORD0] 	= oprA[`WORD0] >> shift_amount[0:4];
								result[`WORD1] 	= oprA[`WORD1] >> shift_amount[0:4];
							end
						`WW_D:
							begin
								result = oprA >> shift_amount[0:4];
							end 
						default: result = 0;
					endcase
				end
			// VSRA
			17:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`BYTE0] 	= $signed(oprA[`BYTE0]) >>> oprB[5:7];
								result[`BYTE1] 	= $signed(oprA[`BYTE1]) >>> oprB[13:15];
								result[`BYTE2] 	= $signed(oprA[`BYTE2]) >>> oprB[21:23];
								result[`BYTE3] 	= $signed(oprA[`BYTE3]) >>> oprB[29:31];
								result[`BYTE4] 	= $signed(oprA[`BYTE4]) >>> oprB[37:39];
								result[`BYTE5] 	= $signed(oprA[`BYTE5]) >>> oprB[45:47];
								result[`BYTE6] 	= $signed(oprA[`BYTE6]) >>> oprB[53:55];
								result[`BYTE7] 	= $signed(oprA[`BYTE7]) >>> oprB[61:63];
							end
						`WW_H: 
							begin
								result[`HW0] 	= $signed(oprA[`HW0]) >>> oprB[12:15];
								result[`HW1] 	= $signed(oprA[`HW1]) >>> oprB[28:31];
								result[`HW2] 	= $signed(oprA[`HW2]) >>> oprB[44:47];
								result[`HW3] 	= $signed(oprA[`HW3]) >>> oprB[60:63];
							end
						`WW_W: 
							begin
								result[`WORD0] 	= $signed(oprA[`WORD0]) >>> oprB[27:31];
								result[`WORD1] 	= $signed(oprA[`WORD1]) >>> oprB[59:63];
							end
						`WW_D:
							begin
								result = $signed(oprA) >>> oprB[58:63];
							end 
						default: result = 0;
					endcase
				end
			// VSRAI
			18:
				begin
					case (ww)
						`WW_B: 
							begin
								result[`BYTE0] 	= $signed(oprA[`BYTE0]) >>> shift_amount[2:4];
								result[`BYTE1] 	= $signed(oprA[`BYTE1]) >>> shift_amount[2:4];
								result[`BYTE2] 	= $signed(oprA[`BYTE2]) >>> shift_amount[2:4];
								result[`BYTE3] 	= $signed(oprA[`BYTE3]) >>> shift_amount[2:4];
								result[`BYTE4] 	= $signed(oprA[`BYTE4]) >>> shift_amount[2:4];
								result[`BYTE5] 	= $signed(oprA[`BYTE5]) >>> shift_amount[2:4];
								result[`BYTE6] 	= $signed(oprA[`BYTE6]) >>> shift_amount[2:4];
								result[`BYTE7] 	= $signed(oprA[`BYTE7]) >>> shift_amount[2:4];
							end
						`WW_H: 
							begin
								result[`HW0] 	= $signed(oprA[`HW0]) >>> shift_amount[1:4];
								result[`HW1] 	= $signed(oprA[`HW1]) >>> shift_amount[1:4];
								result[`HW2] 	= $signed(oprA[`HW2]) >>> shift_amount[1:4];
								result[`HW3] 	= $signed(oprA[`HW3]) >>> shift_amount[1:4];
							end
						`WW_W: 
							begin
								result[`WORD0] 	= $signed(oprA[`WORD0]) >>> shift_amount[0:4];
								result[`WORD1] 	= $signed(oprA[`WORD1]) >>> shift_amount[0:4];
							end
						`WW_D:
							begin
								result = $signed(oprA) >>> shift_amount[0:4];
							end 
						default: result = 0;
					endcase
				end
			default: result = 0;
		endcase
	end 

endmodule