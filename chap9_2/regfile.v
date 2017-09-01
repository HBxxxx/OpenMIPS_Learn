`include "define.v"

module regfile(

	input wire clk,
	input wire rst,
	
	//写入端口
	input wire we,
	input wire[`RegAddrBus] waddr,
	input wire[`RegBus] wdata,

	//读取端口1
	input wire re1,
	input wire[`RegAddrBus] raddr1,
	output wire[`RegBus] rdata1,

	//读取端口2
	input wire re2,
	input wire[`RegAddrBus] raddr2,
	output wire[`RegBus] rdata2,

);

	reg[`RegBus]  regs[0:`RegNum-1];

	//写入操作
	always @ (posedge clk) begin
		if (rst == `RstDisable) begin
			if((we == `WriteEnable) && (waddr != `RegNumLog2'h0)) begin
				regs[waddr] <= wdata;			
			end
		end
	end

	//读取端口1
	always @ (*) begin
		if (rst == `RstEnable) begin
			rdata1 <= `ZerWord;
		end else if (raddr1 == `RegNumLog2'h0) begin
			rdata1 <= `ZerWord;
		end else if((raddr1 == waddr) && (we == `WriteEnable) 
	  	            && (re1 == `ReadEnable)) begin
			rdata1 <= wdata;
		end else if(re1 == `ReadEnable) begin
			rdata1 <= regs[raddr1];
		end else begin
	     	rdata1 <= `ZeroWord;
		end
	end

	//读取端口2
	always @ (*) begin
		if (rst == `RstEnable) begin
			rdata2 <= `ZerWord;
		end else if (raddr2 == `RegNumLog2'h0) begin
			rdata2 <= `ZerWord;
		end else if((raddr2 == waddr) && (we == `WriteEnable) 
	  	            && (re2 == `ReadEnable)) begin
			rdata2 <= wdata;
		end else if(re2 == `ReadEnable) begin
			rdata2 <= regs[raddr2];
		end else begin
	     	rdata2 <= `ZeroWord;
		end
	end

endmodule
