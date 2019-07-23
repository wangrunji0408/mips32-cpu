// 寄存器堆
module RegFile (
	input  wire			rst,	// 重置：所有寄存器清零
	input  wire			clk,	// 时钟：上升沿时写入 rd
	input  wire[4:0]	rs,		// 读寄存器编号1
	output wire[31:0]	data1,	// 寄存器 rs 的值，立即读出
	input  wire[4:0]	rt,		// 读寄存器编号2
	output wire[31:0]	data2,	// 寄存器 rt 的值，立即读出
	input  wire[4:0]	rd,		// 写寄存器编号，rd = 0 时无效
	input  wire[31:0] 	wdata	// 写寄存器数据，上升沿写入
);

// 寄存器数据
reg[31:0][31:0] regs;

// 读寄存器
assign data1 = rs == 0? 0: regs[rs];
assign data2 = rt == 0? 0: regs[rt];

// 写寄存器
always @(posedge clk or posedge rst) begin
	if (rst) begin
		regs <= {32{32'b0}};
	end else if (rd != 0) begin
		regs[rd] <= wdata;
	end
end

endmodule // RegFile