module openmips_min_sopc(  
  
    input   wire clk,  
    input  wire rst  
      
);  
  
    // 连接指令存储器  
    wire[`InstAddrBus] inst_addr;  
    wire[`InstBus] inst;  
    wire rom_ce;  
   
       // 例化处理器OpenMIPS  
    openmips openmips0(  
        .clk(clk),
        .rst(rst),  
        .rom_addr_o(inst_addr),
        .rom_data_i(inst),
        .rom_ce(rom_ce)  
    );  
      
       // 例化指令存储器ROM  
    inst_rom inst_rom0(  
        .ce(rom_ce),  
        .addr(inst_addr), 
        .inst(inst)  
    ); 
  
endmodule