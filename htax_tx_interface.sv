interface htax_tx_interface (input clk, rst_n);

  import uvm_pkg::*;
  `include "uvm_macros.svh"

	parameter PORTS = `PORTS;
	parameter VC = `VC;
	parameter WIDTH = `WIDTH;
	
	logic [PORTS-1:0] tx_outport_req;
	logic [VC-1:0] 		tx_vc_req;
	logic [VC-1:0] 		tx_vc_gnt;
	logic [WIDTH-1:0]	tx_data;
	logic [VC-1:0]		tx_sot;
	logic							tx_eot;
	logic 						tx_release_gnt;
	logic              flag_tx_vc_req;
	logic              flag_tx_eot;
	logic              flag_tx_sot;
	logic              start = 0;
	
	always @(posedge |tx_vc_req) begin
	   flag_tx_vc_req = 1'b1;
	end
    always @(negedge |tx_vc_req) 
	   flag_tx_vc_req = #20 1'b0;
	always @(posedge tx_eot) begin 
	   flag_tx_eot = 1'b1;
	   start = 1'b1;
	end
	always @(posedge |tx_sot) begin
	   flag_tx_eot = 1'b0;
	   flag_tx_sot = 1'b1;
	end
	always @(posedge tx_release_gnt) 
	   flag_tx_sot = 1'b0;
	   
//ASSERTIONS

   // --------------------------- 
   // tx_outport_req is one-hot 
   // --------------------------- 
   property tx_outport_req_one_hot;
      @(posedge clk) disable iff(!rst_n)
      (|tx_outport_req) |-> $onehot(tx_outport_req);
   endproperty

   assert_tx_outport_req_one_hot : assert property(tx_outport_req_one_hot)
   else
      $error("HTAX_TX_INF ERROR : tx_outport request is not one hot encoded");

   // ----------------------------------- 
   // no tx_outport_req without tx_vc_req
   // ----------------------------------- 
   property tx_outport_req_with_tx_vc_req;
      @ (posedge clk) disable iff(!rst_n)
	  (!(|tx_vc_req)) |-> (!(|tx_outport_req));
   endproperty
   assert_tx_outport_req_deasserted_after_vc_req : assert property(tx_outport_req_with_tx_vc_req)
   else 
      $error("HTAX_TX_INF ERROR : tx_outport_req is not zero when no tx_vc_req");

   // ----------------------------------- 
   // no tx_vc_req without tx_outport_req
   // ----------------------------------- 
   property tx_vc_req_with_tx_outport_req;
      @ (posedge clk) disable iff(!rst_n)
	  (!(|tx_outport_req)) |-> (!(|tx_vc_req));
   endproperty
   assert_tx_vc_req_deasserted_after_outport_req : assert property(tx_vc_req_with_tx_outport_req)
   else 
      $error("HTAX_TX_INF ERROR : tx_vc_req is not zero when no tx_outport_req");
	  
   // ----------------------------------- 
   // tx_outport_req asserted after tx_vc_req
   // ----------------------------------- 
   property tx_outport_req_asserted_after_tx_vc_req;
      @ (posedge clk) disable iff(!rst_n)
	  (|tx_vc_req) |-> (|tx_outport_req);
   endproperty
   assert_tx_outport_req_asserted_with_vc_req : assert property(tx_outport_req_asserted_after_tx_vc_req)
   else 
      $error("HTAX_TX_INF ERROR : tx_outport_req is zero when tx_vc_req is asserted");

   // ----------------------------------- 
   // tx_vc_req asserted after tx_outport_req
   // ----------------------------------- 
   property tx_vc_req_asserted_after_tx_outport_req;
      @ (posedge clk) disable iff(!rst_n)
	  (!(|tx_outport_req)) |-> (!(|tx_vc_req));
   endproperty
   assert_tx_vc_req_asserted_after_outport_req : assert property(tx_vc_req_asserted_after_tx_outport_req)
   else 
      $error("HTAX_TX_INF ERROR : tx_vc_req is zero when tx_outport_req is asserted");

   // ----------------------------------- 
   // tx_vc_gnt is subset of vc_request
   // ----------------------------------- 
   property tx_vc_gnt_within_vc_request;
      @ (posedge clk) disable iff(!rst_n)
	  (($fell(tx_vc_gnt) && (|tx_sot))|| ($rose(tx_vc_gnt) && (|tx_outport_req))) |-> flag_tx_vc_req;
   endproperty
   assert_tx_vc_gnt_within_vc_request : assert property(tx_vc_gnt_within_vc_request)
   else 
      $error("HTAX_TX_INF ERROR : tx_vc_gnt is not a subset of tx_vc_req");

   // ------------------------------------ 
   // no tx_sot without previous tx_vc_gnt 
   // ------------------------------------ 
   property tx_sot_with_pre_tx_vc_gnt;
      @(posedge clk) disable iff (!rst_n)
	  (|tx_sot) |-> (|$past(tx_vc_gnt,1));
   endproperty
   assert_tx_sot_with_pre_tx_vc_gnt : assert property(tx_sot_with_pre_tx_vc_gnt)
   else 
      $error ("HTAX_TX_INF ERROR : tx_sot is not zero without a previous tx_vc_gnt");

   // ------------------------------------------- 
   // tx_eot is asserted for a single clock cycle 
   // ------------------------------------------- 
   property tx_eot_asserted_for_one_cycle;
      @(posedge clk) disable iff (!rst_n)
	  (tx_eot) |-> (!$past(tx_eot,1));
   endproperty
   assert_tx_eot_asserted_for_one_cycle : assert property(tx_eot_asserted_for_one_cycle)
   else 
      $error ("HTAX_TX_INF ERROR : tx_eot is not asserted for only one cycle");


endinterface : htax_tx_interface
