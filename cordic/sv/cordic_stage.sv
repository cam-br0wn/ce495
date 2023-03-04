module cordic_stage
(
    input           clk,
    input           reset,
    
    input           valid_in,
    input [15:0]    k_in,
    input [15:0]    c_in,
    input [15:0]    x_in,
    input [15:0]    y_in,
    input [15:0]    z_in,

    output          valid_out,
    output [15:0]   x_out,
    output [15:0]   y_out,
    output [15:0]   z_out
);

logic           valid_q;
logic   [15:0]  d, x_q, y_q, z_q, y_shifted, x_shifted, y_xor_d, x_xor_d, y_minus_d, x_minus_d;
assign d = ($signed(z_in) >= $signed(0)) ? 16'h0000 : 16'hffff;
assign x_out = x_q;
assign y_out = y_q;
assign z_out = z_q;
assign valid_out = valid_q;

always_ff @( posedge clk or posedge reset ) begin : stage
    if (reset) begin
        x_q <= '0;
        y_q <= '0;
        z_q <= '0;
        valid_q <= '0;
    end
    else begin
        x_q <= x_in + ~(y_minus_d) + 16'b1;
        y_q <= y_in + x_minus_d;
        z_q <= $signed($signed(z_in) - $signed($signed(c_in ^ d) - $signed(d)));
        valid_q <= valid_in;
    end
end

always_comb begin
    y_shifted = $signed(y_in) >>> k_in;
    y_xor_d = y_shifted ^ d;
    y_minus_d = y_xor_d + ~(d) + 16'b1;

    x_shifted = $signed(x_in) >>> k_in;
    x_xor_d = x_shifted ^ d;
    x_minus_d = x_xor_d + ~(d) + 16'b1;
end

endmodule