module matmul
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 6,
    parameter VECTOR_SIZE = 8
    // parameter ADDR_WIDTH = 4,
    // parameter VECTOR_SIZE = 4
)

(
    input logic clock,
    input logic reset,
    input logic start,
    output logic done,
    // incoming data from X and Y BRAMs
    input logic [DATA_WIDTH-1:0] x_dout,
    input logic [DATA_WIDTH-1:0] y_dout,
    // outgoing addresses to access data from X and Y
    output logic [ADDR_WIDTH-1:0] x_addr,
    output logic [ADDR_WIDTH-1:0] y_addr,
    // outgoing address and data signals to Z BRAM
    output logic [DATA_WIDTH-1:0] z_din,
    output logic [ADDR_WIDTH-1:0] z_addr,
    output logic z_wr_en
);

typedef enum logic [1:0] {s0, s1, s2} state_t;
state_t state, state_c;
logic [ADDR_WIDTH/2-1:0] j, j_c;
logic [ADDR_WIDTH/2:0] k, k_c, i, i_c;
logic [DATA_WIDTH-1:0] sum, sum_c;
logic done_c;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= s0;
        i <= '0;
        j <= '0;
        k <= '0;
        done <= 'b0;
        sum <= 'b0;
    end else begin
        state <= state_c;
        i <= i_c;
        j <= j_c;
        k <= k_c;
        done <= done_c;
        sum <= sum_c;
    end
end

always_comb begin
    z_din = (sum + ($unsigned(y_dout) * $unsigned(x_dout)));
    z_wr_en = (k == 4'h7 && state == s2) ? '1 : '0;
    z_addr = ($unsigned(i) * $unsigned(VECTOR_SIZE)) + $unsigned(j);
    x_addr = ($unsigned(i_c) * $unsigned(VECTOR_SIZE)) + $unsigned(k_c);
    y_addr = ($unsigned(k_c) * $unsigned(VECTOR_SIZE)) + $unsigned(j_c);
    state_c = state;
    i_c = i;
    j_c = j;
    k_c = k;
    sum_c = sum;
    done_c = done;

    case (state)
        // idle state
        s0: begin
           i_c = '0;
           j_c = '0;
           k_c = '0;
           if (start == 1'b1) begin
               state_c = s1;
               done_c = 1'b0;
               sum_c = 1'b0;
           end
        end
        // check for new cell entry
        s1: begin
            if ($unsigned(i) < $unsigned(VECTOR_SIZE)) begin
                state_c = s2;
            end else begin
                done_c = 1'b1;
                state_c = s0;
                sum_c = 32'b0;
            end
        end
        // write to Z if done with computation
        s2: begin
            // z_din = sum;
            sum_c = (k > 4'h7) ? 32'b0 : (sum + ($unsigned(y_dout) * $unsigned(x_dout)));
            if (k == 4'h7 && j == 3'h7) begin
                i_c = i + 'b1;
                j_c = j + 'b1;
            end else if (k == 4'h7) begin
                j_c = j + 'b1;
            end
            k_c = (k > 4'h7) ? 'b0 : k + 'b1;
            state_c = s1;
        end
        default: begin
            z_din = 'x;
            z_wr_en = 'x;
            z_addr = 'x;
            x_addr = 'x;
            y_addr = 'x;
            state_c = s0;
            i_c = 'x;
            k_c = 'x;
            j_c = 'x;
            done_c = 'x;
            sum_c = 'x;
        end
    endcase
end

endmodule