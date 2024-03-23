`include "defines.v"

module stage_ex (
	input  wire                rst        ,
	input  wire [   `AluOpBus] aluop      ,
	input  wire [  `AluSelBus] alusel     ,
	input  wire [     `RegBus] opv1       ,
	input  wire [     `RegBus] opv2       ,
	input  wire [ `RegAddrBus] reg_waddr_i,
	input  wire                we_i       ,
	input  wire [`InstAddrBus] link_addr  ,
	input  wire [     `RegBus] mem_offset ,
	output reg  [ `RegAddrBus] reg_waddr_o,
	output reg                 we_o       ,
	output reg  [     `RegBus] reg_wdata  ,
	output reg                 stallreq   ,
	output reg  [ `MemAddrBus] mem_addr   ,
	output wire [   `AluOpBus] ex_aluop   ,
	output wire [     `RegBus] rt_data,

	// New stage signals and outputs
	output reg  [ `RegBus] reg_wdata_m3,
	output reg  [ `RegBus] reg_wdata_m4,
	output reg                 stallreq_m3,
	output reg                 stallreq_m4,
	output reg  [ `MemAddrBus] mem_addr_m3,
	output reg  [ `MemAddrBus] mem_addr_m4,
	output wire [   `AluOpBus] ex_aluop_m3,
	output wire [   `AluOpBus] ex_aluop_m4,
	output wire [     `RegBus] rt_data_m3,
	output wire [     `RegBus] rt_data_m4
);

	// Existing stage logic remains unchanged

	// EXE_RES_ARITH_M3
	always @ (*) begin
		if(rst || alusel != `EXE_RES_ARITH_M3) begin
			arith_out_m3 = 0;
		end else begin
			case (aluop)
				// Modify for new ALU operations and outputs
			endcase
		end
	end

	// EXE_RES_ARITH_M4
	always @ (*) begin
		if(rst || alusel != `EXE_RES_ARITH_M4) begin
			arith_out_m4 = 0;
		end else begin
			case (aluop)
				// Modify for new ALU operations and outputs
			endcase
		end
	end

	// Final outputs for M3
	always @ (*) begin
		stallreq_m3    = 0;
		reg_waddr_o_m3 = reg_waddr_i;
		we_o_m3        = we_i;
		mem_addr_m3    = 0;
		case (alusel)
			// Modify for new ALU operations and outputs
		endcase
	end

	// Final outputs for M4
	always @ (*) begin
		stallreq_m4    = 0;
		reg_waddr_o_m4 = reg_waddr_i;
		we_o_m4        = we_i;
		mem_addr_m4    = 0;
		case (alusel)
			// Modify for new ALU operations and outputs
		endcase
	end

endmodule // stage_ex
