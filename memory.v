module blockram( clk,addr_w,wr_enable,data_in,
addr_r,data_out );
parameter WIDTH = 16;
parameter DEPTH = 12;
input clk;
input wr_enable;
input [DEPTH-1:0] addr_w,addr_r;
input [WIDTH-1:0] data_in;
output reg [WIDTH-1:0] data_out;
reg [15:0] x_ram [0:(1 << DEPTH) - 1];
always@(posedge clk)
begin
if (wr_enable == 1'b1)
x_ram[addr_w] <= data_in;
end
always@(posedge clk)
begin
data_out = x_ram[addr_r];
end
integer index;
initial begin
for (index = 0; index < 4096; index = index + 1) begin
x_ram[index] = 8'h20; // ASCII space
end
end
endmodule
3.5.8) Controller
Controller code is attached which shows fetch decode and execute cycles from the program
module controller(clock, result, inPress, key, ansA, ansB, OPCODE, btn, ansstatus, anscountline);
input clock;
input [15:0] inPress; //input from keyboard
input key; //input from keyboard
input [3:0] btn;
reg start; //Memory
reg [15:0]pro_mem[0:511]; //Instruction memory
reg [15:0]data_mem[0:511]; //Data memory
reg [15:0]stack[0:31]; //Stack
reg [3:0]stack[0:2];
reg [2:0]firstChk;
reg [3:0]secChk;
reg [3:0]thirdChk;
reg [3:0]fourthChk;
reg [1:0]tab;
reg [15:0]checkOp; //copy of opcode
integer i;
//Registers
output reg [15:0]result;
output reg [15:0]ansA;
output reg [15:0]ansB;
output reg [2:0] ansstatus;
output reg[3:0] anscountline=0;
output reg [15:0] OPCODE=16'hfff0;
//Flags
reg C;
reg Z;
reg IEN;
reg var1, var2, var3;
reg init, nop;
//Registers
reg [11:0]PC; //Program Counter
reg [15:0]IR; //Instruction Register
reg [11:0]SP; //Stack Pointer
reg [11:0]savePC;
reg [4:0]operation;
reg [11:0]addr_ls; //Address register for LOAD/STORE operations
reg [15:0]A;
reg [15:0]B;
reg [4:0]saveOP[0:31];
reg [11:0]saveAddr[0:31];
reg [3:0]alu_op[0:31];
reg [3:0]mem_op[0:31];
reg [11:0]IR_addr[0:31];
integer x, ad, address;
initial
begin
firstChk <= 3'b0;
secChk <= 4'b0;
thirdChk <= 4'b0;
fourthChk <= 4'b0;
tab <= 2'b0;
i <= 0;
start = 0;
var1 <= 0;
var2 <= 0;
var3 <= 0;
init <= 0;
x <= 0;
ad <= 0;
saveAddr[0] = 12'h000;
saveOP[0] = 5'd26;
saveAddr[1] = 12'h000;
saveOP[1] = 5'd26;
saveAddr[2] = 12'h000;
saveOP[2] = 5'd26;
alu_op[0] = 4'hF;
mem_op[0] = 4'h0;
IR_addr[0] = 12'h000;
alu_op[1] = 4'hF;
mem_op[1] = 4'h0;
IR_addr[1] = 12'h00;
//ISR
pro_mem[50] = 16'h0000;
pro_mem[51] = 16'h1102 ; //lda 102
pro_mem[52] = 16'h7100; //ADD
pro_mem[53] = 16'hB000; //RET
//COE
data_mem[0] = 16'hABCD;
data_mem[256] = 16'h0000; //100
data_mem[257] = 16'h0001; //101
data_mem[258] = 16'h0002; //102
data_mem[259] = 16'h0003; //103
data_mem[260] = 16'hFFFF; //104
data_mem[261] = 16'hAAAA;
end
always @(posedge clock)
begin
if(!start)
begin
if(key)
begin
if(inPress != 16'hF05a) //if the key pressed is not "ENTER"
begin
case(firstChk)
//check the letter position in the instruction
3'b000:
begin
case(inPress)
16'hF01C: begin firstChk <=3'b001; secChk <= 4'b0000; end//A
16'hF021: begin firstChk <=3'b001; secChk <= 4'b0001; end//C
16'hF043: begin firstChk <=3'b001; secChk <= 4'b0010; end//I
16'hF04B: begin firstChk <=3'b001; secChk <= 4'b0100; end//L
16'hF03B: begin firstChk <=3'b001; secChk <= 4'b0101; end//J
16'hF04D: begin firstChk <=3'b001; secChk <= 4'b0110; end//P
16'hF02D: begin firstChk <=3'b001; secChk <= 4'b1111; end //R
16'hF023: begin firstChk <=3'b001; secChk <= 4'b0111; end//D
16'hF01B: begin firstChk <=3'b001; secChk <= 4'b0011; end//S
16'hF033: begin firstChk <=3'b001; secChk <= 4'b1110; end//H
16'hF031: OPCODE = 16'hF000; //NOP
default: firstChk <= 3'b000;
endcase
end
3'b001:
begin
case(inPress) //second alphabet
16'hF024:
begin
if(secChk == 4'b1111) begin firstChk <= 3'b010; thirdChk <= 4'b1111; end //RE
else if(secChk == 4'b0111) begin firstChk <= 3'b010; thirdChk <= 4'b1001; end //DE
end
16'hF01C:
begin
if(secChk == 4'b1110) begin firstChk <= 3'b010; thirdChk <= 4'b1110; end //HA
end
16'hF023:
begin
if(secChk == 4'b0000) begin firstChk <= 3'b010; thirdChk <= 4'b0111; end//AD
else if(secChk == 4'b0100) begin firstChk <= 3'b010; thirdChk <= 4'b0000; end//LD
end//D
16'hF031:
begin
if(secChk == 4'b0000) begin firstChk <= 3'b010; thirdChk <= 4'b0110; end//AN
16'hF04B:
begin
if(secChk == 4'b0001) begin firstChk <= 3'b010; thirdChk <= 4'b0001; end //CL
end
16'hF03A:
begin
if(secChk == 4'b0001) begin OPCODE = 16'h7500 ; end//CM
else if(secChk == 4'b0101) begin firstChk <= 3'b010; thirdChk <= 4'b0100 ; end//JM
end//M
16'hF044:
begin
if(secChk == 4'b0010) begin firstChk <= 3'b010; thirdChk <= 4'b0010; end//IO
else if(secChk == 4'b0110) begin OPCODE = 16'hA000 ; end//PO
end//O
16'hF021:
begin
if(secChk == 4'b0011) begin OPCODE = 16'h7C00; end
end//SC
16'hF01A:
begin
if(secChk == 4'b0011) begin OPCODE = 16'h7D00; end
end//SZ
16'hF02C:
begin
if(secChk == 4'b0011) begin firstChk <= 3'b010; thirdChk <= 4'b0011; end
end//ST
16'hF01B:
begin if(secChk == 4'b0101) begin firstChk <= 3'b010; thirdChk <= 4'b0101; end
end//JS
16'hF03C:
begin
if(secChk == 4'b0110) begin OPCODE = 16'b1001000000000000; end
end//PU
default: #0;
endcase
end
3'b010:
begin
case(inPress) //third alphabet
16'hF04B:
begin
if(thirdChk == 4'b1110) begin firstChk <= 3'b011; fourthChk <= 4'b1110; end //HAL
end
16'hF02C:
begin
if(thirdChk == 4'b1111) begin OPCODE = 16'b1011000000000000; end//RET
end
16'hF023:
begin
if(thirdChk == 4'b0111) begin OPCODE = 16'h7100; end//ADD
else if(thirdChk == 4'b0110) begin OPCODE = 16'h7200; end//AND
end
16'hF01C:
begin
if(thirdChk == 4'b0000) begin firstChk <= 3'b011; fourthChk <= 4'b0000; end//LDA
else if(thirdChk == 4'b0001) begin OPCODE = 16'h7300; end//CLA
else if(thirdChk == 4'b0011) begin firstChk <= 3'b011; fourthChk <= 4'b0010; end//STA
end//A
16'hF032:
begin
if(thirdChk == 4'b0000) begin firstChk <= 3'b011; fourthChk <= 4'b0001; end//LDB
else if(thirdChk == 4'b0001) begin OPCODE = 16'h7400; end//CLB
else if(thirdChk == 4'b0011) begin firstChk <= 3'b011; fourthChk <= 4'b0011; end//STB
end//B
16'hF021:
begin
if(thirdChk == 4'b0001) OPCODE = 16'h7800;//CLC
else if(thirdChk == 4'b1001) begin firstChk <= 3'b011; fourthChk <= 4'b0111; end//DEC
end //C
16'hF01A: begin if(thirdChk == 4'b0001) OPCODE = 16'h7900; end//CLZ
16'hF031: begin if(thirdChk == 4'b0010) OPCODE = 16'h7A00; end//ION
16'hF02B: begin if(thirdChk == 4'b0010) OPCODE = 16'h7B00; end//IOF
16'hF04D:
begin
if(thirdChk == 4'b0100) begin firstChk <= 3'b011; fourthChk <= 4'b0100; end //JMP
end
16'hF02D:
begin
if(thirdChk == 4'b0101) begin firstChk <= 3'b011; fourthChk <= 4'b0101; end //JSR
end
default: #0;
endcase
end
3'b011:
begin
if(inPress == 16'hF02C)
begin
if(fourthChk == 4'b1110) begin OPCODE = 16'hC000; end //HALT
end
if(inPress == 16'hF01C)
begin
if(fourthChk == 4'b0110) begin OPCODE = 16'h7E00; end//INCA
else if(fourthChk == 4'b0111) begin OPCODE = 16'h7F00; end//DECA
end//A
if(inPress == 16'hF032)
begin
if(fourthChk == 4'b0110) begin OPCODE = 16'h7600; end//INCB
else if(fourthChk == 4'b0111) begin OPCODE = 16'h7700; end//DECB
end//B
/////////////////////////////////////////////
if(inPress == 16'hF00D) begin tab <= 2'b01; end
//address following mnemonic
if(tab == 2'b01)
begin
case(inPress)
16'hF045: begin stack[0] <= 4'b0000 ; firstChk <= 3'b100; end
16'hF016: begin stack[0] <= 4'b0001 ; firstChk <= 3'b100; end
16'hF01E: begin stack[0] <= 4'b0010 ; firstChk <= 3'b100; end
16'hF026: begin stack[0] <= 4'b0011 ; firstChk <= 3'b100; end
16'hF025: begin stack[0] <= 4'b0100 ; firstChk <= 3'b100; end
16'hF02E: begin stack[0] <= 4'b0101 ; firstChk <= 3'b100; end
16'hF036: begin stack[0] <= 4'b0110 ; firstChk <= 3'b100; end
16'hF03D: begin stack[0] <= 4'b0111 ; firstChk <= 3'b100; end
16'hF03E: begin stack[0] <= 4'b1000 ; firstChk <= 3'b100; end
16'hF046: begin stack[0] <= 4'b1001 ; firstChk <= 3'b100; end
16'hF01C: begin stack[0] <= 4'b1010 ; firstChk <= 3'b100; end
16'hF032: begin stack[0] <= 4'b1011 ; firstChk <= 3'b100; end
16'hF021: begin stack[0] <= 4'b1100 ; firstChk <= 3'b100; end
16'hF023: begin stack[0] <= 4'b1101 ; firstChk <= 3'b100; end
16'hF024: begin stack[0] <= 4'b1110 ; firstChk <= 3'b100; end
16'hF02B: begin stack[0] <= 4'b1111 ; firstChk <= 3'b100; end
default: #0;
endcase
end
end
3'b100:
begin
if(inPress == 16'hF00D) begin tab <= 2'b10; end
//address following mnemonic
if(tab == 2'b10)
begin
case(inPress)
16'hF045: begin stack[1] <= 4'b0000 ; firstChk <= 3'b101; end
16'hF016: begin stack[1] <= 4'b0001 ; firstChk <= 3'b101; end
16'hF01E: begin stack[1] <= 4'b0010 ; firstChk <= 3'b101; end
16'hF026: begin stack[1] <= 4'b0011 ; firstChk <= 3'b101; end
16'hF025: begin stack[1] <= 4'b0100 ; firstChk <= 3'b101; end
16'hF02E: begin stack[1] <= 4'b0101 ; firstChk <= 3'b101; end
16'hF036: begin stack[1] <= 4'b0110 ; firstChk <= 3'b101; end
16'hF03D: begin stack[1] <= 4'b0111 ; firstChk <= 3'b101; end
16'hF03E: begin stack[1] <= 4'b1000 ; firstChk <= 3'b101; end
16'hF046: begin stack[1] <= 4'b1001 ; firstChk <= 3'b101; end
16'hF01C: begin stack[1] <= 4'b1010 ; firstChk <= 3'b101; end
16'hF032: begin stack[1] <= 4'b1011 ; firstChk <= 3'b101; end
16'hF021: begin stack[1] <= 4'b1100 ; firstChk <= 3'b101; end
16'hF023: begin stack[1] <= 4'b1101 ; firstChk <= 3'b101; end
16'hF024: begin stack[1] <= 4'b1110 ; firstChk <= 3'b101; end
16'hF02B: begin stack[1] <= 4'b1111 ; firstChk <= 3'b101; end
default: #0 ;
endcase
end
end
3'b101:
begin
if(inPress == 16'hF00D) begin tab <= 2'b11; end
//address following mnemonic
if(tab == 2'b11)
begin
case(inPress)
16'hF045: begin stack[2] <= 4'b0000; end
16'hF016: begin stack[2] <= 4'b0001; end
16'hF01E: begin stack[2] <= 4'b0010; end
16'hF026: begin stack[2] <= 4'b0011; end
16'hF025: begin stack[2] <= 4'b0100; end
16'hF02E: begin stack[2] <= 4'b0101; end
16'hF036: begin stack[2] <= 4'b0110; end
16'hF03D: begin stack[2] <= 4'b0111; end
16'hF03E: begin stack[2] <= 4'b1000; end
16'hF046: begin stack[2] <= 4'b1001; end
16'hF01C: begin stack[2] <= 4'b1010; end
16'hF032: begin stack[2] <= 4'b1011; end
16'hF021: begin stack[2] <= 4'b1100; end
16'hF023: begin stack[2] <= 4'b1101; end
16'hF024: begin stack[2] <= 4'b1110; end
16'hF02B: begin stack[2] <= 4'b1111; end
default: #0 ;
endcase
end
if(fourthChk == 4'b0000) begin OPCODE = {4'b0000, stack[0], stack[1], stack[2]}; end//LDA
else if(fourthChk == 4'b0001) begin OPCODE = {4'b0001, stack[0], stack[1], stack[2]}; end//LDB
else if(fourthChk == 4'b0010) begin OPCODE = {4'b0010, stack[0], stack[1], stack[2]}; end//STA
else if(fourthChk == 4'b0011) begin OPCODE = {4'b0011, stack[0], stack[1], stack[2]}; end//STB
else if(fourthChk == 4'b0100) begin OPCODE = {4'b0100, stack[0], stack[1], stack[2]}; end//JMP
else if(fourthChk == 4'b0101) begin OPCODE = {4'b1000, stack[0], stack[1], stack[2]}; end//JSR
end
endcase
end
else if(inPress == 16'hF05a) //"ENTER" key pressed
begin
anscountline= anscountline+1;
if(!i)
begin
pro_mem[i] = OPCODE;
i = i+1;
end
else
begin
if(OPCODE != checkOp)
begin
pro_mem[i] = OPCODE;
i = i+1;
end
end
checkOp = OPCODE;
firstChk <= 3'b0;
secChk <= 4'b0;
thirdChk <= 4'b0;
fourthChk <= 4'b0;
tab <= 2'b0;
stack[0] <= 4'b0;
stack[1] <= 4'b0;
stack[2] <= 4'b0;
if(OPCODE == 16'hC000)
start = 1;
end
end//if(key)
end//if(!start)
else
begin
//initialize PC, IR, SP and addr_ls
if(btn[0] == 1)
begin
PC = 12'b0;
IR = 16'hF000;
SP = 12'd31;
addr_ls = 12'b0;
init <= 1;
end
//if control registers have been initialized
else
begin
if(init && !var1)
begin
if((IR[15:8] == 8'b01111100) && C)
begin
PC = PC + 1;
end
//SZ instruction
else if(IR[15:8] == 8'b01111101 && Z)
begin
PC = PC + 1;
end
//JMP instruction
else if(IR[15:12] == 4'b0100)
begin
PC = IR[11:0];
end
//JSR instruction
else if((IR[15:12] == 4'b1000) && (IEN==1))
begin
stack[SP] = PC;
PC = IR[11:0];
SP = SP-1;
end
//RET instruction
else if(IR[15:12] == 4'b1011)
begin
SP = SP+1;
PC = stack[SP];
end
//HALT instruction
else if(IR[15:12] == 4'b1100)
begin
var1 <= 1;
end
//load the IR
IR = pro_mem[PC];
IR_addr[ad+2] = IR[11:0];
alu_op[ad+2] = IR[15:12];
mem_op[ad+2] = IR[11:8];
PC = PC + 1;
ad = ad + 1;
end
if(init && !var2)
begin
if(alu_op[ad] == 4'b0111)
begin
case(mem_op[ad])
4'b0001: operation = 1;//ADD
4'b0010: operation = 2;//AND
4'b0011: operation = 3;//CLA
4'b0100: operation = 4;//CLB
4'b0101: operation = 5;//CMB
4'b0110: operation = 6;//INCB
4'b0111: operation = 7;//DECB
4'b1000: operation = 8;//CLC
4'b1001: operation = 9;//CLZ
4'b1010: operation = 10;//ION
4'b1011: operation = 11;//IOFF
4'b1100: operation = 12;//SC
4'b1101: operation = 13;//SZ
4'b1110: operation = 24;//INCA
4'b1111: operation = 25;//DECA
default: operation = 26;//NOP
endcase
saveOP[x+2] = operation;
end
else
begin
case(alu_op[ad])
4'b0000: begin operation = 14; addr_ls = IR_addr[ad]; saveAddr[x+2] = addr_ls; end//LDA
4'b0001: begin operation = 15; addr_ls = IR_addr[ad]; saveAddr[x+2] = addr_ls; end//LDB
4'b0010: begin operation = 16; addr_ls = IR_addr[ad]; saveAddr[x+2] = addr_ls; end//STA
4'b0011: begin operation = 17; addr_ls = IR_addr[ad]; saveAddr[x+2] = addr_ls; end//STB
4'b0100: begin operation = 18; addr_ls = IR_addr[ad]; saveAddr[x+2] = addr_ls; end//JMP
4'b1000: begin operation = 19; addr_ls = IR_addr[ad]; saveAddr[x+2] = addr_ls; end//JSR
4'b1001: operation = 20;//PUSHA
4'b1010: operation = 21;//POPA
4'b1011: operation = 22;//RET
4'b1100: begin operation = 23; var2 <= 1; end//HALT
4'b1111: begin operation = 26; end//NOP
default: operation = 26;//NOP
endcase
saveOP[x+2] = operation;
end
end
if(init && !var3)
begin
x = x + 1;
case(saveOP[x])
1: begin {C, A[15:0]} = A + B;
if(A == 0 || B == 0) Z = 1; else Z = 0;end//ADD
2: begin A = A & B; if(A == 0 || B == 0) Z = 1; else Z = 0;end//AND
3: begin A = 0; if(A == 0 || B == 0) Z = 1; else Z = 0;end//CLA
4: begin B = 0; if(A == 0 || B == 0) Z = 1; else Z = 0;end//CLB
5: begin B = ~B; if(A == 0 || B == 0) Z = 1; else Z = 0;end//CMB
6: begin B = B + 1'b1; if(A == 0 || B == 0) Z = 1; else Z = 0;end//INCB
7: begin B = B - 1'b1; if(A == 0 || B == 0) Z = 1; else Z = 0;end//DECB
8: begin C = 0; end//CLC
9: begin Z = 0; end//CLZ
10: begin IEN = 1; end//ION
11: begin IEN = 0; end//IOFF
12: begin if(C) savePC = PC + 1; end//SC
13: begin if(Z) savePC = PC + 1; end//SZ
14: begin address = saveAddr[x]; A = data_mem[address];if(A == 0 || B == 0) Z = 1; else Z = 0; end//LDA
15: begin address = saveAddr[x]; B = data_mem[address]; if(A == 0 || B == 0) Z = 1; else Z = 0;end//LDB
16: begin address = saveAddr[x]; data_mem[address] = A; end//STA
17: begin address = saveAddr[x]; data_mem[address] = B; end//STB
18: begin savePC = saveAddr[x]; end//JMP
19: begin savePC = saveAddr[x]; end//JSR
20: begin stack[SP] = A; end//PUSHA
21: begin A = stack[SP]; if(A == 0 || B == 0) Z = 1; else Z = 0;end//POPA
22: begin savePC = stack[SP]; end//RET
23: begin var3 <= 1; end//HALT
24: begin {C,A} = A + 1'b1;if(A == 0 || B == 0) Z = 1; else Z = 0; end//INCA
25: begin {C,A} = A - 1'b1; if(A == 0 || B == 0) Z = 1; else Z = 0;end//DECA
26: begin nop = ~nop; end//NOP
default: begin A = A + 1'b0; B = B + 1'b0; end
endcase
end
//display
if(init && var3)
begin
ansA = A;
ansB = B;
ansstatus[0]= C;
ansstatus[1]= Z;
ansstatus[2]= IEN;
end
end
end
end
endmodule
