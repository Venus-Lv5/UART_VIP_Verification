class mismatch_stop_width_test extends uart_base_test;
	`uvm_component_utils(mismatch_stop_width_test)

	

	function new(string name="mismatch_stop_width_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		assert(cfg.randomize() with {
			mode == uart_config::FULL;
			stop_width == 2;
		})
		else `uvm_fatal(get_type_name(), $sformatf("Failed to random uart_config"))	

		config_uart(cfg);
	endfunction
	
	virtual task run_phase(uvm_phase phase);
		uvm_status_e status;
		bit[31:0] data;
		bit[31:0] sdata;
		bit [31:0] lcr;
		phase.raise_objection(this);
		lcr = config_lcr();
		regmodel.FSR.write(status, 32'h0000_0010);
		regmodel.MDR.write(status, config_mdr());
		regmodel.DLL.write(status, config_dll());
		regmodel.DLH.write(status, config_dlh());
		regmodel.LCR.write(status, {26'h0, lcr[5:3], 1'b0, lcr[1:0]});


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

	virtual task main_phase(uvm_phase phase);
		phase.raise_objection(this);
		
//		err_catcher.add_error_catcher_msg("Data transfer from dut to uart mismatch");
//		err_catcher.add_error_catcher_msg("Parity transfer from dut to uart mismatch");
		err_catcher.add_error_catcher_msg("Stop width transfer from dut to uart mismatch");
	

//		err_catcher.add_error_catcher_msg("Data transfer from uart to dut mismatch");
//		err_catcher.add_error_catcher_msg("Parity transfer from uart to dut mismatch");

		phase.drop_objection(this);
	endtask

endclass
