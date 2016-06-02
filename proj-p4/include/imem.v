/////////////////////////////////////////////////////////////////////
// Project      : EE577B Spring2016 Gold SoC
// Filename     : imem.v
// Description  : Instruction Memory For Gold Variable-width Processor 
// Author       : Aditya Deshpande
// Date Created : 03/06/2016
// Version      : ver1
// Last Modified by : Aditya 
// Update Log   :
//
/////////////////////////////////////////////////////////////////////
`timescale 1ns/10ps

module imem (memAddr, dataOut);
	input  [0:7]   memAddr;   // Memory Read Address (8-bit)
	output [0:31]  dataOut;   // Memory READ Output Data

	// Memory Declaration
	reg [0:31] MEM[0:255];    // 32-wide, 256-deep memory

	// Asynchronous READ Operation
	assign dataOut = MEM[memAddr];
	
endmodule

