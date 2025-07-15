class uart_monitor extends uvm_monitor;
	`uvm_component_utils(uart_monitor)

	virtual uart_if uart_vif;
	virtual ahb_if ahb_vif;
	uart_config cfg;
	uart_transaction s_trans, r_trans;

	event rx_capture_done;
	event transfer_parity_done;

	uvm_analysis_port #(uart_transaction) uart_observe_port_tx;
	uvm_analysis_port #(uart_transaction) uart_observe_port_rx;

	function new(string name="uart_monitor", uvm_component parent);
		super.new(name, parent);
		uart_observe_port_tx = new("uart_observe_port_tx", this);
		uart_observe_port_rx = new("uart_observe_port_rx", this);
	endfunction: new

	virtual function void build_phase (uvm_phase phase);
		super.build_phase(phase);

		if (!uvm_config_db #(virtual uart_if)::get(this, "", "uart_vif", uart_vif))
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_if"))
		if (!uvm_config_db #(uart_config)::get(this, "", "cfg", cfg))
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_config"))
		if (!uvm_config_db #(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif))
			`uvm_fatal(get_type_name(), $sformatf("Failed to get ahb_vif"))
		
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		forever begin
			case (cfg.mode)
				uart_config::FULL : 
					fork
						tx_capture();
						rx_capture();
					join
				uart_config::TX : tx_capture();
				uart_config::RX : rx_capture();
			endcase
		end
	endtask: run_phase

	task tx_capture();
		wait (uart_vif.tx == 0);
		delay_clk(cal_delay_clk()/2);
		s_trans = uart_transaction::type_id::create("s_trans", this);
		//Data
		for(int i=0; i<cfg.data_width; i++) begin
			delay_clk(cal_delay_clk());
			s_trans.data[i] = uart_vif.tx;
		end

		//Parity
		if (!(cfg.parity_type == uart_config::NONE || cfg.data_width == 9)) begin
			delay_clk(cal_delay_clk());
			s_trans.parity = uart_vif.tx;
			->transfer_parity_done;
		end

		//Stop
		for (int i=0; i<cfg.stop_width; i++) begin
			delay_clk(cal_delay_clk());
			s_trans.stop[i] = 1;
		end
		`uvm_info("run_phase", $sformatf("Send s_trans from monitor to scoreboard: \n%s", s_trans.sprint()), UVM_LOW)

		uart_observe_port_tx.write(s_trans);
		delay_clk(cal_delay_clk()/2);
		$display("done");

	endtask: tx_capture

	task rx_capture();
		wait(uart_vif.rx == 0);
		delay_clk(cal_delay_clk()/2);
		r_trans = uart_transaction::type_id::create("r_trans", this);

		//Data
		for (int j=0; j<cfg.data_width; j++) begin
			delay_clk(cal_delay_clk());
			r_trans.data[j] = uart_vif.rx;
		end

		//Parity
		if (!(cfg.parity_type == uart_config::NONE || cfg.data_width == 9)) begin
			delay_clk(cal_delay_clk());
			r_trans.parity = uart_vif.rx;
		end

		//Stop
		for(int j=0; j<cfg.stop_width; j++) begin
			delay_clk(cal_delay_clk());
			r_trans.stop[j] = uart_vif.rx;
		end
		uart_observe_port_rx.write(r_trans);
		`uvm_info("run_phase", $sformatf("Send r_trans from monitor to scoreboard: \n%s", r_trans.sprint()), UVM_LOW)
		delay_clk(cal_delay_clk()/2);
		-> rx_capture_done;
	endtask: rx_capture

	function int cal_delay_clk();
		int n;
		case (cfg.ovsmp)
			uart_config::x16 : n = 16*cfg.div;
			uart_config::x13 : n = 13*cfg.div;
		endcase
		return n;
	endfunction

	task delay_clk(int n);
		repeat(n) @(posedge ahb_vif.HCLK);
	endtask

endclass: uart_monitor

