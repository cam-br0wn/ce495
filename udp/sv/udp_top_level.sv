module udp_top_level
(
    input   logic           clk,
    input   logic           reset,

    input   logic           in_wr_en,
    input   logic [7:0]     in_din,
    input   logic           in_wr_sof,
    input   logic           in_wr_eof,
    output  logic           in_full,

    input   logic           out_rd_en,
    input   logic           out_rd_sof,
    input   logic           out_rd_eof,
    output  logic           out_empty,
    output  logic [7:0]     out_dout
);

// input fifo -> udp parser signals
logic                       input_fifo_rd_en;
logic                       input_fifo_rd_sof;
logic                       input_fifo_rd_eof;
logic   [7:0]               input_fifo_dout;
logic                       input_fifo_empty;

// udp parser -> output fifo signals
logic                       output_fifo_full;
logic                       output_fifo_empty;
logic   [7:0]               udp_parser_dout;
logic                       output_fifo_wr_en;
logic                       udp_parser_sof;
logic                       udp_parser_eof;

fifo_ctrl input_fifo (
    .reset(reset),
    .wr_clk(clk),
    .wr_en(in_wr_en),
    .wr_sof(in_wr_sof),
    .wr_eof(in_wr_eof),
    .din(in_din),
    .full(in_full),
    .rd_clk(clk),
    .rd_en(input_fifo_rd_en),
    .rd_sof(input_fifo_rd_sof),
    .rd_eof(input_fifo_rd_eof),
    .dout(input_fifo_dout),
    .empty(input_fifo_empty)
);

parse_udp parser (
    .clk(clk),
    .reset(reset),
    .input_sof(input_fifo_rd_sof),
    .input_eof(input_fifo_rd_eof),
    .in_rd_en(input_fifo_rd_en),
    .out_full(ouput_fifo_full),
    .in_empty(input_fifo_empty),
    .out_empty(output_fifo_empty),
    .data_in(input_fifo_dout),
    .data_out(udp_parser_dout),
    .out_wr_en(output_fifo_wr_en),
    .output_sof(udp_parser_sof),
    .output_eof(udp_parser_eof)
);

fifo_ctrl output_fifo (
    .reset(reset),
    .wr_clk(clk),
    .wr_en(output_fifo_wr_en),
    .wr_sof(udp_parser_sof),
    .wr_eof(udp_parser_eof),
    .din(udp_parser_dout),
    .full(output_fifo_full),
    .rd_clk(clk),
    .rd_en(out_rd_en),
    .rd_sof(out_rd_sof),
    .rd_eof(out_rd_eof),
    .dout(out_dout),
    .empty(out_empty)
);

endmodule