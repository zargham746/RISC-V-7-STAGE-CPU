`include "defines.v"

module stage_id (
	input  wire                rst          ,
	input  wire [`InstAddrBus] pc           ,
	input  wire [    `InstBus] inst         ,
	input  wire [     `RegBus] reg_data1    ,
	input  wire [     `RegBus] reg_data2    ,
	// forwarding
	input  wire [   `AluOpBus] ex_aluop     ,
	input  wire                ex_we        ,
	input  wire [     `RegBus] ex_reg_wdata ,
	input  wire [ `RegAddrBus] ex_reg_waddr ,
	input  wire                mem_we       ,
	input  wire [     `RegBus] mem_reg_wdata,
	input  wire [ `RegAddrBus] mem_reg_waddr,
	output reg                 re1          ,
	output reg                 re2          ,
	output reg  [ `RegAddrBus] reg_addr1    ,
	output reg  [ `RegAddrBus] reg_addr2    ,
	output reg  [   `AluOpBus] aluop        ,
	output reg  [  `AluSelBus] alusel       ,
	output reg  [     `RegBus] opv1         ,
	output reg  [     `RegBus] opv2         ,
	output reg  [ `RegAddrBus] reg_waddr    ,
	output reg                 we           ,
	output wire                stallreq     ,
	output reg                 br           ,
	output reg  [`InstAddrBus] br_addr      ,
	output reg  [`InstAddrBus] link_addr    ,
	output reg  [     `RegBus] mem_offset,
	
	// New outputs for E4, M3, M4 stages
	output reg  [ `RegBus] opv1_e4,
	output reg  [ `RegBus] opv2_e4,
	output reg  [ `RegBus] opv1_m3,
	output reg  [ `RegBus] opv2_m3,
	output reg  [ `RegBus] opv1_m4,
	output reg  [ `RegBus] opv2_m4
);

	wire[6:0] opcode = inst[6:0];
	wire[2:0] funct3 = inst[14:12];
	wire[6:0] funct7 = inst[31:25];
	wire[11:0] I_imm = inst[31:20];
	wire[19:0] U_imm = inst[31:12];
	wire[11:0] S_imm = {inst[31:25], inst[11:7]};
	reg[31:0] imm1;
	reg[31:0] imm2;
	reg inst_valid;

	wire[`RegBus] rd = inst[11:7];
	wire[`RegBus] rs = inst[19:15];
	wire[`RegBus] rt = inst[24:20];

	reg stallreq_for_reg1_load;
	reg stallreq_for_reg2_load;
	assign stallreq = stallreq_for_reg1_load || stallreq_for_reg2_load;

	wire prev_is_load;
	assign prev_is_load = (ex_aluop == `EXE_LB_OP)  || 
                          (ex_aluop == `EXE_LH_OP)  ||
                          (ex_aluop == `EXE_LW_OP)  ||
                          (ex_aluop == `EXE_LBU_OP) ||
                          (ex_aluop == `EXE_LHU_OP);

    wire[`InstAddrBus] reg1_plus_I_imm;
    wire[`InstAddrBus] pc_plus_J_imm;
    wire[`InstAddrBus] pc_plus_B_imm;
    wire[`InstAddrBus] pc_plus_4;
    assign reg1_plus_I_imm = reg_data1 + {{20{I_imm[11]}}, I_imm};
    assign pc_plus_J_imm = pc + {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
   	assign pc_plus_B_imm = pc + {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
    assign pc_plus_4 = pc + 4;

    wire reg1_reg2_eq;
    wire reg1_reg2_ne;
    wire reg1_reg2_lt;
    wire reg1_reg2_ltu;
    wire reg1_reg2_ge;
    wire reg1_reg2_geu;
    assign reg1_reg2_eq = (opv1 == opv2);
    assign reg1_reg2_ne = (opv1 != opv2);
	assign reg1_reg2_lt = ($signed(opv1) < $signed(opv2));
	assign reg1_reg2_ltu = (opv1 < opv2);
	assign reg1_reg2_ge = ($signed(opv1) >= $signed(opv2));
	assign reg1_reg2_geu = (opv1 >= opv2);

	`define SET_INST(i_alusel, i_aluop, i_inst_valid, i_re1, i_reg_addr1, i_re2, i_reg_addr2, i_we, i_reg_waddr, i_imm1, i_imm2, i_mem_offset) \
		aluop = i_aluop; \
		alusel = i_alusel; \
		inst_valid = i_inst_valid; \
		re1 = i_re1; \
		reg_addr1 = i_reg_addr1; \
		re2 = i_re2; \
		reg_addr2 = i_reg_addr2; \
		we = i_we; \
		reg_waddr = i_reg_waddr; \
		imm1 = i_imm1; \
		imm2 = i_imm2; \
		mem_offset = i_mem_offset;

	`define SET_BRANCH(i_br, i_br_addr, i_link_addr) \
		br = i_br; \
		br_addr = i_br_addr; \
		link_addr = i_link_addr;

	always @ (*) begin
		if (rst) begin
			`SET_INST(`EXE_RES_NOP, `EXE_NOP_OP, 1, 0, rs, 0, rt, 0, rd, 0, 0, 0)
			`SET_BRANCH(0, 0, 0)
		end else begin
			`SET_INST(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
			`SET_BRANCH(0, 0, 0)
			case (opcode)
				`OP_LUI : begin
					`SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, 1, 0, 0, 0, 0, 1, rd, ({U_imm, 12'b0}), 0, 0)
				end
				`OP_AUIPC : begin
					`SET_INST(`EXE_RES_ARITH, `EXE_ADD_OP, 1, 0, )
