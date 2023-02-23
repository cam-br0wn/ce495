
module grayscale_cam (
    output logic        in_rd_en,
    input  logic        in_empty,
    input  logic [23:0] in_dout,
    output logic        out_wr_en,
    input  logic        out_full,
    output logic [7:0]  out_din
);

always_comb begin
    in_rd_en  = ~in_empty;
    out_wr_en = ~out_full;
    out_din   = 8'(($unsigned({2'b0, in_dout[23:16]}) + $unsigned({2'b0, in_dout[15:8]}) + $unsigned({2'b0, in_dout[7:0]})) / $unsigned(10'd3));
end

endmodule
