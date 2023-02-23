
module edge_detect_top #(
    parameter IMG_WIDTH = 720,
    parameter IMG_HEIGHT = 540
) (
    input  logic        clock,
    input  logic        reset,
    output logic        in_full,
    input  logic        in_wr_en,
    input  logic [23:0] in_din,
    output logic        out_empty,
    input  logic        out_rd_en,
    output logic [23:0]  out_dout
);

// fifo A signals
logic [23:0]    fifo_A_out;
logic           A_empty;
logic           A_rd_en;
logic           A_full;

// grayscale signals
logic [7:0]     grayscale_out;

// fifo B signals
logic [8:0]     fifo_B_out;
logic           B_empty;
logic           B_rd_en;
logic           B_wr_en;
logic           B_full;

// internal signals to connect components
logic [7:0]     sreg_2_2_out, sreg_2_1_out, sreg_2_0_out;
logic [7:0]     sreg_line1_out;
logic [7:0]     sreg_1_2_out, sreg_1_1_out, sreg_1_0_out;
logic [7:0]     sreg_line0_out;
logic [7:0]     sreg_0_2_out, sreg_0_1_out, sreg_0_0_out;
logic [7:0]     sobel_out;

// valid wires
logic           sreg_delay_valid_out;
logic           sreg_2_2_valid_out, sreg_2_1_valid_out, sreg_2_0_valid_out;
logic           sreg_line1_valid_out;
logic           sreg_1_2_valid_out, sreg_1_1_valid_out, sreg_1_0_valid_out;
logic           sreg_line0_valid_out;
logic           sreg_0_2_valid_out, sreg_0_1_valid_out, sreg_0_0_valid_out;
logic           all_valid;

// output fifo signals
logic  [23:0]   out_din;
logic           out_full;
logic           out_wr_en;

logic  [9:0]    row, col;

always_ff @( posedge clock ) begin : count
    if (reset) begin
        row = 11'b0;
        col = 11'b0;
    end
    else if (sreg_1_1_valid_out) begin
        if (col == IMG_WIDTH - 1) begin
            col = 11'b0;
            row = row + 11'b1;
        end
        else begin
            col = col + 11'b1;
        end
    end
end

// combinational
assign in_full = A_full;
assign B_rd_en = ~B_empty;
assign all_valid = &{sreg_2_2_valid_out, sreg_2_1_valid_out, sreg_2_0_valid_out, 
                     sreg_1_2_valid_out, sreg_1_1_valid_out, sreg_1_0_valid_out, 
                     sreg_0_2_valid_out, sreg_0_1_valid_out, sreg_0_0_valid_out};

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(24)
) fifo_A_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(in_wr_en),
    .din(in_din),
    .full(A_full),
    .rd_clk(clock),
    .rd_en(A_rd_en),
    .dout(fifo_A_out),
    .empty(A_empty)
);

grayscale_cam #(
) grayscale_inst (
    .in_dout(fifo_A_out),
    .in_rd_en(A_rd_en),
    .in_empty(A_empty),
    .out_din(grayscale_out),
    .out_full(B_full),
    .out_wr_en(B_wr_en)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(8)
) fifo_B_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(B_wr_en),
    .din(grayscale_out),
    .full(B_full),
    .rd_clk(clock),
    .rd_en(B_rd_en),
    .dout(fifo_B_out),
    .empty(B_empty)
);

shift_reg #(
    .SHIFT_REG_LENGTH(2),
    .SHIFT_REG_WIDTH(1)
) sreg_delay_valid (
    .clock(clock),
    .reset(reset),
    .data_in(),
    .data_out(),
    .valid_in(B_rd_en),
    .valid_out(sreg_delay_valid_out)
);

shift_reg #(
    .SHIFT_REG_LENGTH(1),
    .SHIFT_REG_WIDTH(8)
) sreg_2_2 (
    .clock(clock),
    .reset(reset),
    .data_in(fifo_B_out),
    .data_out(sreg_2_2_out),
    .valid_in(sreg_delay_valid_out),
    .valid_out(sreg_2_2_valid_out)
);

shift_reg #(
    .SHIFT_REG_LENGTH(1),
    .SHIFT_REG_WIDTH(8)
) sreg_2_1 (
    .clock(clock),
    .reset(reset),
    .data_in(sreg_2_2_out),
    .data_out(sreg_2_1_out),
    .valid_in(sreg_2_2_valid_out),
    .valid_out(sreg_2_1_valid_out)
);

