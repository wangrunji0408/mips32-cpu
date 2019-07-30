`include "defs.v"

// 多周期控制信号生成器
//
// 输入指令和当前状态，输出控制信号
// 组合逻辑电路
// 建议配合讲稿数据通路图食用
module Controller(
    input  wire[31:0]   inst,       // 指令
    input  wire[2:0]    state,      // 状态
    input  wire         alu_zero,   // ALU 输出是否为0
    input  wire         alu_sign,   // ALU 输出是否为负

    // 状态控制
    output reg[3:0]     next_state, // 下一周期状态

    // 中间寄存器控制
    output reg          write_pc,   // 是否写 PC 寄存器
    output reg          write_ir,   // 是否写 IR 寄存器

    // 访存控制
    output reg[3:0]     mem_mode,   // 访存模式
    output reg          mem_src,    // 访存数据来源 { 0: PC, 1: C }

    // 寄存器堆控制
    output reg[1:0]     reg_dst,    // 写寄存器目标 { 0: $0, 1: rd, 2: rt, 3: $31 }
    output reg          mem_to_reg, // 写寄存器来源 { 0: C, 1: DR }

    // ALU 控制
    output reg[1:0]     alu_src_a,  // ALU 第一个操作数来源 { 0: PC, 1: A, 2: sa }
    output reg[1:0]     alu_src_b,  // ALU 第二个操作数来源 { 0: B, 1: 0x4, 2: imme-extend, 3: imme-extend << 2 }
    output reg[2:0]     alu_op,     // ALU 操作符
    output reg          sign_ext,   // 是否符号扩展立即数

    // PC 控制
    output reg[1:0]     pc_src      // PC 来源 { 0: C, 1: ALU, 2: {PC[31:28], target << 2} }
);

wire[5:0] opcode = inst[31:26];
wire[5:0] func = inst[5:0];

wire is_load  = opcode[5:3] == 3'b100;
wire is_store = opcode[5:3] == 3'b101;

always @(*) begin
    // 默认输出，均为0
    next_state <= `S_IF;
    write_pc <= 0;
    write_ir <= 0;
    mem_mode <= `IO_NOP;
    mem_src <= `MEM_SRC_PC;
    reg_dst <= `REG_DST_0;
    mem_to_reg <= 0;
    alu_src_a <= `ALU_SRC_A_A;
    alu_src_b <= `ALU_SRC_B_B;
    alu_op <= `ALU_ADD;
    sign_ext <= 0;
    pc_src <= `PC_SRC_C;

    case (state)
        `S_IF: begin
            next_state <= `S_ID;
            // 访存
            mem_mode <= `IO_LW;
            mem_src <= `MEM_SRC_PC;
            write_ir <= 1;
            // ALU：PC + 4
            alu_op <= `ALU_ADD;
            alu_src_a <= `ALU_SRC_A_PC;
            alu_src_b <= `ALU_SRC_B_4;
            // 更新 PC
            write_pc <= 1;
            pc_src <= `PC_SRC_ALU;
        end 
        `S_ID: begin
            next_state <= `S_EX;
            case (opcode)
                `OP_J, `OP_JAL: begin
                    next_state <= `S_IF;
                    write_pc <= 1;
                    pc_src <= `PC_SRC_TARGET;
                    if (opcode == `OP_JAL) begin
                        next_state <= `S_WB;
                        alu_op <= `ALU_ADD;
                        alu_src_a <= `ALU_SRC_A_PC;
                        alu_src_b <= `ALU_SRC_B_4;                      
                    end
                end
                `OP_BEQ, `OP_BNE, `OP_BGTZ, `OP_BLEZ: begin
                    // ALU：PC + sign_ext(imme) x 4 
                    alu_op <= `ALU_ADD;
                    alu_src_a <= `ALU_SRC_A_PC;
                    alu_src_b <= `ALU_SRC_B_IMMEx4; 
                    sign_ext <= 1;
                end
            endcase
        end
        `S_EX: begin
            next_state <= `S_WB;
            case (opcode)
                `OP_BEQ, `OP_BNE, `OP_BGTZ, `OP_BLEZ: begin
                    next_state <= `S_IF;
                    alu_op <= `ALU_SUB;
                    if( opcode == `OP_BEQ && alu_zero
                    ||  opcode == `OP_BNE && ~alu_zero
                    ||  opcode == `OP_BGTZ && ~alu_zero && ~alu_sign
                    ||  opcode == `OP_BLEZ && (alu_zero || alu_sign)
                    ) begin
                        write_pc <= 1;
                        pc_src <= `PC_SRC_C;
                    end
                end
                `OP_SPECIAL: begin
                    case (func)
                        `FUNC_ADD:	alu_op <= `ALU_ADD;
                        `FUNC_AND:	alu_op <= `ALU_AND;
                        `FUNC_OR:	alu_op <= `ALU_OR;
                        `FUNC_XOR:	alu_op <= `ALU_XOR;
                        `FUNC_SLL: begin
                            alu_op <= `ALU_SLL;
                            alu_src_a <= `ALU_SRC_A_SA;
                        end
                        `FUNC_SRL: begin
                            alu_op <= `ALU_SRL;
                            alu_src_a <= `ALU_SRC_A_SA;
                        end
                        `FUNC_JR: begin
                            next_state <= `S_IF;
                            write_pc <= 1;
                            pc_src <= `PC_SRC_ALU;
                        end
                    endcase
                end
                // 立即数
                `OP_ADDIU: begin 
                    alu_op <= `ALU_ADD;
                    alu_src_b <= `ALU_SRC_B_IMME;
                    sign_ext <= 1;
                end
                `OP_ANDI: begin 
                    alu_op <= `ALU_AND;
                    alu_src_b <= `ALU_SRC_B_IMME;
                end
                `OP_ORI: begin 
                    alu_op <= `ALU_OR;
                    alu_src_b <= `ALU_SRC_B_IMME;
                end
                `OP_XORI: begin 
                    alu_op <= `ALU_XOR;
                    alu_src_b <= `ALU_SRC_B_IMME;
                end
                `OP_LUI: begin 
                    alu_op <= `ALU_LUI;
                    alu_src_b <= `ALU_SRC_B_IMME;
                end
                // 访存
                `OP_LB, `OP_LW, `OP_SB, `OP_SW: begin
                    next_state <= `S_MEM;
                    alu_op <= `ALU_ADD;
                    alu_src_b <= `ALU_SRC_B_IMME;
                    sign_ext <= 1;
                end
            endcase
        end
        `S_MEM: begin
            next_state <= is_load? `S_WB: `S_IF;
            mem_src <= `MEM_SRC_C;
            case (opcode)
                `OP_LB:     mem_mode <= `IO_LB;
                `OP_LW:     mem_mode <= `IO_LW;
                `OP_SB:     mem_mode <= `IO_SB;
                `OP_SW:     mem_mode <= `IO_SW;
            endcase
        end
        `S_WB: begin
            next_state <= `S_IF;
            reg_dst <= (opcode == `OP_JAL)? `REG_DST_31: 
                        (opcode == `OP_SPECIAL)? `REG_DST_RD:
                        `REG_DST_RT;
            mem_to_reg <= is_load;
        end
    endcase
end

endmodule // Controller