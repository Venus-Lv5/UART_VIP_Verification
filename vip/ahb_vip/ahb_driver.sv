class ahb_driver extends uvm_driver #(ahb_transaction);
  `uvm_component_utils(ahb_driver)

  virtual ahb_if ahb_vif;

  function new(string name="ahb_driver", uvm_component parent);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    /** Applying the virtual interface received through the config db - learn detail in next session*/
    if(!uvm_config_db#(virtual ahb_if)::get(this,"","ahb_vif",ahb_vif))
      `uvm_fatal(get_type_name(),$sformatf("Failed to get from uvm_config_db. Please check!"))
  endfunction: build_phase

  /** User can use ahb_vif to control real interface like systemverilog part*/
  virtual task run_phase(uvm_phase phase);
  	ahb_transaction seq, rsp;

	wait(ahb_vif.HRESETn == 1);

	forever begin
		seq_item_port.get_next_item(seq);


		@(posedge ahb_vif.HCLK);
		ahb_vif.HADDR		<= seq.addr;
		ahb_vif.HWRITE		<= seq.xact_type;
		ahb_vif.HBURST		<= seq.burst_type;
		ahb_vif.HSIZE 		<= seq.xfer_size;
		ahb_vif.HPROT		<= seq.prot;
		ahb_vif.HMASTLOCK	<= seq.lock;
		ahb_vif.HTRANS		<= 2'h2;

		`uvm_info("run_phase", $sformatf("Start %s transaction - ADRRESS: 0x%0h", seq.xact_type ? "WRITE" : "READ", seq.addr), UVM_LOW);

		//Phase 2
		@(posedge ahb_vif.HCLK);
		ahb_vif.HADDR 		<= 0;
		ahb_vif.HWRITE		<= 0;
		ahb_vif.HBURST		<= 0;
		ahb_vif.HSIZE		<= 0;
		ahb_vif.HPROT 		<= 0;
		ahb_vif.HMASTLOCK 	<= 0;
		ahb_vif.HTRANS 		<= 0;

		if (seq.xact_type == ahb_transaction::WRITE) begin
			ahb_vif.HWDATA <= seq.data;
		end
		@(posedge ahb_vif.HREADYOUT);
		if(seq.xact_type == ahb_transaction::READ) begin
			@(posedge ahb_vif.HCLK);
			seq.data = ahb_vif.HRDATA;
		end

		$cast(rsp, seq.clone());
		rsp.set_id_info(seq);

		seq_item_port.put(rsp);

		`uvm_info("run_phase", $sformatf("Completed %s transaction at addr 0x%0h and data: 0x%0h", seq.xact_type ? "WRITE" : "READ", seq.addr, seq.data), UVM_LOW);

		seq_item_port.item_done();
	end
		

  endtask: run_phase

endclass: ahb_driver

