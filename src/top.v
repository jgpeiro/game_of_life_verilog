module TOP
(
    input           CLK_IN,
    input           BUTTON1,
    input           BUTTON2,

    output          LCD_CLK,
    output          LCD_VSYNC,
    output          LCD_HSYNC,
    output          LCD_DE,

    output  [4:0]   LCD_R,
    output  [5:0]   LCD_G,
    output  [4:0]   LCD_B
);
    // Reset generation
    wire rst = BUTTON1;
    wire btn2 = BUTTON2;

    // Clock generation
    wire clk = CLK_IN;
    wire lcd_clk;
    div #(
        .RATIO(5)
    )div0(
        .i_rst_n(!rst),
        .i_clk(clk),
        .o_clk(lcd_clk)
    );
    wire gol_clk;
    wire fb_clk;
    /*Gowin_rPLL your_instance_name(
        .clkin(clk),
        .clkout(gol_clk)
    );*/
    assign gol_clk = clk;
    assign fb_clk = clk;

    // Game Of Life engine
    wire ab;
    wire wrea;
    wire [16:0] ada_i;
    wire [16:0] adb_i;
    wire dina_i;
    wire douta_o;
    wire doutb_o;

    gol #(
        .WIDTH(480),
        .HEIGHT(272)
    ) gol0 (
        .rst(rst),
        .clk(gol_clk),
        .addr(ada_i),
        .din(douta_o),
        .dout(dina_i),
        .write(wrea),
        .done(ab)
    );

    // Framebuffer
    double_dual_port_framebuffer fb0(
        .rst(rst),
        .clk(fb_clk),
        
        // A
        .addra(ada_i),
        .din(dina_i),
        .douta(douta_o),
        .wrea(wrea),
        
        // B
        .addrb(adb_i),
        .doutb(doutb_o),
        
        .ab(ab)
    );
    
    // Display
    wire [8:0] x;
    wire [8:0] y;
    vga vga0(
        .i_rst(rst),
        .i_clk(lcd_clk),

        .o_dclk(LCD_CLK),
        .o_hsync(LCD_VSYNC),
        .o_vsync(LCD_HSYNC),
        .o_de(LCD_DE),

        .o_x(x),
        .o_y(y)
    );

    assign adb_i = y*9'd480 + x;
    
    assign LCD_R = doutb_o? 5'h1F : 5'h00;
    assign LCD_G = doutb_o? 6'h3F : 6'h00;
    assign LCD_B = doutb_o? 5'h1F : 5'h00;
endmodule