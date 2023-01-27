module motion_detect_top #(
    parameter WIDTH = 720,
    parameter HEIGHT = 540
) (
    input  logic        clock,
    input  logic        reset,

    output logic        A_full,
    output logic        B_full,
    output logic        C_full,
    input  logic        background_wr_en,
    input  logic        frame_wr_en,

    // need separate DINs for background and frame
    input   logic [23:0] background_din,
    input   logic [23:0] frame_din,

    output logic         out_empty,
    // output logic         sub_out_empty,
    input  logic         out_rd_en,
    // output logic [23:0]  sub_dout,
    output logic [23:0]  out_dout
);

// fifo A internal signals
logic [23:0]    A_dout;
logic           A_rd_en;
logic           A_empty;

// fifo B internal signals
logic [23:0]    B_dout;
logic           B_rd_en;
logic           B_empty;

// fifo C internal signals
logic [23:0]    C_dout;
logic           C_rd_en;
logic           C_empty;

// fifo D internal signals
logic [7:0]     D_din;
logic [7:0]     D_dout;
logic           D_rd_en;
logic           D_wr_en;
logic           D_empty;
logic           D_full;

// fifo E internal signals
logic [7:0]     E_din;
logic [7:0]     E_dout;
logic           E_rd_en;
logic           E_wr_en;
logic           E_empty;
logic           E_full;

// fifo F internal signals
logic           F_din;
logic           F_dout;
logic           F_rd_en;
logic           F_wr_en;
logic           F_empty;
logic           F_full;

// fifo G internal signals
logic [23:0]    G_din;
logic           G_wr_en;
logic           G_full;

// DEBUG
// assign sub_dout = {24{F_dout}};
// assign sub_out_empty = F_empty;

grayscale #(
) grayscale_inst1 (
    .clock(clock),
    .reset(reset),
    .in_dout(A_dout),
    .in_rd_en(A_rd_en),
    .in_empty(A_empty),
    .out_din(D_din),
    .out_full(D_full),
    .out_wr_en(D_wr_en)
);

grayscale #(
) grayscale_inst2 (
    .clock(clock),
    .reset(reset),
    .in_dout(B_dout),
    .in_rd_en(B_rd_en),
    .in_empty(B_empty),
    .out_din(E_din),
    .out_full(E_full),
    .out_wr_en(E_wr_en)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(24)
) fifo_a (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(background_wr_en),
    .din(background_din),
    .full(A_full),
    .rd_clk(clock),
    .rd_en(A_rd_en),
    .dout(A_dout),
    .empty(A_empty)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(24)
) fifo_b (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(frame_wr_en),
    .din(frame_din),
    .full(B_full),
    .rd_clk(clock),
    .rd_en(B_rd_en),
    .dout(B_dout),
    .empty(B_empty)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(24)
) fifo_c (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(frame_wr_en),
    .din(frame_din),
    .full(C_full),
    .rd_clk(clock),
    .rd_en(C_rd_en),
    .dout(C_dout),
    .empty(C_empty)
);

// internal signals for subtract
logic   DE_empty;
logic   DE_rd_en;

// drive DE empty with OR of D_empty and E_empty
assign DE_empty = ~D_empty && ~E_empty;
assign D_rd_en = DE_rd_en;
assign E_rd_en = DE_rd_en;

subtract #(
) subtract_inst (
    .clock(clock),
    .reset(reset),
    .inD_dout(D_dout),
    .inE_dout(E_dout),
    .in_rd_en(DE_rd_en),
    .in_empty(DE_empty),
    .out_din(F_din),
    .out_full(F_full),
    .out_wr_en(F_wr_en)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(8)
) fifo_d (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(D_wr_en),
    .din(D_din),
    .full(D_full),
    .rd_clk(clock),
    .rd_en(D_rd_en),
    .dout(D_dout),
    .empty(D_empty)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(8)
) fifo_e (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(E_wr_en),
    .din(E_din),
    .full(E_full),
    .rd_clk(clock),
    .rd_en(E_rd_en),
    .dout(E_dout),
    .empty(E_empty)
);

// internal signals for highlight
logic   CF_empty;
logic   CF_rd_en;

// drive CF_empty with OR of C_empty and F_empty
assign CF_empty = C_empty || F_empty;
assign C_rd_en = CF_rd_en;
assign F_rd_en = CF_rd_en;

highlight #(
) highlight_inst (
    .clock(clock),
    .reset(reset),
    .inF_dout(F_dout),
    .inC_dout(C_dout),
    .in_rd_en(CF_rd_en),
    .in_empty(CF_empty),
    .out_din(G_din),
    .out_full(G_full),
    .out_wr_en(G_wr_en)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(1)
) fifo_f (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(F_wr_en),
    .din(F_din),
    .full(F_full),
    .rd_clk(clock),
    .rd_en(F_rd_en),
    .dout(F_dout),
    .empty(F_empty)
);

fifo #(
    .FIFO_BUFFER_SIZE(256),
    .FIFO_DATA_WIDTH(24)
) fifo_g (
    .reset(reset),
    .wr_clk(clock),
    .wr_en(G_wr_en),
    .din(G_din),
    .full(G_full),
    .rd_clk(clock),
    .rd_en(out_rd_en),
    .dout(out_dout),
    .empty(out_empty)
);

endmodule
