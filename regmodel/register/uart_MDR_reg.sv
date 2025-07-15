class uart_MDR_reg extends uvm_reg;
	`uvm_object_utils(uart_MDR_reg)

	uvm_reg_field rsvd;
	rand uvm_reg_field MDR;
	
	function new(string name="uart_MDR_reg");
		super.new(name, 32, UVM_NO_COVERAGE);
	endfunction

	virtual function void build();
		rsvd = uvm_reg_field::type_id::create("rsvd");
		MDR = uvm_reg_field::type_id::create("MDR");

		rsvd.configure(this, 31, 1, "RO", 1'b0, 34'b0, 1, 1, 1);
		MDR.configure(this, 1, 0, "RW", 1'b0, 1'b0, 1, 1, 1);
	endfunction
endclass
