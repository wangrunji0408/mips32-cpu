`include "defs.v"

// 算术逻辑单元
module ALU (
    input  wire[31:0] a,		// 运算数1
    input  wire[31:0] b,		// 运算数2
    input  wire[ 2:0] op,		// 操作符
    output reg [31:0] out		// 结果
);

always @(*) begin
    case (op)
        `ALU_ADD:	out <= a + b;
        `ALU_SUB:	out <= a - b;
        `ALU_AND:	out <= a & b;
        `ALU_OR:	out <= a | b;
        `ALU_XOR:	out <= a ^ b;
        `ALU_SLL:	out <= b << a[4:0];
        `ALU_SRL:	out <= b >> a[4:0];
        `ALU_LUI:	out <= {b[15:0], 16'b0};
        default: 	out <= 0;
    endcase
end

endmodule // ALU