
`timescale 1 ns / 1 ns

module motion_detect_tb;

localparam string BACKGROUND_IN_NAME  = "/home/ckb4640/ce495/motion_detect/bmp/base.bmp";
localparam string FRAME_IN_NAME = "/home/ckb4640/ce495/motion_detect/bmp/pedestrians.bmp";
localparam string IMG_OUT_NAME = "/home/ckb4640/ce495/motion_detect/bmp/result.bmp";
localparam string IMG_CMP_NAME = "/home/ckb4640/ce495/motion_detect/bmp/img_out.bmp";
// localparam string SUB_OUT_NAME = "/home/ckb4640/ce495/motion_detect/bmp/subtract_result.bmp";
// localparam string SUB_CMP_NAME = "/home/ckb4640/ce495/motion_detect/bmp/img_mask.bmp";
localparam CLOCK_PERIOD = 10;

logic clock = 1'b1;
logic reset = '0;
logic start = '0;
logic done  = '0;

logic           A_full;
logic           B_full;
logic           C_full;
logic           background_wr_en    = '0;
logic           frame_wr_en         = '0;
logic   [23:0]  background_din      = '0;
logic   [23:0]  frame_din           = '0;
logic           out_rd_en;
// logic           sub_out_rd_en;
logic           out_empty;
// logic           sub_out_empty;
logic   [23:0]  out_dout;
// logic   [23:0]  sub_dout;

logic   hold_clock                  = '0;
logic   background_write_done       = '0;
logic   frame_write_done            = '0;
logic   out_read_done               = '0;
// logic   sub_out_read_done           = '0;
integer out_errors                  = '0;

localparam WIDTH = 768;
localparam HEIGHT = 576;
localparam BMP_HEADER_SIZE = 54;
localparam BYTES_PER_PIXEL = 3;
localparam BMP_DATA_SIZE = WIDTH*HEIGHT*BYTES_PER_PIXEL;

motion_detect_top #(
    .WIDTH(WIDTH),
    .HEIGHT(HEIGHT)
) motion_detect_top_inst (
    .clock(clock),
    .reset(reset),
    .A_full(A_full),
    .B_full(B_full),
    .C_full(C_full),
    .background_wr_en(background_wr_en),
    .frame_wr_en(frame_wr_en),
    .background_din(background_din),
    .frame_din(frame_din),
    .out_empty(out_empty),
    // .sub_out_empty(sub_out_empty),
    .out_rd_en(out_rd_en),
    // .sub_dout(sub_dout),
    .out_dout(out_dout)
);

always begin
    clock = 1'b1;
    #(CLOCK_PERIOD/2);
    clock = 1'b0;
    #(CLOCK_PERIOD/2);
end

initial begin
    @(posedge clock);
    reset = 1'b1;
    @(posedge clock);
    reset = 1'b0;
end

initial begin : tb_process
    longint unsigned start_time, end_time;

    @(negedge reset);
    @(posedge clock);
    start_time = $time;

    // start
    $display("@ %0t: Beginning simulation...", start_time);
    start = 1'b1;
    @(posedge clock);
    start = 1'b0;

    wait(out_read_done);
    end_time = $time;

    // report metrics
    $display("@ %0t: Simulation completed.", end_time);
    $display("Total simulation cycle count: %0d", (end_time-start_time)/CLOCK_PERIOD);
    $display("Total error count: %0d", out_errors);

    // end the simulation
    $finish;
end

initial begin : background_read_process
    int i, r;
    int in_file;
    logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, BACKGROUND_IN_NAME);

    in_file = $fopen(BACKGROUND_IN_NAME, "rb");
    background_wr_en = 1'b0;

    // Skip BMP header
    r = $fread(bmp_header, in_file, 0, BMP_HEADER_SIZE);

    // Read data from image file
    i = 0;
    while ( i < BMP_DATA_SIZE ) begin
        @(negedge clock);
        background_wr_en = 1'b0;
        if (A_full == 1'b0) begin
            r = $fread(background_din, in_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
            background_wr_en = 1'b1;
            i += BYTES_PER_PIXEL;
        end
    end

    @(negedge clock);
    background_wr_en = 1'b0;
    $fclose(in_file);
    background_write_done = 1'b1;
end

initial begin : frame_read_process
    int i, r;
    int in_file;
    logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, FRAME_IN_NAME);

    in_file = $fopen(FRAME_IN_NAME, "rb");
    frame_wr_en = 1'b0;

    // Skip BMP header
    r = $fread(bmp_header, in_file, 0, BMP_HEADER_SIZE);

    // Read data from image file
    i = 0;
    while ( i < BMP_DATA_SIZE ) begin
        @(negedge clock);
        frame_wr_en = 1'b0;
        if (C_full == 1'b0 && B_full == 1'b0) begin
            r = $fread(frame_din, in_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
            frame_wr_en = 1'b1;
            i += BYTES_PER_PIXEL;
        end
    end

    @(negedge clock);
    frame_wr_en = 1'b0;
    $fclose(in_file);
    frame_write_done = 1'b1;
end

// initial begin : subtract_write_process
//     int i, r;
//     int sub_out_file;
//     int sub_cmp_file;
//     logic [23:0] sub_cmp_dout;
//     logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

//     @(negedge reset);
//     @(negedge clock);

//     $display("@ %0t: Comparing file %s...", $time, SUB_OUT_NAME);

//     sub_out_file = $fopen(SUB_OUT_NAME, "wb");
//     sub_cmp_file = $fopen(SUB_CMP_NAME, "rb");
//     sub_out_rd_en = 1'b0;
    
//     // Copy the BMP header
//     r = $fread(bmp_header, sub_cmp_file, 0, BMP_HEADER_SIZE);
//     for (i = 0; i < BMP_HEADER_SIZE; i++) begin
//         $fwrite(sub_out_file, "%c", bmp_header[i]);
//     end

//     i = 0;
//     while (i < BMP_DATA_SIZE) begin
//         @(negedge clock);
//         sub_out_rd_en = 1'b0;
//         if (sub_out_empty == 1'b0) begin
//             r = $fread(sub_cmp_dout, sub_cmp_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
//             $fwrite(sub_out_file, "%c%c%c", sub_dout[23:16], sub_dout[15:8], sub_dout[7:0]);

//             if (sub_cmp_dout != sub_dout) begin
//                 out_errors += 1;
//                 $write("@ %0t: %s(%0d): ERROR: %x != %x at address 0x%x.\n", $time, SUB_OUT_NAME, i+1, sub_dout, sub_cmp_dout, i);
//             end
//             sub_out_rd_en = 1'b1;
//             i += BYTES_PER_PIXEL;
//         end
//     end

//     @(negedge clock);
//     sub_out_rd_en = 1'b0;
//     $fclose(sub_out_file);
//     $fclose(sub_cmp_file);
//     sub_out_read_done = 1'b1;
// end

initial begin : img_write_process
    int i, r;
    int out_file;
    int cmp_file;
    logic [23:0] cmp_dout;
    logic [7:0] bmp_header [0:BMP_HEADER_SIZE-1];

    @(negedge reset);
    @(negedge clock);

    $display("@ %0t: Comparing file %s...", $time, IMG_OUT_NAME);
    
    out_file = $fopen(IMG_OUT_NAME, "wb");
    cmp_file = $fopen(IMG_CMP_NAME, "rb");
    out_rd_en = 1'b0;
    
    // Copy the BMP header
    r = $fread(bmp_header, cmp_file, 0, BMP_HEADER_SIZE);
    for (i = 0; i < BMP_HEADER_SIZE; i++) begin
        $fwrite(out_file, "%c", bmp_header[i]);
    end

    i = 0;
    while (i < BMP_DATA_SIZE) begin
        @(negedge clock);
        out_rd_en = 1'b0;
        if (out_empty == 1'b0) begin
            r = $fread(cmp_dout, cmp_file, BMP_HEADER_SIZE+i, BYTES_PER_PIXEL);
            $fwrite(out_file, "%c%c%c", out_dout[23:16], out_dout[15:8], out_dout[7:0]);

            if (cmp_dout != out_dout) begin
                out_errors += 1;
                $write("@ %0t: %s(%0d): ERROR: %x != %x at address 0x%x.\n", $time, IMG_OUT_NAME, i+1, out_dout, cmp_dout, i);
            end
            out_rd_en = 1'b1;
            i += BYTES_PER_PIXEL;
        end
    end

    @(negedge clock);
    out_rd_en = 1'b0;
    $fclose(out_file);
    $fclose(cmp_file);
    out_read_done = 1'b1;
end

endmodule
