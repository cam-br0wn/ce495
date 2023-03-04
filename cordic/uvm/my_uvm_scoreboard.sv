import uvm_pkg::*;

`uvm_analysis_imp_decl(_output)
`uvm_analysis_imp_decl(_compare)

class my_uvm_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(my_uvm_scoreboard)

    uvm_analysis_export #(my_uvm_transaction) sb_export_cos;
    uvm_analysis_export #(my_uvm_transaction) sb_export_sin;
    uvm_analysis_export #(my_uvm_transaction) sb_export_compare_cos;
    uvm_analysis_export #(my_uvm_transaction) sb_export_compare_sin;

    uvm_tlm_analysis_fifo #(my_uvm_transaction) cos_fifo;
    uvm_tlm_analysis_fifo #(my_uvm_transaction) sin_fifo;
    uvm_tlm_analysis_fifo #(my_uvm_transaction) cos_compare_fifo;
    uvm_tlm_analysis_fifo #(my_uvm_transaction) sin_compare_fifo;

    my_uvm_transaction tx_cos;
    my_uvm_transaction tx_sin;
    my_uvm_transaction tx_cmp_cos;
    my_uvm_transaction tx_cmp_sin;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        tx_cos      = new("tx_cos");
        tx_sin      = new("tx_sin");
        tx_cmp_cos  = new("tx_cmp_cos");
        tx_cmp_sin  = new("tx_cmp_sin");
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sb_export_cos    = new("sb_export_cos", this);
        sb_export_sin    = new("sb_export_sin", this);
        sb_export_compare_cos   = new("sb_export_compare_cos", this);
        sb_export_compare_sin   = new("sb_export_compare_sin", this);

        cos_fifo        = new("cos_fifo", this);
        sin_fifo        = new("sin_fifo", this);
        cos_compare_fifo    = new("cos_compare_fifo", this);
        sin_compare_fifo    = new("sin_compare_fifo", this);
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        sb_export_cos.connect(cos_fifo.analysis_export);
        sb_export_sin.connect(sin_fifo.analysis_export);
        sb_export_compare_cos.connect(cos_compare_fifo.analysis_export);
        sb_export_compare_sin.connect(sin_compare_fifo.analysis_export);
    endfunction: connect_phase

    virtual task run();
        forever begin
            cos_fifo.get(tx_cos);
            sin_fifo.get(tx_sin);
            cos_compare_fifo.get(tx_cmp_cos);
            sin_compare_fifo.get(tx_cmp_sin);            
            comparison();
        end
    endtask: run

    virtual function void comparison();
        if (tx_cos.theta_in != tx_cmp_cos.theta_in) begin
            // use uvm_error to report errors and continue
            // use uvm_fatal to halt the simulation on error
            `uvm_info("SB_CMP", tx_cos.sprint(), UVM_LOW);
            `uvm_info("SB_CMP", tx_cmp_cos.sprint(), UVM_LOW);
            `uvm_fatal("SB_CMP", $sformatf("Test: Failed! Expecting: %04h, Received: %04h", tx_cmp_cos.theta_in, tx_cos.theta_in))
        end
        if (tx_sin.theta_in != tx_cmp_sin.theta_in) begin
            // use uvm_error to report errors and continue
            // use uvm_fatal to halt the simulation on error
            `uvm_info("SB_CMP", tx_sin.sprint(), UVM_LOW);
            `uvm_info("SB_CMP", tx_cmp_sin.sprint(), UVM_LOW);
            `uvm_fatal("SB_CMP", $sformatf("Test: Failed! Expecting: %04h, Received: %04h", tx_cmp_sin.theta_in, tx_sin.theta_in))
        end
    endfunction: comparison
endclass: my_uvm_scoreboard
