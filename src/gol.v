/*
This `gol` module implements the Game of Life engine. It iterates over each cell in the grid, calculates the number of live neighbors, and determines the next state of each cell based on the Game of Life rules.

The module has the following parameters:
- `WIDTH`: The width of the grid (default: 480)
- `HEIGHT`: The height of the grid (default: 272)

The module has the following inputs and outputs:
- `rst`: Reset input
- `clk`: Input clock
- `addr`: Output address for accessing the framebuffer
- `din`: Input data from the framebuffer
- `dout`: Output data to the framebuffer
- `write`: Output write enable signal for the framebuffer
- `done`: Output done signal indicating the completion of a generation

The module uses a state machine to control the execution flow. The states are:
- `STATE_INIT`: Initialization state where the grid is randomly populated
- `STATE_INIT_DONE`: Initialization done state
- `STATE_NEXT_CELL`: State to move to the next cell
- `STATE_SET_READ_ADDR`: State to set the read address for accessing neighbor cells
- `STATE_WAIT_FOR_READ`: State to wait for the read operation
- `STATE_READ`: State to read the neighbor cell states
- `STATE_SET_WRITE_ADDR`: State to set the write address for updating the current cell
- `STATE_WRITE`: State to write the updated cell state to the framebuffer

The module uses an LFSR (Linear Feedback Shift Register) to generate random initial states for the cells. It iterates over each cell in the grid, reads the states of the neighboring cells, and applies the Game of Life rules to determine the next state of each cell. The updated cell states are then written back to the framebuffer.

The `done` signal is toggled when a complete generation has been processed, indicating that the framebuffer contains the updated cell states.

This module forms the core of the Game of Life implementation, handling the game logic and updating the cell states in the framebuffer.
*/
module gol#(
    parameter WIDTH = 480,     // Grid width
    parameter HEIGHT = 272     // Grid height
)(
    input   rst,               // Reset input
    input   clk,               // Input clock
    output reg [16:0]   addr,  // Output address for framebuffer
    input               din,   // Input data from framebuffer
    output reg          dout,  // Output data to framebuffer
    output reg          write, // Output write enable signal for framebuffer
    output reg          done   // Output done signal indicating completion of a generation
);
    // Instantiate LFSR module for random number generation
    wire rand;
    lfsr lfsr0(
        .i_rst_n(1'b1),        // Disable reset to create different worlds each reset
        .i_clk(clk),           // Connect input clock
        .o_data(rand)          // Output random data
    );

    // State machine parameters
    parameter STATE_INIT            = 4'd0; // Initialization state
    parameter STATE_INIT_DONE       = 4'd1; // Initialization done state
    parameter STATE_NEXT_CELL       = 4'd2; // Next cell state
    parameter STATE_SET_READ_ADDR   = 4'd3; // Set read address state
    parameter STATE_WAIT_FOR_READ   = 4'd4; // Wait for read state
    parameter STATE_READ            = 4'd5; // Read state
    parameter STATE_SET_WRITE_ADDR  = 4'd6; // Set write address state
    parameter STATE_WRITE           = 4'd7; // Write state

    reg [3:0] state;           // Current state
    reg [8:0] x;               // Current cell X-coordinate
    reg [8:0] y;               // Current cell Y-coordinate
    reg [1:0] i;               // Neighbor cell row offset
    reg [1:0] j;               // Neighbor cell column offset
    reg [2:0] neighbours;      // Number of live neighbors
    reg center;                // Current cell state

    // Game of Life state machine process
    always @(negedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;          // Reset state to initialization
            x <= 0;              // Reset X-coordinate
            y <= 0;              // Reset Y-coordinate
            i <= 0;              // Reset row offset
            j <= 0;              // Reset column offset
            neighbours <= 0;     // Reset number of live neighbors
            center <= 0;         // Reset current cell state
            write <= 0;          // Reset write enable signal
            dout <= 0;           // Reset output data
            done <= 0;           // Reset done signal
            addr <= 0;           // Reset address
        end else begin
            case(state)
                STATE_INIT: begin
                    state <= STATE_INIT; // Stay in initialization state
                    if( x < WIDTH-2 ) begin
                        x <= x + 1'b1; // Increment X-coordinate
                    end else begin
                        x <= 0;        // Reset X-coordinate
                        if( y < HEIGHT-2 ) begin
                            y <= y + 1'b1; // Increment Y-coordinate
                        end else begin
                            y <= 0;    // Reset Y-coordinate
                            state <= STATE_INIT_DONE; // Move to initialization done state
                        end
                    end
                    addr <= (y+1)*WIDTH + (x+1); // Calculate address for current cell
                    dout <= rand;      // Set output data to random value
                    write <= 1;        // Enable write to framebuffer
                    done <= 1;         // Set done signal
                end
                STATE_INIT_DONE: begin
                    write <= 0;        // Disable write to framebuffer
                    done <= 0;         // Clear done signal
                    state <= STATE_NEXT_CELL; // Move to next cell state
                end
                STATE_NEXT_CELL: begin
                    if( j < 2 ) begin
                        j <= j + 1'b1; // Increment column offset
                    end else begin
                        j <= 0;        // Reset column offset
                        if( i < 2 ) begin
                            i <= i + 1'b1; // Increment row offset
                        end else begin
                            i <= 0;    // Reset row offset
                            if( x < WIDTH-2 ) begin
                                x <= x + 1'b1; // Increment X-coordinate
                            end else begin
                                x <= 0; // Reset X-coordinate
                                if( y < HEIGHT-2 ) begin
                                    y <= y + 1'b1; // Increment Y-coordinate
                                end else begin
                                    y <= 0; // Reset Y-coordinate
                                    done <= !done; // Toggle done signal
                                end
                            end
                        end
                    end
                    write <= 0;        // Disable write to framebuffer
                    state <= STATE_SET_READ_ADDR; // Move to set read address state
                end
                STATE_SET_READ_ADDR: begin
                    addr <= (y+i)*WIDTH + (x+j); // Calculate address for neighbor cell
                    state <= STATE_WAIT_FOR_READ; // Move to wait for read state
                end
                STATE_WAIT_FOR_READ: begin
                    state <= STATE_READ; // Move to read state
                end
                STATE_READ: begin
                    if( i == 1 && j == 1 ) begin
                        center <= din; // Store current cell state
                    end else begin
                        neighbours <= neighbours + din; // Increment number of live neighbors
                    end
                    if( i == 2 && j == 2 ) begin
                        state <= STATE_SET_WRITE_ADDR; // Move to set write address state
                    end else begin
                        state <= STATE_NEXT_CELL; // Move to next cell state
                    end
                end
                STATE_SET_WRITE_ADDR: begin
                    addr <= (y+1)*WIDTH + (x+1); // Calculate address for current cell
                    if( center ) begin
                        if( neighbours < 2 ) begin
                            dout <= 0; // Cell dies due to underpopulation
                        end else if( neighbours == 2 || neighbours == 3 ) begin
                            dout <= 1; // Cell survives
                        end else begin
                            dout <= 0; // Cell dies due to overpopulation
                        end
                    end else begin
                        if( neighbours == 3 ) begin
                            dout <= 1; // Cell is born
                        end else begin
                            dout <= 0; // Cell remains dead
                        end
                    end
                    center <= 0;       // Reset current cell state
                    neighbours <= 0;   // Reset number of live neighbors
                    state <= STATE_WRITE; // Move to write state
                end
                STATE_WRITE: begin
                    write <= 1;        // Enable write to framebuffer
                    state <= STATE_NEXT_CELL; // Move to next cell state
                end
            endcase
        end
    end
endmodule