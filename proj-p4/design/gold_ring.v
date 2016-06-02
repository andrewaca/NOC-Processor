module gold_ring(clk, reset, node0_pesi, node0_peri, node0_pedi, node0_peso, node0_pero, node0_pedo, node1_pesi, node1_peri, node1_pedi, node1_peso, node1_pero, node1_pedo, node2_pesi, node2_peri, node2_pedi, node2_peso, node2_pero, node2_pedo, node3_pesi, node3_peri, node3_pedi, node3_peso, node3_pero, node3_pedo, node0_polarity, node1_polarity, node2_polarity, node3_polarity);

	input clk, reset;
	output node0_polarity, node1_polarity,	node2_polarity,	node3_polarity;
	input node0_pesi, node1_pesi, node2_pesi, node3_pesi;
	output node0_peri, node1_peri, node2_peri, node3_peri;
	output node0_peso, node1_peso, node2_peso, node3_peso;
	input node0_pero, node1_pero, node2_pero, node3_pero;
	input [63:0] node0_pedi, node1_pedi, node2_pedi, node3_pedi;
	output [63:0] node0_pedo, node1_pedo, node2_pedo, node3_pedo;

	wire [3:0] cws, cwr, ccws, ccwr;
	wire [63:0] cwd [0:3];
	wire [63:0] ccwd [0:3];

	gold_router	node0(.clk(clk), .reset(reset), .polarity(node0_polarity),
		.cwsi  (cws[3]), .cwso  (cws[0]), .cwri  (cwr[3]), .cwro  (cwr[0]), .cwdi  (cwd[3][63:0]), .cwdo  (cwd[0][63:0]),
		.ccwsi(ccws[0]), .ccwso(ccws[3]), .ccwri(ccwr[0]), .ccwro(ccwr[3]), .ccwdi(ccwd[0][63:0]), .ccwdo(ccwd[3][63:0]),
		.pesi(node0_pesi), .peso(node0_peso), .peri(node0_peri), .pero(node0_pero), .pedi(node0_pedi), .pedo(node0_pedo)
		);
	gold_router	node1(.clk(clk), .reset(reset), .polarity(node1_polarity),
		.cwsi  (cws[0]), .cwso  (cws[1]), .cwri  (cwr[0]), .cwro  (cwr[1]), .cwdi  (cwd[0][63:0]), .cwdo  (cwd[1][63:0]),
		.ccwsi(ccws[1]), .ccwso(ccws[0]), .ccwri(ccwr[1]), .ccwro(ccwr[0]), .ccwdi(ccwd[1][63:0]), .ccwdo(ccwd[0][63:0]),
		.pesi(node1_pesi), .peso(node1_peso), .peri(node1_peri), .pero(node1_pero), .pedi(node1_pedi), .pedo(node1_pedo)
		);
	gold_router	node2(.clk(clk), .reset(reset), .polarity(node2_polarity),
		.cwsi  (cws[1]), .cwso  (cws[2]), .cwri  (cwr[1]), .cwro  (cwr[2]), .cwdi  (cwd[1][63:0]), .cwdo  (cwd[2][63:0]),
		.ccwsi(ccws[2]), .ccwso(ccws[1]), .ccwri(ccwr[2]), .ccwro(ccwr[1]), .ccwdi(ccwd[2][63:0]), .ccwdo(ccwd[1][63:0]),
		.pesi(node2_pesi), .peso(node2_peso), .peri(node2_peri), .pero(node2_pero), .pedi(node2_pedi), .pedo(node2_pedo)
		);
	gold_router	node3(.clk(clk), .reset(reset), .polarity(node3_polarity),
		.cwsi  (cws[2]), .cwso  (cws[3]), .cwri  (cwr[2]), .cwro  (cwr[3]), .cwdi  (cwd[2][63:0]), .cwdo  (cwd[3][63:0]),
		.ccwsi(ccws[3]), .ccwso(ccws[2]), .ccwri(ccwr[3]), .ccwro(ccwr[2]), .ccwdi(ccwd[3][63:0]), .ccwdo(ccwd[2][63:0]),
		.pesi(node3_pesi), .peso(node3_peso), .peri(node3_peri), .pero(node3_pero), .pedi(node3_pedi), .pedo(node3_pedo)
		);	
endmodule