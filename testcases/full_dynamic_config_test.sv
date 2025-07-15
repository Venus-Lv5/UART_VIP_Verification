class full_dynamic_config_test extends uart_base_test;
	`uvm_component_utils(full_dynamic_config_test)

	uart_config cfg_save;

	function new(string name="full_dynamic_config_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		assert(cfg.randomize() with {
			mode == uart_config::FULL;
		})
		else `uvm_fatal(get_type_name(), $sformatf("Failed to random uart_config"))	

		config_uart(cfg);
		cfg_save = uart_config::type_id::create("cfg_save");
		
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

		fork
			repeat(3) begin	
				seq = uart_sequence::type_id::create("seq");
				seq.start(env.uart_agt.sequencer);
			
				regmodel.RBR.read(status, data);
				regmodel.FSR.read(status, data);
			end

			repeat(3) begin
				sdata = $urandom_range(32'h0000_0000, 32'h0000_00FF);
				`uvm_info("run_phase", $sformatf("Send frame to uart with data = %0b", sdata), UVM_LOW)
				regmodel.TBR.write(status, sdata);
				wait(env.uart_agt.monitor.rx_capture_done);
			end
		join
		
		cfg_save.copy(cfg);
	
		assert(cfg.randomize() with {
			mode == uart_config::FULL;
			baudrate != cfg_save.baudrate;
			data_width != cfg_save.data_width;
			parity_type != cfg_save.parity_type;
			stop_width != cfg_save.stop_width;
		})
		else `uvm_fatal(get_type_name(), "Failed to random cfg")
		config_uart(cfg);

		regmodel.FSR.write(status, 32'h0000_0010);
		regmodel.MDR.write(status, config_mdr());
		regmodel.DLL.write(status, config_dll());
		regmodel.DLH.write(status, config_dlh());
		regmodel.LCR.write(status, config_lcr());

		fork
			repeat(3) begin	
				seq = uart_sequence::type_id::create("seq");
				seq.start(env.uart_agt.sequencer);
			
				regmodel.RBR.read(status, data);
				regmodel.FSR.read(status, data);
			end

			repeat(3) begin
				sdata = $urandom_range(32'h0000_0000, 32'h0000_00FF);
				`uvm_info("run_phase", $sformatf("Send frame to uart with data = %0b", sdata), UVM_LOW)
				regmodel.TBR.write(status, sdata);
				wait(env.uart_agt.monitor.rx_capture_done);
			end
		join	

			
		phase.drop_objection(this);
	endtask
endclass
