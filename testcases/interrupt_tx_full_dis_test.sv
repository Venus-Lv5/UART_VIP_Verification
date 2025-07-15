class interrupt_tx_full_dis_test extends uart_base_test;
	`uvm_component_utils(interrupt_tx_full_dis_test)

	

	function new(string name="interrupt_tx_full_dis_test", uvm_component parent);
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
		phase.raise_objection(this);

		regmodel.FSR.write(status, 32'h0000_0010);
		regmodel.IER.write(status, 32'h0000_0000);
		regmodel.MDR.write(status, config_mdr());
		regmodel.DLL.write(status, config_dll());
		regmodel.DLH.write(status, config_dlh());
		regmodel.LCR.write(status, config_lcr());

		repeat(16) begin	
			sdata = $urandom_range(32'h0000_0000, 32'h0000_00FF);
			regmodel.TBR.write(status, sdata);
		end
		regmodel.FSR.read(status, data);
		case ({data[0], ahb_vif.interrupt})
			2'b01 : `uvm_error(get_type_name(), "Interrupt rise soon, FSR record correct status")
			2'b10 : `uvm_error(get_type_name(), "FSR record incorrect status")
			2'b11 : `uvm_error(get_type_name(), "Interrupt rise soon, FSR record incorrect status")
		endcase	
		sdata = $urandom_range(32'h0000_0000, 32'h0000_00FF);
		regmodel.TBR.write(status, sdata);
		regmodel.FSR.read(status, data);
		case ({data[0], ahb_vif.interrupt})
			2'b00 : `uvm_error(get_type_name(), "FSR record incorrect status")
			2'b11 : `uvm_error(get_type_name(), "Interrupt rise, FSR record correct status")
			2'b01 : `uvm_error(get_type_name(), "Interrupt rise, FSR record incorrect status")
		endcase
	
		phase.drop_objection(this);
	endtask
endclass
