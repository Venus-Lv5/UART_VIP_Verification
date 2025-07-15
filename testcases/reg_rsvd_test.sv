class reg_rsvd_test extends uart_base_test;
	`uvm_component_utils(reg_rsvd_test)

	rsvd_sequence seq;
	function new(string name="reg_rsvd_test", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction

	virtual task run_phase(uvm_phase phase);
		phase.raise_objection(this);

		repeat(10) begin
			seq = rsvd_sequence::type_id::create("seq");
			seq.start(env.ahb_agt.sequencer);
		end

		phase.drop_objection(this);
	endtask
endclass
