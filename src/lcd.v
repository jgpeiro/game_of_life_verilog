module vga (
    input i_rst,
    input i_clk,

    output wire o_dclk,
    output wire o_hsync,
    output wire o_vsync,
    output wire o_de,

    output wire [8:0] o_x,
    output wire [8:0] o_y
);
    parameter HLOW = 4;
    parameter HBP  = 40;
    parameter HACT = 480;
    parameter HFP  = 8;

    parameter VLOW = 4;
    parameter VBP  = 12;
    parameter VACT = 272;
    parameter VFP  = 8;
    
    parameter HA = HLOW;
    parameter HB = HLOW + HBP;
    parameter HC = HLOW + HBP + HACT;
    parameter HD = HLOW + HBP + HACT + HFP;

    parameter VA = VLOW;
    parameter VB = VLOW + VBP;
    parameter VC = VLOW + VBP + VACT;
    parameter VD = VLOW + VBP + VACT + VFP;


    reg [9:0] hcnt;
    reg [9:0] vcnt;
    always @(posedge i_clk or posedge i_rst) begin
        if( i_rst ) begin
            hcnt <= 0;
            vcnt <= 0;
        end else begin
            if( hcnt < HD-1 ) begin
                hcnt <= hcnt + 1'b1;
            end else begin
                hcnt <= 0;
                if( vcnt < VD-1 ) begin
                    vcnt <= vcnt + 1'b1;
                end else begin
                    vcnt <= 0;
                end
            end
        end
    end
    
    assign o_dclk   = !i_clk;
    assign o_hsync  = ( hcnt < HA )? 1'b0 : 1'b1;
    assign o_vsync  = ( vcnt < VA )? 1'b0 : 1'b1;
    assign o_de     = ( (HB <= hcnt && hcnt < HC) &&
                        (VB <= vcnt && vcnt < VC) )? 1'b1 : 1'b0;
    
    assign o_x      = ( o_de == 1'b1 )? hcnt[8:0] - HB[8:0] : 1'b0;
    assign o_y      = ( o_de == 1'b1 )? vcnt[8:0] - VB[8:0] : 1'b0;

endmodule