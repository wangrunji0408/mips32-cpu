`include "defs.v"

// 多周期 CPU
module CPU (
    input  wire         rst,        // 重置
    input  wire         clk,        // 时钟

                                    // IO 接口
    output reg [3:0]    io_mode,    // IO 类型
    output reg [31:0]   io_addr,    // 地址
    output reg [31:0]   io_wdata,   // 写数据
    input  wire[31:0]   io_rdata    // 读数据
);

// 定义状态
parameter S_IF = 0, S_ID = 1, S_EX = 2, S_MEM = 3;

// 内部状态
reg[ 1:0]   state,  next_state;     // 当前状态
reg[31:0]   pc,     next_pc;        // 地址
reg[31:0]   inst,   next_inst;      // 指令
reg         in_delay_slot, next_in_delay_slot;  // 是否位于延迟槽
reg[31:0]   delay_pc, next_delay_pc;            // 延迟槽后的跳转地址
reg[31:0]   alu_a, alu_b, alu_out;  // ALU 输入和结果

// 状态转移
always @ (posedge clk or posedge rst) begin
    if(rst) begin
        state <= S_IF;
        pc <= 'h80000000;
        inst <= 0;
        in_delay_slot <= 0;
        delay_pc <= 0;
        alu_a <= 0;
        alu_b <= 0;
        alu_out <= 0;
    end else begin
        state <= next_state;
        pc <= next_pc;
        inst <= next_inst;
        in_delay_slot <= next_in_delay_slot;
        delay_pc <= next_delay_pc;
        alu_a <= id.alu_a;
        alu_b <= id.alu_b;
        alu_out <= alu.out;
    end
end

// 输出控制
always @ (*) begin
    next_pc <= pc;
    next_inst <= inst;
    next_in_delay_slot <= in_delay_slot;
    next_delay_pc <= delay_pc;
    io_mode <= `IO_NOP;
    io_addr <= 0;
    io_wdata <= 0;
    reg_rd <= 0;
    reg_wdata <= 0;
    cp0_wenable <= 0;

    case(state)
        S_IF: begin
            // IO 读指令内容
            io_mode <= `IO_LW;
            io_addr <= pc;
            next_inst <= io_rdata;
            // 更新 PC
            next_pc <= in_delay_slot? delay_pc: pc + 4;
            next_state <= S_ID;
        end
        S_ID: begin
            // 一般情况，转 EX 阶段
            next_state <= S_EX;
            // 若写寄存器数据已经准备好（JAL, MFC0），进入下条指令
            if(id.rd_ready) begin
                next_state <= S_IF;
                next_in_delay_slot <= 0;
                reg_rd <= id.rd_idx;
                reg_wdata <= id.rd_data;
            end
            // 若写 CP0，进入下条指令
            if(id.cp0_wenable) begin
                next_state <= S_IF;
                next_in_delay_slot <= 0;
                cp0_wenable <= 1;
            end
            // 若是跳转指令，进入延迟槽指令
            if(id.is_jump) begin
                next_state <= S_IF;
                // assert(in_delay_slot == 0)
                next_in_delay_slot <= 1;
                next_delay_pc <= id.jump_pc;
            end
        end
        S_EX: begin
            // 访存指令，转 MEM 阶段
            if(id.io_mode != `IO_NOP)
                next_state <= S_MEM;
            // 其它指令，写回寄存器，进入下条指令
            else begin
                next_state <= S_IF;
                next_in_delay_slot <= 0;
                reg_rd <= id.rd_idx;
                reg_wdata <= alu.out;
            end
        end
        S_MEM: begin
            // 给 IO 请求
            next_state <= S_IF;
            io_mode <= id.io_mode;
            io_addr <= alu_out;
            io_wdata <= id.rd_data;
            // 写回寄存器
            reg_rd <= id.rd_idx;
            reg_wdata <= io_rdata;
        end
        default: 
            next_state <= S_IF;
    endcase
end

// 子模块

reg[4:0]    reg_rd;
reg[31:0]   reg_wdata;

RegFile regs(
    .rst,
    .clk,
    .rd(reg_rd),
    .wdata(reg_wdata)
);

InstDecode id(
    .next_pc(pc),
    .inst(inst),
    .rs_idx(regs.rs),
    .rs_data(regs.data1),
    .rt_idx(regs.rt),
    .rt_data(regs.data2),
    .cp0_ridx(cp0.ridx),
    .cp0_rdata(cp0.rdata),
    .cp0_widx(cp0.widx),
    .cp0_wdata(cp0.wdata)
);

ALU alu(
    .a(alu_a),
    .b(alu_b),
    .op(id.alu_op)
);

reg cp0_wenable;

CP0 cp0(
    .rst,
    .clk,
    .wenable(cp0_wenable)
);

endmodule