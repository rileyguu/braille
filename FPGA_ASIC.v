module	FPGA_ASIC	(
			clk,
			reset,

			led_out,
            done
			);

// port declaration

input	clk;
input	reset;

output	[5:0]	led_out;
output done;

// data type declaration

wire	[7:0]	mem_addr;
wire	[7:0]	mem_dout;
wire	[5:0]	led_out;

// function description

memory	memory	(
		.mem_addr(mem_addr),

		.mem_dout(mem_dout)
		);

braille_converter braille_converter (
			.clk(clk),               
			.reset(reset),                
			.mem_dout(mem_dout),

			.mem_addr(mem_addr),  
			.led_out(led_out),   
            .done(done)     
			);

endmodule