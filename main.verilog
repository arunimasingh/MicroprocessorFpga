module MAIN
(
SYSTEM_CLOCK,
VGA_HSYNCH,
VGA_VSYNCH,
R0,R1,R2,R3,
G0,G1,G2,G3,
B0,B1, B2,B3,
result,
ps2_data,
ps2_clk,
btn,
LED
);
input [3:0] btn;
input SYSTEM_CLOCK; // 100MHz LVTTL SYSTEM CLOCK
input ps2_data;
input ps2_clk;
output VGA_HSYNCH; // horizontal sync for the VGA output connector
output VGA_VSYNCH; // vertical sync for the VGA output connector
output R0,R1,R2,R3,G0,G1,G2,G3,B0,B1,B2,B3;
output [15:0] result;
output [3:0] LED;
assign LED[3] = btn[0]; // Turn LED 0 on when switch 0 is on
/*assign LED[1] = btn[1]; // Turn LED 1 on when switch 1 is on
assign LED[2] = btn[2]; // Turn LED 2 on when switch 2 is on
assign LED[3] = btn[3]; // Turn LED 3 on when switch 3 is on*/
wire system_clock_buffered; // buffered SYSTEM CLOCK
wire pixel_clock; // generated from SYSTEM CLOCK
wire reset; // reset asserted when DCMs are NOT LOCKED
wire vga_red_data; // red video data
wire vga_green_data; // green video data
wire vga_blue_data; // blue video data
// internal video timing signals
wire h_synch; // horizontal synch for VGA connector
wire v_synch; // vertical synch for VGA connector
wire blank; // composite blanking
wire [10:0] pixel_count; // bit mapped pixel position within the line
wire [9:0] line_count; // bit mapped line number in a frame lines within the frame
wire [2:0] subchar_pixel; // pixel position within the character
wire [2:0] subchar_line; // identifies the line number within a character block
wire [6:0] char_column; // character number on the current line
wire [6:0] char_line; // line number on the screen
wire [15:0] char;
wire key;
wire [15:0] opcode;
wire [15:0] Ain;
wire [15:0] Bin;
wire[2:0] status;
// instantiate the clock generator
CLOCK_GEN CLOCK_GEN
(
SYSTEM_CLOCK,
pixel_clock
);
// instantiate the microprocessor
MICROPROCESSOR MICROPROCESSOR
(
SYSTEM_CLOCK,
result,
ps2_data,
ps2_clk,
opcode,
Ain,
Bin,
Btn,
status
);
// instantiate the character generator
CHAR_DISPLAY CHAR_DISPLAY
(
char_column,
char_line,
subchar_line,
subchar_pixel,
pixel_clock,
reset,
vga_red_data,
vga_green_data,
vga_blue_data,
opcode,
Ain,
Bin,
status
);
// instantiate the video timing generator
SVGA_TIMING_GENERATION SVGA_TIMING_GENERATION
(
pixel_clock,
reset,
h_synch,
v_synch,
blank,
pixel_count,
line_count,
subchar_pixel,
subchar_line,
char_column,
char_line
);
// instantiate the video output mux
VIDEO_OUT VIDEO_OUT
(
pixel_clock,
reset,
vga_red_data,
vga_green_data,
vga_blue_data,
h_synch,
v_synch,
blank,
VGA_HSYNCH,
VGA_VSYNCH,
R0,
R1,
R2,
R3,
G0,
G1,
G2,
G3,
B0,
B1,
B2,
B3
);
endmodule // MAIN
