class uart_environment extends uvm_env;
	`uvm_component_utils(uart_environment)

	virtual uart_if uart_vif;
	virtual ahb_if ahb_vif;

	uart_config cfg;

	uart_scoreboard sb;
	uart_agent uart_agt;
	ahb_agent ahb_agt;

	uart_reg_block regmodel;
	uart_reg2ahb_adapter ahb_adapter;
	uvm_reg_predictor #(ahb_transaction) ahb_predictor;

	function new(string name="uart_environment", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("build_phase", "Entered...", UVM_HIGH)

		if(!uvm_config_db #(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif))
			`uvm_fatal(get_type_name(), $sformatf("Failed to get ahb_if"))
		if(!uvm_config_db #(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_if"))
		if(!uvm_config_db #(uart_config)::get(this, "", "cfg", cfg))
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_config"))

		ahb_agt = ahb_agent::type_id::create("ahb_agt", this);
		uart_agt = uart_agent::type_id::create("uart_agt", this);
		sb = uart_scoreboard::type_id::create("sb", this);

		ahb_adapter = uart_reg2ahb_adapter::type_id::create("ahb_adapter");
		regmodel = uart_reg_block::type_id::create("regmodel", this);
		regmodel.build();

		ahb_predictor = uvm_reg_predictor #(ahb_transaction)::type_id::create("ahb_predictor", this);

		uvm_config_db #(virtual uart_if)::set(this, "uart_agt", "uart_vif", uart_vif);
		uvm_config_db #(virtual ahb_if)::set(this, "ahb_agt", "ahb_vif", ahb_vif);
		uvm_config_db #(virtual ahb_if)::set(this, "uart_agt", "ahb_vif", ahb_vif);
		uvm_config_db #(uart_config)::set(this, "uart_agt", "cfg", cfg);
		uvm_config_db #(uart_config)::set(this, "sb", "cfg", cfg);

		`uvm_info("build_phase", "Exitting...", UVM_HIGH)
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info("connect_phase", "Entered...", UVM_HIGH)
		if (regmodel.get_parent() == null)
			regmodel.ahb_map.set_sequencer(ahb_agt.sequencer, ahb_adapter);

		ahb_predictor.map = regmodel.ahb_map;
		ahb_predictor.adapter = ahb_adapter;
		ahb_agt.monitor.mon_ap.connect(ahb_predictor.bus_in);

		uart_agt.monitor.uart_observe_port_tx.connect(sb.tx_export);
		uart_agt.monitor.uart_observe_port_rx.connect(sb.rx_export);
		ahb_agt.monitor.mon_ap.connect(sb.ahb_export);
		`uvm_info("connect_phase", "Exiting...", UVM_HIGH)
	endfunction
endclass	
