`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2023 02:14:59 PM
// Design Name: 
// Module Name: MAC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module MAC #(parameter size=4, bit_width=8, bit_width_2=16)(
     clk,
	 rst_n, // no need control
	 //acc_in,	//ps_in
	 acc_out,	
	 data_in,	
	 wt_path_in,
	 data_out,	
	 wt_path_out		
	 );
	 
	 
	input clk;
	input rst_n; // test remove control
	
	//input [acc_width-1:0] acc_in; // accumulation in (initial partial sum = 0)
	input [bit_width-1:0] data_in;  // data input or activation in
	input [bit_width-1:0] wt_path_in;   // weight data in
	output reg [bit_width_2-1:0] acc_out;  // accumulation out
	output reg [bit_width-1:0] data_out;    // activation out
	output reg [bit_width-1:0] wt_path_out;		// weight data out
	

	// implement your MAC Unit below
	always @(posedge clk or negedge rst_n)begin
		if(!rst_n) begin //weight preload
			data_out 	<= 0;
			wt_path_out <= 0;
			acc_out 	<= 0;
		end else begin  //
			data_out 	<= data_in;
			wt_path_out <= wt_path_in;
			acc_out     <= acc_out + data_out*wt_path_out;
		end
	end

endmodule



