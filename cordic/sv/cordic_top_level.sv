module cordic_top_level
(
    // gen pins
    input   logic           clk,
    input   logic           reset,

    // theta fifo pins
    output  logic           in_full,
    input   logic           in_wr_en,
    input   logic [31:0]    theta_in,

    // sin and cos fifos' pins
    output  logic           out_empty,
    input   logic           out_rd_en,
    output  logic [15:0]    cos_dout,
    output  logic [15:0]    sin_dout
);

logic [31:0]    theta_out;
logic           theta_fifo_rd_en;
logic           theta_fifo_empty;

// cos fifo internals
logic           cos_fifo_empty;
logic           cos_fifo_full;
logic [15:0]    cos_out;
// sin fifo internals
logic           sin_fifo_empty;
logic           sin_fifo_full;
logic [15:0]    sin_out;

assign out_empty = cos_fifo_empty || sin_fifo_empty;
assign theta_fifo_rd_en = ~theta_fifo_empty;

fifo #(
    .FIFO_BUFFER_SIZE(1024),
    .FIFO_DATA_WIDTH(32)
) theta_fifo (
    .reset(reset),
    .wr_clk(clk),
    .wr_en(in_wr_en),
    .din(theta_in),
    .full(in_full),
    .rd_clk(clk),
    .rd_en(theta_fifo_rd_en),
    .dout(theta_out),
    .empty(theta_fifo_empty)
);

cordic cordic_inst (
    .clk(clk),
    .reset(reset),
    .valid_in(theta_fifo_rd_en),
    .theta_in(theta_out),
    .cos_out(cos_out),
    .sin_out(sin_out),
    .valid_out(cordic_out_wr_en)
);

fifo #(
    .FIFO_BUFFER_SIZE(1024),
    .FIFO_DATA_WIDTH(16)
) cos_fifo (
    .reset(reset),
    .wr_clk(clk),
    .wr_en(cordic_out_wr_en),
    .din(cos_out),
    .full(cos_fifo_full),
    .rd_clk(clk),
    .rd_en(out_rd_en),
    .dout(cos_dout),
    .empty(cos_fifo_empty)
);

fifo #(
    .FIFO_BUFFER_SIZE(1024),
    .FIFO_DATA_WIDTH(16)
) sin_fifo (
    .reset(reset),
    .wr_clk(clk),
    .wr_en(cordic_out_wr_en),
    .din(sin_out),
    .full(sin_fifo_full),
    .rd_clk(clk),
    .rd_en(out_rd_en),
    .dout(sin_dout),
    .empty(sin_fifo_empty)
);


endmodule