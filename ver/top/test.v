// 0000-0FFF RAM
// 1000      Simulation control
// 1001      read only, A[23:16]
// F000-FFFF ROM

module test;

reg         rst, clk, halt=0,
            nmi=0, irq=0, firq=0, dtack=0;
wire        cen, cen2;
reg  [ 7:0] ram[0:2**12-1], rom[0:2**12-1];
reg  [ 7:0] cpu_din;
wire [ 7:0] cpu_dout;
reg  [ 1:0] cen_cnt=0;
reg         sim_bad, simctrl_cs, ram_cs;
wire [23:0] cpu_addr;
integer     f, fcnt, finish_cnt=-1;

assign cen2 =  cen_cnt[0];
assign cen  = &cen_cnt[1:0];

initial begin
    clk = 0;
    forever #5 clk=~clk;
end

initial begin
    rst = 0;
    #30
    rst = 1;
    #30
    rst = 0;
    #100_000
    $display("Finish after timeout");
    $display("FAIL");
    $finish;
end

initial begin
    f = $fopen("test.bin","rb");
    fcnt=$fread(rom,f);
    $fclose(f);
    $dumpfile("test.lxt");
    $dumpvars;
    $dumpon;
end

always @(posedge clk) begin
    cen_cnt <= cen_cnt+1'd1;
    if( finish_cnt>0  ) finish_cnt <= finish_cnt - 1;
    if( finish_cnt==0 ) begin
        if( sim_bad )
            $display("FAIL");
        else
            $display("PASS");
        $finish;
    end
    if( simctrl_cs && cpu_we ) begin
        if( cpu_dout[0] ) finish_cnt <= 20;
        sim_bad <= cpu_dout[1];
        {nmi,firq,irq} <= cpu_dout[7:5];
    end
    if( ram_cs && cpu_we ) begin
        if(cen2) $display("RAM write %X -> %X", cpu_dout, cpu_addr );
        ram[cpu_addr[11:0]] <= cpu_dout;
    end
end

always @* begin
    cpu_din    = 0;
    simctrl_cs = 0;
    ram_cs     = 0;
    casez( cpu_addr[15:0] )
        16'h0???: begin
            cpu_din = ram[cpu_addr[11:0]];
            ram_cs  = 1;
        end
        16'h1??0: simctrl_cs = 1;
        16'h1??1: cpu_din = cpu_addr[23:16];
        16'hf???: cpu_din = rom[cpu_addr[11:0]];
    endcase
end

jtkcpu uut(
    .rst        ( rst       ),
    .clk        ( clk       ),
    .cen        ( cen       ),
    .cen2       ( cen2      ),

    .halt       ( halt      ),
    .nmi_n      ( ~nmi      ),
    .irq_n      ( ~irq      ),
    .firq_n     ( ~firq     ),
    .dtack      ( dtack     ),

    // memory bus
    .din        ( cpu_din   ),
    .dout       ( cpu_dout  ),
    .addr       ( cpu_addr  ),
    .we         ( cpu_we    )
);

endmodule