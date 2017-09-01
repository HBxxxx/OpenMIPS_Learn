`include "define.v"

module id(

	input wire rst,

	input wire[`InstAddrBus] pc_i,
	input wire[`InstBus] inst_i,

	input wire[`RegBus]	reg1_data_i,
	input wire[`RegBus] reg2_data_i,

	output reg[`AluOpBus] aluop_o,
	output reg[`AluSelBus] alusel_o,
	output reg[`RegBus] reg1_o,
	output reg[`RegBus] reg2_o,
	output reg[`RegAddrBus] wd_o,
	output reg wreg_o,
);
	
	wire[5:0] op = inst_i[31:26];
  	wire[4:0] op2 = inst_i[10:6];
  	wire[5:0] op3 = inst_i[5:0];
  	wire[4:0] op4 = inst_i[20:16];
  	reg[`RegBus] imm;
  	reg instvalid;

  	always @ (*) begin
  		if (rst == `RstEnable) begin
  			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= `NOPRegAddr;
			wreg_o <= `WriteDisable;
			instvalid <= `InstValid;
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= `NOPRegAddr;
			reg2_addr_o <= `NOPRegAddr;
			imm <= 32'h0;
  			
  		end
  		else begin
  			aluop_o <= `EXE_NOP_OP;
			alusel_o <= `EXE_RES_NOP;
			wd_o <= inst_i[15:11];
			wreg_o <= `WriteDisable;
			instvalid <= `InstInvalid;	   
			reg1_read_o <= 1'b0;
			reg2_read_o <= 1'b0;
			reg1_addr_o <= inst_i[25:21];	// 默认通过Regfile读端口1读取的寄存器地址  
			reg2_addr_o <= inst_i[20:16];	// 默认通过Regfile读端口2读取的寄存器地址  	
			imm <= `ZeroWord;

  			case (op)
		  		`EXE_ORI: begin // 依据op的值判断是否是ori指令  
		  			wreg_o <= `WriteEnable; // ori指令需要将结果写入目的寄存器，所以wreg_o为WriteEnable
		  			aluop_o <= `EXE_OR_OP; // 运算的子类型是逻辑“或”运算
		  			alusel_o <= `EXE_RES_LOGIC; // 运算类型是逻辑运算  
		  	    	reg1_read_o <= 1'b1; // 需要通过Regfile的读端口1读取寄存器  
		  	   		reg2_read_o <= 1'b0; // 不需要通过Regfile的读端口2读取寄存器  	  	
					imm <= {16'h0, inst_i[15:0]}; // 指令执行需要的立即数 
					wd_o <= inst_i[20:16]; // 指令执行要写的目的寄存器地址
					instvalid <= `InstValid; // ori指令是有效指令	
		  		end 							 
		    	default: begin
				end
			endcase //case op
		end
  	end

  	always @ (*) begin
  		if (rst == `RstEnable)
  			reg2_o <= `ZeroWord;
  		end else if (reg2_read_o == 1'b1) begin
  			reg2_o <= reg_data_i;
  		end else if (reg2_read_o == 1'b0) begin
  			reg2_o <= imm;
  		end else begin
  			reg2_o <= `ZeroWord;
  		end
  	end

endmodule