// `include "cordic_macros.sv"

module cordic
(
    input           clk,
    input           reset,
    input           valid_in,
    input  [31:0]   theta_in,
    output          valid_out,
    output [15:0]   cos_out,
    output [15:0]   sin_out
);

// cordic lookup table
localparam logic[15:0][15:0] CORDIC_TABLE = '{16'h3243, 16'h1DAC, 16'h0FAD, 16'h07F5, 
                                        16'h03FE, 16'h01FF, 16'h00FF, 16'h007F, 
                                        16'h003F, 16'h001F, 16'h000F, 16'h0007, 
                                        16'h0003, 16'h0001, 16'h0000, 16'h0000};
typedef logic[15:0]     short_t;
logic   [31:0]          r_bound_1, r_bound_2, int_x;
logic   [16:1][15:0]    k_stage, c_stage;
logic   [16:0][15:0]    x_stage, y_stage, z_stage;
logic   [16:0]          valid_stage;

always_comb begin
    y_stage[0] = '0;
    valid_stage[0] = valid_in;

    // first bounds check
    if ($signed(theta_in) > 16'hc90f) begin
        r_bound_1 = $signed(theta_in) - `TWO_PI;
    end else if ($signed(theta_in) < (-1 * `PI)) begin
        r_bound_1 = $signed(theta_in) + `TWO_PI;
    end else begin
        r_bound_1 = theta_in;
    end

    // second bounds check
    if ($signed(r_bound_1) > `HALF_PI) begin
        r_bound_2 = $signed(r_bound_1) - `PI;
        int_x = -1 * `CORDIC_1K;
    end 
    else if ($signed(r_bound_1) < (-1 * `HALF_PI)) begin
        r_bound_2 = $signed(r_bound_1) + `PI;
        int_x = -1 * `CORDIC_1K;
    end
    else begin
        r_bound_2 = r_bound_1;
        int_x = `CORDIC_1K;
    end

    z_stage[0] = r_bound_2[15:0];
    x_stage[0] = int_x[15:0];

end

genvar i;
generate
    for (i = 0; i < 16; i++) begin
        cordic_stage cordic_stage_inst (
            .clk(clk), 
            .reset(reset), 
            .valid_in(valid_stage[i]), 
            .k_in(short_t'(i)), 
            .c_in(CORDIC_TABLE[i]), 
            .x_in(x_stage[i]), 
            .y_in(y_stage[i]), 
            .z_in(z_stage[i]), 
            .valid_out(valid_stage[i+1]), 
            .x_out(x_stage[i+1]),
            .y_out(y_stage[i+1]),
            .z_out(z_stage[i+1])
        );
    end
endgenerate

assign cos_out = x_stage[16];
assign sin_out = y_stage[16];
assign valid_out = valid_stage[16];

endmodule