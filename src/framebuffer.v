module double_dual_port_framebuffer(
    input   rst,
    input   clk,
    
    // A
    input [16:0] addra,
    input din,
    output douta,
    input wrea,
    
    // B
    input [16:0] addrb,
    output doutb,
    
    input ab
);
    wire wrea1;
    wire douta_o1;
    wire doutb_o1;

    wire wrea2;
    wire douta_o2;
    wire doutb_o2;

    assign wrea1 = (ab==0)? 0    : wrea;
    assign wrea2 = (ab==0)? wrea : 0;

    assign douta = (ab==0)? douta_o1 : douta_o2;
    assign doutb = (ab==0)? doutb_o1 : doutb_o2;

    Gowin_DPB fb1(
        .reseta(rst),
        .resetb(rst),

        .clka(clk),
        .clkb(clk),
        
        .ocea(1'b1),
        .oceb(1'b1),

        .cea(1'b1),
        .ceb(1'b1),

        .wrea(wrea1),
        .wreb(1'b0),

        .ada(addra),
        .adb(addrb),

        .dina(din),
        .dinb(1'b0),

        .douta(douta_o1),
        .doutb(doutb_o1)
    );

    Gowin_DPB fb2(
        .reseta(rst),
        .resetb(rst),

        .clka(clk),
        .clkb(clk),
        
        .ocea(1'b1),
        .oceb(1'b1),

        .cea(1'b1),
        .ceb(1'b1),

        .wrea(wrea2),
        .wreb(1'b0),

        .ada(addra),
        .adb(addrb),

        .dina(din),
        .dinb(1'b0),

        .douta(douta_o2),
        .doutb(doutb_o2)
    );

endmodule