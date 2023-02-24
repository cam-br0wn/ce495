module parse_udp
(
    input   logic       clk,
    input   logic       reset,

    input   logic       input_sof,
    input   logic       input_eof,
    output  logic       in_rd_en,
    input   logic [7:0] data_in,
    input   logic       in_empty,

    input   logic       out_full,
    input   logic       out_empty,
    output  logic [7:0] data_out,
    output  logic       out_wr_en,
    output  logic       output_sof,
    output  logic       output_eof
);

localparam PACKET_HEADER_BYTES      = 40;
localparam UDP_CHECKSUM_BYTES       = 2;

typedef enum logic [2:0] {idle,
                          packet_header,
                          udp_checksum, 
                          udp_data, 
                          validate_checksum, 
                          output_data
} state_t;

logic   [31:0]  sum, sum_c;
logic   [15:0]  checksum, checksum_c;
state_t         state, state_c;
logic   [7:0]   cycle, cycle_c;
logic           checksum_valid, checksum_valid_c;

// signals for the buffer fifo
logic           buffer_wr_en;
logic   [7:0]   buffer_din;
logic           buffer_full;
logic           buffer_rd_en;
logic           buffer_wr_sof, buffer_wr_eof, buffer_rd_sof, buffer_rd_eof;
logic   [7:0]   buffer_dout;
logic           buffer_empty;

fifo_ctrl data_buffer 
(
    .reset(reset),
    .wr_clk(clk),
    .wr_en(buffer_wr_en),
    .wr_sof(buffer_wr_sof),
    .wr_eof(buffer_wr_eof),
    .din(buffer_din),
    .full(buffer_full),
    .rd_clk(clk),
    .rd_en(buffer_rd_en),
    .rd_sof(buffer_rd_sof),
    .rd_eof(buffer_rd_eof),
    .dout(buffer_dout),
    .empty(buffer_empty)
);

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        sum <= '0;
        checksum <= '0;
        state <= idle;
        cycle <= '0;
        checksum_valid <= '0;
    end
    else begin
        sum <= sum_c;
        checksum <= checksum_c;
        state <= state_c;
        cycle <= cycle_c;
        checksum_valid <= checksum_valid_c;
    end
end

always_comb begin
    checksum_valid_c = checksum_valid;
    in_rd_en = '1;
    out_wr_en = '0;
    buffer_wr_en = '0;
    buffer_rd_en = '0;
    buffer_wr_eof = (state == udp_data) ? input_eof : '0;
    buffer_din = (state == udp_data) ? data_in : '0;
    data_out = (state == output_data) ? buffer_dout : '0;
    case(state)
    idle: begin
        cycle_c = '0;
        state_c = (input_sof) ? packet_header : idle;
        in_rd_en = '0;
        sum_c = '0;
        checksum_c = '0;
    end
    packet_header: begin
        sum_c = (cycle[0]) ? sum + $unsigned({24'b0, data_in}) : sum + $unsigned({16'b0, data_in, 8'b0});
        if (cycle == PACKET_HEADER_BYTES-1) begin
            state_c = udp_checksum;
            cycle_c = '0;
        end
        else begin
           state_c = packet_header;
           cycle_c = cycle + 8'b1; 
        end
    end
    udp_checksum: begin
        sum_c = (cycle[0]) ? sum + $unsigned({24'b0, data_in}) : sum + $unsigned({16'b0, data_in, 8'b0});
        if (cycle == UDP_CHECKSUM_BYTES-1) begin
            state_c = udp_data;
            cycle_c = '0;
            checksum_c = checksum + $unsigned(data_in);
        end
        else begin
            state_c = udp_checksum;
            cycle_c = cycle + 8'b1;
            checksum_c = {data_in, 8'b0};
        end
    end
    udp_data: begin
        sum_c = (cycle[0]) ? sum + $unsigned({24'b0, data_in}) : sum + $unsigned({16'b0, data_in, 8'b0});
        cycle_c = '0;
        if (input_eof) begin
            state_c = validate_checksum;
            buffer_wr_en = '0;
        end
        else begin
            state_c = udp_data;
            buffer_wr_en = '1;
        end
    end
    validate_checksum: begin
        cycle_c = '0;
        in_rd_en = '0;
        if(|sum[31:16]) begin
            state_c = validate_checksum;
            sum_c = $unsigned(sum[15:0]) + $unsigned(sum[31:16]);
        end
        else begin
            state_c = output_data;
            checksum_valid_c = (sum == checksum);
        end
    end
    output_data: begin
        in_rd_en = '0;
        if (buffer_rd_eof) begin
            state_c = idle;
        end
        else begin
            state_c = (buffer_empty) ? idle : output_data;
            out_wr_en = '1;
            buffer_rd_en = '1;
        end
    end
    endcase
end

endmodule