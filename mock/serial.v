`include "defs.v"

// 模拟串口设备
module MockSerial(
    input  wire			clk,
    input  wire[3:0]	mode,
    input  wire[31:0] 	addr,
    input  wire[31:0] 	wdata,
    output wire[31:0]	rdata
);

// 0x8: data
// 0xc: stat

// 硬编码输入数据
parameter inputs = "";
integer input_idx = 0;
wire[7:0] input_data = {
    inputs[$bits(inputs) - 1 - input_idx * 8],
    inputs[$bits(inputs) - 2 - input_idx * 8],
    inputs[$bits(inputs) - 3 - input_idx * 8],
    inputs[$bits(inputs) - 4 - input_idx * 8],
    inputs[$bits(inputs) - 5 - input_idx * 8],
    inputs[$bits(inputs) - 6 - input_idx * 8],
    inputs[$bits(inputs) - 7 - input_idx * 8],
    inputs[$bits(inputs) - 8 - input_idx * 8]
};

// 请求类型
wire is_read  = mode == `IO_LB && addr[3:0] == 'h8;
wire is_write = mode == `IO_SB && addr[3:0] == 'h8;
wire is_test  = mode == `IO_LB && addr[3:0] == 'hc;

// 当前状态
wire can_read = input_idx < ($bits(inputs) / 8);
wire can_write = 1;
wire[7:0] stat_data = {6'b0, can_read, can_write};

// 读
assign rdata = 
    is_read? input_data:
    is_test? stat_data: 0;

// 写
always @(posedge clk) begin
    if (is_read) begin
        $display("read:  0x%x '%c'", input_data, input_data);
        input_idx ++;
    end
    if (is_write) begin
        $display("write: 0x%x '%c'", wdata[7:0], wdata[7:0]);
    end
end

endmodule // MockSerial