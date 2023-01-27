module highlight (
    input  logic        clock,
    input  logic        reset,
    output logic        in_rd_en,
    input  logic        in_empty,
    input  logic [23:0] inC_dout,
    input  logic        inF_dout,
    output logic        out_wr_en,
    input  logic        out_full,
    output logic [23:0] out_din
);

typedef enum logic [0:0] {s0, s1} state_types;
state_types state, state_c;

logic [23:0] hl, hl_c;

always_ff @(posedge clock or posedge reset) begin
    if (reset == 1'b1) begin
        state <= s0;
        hl <= 24'h0;
    end else begin
        state <= state_c;
        hl <= hl_c;
    end
end

always_comb begin
    in_rd_en  = 1'b0;
    out_wr_en = 1'b0;
    out_din   = 24'b0;
    state_c   = state;
    hl_c = hl;

    case (state)
        s0: begin
            if (~in_empty) begin
                hl_c = inF_dout ? inC_dout : 24'h0000ff;
                in_rd_en = 1'b1;
                state_c = s1;
            end
        end

        s1: begin
            if (out_full == 1'b0) begin
                out_din = hl;
                out_wr_en = 1'b1;
                state_c = s0;
            end
        end

        default: begin
            in_rd_en  = 1'b0;
            out_wr_en = 1'b0;
            out_din = 24'bX;
            state_c = s0;
            hl_c = 24'hX;
        end

    endcase
end

endmodule
