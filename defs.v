`define OP_SPECIAL  6'b000000
`define OP_J        6'b000010
`define OP_JAL      6'b000011
`define OP_BEQ      6'b000100
`define OP_BNE      6'b000101
`define OP_BLEZ     6'b000110
`define OP_BGTZ     6'b000111
`define OP_ADDIU    6'b001001
`define OP_ANDI     6'b001100
`define OP_ORI      6'b001101
`define OP_XORI     6'b001110
`define OP_LUI      6'b001111
`define OP_COP0     6'b010000
`define OP_LB       6'b100000
`define OP_LW       6'b100011
`define OP_SB       6'b101000
`define OP_SW       6'b101011

`define FUNC_ADD    6'b100001
`define FUNC_AND    6'b100100
`define FUNC_JR     6'b001000
`define FUNC_OR     6'b100101
`define FUNC_SLL    6'b000000
`define FUNC_SRL    6'b000010
`define FUNC_XOR    6'b100110

`define CP0_Index 		{5'd0,3'd0}
`define CP0_Random 		{5'd1,3'd0}
`define CP0_EntryLo0 	{5'd2,3'd0}
`define CP0_EntryLo1 	{5'd3,3'd0}
`define CP0_Context		{5'd4,3'd0}
`define CP0_Wired 		{5'd6,3'd0}
`define CP0_BadVAddr 	{5'd8,3'd0}
`define CP0_Count 		{5'd9,3'd0}
`define CP0_EntryHi 	{5'd10,3'd0}
`define CP0_Compare 	{5'd11,3'd0}
`define CP0_Status 		{5'd12,3'd0}
`define CP0_Cause 		{5'd13,3'd0}
`define CP0_EPC 		{5'd14,3'd0}
`define CP0_PRId 		{5'd15,3'd0}
`define CP0_EBase 		{5'd15,3'd1}
`define CP0_Config 		{5'd16,3'd0}
`define CP0_Config1 	{5'd16,3'd1}

// ALU 操作码
`define ALU_ADD	    3'd0
`define ALU_AND	    3'd1
`define ALU_OR	    3'd2
`define ALU_XOR	    3'd3
`define ALU_SLL	    3'd4
`define ALU_SRL	    3'd5
`define ALU_SUB	    3'd6
`define ALU_LUI	    3'd7

// IO 类型
`define IO_NOP 		4'b0000
`define IO_LW  		4'b0001
`define IO_LH  		4'b0010
`define IO_LHU 		4'b0011
`define IO_LB  		4'b0100
`define IO_LBU 		4'b0101
`define IO_SW  		4'b1001
`define IO_SH  		4'b1010
`define IO_SB  		4'b1100

// 状态
`define S_IF    0
`define S_ID    1
`define S_EX    2
`define S_MEM   3
`define S_WB    4

// 控制信号
`define ALU_SRC_A_A     0
`define ALU_SRC_A_PC    1
`define ALU_SRC_A_SA    2

`define ALU_SRC_B_B     0
`define ALU_SRC_B_4     1
`define ALU_SRC_B_IMME  2
`define ALU_SRC_B_IMMEx4 3

`define PC_SRC_C        0
`define PC_SRC_ALU      1
`define PC_SRC_TARGET   2

`define MEM_SRC_PC      0
`define MEM_SRC_C       1

`define REG_DST_0       0
`define REG_DST_RD      1
`define REG_DST_RT      2
`define REG_DST_31      3

// ADDIU    001001ssssstttttiiiiiiiiiiiiiiii
// ADDU     000000ssssstttttddddd00000100001
// AND      000000ssssstttttddddd00000100100
// ANDI     001100ssssstttttiiiiiiiiiiiiiiii
// BEQ      000100ssssstttttoooooooooooooooo
// BGTZ     000111sssss00000oooooooooooooooo
// BNE      000101ssssstttttoooooooooooooooo
// J        000010iiiiiiiiiiiiiiiiiiiiiiiiii
// JAL      000011iiiiiiiiiiiiiiiiiiiiiiiiii
// JR       000000sssss0000000000hhhhh001000
// LB       100000bbbbbtttttoooooooooooooooo
// LUI      00111100000tttttiiiiiiiiiiiiiiii
// LW       100011bbbbbtttttoooooooooooooooo
// OR       000000ssssstttttddddd00000100101
// ORI      001101ssssstttttiiiiiiiiiiiiiiii
// SB       101000bbbbbtttttoooooooooooooooo
// SLL      00000000000tttttdddddaaaaa000000
// SRL      00000000000tttttdddddaaaaa000010
// SW       101011bbbbbtttttoooooooooooooooo
// XOR      000000ssssstttttddddd00000100110
// XORI     001110ssssstttttiiiiiiiiiiiiiiii
