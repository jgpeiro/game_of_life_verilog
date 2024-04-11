/*
The `TOP` module is the top-level module of the Game of Life implementation on an FPGA. It instantiates and connects all the necessary submodules to create a complete system.

The module has the following inputs and outputs:
- `CLK_IN`: Input clock signal
- `BUTTON1`: Reset button input
- `BUTTON2`: Unused button input
- `LCD_CLK`: LCD clock output
- `LCD_VSYNC`: LCD vertical sync output
- `LCD_HSYNC`: LCD horizontal sync output
- `LCD_DE`: LCD data enable output
- `LCD_R`: LCD red color output (5 bits)
- `LCD_G`: LCD green color output (6 bits)
- `LCD_B`: LCD blue color output (5 bits)

The `TOP` module performs the following functions:

1. Reset Generation:
   - The `BUTTON1` input is used as the reset signal (`rst`).
   - The `BUTTON2` input is unused.

2. Clock Generation:
   - The input clock (`CLK_IN`) is assigned to the internal clock signal (`clk`).
   - The `div` module is instantiated to generate a divided clock (`lcd_clk`) for the LCD.
   - The `gol_clk` and `fb_clk` signals are assigned the same clock as `clk` (no division).

3. Game of Life Engine:
   - The `gol` module is instantiated to implement the Game of Life logic.
   - It takes the `rst`, `gol_clk`, and framebuffer signals as inputs and outputs the updated cell states and control signals.

4. Framebuffer:
   - The `double_dual_port_framebuffer` module is instantiated to store the cell states.
   - It has two ports (A and B) for simultaneous read and write operations.
   - Port A is connected to the `gol` module for updating cell states.
   - Port B is connected to the VGA controller for displaying the cell states.

5. VGA Controller:
   - The `vga` module is instantiated to generate the necessary timing signals for displaying the cell states on an LCD screen.
   - It takes the `rst` and `lcd_clk` signals as inputs and outputs the `LCD_CLK`, `LCD_VSYNC`, `LCD_HSYNC`, `LCD_DE`, `x`, and `y` signals.

6. Display:
   - The framebuffer address for the current pixel is calculated based on the `x` and `y` coordinates from the VGA controller.
   - The color outputs (`LCD_R`, `LCD_G`, `LCD_B`) are assigned based on the cell state read from the framebuffer.
*/

// TOP module: Top-level module that instantiates and connects all the submodules
module TOP
(
    input           CLK_IN,     // Clock input
    input           BUTTON1,    // Reset button input
    input           BUTTON2,    // Unused button input
    output          LCD_CLK,    // LCD clock output
    output          LCD_VSYNC,  // LCD vertical sync output
    output          LCD_HSYNC,  // LCD horizontal sync output
    output          LCD_DE,     // LCD data enable output
    output  [4:0]   LCD_R,      // LCD red color output
    output  [5:0]   LCD_G,      // LCD green color output
    output  [4:0]   LCD_B       // LCD blue color output
);
    // Reset generation
    wire rst = BUTTON1;         // Assign reset signal to BUTTON1
    wire btn2 = BUTTON2;        // Unused button input

    // Clock generation
    wire clk = CLK_IN;          // Assign input clock to internal clock signal
    wire lcd_clk;               // LCD clock signal

    // Instantiate clock divider module to generate LCD clock
    div #(
        .RATIO(5)               // Set clock division ratio to 5
    )div0(
        .i_rst_n(!rst),         // Connect reset signal (active low)
        .i_clk(clk),            // Connect input clock
        .o_clk(lcd_clk)         // Output divided clock for LCD
    );

    wire gol_clk;               // Game of Life clock signal
    wire fb_clk;                // Framebuffer clock signal

    // Assign Game of Life and framebuffer clocks to input clock (no division)
    assign gol_clk = clk;
    assign fb_clk = clk;

    // Game of Life engine signals
    wire ab;                    // Framebuffer A/B selection signal
    wire wrea;                  // Write enable signal for framebuffer
    wire [16:0] ada_i;          // Address input for framebuffer port A
    wire [16:0] adb_i;          // Address input for framebuffer port B
    wire dina_i;                // Data input for framebuffer port A
    wire douta_o;               // Data output from framebuffer port A
    wire doutb_o;               // Data output from framebuffer port B

    // Instantiate Game of Life engine module
    gol #(
        .WIDTH(480),            // Set grid width to 480 cells
        .HEIGHT(272)            // Set grid height to 272 cells
    ) gol0 (
        .rst(rst),              // Connect reset signal
        .clk(gol_clk),          // Connect Game of Life clock
        .addr(ada_i),           // Connect address output to framebuffer port A
        .din(douta_o),          // Connect data input from framebuffer port A
        .dout(dina_i),          // Connect data output to framebuffer port A
        .write(wrea),           // Connect write enable signal to framebuffer
        .done(ab)               // Connect done signal to framebuffer A/B selection
    );

    // Instantiate double dual-port framebuffer module
    double_dual_port_framebuffer fb0(
        .rst(rst),              // Connect reset signal
        .clk(fb_clk),           // Connect framebuffer clock

        // Port A
        .addra(ada_i),          // Connect address input for port A
        .din(dina_i),           // Connect data input for port A
        .douta(douta_o),        // Connect data output from port A
        .wrea(wrea),            // Connect write enable signal for port A

        // Port B
        .addrb(adb_i),          // Connect address input for port B
        .doutb(doutb_o),        // Connect data output from port B

        .ab(ab)                 // Connect A/B selection signal
    );

    // Display signals
    wire [8:0] x;               // X-coordinate of current pixel
    wire [8:0] y;               // Y-coordinate of current pixel

    // Instantiate VGA controller module
    vga vga0(
        .i_rst(rst),            // Connect reset signal
        .i_clk(lcd_clk),        // Connect LCD clock
        .o_dclk(LCD_CLK),       // Output LCD clock
        .o_hsync(LCD_VSYNC),    // Output LCD vertical sync
        .o_vsync(LCD_HSYNC),    // Output LCD horizontal sync
        .o_de(LCD_DE),          // Output LCD data enable
        .o_x(x),                // Output current pixel X-coordinate
        .o_y(y)                 // Output current pixel Y-coordinate
    );

    // Calculate framebuffer address for current pixel
    assign adb_i = y*9'd480 + x;

    // Assign color outputs based on framebuffer data
    assign LCD_R = doutb_o? 5'h1F : 5'h00;  // Set red color to maximum or zero
    assign LCD_G = doutb_o? 6'h3F : 6'h00;  // Set green color to maximum or zero
    assign LCD_B = doutb_o? 5'h1F : 5'h00;  // Set blue color to maximum or zero
endmodule