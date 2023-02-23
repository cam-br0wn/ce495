module shift_reg #(
    parameter SHIFT_REG_LENGTH  = 1,
    parameter SHIFT_REG_WIDTH   = 8
)
(
    input logic                             clock,
    input logic                             reset,
    input logic     [SHIFT_REG_WIDTH-1:0]   data_in,
    input logic                             valid_in,
    output logic    [SHIFT_REG_WIDTH-1:0]   data_out,
    output logic                            valid_out
);

logic [SHIFT_REG_LENGTH-1:0] [SHIFT_REG_WIDTH-1:0]  data;
logic [SHIFT_REG_LENGTH-1:0]                        valid;

always_ff @(posedge clock, posedge reset)
begin
    if (reset) begin
        data <= {(SHIFT_REG_LENGTH * SHIFT_REG_WIDTH){0}};
        valid <= {SHIFT_REG_LENGTH{0}};
    end else begin
        if (valid_in) begin
            data <= {data[SHIFT_REG_LENGTH-2:0], data_in};
            valid <= {valid[SHIFT_REG_LENGTH-2:0], valid_in};
        end else begin
            data <= data;
            valid <= valid;
        end
    end
end

assign data_out = data[SHIFT_REG_LENGTH-1][7:0];
assign valid_out = valid[SHIFT_REG_LENGTH-1];

endmodule
