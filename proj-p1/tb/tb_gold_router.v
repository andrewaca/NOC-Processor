//---------------------------------------------------------------------------------------
//  Project - Phase 1 - Gold Router Implementation - Testbench
// 	
//	Details: 
// 	-------- 	
//	- the tb_router module runs different tests for a single router element
//	- set the RUN_ALL directive to run all test cases 
// 	- to run cases from only a single test category, reset RUN_ALL and set the value of 
//		the TEST_CATEGORY localparam to the desired value 
//---------------------------------------------------------------------------------------

`timescale 1ns/1ps

`define RUN_ALL 1
module tb_gold_router;
	
	// testbench variables
	reg clk_tb, reset_tb;
	wire polarity_tb;
	
	reg cwsi_tb, ccwsi_tb, pesi_tb;
	reg [63:0] cwdi_tb, ccwdi_tb, pedi_tb;
	wire cwri_tb, ccwri_tb, peri_tb;
	
	reg cwro_tb, ccwro_tb, pero_tb;
	wire cwso_tb, ccwso_tb, peso_tb;
	wire [63:0] cwdo_tb, ccwdo_tb, pedo_tb;
	
	integer testnum = 2;
	
	// constants
	localparam CLK_PERIOD = 4;
	
	// 0 - individual tokens on a single channel
	// 1 - multiple tokens on different VCs of same channel
	// 2 - multiple tokens on same VCs of same channel
	// 3 - multiple tokens on different VCs of different channels
	// 4 - multiple tokens on same VCs of different channels
	// 5 - gather on different VCs of same channel
	// 6 - gather on same VCs of same channel + arbitration check
	// 7 - sending on three channels (same VC)
	// 8 - blocking - fill all input and output buffers
	localparam TEST_CATEGORY = 8;	
	
	localparam CW = 0;
	localparam CCW = 1;
	localparam PE = 2;
	
	localparam EVEN = 0;
	localparam ODD = 1;
	reg [31:0] payload_data = 0;
	integer curr_category = 0;
	
	// instantiate design
	gold_router	uut(.clk(clk_tb), .reset(reset_tb), .polarity(polarity_tb),
					.cwsi(cwsi_tb), .cwri(cwri_tb), .ccwsi(ccwsi_tb), .ccwri(ccwri_tb), 
					.pesi(pesi_tb), .peri(peri_tb), .cwdi(cwdi_tb), .ccwdi(ccwdi_tb), .pedi(pedi_tb), 
					.cwso(cwso_tb), .cwro(cwro_tb), .ccwso(ccwso_tb), .ccwro(ccwro_tb), 
					.peso(peso_tb), .pero(pero_tb), .cwdo(cwdo_tb), .ccwdo(ccwdo_tb), .pedo(pedo_tb));

	// file IO
	integer fp;
	initial 
	begin
    	fp = $fopen("reports/tb_gold_router.res"); 
		if (fp == 0) 
		begin
			$display("data_file handle was NULL");
			$finish;
		end
	end
	
	always @(negedge clk_tb)
	begin
		$fdisplay(fp, "TIME=%g ns", $time);
		$fdisplay(fp, "RESET=%b, \tPOLARITY=%b, \tTEST_NUM=%g,\tTEST_CAT=%g", reset_tb, polarity_tb, testnum, curr_category);
		$fdisplay(fp, ">>CWSI=%b, \tCWRI=%b, \tCWDI=%h, \tCWSO=%b, \tCWRO=%b, \tCWDO=%h", cwsi_tb, cwri_tb, cwdi_tb, cwso_tb, cwro_tb, cwdo_tb);
		$fdisplay(fp, ">>CCSI=%b, \tCCRI=%b, \tCCDI=%h, \tCCSO=%b, \tCCRO=%b, \tCCDO=%h", ccwsi_tb, ccwri_tb, ccwdi_tb, ccwso_tb, ccwro_tb, ccwdo_tb);
		$fdisplay(fp, ">>PESI=%b, \tPERI=%b, \tPEDI=%h, \tPESO=%b, \tPERO=%b, \tPEDO=%h\n", pesi_tb, peri_tb, pedi_tb, peso_tb, pero_tb, pedo_tb);
	end 
	
	
	// stimulus
	initial
	begin	: CLK_GENERATOR
		clk_tb = 1'b0;
		forever #(CLK_PERIOD/2) clk_tb = ~clk_tb;
	end

	initial
	begin	: RESET_GENERATOR
		reset_tb = 1'b1;
		#(2*CLK_PERIOD)	reset_tb = ~reset_tb;
	end
	
	
	initial 
	begin : STIMULUS
		
		// reset all signals
		cwsi_tb = 0;
		ccwsi_tb = 0;
		pesi_tb = 0;

		cwro_tb = 1;
		ccwro_tb = 1;
		pero_tb = 1;
		
		cwdi_tb = 0;
		ccwdi_tb = 0;
		pedi_tb = 0;
		
		repeat(3) @(posedge clk_tb);
	
		//----------------------------------------------------------------
		// 0 - individual tokens on a single channel
		//----------------------------------------------------------------
		if (TEST_CATEGORY == 0 || `RUN_ALL)
		begin		
			curr_category = 0;
			// test case 1 - (1)
			// send from pe to cw 
			// no blocking
			// polarity even
			run_test(PE, CW, EVEN, form_packet(EVEN, CW, 4), 0);
			repeat(3) @(posedge clk_tb);

			// test case 2 - (2)
			// send from pe to cw 
			// no blocking
			// polarity odd
			run_test(PE, CW, ODD, form_packet(ODD, CW, 4), 0);
			repeat(3) @(posedge clk_tb);
			
			// test case 3 - (3)
			// send from pe to ccw 
			// no blocking
			// polarity even
			run_test(PE, CCW, EVEN, form_packet(EVEN, CCW, 4), 0);
			repeat(3) @(posedge clk_tb);
			
			// test case 4 - (4)
			// send from pe to ccw 
			// no blocking
			// polarity odd 
			run_test(PE, CCW, ODD, form_packet(ODD, CCW, 4), 0);
			repeat(3) @(posedge clk_tb);
			
			// test case 5 - (5)
			// send through cw
			// no blocking
			// polarity even
			run_test(CW, CW, EVEN, form_packet(EVEN, CW, 4), 0);
			repeat(3) @(posedge clk_tb);
			
			// test case 6 - (6)
			// send through cw 
			// no blocking
			// polarity odd 
			run_test(CW, CW, ODD, form_packet(ODD, CW, 4), 0);
			repeat(3) @(posedge clk_tb);
			
			// test case 7 - (7)
			// send through ccw 
			// no blocking
			// polarity even
			run_test(CCW, CCW, EVEN, form_packet(EVEN, CCW, 4), 0);
			repeat(3) @(posedge clk_tb);
			
			// test case 8 - (8)
			// send through ccw 
			// no blocking
			// polarity odd 
			run_test(CCW, CCW, ODD, form_packet(ODD, CCW, 4), 0);
			repeat(3) @(posedge clk_tb);
			
			// test case 9 - (9)
			// send from pe to cw channel
			// blocking
			// polarity even
			run_test(PE, CW, EVEN, form_packet(EVEN, CW, 4), 1);
			repeat(3) @(posedge clk_tb);
			
			
			// test case 10 - (10)
			// send from pe to cw channel
			// blocking
			// polarity odd
			run_test(PE, CW, ODD, form_packet(ODD, CW, 4), 1);
			repeat(3) @(posedge clk_tb);
			
			
			// test case 11 - (11)
			// send from pe to ccw channel
			// blocking
			// polarity even
			run_test(PE, CCW, EVEN, form_packet(EVEN, CCW, 4), 1);
			repeat(3) @(posedge clk_tb);
			
			// test case 12 - (12)
			// send from pe to ccw channel
			// blocking
			// polarity odd
			run_test(PE, CCW, ODD, form_packet(ODD, CCW, 4), 1);
			repeat(3) @(posedge clk_tb);
			
			// test case 13 - (13)
			// send through cw 
			// blocking
			// polarity even
			run_test(CW, CW, EVEN, form_packet(EVEN, CW, 4), 1);
			repeat(3) @(posedge clk_tb);
			
			// test case 14 - (14)
			// send through cw 
			// blocking
			// polarity odd
			run_test(CW, CW, ODD, form_packet(ODD, CW, 4), 1);
			repeat(3) @(posedge clk_tb);
			
			// test case 15 - (15)
			// send through ccw
			// blocking
			// polarity even
			run_test(CCW, CCW, EVEN, form_packet(EVEN, CCW, 4), 1);
			repeat(3) @(posedge clk_tb);
			
			// test case 16 - (16)
			// send through ccw
			// blocking
			// polarity odd
			run_test(CCW, CCW, ODD, form_packet(ODD, CCW, 4), 1);
			repeat(3) @(posedge clk_tb);
			
			// test case 17 - (17)
			// send from cw to pe 
			// blocking
			// polarity even
			run_test(CW, PE, EVEN, form_packet(EVEN, CW, 0), 1);
			repeat(3) @(posedge clk_tb);
			
			// test case 18 - (18)
			// send from cw to pe 
			// blocking
			// polarity odd 18
			run_test(CW, PE, ODD, form_packet(ODD, CW, 0), 1);
			repeat(3) @(posedge clk_tb);
			
			// test case 19 - (19)
			// send from ccw to pe 
			// blocking
			// polarity even
			run_test(CCW, PE, EVEN, form_packet(EVEN, CCW, 0), 1);
			repeat(3) @(posedge clk_tb);
			
			// test case 20 - (20)
			// send from ccw to pe 
			// blocking
			// polarity odd
			run_test(CCW, PE, ODD, form_packet(ODD, CCW, 0), 1);
			repeat(3) @(posedge clk_tb);
		end 
		
		
		//----------------------------------------------------------------
		// 1 - multiple tokens on different VCs of same channel
		//----------------------------------------------------------------
		if (TEST_CATEGORY == 1 || `RUN_ALL)
		begin 
			curr_category = 1;
			// test case 1 - (21)
			// pi to cw on even 
			// pi to cw on odd
			// non-blocking 
			run_test_b2b(PE, CW, EVEN, form_packet(EVEN, CW, 4), form_packet(ODD, CW, 4), 0);
			repeat(5) @(posedge clk_tb);
			
			// test case 2 - (22)
			// pi to ccw on even
			// pi to ccw on odd
			// non-blocking 
			//run_test(PE, CCW, EVEN, form_packet(EVEN, CCW, 4), 0);
			//run_test(PE, CCW, ODD, form_packet(ODD, CCW, 4), 0);
			run_test_b2b(PE, CCW, EVEN, form_packet(EVEN, CCW, 4), form_packet(ODD, CCW, 4), 0);
			repeat(5) @(posedge clk_tb);
			
			// test case 3 - (23)
			// pi to cw on even 
			// pi to cw odd
			// blocking 
			run_test_b2b(PE, CW, EVEN, form_packet(EVEN, CW, 4), form_packet(ODD, CW, 4), 1);
			repeat(5) @(posedge clk_tb);
			
			// test case 4 - (24)
			// pi to ccw on even
			// pi to ccw on odd
			// blocking 
			run_test_b2b(PE, CCW, EVEN, form_packet(EVEN, CCW, 4), form_packet(ODD, CCW, 4), 1);
			repeat(5) @(posedge clk_tb);
			
			// test case 5 - (25)
			// through cw on even
			// through cw on odd
			// non-blocking
			run_test_b2b(CW, CW, EVEN, form_packet(EVEN, CW, 4), form_packet(ODD, CW, 4), 0);
			repeat(5) @(posedge clk_tb);
			
			// test case 6 - (26)
			// through ccw on even
			// through ccw on odd
			// non-blocking
			run_test_b2b(CCW, CCW, EVEN, form_packet(EVEN, CCW, 4), form_packet(ODD, CCW, 4), 0);
			repeat(5) @(posedge clk_tb);
			
			// test case 7 - (27)
			// cw to po on even
			// cw to po on odd
			// non-blocking
			run_test_b2b(CW, PE, EVEN, form_packet(EVEN, CW, 0), form_packet(ODD, CW, 0), 0);
			repeat(5) @(posedge clk_tb);
			
			// test case 8 - (28)
			// ccw to po on even
			// ccw to po on odd 
			// non-blocking
			run_test_b2b(CCW, PE, EVEN, form_packet(EVEN, CCW, 0), form_packet(ODD, CCW, 0), 0);
			repeat(5) @(posedge clk_tb);
		end 
		
		//----------------------------------------------------------------
		// 2 - multiple tokens on same VCs of same channel
		//----------------------------------------------------------------
		if (TEST_CATEGORY == 2 || `RUN_ALL)
		begin
			curr_category = 2;
			// test case 1 - (29)
			// pi to cw on even 
			// pi to cw on even
			testnum = testnum - 1;
			run_test(PE, CW, EVEN, form_packet(EVEN, CW, 4), 0);
			@(posedge clk_tb);
			run_test(PE, CW, EVEN, form_packet(EVEN, CW, 4), 0);
			
			repeat(5) @(posedge clk_tb);
			
			// test case 2 - (30)
			// pi to ccw on odd
			// pi to ccw on odd 
			run_test(PE, CCW, ODD, form_packet(ODD, CCW, 4), 0);
			run_test(PE, CCW, ODD, form_packet(ODD, CCW, 4), 0);
			testnum = testnum - 1;
			repeat(5) @(posedge clk_tb);
			
			
			// test case 3 - (31)
			// through cw on even
			// through cw on even
			run_test(CW, CW, EVEN, form_packet(EVEN, CW, 4), 0);
			run_test(CW, CW, EVEN, form_packet(EVEN, CW, 4), 0);
			testnum = testnum - 1;
			repeat(5) @(posedge clk_tb);
			
			// test case 4 - (32)
			// through ccw on odd
			// through ccw on odd
			run_test(CCW, CCW, ODD, form_packet(ODD, CCW, 4), 0);
			run_test(CCW, CCW, ODD, form_packet(ODD, CCW, 4), 0);
			testnum = testnum - 1;
			repeat(5) @(posedge clk_tb);
			
			// test case 5 - (33)
			// cw to po on even
			// cw to po on even
			run_test(CW, PE, EVEN, form_packet(EVEN, CW, 0), 0);
			run_test(CW, PE, EVEN, form_packet(EVEN, CW, 0), 0);
			testnum = testnum - 1;
			repeat(5) @(posedge clk_tb);
			
			// test case 6 - (34)
			// cw to po on even
			// cw to po on even
			// blocking 
			run_test(CW, PE, EVEN, form_packet(EVEN, CW, 0), 1);
			run_test(CW, PE, EVEN, form_packet(EVEN, CW, 0), 1);
			testnum = testnum - 1;
			repeat(5) @(posedge clk_tb);
		end 
		
		//----------------------------------------------------------------
		// 3 - multiple tokens on different VCs of different channels
		//----------------------------------------------------------------
		if (TEST_CATEGORY == 3 || `RUN_ALL)
		begin
			curr_category = 3;
			// test case 1 - (35)
			// pi to cw on even
			// pi to ccw on odd 
			// non-blocking 
			testnum = testnum + 1;
			cwro_tb = 1;
			ccwro_tb = 1;
			@(posedge clk_tb);
			#1;
			wait((polarity_tb == ODD) && (peri_tb == 1));
			pesi_tb = 1;
			pedi_tb = form_packet(EVEN, CW, 4);
			@(posedge clk_tb);
			#1;
			pedi_tb = form_packet(ODD, CCW, 4);
			@(posedge clk_tb);
			#1;
			reset_signals;
			repeat(3) @(posedge clk_tb);
			
			// test case 2 - (36)
			// cw to cw on even
			// ccw to ccw on odd 
			// non-blocking - N 
			testnum = testnum + 1;
			cwro_tb = 1;
			ccwro_tb = 1;
			@(posedge clk_tb);
			#1;
			wait((polarity_tb == ODD) && (cwri_tb == 1));
			cwsi_tb = 1;
			cwdi_tb = form_packet(EVEN, CW, 4);
			@(posedge clk_tb);
			#1;
			reset_send_signals;
			wait((polarity_tb == EVEN) &&(ccwri_tb == 1));
			ccwsi_tb = 1;
			ccwdi_tb = form_packet(ODD, CCW, 4);
			@(posedge clk_tb);
			#1;
			reset_signals;
			repeat(3) @(posedge clk_tb);
			
			// test case 3 - (37)
			// ccw to po on even
			// cw to cw on odd
			// non-blocking - N
			testnum = testnum + 1;
			cwro_tb = 1;
			pero_tb = 1;
			@(posedge clk_tb);
			#1;
			wait((polarity_tb == ODD) && (cwri_tb == 1));
			ccwsi_tb = 1;
			ccwdi_tb = form_packet(EVEN, CCW, 0);
			@(posedge clk_tb);
			#1;
			reset_send_signals;
			wait((polarity_tb == EVEN) &&(ccwri_tb == 1));
			cwsi_tb = 1;
			cwdi_tb = form_packet(ODD, CW, 4);
			@(posedge clk_tb);
			#1;
			reset_signals;
			repeat(3) @(posedge clk_tb);			
		end
		
		//----------------------------------------------------------------
		// 4 - multiple tokens on same VCs of different channels
		//----------------------------------------------------------------
		if (TEST_CATEGORY == 4 || `RUN_ALL)
		begin 
			curr_category = 4;
			// test case 1 - (38)
			// pi to cw on even
			// pi to ccw on even 
			// non-blocking 
			run_test(PE, CW, EVEN, form_packet(EVEN, CW, 4), 0);
			run_test(PE, CCW, EVEN, form_packet(EVEN, CCW, 4), 0);
			repeat(5) @(posedge clk_tb);
			
			// test case 2 - (39)
			// cw to cw on odd
			// ccw to ccw on odd 
			// non-blocking 
			run_test(CW, CW, ODD, form_packet(ODD, CW, 4), 0);
			run_test(CCW, CCW, ODD, form_packet(ODD, CCW, 4), 0);
			repeat(5) @(posedge clk_tb);
			
			// test case 3 - (40)
			// ccw to po on even
			// cw to cw on even
			// non-blocking
			run_test(CCW, PE, EVEN, form_packet(EVEN, CCW, 0), 0);
			run_test(CW, CW, EVEN, form_packet(EVEN, CCW, 4), 0);
			repeat(5) @(posedge clk_tb);
		end 
		
		//----------------------------------------------------------------
		// 5 - gather on different VCs of same channel
		//----------------------------------------------------------------
		if (TEST_CATEGORY == 5 || `RUN_ALL)
		begin 
			curr_category = 5;
			// test case 1 - (41)
			// pi to cw on even 
			// cw to cw on odd 
			testnum = testnum + 1;
			cwro_tb = 1;
			@(posedge clk_tb);
			#1;
			wait((polarity_tb == ODD) && (peri_tb == 1));
			pesi_tb = 1;
			pedi_tb = form_packet(EVEN, CW, 4);
			@(posedge clk_tb);
			#1;
			reset_send_signals;
			wait((polarity_tb == EVEN) &&(cwri_tb == 1));
			cwsi_tb = 1;
			cwdi_tb = form_packet(ODD, CW, 4);
			@(posedge clk_tb);
			#1;
			reset_signals;
			repeat(3) @(posedge clk_tb);
			
			// test case 2 - (42)
			// ccw to ccw on even
			// pi to ccw on odd
			testnum = testnum + 1;
			ccwro_tb = 1;
			@(posedge clk_tb);
			#1;
			wait((polarity_tb == ODD) && (ccwri_tb == 1));
			ccwsi_tb = 1;
			ccwdi_tb = form_packet(EVEN, CCW, 4);
			@(posedge clk_tb);
			#1;
			reset_send_signals;
			wait((polarity_tb == EVEN) &&(peri_tb == 1));
			pesi_tb = 1;
			pedi_tb = form_packet(ODD, CCW, 4);
			@(posedge clk_tb);
			#1;
			reset_signals;
			repeat(3) @(posedge clk_tb);
			
			// test case 3 - (43)
			// cw to po on even
			// ccw to po on odd
			testnum = testnum + 1;
			pero_tb = 1;
			@(posedge clk_tb);
			#1;
			wait((polarity_tb == ODD) && (cwri_tb == 1));
			cwsi_tb = 1;
			cwdi_tb = form_packet(EVEN, CW, 0);
			@(posedge clk_tb);
			#1;
			reset_send_signals;
			wait((polarity_tb == EVEN) &&(ccwri_tb == 1));
			ccwsi_tb = 1;
			ccwdi_tb = form_packet(ODD, CCW, 0);
			@(posedge clk_tb);
			#1;
			reset_signals;
			repeat(3) @(posedge clk_tb);
			
		end 
		
		//----------------------------------------------------------------
		// 6 - gather on same VCs of same channel - arbitration check
		//----------------------------------------------------------------
		if (TEST_CATEGORY == 6 || `RUN_ALL)
		begin
			curr_category = 6;
			// test case 1 - (44)
			// pi to cw on even 
			// cw to cw on even
			testnum = testnum + 1;
			cwro_tb = 1;
			@(posedge clk_tb);
			#1;
			wait((polarity_tb == ODD) && (peri_tb == 1)  &&(cwri_tb == 1) );
			pesi_tb = 1;
			cwsi_tb = 1;
			pedi_tb = form_packet(EVEN, CW, 4);
			cwdi_tb = form_packet(EVEN, CW, 4);
			@(posedge clk_tb);
			#1;
			reset_signals;
			repeat(3) @(posedge clk_tb);
		
			// test case 2 - (45)
			// ccw to ccw on odd
			// pi to ccw on odd
			testnum = testnum + 1;
			ccwro_tb = 1;
			@(posedge clk_tb);
			#1;
			wait((polarity_tb == EVEN) && (peri_tb == 1)  &&(ccwri_tb == 1) );
			pesi_tb = 1;
			ccwsi_tb = 1;
			pedi_tb = form_packet(ODD, CCW, 4);
			ccwdi_tb = form_packet(ODD, CCW, 4);
			@(posedge clk_tb);
			#1;
			reset_signals;
			repeat(3) @(posedge clk_tb);
		
			// test case 3 - (46)
			// cw to po on even
			// ccw to po on even
			testnum = testnum + 1;
			pero_tb = 1;
			@(posedge clk_tb);
			#1;
			wait((polarity_tb == ODD) && (ccwri_tb == 1)  &&(cwri_tb == 1) );
			ccwsi_tb = 1;
			cwsi_tb = 1;
			ccwdi_tb = form_packet(EVEN, CW, 4);
			cwdi_tb = form_packet(EVEN, CW, 4);
			@(posedge clk_tb);
			#1;
			reset_signals;
			repeat(3) @(posedge clk_tb);
		
			// test case 4  - (47)
			// 2 simultaneous gathers - case 1 x2
			testnum = testnum + 1;
			cwro_tb = 1;
			@(posedge clk_tb);
			#1;
			wait((polarity_tb == ODD) && (peri_tb == 1)  &&(cwri_tb == 1) );
			pesi_tb = 1;
			cwsi_tb = 1;
			pedi_tb = form_packet(EVEN, CW, 4);
			cwdi_tb = form_packet(EVEN, CW, 4);
			@(posedge clk_tb);
			#1;
			reset_send_signals;
			@(posedge clk_tb);
			@(posedge clk_tb);
			wait((polarity_tb == ODD) && (peri_tb == 1)  &&(cwri_tb == 1) );
			pesi_tb = 1;
			cwsi_tb = 1;
			pedi_tb = form_packet(EVEN, CW, 4);
			cwdi_tb = form_packet(EVEN, CW, 4);
			@(posedge clk_tb);
			#1;
			reset_signals;
			repeat(3) @(posedge clk_tb);
		end 
		
		//----------------------------------------------------------------
		// 7 - sending on three channels (same VC)
		//----------------------------------------------------------------
		if (TEST_CATEGORY == 7 || `RUN_ALL)
		begin
			curr_category = 7;
			// test case 1 - (48)
			// cw to cw on even
			// ccw to ccw on even
			// pe to ccw on even
			testnum = testnum + 1;
			cwro_tb = 1;
			ccwro_tb = 1;
			@(posedge clk_tb);
			#1;
			wait((polarity_tb == ODD) && (peri_tb)  &&(cwri_tb) && (ccwri_tb));
			pesi_tb = 1;
			cwsi_tb = 1;
			ccwsi_tb = 1;
			pedi_tb = form_packet(EVEN, CCW, 4);
			cwdi_tb = form_packet(EVEN, CW, 4);
			ccwdi_tb = form_packet(EVEN, CCW, 4);
			@(posedge clk_tb);
			#1;
			reset_signals;
			repeat(3) @(posedge clk_tb);
		
		end 

		//----------------------------------------------------------------
		// 8 - blocking - fill all input and output buffers
		//----------------------------------------------------------------
		if (TEST_CATEGORY == 8 || `RUN_ALL)
		begin
			curr_category = 8;
			// test case 1 - (49)
			testnum = testnum + 1;
						
			cwro_tb = 0;
			ccwro_tb = 0;
			pero_tb = 0;
			@(posedge clk_tb);
			#1;
			wait((polarity_tb == ODD) );//&& (peri_tb)  &&(cwri_tb) && (ccwri_tb));
			//pesi_tb = 1;
			cwsi_tb = 1;
			ccwsi_tb = 1;
			pesi_tb = 1;
			
			cwdi_tb = form_packet(EVEN, CW, 0);
			ccwdi_tb = form_packet(EVEN, CCW, 4);
			pedi_tb = form_packet(EVEN, CW, 4);
			@(posedge clk_tb);
			#1;
			cwdi_tb = form_packet(ODD, CW, 0);
			ccwdi_tb = form_packet(ODD, CCW, 4);
			pedi_tb = form_packet(EVEN, CW, 4);

			@(posedge clk_tb);
			#1;		
			cwdi_tb = form_packet(EVEN, CW, 0);
			ccwdi_tb = form_packet(EVEN, CCW, 4);
			pedi_tb = form_packet(EVEN, CW, 4);
			@(posedge clk_tb);
			#1;
			cwdi_tb = form_packet(ODD, CW, 0);
			ccwdi_tb = form_packet(ODD, CCW, 4);
			pedi_tb = form_packet(EVEN, CW, 4);	
			
			@(posedge clk_tb);
			#1;

			reset_signals;
			repeat(5) @(posedge clk_tb);
		
		end
		
		
		// all test cases finished 
		repeat(3) @(posedge clk_tb);
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
	
	// to reset input signals
	task reset_signals;
	begin	
		cwsi_tb = 0;
		ccwsi_tb = 0;
		pesi_tb = 0;

		cwro_tb = 1;
		ccwro_tb = 1;
		pero_tb = 1;
	end
	endtask 
	
	// to reset input send signals
	task reset_send_signals;
	begin	
		cwsi_tb = 0;
		ccwsi_tb = 0;
		pesi_tb = 0;
	end
	endtask 
	
	// to send a token from one input channel to an output channel
	task run_test;
		input [1:0] inp_channel;
		input [1:0] out_channel;
		input polar;
		input [63:0] packet;
		input is_blocking;
	begin
		testnum = testnum + 1;
		if(!is_blocking)
		begin
			// set output channel ready in 
			case (out_channel)
				CW:
					begin
						cwro_tb = 1;
					end
				CCW:
					begin
						ccwro_tb = 1;
					end
				PE:
					begin
						pero_tb = 1;
					end
			endcase
			
			case (inp_channel)
				CW:
					begin
						@(posedge clk_tb);
						#1;
						wait( clk_tb && (polarity_tb == ~polar) && (cwri_tb == 1));
						cwsi_tb = 1;
						cwdi_tb = packet;
					end
				CCW:
					begin
						@(posedge clk_tb);
						#1;
						wait( clk_tb && (polarity_tb == ~polar) && (ccwri_tb == 1));
						ccwsi_tb = 1;
						ccwdi_tb = packet;
					end
				PE:
					begin
						@(posedge clk_tb);
						#1;
						wait( clk_tb && (polarity_tb == ~polar) && (peri_tb == 1));
						$display("Time=%g, POLARITY=%b, POLAR=%b", $time, polarity_tb, polar);
						pesi_tb = 1;
						pedi_tb = packet;
					end
			endcase
			
			@(posedge clk_tb);
			#1;
			reset_signals;
		end
		else
		begin
			// reset output channel ready in 
			case (out_channel)
				CW:
					begin
						cwro_tb = 0;
					end
				CCW:
					begin
						ccwro_tb = 0;
					end
				PE:
					begin
						pero_tb = 0;
					end
			endcase
			
			case (inp_channel)
				CW:
					begin
						@(posedge clk_tb);
						#1;
						wait( clk_tb && (polarity_tb == ~polar) && (cwri_tb == 1));
						cwsi_tb = 1;
						cwdi_tb = packet;
					end
				CCW:
					begin
						@(posedge clk_tb);
						#1;
						wait( clk_tb && (polarity_tb == ~polar) && (ccwri_tb == 1));
						ccwsi_tb = 1;
						ccwdi_tb = packet;
					end
				PE:
					begin
						@(posedge clk_tb);
						#1;
						wait( clk_tb && (polarity_tb == ~polar) && (peri_tb == 1));
						$display("Time=%g, POLARITY=%b, POLAR=%b", $time, polarity_tb, polar);
						pesi_tb = 1;
						pedi_tb = packet;
					end
			endcase
			
			@(posedge clk_tb);
			#1;
			reset_send_signals;
			@(posedge clk_tb);
			@(posedge clk_tb);
			#1;
			reset_signals;
		end 
	end 
	endtask 
	
	
	// to run a test with back-to-back tokens from a single input channel 
	// to a single output channel
	task run_test_b2b;
		input [1:0] inp_channel;
		input [1:0] out_channel;
		input polar;
		input [63:0] packet_one;
		input [63:0] packet_two;
		input is_blocking;
	begin
		testnum = testnum + 1;
		if(!is_blocking)
		begin
			// set output channel ready in 
			case (out_channel)
				CW:
					begin
						cwro_tb = 1;
					end
				CCW:
					begin
						ccwro_tb = 1;
					end
				PE:
					begin
						pero_tb = 1;
					end
			endcase
			
			case (inp_channel)
				CW:
					begin
						@(posedge clk_tb);
						#1;
						wait( clk_tb && (polarity_tb == ~polar) && (cwri_tb == 1));
						cwsi_tb = 1;
						cwdi_tb = packet_one;
						@(posedge clk_tb);
						#1;
						cwdi_tb = packet_two;
					end
				CCW:
					begin
						@(posedge clk_tb);
						#1;
						wait( clk_tb && (polarity_tb == ~polar) && (ccwri_tb == 1));
						ccwsi_tb = 1;
						ccwdi_tb = packet_one;
						@(posedge clk_tb);
						#1;
						ccwdi_tb = packet_two;
					end
				PE:
					begin
						@(posedge clk_tb);
						#1;
						wait( clk_tb && (polarity_tb == ~polar) && (peri_tb == 1));
						pesi_tb = 1;
						pedi_tb = packet_one;
						@(posedge clk_tb);
						wait( clk_tb && (polarity_tb == polar) && (peri_tb == 1));
						#1;
						pedi_tb = packet_two;
					end
			endcase
			
			@(posedge clk_tb);
			#1;
			reset_signals;
		end
		else
		begin
			// reset output channel ready in 
			case (out_channel)
				CW:
					begin
						cwro_tb = 0;
					end
				CCW:
					begin
						ccwro_tb = 0;
					end
				PE:
					begin
						pero_tb = 0;
					end
			endcase
			
			case (inp_channel)
				CW:
					begin
						@(posedge clk_tb);
						#1;
						wait( clk_tb && (polarity_tb == ~polar) && (cwri_tb == 1));
						cwsi_tb = 1;
						cwdi_tb = packet_one;
						@(posedge clk_tb);
						#1;
						cwdi_tb = packet_two;
					end
				CCW:
					begin
						@(posedge clk_tb);
						#1;
						wait( clk_tb && (polarity_tb == ~polar) && (ccwri_tb == 1));
						ccwsi_tb = 1;
						ccwdi_tb = packet_one;
						@(posedge clk_tb);
						#1;
						ccwdi_tb = packet_two;
					end
				PE:
					begin
						@(posedge clk_tb);
						#1;
						wait( clk_tb && (polarity_tb == ~polar) && (peri_tb == 1));
						pesi_tb = 1;
						pedi_tb = packet_one;
						@(posedge clk_tb);
						#1;
						pedi_tb = packet_two;
					end
			endcase
			
			@(posedge clk_tb);
			#1;
			reset_send_signals;
			@(posedge clk_tb);
			@(posedge clk_tb);
			#1;
			reset_signals;
		end 
	end
	endtask
	
endmodule
