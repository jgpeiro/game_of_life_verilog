module lfsr(
    input   i_rst_n,
    input   i_clk,
    output reg o_data
);
    // 32-bit LFSR. Polynomial: (x^32 + x^22 + x^2 + x + 1)
    reg [31:0] cnt;
    always @(posedge i_clk or negedge i_rst_n)
    begin
        if( !i_rst_n ) begin
            cnt <= 0;//32'h12345678;
            o_data <= 0;
        end else begin
            cnt <= {cnt[30:0], cnt[0] ^ cnt[22] ^ cnt[30] ^ cnt[31]};
            o_data <= cnt[0];
        end
    end
endmodule