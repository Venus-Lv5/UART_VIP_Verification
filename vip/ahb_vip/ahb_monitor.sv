class ahb_monitor extends uvm_monitor;
  `uvm_component_utils(ahb_monitor)
  uvm_analysis_port #(ahb_transaction) mon_ap;
  virtual ahb_if ahb_vif;
 
  function new(string name="ahb_monitor", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon_ap = new("mon_ap", this);
    if (!uvm_config_db #(virtual ahb_if)::get(this, "", "ahb_vif", ahb_vif))
	    `uvm_fatal(get_type_name(), $sformatf("Failed to get ahb_vif"));
    
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
  	forever begin
		ahb_transaction trans;
		`uvm_info("ahb_monitor", $sformatf("Capturing data from DUT"), UVM_LOW);

 		wait(ahb_vif.HTRANS !=0);
  		trans = ahb_transaction::type_id::create("trans");
		trans.addr = ahb_vif.HADDR;
		$cast(trans.xact_type, ahb_vif.HWRITE);
		trans.prot = ahb_vif.HPROT;
		trans.lock = ahb_vif.HMASTLOCK;
		$cast(trans.xfer_size, ahb_vif.HSIZE);
		$cast(trans.burst_type, ahb_vif.HBURST);

		@(posedge ahb_vif.HREADYOUT); #1;
		trans.data = trans.xact_type ? ahb_vif.HWDATA : ahb_vif.HRDATA;
		trans.resp = ahb_vif.HRESP;
		`uvm_info("ahb_monitor", $sformatf("Finish"), UVM_LOW);
		`uvm_info("ahb_monitor", $sformatf("Send trans from monitor to scoreboard: \n%s", trans.sprint()), UVM_LOW);
		mon_ap.write(trans);
	end
  endtask: run_phase

endclass: ahb_monitor

