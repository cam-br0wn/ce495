module fifo_ctrl #(
    parameter DATA_FIFO_WIDTH   = 8,
    parameter FLAG_FIFO_WIDTH   = 2,
    parameter FIFO_BUFFER_SIZE  = 1024
)
(
    input  logic        reset,

    input  logic        wr_clk,
    input  logic        wr_en,
    input  logic        wr_sof,
    input  logic        wr_eof,
    input  logic [7:0]  din,
    output logic        full,

    input  logic        rd_clk,
    input  logic        rd_en,
    output logic        rd_sof,
    output logic        rd_eof,
    output logic [7:0]  dout,
    output logic        empty
);

logic   data_empty, flag_empty;
logic   data_full, flag_full;

fifo #(
    .FIFO_DATA_WIDTH(DATA_FIFO_WIDTH),
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE)
) data_fifo (
    .reset(reset),
    .wr_clk(wr_clk),
    .wr_en(wr_en),
    .din(din),
    .full(data_full),
    .rd_clk(rd_clk),
    .rd_en(rd_en),
    .dout(dout),
    .empty(data_empty)
);

fifo #(
    .FIFO_DATA_WIDTH(FLAG_FIFO_WIDTH),
    .FIFO_BUFFER_SIZE(FIFO_BUFFER_SIZE)
) flag_fifo (
    .reset(reset),
    .wr_clk(wr_clk),
    .wr_en(wr_en),
    .din({wr_sof, wr_eof}),
    .full(flag_full),
    .rd_clk(rd_clk),
    .rd_en(rd_en),
    .dout({rd_sof, rd_eof}),
    .empty(flag_empty)
);

assign empty = data_empty || flag_empty;
assign full = data_full || flag_full;

endmodule