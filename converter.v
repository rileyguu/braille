module braille_converter (
    clk,               
    reset,                
    mem_dout,
    mem_addr,
    led_out,
    done          
);

// Port declaration

input       clk;        // System clock, 10kHz
input       reset;      // System synchronous reset
input [7:0] mem_dout;  // Memory data, coming from memory


output reg [7:0] mem_addr; // Memory address, going to memory
output reg [5:0] led_out;  // 6-bit Braille output for LED
output reg done;


// Data type declaration

reg [5:0] braille_fifo[0:255]; // FIFO for Braille translations with 256 words, each 6 bits wide FIX
reg [7:0] fifo_ptr_w;         // 8-bit FIFO WRITE pointer to support 256 words
reg [7:0] size;
reg indi;
//reg [2:0] mem_addr;

reg [23:0] clk_counter;        // Clock counter for LED display time
reg [7:0] fifo_ptr_r;         // 8-bit FIFO READ pointer to support 16 words
//reg [5:0] led_out;

// Function to convert ASCII to Braille
function [5:0] ascii_to_braille;
    input [7:0] ascii;
    begin
        case (ascii)
            8'd65: ascii_to_braille = 6'b100000; // A -> 0x20
            8'd66: ascii_to_braille = 6'b101000; // B -> 0x28
            8'd67: ascii_to_braille = 6'b110000; // C -> 0x30
            8'd68: ascii_to_braille = 6'b110100; // D -> 0x34
            8'd69: ascii_to_braille = 6'b100100; // E -> 0x24
            8'd70: ascii_to_braille = 6'b111000; // F -> 0x38
            8'd71: ascii_to_braille = 6'b111100; // G -> 0x3C
            8'd72: ascii_to_braille = 6'b101100; // H -> 0x2C
            8'd73: ascii_to_braille = 6'b011000; // I -> 0x18
            8'd74: ascii_to_braille = 6'b011100; // J -> 0x1C
            8'd75: ascii_to_braille = 6'b100010; // K -> 0x22
            8'd76: ascii_to_braille = 6'b101010; // L -> 0x2A
            8'd77: ascii_to_braille = 6'b110010; // M -> 0x32
            8'd78: ascii_to_braille = 6'b110110; // N -> 0x36
            8'd79: ascii_to_braille = 6'b100110; // O -> 0x26
            8'd80: ascii_to_braille = 6'b111010; // P -> 0x3A
            8'd81: ascii_to_braille = 6'b111110; // Q -> 0x3E
            8'd82: ascii_to_braille = 6'b101110; // R -> 0x2E
            8'd83: ascii_to_braille = 6'b011010; // S -> 0x1A
            8'd84: ascii_to_braille = 6'b011110; // T -> 0x1E
            8'd85: ascii_to_braille = 6'b100011; // U -> 0x23
            8'd86: ascii_to_braille = 6'b101011; // V -> 0x2B
            8'd87: ascii_to_braille = 6'b011101; // W -> 0x1D
            8'd88: ascii_to_braille = 6'b110011; // X -> 0x33
            8'd89: ascii_to_braille = 6'b110111; // Y -> 0x37
            8'd90: ascii_to_braille = 6'b100111; // Z -> 0x27

            // Mapping for lowercase letters a-z
            8'd97: ascii_to_braille = 6'b100000; // a -> 0x20
            8'd98: ascii_to_braille = 6'b101000; // b -> 0x28
            8'd99: ascii_to_braille = 6'b110000; // c -> 0x30
            8'd100: ascii_to_braille = 6'b110100; // d -> 0x34
            8'd101: ascii_to_braille = 6'b100100; // e -> 0x24
            8'd102: ascii_to_braille = 6'b111000; // f -> 0x38
            8'd103: ascii_to_braille = 6'b111100; // g -> 0x3C
            8'd104: ascii_to_braille = 6'b101100; // h -> 0x2C
            8'd105: ascii_to_braille = 6'b011000; // i -> 0x18
            8'd106: ascii_to_braille = 6'b011100; // j -> 0x1C
            8'd107: ascii_to_braille = 6'b100010; // k -> 0x22
            8'd108: ascii_to_braille = 6'b101010; // l -> 0x2A
            8'd109: ascii_to_braille = 6'b110010; // m -> 0x32
            8'd110: ascii_to_braille = 6'b110110; // n -> 0x36
            8'd111: ascii_to_braille = 6'b100110; // o -> 0x26
            8'd112: ascii_to_braille = 6'b111010; // p -> 0x3A
            8'd113: ascii_to_braille = 6'b111110; // q -> 0x3E
            8'd114: ascii_to_braille = 6'b101110; // r -> 0x2E
            8'd115: ascii_to_braille = 6'b011010; // s -> 0x1A
            8'd116: ascii_to_braille = 6'b011110; // t -> 0x1E
            8'd117: ascii_to_braille = 6'b100011; // u -> 0x23
            8'd118: ascii_to_braille = 6'b101011; // v -> 0x2B
            8'd119: ascii_to_braille = 6'b011101; // w -> 0x1D
            8'd120: ascii_to_braille = 6'b110011; // x -> 0x33
            8'd121: ascii_to_braille = 6'b110111; // y -> 0x37
            8'd122: ascii_to_braille = 6'b100111; // z -> 0x27

            // Mapping for digits 0-9
            8'd48: ascii_to_braille = 6'b001111; // 0 -> 0x0F
            8'd49: ascii_to_braille = 6'b100000; // 1 -> 0x20
            8'd50: ascii_to_braille = 6'b101000; // 2 -> 0x28
            8'd51: ascii_to_braille = 6'b110000; // 3 -> 0x30
            8'd52: ascii_to_braille = 6'b110100; // 4 -> 0x34
            8'd53: ascii_to_braille = 6'b100100; // 5 -> 0x24
            8'd54: ascii_to_braille = 6'b111000; // 6 -> 0x38
            8'd55: ascii_to_braille = 6'b111100; // 7 -> 0x3C
            8'd56: ascii_to_braille = 6'b101100; // 8 -> 0x2C
            8'd57: ascii_to_braille = 6'b011000; // 9 -> 0x18

            // Mapping for common punctuation marks
            8'd32: ascii_to_braille = 6'b000000; // Space -> 0x00
            8'd33: ascii_to_braille = 6'b001110; // ! -> 0x0E
            8'd34: ascii_to_braille = 6'b001010; // " -> 0x0A
            8'd35: ascii_to_braille = 6'b010111; // # -> 0x2F
            8'd36: ascii_to_braille = 6'b111001; // $ -> 0x39
            8'd37: ascii_to_braille = 6'b110101; // % -> 0x35
            8'd38: ascii_to_braille = 6'b101101; // & -> 0x2D
            8'd39: ascii_to_braille = 6'b001000; // ' -> 0x08
            8'd40: ascii_to_braille = 6'b011011; // ( -> 0x1B
            8'd41: ascii_to_braille = 6'b011111; // ) -> 0x1F
            8'd42: ascii_to_braille = 6'b100101; // * -> 0x25
            8'd43: ascii_to_braille = 6'b010110; // + -> 0x16
            8'd44: ascii_to_braille = 6'b000010; // , -> 0x02
            8'd45: ascii_to_braille = 6'b001001; // - -> 0x09
            8'd46: ascii_to_braille = 6'b000011; // . -> 0x03
            8'd47: ascii_to_braille = 6'b010011; // / -> 0x13
            8'd58: ascii_to_braille = 6'b010010; // : -> 0x12
            8'd59: ascii_to_braille = 6'b011010; // ; -> 0x1A
            8'd60: ascii_to_braille = 6'b010001; // < -> 0x

            default: ascii_to_braille = 6'b000000;
        endcase
    end
