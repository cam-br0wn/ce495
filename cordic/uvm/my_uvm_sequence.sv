import uvm_pkg::*;


class my_uvm_transaction extends uvm_sequence_item;
    logic [15:0]     theta_in;
    logic           wr_en;


    function new(string name = "");
        super.new(name);
    endfunction: new

    `uvm_object_utils_begin(my_uvm_transaction)
        `uvm_field_int(theta_in, UVM_ALL_ON)
    `uvm_object_utils_end
endclass: my_uvm_transaction


class my_uvm_sequence extends uvm_sequence#(my_uvm_transaction);
    `uvm_object_utils(my_uvm_sequence)

    function new(string name = "");
        super.new(name);
    endfunction: new

    task body();        
        my_uvm_transaction tx;
        int in_file, cos_cmp_file, sin_cmp_file, theta_lines;
        logic [31:0] din;
        int i, j;

        `uvm_info("SEQ_RUN", $sformatf("Loading file %s...", THETA_IN_NAME), UVM_LOW);

        in_file = $fopen(THETA_IN_NAME, "rb");
        cos_cmp_file = $fopen(COS_CMP_NAME, "rb");
        sin_cmp_file = $fopen(SIN_CMP_NAME, "rb");


        if ( !in_file ) begin
            `uvm_fatal("SEQ_RUN", $sformatf("Failed to open file %s...", THETA_IN_NAME));
        end
        if ( !cos_cmp_file ) begin
            `uvm_fatal("SEQ_RUN", $sformatf("Failed to open comparison file %s...", COS_CMP_NAME));
        end
        if ( !sin_cmp_file ) begin
            `uvm_fatal("SEQ_RUN", $sformatf("Failed to open comparison file %s...", SIN_CMP_NAME));
        end

        theta_lines = 721;

        i = 0;
        while ( i < theta_lines * 5 ) begin
            tx = my_uvm_transaction::type_id::create(.name("tx"), .contxt(get_full_name()));
            start_item(tx);
            j = $fread(din, in_file, i, 9);
            tx.wr_en = 1'b1;
            tx.theta_in = din;
            //`uvm_info("SEQ_RUN", tx.sprint(), UVM_LOW);
            finish_item(tx);
            i += 9;
        end
        tx.wr_en = 1'b0;

        `uvm_info("SEQ_RUN", $sformatf("Closing file %s...", THETA_IN_NAME), UVM_LOW);
        $fclose(in_file);
    endtask: body
endclass: my_uvm_sequence

typedef uvm_sequencer#(my_uvm_transaction) my_uvm_sequencer;
