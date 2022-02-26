
class simple_port_to_port_test extends base_test;
	`uvm_component_utils(simple_port_to_port_test)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		uvm_config_wrapper::set(this,"tb.vsequencer.run_phase", "default_sequence", simple_port_to_port_vsequence::type_id::get());
		super.build_phase(phase);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		`uvm_info(get_type_name(),"Starting simple port to port test",UVM_NONE)
	endtask : run_phase
endclass : simple_port_to_port_test



class simple_port_to_port_vsequence extends htax_base_vseq;
  `uvm_object_utils(simple_port_to_port_vsequence)

  rand int port;

  function new (string name = "simple_port_to_port_vsequence");
    super.new(name);
  endfunction : new

  task body();
    repeat(500) begin
      port = 1;
      `uvm_do_on_with(req, p_sequencer.htax_seqr[port], {req.dest_port inside {[1:1]};})		
    end
  endtask : body

endclass : simple_port_to_port_vsequence
