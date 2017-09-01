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
        		`EXE_SPECIAL_INST: begin           //指令码是SPECIAL  
            		case (op2)  
            			5'b00000: begin             
            				case (op3)                     //依据功能码判断是哪种指令  
              					`EXE_OR: begin          //or指令  
                        	  		wreg_o <= `WriteEnable;  
                          			aluop_o <= `EXE_OR_OP;  
                          			alusel_o <= `EXE_RES_LOGIC;  
                          			reg1_read_o <= 1'b1;  
                          			reg2_read_o <= 1'b1;  
                          			instvalid <= `InstValid;   
            					end    
               					`EXE_AND: begin          //and指令  
                        		  	wreg_o <= `WriteEnable;  
                          			aluop_o <= `EXE_AND_OP;  
                          			alusel_o <= `EXE_RES_LOGIC;   
                          			reg1_read_o <= 1'b1;  
                          			reg2_read_o <= 1'b1;  
                          			instvalid   <= `InstValid;   
            					end  
                				`EXE_XOR: begin          //xor指令  
                          			wreg_o <= `WriteEnable;  
                          			aluop_o <= `EXE_XOR_OP;  
                          			alusel_o <= `EXE_RES_LOGIC;  
                          			reg1_read_o <= 1'b1;  
                          			reg2_read_o <= 1'b1;  
                          			instvalid   <= `InstValid;   
            					end 	                  
                				`EXE_NOR: begin          //nor指令  
                          			wreg_o <= `WriteEnable;  
                          			aluop_o <= `EXE_NOR_OP;  
                          			alusel_o <= `EXE_RES_LOGIC;  
                          			reg1_read_o <= 1'b1;  
                          			reg2_read_o <= 1'b1;  
                        	  		instvalid <= `InstValid;   
           						end  
           						`EXE_SLLV: begin         //sllv指令  
            	              		wreg_o <= `WriteEnable;  
                	          		aluop_o <= `EXE_SLL_OP;  
                    	      		alusel_o <= `EXE_RES_SHIFT;  
                        	  		reg1_read_o <= 1'b1;  
                          			reg2_read_o <= 1'b1;  
                          			instvalid <= `InstValid;   
            					end   
	            				`EXE_SRLV: begin         //srlv指令  
    	                      		wreg_o <= `WriteEnable;  
        	                  		aluop_o <= `EXE_SRL_OP;  
            	              		alusel_o <= `EXE_RES_SHIFT;  
                	          		reg1_read_o <= 1'b1;     
                    	      		reg2_read_o <= 1'b1;  
                        	  		instvalid   <= `InstValid;   
           						end  
	            				`EXE_SRAV:begin        //srav指令  
    	                      		wreg_o <= `WriteEnable;  
        	                  		aluop_o <= `EXE_SRA_OP;  
                    	      		alusel_o <= `EXE_RES_SHIFT;  
            	              		reg1_read_o <= 1'b1;  
                	          		reg2_read_o <= 1'b1;  
                        	  		instvalid <= `InstValid;  
            					end  
       	    	 				`EXE_SYNC: begin            //sync指令  
        	                  		wreg_o <= `WriteDisable;  
                	          		aluop_o <= `EXE_NOP_OP;  
                    	      		alusel_o <= `EXE_RES_NOP;  
                        	  		reg1_read_o <= 1'b0;  
                          			reg2_read_o <= 1'b1;  
                          			instvalid <= `InstValid;  
                    			end
            					default: begin  
            					end  
             				endcase  
           				end  
          				default: begin  
           				end
           			endcase
           		end	    
         		`EXE_ORI:  begin             //ori指令  
            	    wreg_o      <= `WriteEnable;  
            	    aluop_o     <= `EXE_OR_OP;  
            	    alusel_o    <= `EXE_RES_LOGIC;   
            	    reg1_read_o <= 1'b1;  
           		    reg2_read_o <= 1'b0;  
                	imm         <= {16'h0, inst_i[15:0]};  
                	wd_o        <= inst_i[20:16];  
                	instvalid   <= `InstValid;  
         		end  
        		`EXE_ANDI:  begin              //andi指令  
             	    wreg_o      <= `WriteEnable;  
            	    aluop_o     <= `EXE_AND_OP;  
            	    alusel_o    <= `EXE_RES_LOGIC;  
           		    reg1_read_o <= 1'b1;  
                	reg2_read_o <= 1'b0;  
                 	imm         <= {16'h0, inst_i[15:0]};  
                 	wd_o        <= inst_i[20:16];  
                 	instvalid   <= `InstValid;    
         		end  
         		`EXE_XORI: begin              //xori指令  
                	wreg_o      <= `WriteEnable;  
                 	aluop_o     <= `EXE_XOR_OP;  
                 	alusel_o    <= `EXE_RES_LOGIC;  
                 	reg1_read_o <= 1'b1;  
                 	reg2_read_o <= 1'b0;  
                 	imm         <= {16'h0, inst_i[15:0]};  
                 	wd_o        <= inst_i[20:16];  
                 	instvalid   <= `InstValid;    
         		end  
         		`EXE_LUI:  begin              //lui指令  
                 	reg_o       <= `WriteEnable;  
                 	aluop_o     <= `EXE_OR_OP;  
                 	alusel_o    <= `EXE_RES_LOGIC;   
                 	reg1_read_o <= 1'b1;  
                 	reg2_read_o <= 1'b0;  
                 	imm         <= {inst_i[15:0], 16'h0};  
                 	wd_o        <= inst_i[20:16];  
                 	instvalid   <= `InstValid;    
         		end  
         		`EXE_PREF: begin             //pref指令  
                 	wreg_o      <= `WriteDisable;  
                 	aluop_o     <= `EXE_NOP_OP;  
                 	alusel_o    <= `EXE_RES_NOP;   
                 	reg1_read_o <= 1'b0;  
                 	reg2_read_o <= 1'b0;  
                 	instvalid   <= `InstValid;  
         		end  
         		default: begin  
         		end  
      		endcase         //case op

      		if (inst_i[31:21] == 11'b00000000000) begin  
        		if (op3 == `EXE_SLL) begin              //sll指令  
          			wreg_o      <= `WriteEnable;  
                	aluop_o     <= `EXE_SLL_OP;  
                  	alusel_o    <= `EXE_RES_SHIFT;   
                  	reg1_read_o <= 1'b0;  
                  	reg2_read_o <= 1'b1;  
                  	imm[4:0]    <= inst_i[10:6];  
                  	wd_o        <= inst_i[15:11];  
                  	instvalid   <= `InstValid;   
         		end else if ( op3 == `EXE_SRL ) begin   //srl指令  
                  	wreg_o      <= `WriteEnable;  
                  	aluop_o     <= `EXE_SRL_OP;  
                  	alusel_o    <= `EXE_RES_SHIFT;   
                  	reg1_read_o <= 1'b0;  
                  	reg2_read_o <= 1'b1;  
                  	imm[4:0]    <= inst_i[10:6];  
                  	wd_o        <= inst_i[15:11];  
                  	instvalid   <= `InstValid;   
             	end else if ( op3 == `EXE_SRA ) begin   //sra指令  
                  	wreg_o      <= `WriteEnable;  
                  	aluop_o     <= `EXE_SRA_OP;  
                  	alusel_o    <= `EXE_RES_SHIFT;   
                  	reg1_read_o <= 1'b0;  
                  	reg2_read_o <= 1'b1;  
                  	imm[4:0]    <= inst_i[10:6];  
                  	wd_o        <= inst_i[15:11];  
                  	instvalid   <= `InstValid;   
         		end  
      		end   
    	end       //if  
	end         //always  


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