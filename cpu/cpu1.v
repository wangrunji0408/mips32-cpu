`include "defs.v"

// 多周期 CPU
//
// 基于 控制信号
module MultiCycleCPU (
    input  wire         rst,        // 重置
    input  wire         clk,        // 时钟

    // IO 接口
    output wire[3:0]    io_mode,    // IO 类型
    output wire[31:0]   io_addr,    // 地址
    output wire[31:0]   io_wdata,   // 写数据
    input  wire[31:0]   io_rdata    // 读数据
);

// 中间寄存器
reg[ 2:0]   state;     // 当前状态
reg[31:0]   pc;        // 地址
reg[31:0]   ir;        // 指令
reg[31:0]   dr;        // 访存数据
reg[31:0]   a, b, c;   // A, B, C 寄存器

// 中间寄存器 状态转移
always @(posedge clk or posedge rst) begin
    if(rst) begin
        state <= `S_IF;
        pc <= 32'h80000000;
        ir <= 0;
        dr <= 0;
        a <= 0;
        b <= 0;
        c <= 0;
    end else begin
        state <= ctrl.next_state;
        if(ctrl.write_pc)   pc <= next_pc;
        if(ctrl.write_ir)   ir <= io_rdata;
        dr <= io_rdata;
        a <= regs.data1;
        b <= regs.data2;
        c <= alu.out;
    end
end

// 指令解码
wire[25:0] target = ir[25:0];
wire[4:0] rs = ir[25:21];
wire[4:0] rt = ir[20:16];
wire[4:0] rd = ir[15:11];
wire[5:0] sa = ir[10:6];
wire[15:0] imme = ir[15:0];
wire[31:0] imme_s = {{16{imme[15]}}, imme}; // sign extension

// 根据控制信号决定输出
wire[31:0] next_pc = 
    (ctrl.pc_src == `PC_SRC_C)? c:
    (ctrl.pc_src == `PC_SRC_ALU)? alu.out:
    (ctrl.pc_src == `PC_SRC_TARGET)? {pc[31:28], target, 2'b00}: 0;

assign io_addr =
    (ctrl.mem_src == `MEM_SRC_PC)? pc:
    (ctrl.mem_src == `MEM_SRC_C)? c: 0;

assign io_mode = ctrl.mem_mode;

assign io_wdata = regs.data2;

wire[31:0] imme_ext = ctrl.sign_ext? imme_s: imme;

wire[31:0] alu_a = 
    (ctrl.alu_src_a == `ALU_SRC_A_A)? a:
    (ctrl.alu_src_a == `ALU_SRC_A_PC)? pc:
    (ctrl.alu_src_a == `ALU_SRC_A_SA)? sa: 0;

wire[31:0] alu_b = 
    (ctrl.alu_src_b == `ALU_SRC_B_B)? b:
    (ctrl.alu_src_b == `ALU_SRC_B_4)? 4:
    (ctrl.alu_src_b == `ALU_SRC_B_IMME)? imme_ext:
    (ctrl.alu_src_b == `ALU_SRC_B_IMMEx4)? (imme_ext << 2): 0;

wire[4:0] reg_rd = 
    ~ctrl.reg_write? 0:
    (ctrl.reg_dst == `REG_DST_RD)? rd:
    (ctrl.reg_dst == `REG_DST_RT)? rt:
    (ctrl.reg_dst == `REG_DST_31)? 31: 0;

wire[31:0] reg_wdata = ctrl.mem_to_reg? dr: c;

// 子模块

Controller ctrl(
    .inst(ir),
    .state,
    .alu_zero(alu.out == 0),
    .alu_sign(alu.out[31])
);

RegFile regs(
    .rst,
    .clk,
    .rs,
    .rt,
    .rd(reg_rd),
    .wdata(reg_wdata)
);

ALU alu(
    .a(alu_a),
    .b(alu_b),
    .op(ctrl.alu_op)
);

endmodule