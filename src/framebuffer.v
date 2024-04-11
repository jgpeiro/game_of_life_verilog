// double_dual_port_framebuffer module: Dual-port framebuffer module with double buffering
module double_dual_port_framebuffer(
    input   rst,               // Reset input
    input   clk,               // Input clock

    // Port A
    input [16:0] addra,        // Address input for port A
    input din,                 // Data input for port A
    output douta,              // Data output from port A
    input wrea,                // Write enable input for port A

    // Port B
    input [16:0] addrb,        // Address input for port B
    output doutb,              // Data output from port B

    input ab                   // A/B selection input
);
    wire wrea1;                // Write enable signal for framebuffer 1
    wire douta_o1;             // Data output from framebuffer 1 port A
    wire doutb_o1;             // Data output from framebuffer 1 port B
    wire wrea2;                // Write enable signal for framebuffer 2
    wire douta_o2;             // Data output from framebuffer 2 port A
    wire doutb_o2;             // Data output from framebuffer 2 port B

    // Assign write enable signals based on A/B selection
    assign wrea1 = (ab==0)? 0    : wrea;
    assign wrea2 = (ab==0)? wrea : 0;

    // Assign data outputs based on A/B selection
    assign douta = (ab==0)? douta_o1 : douta_o2;
    assign doutb = (ab==0)? doutb_o1 : doutb_o2;

    // Instantiate framebuffer 1 (Gowin_DPB primitive)
    Gowin_DPB fb1(
        .reseta(rst),          // Reset input for port A
        .resetb(rst),          // Reset input for port B
        .clka(clk),            // Clock input for port A
        .clkb(clk),            // Clock input for port B

        .ocea(1'b1),           // Output clock enable for port A (always enabled)
        .oceb(1'b1),           // Output clock enable for port B (always enabled)
        .cea(1'b1),            // Clock enable for port A (always enabled)
        .ceb(1'b1),            // Clock enable for port B (always enabled)
        .wrea(wrea1),          // Write enable input for port A
        .wreb(1'b0),           // Write enable input for port B (always disabled)
        .ada(addra),           // Address input for port A
        .adb(addrb),           // Address input for port B
        .dina(din),            // Data input for port A
        .dinb(1'b0),           // Data input for port B (unused)
        .douta(douta_o1),      // Data output from port A
        .doutb(doutb_o1)       // Data output from port B
    );

    // Instantiate framebuffer 2 (Gowin_DPB primitive)
    Gowin_DPB fb2(
        .reseta(rst),          // Reset input for port A
        .resetb(rst),          // Reset input for port B
        .clka(clk),            // Clock input for port A
        .clkb(clk),            // Clock input for port B

        .ocea(1'b1),           // Output clock enable for port A (always enabled)
        .oceb(1'b1),           // Output clock enable for port B (always enabled)
        .cea(1'b1),            // Clock enable for port A (always enabled)
        .ceb(1'b1),            // Clock enable for port B (always enabled)
        .wrea(wrea2),          // Write enable input for port A
        .wreb(1'b0),           // Write enable input for port B (always disabled)
        .ada(addra),           // Address input for port A
        .adb(addrb),           // Address input for port B
        .dina(din),            // Data input for port A
        .dinb(1'b0),           // Data input for port B (unused)
        .douta(douta_o2),      // Data output from port A
        .doutb(doutb_o2)       // Data output from port B
    );
endmodule