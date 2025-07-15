class uart_reg2ahb_adapter extends uvm_reg_adapter;
  `uvm_object_utils(uart_reg2ahb_adapter)

  function new(string name="uart_reg2ahb_adapter");
    super.new(name);
    // Does the protocol the Agent is modeling support byte enables?
    // 0 = NO
    // 1 = YES
    supports_byte_enable = 0;

    // Does the Agent's Driver provide separate response sequence items?
    // i.e. Does the driver call seq_item_port.put()
    // and do the sequences call get_response()?
    // 0 = NO
    // 1 = YES
    provides_responses = 1;
  endfunction

  //--------------------------------------------------------------------
  // reg2bus
  //--------------------------------------------------------------------
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
  	ahb_transaction ahb = ahb_transaction::type_id::create("ahb");
	ahb.xact_type = (rw.kind == UVM_WRITE)?ahb_transaction::WRITE : ahb_transaction::READ;
	ahb.addr = rw.addr;
	ahb.data = rw.data;
	`uvm_info(get_type_name(), $sformatf("reg2bus: address = 0x%0h, data = 0x%0h, kind = %0s", ahb.addr, ahb.data, ahb.xact_type.name()), UVM_HIGH)
	return ahb;
  endfunction 
  
  //--------------------------------------------------------------------
  // bus2reg
  //--------------------------------------------------------------------
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
  	ahb_transaction ahb;
	if (!$cast(ahb, bus_item))
		`uvm_fatal(get_type_name(), $sformatf("Failed to cast bus item to ahb transaction"))
	rw.kind = (ahb.xact_type == ahb_transaction::WRITE) ? UVM_WRITE : UVM_READ;
	rw.addr = ahb.addr;
	rw.data = ahb.data;
	`uvm_info(get_type_name(), $sformatf("bus2reg: address = 0x%0h, data = 0x%0h, kind = %0s, status = %0s", rw.addr, rw.data, rw.kind.name(), rw.status.name()), UVM_HIGH)

  endfunction 

endclass

