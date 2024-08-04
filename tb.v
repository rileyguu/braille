`timescale 1us / 1ns

module tb_braille_converter;

// Testbench signals
reg clk;
reg reset;
wire [5:0] led_out;
wire done;

// Instantiate the braille_converter
FPGA_ASIC uut (
    .clk(clk),
    .reset(reset),

    .led_out(led_out),
    .done(done)
);

// Clock generation
always begin
    #10 clk = ~clk; // 50 MHz clock frequency (200 ns period)
end

// Testbench procedure
initial begin
    // Initialize signals
    clk = 0;
    reset = 0;

    // Apply reset
    #20;
    reset = 1;

    $dumpfile("tb.vcd"); // Dump simulation results
    $dumpvars(); // Dump all variables
    
    // Wait for a few clock cycles to simulate processing
    //#200;

    // Add more test scenarios as needed
    // Example: Checking different scenarios with specific input values

    // Finish simulation
    //#10000;
    //$finish;
    wait (done) 
    $finish;
end

endmodule
