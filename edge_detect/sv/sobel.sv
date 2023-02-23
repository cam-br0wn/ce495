module sobel (
    input logic [7:0] top_L,
    input logic [7:0] top_C,
    input logic [7:0] top_R,
    input logic [7:0] mid_L,
    input logic [7:0] mid_R,
    input logic [7:0] bot_L,
    input logic [7:0] bot_C,
    input logic [7:0] bot_R,
    output logic [7:0] result
);

// internal signals
logic [10:0] shift_mid_L, shift_mid_R, shift_top_C, shift_bot_C;
logic [10:0] id_top_L, id_bot_L, id_top_R;
logic [10:0] neg_top_R, neg_bot_R, neg_bot_L;

logic [10:0] x_val, y_val, x_val_abs, y_val_abs, sum, sum_d2;

always_comb begin

    // shifted values
    shift_mid_L = {2'b0, mid_L, 1'b0};
    shift_mid_R = ~{2'b0, mid_R, 1'b0} + 1'b1;
    shift_top_C = {2'b0, top_C, 1'b0};
    shift_bot_C = ~{2'b0, bot_C, 1'b0} + 1'b1;
    
    // zero extend ID values
    id_top_L = {3'b0, top_L};
    id_bot_L = {3'b0, bot_L};
    id_top_R = {3'b0, top_R};

    // negate values
    neg_top_R = ~{3'b0, top_R} + 1;
    neg_bot_R = ~{3'b0, bot_R} + 1;
    neg_bot_L = ~{3'b0, bot_L} + 1;

    x_val = $signed(id_top_L) + $signed(shift_mid_L) + $signed(id_bot_L) + $signed(neg_top_R) + $signed(shift_mid_R) + $signed(neg_bot_R);
    y_val = $signed(id_top_L) + $signed(shift_top_C) + $signed(id_top_R) + $signed(neg_bot_L) + $signed(shift_bot_C) + $signed(neg_bot_R);

    x_val_abs = (x_val[10]) ? -x_val : x_val;
    y_val_abs = (y_val[10]) ? -y_val : y_val;
    sum = x_val_abs + y_val_abs;
    sum_d2 = {1'b0, sum[10:1]};
    result = ($unsigned(sum_d2) > 255) ? 8'hff : sum_d2[7:0]; 

end

endmodule