endfunction

// FIFO Write and Memory Address Update
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        // Reset to initial values
        mem_addr <= 0;
        fifo_ptr_w <= 0;
        size <= 0;
        indi <= 0;
    end
    else begin
        if (mem_addr == 0) begin
            size <= mem_dout;
            mem_addr <= mem_addr + 1;
        end

    	else begin

            if (indi == 1) begin
                braille_fifo[fifo_ptr_w] <= ascii_to_braille(mem_dout);
                if (mem_addr == size) fifo_ptr_w <= 0;
                fifo_ptr_w <= fifo_ptr_w + 1;
                mem_addr <= mem_addr + 1;
                indi <= 0;
            end
            
	        else if (mem_dout >= 65 && mem_dout <= 90) begin
	            // Uppercase (capital letter)
	            braille_fifo[fifo_ptr_w] <= 6'b000001; // Capital letter indicator
	            if (mem_addr == size) fifo_ptr_w <= 0;
	            else fifo_ptr_w <= fifo_ptr_w + 1;
                indi <= 1;

	        end

            else if (mem_dout >= 48 && mem_dout <= 57) begin
                // Digits
                braille_fifo[fifo_ptr_w] <= 6'b010111; // Digit indicator
                if (mem_addr == size) fifo_ptr_w <= 0;
	            else fifo_ptr_w <= fifo_ptr_w + 1;
                indi <= 1;
            end

            else begin
                braille_fifo[fifo_ptr_w] <= ascii_to_braille(mem_dout);
                if (mem_addr == size) fifo_ptr_w <= 0;
                fifo_ptr_w <= fifo_ptr_w + 1;
                mem_addr <= mem_addr + 1;
            end

	    end
        
    end
end


// LED Output Update
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        clk_counter <= 0;
        fifo_ptr_r <= 0;
        led_out <= 0;
        done <= 0;
    end
    else if (clk_counter == 24'h00ffff) begin
        led_out <= braille_fifo[fifo_ptr_r];
        fifo_ptr_r <= fifo_ptr_r + 1;
        clk_counter <= 0; // Reset counter after reaching limit
        if (fifo_ptr_r == size) begin
        	//$finish;
            done <= 1'b1;
        end
    end
    else
        clk_counter <= clk_counter + 1;
end

endmodule