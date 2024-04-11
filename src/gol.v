module gol#(
    parameter WIDTH = 480,
    parameter HEIGHT = 272
)(
    input   rst,
    input   clk,
    output reg [16:0]   addr,
    input               din,
    output reg          dout,
    output reg          write,
    output reg          done
);

    // Randomize world
    wire rand;
    lfsr lfsr0(
        .i_rst_n(1'b1), // Disable reset to create different worlds each reset
        //.i_rst_n(!rst),
        .i_clk(clk),
        .o_data(rand)
    );

    parameter STATE_INIT            = 4'd0;
    parameter STATE_INIT_DONE       = 4'd1;
    parameter STATE_NEXT_CELL       = 4'd2;
    parameter STATE_SET_READ_ADDR   = 4'd3;
    parameter STATE_WAIT_FOR_READ   = 4'd4;
    parameter STATE_READ            = 4'd5;
    parameter STATE_SET_WRITE_ADDR  = 4'd6;
    parameter STATE_WRITE           = 4'd7;
    
    reg [3:0] state;
    reg [8:0] x;
    reg [8:0] y;
    reg [1:0] i;
    reg [1:0] j;
    reg [2:0] neighbours;
    reg center;

    always @(negedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            x <= 0;
            y <= 0;
            i <= 0;
            j <= 0;
            neighbours <= 0;
            center <= 0;
            write <= 0;
            dout <= 0;
            done <= 0;
            addr <= 0;
        end else begin
            case(state)
                STATE_INIT: begin
                    state <= STATE_INIT;
                    if( x < WIDTH-2 ) begin
                        x <= x + 1'b1;
                    end else begin
                        x <= 0;
                        if( y < HEIGHT-2 ) begin
                            y <= y + 1'b1;
                        end else begin
                            y <= 0;
                            state <= STATE_INIT_DONE;
                        end
                    end
                    addr <= (y+1)*WIDTH + (x+1);
                    dout <= rand;
                    write <= 1;
                    done <= 1;
                end
                STATE_INIT_DONE: begin
                    write <= 0;
                    done <= 0;
                    state <= STATE_NEXT_CELL;
                end

                STATE_NEXT_CELL: begin
                    if( j < 2 ) begin
                        j <= j + 1'b1;
                    end else begin
                        j <= 0;
                        if( i < 2 ) begin
                            i <= i + 1'b1;
                        end else begin
                            i <= 0;
                            if( x < WIDTH-2 ) begin
                                x <= x + 1'b1;
                            end else begin
                                x <= 0;
                                if( y < HEIGHT-2 ) begin
                                    y <= y + 1'b1;
                                end else begin
                                    y <= 0;
                                    done <= !done;
                                end
                            end
                        end
                    end
                    write <= 0;
                    state <= STATE_SET_READ_ADDR;
                end

                STATE_SET_READ_ADDR: begin
                    addr <= (y+i)*WIDTH + (x+j);
                    state <= STATE_WAIT_FOR_READ;
                end

                STATE_WAIT_FOR_READ: begin
                    state <= STATE_READ;
                end

                STATE_READ: begin
                    if( i == 1 && j == 1 ) begin
                        center <= din;
                    end else begin
                        neighbours <= neighbours + din;
                    end
                    if( i == 2 && j == 2 ) begin
                        state <= STATE_SET_WRITE_ADDR;
                    end else begin
                        state <= STATE_NEXT_CELL;
                    end
                end

                STATE_SET_WRITE_ADDR: begin
                    addr <= (y+1)*WIDTH + (x+1);
                    if( center ) begin
                        if( neighbours < 2 ) begin
                            dout <= 0; // No food
                        end else if( neighbours == 2 || neighbours == 3 ) begin
                            dout <= 1; // Alive
                        end else begin
                            dout <= 0; // Overpopulation
                        end
                    end else begin
                        if( neighbours == 3 ) begin
                            dout <= 1; // Born
                        end else begin
                            dout <= 0;
                        end
                    end
                    center <= 0;
                    neighbours <= 0;
                    state <= STATE_WRITE;
                end

                STATE_WRITE: begin
                    write <= 1;
                    state <= STATE_NEXT_CELL;
                end
            endcase
        end
    end
endmodule

