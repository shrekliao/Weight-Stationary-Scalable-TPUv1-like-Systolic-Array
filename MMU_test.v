`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2023 02:03:16 AM
// Design Name: 
// Module Name: MMU_test
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
// `include "asap7sc7p5t_24_SIMPLE_RVT_TT.v"
// `include "asap7sc7p5t_24_SEQ_RVT_TT.v"
// `include "asap7sc7p5t_24_OA_RVT_TT.v"
// `include "asap7sc7p5t_24_INVBUF_RVT_TT.v"
// `include "asap7sc7p5t_24_AO_RVT_TT.v"

// sample testbench for a 4X4 Systolic Array

module test_TPU #(parameter size=4, bit_width=8, arr_width=32, acc_width=256);

	// Inputs
	reg clk;
	reg rst_n;
	reg control;
	reg [arr_width-1:0] data_arr;
	reg [arr_width-1:0] wt_arr;

	// Outputs
	wire [acc_width-1:0] acc_out;
	//wire [bit_width-1:0] acc_out[0:size-1][0:size-1];

	//Instantiate the Unit Under Test (UUT)
	MMU_S u_mmu (
		.clk(clk),
		.rst_n(rst_n), 
		.control(control), 
		.data_arr(data_arr), 
		.wt_arr(wt_arr), 
		.acc_out(acc_out)
	);

    //clock generation
    initial
    begin
        clk = 0;
		rst_n = 0;
		control=0;
        forever 
        begin
            #25 clk = ~clk;
        end
    end


	initial begin		
		#100 rst_n = 1;
		wt_arr  =32'h 00000000;
		data_arr=32'h 00000000;
		
		@(posedge clk); //wait for the next rising edge
		control=1;
		wt_arr=32'h 05020304;
		
		@(posedge clk);
		wt_arr=32'h 03010203;
		
		@(posedge clk);
		wt_arr=32'h 07040102;

		@(posedge clk);
		wt_arr=32'h 01020403;

		
		@(posedge clk);

		control=0;
		
		data_arr=32'h 00000001;
		
		@(posedge clk);
		data_arr=32'h 00000102;
		
		@(posedge clk);
		data_arr=32'h 00010200;
		
		@(posedge clk);
		data_arr=32'h 00010100;
		
		@(posedge clk);
		data_arr=32'h 02030200;
		
		@(posedge clk);
		data_arr=32'h 04010000;
		
		@(posedge clk);
		data_arr=32'h 05000000;
		
	end
      
endmodule

