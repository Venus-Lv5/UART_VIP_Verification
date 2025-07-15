`uvm_analysis_imp_decl(_tx)
`uvm_analysis_imp_decl(_rx)
`uvm_analysis_imp_decl(_ahb)

class uart_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(uart_scoreboard)

	`include "uart_coverage.sv"

	uvm_analysis_imp_tx #(uart_transaction, uart_scoreboard) tx_export;
	uvm_analysis_imp_rx #(uart_transaction, uart_scoreboard) rx_export;
	uvm_analysis_imp_ahb #(ahb_transaction, uart_scoreboard) ahb_export;

	uart_transaction uart_tx_queue[$];
	uart_transaction uart_rx_queue[$];
	ahb_transaction ahb_tx_queue[$];
	ahb_transaction ahb_rx_queue[$];
	ahb_transaction ahb_lcr_queue[$];
	ahb_transaction ahb_fsr_queue[$];
	ahb_transaction ahb_rsvd_queue[$];

	uart_transaction uart_tx_trans;
	uart_transaction uart_rx_trans;

	ahb_transaction ahb_lcr_trans;
	ahb_transaction ahb_fsr_trans;
	ahb_transaction ahb_tx_trans;
	ahb_transaction ahb_rx_trans;
	ahb_transaction ahb_rsvd_trans;

	uart_config cfg;
	uvm_status_e status;
	bit[31:0] tbr_data = 32'h0;

	bit check_wr_tx_full = 0;

	function new (string name="uart_scoreboard", uvm_component parent);
		super.new(name, parent);
		
		coverage_cfg = new();
		UART_COVERGROUP = new();
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if (!uvm_config_db #(uart_config)::get(this, "", "cfg", cfg))
			`uvm_fatal(get_type_name(), $sformatf("Failed to get uart_config"))

		tx_export = new("tx_export", this);
		rx_export = new("rx_export", this);
		ahb_export = new("ahb_export", this);
		sample_uart_fc(cfg);
	endfunction

	virtual task run_phase(uvm_phase phase);
	endtask

	virtual function void write_tx(uart_transaction trans);
		`uvm_info("run_phase", $sformatf("Get frame data from tx: \n%s", trans.sprint()), UVM_LOW)
		uart_tx_queue.push_back(trans);
	endfunction

	virtual function void write_rx(uart_transaction trans);
		`uvm_info("run_phase", $sformatf("Get frame data from rx: \n%s", trans.sprint()), UVM_LOW)
		uart_rx_queue.push_back(trans);
		compare();
	endfunction

	virtual function void write_ahb(ahb_transaction trans);
		if(trans.xact_type == ahb_transaction::WRITE) begin
			case(trans.addr)
				10'h0C: ahb_lcr_queue.push_back(trans);
				10'h18: ahb_tx_queue.push_back(trans);
			endcase
		end
		else if (trans.xact_type == ahb_transaction::READ) begin
			if (trans.addr == 10'h1C)
				ahb_rx_queue.push_back(trans);
			if (trans.addr == 10'h14)
				ahb_fsr_queue.push_back(trans);
			if (trans.addr <= 10'h3FF && trans.addr >= 10'h20) begin
				ahb_rsvd_queue.push_back(trans);
				check_rsvd();
			end
			
		end
		compare();
	endfunction

	function uart_config::parity_type_enum cal_parity (uart_transaction trans);
//		$display("%0b", trans.parity);

		int count = 0;
		for (int i=0; i<cfg.data_width; i++) begin
			if(trans.data[i] == 1)
				count++;
		end

		if(trans.parity == 1) count++;
		if(trans.parity === 1'bx) return uart_config::NONE;
		else if(count%2==0) return uart_config::EVEN;
		else if(count%2==1) return uart_config::ODD;
		
	endfunction

	function bit convert_stopbit (uart_transaction trans);
		if (trans.stop == 2'b11) return 1'b1;
		if (trans.stop == 2'b01) return 1'b0;
	endfunction


	function void check_TX_data();
		while (ahb_tx_queue.size()>0 && uart_rx_queue.size()>0) begin
			ahb_tx_trans = ahb_tx_queue.pop_front();
			uart_rx_trans = uart_rx_queue.pop_front();
			tbr_data = 0;
			`uvm_info(get_type_name(), "Entered check_TX_data", UVM_LOW)
			case (cfg.data_width)
				5: tbr_data[4:0] = ahb_tx_trans.data[4:0];
				6: tbr_data[5:0] = ahb_tx_trans.data[5:0];
				7: tbr_data[6:0] = ahb_tx_trans.data[6:0];
				8: tbr_data[7:0] = ahb_tx_trans.data[7:0];
			endcase
//			`uvm_info("run_phase", $sformatf("Drive %0b to uart", tbr_data), UVM_LOW)
			if (tbr_data != uart_rx_trans.data)
				`uvm_error(get_type_name(), $sformatf("Data transfer from dut to uart mismatch"))
			if (ahb_lcr_trans.data[3] == 0)
				if (cal_parity(uart_rx_trans) != uart_config::NONE)
					`uvm_error(get_type_name(), $sformatf("Parity_en transfer dut to uart mismatch"))
			if (ahb_lcr_trans.data[3] != 0) begin
				if (cal_parity(uart_rx_trans) == uart_config::NONE)
					`uvm_error(get_type_name(), $sformatf("Parity_en transfer from dut to uart mismatch"))
				else begin 
		
					if (cal_parity(uart_rx_trans) !== cfg.parity_type)
						`uvm_error(get_type_name(), $sformatf("Parity transfer from dut to uart mismatch"))
				end
			end

			if (ahb_lcr_trans.data[2] != convert_stopbit(uart_rx_trans))
				`uvm_error(get_type_name(), $sformatf("Stop width transfer from dut to uart mismatch"))
			`uvm_info(get_type_name(), "Exitting check_TX_data", UVM_LOW)

		end
	endfunction

	function void check_RX_data();
		while (ahb_rx_queue.size()>0 && uart_tx_queue.size()>0 && ahb_fsr_queue.size()>0) begin
			ahb_rx_trans = ahb_rx_queue.pop_front();
			uart_tx_trans = uart_tx_queue.pop_front();
			ahb_fsr_trans = ahb_fsr_queue.pop_front();
			`uvm_info(get_type_name(), "Entered check_RX_data", UVM_LOW)
		
			if (ahb_rx_trans.data != uart_tx_trans.data)
				`uvm_error(get_type_name(), $sformatf("Data transfer from uart to dut mismatch"))
			if (ahb_fsr_trans.data[4] == 1)
				`uvm_error(get_type_name(), $sformatf("Parity transfer from uart to dut mismatch"))

			`uvm_info(get_type_name(), "Exitting check_RX_data", UVM_LOW)
		end
	endfunction


	function void compare();
		while (ahb_lcr_queue.size()>0)
			ahb_lcr_trans = ahb_lcr_queue.pop_front();
		if(check_wr_tx_full)
			check_wr_when_tx_full();
		else begin
			case(cfg.mode) 
				uart_config::TX : check_RX_data();
				uart_config::RX : check_TX_data();
				uart_config::FULL:
					fork
						check_RX_data();
						check_TX_data();
					join
			endcase
		end
	endfunction

	function void check_rsvd();
		while(ahb_rsvd_queue.size()>0) begin
			ahb_rsvd_trans = ahb_rsvd_queue.pop_front();
			if(ahb_rsvd_trans.data != 32'hFFFF_FFFF)
				`uvm_error(get_type_name(), "Rsvd value mismatch with spec")
			if(ahb_rsvd_trans.resp ==0)
				`uvm_error(get_type_name(), "Rsvd not give response")
		end
	endfunction

	function void check_wr_when_tx_full();
		while(ahb_tx_queue.size()>0 && uart_rx_queue.size()>0) begin
			ahb_tx_trans = ahb_tx_queue.pop_front();
			uart_rx_trans = uart_rx_queue.pop_front();
			
			`uvm_info(get_type_name(), "Entered check wr when tx full", UVM_LOW)
			if (ahb_tx_trans.data != uart_rx_trans.data)
				`uvm_error(get_type_name(), "Data transfer from dut to uart mismatch")
			if (uart_rx_trans.data == 32'h0000_00FF) begin
				`uvm_error(get_type_name(), "Data is not dropped when tx fifo full")
				break;
			end
			`uvm_info(get_type_name(), "Exiting check wr when tx full", UVM_LOW)
		end
	endfunction

	
	function void check_wr_when_tx_full_en();
		check_wr_tx_full = 1;
	endfunction
	
	function void sample_uart_fc(uart_config cfg);
		$cast(coverage_cfg, cfg);
		UART_COVERGROUP.sample();
	endfunction
endclass

