// vga module: VGA controller module for generating display signals
module vga (
    input i_rst,               // Reset input
    input i_clk,               // Input clock
    output wire o_dclk,        // Output display clock
    output wire o_hsync,       // Output horizontal sync
    output wire o_vsync,       // Output vertical sync
    output wire o_de,          // Output data enable
    output wire [8:0] o_x,     // Output current pixel X-coordinate
    output wire [8:0] o_y      // Output current pixel Y-coordinate
);
    // Horizontal timing parameters
    parameter HLOW = 4;        // Horizontal sync low pulse width
    parameter HBP  = 40;       // Horizontal back porch
    parameter HACT = 480;      // Horizontal active pixels
    parameter HFP  = 8;        // Horizontal front porch

    // Vertical timing parameters
    parameter VLOW = 4;        // Vertical sync low pulse width
    parameter VBP  = 12;       // Vertical back porch
    parameter VACT = 272;      // Vertical active lines
    parameter VFP  = 8;        // Vertical front porch

    // Derived timing parameters
    parameter HA = HLOW;       // Horizontal sync start
    parameter HB = HLOW + HBP; // Horizontal active start
    parameter HC = HLOW + HBP + HACT; // Horizontal active end
    parameter HD = HLOW + HBP + HACT + HFP; // Horizontal total pixels
    parameter VA = VLOW;       // Vertical sync start
    parameter VB = VLOW + VBP; // Vertical active start
    parameter VC = VLOW + VBP + VACT; // Vertical active end
    parameter VD = VLOW + VBP + VACT + VFP; // Vertical total lines

    reg [9:0] hcnt;            // Horizontal pixel counter
    reg [9:0] vcnt;            // Vertical line counter

    // Pixel and line counting process
    always @(posedge i_clk or posedge i_rst) begin
        if( i_rst ) begin
            hcnt <= 0;          // Reset horizontal counter on reset
            vcnt <= 0;          // Reset vertical counter on reset
        end else begin
            if( hcnt < HD-1 ) begin
                hcnt <= hcnt + 1'b1; // Increment horizontal counter
            end else begin
                hcnt <= 0;       // Reset horizontal counter at the end of line
                if( vcnt < VD-1 ) begin
                    vcnt <= vcnt + 1'b1; // Increment vertical counter
                end else begin
                    vcnt <= 0;   // Reset vertical counter at the end of frame
                end
            end
        end
    end

    // Output display clock (inverted input clock)
    assign o_dclk   = !i_clk;

    // Output horizontal sync (active low)
    assign o_hsync  = ( hcnt < HA )? 1'b0 : 1'b1;

    // Output vertical sync (active low)
    assign o_vsync  = ( vcnt < VA )? 1'b0 : 1'b1;

    // Output data enable (active high during active pixels)
    assign o_de     = ( (HB <= hcnt && hcnt < HC) &&
                        (VB <= vcnt && vcnt < VC) )? 1'b1 : 1'b0;

    // Output current pixel X-coordinate (relative to active area)
    assign o_x      = ( o_de == 1'b1 )? hcnt[8:0] - HB[8:0] : 1'b0;

    // Output current pixel Y-coordinate (relative to active area)
    assign o_y      = ( o_de == 1'b1 )? vcnt[8:0] - VB[8:0] : 1'b0;
endmodule