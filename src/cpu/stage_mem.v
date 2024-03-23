`include "defines.v"

module stage_mem (
    input  wire               rst        ,
    input  wire [`RegAddrBus] reg_waddr_i,
    input  wire               we_i       ,
    input  wire [    `RegBus] reg_wdata_i,
    input  wire [`MemAddrBus] mem_addr_i ,
    input  wire [  `AluOpBus] aluop      ,
    input  wire [    `RegBus] rt_data    ,
    input  wire [    `RegBus] mem_data_i ,
    input  wire               mem_busy   ,
    input  wire               mem_done   ,
    output reg  [`RegAddrBus] reg_waddr_o,
    output reg                we_o       ,
    output reg  [    `RegBus] reg_wdata_o,
    output reg  [`MemAddrBus] mem_addr_o ,
    output reg                mem_re     ,
    output reg                mem_we     ,
    output reg  [        3:0] mem_sel    ,
    output reg  [    `RegBus] mem_data_o ,
    output reg                stallreq
);

    reg mem_taking;

    always @ (*) begin
        if(rst) begin
            stallreq    = 0;
            mem_taking  = 0;
            reg_waddr_o = 0;
            we_o        = 0;
            reg_wdata_o = 0;
            mem_sel     = 4'b0000;
            mem_addr_o  = 0;  // Added initialization for mem_addr_o
            mem_data_o  = 0;  // Added initialization for mem_data_o
        end else if (!mem_busy && !mem_taking) begin
            reg_waddr_o = reg_waddr_i;
            we_o        = we_i;
            case (aluop)
                ...
        end else if (!mem_busy && mem_taking) begin
            stallreq   = 0;
            mem_taking = 0;
            case (aluop)
                ...
        end else if (mem_busy) begin
            stallreq = 1;
        end else begin
            stallreq    = 0;
            mem_taking  = 0;
            reg_waddr_o = 0;
            we_o        = 0;
            reg_wdata_o = 0;
            mem_sel     = 4'b0000;
            mem_addr_o  = 0;  // Added reset for mem_addr_o
            mem_data_o  = 0;  // Added reset for mem_data_o
        end
    end

endmodule // stage_mem
