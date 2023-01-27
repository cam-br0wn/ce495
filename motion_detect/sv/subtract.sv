module subtract (
    input  logic        clock,
    input  logic        reset,
    output logic        in_rd_en,
    input  logic        in_empty,
    input  logic [7:0] inD_dout,
    input  logic [7:0] inE_dout,
    output logic        out_wr_en,
    input  logic        out_full,
    output logic        out_din
);

typedef enum logic [0:0] {s0, s1} state_types;
state_types state, state_c;

logic [7:0] sub, sub_c;
// logic [8:0] diff, abs;
logic [7:0] diff;
logic color;

assign diff =   $unsigned(inD_dout) > $unsigned(inE_dout) ? 
                    $unsigned(inD_dout) - $unsigned(inE_dout) : 
                    $unsigned(inE_dout) - $unsigned(inD_dout);
assign color = (diff <= 8'h32);

always_ff @(posedge clock or posedge reset) begin
    if (reset == 1'b1) begin
        state <= s0;
        sub <= 8'h0;
    end else begin
        state <= state_c;
        sub <= sub_c;
    end
end

always_comb begin
    in_rd_en  = 1'b0;
    out_wr_en = 1'b0;
    out_din   = 24'b0;
    state_c   = state;
    sub_c = sub;
    // diff =  ($unsigned({1'b0, inE_dout}) - $unsigned({1'b0, inD_dout}));
    // abs = (diff[8]) ? ~diff + 9'd1 : diff;

    case (state)
        s0: begin
            if (in_empty) begin
                // sub_c = ($unsigned(abs) <= 9'd50) ? 24'b0 : 24'hffffff;
                sub_c = color;
                in_rd_en = 1'b1;
                state_c = s1;
            end
        end

        s1: begin
            if (out_full == 1'b0) begin
                out_din = sub;
                out_wr_en = 1'b1;
                state_c = s0;
            end
        end

        default: begin
            in_rd_en  = 1'bX;
            out_wr_en = 1'bX;
            out_din = 24'bX;
            state_c = s0;
            sub_c = 8'hX;
        end

    endcase
end

endmodule
