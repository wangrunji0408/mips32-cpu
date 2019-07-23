`include "defs.v"

// 模拟 RAM 设备
module MockRam(
	input  wire			clk,
	input  wire[3:0]	mode,
	input  wire[31:0] 	addr,
	input  wire[31:0] 	wdata,
	output wire[31:0]	rdata
);

reg[7:0] ram[0: ram_size - 1];

parameter ram_size = 8 * 1024 * 1024;
parameter bin_file = "program.bin";
integer i;
initial begin
	$readmemh (bin_file, ram);
end

wire[22:0] raddr = addr[22:0];

// 读
wire[31:0] rword = {ram[raddr+3], ram[raddr+2], ram[raddr+1], ram[raddr]};
assign rdata = 
    (mode == `IO_LH) ? {{16{rword[15]}}, rword[15:0]} :
    (mode == `IO_LHU) ? {{16{1'b0}}, rword[15:0]} :
    (mode == `IO_LB) ? {{24{rword[7]}}, rword[7:0]} :
    (mode == `IO_LBU) ? {{24{1'b0}}, rword[7:0]} : rword;

// 写
wire[3:0] wmask = 
	(mode == `IO_SB) ? 4'b0001:
    (mode == `IO_SH) ? 4'b0011:
    (mode == `IO_SW) ? 4'b1111: 0;

always @(posedge clk) begin
	if(wmask[0])
		ram[raddr] <= wdata[7:0];
	if(wmask[1])
		ram[raddr + 1] <= wdata[15:8];
	if(wmask[2])
		ram[raddr + 2] <= wdata[23:16];
	if(wmask[3])
		ram[raddr + 3] <= wdata[31:24];
end

endmodule // MockRam