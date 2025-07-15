class wr_when_tx_full_test extends uart_base_test;
	`uvm_component_utils(wr_when_tx_full_test)

	time t1, t2, rx_capture_time;
	function new(string name="wr_when_tx_full_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		assert(cfg.randomize() with {
			mode == uart_config::RX;
			data_width == 8;
		})
		else `uvm_fatal(get_type_name(), $sformatf("Failed to random uart_config"))	

		config_uart(cfg);
	endfunction
	
	virtual task run_phase(uvm_phase phase);
		uvm_status_e status;
		bit[31:0] data;
		bit[31:0] sdata;
		int count = 0;
		phase.raise_objection(this);

		regmodel.FSR.write(status, 32'h0000_0010);
		regmodel.IER.write(status, 32'h0000_0001);
		regmodel.MDR.write(status, config_mdr());
		regmodel.DLL.write(status, config_dll());
		regmodel.DLH.write(status, config_dlh());
		regmodel.LCR.write(status, config_lcr());
		env.sb.check_wr_when_tx_full_en();

		repeat (17) begin	
			sdata = $urandom_range(32'h0000_0000, 32'h0000_00FE);
			regmodel.TBR.write(status, sdata);
		end
		
		regmodel.TBR.write(status, 32'h0000_00FF);
		repeat (17) begin
			t1 = $time;
			wait(env.uart_agt.monitor.rx_capture_done);
			t2 = $time;
		end
		rx_capture_time = t2 - t1;
		#rx_capture_time;
	
		phase.drop_objection(this);
	endtask
endclass
