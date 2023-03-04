import uvm_pkg::*;

interface my_uvm_if;
    logic           clock;
    logic           reset;
    logic   [31:0]  in_din;
    logic           in_full;
    logic           in_wr_en;
    logic           out_empty;
    logic           out_rd_en;
    logic   [15:0]  cos_dout;
    logic   [15:0]  sin_dout;
endinterface
