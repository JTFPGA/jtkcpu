module test;

reg clk, rst;

reg psh_ussel;
reg psh_hilon;
reg pul_en;
reg [ 7:0] psh_sel;
reg [ 7:0] cc, op_sel;

reg [15:0] alu, pc;

reg up_a  = 0;
reg up_b  = 0;
reg up_dp = 0;
reg up_x  = 0;
reg up_y  = 0;
reg up_u  = 0;
reg up_s  = 0;

reg dec_us;

wire  [15:0] mux, psh_addr;
wire  [15:0] nx_u, nx_s;
wire  [15:0] idx_reg;
wire  [ 7:0] psh_mux, psh_bit;
wire  up_pul_cc, up_pull_pc;


integer up_random;
integer up_cc, up_pc;


initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    $dumpfile("test.lxt");
    $dumpvars;
    $dumpon;
end

initial begin
    rst = 1;
    op_sel = 8'h88; 
    psh_sel = 8'b00100000; 
    psh_ussel = 0;  
    psh_hilon = 0; 
    pul_en = 0;
    dec_us = 0;

    up_random = 0;
    alu = 127;

    up_cc = 0;
    up_pc = 0;

    #5 rst = 0;
    repeat (30) begin
    	// $display("");
 		alu = $random;
 		up_random = {$random} %10;
		@(posedge clk);
    	case (up_random) 
 			1 : up_a = 1; 
 			2 : up_b = 1; 
  			3 : up_dp = 1; 
 			4 : up_x = 1; 
 			5 : up_y  = 1;  
			6 : up_u  = 1; 
			7 :	up_s  = 1; 
			8 : up_cc  = 1; 
			9 : up_pc  = 1; 
			default begin end 
 		endcase // up_random
 		if (up_pc) 
 			pc <= alu[15:0];
 		if (up_cc)
 			cc <= alu[7:0];     		
 
     	@(posedge clk);
     	@(posedge clk);
 		up_a = 0;
 		up_b = 0;
 		up_dp = 0;
 		up_x = 0; 
 		up_y = 0; 
 		up_u = 0; 
 		up_s = 0; 
 		up_cc = 0; 
 		up_pc = 0; 
     			
    end
    $finish;
end

jtkcpu_regs uut_regs (
	.rst        ( rst        ),
    .clk        ( clk        ),
    .op         ( op         ), 
    .op_sel     ( op_sel     ), 
    .psh_sel    ( psh_sel    ),
    .psh_hilon  ( psh_hilon  ),
    .psh_ussel  ( psh_ussel  ),
    .pul_en     ( pul_en     ),
    .psh_mux    ( psh_mux    ),
    .psh_bit    ( psh_bit    ),
    .psh_addr   ( psh_addr   ),
    .dec_us     ( dec_us     ),
    .cc         ( cc         ),
    .pc         ( pc         ),
    .alu        ( alu        ),
    .up_a       ( up_a       ),
    .up_b       ( up_b       ),
    .up_dp      ( up_dp      ),
    .up_x       ( up_x       ),
    .up_y       ( up_y       ),
    .up_u       ( up_u       ),
    .up_s       ( up_s       ),
    .mux        ( mux        ),
    .idx_reg    ( idx_reg    ),
    .up_pul_cc  ( up_pul_cc  ),
    .up_pul_pc  ( up_pul_pc  ),
    .nx_u       ( nx_u       ),
    .nx_s       ( nx_s       )    
);


endmodule