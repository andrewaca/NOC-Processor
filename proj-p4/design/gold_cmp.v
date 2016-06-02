module gold_cmp(clk, reset, 
node0_inst_in, node0_d_in, node0_pc_out, node0_d_out, node0_addr_out, node0_memWrEn, node0_memEn,
node1_inst_in, node1_d_in, node1_pc_out, node1_d_out, node1_addr_out, node1_memWrEn, node1_memEn,
node2_inst_in, node2_d_in, node2_pc_out, node2_d_out, node2_addr_out, node2_memWrEn, node2_memEn,
node3_inst_in, node3_d_in, node3_pc_out, node3_d_out, node3_addr_out, node3_memWrEn, node3_memEn);
	
	input			clk;
	input			reset;
	
	input	[0:31]	node0_inst_in;
	input	[0:63]	node0_d_in;
	output	[0:31]	node0_pc_out;
	output	[0:63]	node0_d_out;
	output	[0:31]	node0_addr_out;
	output			node0_memWrEn;
	output			node0_memEn;
	wire	[0:1]	node0_addr_nic;
	wire	[0:63]	node0_din_nic;
	wire	[0:63]	node0_dout_nic;
	wire			node0_nicEn;
	wire			node0_nicWrEn;
	
	input	[0:31]	node1_inst_in;
	input	[0:63]	node1_d_in;
	output	[0:31]	node1_pc_out;
	output	[0:63]	node1_d_out;
	output	[0:31]	node1_addr_out;
	output			node1_memEn;
	output			node1_memWrEn;
	wire	[0:1]	node1_addr_nic;
	wire	[0:63]	node1_din_nic;
	wire	[0:63]	node1_dout_nic;
	wire			node1_nicEn;
	wire			node1_nicWrEn;
	
	input	[0:31]	node2_inst_in;
	input	[0:63]	node2_d_in;
	output	[0:31]	node2_pc_out;
	output	[0:63]	node2_d_out;
	output	[0:31]	node2_addr_out;
	output			node2_memEn;
	output			node2_memWrEn;
	wire	[0:1]	node2_addr_nic;
	wire	[0:63]	node2_din_nic;
	wire	[0:63]	node2_dout_nic;
	wire			node2_nicEn;
	wire			node2_nicWrEn;
	
	input	[0:31]	node3_inst_in;
	input	[0:63]	node3_d_in;
	output	[0:31]	node3_pc_out;
	output	[0:63]	node3_d_out;
	output	[0:31]	node3_addr_out;
	output			node3_memEn;
	output			node3_memWrEn;
	wire	[0:1]	node3_addr_nic;
	wire	[0:63]	node3_din_nic;
	wire	[0:63]	node3_dout_nic;
	wire			node3_nicEn;
	wire			node3_nicWrEn;

	wire node0_polarity, node1_polarity,	node2_polarity,	node3_polarity;
	wire node0_pesi, node1_pesi, node2_pesi, node3_pesi;
	wire node0_peri, node1_peri, node2_peri, node3_peri;
	wire node0_peso, node1_peso, node2_peso, node3_peso;
	wire node0_pero, node1_pero, node2_pero, node3_pero;
	wire [63:0] node0_pedi, node1_pedi, node2_pedi, node3_pedi;
	wire [63:0] node0_pedo, node1_pedo, node2_pedo, node3_pedo;
	
	gold_ring ring(clk, reset, node0_pesi, node0_peri, node0_pedi, node0_peso, node0_pero, node0_pedo, node1_pesi, node1_peri, node1_pedi, node1_peso, node1_pero, node1_pedo, node2_pesi, node2_peri, node2_pedi, node2_peso, node2_pero, node2_pedo, node3_pesi, node3_peri, node3_pedi, node3_peso, node3_pero, node3_pedo, node0_polarity, node1_polarity, node2_polarity, node3_polarity);

	Gold_nic nic_0(.clk(clk), .reset(reset), .addr(node0_addr_nic), .d_in(node0_din_nic), .d_out(node0_dout_nic), .nicEn(node0_nicEn), .nicEnWr(node0_nicWrEn), .net_si(node0_peso), .net_ri(node0_pero), .net_di(node0_pedo), .net_so(node0_pesi), .net_ro(node0_peri), .net_do(node0_pedi), .net_polarity(node0_polarity));

	gold_processor proc_0(.clk(clk), .reset(reset), .pc(node0_pc_out), .instruction(node0_inst_in),	.memAddr(node0_addr_out), .memEn(node0_memEn), .memWrEn(node0_memWrEn), .dataIn(node0_d_in), .dataOut(node0_d_out), .addr(node0_addr_nic), .d_in(node0_din_nic), .d_out(node0_dout_nic), .nicEn(node0_nicEn), .nicEnWr(node0_nicWrEn));

	Gold_nic nic_1(.clk(clk), .reset(reset), .addr(node1_addr_nic), .d_in(node1_din_nic), .d_out(node1_dout_nic), .nicEn(node1_nicEn), .nicEnWr(node1_nicWrEn), .net_si(node1_peso), .net_ri(node1_pero), .net_di(node1_pedo), .net_so(node1_pesi), .net_ro(node1_peri), .net_do(node1_pedi), .net_polarity(node1_polarity));

	gold_processor proc_1(.clk(clk), .reset(reset), .pc(node1_pc_out), .instruction(node1_inst_in),	.memAddr(node1_addr_out), .memEn(node1_memEn), .memWrEn(node1_memWrEn), .dataIn(node1_d_in), .dataOut(node1_d_out), .addr(node1_addr_nic), .d_in(node1_din_nic), .d_out(node1_dout_nic), .nicEn(node1_nicEn), .nicEnWr(node1_nicWrEn));

	Gold_nic nic_2(.clk(clk), .reset(reset), .addr(node2_addr_nic), .d_in(node2_din_nic), .d_out(node2_dout_nic), .nicEn(node2_nicEn), .nicEnWr(node2_nicWrEn), .net_si(node2_peso), .net_ri(node2_pero), .net_di(node2_pedo), .net_so(node2_pesi), .net_ro(node2_peri), .net_do(node2_pedi), .net_polarity(node2_polarity));

	gold_processor proc_2(.clk(clk), .reset(reset), .pc(node2_pc_out), .instruction(node2_inst_in),	.memAddr(node2_addr_out), .memEn(node2_memEn), .memWrEn(node2_memWrEn), .dataIn(node2_d_in), .dataOut(node2_d_out), .addr(node2_addr_nic), .d_in(node2_din_nic), .d_out(node2_dout_nic), .nicEn(node2_nicEn), .nicEnWr(node2_nicWrEn));

	Gold_nic nic_3(.clk(clk), .reset(reset), .addr(node3_addr_nic), .d_in(node3_din_nic), .d_out(node3_dout_nic), .nicEn(node3_nicEn), .nicEnWr(node3_nicWrEn), .net_si(node3_peso), .net_ri(node3_pero), .net_di(node3_pedo), .net_so(node3_pesi), .net_ro(node3_peri), .net_do(node3_pedi), .net_polarity(node3_polarity));

	gold_processor proc_3(.clk(clk), .reset(reset), .pc(node3_pc_out), .instruction(node3_inst_in),	.memAddr(node3_addr_out), .memEn(node3_memEn), .memWrEn(node3_memWrEn), .dataIn(node3_d_in), .dataOut(node3_d_out), .addr(node3_addr_nic), .d_in(node3_din_nic), .d_out(node3_dout_nic), .nicEn(node3_nicEn), .nicEnWr(node3_nicWrEn));
	
endmodule