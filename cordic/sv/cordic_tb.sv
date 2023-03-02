`timescale 1ns/1ns
// `include "cordic_macros.sv"

module cordic_tb;

localparam string THETA_IN_NAME = "../rad.txt";
localparam string COS_OUT_NAME = "../cos_out.txt";
localparam string SIN_OUT_NAME = "../sin_out.txt";
localparam string COS_CMP_NAME = "../cos.txt";
localparam string SIN_CMP_NAME = "../sin.txt";

localparam CLOCK_PERIOD = 10;

logic               clk = 1'b1;
logic               reset = '0;
logic               start = '0;

logic               in_wr_en = '0;
logic   [31:0]      in_din;
logic               in_full;

logic               out_rd_en;
logic   [31:0]      cos_dout;
logic   [31:0]      sin_dout;
logic               out_empty;

logic               in_write_done = '0;
logic               out_read_done = '0;
integer             out_errors = '0;

cordic_top_level cordic_top_inst (
    .clk(clk),
    .reset(reset),

    .in_full(in_full),
    .in_wr_en(in_wr_en),
    .theta_in(in_din),

    .out_empty(out_empty),
    .out_rd_en(out_rd_en),
    .cos_out(cos_dout),
    .sin_out(sin_dout)
);

always begin
    clk = 1'b1;
    #(CLOCK_PERIOD/2);
    clk = 1'b0;
    #(CLOCK_PERIOD/2);
end

initial begin
    @(posedge clk);
    reset = 1'b1;
    @(posedge clk);
    reset = 1'b0;
end

initial begin : tb_process
    longint unsigned start_time, end_time;

    @(negedge reset);
    @(posedge clk);
    start_time = $time;

    // start
    $display("@ %0t: Beginning simulation...", start_time);
    start = 1'b1;
    @(posedge clk);
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

initial begin : theta_read_process

    int i, in_file;

    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, THETA_IN_NAME);

    in_file = $fopen(THETA_IN_NAME, "rb");
    in_wr_en = 1'b0;

    // Read data from input angles text file
    while ( !$feof(in_file) ) begin
        @(negedge clk);
        if (in_full == 1'b0) begin
            $fscanf(in_file, "%x", in_din);
            in_wr_en = 1'b1;
        end else begin
            in_wr_en = 1'b0;
        end
    end

    @(negedge clk);
    in_wr_en = 1'b0;
    $fclose(in_file);
    in_write_done = 1'b1;
end

initial begin : cos_write_process
    int i, n_bytes, r;
    int out_file;
    int cmp_file;
    logic [15:0] cmp_dout;

    @(negedge reset);
    @(negedge clk);

    $display("@ %0t: Comparing file %s...", $time, COS_OUT_NAME);

    out_file = $fopen(COS_OUT_NAME, "wb");
    cmp_file = $fopen(COS_CMP_NAME, "rb");
    out_rd_en = 1'b0;

    i = $fseek(cmp_file, 0, 2);
    n_bytes = $ftell(cmp_file);
    i = $fseek(cmp_file, 0, 0);
    $display("n_bytes = %d\n", n_bytes);

    while (!$feof(cmp_file)) begin
        @(negedge clk);
        out_rd_en = 1'b0;
        if (out_empty == 1'b0) begin
            r = $fread(cmp_dout, cmp_file, i, 1);
            $fwrite(out_file, "%x", cos_dout);

            if (cmp_dout != cos_dout) begin
                out_errors += 1;
                $write("@ %0t: %s(%0d): ERROR %x != %x at address0x%x.\n", $time, COS_OUT_NAME, i+1, cos_dout, cmp_dout, i);
            end
            out_rd_en = 1'b1;
            i++;
        end
    end

    @(negedge clk);
    out_rd_en = 1'b0;
    $fclose(out_file);
    $fclose(cmp_file);
    out_read_done = 1'b1;
end

initial begin : sin_write_process
    int i, n_bytes, r;
    int out_file;
    int cmp_file;
    logic [15:0] cmp_dout;

    @(negedge reset);
    @(negedge clk);

    $display("@ %0t: Comparing file %s...", $time, SIN_OUT_NAME);

    out_file = $fopen(SIN_OUT_NAME, "wb");
    cmp_file = $fopen(SIN_CMP_NAME, "rb");
    out_rd_en = 1'b0;

    i = $fseek(cmp_file, 0, 2);
    n_bytes = $ftell(cmp_file);
    i = $fseek(cmp_file, 0, 0);
    $display("n_bytes = %d\n", n_bytes);

    while (!$feof(cmp_file)) begin
        @(negedge clk);
        out_rd_en = 1'b0;
        if (out_empty == 1'b0) begin
            r = $fread(cmp_dout, cmp_file, i, 1);
            $fwrite(out_file, "%x", sin_dout);

            if (cmp_dout != sin_dout) begin
                out_errors += 1;
                $write("@ %0t: %s(%0d): ERROR %x != %x at address0x%x.\n", $time, SIN_OUT_NAME, i+1, sin_dout, cmp_dout, i);
            end
            out_rd_en = 1'b1;
            i++;
        end
    end

    @(negedge clk);
    out_rd_en = 1'b0;
    $fclose(out_file);
    $fclose(cmp_file);
    out_read_done = 1'b1;
end

endmodule