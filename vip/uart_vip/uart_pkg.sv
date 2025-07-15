//=============================================================================
// Project       : UART VIP
//=============================================================================
// Filename      : uart_pkg.sv
// Author        : Huy Nguyen
// Company       : NO
// Date          : 20-Dec-2021
//=============================================================================
// Description   : 
//
//
//
//=============================================================================
`ifndef GUARD_UART_PKG__SV
`define GUARD_UART_PKG__SV
package uart_pkg;
  import uvm_pkg::*;

  // Include your file
  `include "uart_transaction.sv"
  `include "uart_config.sv"
  `include "uart_sequencer.sv"
  `include "uart_driver.sv"
  `include "uart_monitor.sv"
  `include "uart_agent.sv"
  `include "uart_error_catcher.sv"
endpackage: uart_pkg
 
`endif

