`ifndef CMOS_SEQ_LIB__SV
`define CMOS_SEQ_LIB__SV

virtual class cmos_base_sequence extends uvm_sequence #(cmos_trans);

	function new(string name="cmos_base_sequence");
		super.new(name);
	endfunction
  
	virtual task pre_body();
		if (starting_phase!=null) begin
		   `uvm_info(get_type_name(),
			 $sformatf("%s pre_body() raising %s objection", 
				   get_sequence_path(),
				   starting_phase.get_name()), UVM_MEDIUM);
		   starting_phase.raise_objection(this);
		end
	endtask

	virtual task post_body();
		if (starting_phase!=null) begin
		    `uvm_info(get_type_name(),
				$sformatf("%s post_body() dropping %s objection", 
				get_sequence_path(),
				starting_phase.get_name()), UVM_MEDIUM);
			starting_phase.drop_objection(this);
		end
	endtask
  
endclass : cmos_base_sequence


class send_one_seq extends cmos_base_sequence;

  function new(string name="send_one_seq");
    super.new(name);
  endfunction
  
  `uvm_object_utils(send_one_seq)
  
  rand int unsigned transmit_del = 0;	
  constraint transmit_del_ct { (transmit_del <= 10); }

	virtual task body();	
		#5ms
		repeat(2) begin
			`uvm_do_with(req, 
				{req.size == 12800;
				req.column_size == 800;
				req.row_size == 16;
				req.bank_size == 50;
				req.ref_gap == 16;
				req.vsyn_high_width == 100; } )
			`uvm_info(get_type_name(), "drive one frame finish\n", UVM_HIGH);
		end
	endtask
endclass : send_one_seq



`endif  //CMOS_SEQ_LIB__SV