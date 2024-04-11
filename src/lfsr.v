// lfsr module: Linear feedback shift register module for random number generation
module lfsr(
    input   i_rst_n,           // Reset input (active low)
    input   i_clk,             // Input clock
    output reg o_data          // Output random data
);
    // 32-bit LFSR with polynomial: (x^32 + x^22 + x^2 + x + 1)
    reg [31:0] cnt;            // LFSR counter

    // LFSR process
    always @(posedge i_clk or negedge i_rst_n)
    begin
        if( !i_rst_n ) begin
            cnt <= 0;           // Reset LFSR counter on reset
            o_data <= 0;        // Reset output data
        end else begin
            // Update LFSR counter based on polynomial feedback
            cnt <= {cnt[30:0], cnt[0] ^ cnt[22] ^ cnt[30] ^ cnt[31]};
            o_data <= cnt[0];   // Output LSB of LFSR counter as random data
        end
    end
endmodule