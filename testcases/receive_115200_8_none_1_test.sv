class receive_115200_8_none_1_test extends uart_base_test;
	`uvm_component_utils(receive_115200_8_none_1_test)

	

	function new(string name="receive_115200_8_none_1_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		assert(cfg.randomize() with {
			mode == uart_config::TX;
			baudrate == 115200;
			data_width == 8;
			parity_type == uart_config::NONE;
			stop_width == 1;
		})
		else `uvm_fatal(get_type_name(), $sformatf("Failed to random uart_config"))	

		config_uart(cfg);
	endfunction
	
	virtual task run_phase(uvm_phase phase);
		uvm_status_e status;
		bit[31:0] data;
		bit[31:0] sdata;
		phase.raise_objection(this);

		regmodel.FSR.write(status, 32'h0000_0010);
		regmodel.MDR.write(status, config_mdr());
		regmodel.DLL.write(status, config_dll());
		regmodel.DLH.write(status, config_dlh());
		regmodel.LCR.write(status, config_lcr());

		repeat(3) begin	
			seq = uart_sequence::type_id::create("seq");
			seq.start(env.uart_agt.sequencer);
		
			regmodel.RBR.read(status, data);
			regmodel.FSR.read(status, data);
		end
	
		phase.drop_objection(this);
	endtask
endclass
