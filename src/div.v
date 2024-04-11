module div #(
  parameter RATIO = 8
)(
    input   i_rst_n,
    input   i_clk,
    
    output reg o_clk
);
    reg [7:0] cnt;
    always @(posedge i_clk or negedge i_rst_n)
    begin
        if( !i_rst_n ) begin
            cnt <= 0;
        end else begin
            if( cnt + 1 < RATIO ) begin
                cnt <= cnt + 1'b1;
            end else begin
                cnt <= 0;
                o_clk <= !o_clk;
            end
        end
    end
endmodule