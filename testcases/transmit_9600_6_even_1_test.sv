class transmit_9600_6_even_1_test extends uart_base_test;
	`uvm_component_utils(transmit_9600_6_even_1_test)

	

	function new(string name="transmit_9600_6_even_1_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		assert(cfg.randomize() with {
			mode == uart_config::RX;
			baudrate == 9600;
			data_width == 6;
			parity_type == uart_config::EVEN;
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
			sdata = $urandom_range(32'h0000_0000, 32'h0000_00FF);
			`uvm_info("run_phase", $sformatf("Send frame to uart with data = %0b", sdata), UVM_LOW)
			regmodel.TBR.write(status, sdata);
			wait(env.uart_agt.monitor.rx_capture_done);
		end
	
	
		phase.drop_objection(this);
	endtask
endclass
