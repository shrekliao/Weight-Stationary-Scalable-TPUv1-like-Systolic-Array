`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/10/2023 02:13:32 PM
// Design Name: 
// Module Name: MMU
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
// Systolic Array top level module. 
module MMU #(parameter size=4, bit_width=8, bit_width_2=16, arr_width=32, acc_width=256) //
(
	clk,
	rst_n,
	control,
	data_arr,
	wt_arr,
	acc_out
    );

	input clk;
	input rst_n;
	input control; 
	input [arr_width-1:0] data_arr; 
	input [arr_width-1:0] wt_arr;   
	output reg [acc_width-1:0] acc_out;
				
//------data, weight------	
	integer i;	
	reg [arr_width-1:0] weight_in; // queue the preloaded weight
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			weight_in <= 0;
		end else if (control) begin	
			weight_in <= wt_arr; 
		end else begin
			weight_in <= 0;		
		end
	end
	
	reg [arr_width-1:0] weight_in_sf1;
	reg [arr_width-1:0] weight_in_sf2;
	reg [arr_width-1:0] weight_in_sf3;
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			weight_in_sf1 <= 0;
			weight_in_sf2 <= 0;
			weight_in_sf3 <= 0;
		end else begin	
			weight_in_sf1 <= weight_in << bit_width; 
			weight_in_sf2 <= weight_in_sf1 << bit_width;
			weight_in_sf3 <= weight_in_sf2 << bit_width;		
		end
	end

	reg [bit_width-1:0] w1, w2, w3, w4;
	reg [bit_width-1:0] w1_d1, w2_d1, w3_d1, w4_d1;
	reg [bit_width-1:0] w1_d2, w2_d2, w3_d2, w4_d2;
	reg [bit_width-1:0] w1_d3, w2_d3, w3_d3, w4_d3;
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			{w1, w2, w3, w4} 			 <= 0;
			{w1_d1, w2_d1, w3_d1, w4_d1} <= 0;
			{w1_d2, w2_d2, w3_d2, w4_d2} <= 0;
			{w1_d3, w2_d3, w3_d3, w4_d3} <= 0;
		end else begin	
			{w1, w2, w3, w4} <= {weight_in[31:24], weight_in_sf1[31:24], weight_in_sf2[31:24], weight_in_sf3[31:24]}; 
			{w1_d1, w2_d1, w3_d1, w4_d1} <= {w1, w2, w3, w4};
			{w1_d2, w2_d2, w3_d2, w4_d2} <= {w1_d1, w2_d1, w3_d1, w4_d1};
			{w1_d3, w2_d3, w3_d3, w4_d3} <= {w1_d2, w2_d2, w3_d2, w4_d2};
		end
	end
	

	reg [bit_width-1:0] a1, a2, a3, a4;
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			{a4, a3, a2, a1} <= 0;
		end else begin	
			{a4, a3, a2, a1}  <= data_arr;	
		end
	end

	wire [(bit_width_2-1):0] acc_out00, acc_out01, acc_out02, acc_out03, acc_out10, acc_out11, acc_out12, acc_out13;
	wire [(bit_width_2-1):0] acc_out20, acc_out21, acc_out22, acc_out23, acc_out30, acc_out31, acc_out32, acc_out33;
	wire [bit_width-1:0] w10, w11, w12, w13, w20, w21, w22, w23, w30, w31, w32, w33, w00, w01, w02, w03;
	wire [bit_width-1:0] a00, a01, a02, a03, a10, a11, a12, a13, a20, a21, a22, a23, a30, a31, a32, a33;
// Implement your logic below based on the MAC unit design in MAC.v
		 //cr
	MAC MAC00(.clk(clk), .rst_n(rst_n),.acc_out(acc_out00), .data_in(a[0]), .wt_path_in(w_f[0]), .data_out(a00), .wt_path_out(w00));
	MAC MAC10(.clk(clk), .rst_n(rst_n),.acc_out(acc_out10), .data_in(a[1]), .wt_path_in(w00), 	 .data_out(a10), .wt_path_out(w10));
	MAC MAC20(.clk(clk), .rst_n(rst_n),.acc_out(acc_out20), .data_in(a[2]), .wt_path_in(w10), 	 .data_out(a20), .wt_path_out(w20));
	MAC MAC30(.clk(clk), .rst_n(rst_n),.acc_out(acc_out30), .data_in(a[3]), .wt_path_in(w20), 	 .data_out(a30), .wt_path_out(w30));
								                       
	MAC MAC01(.clk(clk), .rst_n(rst_n),.acc_out(acc_out01), .data_in(a00), .wt_path_in(w_f[1]), .data_out(a01), .wt_path_out(w01));
	MAC MAC11(.clk(clk), .rst_n(rst_n),.acc_out(acc_out11), .data_in(a10), .wt_path_in(w01),    .data_out(a11), .wt_path_out(w11));
	MAC MAC21(.clk(clk), .rst_n(rst_n),.acc_out(acc_out21), .data_in(a20), .wt_path_in(w11),    .data_out(a21), .wt_path_out(w21));
	MAC MAC31(.clk(clk), .rst_n(rst_n),.acc_out(acc_out31), .data_in(a30), .wt_path_in(w21),    .data_out(a31), .wt_path_out(w31));
								                       
	MAC MAC02(.clk(clk), .rst_n(rst_n),.acc_out(acc_out02), .data_in(a01), .wt_path_in(w_f[2]), .data_out(a02), .wt_path_out(w02));
	MAC MAC12(.clk(clk), .rst_n(rst_n),.acc_out(acc_out12), .data_in(a11), .wt_path_in(w02),    .data_out(a12), .wt_path_out(w12));
	MAC MAC22(.clk(clk), .rst_n(rst_n),.acc_out(acc_out22), .data_in(a21), .wt_path_in(w12),    .data_out(a22), .wt_path_out(w22));
	MAC MAC32(.clk(clk), .rst_n(rst_n),.acc_out(acc_out32), .data_in(a31), .wt_path_in(w22),    .data_out(a32), .wt_path_out(w32));
							                           
	MAC MAC03(.clk(clk), .rst_n(rst_n),.acc_out(acc_out03), .data_in(a02), .wt_path_in(w_f[3]), .data_out(a03), .wt_path_out(w03));
	MAC MAC13(.clk(clk), .rst_n(rst_n),.acc_out(acc_out13), .data_in(a12), .wt_path_in(w03),    .data_out(a13), .wt_path_out(w13));
	MAC MAC23(.clk(clk), .rst_n(rst_n),.acc_out(acc_out23), .data_in(a22), .wt_path_in(w13),    .data_out(a23), .wt_path_out(w23));
	MAC MAC33(.clk(clk), .rst_n(rst_n),.acc_out(acc_out33), .data_in(a32), .wt_path_in(w23),    .data_out(a33), .wt_path_out(w33));
	
	//integer i,j;
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			acc_out <= 0;
		end else begin			
				acc_out <= {acc_out00, acc_out01, acc_out02, acc_out03, 
						    acc_out10, acc_out11, acc_out12, acc_out13,
							acc_out20, acc_out21, acc_out22, acc_out23,
							acc_out30, acc_out31, acc_out32, acc_out33};
	   end
	end
	
	
endmodule

//bits swap
	//integer j;
	// reg [arr_width-1:0] active_in; //active swap
	// always@(posedge clk or negedge rst_n) begin
		// if (!rst_n)begin
			// active_in   <= 0;		
		// end else begin		
			// for (i=0; i<size; i=i+1)begin
			// active_in[(bit_width*i)+:bit_width] <= data_arr[(arr_width-(bit_width*i)-bit_width)+:bit_width];
			// end	
			////active_in[0+ :8] <= data_arr[16+:8];
			////active_in[8+:8]  <= data_arr[8+:8];
			////active_in[16+:8] <= data_arr[0+ :8];
		// end
	// end
