`include "defs.v"

// IO 控制器
//
// 根据 CPU 传来的访存请求，派发到不同的设备
module IOManager(
    // CPU
    input  wire[3:0]    cpu_mode,
    input  wire[31:0]   cpu_addr,
    input  wire[31:0]   cpu_wdata,
    output wire[31:0]   cpu_rdata,

    // RAM
    output wire[3:0]    ram_mode,
    output wire[31:0]   ram_addr,
    output wire[31:0]   ram_wdata,
    input  wire[31:0]   ram_rdata,

    // 串口
    output wire[3:0]    serial_mode,
    output wire[31:0]   serial_addr,
    output wire[31:0]   serial_wdata,
    input  wire[31:0]   serial_rdata
);

// 物理地址映射
// [0x80000000, 0x80800000): RAM
// [0xA0000000, 0xA0800000): RAM
// [0xBFD003F0, 0xBFD00400): 串口
parameter RAM_START1    = 'h80000000;
parameter RAM_START2    = 'hA0000000;
parameter RAM_MASK      = 'hFF800000;
parameter SERIAL_START  = 'hBFD003F0;
parameter SERIAL_MASK   = 'hFFFFFFF0;

// 设备判定
wire is_ram     = (cpu_addr & RAM_MASK) == RAM_START1 || (cpu_addr & RAM_MASK) == RAM_START2;
wire is_serial  = (cpu_addr & SERIAL_MASK) == SERIAL_START;

// RAM 请求
assign ram_mode     = is_ram? cpu_mode: 0;
assign ram_addr     = cpu_addr & ~RAM_MASK;
assign ram_wdata    = cpu_wdata;

// 串口 请求
assign serial_mode  = is_serial? cpu_mode: 0;
assign serial_addr  = cpu_addr & ~SERIAL_MASK;
assign serial_wdata = cpu_wdata;

// CPU 结果
assign cpu_rdata    = is_ram? ram_rdata: is_serial? serial_rdata: 0;

endmodule // IOManager