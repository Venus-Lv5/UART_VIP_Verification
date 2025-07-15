class uart_sequence extends uvm_sequence #(uart_transaction);
	`uvm_object_utils(uart_sequence)

	function new(string name="uart_sequence");
		super.new(name);
	endfunction

	virtual task body();
		req = uart_transaction::type_id::create("req");
		start_item(req);
		if(req.randomize()) 
			`uvm_info(get_type_name(), $sformatf("Send req to driver: \n%s", req.sprint()), UVM_LOW)
		else
			`uvm_fatal(get_type_name(), $sformatf("Randomize failed"))

		finish_item(req);
		get_response(rsp);
	endtask: body
endclass: uart_sequence
