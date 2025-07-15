class uart_config extends uvm_object;
	typedef enum bit [1:0] {
		NONE = 0,
		ODD = 1,
		EVEN = 2
	} parity_type_enum;

	typedef enum int {
		TX = 1,
		RX = 2,
		FULL = 3
	} mode_enum;

	typedef enum bit {
		x16 = 0,
		x13 = 1
	} ovsmp_enum;
	rand int 		data_width;
	rand parity_type_enum 	parity_type;
	rand int		stop_width;
	rand int 		baudrate;
	rand mode_enum		mode;
	bit [31:0]		div;
	rand ovsmp_enum		ovsmp;

	constraint width {
		data_width inside {[5:8]};
		stop_width inside {[1:2]};
		baudrate inside {[2400:115200]};

	};


	`uvm_object_utils_begin (uart_config)
		`uvm_field_int (data_width, UVM_ALL_ON | UVM_DEC)
		`uvm_field_enum (parity_type_enum, parity_type, UVM_ALL_ON | UVM_HEX)
		`uvm_field_int (stop_width, UVM_ALL_ON |UVM_DEC)
		`uvm_field_int (baudrate, UVM_ALL_ON | UVM_DEC)
		`uvm_field_enum (mode_enum, mode, UVM_ALL_ON | UVM_BIN)
		`uvm_field_int (div, UVM_ALL_ON | UVM_DEC)
		`uvm_field_enum (ovsmp_enum, ovsmp, UVM_ALL_ON | UVM_DEC)
	 `uvm_object_utils_end

	function new (string name = "uart_config");
       		super.new(name);

		//default value
		parity_type = NONE;
		stop_width = 1;
		data_width = 8;
		baudrate = 9600;
		ovsmp = x16;
		mode = TX;
	endfunction: new	
endclass: uart_config	
