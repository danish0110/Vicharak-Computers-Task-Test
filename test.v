module test (

input clk,
input rst,
input [18:0] instr,
output reg[18:0] pc,
output reg[18:0] result,
);

reg [18:0] regfile [0:15]; //register
reg [18:0] memory [0:1023]; //memory
reg [18:0] stack [0:15]; //stack
reg [3:0] sp; //stack pointer

//instructions

wire [5:0] opcode = instr[18:13];
wire [3:0] r1 = instr[12:9]; //destination register
wire [3:0] r2 = instr[8:5]; //source register 1
wire [3:0] r3 = instr[4:1]; //source register 2
wire [18:9] addr = {instr[12:0], 6'b0}; //address

//ALU

always @(posedge clk or posedge rst) begin
    if (rst)begin
        pc <= 0;

        sp <= 0;
    end
      else begin
        case(opcode)

     //Arirgmetic Instructions
      
    6'b000001 : regfile[r1] <= regfile[r2] + regfile[r2]; //Addition
    6'b000010 : regfile[r1] <= regfile[r2] - regfile[r2]; //Substraction
    6'b000011 : regfile[r1] <= regfile[r2] * regfile[r2]; //Multiplication
    6'b000100 : regfile[r1] <= regfile[r2] / regfile[r2]; //Division
    6'b000101 : regfile[r1] <= regfile[r1] + 1; //Increment
    6'b000110 : regfile[r1] <= regfile[r1] - 1; //Decrement

    //Logical Instruction
    
    6'b001001 : regfile[r1] <= regfile[r2] & regfile[r3]; //AND
    6'b001010 : regfile[r1] <= regfile[r2] | regfile[r3]; // OR
    6'b001011 : regfile[r1] <= regfile[r2] ^ regfile[r3]; //XOR
    6'b001100 : regfile[r1] <= ~regfile[r2]; //NOT


    //Control Flow Instructions

    6'b010001 : pc <= addr; //Jump
    6'b010010 : if(regfile[r1] == regfile[r2]) pc <= addr; //BEQ
    6'b010011 : if(regfile[r1] != regfile[r2]) pc <= addr; //BNE
    
    6'b010100 :  begin  //Call Addr
      stack[sp] <= pc + 1;
      sp <= sp - 1;
      pc <= addr;

    end
 
    6'b010101 : begin //RET
     sp <=  sp + 1;
     pc = stack[sp];
    end

    // Memory Access Instruction

    6'b011001 : regfile[r1] <= memory[addr]; //LD r1, addr
    6'b011010 : memory[addr] <= regfile[r1]; //ST addr,r1

    // Custom Instruction

    6'b100001 : begin
     FFT(memory[r2], result ); memory[r1] <= result; //fft r1,r2
    end

    
    6'b100010 : begin
    regfile[r1] <= memory[r2] ^ 19'hABCD; //encryption using xor with constant key
    end
    
    6'b100011 : begin
     regfile[r1] <= memory[r2] ^ 19'hABCD; //decryption using xor with same key
    end

 default: result <= 0; //default
 endcase
      end
end
endmodule