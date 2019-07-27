// CP0 协处理器
//
// idx[7:0] = {reg[4:0], sel[2:0]}
module CP0(
    input   wire        rst,        // 重置
    input   wire        clk,        // 时钟

    input   wire[7:0]   ridx,       // 读地址
    output  reg [31:0]  rdata,      // 读数据，立即读出

    input   wire        wenable,    // 写使能
    input   wire[7:0]   widx,       // 写地址
    input   wire[31:0]  wdata       // 写数据，上升沿写入
);

// 寄存器内容
reg[31:0] epc;

// 读
always @(*) begin
    case (ridx)
        `CP0_EPC:   rdata <= epc;
        default:    rdata <= 0;
    endcase
end

// 写
always @(posedge clk or posedge rst) begin
    if (rst) begin
        epc <= 0;
    end else if(wenable) begin
    case (ridx)
        `CP0_EPC:   epc <= wdata;
    endcase
    end
end

endmodule // CP0