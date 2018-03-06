include "SVGA_DEFINES.v"
module CLOCK_GEN
(
SYSTEM_CLOCK,
pixel_clock
);
input SYSTEM_CLOCK;
output pixel_clock;
// Begin clock division
parameter N = 2; // parameter for clock division
//reg clk_25Mhz;
reg pixel_clock;
reg [N-1:0] count;
always @ (posedge SYSTEM_CLOCK) begin
count <= count + 1'b1;
pixel_clock <= count[N-1];
end
// End clock division
endmodule
