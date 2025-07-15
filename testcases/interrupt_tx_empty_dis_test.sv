class interrupt_tx_empty_dis_test extends uart_base_test;
	`uvm_component_utils(interrupt_tx_empty_dis_test)

	

	function new(string name="interrupt_tx_empty_dis_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		assert(cfg.randomize() with {
			mode == uart_config::RX;
		})
		else `uvm_fatal(get_type_name(), $sformatf("Failed to random uart_config"))	

		config_uart(cfg);
	endfunction
	
	virtual task run_phase(uvm_phase phase);
		uvm_status_e status;
		bit[31:0] data;
		bit[31:0] sdata;
		bit[31:0] lcr;
		phase.raise_objection(this);

		lcr = config_lcr();

		regmodel.FSR.write(status, 32'h0000_0010);
		regmodel.IER.write(status, 32'h0000_0000);
		regmodel.MDR.write(status, config_mdr());
		regmodel.DLL.write(status, config_dll());
		regmodel.DLH.write(status, config_dlh());
		regmodel.LCR.write(status, {26'h0, 1'b0, lcr[4:0]});

		
		`uvm_info(get_type_name(), "Check first time", UVM_LOW)
		repeat(2) begin
			sdata = $urandom_range(32'h0000_0000, 32'h0000_00FF);
			regmodel.TBR.write(status, sdata);
		end
		regmodel.FSR.read(status, data);
			
		case ({data[1], ahb_vif.interrupt})
			2'b01 : `uvm_error(get_type_name(), "Interrupt rise, FSR record correct status")
			2'b10 : `uvm_error(get_type_name(), "FSR record incorrect status")
			2'b11 : `uvm_error(get_type_name(), "Interrupt rise, FSR record incorrect status")
		endcase	
	

		`uvm_info(get_type_name(), "Check second time", UVM_LOW)
		regmodel.LCR.write(status, config_lcr());
		wait(env.uart_agt.monitor.rx_capture_done);
		regmodel.FSR.read(status, data);
		
		case ({data[1], ahb_vif.interrupt})
			2'b01 : `uvm_error(get_type_name(), "Interrupt rise, FSR record incorrect status")
			2'b11 : `uvm_error(get_type_name(), "Interrupt rise, FSR record correct status")
			2'b00 : `uvm_error(get_type_name(), "FSR record incorrect status")
		endcase
	
		phase.drop_objection(this);
	endtask
endclass
