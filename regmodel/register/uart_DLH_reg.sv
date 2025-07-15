class uart_DLH_reg extends uvm_reg;
	`uvm_object_utils(uart_DLH_reg)

	uvm_reg_field rsvd;
	rand uvm_reg_field DLH;

	function new(string name="uart_DLH_reg");
		super.new(name, 32, UVM_NO_COVERAGE);
	endfunction

	virtual function void build();
		rsvd = uvm_reg_field::type_id::create("rsvd");
		DLH = uvm_reg_field::type_id::create("DLH");

		rsvd.configure(this, 24, 8, "RO", 1'b0, 24'b0, 1, 1, 1);
		DLH.configure(this, 8, 0, "RW", 1'b0, 8'b0, 1, 1, 1);
	endfunction
endclass
