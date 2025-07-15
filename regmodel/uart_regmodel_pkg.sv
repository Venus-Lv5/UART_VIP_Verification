package uart_regmodel_pkg;

	import uvm_pkg::*;
	import ahb_pkg::*;
	import uart_register_pkg::*;

	`include "uart_reg2ahb_adapter.sv"
	`include "uart_reg_block.sv"
endpackage
