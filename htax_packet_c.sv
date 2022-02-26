class htax_packet_c extends uvm_sequence_item;
	
	parameter PORTS = `PORTS;
	parameter VC    = `VC;
	parameter WIDTH = `WIDTH;
	
	rand int length;
	rand int dest_port;
	rand int delay;
	rand bit [VC-1:0] vc;
	rand bit [WIDTH-1:0] data [];


	`uvm_object_utils_begin(htax_packet_c)
		`uvm_field_int(delay,UVM_ALL_ON)
		`uvm_field_int(dest_port,UVM_ALL_ON)
		`uvm_field_int(vc,UVM_ALL_ON)
		`uvm_field_int(length,UVM_ALL_ON)
		`uvm_field_array_int(data,UVM_ALL_ON)
	`uvm_object_utils_end


	function new (string name="htax_packet_c");
		super.new(name);
	endfunction

	//Data length 
	constraint length_cons {soft length inside {[3:63]};
		data.size() == length;}

	//destination port should be between 0 and (PORTS-1)
	constraint dest_port_cons {dest_port inside {[0:PORTS-1]};}

	//delay should be between 1 and 20
	constraint delay_cons {delay inside {[1:20]};}

	//VC request should be valid
	constraint vc_cons {vc > 0;}
												
endclass : htax_packet_c
