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
    op_sel = 8'h88; // 
    psh_sel = 8'b00010000; // d16, h10
    psh_ussel = 0; // u 
    psh_hilon = 0; // hi
    pul_en = 0;
    dec_us = 0;
    alu = 127;

    #5 rst = 0;
    repeat (30) begin
    	// $display("");
 		
     			
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
    .acc        ( acc        ),
    .up_pul_cc  ( up_pul_cc  ),
    .up_pul_pc  ( up_pul_pc  ),
    .nx_u       ( nx_u       ),
    .nx_s       ( nx_s       )    
);

jtkcpu_pshpul uut_pshpul(
    .rst        ( rst        ),
    .clk        ( clk        ),
    .op         ( op         ), 
    .pul_go     ( pul_go     ),
    .psh_go     ( psh_go     ),
    .psh_bit    ( psh_bit    ),
    .hi_lon     ( hi_lon     ),
    .pul_en     ( pul_en     ),
    .dec_us     ( dec_us     ),
    .psh_sel    ( psh_sel    ),
    .idle       ( idle       ),
    .us_sel     ( us_sel     ),
    .postbyte   ( postbyte   )
);


endmodule