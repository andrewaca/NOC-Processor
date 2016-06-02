`define VC 63
`define DIR 62
`define RESERVED 61:56
`define HOPCNT 55:48
`define SOURCE 47:32
`define PAYLOAD 31:0
`define BEFORE_HOPCNT 63:56
`define AFTER_HOPCNT 47:0

module gold_router(clk, reset, polarity,
				   cwsi, cwri, ccwsi, ccwri, pesi, peri, cwdi, ccwdi, pedi, 
				   cwso, cwro, ccwso, ccwro, peso, pero, cwdo, ccwdo, pedo);
	input clk, reset;
	output reg polarity;
	
	input cwsi, ccwsi, pesi;
	input [63:0] cwdi, ccwdi, pedi;
	output cwri, ccwri, peri;
	
	input cwro, ccwro, pero;
	output cwso, ccwso, peso;
	output [63:0] cwdo, ccwdo, pedo;
	
	always @(posedge clk) begin
		if(reset) begin
			polarity <= 0;
		end else begin
			// Polarity is clk/2
			polarity <= ~polarity;
		end
	end
	
	wire [63:0] inBufferOut0, inBufferOut1, inBufferOut2;
	wire [1:0] request0, request1, request2;
	wire [1:0] grant0, grant1, grant2;
	
	inputBuffer i0( .clk(clk), .reset(reset), .polarity(polarity), .sendIn(cwsi), .readyIn(cwri), .dataIn(cwdi), 
			.dataOut(inBufferOut0), .request(request0), .outputBufferGrant( {grant2[0], grant0[0]} ) );
	inputBuffer i1( .clk(clk), .reset(reset), .polarity(polarity),.sendIn(ccwsi), .readyIn(ccwri), .dataIn(ccwdi), 
			.dataOut(inBufferOut1), .request(request1), .outputBufferGrant( {grant2[1], grant1[0]} ) );
	// Input PE buffer has different input logic
	inputBuffer #(.PE(1)) i2( .clk(clk), .reset(reset), .polarity(polarity), .sendIn(pesi), .readyIn(peri), .dataIn(pedi), 
			.dataOut(inBufferOut2), .request(request2), .outputBufferGrant( {grant1[1], grant0[1]} ) );
			
	outputBuffer o1(.clk(clk), .reset(reset), .polarity(polarity), .inputBufferRequest( {request2[0], request0[0]} ), 
			.dataIn0(inBufferOut0), .dataIn1(inBufferOut2), .sendOut(cwso), .readyOut(cwro), 
			.dataOut(cwdo), .InputBufferGrant(grant0) );
	outputBuffer o2(.clk(clk), .reset(reset), .polarity(polarity), .inputBufferRequest( {request2[1], request1[0]} ), 
			.dataIn0(inBufferOut1), .dataIn1(inBufferOut2), .sendOut(ccwso), .readyOut(ccwro), 
			.dataOut(ccwdo), .InputBufferGrant(grant1) );
	outputBuffer o3(.clk(clk), .reset(reset), .polarity(polarity), .inputBufferRequest( {request1[1], request0[1]} ), 
			.dataIn0(inBufferOut0), .dataIn1(inBufferOut1), .sendOut(peso), .readyOut(pero), 
			.dataOut(pedo), .InputBufferGrant(grant2) );
endmodule

