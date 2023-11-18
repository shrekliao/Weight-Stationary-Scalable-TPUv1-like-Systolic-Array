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
module MMU_S #(parameter size=4, bit_width=8, bit_width_2=16, arr_width=32, acc_width=256) //
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
	//output reg [bit_width-1:0] acc_out[0:size-1][0:size-1];				
//------data, weight------	
		
	reg [arr_width-1:0] weight_in; // queue the preloaded weight
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			weight_in <= 0;
		end else if (control) begin	
			weight_in <= wt_arr; //strange no delay???
		end else begin
			weight_in <= 0;		
		end
	end
	
	integer x;
	//orgainze input weight by shifting
	reg [arr_width-1:0] weight_in_d [0:size-1];
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for ( x = 0; x < size; x = x + 1) begin
				weight_in_d[x] <= 0;
			end
		end else begin
			weight_in_d[0] <= weight_in;
			for ( x = 1; x < size; x = x + 1) begin
				weight_in_d[x] <= weight_in_d[x-1] << bit_width;
			end
		end
	end
	
	//get the first weight number for SA input
	integer i, j, k, y;
	reg [bit_width-1:0] w [0:size-1];
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			for (i = 0; i < size; i = i + 1) begin
				w[i] <= 0;
			end	
		end else begin	
			for (i = 0; i < size; i = i + 1) begin
				w[i] <= weight_in_d[i][(size*bit_width-1)-:bit_width];
			end	
		end
	end

	//delay weight to match with action data (shift redister) ??? many area
	localparam delay = size-2;
	reg [bit_width-1:0] w_d [0:size-1][0:delay-1];	
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			for ( y = 0; y < size; y = y + 1) begin
				for ( j = 0; j < delay; j = j + 1) begin
					w_d[y][j] <= 0;
				end
			end	
		end else begin	
			for ( y = 0; y < size; y = y + 1) begin
				w_d[y][0] <= w[y];
				for ( j = 1; j < delay; j = j + 1) begin
					w_d[y][j] <= w_d[y][j-1];
				end
			end	
		end
	end
	
	wire [bit_width-1:0] w_f [0:size-1];
	genvar z;
	generate
		for (z = 0; z < size; z = z + 1) begin : assign_loop
			assign w_f[z] = w_d[z][delay-1];
		end
	endgenerate
	
	//organize input action data
	reg [bit_width-1:0] a [0:size-1];
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
		    for (k = 0; k < size; k = k + 1) begin
				a[k]  <= 0;	
			end	
		end else begin	
		    for (k = 0; k < size; k = k + 1) begin
				a[k]  <= data_arr[k*bit_width+:bit_width];	
			end	
		end
	end

	//MAC
	wire  [bit_width-1:0] a_out [0:size-1][0:size-1] ;
	wire [bit_width-1:0] w_out [0:size-1][0:size-1] ;
	wire [bit_width-1:0] out_pre [0:size-1][0:size-1];
	genvar r, c;
	generate
		for (r = 0; r < size; r = r + 1) begin : mac_r
			for (c = 0; c < size; c = c + 1) begin : mac_c
				if (r == 0 && c == 0) begin
					MAC mac(.clk(clk), .rst_n(rst_n), .acc_out(out_pre[0][0]), .data_in(a[0]), .wt_path_in(w_f[0]), .data_out(a_out[0][0]), .wt_path_out(w_out[0][0]));
				end else if (r == 0) begin
					MAC mac(.clk(clk), .rst_n(rst_n), .acc_out(out_pre[c][0]), .data_in(a[c]), .wt_path_in(w_out[c-1][0]), .data_out(a_out[c][0]), .wt_path_out(w_out[c][0]));
				end else if (c == 0) begin
					MAC mac(.clk(clk), .rst_n(rst_n), .acc_out(out_pre[c][r]), .data_in(a_out[0][r-1]), .wt_path_in(w_f[r]), .data_out(a_out[0][r]), .wt_path_out(w_out[0][r]));
				end else begin
					MAC mac(.clk(clk), .rst_n(rst_n), .acc_out(out_pre[c][r]), .data_in(a_out[c][r-1]), .wt_path_in(w_out[c-1][r]), .data_out(a_out[c][r]), .wt_path_out(w_out[c][r]));
				end
			end
		end
	endgenerate

	//acc_out ???
	integer m, n;
	always@(posedge clk or negedge rst_n) begin
		if (!rst_n)begin
			acc_out <= 0;
		end else begin			
			for(n=0; n<size; n=n+1) begin
				for(m=0; m<size; m=m+1) begin
				acc_out <= {acc_out[acc_width-1:bit_width],out_pre[n][m]};
				end
			end
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
