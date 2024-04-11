// div module: Clock divider module
module div #(
  parameter RATIO = 8          // Default clock division ratio
)(
    input   i_rst_n,           // Reset input (active low)
    input   i_clk,             // Input clock
    output reg o_clk           // Output divided clock
);
    reg [7:0] cnt;             // Counter for clock division

    // Clock division process
    always @(posedge i_clk or negedge i_rst_n)
    begin
        if( !i_rst_n ) begin
            cnt <= 0;           // Reset counter on reset
        end else begin
            if( cnt + 1 < RATIO ) begin
                cnt <= cnt + 1'b1;  // Increment counter if not reached ratio
            end else begin
                cnt <= 0;           // Reset counter when reached ratio
                o_clk <= !o_clk;    // Toggle output clock
            end
        end
    end
endmodule