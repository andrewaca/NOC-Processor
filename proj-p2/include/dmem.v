/////////////////////////////////////////////////////////////////////
// Project      : EE577B Spring2016 Gold SoC
// Filename     : dmem.v
// Description  : Data Memory For Gold Variable-width Processor 
// Author       : Aditya Deshpande
// Date Created : 03/06/2016 
// Version      : ver2
// Last Modified by : Aditya 
// Update Log   : last updated on 3/20/2016
// Ver2: update line75 from MEM[memAddr] to MEM[r_memAddr]
//
/////////////////////////////////////////////////////////////////////
`timescale 1ns/10ps

/*
            --	Addr     ------------
    Addr-->|  |-------->|            | data_out
           |  | Data    |   MEM      |------>
    Data-->|  |-------->|   64x256   |
           |  | Control |            |------>
Control -->|  |-------->|            | 
	        --			 ------------
	_____|________________|
 clk /reset

*/

module dmem (clk, reset, memEn, memWrEn, memAddr, dataIn, dataOut);
	input         clk;       // System Clock
	input         reset;      // System Reset
	input         memEn;     // Memory Enable
	input         memWrEn;   // Memory Write Enable
	input  [0:7]  memAddr;   // Memory Read/Write Address (8-bit)
	input  [0:63] dataIn;    // Memory WRITE Data
	output [0:63] dataOut;   // Memory READ Output

	// Memory Declaration
	reg [0:63] MEM[0:255];    // 64-wide, 256-deep memory
	
	// Registered Inputs
	reg r_memEn; 			// registered memEn
	reg [0:7] r_memAddr; 	// registered memAddr
	reg r_memWrEn;			// registered memWrEn
	reg [0:63] r_dataIn;	// registered write data
	
	// Signals for 2-clock delays for READs
	reg r_r_memEn;				// 2-stage delayed memEn
	reg [0:7] r_r_memAddr;		//2-stage delayed Addr for READ

	// READ Operation (2-clock cycle latency)
	assign dataOut = r_r_memEn ? MEM[r_r_memAddr] : 64'd0;
	
	// Input Registers
	// Synchronous WRITE Operation
	always @(posedge clk) begin
		if (reset) begin
			// Clear internal registers at reset
			r_memEn     <= 'd0;
			r_r_memEn   <= 'd0;
			r_memAddr   <= 'd0;
			r_r_memAddr <= 'd0;
			r_memWrEn   <= 'd0;
			r_dataIn    <= 'd0;
		end
		else begin
			r_memEn     <= memEn;
			r_memAddr   <= memAddr;
			r_r_memEn   <= r_memEn;
			r_r_memAddr <= r_memAddr;
			r_memWrEn   <= memWrEn;
			r_dataIn    <= dataIn;
			
			if (r_memEn & r_memWrEn) begin
				MEM[r_memAddr] <= r_dataIn;
			end
		end
	end

endmodule