shift_reg #(
    .SHIFT_REG_LENGTH(1),
    .SHIFT_REG_WIDTH(8)
) sreg_2_0 (
    .clock(clock),
    .reset(reset),
    .data_in(sreg_2_1_out),
    .data_out(sreg_2_0_out),
    .valid_in(sreg_2_1_valid_out),
    .valid_out(sreg_2_0_valid_out)
);

shift_reg #(
    .SHIFT_REG_LENGTH(IMG_WIDTH - 3),
    .SHIFT_REG_WIDTH(8)
) sreg_line1 (
    .clock(clock),
    .reset(reset),
    .data_in(sreg_2_0_out),
    .data_out(sreg_line1_out),
    .valid_in(sreg_2_0_valid_out),
    .valid_out(sreg_line1_valid_out)
);

shift_reg #(
    .SHIFT_REG_LENGTH(1),
    .SHIFT_REG_WIDTH(8)
) sreg_1_2 (
    .clock(clock),
    .reset(reset),
    .data_in(sreg_line1_out),
    .data_out(sreg_1_2_out),
    .valid_in(sreg_line1_valid_out),
    .valid_out(sreg_1_2_valid_out)
);

shift_reg #(
    .SHIFT_REG_LENGTH(1),
    .SHIFT_REG_WIDTH(8)
) sreg_1_1 (
    .clock(clock),
    .reset(reset),
    .data_in(sreg_1_2_out),
    .data_out(sreg_1_1_out),
    .valid_in(sreg_1_2_valid_out),
    .valid_out(sreg_1_1_valid_out)
);

shift_reg #(
    .SHIFT_REG_LENGTH(1),
    .SHIFT_REG_WIDTH(8)
) sreg_1_0 (
    .clock(clock),
    .reset(reset),
    .data_in(sreg_1_1_out),
    .data_out(sreg_1_0_out),
    .valid_in(sreg_1_1_valid_out),
    .valid_out(sreg_1_0_valid_out)
);

shift_reg #(
    .SHIFT_REG_LENGTH(IMG_WIDTH - 3),
    .SHIFT_REG_WIDTH(8)
) sreg_line0 (
    .clock(clock),
    .reset(reset),
    .data_in(sreg_1_0_out),
    .data_out(sreg_line0_out),
    .valid_in(sreg_1_0_valid_out),
    .valid_out(sreg_line0_valid_out)
);

shift_reg #(
    .SHIFT_REG_LENGTH(1),
    .SHIFT_REG_WIDTH(8)
) sreg_0_2 (
    .clock(clock),
    .reset(reset),
    .data_in(sreg_line0_out),
    .data_out(sreg_0_2_out),
    .valid_in(sreg_line0_valid_out),
    .valid_out(sreg_0_2_valid_out)
);

shift_reg #(
    .SHIFT_REG_LENGTH(1),
    .SHIFT_REG_WIDTH(8)
) sreg_0_1 (
    .clock(clock),
    .reset(reset),
    .data_in(sreg_0_2_out),
    .data_out(sreg_0_1_out),
    .valid_in(sreg_0_2_valid_out),
    .valid_out(sreg_0_1_valid_out)
);

shift_reg #(
    .SHIFT_REG_LENGTH(1),
    .SHIFT_REG_WIDTH(8)
) sreg_0_0 (
    .clock(clock),
    .reset(reset),
    .data_in(sreg_0_1_out),
    .data_out(sreg_0_0_out),
    .valid_in(sreg_0_1_valid_out),
    .valid_out(sreg_0_0_valid_out)
);

sobel #()
sobel_inst (
    .top_L(sreg_0_2_out),
    .top_C(sreg_0_1_out),
    .top_R(sreg_0_0_out),
    .mid_L(sreg_1_2_out),
    .mid_R(sreg_1_0_out),
    .bot_L(sreg_2_2_out),
    .bot_C(sreg_2_1_out),
    .bot_R(sreg_2_0_out),
    .result(sobel_out)
);

logic [7:0] out_fifo_din;
logic [7:0] out_fifo_dout;
assign out_fifo_din = (col == 0 || col == IMG_WIDTH - 1 || row == 0 || row == IMG_HEIGHT - 1) ? 8'b0 : sobel_out;
assign out_dout = {3{out_fifo_dout}};

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(8)
) fifo_out_inst (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(sreg_1_1_valid_out),
    .din(out_fifo_din),
    .full(out_full),
    .rd_clk(clock),
    .rd_en(out_rd_en),
    .dout(out_fifo_dout),
    .empty(out_empty)
);

endmodule
