`timescale 10ns/1ns

module TestCPU();

reg rst, clk;

// 生成 rst 信号
initial begin
	$dumpfile("test.vcd"); 
	$dumpvars(0, TestCPU);
	rst = 0;
	clk = 1;
	#10
	rst = 1;
	#10
	rst = 0;
	#10000
	$stop;
end

// 生成 clk 信号
always begin
	#1
	clk = ~clk;
end

// CPU
CPU cpu(.rst, .clk);

// 模拟设备
MockRam #(
	.bin_file("program/monitor.bin")
) ram(.clk);
MockSerial #(
	.inputs({"G", 8'h00, 8'h20, 8'h00, 8'h80, "R"})
	// .inputs({"D", 8'h00, 8'h20, 8'h00, 8'h80, 8'h10, 8'h0, 8'h0, 8'h0})
) serial(.clk);

// IO 控制器，连接 CPU 和设备
IOManager io(
	.cpu_mode(cpu.io_mode),
	.cpu_addr(cpu.io_addr),
	.cpu_wdata(cpu.io_wdata),
	.cpu_rdata(cpu.io_rdata),
	.ram_mode(ram.mode),
	.ram_addr(ram.addr),
	.ram_wdata(ram.wdata),
	.ram_rdata(ram.rdata),
	.serial_mode(serial.mode),
	.serial_addr(serial.addr),
	.serial_wdata(serial.wdata),
	.serial_rdata(serial.rdata)
);

endmodule // TestCPU