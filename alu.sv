// EECE 343 - Fall 2020
// Project 1
//
// Dalton Bailey
module alu #(
	parameter DATA_WIDTH = 32
) (
	
	input  logic [DATA_WIDTH-1:0] A,      // "Upper" input operand, always Rn
	input  logic [DATA_WIDTH-1:0] B,      // "Lower" input operand, Rm or Rd
	input  logic [3:0]            ALU_Op, // Operation control signal
	output logic [DATA_WIDTH-1:0] Result, // Result of the operation
	output logic                  N,      // Result condition codes, N = negative
	                              Z,      // Zero
	                              C,      // Carry
	                              V       // oVerflow
);
	//Logic variables used to compute right shifts
	logic [63:0]				asr_data;
	logic [63:0]				lsr_data;
	always_comb  begin
	//Initialize flags and Result to zero
	N = 0;
	C = 0;
	V = 0;
	Z = 0;
	Result = 0; 
	//Compute left shift and right shift to be used later
	lsr_data = {32'h0, A} >> B[4:0];
	if(A[31] == 1)
		asr_data = {32'hffffffff, A} >> B[4:0];
	else
		asr_data = {32'h0, A} >> B[4:0];
		
		//Assign a value to result based on ALU_Op
		case(ALU_Op)
		4'b0000	:	Result = A & B; //And operation
		4'b0001	:	Result = A | B; //Or operation
		4'b0010	:	Result = A ^ B; //Xor operation
		4'b0011	:	{C,Result} = A + B; //Add operation
		4'b0100	:	Result = A << B[4:0]; //Logical shift left operation
		4'b0101	:	Result = lsr_data[31:0]; //Logical shift right operation
		4'b0110	:	Result = asr_data[31:0]; //Arithmetic shift right operation 
		4'b0111	:	Result = A << (32-B[4:0]) | A >> B[4:0]; //Rotate right operation 
		4'b1011	:	{C,Result} = A + ~B + 1'b1; //Subtraction operation 
		default	:	Result = 0; //Undefined operation 
		endcase 
		
		//Assign Zero and negative flags after the operation has been chosen.
		Z = (Result == 32'b0) ? 1:0;
		N = (Result[31] == 1) ? 1:0;  
		//Assign flags based on ALU_Op
		case(ALU_Op)
		4'b0000: V = 1'b0; //Overflow cannot occur during bitwise and
		4'b0011: begin  
					//If Operands have the same sign but result does not; overflow has occured
					if (A[31] == B[31] && Result[31] != A[31])  
							V = 1; 
					else 
							V = 0;
					end 
		4'b0110: //Sets all flags to undefined when performing an arithmetic right shift
					begin 
						Z = 1'bx;
						N = 1'bx;
						C = 1'bx;
						V = 1'bx;
					end
		4'b1011: begin 
						C = ~C;
						//If B has the same sign as Result after a subtraction; we know overflow has occured
						if (Result[31] == B[31] && A[31] != B[31])
							V = 1; 
						else 
							V = 0;
					end 
		endcase 
	end
endmodule



