class interrupt_parity_error_dis_test extends uart_base_test;
	`uvm_component_utils(interrupt_parity_error_dis_test)

	

	function new(string name="interrupt_parity_error_dis_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		assert(cfg.randomize() with {
			mode == uart_config::TX;
			parity_type != uart_config::NONE;
		})
		else `uvm_fatal(get_type_name(), $sformatf("Failed to random uart_config"))	

		config_uart(cfg);
	endfunction
	
	virtual task run_phase(uvm_phase phase);
		uvm_status_e status;
		bit[31:0] data;
		bit[31:0] rdata;
		bit has_toggle = 0;
		phase.raise_objection(this);

		regmodel.FSR.write(status, 32'h0000_0010);
		regmodel.IER.write(status, 32'h0000_0000);
		regmodel.MDR.write(status, config_mdr());
		regmodel.DLL.write(status, config_dll());
		regmodel.DLH.write(status, config_dlh());
		regmodel.LCR.write(status, config_lcr());

		fork 
			repeat(2) begin	
				seq = uart_sequence::type_id::create("seq");
				seq.start(env.uart_agt.sequencer);
				regmodel.LCR.write(status, config_lcr_parity_error());
				
			end

			begin
				`uvm_info(get_type_name(), "Check first time", UVM_LOW)
				wait(env.uart_agt.monitor.transfer_parity_done);
				regmodel.FSR.read(status, data);
				
				case ({data[4], ahb_vif.interrupt})
					2'b01 : `uvm_error(get_type_name(), "Interrupt rise, FSR record correct status")
					2'b10 : `uvm_error(get_type_name(), "FSR record incorrect status")
					2'b11 : `uvm_error(get_type_name(), "Interrupt rise, FSR record incorrect status")
				endcase
				
				regmodel.FSR.write(status, 32'h0000_0010);
				wait(env.uart_agt.monitor.transfer_parity_done);

				`uvm_info(get_type_name(), "Check second time", UVM_LOW)
				regmodel.FSR.read(status, data);
				
				case ({data[4], ahb_vif.interrupt})
					2'b00 : `uvm_error(get_type_name(), "FSR record incorrect status")
					2'b11 : `uvm_error(get_type_name(), "Interrupt rise, FSR record correct status")
					2'b01 : `uvm_error(get_type_name(), "Interrupt rise, FSR record incorrect status")
				endcase
			end
		join
	
		phase.drop_objection(this);
	endtask
endclass
