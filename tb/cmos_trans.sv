`ifndef CMOS_TRANS
`define CMOS_TRANS

class cmos_trans extends uvm_sequence_item;                                  

	rand int unsigned	size;
	rand int 			column_size;
	rand int 			row_size;
	rand int 			bank_size;
	rand int 			ref_gap;
	rand int 			vsyn_high_width;
	rand bit [15:0]		data[];
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
		`uvm_field_int      (size, UVM_DEFAULT)
		`uvm_field_int      (column_size, UVM_DEFAULT)
		`uvm_field_int      (row_size, UVM_DEFAULT)
		`uvm_field_int      (bank_size, UVM_DEFAULT)
		`uvm_field_int      (ref_gap, UVM_DEFAULT)
		`uvm_field_int      (vsyn_high_width, UVM_DEFAULT)
		`uvm_field_array_int(data, UVM_DEFAULT)
	`uvm_object_utils_end

  function new (string name = "cmos_trans_inst");
    super.new(name);
  endfunction : new

endclass : cmos_trans

`endif	//CMOS_TRANS

