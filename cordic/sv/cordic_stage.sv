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
logic   [15:0]  d, x_q, y_q, z_q;
assign d = ($signed(z_in) >= 0) ? 16'h0000 : 16'hffff;
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
        x_q <= $signed(x_in) - $signed(((y_in >>> k_in) ^ d) - $signed(d));
        y_q <= $signed(y_in) - $signed(((x_in >>> k_in) ^ d) - $signed(d));
        z_q <= $signed(z_in) - $signed(((c_in ^ d) - $signed(d));
        valid_q <= valid_in;
    end
end

endmodule