module memory(
    mem_addr,
    mem_dout

);

// port declaration

input [7:0] mem_addr;// 3-bit address to support 8 words, coming from braille_converter

output reg [7:0] mem_dout;// going to braille_converter

// data type declaration

reg[7:0]memory[0:255];// memory array with 8 words, each 8 bits wide
//reg[7:0]mem_dout;

// initialize memory, synthesizable in FPGA but not in ASIC

initial begin
$readmemh("input.txt", memory); // Read data from a binary file into memory
end

// memory read operations

always @(*) begin

    mem_dout = memory[mem_addr];     // Read data from memory
end

endmodule