module inputBuffer(clk, reset, polarity, sendIn, readyIn, dataIn, dataOut, request, outputBufferGrant);
	parameter PE = 0;
	input clk, reset, polarity;
	input sendIn;
	output reg readyIn;
	input [63:0] dataIn;
	output reg [63:0] dataOut;
	output reg [1:0] request;
	input [1:0] outputBufferGrant;
	
	reg [7:0] newHopCnt;
	
	reg [63:0] evenBuffer, oddBuffer;
	reg evenBufferFull, oddBufferFull;
	
	localparam EVEN = 1'b0, ODD = 1'b1;
	localparam CW = 1'b0, CCW = 1'b1;

	always @(posedge clk) begin
		if(reset) begin
			evenBuffer <= 0;
			oddBuffer <= 0;
			evenBufferFull <= 0;
			oddBufferFull <= 0;
		end else begin
			if(polarity == EVEN) begin
				// Whenever a packet is received on a specific polarity set the buffer as full
				// A grant from output buffer indicates the input buffer is no longer full
				if(sendIn) begin
					oddBuffer <= dataIn;
					oddBufferFull <= 1;
				end
				if(|outputBufferGrant) begin
					evenBufferFull <= 0;
					evenBuffer <= 0;
				end
			end else if(polarity == ODD) begin
				if(sendIn) begin
					evenBuffer <= dataIn;
					evenBufferFull <= 1;
				end
				if(|outputBufferGrant) begin
					oddBufferFull <= 0;
					oddBuffer <= 0;
				end
			end
		end	
	end
	
	// Combinational logic block
	always @(*) begin
		if(polarity == EVEN) begin
			// Input buffer is ready whenever it is not full
			readyIn = ~oddBufferFull&&(~reset);
			// Decrement hop count
			newHopCnt = evenBuffer[`HOPCNT] - 1;
			
			if(PE) begin
				dataOut = {evenBuffer[`BEFORE_HOPCNT], newHopCnt, evenBuffer[`AFTER_HOPCNT]};
				// Request either cw or ccw receiver only if buffer is full
				if(evenBuffer[`DIR] == CW)
					request = {1'b0, evenBufferFull};
				else
					request = {evenBufferFull, 1'b0};
			end else if(evenBuffer[`HOPCNT] == 0) begin
				dataOut = evenBuffer;
				// Request PE if hop count is zero
				request = {evenBufferFull, 1'b0};
			end else begin
				dataOut = {evenBuffer[`BEFORE_HOPCNT], newHopCnt, evenBuffer[`AFTER_HOPCNT]};
				request = {1'b0, evenBufferFull};
			end
			
		end else if(polarity == ODD) begin
			readyIn = ~evenBufferFull&&(~reset);
			newHopCnt = oddBuffer[`HOPCNT] - 1;
			
			if(PE) begin
				dataOut = {oddBuffer[`BEFORE_HOPCNT], newHopCnt, oddBuffer[`AFTER_HOPCNT]};
				if(oddBuffer[`DIR] == CW)
					request = {1'b0, oddBufferFull};
				else
					request = {oddBufferFull, 1'b0};
			end else if(oddBuffer[`HOPCNT] == 0) begin
				dataOut = oddBuffer;
				request = {oddBufferFull, 1'b0};
			end else begin
				dataOut = {oddBuffer[`BEFORE_HOPCNT], newHopCnt, oddBuffer[`AFTER_HOPCNT]};
				request = {1'b0, oddBufferFull};
			end
		end	
	end
endmodule

module outputBuffer(clk, reset, polarity, inputBufferRequest, dataIn0, dataIn1, sendOut, readyOut, dataOut, InputBufferGrant);
	input clk, reset, polarity;
	input [1:0] inputBufferRequest;
	input [63:0] dataIn0, dataIn1;
	output reg sendOut;
	input readyOut;
	output reg [63:0] dataOut;
	output reg [1:0] InputBufferGrant;
	
	reg [63:0] evenBuffer, oddBuffer;
	reg evenBufferFull, oddBufferFull;
	reg priorityRegEven, priorityRegOdd;
	
	localparam EVEN = 1'b0, ODD = 1'b1;

	always @(posedge clk) begin
		if(reset) begin
			evenBuffer <= 0;
			oddBuffer <= 0;
			evenBufferFull <= 0;
			oddBufferFull <= 0;
			priorityRegEven <= 0;
			priorityRegOdd <= 0;
		end else begin
			if(polarity == EVEN) begin
				// Store into even or odd buffer whenever a grant is generated
				if(InputBufferGrant[0]) begin
					evenBuffer <= dataIn0;
					evenBufferFull <= 1;
				end else if(InputBufferGrant[1]) begin
					evenBuffer <= dataIn1;
					evenBufferFull <= 1;
				end
				
				// Buffer full for one cycle if sendOut
				if(sendOut) begin
					oddBufferFull <= 0;
					oddBuffer <= 0;
				end
				
				// Arbiter sequential logic
				if( (inputBufferRequest[1] && inputBufferRequest[0]) && (|InputBufferGrant) )
					priorityRegEven <= ~priorityRegEven;
					
			end else if(polarity == ODD) begin
				if(InputBufferGrant[0]) begin
					oddBuffer <= dataIn0;
					oddBufferFull <= 1;
				end else if(InputBufferGrant[1]) begin
					oddBuffer <= dataIn1;
					oddBufferFull <= 1;
				end
				
				// Buffer full for one cycle if sendOut
				if(sendOut) begin
					evenBufferFull <= 0;
					evenBuffer <= 0;
				end
				
				// Arbiter sequential logic
				if( (inputBufferRequest[1] && inputBufferRequest[0]) && (|InputBufferGrant) )
					priorityRegOdd <= ~priorityRegOdd;
					
			end

		end	
	end
	
	// Combinational logic block
	always @(*) begin
		if(polarity == EVEN) begin
			sendOut = oddBufferFull & readyOut;
			dataOut = oddBuffer;
		end else if(polarity == ODD) begin
			sendOut = evenBufferFull & readyOut;
			dataOut = evenBuffer;
		end
		
		// Arbiter
		case (inputBufferRequest)
			2'b00: InputBufferGrant = 2'b00;
			2'b01:
			begin
				// If only one request then grant that request
				if( ((polarity == EVEN) && (~evenBufferFull)) | ((polarity == ODD) && (~oddBufferFull)) )
					InputBufferGrant = 2'b01;
				else
					InputBufferGrant = 2'b00;
			end
			
			2'b10:
			begin
				// If only one request then grant that request
				if( ((polarity == EVEN) && (~evenBufferFull)) | ((polarity == ODD) && (~oddBufferFull)) )
					InputBufferGrant = 2'b10;
				else
					InputBufferGrant = 2'b00;
			end			
			
			2'b11:
			begin
				// Only grant request if buffer is not full
				if( (polarity == EVEN) && (~evenBufferFull) ) begin
					if(priorityRegEven == 1'b0)
						InputBufferGrant = 2'b01;
					else
						InputBufferGrant = 2'b10;
				end else if( (polarity == ODD) && (~oddBufferFull) ) begin
					if(priorityRegOdd == 1'b0)
						InputBufferGrant = 2'b01;
					else
						InputBufferGrant = 2'b10;
				end else begin
					InputBufferGrant = 2'b00;
				end
			end
		endcase
	end
endmodule
