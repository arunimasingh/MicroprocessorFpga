module keyboard(clock, ps2_clk, ps2_data, char, key);
input clock;
input ps2_data;
input ps2_clk;
output [15:0]char;
output key;
reg [15:0]char;
reg key;
reg [9:0] bits = 0;
reg [3:0] count = 0;
reg [1:0] ps2_clk_prev2 = 2'b11;
reg [19:0] timeout = 0;
always @(posedge clock)
ps2_clk_prev2 <= {ps2_clk_prev2[0], ps2_clk};
always @(posedge clock)
begin
if((count == 11) || (timeout[19] == 1))
begin
count <= 0;
//check for key up code or extended key code (E0)
//extract the corresponding key scan code
if((char[7:0] == 8'hE0) || (char[7:0] == 8'hF0))
begin
key <= 1;
char[15:0] <= {char[7:0], bits[7:0]};
end
else
begin
key <= 0;
char[15:0] <= {8'b0, bits[7:0]};
end
end
else
begin
if(ps2_clk_prev2 == 2'b10)
begin
count <= count + 1;
bits <= {ps2_data, bits[9:1]};
end
end
end
always @(posedge clock)
timeout <= (count != 0) ? timeout + 1 : 0;
endmodule //end keyboard
