module matmul
#(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 12,
    paramter VECTOR_SIZE = 64)

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
logic [ADDR_WIDTH/2-1:0] i, i_c, j, j_c, k, k_c;
logic [DATA_WIDTH-1:0] sum, sum_c;
logic done_c;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        state <= s0;
        i <= '0;
        done <= 'b0;
        sum <= 'b0;
    end else begin
        state <= state_c;
        i <= i_c;
        done <= done_c;
        sum <= sum_c;
    end
end

always_comb begin
    z_din = 'b0;
    z_wr_en = 'b0;
    z_addr = 'b0;
    x_addr = 'b0;
    y_addr = 'b0;
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
           if (start == 1'b1) begin
               state_c = s1;
               done_c = 1'b0;
               sum_c = 1'b0;
           end
        end
        // check for new cell entry
        s1: begin
            if ($unsigned(i) < $unsigned(VECTOR_SIZE)) begin
                x_addr = $unsigned(i) * VECTOR_SIZE + $unsigned(k);
                y_addr = $unsigned(k) * VECTOR_SIZE + $unsigned(j);
                state_c = s2;
            end else begin
                done_c = 1'b1;
                state_c = s0;
                sum_c = 32'b0;
            end
        end
        // write to Z if done with computation
        s2: begin
            z_din = sum;
            z_addr = 32($unsigned(i) * VECTOR_SIZE) + $unsigned(j);
            z_wr_en = (k_c == 12'h3f) ? '1 : '0;
            if (k_c == 12'h3f && j_c == 6'h3f) begin
                i_c = i + 'b1;
                j_c = j + 'b1;
            end elsif (k_c == 6'h3f) begin
                j_c = j + 'b1;
            end
            k_c = k + 'b1;
            sum_c = sum + ($signed(y_dout) * $signed(x_dout));
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