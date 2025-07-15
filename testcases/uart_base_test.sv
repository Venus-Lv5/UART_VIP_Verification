class uart_base_test extends uvm_test;
	`uvm_component_utils(uart_base_test)

	uvm_report_server svr;
	uart_environment env;

	uart_reg_block regmodel;
	uart_sequence seq;

	virtual ahb_if ahb_vif;
	virtual uart_if uart_vif;

	uart_config cfg, cfg2;
	uart_error_catcher err_catcher;

	time usr_timeout = 1s;

	function new(string name="uart_base_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void config_uart(uart_config c);
		cfg.mode = c.mode;
		cfg.baudrate = c.baudrate;
		cfg.data_width = c.data_width;
		cfg.parity_type = c.parity_type;
		cfg.stop_width = c.stop_width;
		cfg.ovsmp = c.ovsmp;

		if (c.ovsmp == uart_config::x16)
			case(c.baudrate)
				2400: cfg.div = 2604;
				4800: cfg.div = 1302;
				9600: cfg.div = 651;
				19200: cfg.div = 325;
				38400: cfg.div = 163;
				76800: cfg.div = 81;
				115200: cfg.div = 54;
				default: cfg.div = 1e8/(16*c.baudrate);
			endcase
		else if (c.ovsmp == uart_config::x13) 
			case(c.baudrate)
				2400: cfg.div = 3205;
				4800: cfg.div = 1602;
				9600: cfg.div = 801;
				19200: cfg.div = 401;
				38400: cfg.div = 200;
				76800: cfg.div = 100;
				115200: cfg.div = 67;
				default: cfg.div = 1e8/(13*c.baudrate);
			endcase

		`uvm_info(get_type_name(), $sformatf("Completed config uart: \n%s", cfg.sprint()), UVM_LOW)
	endfunction


	virtual function bit[31:0]  config_lcr();
		bit [31:0] lcr = 3;
		lcr[5] = 1;
		lcr[4] = (cfg.parity_type == uart_config::EVEN)? 1: 0;
		lcr[3] = (cfg.parity_type == uart_config::NONE)? 0: 1;
		lcr[2] = (cfg.stop_width == 2)? 1: 0;
		lcr[1:0] = cfg.data_width - 5;
		return lcr;
		`uvm_info(get_type_name(), $sformatf("Completed config LCR: \n%0b", lcr), UVM_LOW)
	endfunction

	virtual function bit[31:0] config_mdr();
		bit[31:0] mdr = 0;
		case(cfg.ovsmp)
			uart_config::x13: mdr[0] = 1;
			uart_config::x16: mdr[0] = 0;
			default mdr[0] = 0;
		endcase
		return mdr;
		`uvm_info(get_type_name(), $sformatf("Completed config MDR: \n%0b", mdr), UVM_LOW)
	endfunction

	virtual function bit[31:0] config_dll();
		bit[31:0] dll = 0;
		dll[7:0] = cfg.div[7:0];
		return dll;
		`uvm_info(get_type_name(), $sformatf("Completed config DLL: \n%0b", dll), UVM_LOW)
	endfunction

	virtual function bit[31:0] config_dlh();
		bit[31:0] dlh = 0;
		dlh[7:0] = cfg.div[15:8];
		return dlh;
		`uvm_info(get_type_name(), $sformatf("Completed config DLH: \n%0b", dlh), UVM_LOW)
	endfunction

	
	virtual function bit[31:0] config_lcr_parity_error();
		bit [31:0] lcr = 3;
		lcr[5] = 1;
		lcr[4] = (cfg.parity_type == uart_config::EVEN)? 0: 1;
		lcr[3] = 1;
		lcr[2] = (cfg.stop_width == 2)? 1: 0;
		lcr[1:0] = cfg.data_width - 5;
		return lcr;
		`uvm_info(get_type_name(), $sformatf("Completed config LCR with parity_error: \n%0b", lcr), UVM_LOW)
	endfunction

	


	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("build_phase", "Entered...", UVM_HIGH)

		if (!uvm_config_db #(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_if"))
		if (!uvm_config_db #(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif))
			`uvm_fatal(get_type_name(), $sformatf("Failed to get ahb_if"))
		
		env = uart_environment::type_id::create("env", this);
		err_catcher = uart_error_catcher::type_id::create("err_catcher");
		cfg = uart_config::type_id::create("cfg", this);
		uvm_report_cb::add(null, err_catcher);

		uvm_config_db #(virtual uart_if)::set(this, "env", "uart_vif", uart_vif);
		uvm_config_db #(virtual ahb_if)::set(this, "env", "ahb_vif", ahb_vif);
		uvm_config_db #(uart_config)::set(this, "env", "cfg", cfg);

		uvm_top.set_timeout(usr_timeout);
		`uvm_info("build_phase", "Exitting...", UVM_HIGH)
	endfunction


	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		this.regmodel = env.regmodel;
	endfunction

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction

	virtual function void final_phase(uvm_phase phase);
		super.final_phase(phase);
		`uvm_info("final_phase", "Entered...", UVM_HIGH)
		svr = uvm_report_server::get_server();
		if(svr.get_severity_count(UVM_FATAL) + svr.get_severity_count(UVM_ERROR)) begin
			`uvm_info(get_type_name(), "--------------------------------", UVM_NONE)
			`uvm_info(get_type_name(), "----	TEST FAILED	----", UVM_NONE)
			`uvm_info(get_type_name(), "--------------------------------", UVM_NONE)
		end
		else begin
			`uvm_info(get_type_name(), "--------------------------------", UVM_NONE)
			`uvm_info(get_type_name(), "----	TEST PASSED	----", UVM_NONE)
			`uvm_info(get_type_name(), "--------------------------------", UVM_NONE)
		end

		`uvm_info("final_phase", "Exitting...", UVM_HIGH)
	endfunction
endclass
