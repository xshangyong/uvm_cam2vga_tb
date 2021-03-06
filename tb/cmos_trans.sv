`ifndef CMOS_TRANS
`define CMOS_TRANS

class cmos_trans extends uvm_sequence_item;                                  

	rand int unsigned	size;
	rand int unsigned	column_size;
	rand int unsigned	row_size;
	rand int unsigned	bank_size;
	rand int unsigned	ref_gap;
	rand int unsigned	vsyn_high_width;
	rand bit [15:0]		data[];
	rand int unsigned 	column_ar[$];
//	constraint data_size {
//		data.size() == column_size*row_size;
//	}

	constraint cc_size {
		size <= 384000;
	}
	constraint crow_size {
		column_size <= 800;
	}
	constraint ccolumn_size {
		row_size <= 480;
	}
	constraint c_datasize {
		data.size() == size;
	}
	`uvm_object_utils_begin(cmos_trans)
//		`uvm_field_array_int(data, UVM_DEFAULT)
//		`uvm_field_array_int(column_ar, UVM_DEFAULT)
		`uvm_field_int(size, UVM_DEFAULT)
		`uvm_field_int(column_size, UVM_DEFAULT)
		`uvm_field_int(row_size, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "cmos_trans_inst");
	super.new(name);
	endfunction : new
	
	function void set_zero();
		this.size = 0;
		this.column_size = 0;
		this.row_size = 0;
		this.bank_size = 0;
		this.data = new[0];
	endfunction
		
	extern function bit compare_data(cmos_trans tr);
endclass

function bit cmos_trans::compare_data(cmos_trans tr);
	bit res = 1;
	if(tr == null) begin
		`uvm_fatal("cmos_trans", "tr is null");
	end
	for(int i=0;i<tr.data.size();i++)begin
		if(data[i] != tr.data[i]) begin
			res = 0;
		end
	end
	return res;
endfunction
`endif	//CMOS_TRANS

