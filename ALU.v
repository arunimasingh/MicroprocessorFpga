module ALU (operation, a, b, pixel_clock,A1,B1, pc,run,pcnew,ion);
input[7:0] operation;
input[15:0] a;
//////////////
input[15:0] b;
input [11:0] pc;
input pixel_clock;
//input[5:0] status; //5- zero, carry, underflow, overflow, interrupt, negative
//output reg[15:0] ans;
output reg[11:0] pcnew;
reg [15:0] A,B;
reg [5:0] STATUS=0;
reg [11:0] PC;
reg flag=0;
reg c;
input run;
output reg [15:0] A1=0,B1=0;
output reg ion=0;
always @(posedge pixel_clock)
begin
if (run == 1)
begin
A=a;
B=b;
PC=pc;
//STATUS=status;
case(operation)
8'b01110001: begin {c,A1}= A + B; //ADD
if(A1 == 0 ) //zero
STATUS[5]=1;
if(c == 1) //carry
STATUS[4]=1;
if(A1[15]== 1) //negative
STATUS[0]=1;
pcnew=PC;
end
8'b01110010: begin {c,A1}= A & B; //AND
if(A1 == 0 ) //zero
STATUS[5]=1;
if(c == 1) //carry
STATUS[4]=1;
if(A1[15]== 1) //negative
STATUS[0]=1;
pcnew=PC;
end
8'b01110011: begin A=0; STATUS[5]=1; pcnew=PC; end //CLA
8'b01110100: begin B=0; STATUS[5]=1; pcnew=PC; end //CLB
8'b01110101: begin B1=~B;
if(B1 == 0 ) //zero
STATUS[5]=1;
if(B1[15]== 1) //negative
STATUS[0]=1;
pcnew=PC;
end // CMB
8'b01110110: begin {c,B1}=B+1; //INCB
if(B1 == 0 ) //zero
STATUS[5]=1;
if(c == 1) //carry
STATUS[4]=1;
if(B1[15]== 1) //negative
STATUS[0]=1;
pcnew=PC;
end
8'b01110111: begin {c,B1}=B-1; //DECB
if(B1 == 0 ) //zero
STATUS[5]=1;
if(c == 1) //carry
STATUS[4]=1;
if(B1[15]== 1) //negative
STATUS[0]=1;
pcnew=PC;
end
8'b01111000: begin STATUS = STATUS & 6'b101111; pcnew=PC; end //CLC
8'b01111001: begin STATUS = STATUS & 6'b011111; pcnew=PC; end // CLZ
8'b01111010: begin STATUS = STATUS | 6'b000010; ion=1; pcnew=PC; end //ION
8'b01111011: begin STATUS = STATUS & 6'b111101; ion=0; pcnew=PC; end //IOF
8'b01111100: begin
if(STATUS[4] == 1)
pcnew=PC+1; //SC
end
8'b01111101: begin
if(STATUS[5] == 1)
pcnew=PC+1; //SZ
end
default: begin A=0; pcnew=PC; end
endcase
end
A1= 70;
end
endmodule
