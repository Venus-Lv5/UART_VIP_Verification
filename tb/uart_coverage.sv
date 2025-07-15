uart_config coverage_cfg;

covergroup UART_COVERGROUP;
	mode : coverpoint coverage_cfg.mode{
		bins TX = {uart_config::TX};
		bins RX = {uart_config::RX};
		bins FULL = {uart_config::FULL};
	}

	baudrate : coverpoint coverage_cfg.baudrate{
		bins baudrate[] = {2400, 4800, 9600, 19200, 38400, 76800, 115200};
	}

	over_sampling : coverpoint coverage_cfg.ovsmp{
		bins x13 = {uart_config::x13};
		bins x16 = {uart_config::x16};
	}

	data_width : coverpoint coverage_cfg.data_width{
		bins data_width[] = {[5:8]};
	}

	parity_type : coverpoint coverage_cfg.parity_type{
		bins NONE = {uart_config::NONE};
		bins EVEN = {uart_config::EVEN};
		bins ODD = {uart_config::ODD};
	}

	stop_width : coverpoint coverage_cfg.stop_width{
		bins stop_width[] = {[1:2]};
	}

	ovsmp_baudrate_test: cross over_sampling, baudrate;

	mode_baudrate_datawidth_parity_stop_width_test : cross mode, baudrate, data_width, parity_type, stop_width;
endgroup
