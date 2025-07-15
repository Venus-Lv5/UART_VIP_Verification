class rsvd_sequence extends uvm_sequence #(ahb_transaction);
	`uvm_object_utils(rsvd_sequence)

	int rsvd_addr;

	function new(string name="rsvd_sequence");
		super.new(name);
	endfunction

	virtual task body();
		rsvd_addr = $urandom_range(10'h20, 10'h3FF);
		req = ahb_transaction::type_id::create("req");

		start_item(req);
		if(req.randomize() with {
			addr == rsvd_addr;
			xact_type == ahb_transaction::WRITE;
			burst_type == ahb_transaction::SINGLE;
			xfer_size == ahb_transaction::SIZE_32BIT;
		}) 
			`uvm_info(get_type_name(), $sformatf("Send req to driver: \n%s", req.sprint()), UVM_LOW)
		else
			`uvm_fatal(get_type_name(), $sformatf("Randomize failed"))

		finish_item(req);
		get_response(rsp);


		req = ahb_transaction::type_id::create("req");
		start_item(req);
		if(req.randomize() with {
			addr == rsvd_addr;
			xact_type == ahb_transaction::READ;
			burst_type == ahb_transaction::SINGLE;
			xfer_size == ahb_transaction::SIZE_32BIT;
		}) 
			`uvm_info(get_type_name(), $sformatf("Send req to driver: \n%s", req.sprint()), UVM_LOW)
		else
			`uvm_fatal(get_type_name(), $sformatf("Randomize failed"))
		finish_item(req);
		get_response(rsp);


	endtask: body
endclass 
