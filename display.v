module CHAR_DISPLAY
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
A,
B,
status
);
input [6:0] char_column; // character number on the current line
input [6:0] char_line; // line number on the screen
input [2:0] subchar_line; // the line number within a character block 0-8
input [2:0] subchar_pixel; // the pixel number within a character block 0-8
input pixel_clock;
input reset;
output vga_red_data;
output vga_green_data;
output vga_blue_data;
input [15:0] opcode;
input [15:0] A;
input [15:0] B;
input[2:0] status;
// Note: all labels must match their defined length--shorter labels will be padded with solid blocks,
// and longer labels will be truncated
wire [0:8*35-1] example_wel = " ***16 bit Microprocessor***";
wire [0:8*24-1] example_text ;
wire [0:8*24-1] dispA;
wire [0:8*24-1] dispB;
wire [0:8*35-1] dispStatus;
wire [13:0] char_addr = {char_line[6:0], char_column[6:0]};
wire write_enable; // character memory is written to on a clock rise when high
wire pixel_on; // high => output foreground color, low => output background color
line3 instr(opcode, example_text);
line9 flags(status, dispStatus);
line57 showA(char_line, A, dispA);
line57 showB(char_line, B, dispB);
reg [7:0] char_write_data; // the data that will be written to character memory at the clock rise
integer i, k,j,v;
// always enable writing to character RAM
assign write_enable = 1;
// write the appropriate character data to memory
always @ (char_line or char_column) begin
// insert a space by default
char_write_data <= 8'h20;
if (char_line == 7'h01) begin
// write the dispOpcode text starting at the first column
for (v = 0; v < 35; v = v + 1) begin
if (char_column == v)
char_write_data <= example_wel[v*8+:8];
end
end
else if (char_line == 7'h09) begin
for (i = 0; i < 24; i = i + 1) begin
if (char_column == i)
char_write_data <= example_text[i*8+:8];
end
end
else if (char_line == 7'h07) begin
for (i = 0; i < 35; i = i + 1) begin
if (char_column == i)
char_write_data <= dispStatus[i*8+:8];
end
end
else if (char_line == 7'h03) begin
// write the dispOpcode text starting at the first column
for (j = 0; j < 24; j = j + 1) begin
if (char_column == j)
char_write_data <= dispA[j*8+:8];
end
end
else if (char_line == 7'h05) begin
for (k = 0; k < 24; k = k + 1) begin
if (char_column == k)
char_write_data <= dispB[k*8+:8];
end
end
end
reg background_red; // the red component of the background color
reg background_green; // the green component of the background color
reg background_blue; // the blue component of the background color
reg foreground_red; // the red component of the foreground color
reg foreground_green; // the green component of the foreground color
reg foreground_blue; // the blue component of the foreground color
// use the result of the character generator module to choose between the foreground and background color
assign vga_red_data = (pixel_on) ? foreground_red : background_red;
assign vga_green_data = (pixel_on) ? foreground_green : background_green;
assign vga_blue_data = (pixel_on) ? foreground_blue : background_blue;
// select the appropriate character colors
always @ (char_line or char_column) begin
// always use a black background with white text
background_red <= 1'b0;
background_green <= 1'b0;
background_blue <= 1'b1;
foreground_red <= 1'b1;
foreground_green <= 1'b0;
foreground_blue <= 1'b0;
end
// the character generator block includes the character RAM
// and the character generator ROM
CHAR_GEN CHAR_GEN
(
reset, // reset signal
char_addr, // write address
char_write_data, // write data
write_enable, // write enable
pixel_clock, // write clock
char_addr, // read address of current character
subchar_line, // current line of pixels within current character
subchar_pixel, // current column of pixels withing current character
pixel_clock, // read clock
pixel_on // read data
);
endmodule //CHAR_DISPLAY
module line9(status, dispStatus);
input[2:0] status;
output reg [0:8*35-1] dispStatus;
always@(status)
begin
case(status)
3'b000: begin dispStatus<= " IE=0 | Z=0 | C=0 " ;end
3'b001: begin dispStatus<= " IE=0 | Z=0 | C=1 " ;end
3'b010: begin dispStatus<= " IE=0 | Z=1 | C=0 " ;end
3'b011: begin dispStatus<= " IE=0 | Z=1 | C=1 " ;end
3'b100: begin dispStatus<= " IE=1 | Z=0 | C=0 " ;end
3'b101: begin dispStatus<= " IE=1 | Z=0 | C=1 " ;end
3'b110: begin dispStatus<= " IE=1 | Z=1 | C=0 " ;end
3'b111: begin dispStatus<= " IE=1 | Z=1 | C=1 " ;end
default:begin dispStatus<= " " ;end
endcase
end
endmodule
module line3(opcode, dispOpcode);
input [15:0] opcode;
output reg [0:8*12-1] dispOpcode;
always@(opcode)
begin
case(opcode)
16'hB000: dispOpcode <= " RET " ;
16'hF000: dispOpcode <= " NOP " ;
16'hC000: dispOpcode <= " HALT " ;
16'h7100: dispOpcode <= " ADD " ;
16'h7800: dispOpcode <= " CLC " ;
16'h7900: dispOpcode <= " CLZ " ;
16'h7A00: dispOpcode <= " ION " ;
16'h7B00: dispOpcode <= " IOF " ;
16'h7F00: dispOpcode <= " DECA " ;
16'h7600: dispOpcode <= " INCB " ;
16'h7700: dispOpcode <= " DECB " ;
16'h7200: dispOpcode <= " AND " ;
16'h7500: dispOpcode <= " CMB " ;
16'hA000: dispOpcode <= " POPA " ;
16'h7C00: dispOpcode <= " SC " ;
16'h7D00: dispOpcode <= " SZ " ;
16'h9000: dispOpcode <= " PUSHA " ;
16'h7300: dispOpcode <= " CLA " ;
16'h7400: dispOpcode <= " LB " ;
endcase
case(opcode[15:12])
4'b0000: dispOpcode <= " LDA " ;
4'b0001: dispOpcode <= " LDB " ;
4'b0010: dispOpcode <= " STA " ;
4'b0011: dispOpcode <= " STB " ;
4'b0100: dispOpcode <= " JMP " ;
4'b0101: dispOpcode <= " JSR " ;
endcase
end
endmodule
module line57(lineNo, regVal, regChar);
input [0:15] regVal;
input[6:0] lineNo;
reg[3:0] hex1;
reg[3:0] hex2;
reg[3:0] hex3;
reg[3:0] hex4;
output reg [0:8*18-1] regChar;
always@(regVal)
begin
if(lineNo == 7'h03)
begin regChar[0:7] <= "A"; end
else if(lineNo == 7'h05)
begin regChar[0:7] <= "B"; end
regChar[8:15] <= ":";
regChar[16:23] <= 8'h30;
regChar[24:31] <= 8'h58;
if(regVal[0] == 0)
hex1[3]=1'b0;
else if(regVal[0] == 1)
hex1[3]=1;
if(regVal[1] == 0)
hex1[2]=0;
else if(regVal[1] == 1)
hex1[2]=1;
if(regVal[2] == 0)
hex1[1]=0;
else if(regVal[2] == 1)
hex1[1]=1;
if(regVal[3] == 0)
hex1[0]=0;
else if(regVal[3] == 1)
hex1[0]=1;
if(regVal[4] == 0)
hex2[3]=0;
else if(regVal[4] == 1)
hex2[3]=1;
if(regVal[5] == 0)
hex2[2]=0;
else if(regVal[5] == 1)
hex2[2]=1;
if(regVal[6] == 0)
hex2[1]=0;
else if(regVal[6] == 1)
hex2[1]=1;
if(regVal[7] == 0)
hex2[0]=0;
else if(regVal[7] == 1)
hex2[0]=1;
if(regVal[8] == 0)
hex3[3]=0;
else if(regVal[8] == 1)
hex3[3]=1;
if(regVal[9] == 0)
hex3[2]=0;
else if(regVal[9] == 1)
hex3[2]=1;
if(regVal[10] == 0)
hex3[1]=0;
else if(regVal[10] == 1)
hex3[1]=1;
if(regVal[11] == 0)
hex3[0]=0;
else if(regVal[11] == 1)
hex3[0]=1;
if(regVal[12] == 0)
hex4[3]=0;
else if(regVal[12] == 1)
hex4[3]=1;
if(regVal[13] == 0)
hex4[2]=0;
else if(regVal[13] == 1)
hex4[2]=1;
if(regVal[14] == 0)
hex4[1]=0;
else if(regVal[14] == 1)
hex4[1]=1;
if(regVal[15] == 0)
hex4[0]=0;
else if(regVal[15] == 1)
hex4[0]=1;
case(hex1)
4'b0000: regChar[32:39] <= 8'h30;
4'b0001: regChar[32:39] <= 8'h31;
4'b0010: regChar[32:39] <= 8'h32;
4'b0011: regChar[32:39] <= 8'h33;
4'b0100: regChar[32:39] <= 8'h34;
4'b0101: regChar[32:39] <= 8'h35;
4'b0110: regChar[32:39] <= 8'h36;
4'b0111: regChar[32:39] <= 8'h37;
4'b1000: regChar[32:39] <= 8'h38;
4'b1001: regChar[32:39] <= 8'h39;
4'b1010: regChar[32:39] <= 8'h41;
4'b1011: regChar[32:39] <= 8'h42;
4'b1100: regChar[32:39] <= 8'h43;
4'b1101: regChar[32:39] <= 8'h44;
4'b1110: regChar[32:39] <= 8'h45;
4'b1111: regChar[32:39] <= 8'h46;
default: regChar[32:39] <= 8'h30;
endcase
case(hex2)
4'b0000: regChar[40:47] <= 8'h30;
4'b0001: regChar[40:47] <= 8'h31;
4'b0010: regChar[40:47] <= 8'h32;
4'b0011: regChar[40:47] <= 8'h33;
4'b0100: regChar[40:47] <= 8'h34;
4'b0101: regChar[40:47] <= 8'h35;
4'b0110: regChar[40:47] <= 8'h36;
4'b0111: regChar[40:47] <= 8'h37;
4'b1000: regChar[40:47] <= 8'h38;
4'b1001: regChar[40:47] <= 8'h39;
4'b1010: regChar[40:47] <= 8'h41;
4'b1011: regChar[40:47] <= 8'h42;
4'b1100: regChar[40:47] <= 8'h43;
4'b1101: regChar[40:47] <= 8'h44;
4'b1110: regChar[40:47] <= 8'h45;
4'b1111: regChar[40:47] <= 8'h46;
default: regChar[40:47] <= 8'h30;
endcase
case(hex3)
4'b0000: regChar[48:55] <= 8'h30;
4'b0001: regChar[48:55] <= 8'h31;
4'b0010: regChar[48:55] <= 8'h32;
4'b0011: regChar[48:55] <= 8'h33;
4'b0100: regChar[48:55] <= 8'h34;
4'b0101: regChar[48:55] <= 8'h35;
4'b0110: regChar[48:55] <= 8'h36;
4'b0111: regChar[48:55] <= 8'h37;
4'b1000: regChar[48:55] <= 8'h38;
4'b1001: regChar[48:55] <= 8'h39;
4'b1010: regChar[48:55] <= 8'h41;
4'b1011: regChar[48:55] <= 8'h42;
4'b1100: regChar[48:55] <= 8'h43;
4'b1101: regChar[48:55] <= 8'h44;
4'b1110: regChar[48:55] <= 8'h45;
4'b1111: regChar[48:55] <= 8'h46;
default: regChar[48:55] <= 8'h30;
endcase
case(hex4)
4'b0000: regChar[56:63] <= 8'h30;
4'b0001: regChar[56:63] <= 8'h31;
4'b0010: regChar[56:63] <= 8'h32;
4'b0011: regChar[56:63] <= 8'h33;
4'b0100: regChar[56:63] <= 8'h34;
4'b0101: regChar[56:63] <= 8'h35;
4'b0110: regChar[56:63] <= 8'h36;
4'b0111: regChar[56:63] <= 8'h37;
4'b1000: regChar[56:63] <= 8'h38;
4'b1001: regChar[56:63] <= 8'h39;
4'b1010: regChar[56:63] <= 8'h41;
4'b1011: regChar[56:63] <= 8'h42;
4'b1100: regChar[56:63] <= 8'h43;
4'b1101: regChar[56:63] <= 8'h44;
4'b1110: regChar[56:63] <= 8'h45;
4'b1111: regChar[56:63] <= 8'h46;
default: regChar[56:63] <= 8'h30;
endcase
end
endmodule
