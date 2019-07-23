`include "defs.v"

// 指令译码
module InstDecode (
    input  wire[31:0]   next_pc,    // 下一条指令的 PC（指令PC + 4）
    input  wire[31:0]   inst,       // 指令输入

    output reg          is_jump,    // 是否为跳转指令。若是，转IF执行延迟槽，然后跳转到 jump_pc
    output reg [31:0]   jump_pc,    // 跳转目标地址

    output reg [2:0]    alu_op,     // 若非跳转，下一周期执行 ALU 运算
    output reg [31:0]   alu_a,
    output reg [31:0]   alu_b,

    output reg [3:0]    io_mode,    // IO 类型
                                    // 若为读，地址为 ALU 计算结果，数据写入寄存器 rd_idx。
                                    // 若为写，地址为 ALU 计算结果，数据为 rd_data。

    output reg [4:0]    rd_idx,     // 写入寄存器编号，=0 无效
    output reg          rd_ready,   // 写入寄存器数据是否已经准备好。若是，数据为 rd_data，否则为 ALU 计算结果。
    output reg [31:0]   rd_data,    // 写入寄存器数据

    output reg          invalid,    // 非法指令异常

                                    // 接到寄存器堆
    output wire[4:0]    rs_idx,     // 读寄存器编号 rs
    input  wire[31:0]   rs_data,    // rs 寄存器的值，立即读出
    output wire[4:0]    rt_idx,     // 读寄存器编号 rt
    input  wire[31:0]   rt_data     // rt 寄存器的值，立即读出
);

// 指令解码
wire[5:0] op = inst[31:26];
wire[4:0] rs = inst[25:21];     // R, I
wire[4:0] rt = inst[20:16];     // R, I
wire[4:0] rd = inst[15:11];     // R
wire[4:0] sa = inst[10:6];      // R
wire[5:0] func = inst[5:0];     // R
wire[15:0] imme = inst[15:0];   // I
wire[25:0] addr = inst[25:0];   // J
wire[31:0] imme_s = {{16{imme[15]}}, imme}; // sign extension

// 直接输出
assign rs_idx = rs;
assign rt_idx = rt;
wire is_load  = op[5:3] == 3'b100;
wire is_store = op[5:3] == 3'b101;

always @ (*) begin
    // 默认输出
    is_jump <= 0;
    jump_pc <= 0;
    alu_a <= rs_data;
    alu_b <= rt_data;
    alu_op <= 0;
    io_mode <= `IO_NOP;
    rd_idx <= 0;
    rd_data <= 0;
    rd_ready <= 0;
    invalid <= 0;

    case (op[5:3])
        // 寄存器 + 跳转
        3'b000: case (op)
            // 寄存器
            `OP_SPECIAL: begin
                rd_idx <= rd;
                case (func)
                    `FUNC_ADD:	alu_op <= `ALU_ADD;
                    `FUNC_AND:	alu_op <= `ALU_AND;
                    `FUNC_OR:	alu_op <= `ALU_OR;
                    `FUNC_XOR:	alu_op <= `ALU_XOR;
                    `FUNC_SLL: begin
                        alu_op <= `ALU_SLL;
                        alu_a <= sa;
                    end
                    `FUNC_SRL: begin
                        alu_op <= `ALU_SRL;
                        alu_a <= sa;
                    end
                    `FUNC_JR: begin
                        is_jump <= 1;
                        jump_pc <= rs_data;
                    end
                    default: invalid <= 1;
                endcase
            end
            // 无条件跳转
            `OP_J, `OP_JAL: begin
                is_jump <= 1;
                jump_pc <= {next_pc[31:28], addr, 2'b00};
                if(op == `OP_JAL) begin
                    rd_idx <= 31;
                    rd_data <= next_pc + 4;
                    rd_ready <= 1;
                end
            end
            // 条件跳转
            `OP_BEQ, `OP_BNE, `OP_BGTZ, `OP_BLEZ: begin
                is_jump <= 1;
                jump_pc <= _jump? next_pc + {imme_s[29:0], 2'b00}: next_pc + 4;
            end
            default: invalid <= 1;
        endcase

        // 立即数运算
        3'b001: begin
            alu_b <= imme;
            rd_idx <= rt;
            case(op)
                `OP_ADDIU: begin 
                    alu_op <= `ALU_ADD; 
                    alu_b <= imme_s;
                end
                `OP_ANDI:   alu_op <= `ALU_AND;
                `OP_ORI:    alu_op <= `ALU_OR;
                `OP_XORI:   alu_op <= `ALU_XOR;
                `OP_LUI: begin 
                    alu_op <= `ALU_SLL; 
                    alu_a <= 16;
                end
                default:    invalid <= 1;
            endcase
        end

        // 内存
        3'b100, 3'b101: begin
            alu_op <= `ALU_ADD;
            alu_b <= imme_s;
            rd_idx <= is_load? rt: 0;
            rd_data <= is_store? rt_data: 0;
            case(op)
                `OP_LB:     io_mode <= `IO_LB;
                `OP_LW:     io_mode <= `IO_LW;
                `OP_SB:     io_mode <= `IO_SB;
                `OP_SW:     io_mode <= `IO_SW;
                default:    invalid <= 1;
            endcase
        end
        default: invalid <= 1;
    endcase
end

// 临时变量
wire _jump = 
    (op == `OP_BEQ)? rs_data == rt_data:
    (op == `OP_BNE)? rs_data != rt_data:
    (op == `OP_BGTZ)? rs_data > 0:
    (op == `OP_BLEZ)? rs_data < 0: 0;

endmodule // InstDecode
