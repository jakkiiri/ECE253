`timescale 1ns / 1ns
/************************** Control path **************************************************/
module control_path(
    input logic clk,
    input logic reset, 
    input logic run, 
    input logic [15:0] INSTRin,
    output logic R0in, R1in, Ain, Rin, IRin, 
    output logic [1:0] select, ALUOP,
    output logic done
); 

/* OPCODE format: II M X DDDDDDDDDDDD, where 
    *     II = instruction, M = Immediate, X = rX; X = (rX==0) ? r0:r1
    *     If M = 0, DDDDDDDDDDDD = 00000000000Y = rY; Y = (rY==0) r0:r1
    *     If M = 1, DDDDDDDDDDDD = #D is the immediate operand 
    *
    *  II M  Instruction   Description
    *  -- -  -----------   -----------
    *  00 0: mv    rX,rY    rX <- rY
    *  00 1: mv    rX,#D    rX <- D (sign extended)
    *  01 0: add   rX,rY    rX <- rX + rY
    *  01 1: add   rX,#D    rX <- rX + D
    *  10 0: sub   rX,rY    rX <- rX - rY
    *  10 1: sub   rX,#D    rX <- rX - D
    *  11 0: mult  rX,rY    rX <- rX * rY
    *  11 1: mult  rX,#D    rX <- rX * D 
*/

parameter mv = 2'b00, add = 2'b01, sub = 2'b10, mult = 2'b11;

logic [1:0] II;
logic M, rX, rY;

assign II = INSTRin[15:14];
assign M =  INSTRin[13];
assign rX = INSTRin[12];
assign rY = INSTRin[0];

// control FSM states
typedef enum logic[1:0]
{
    C0 = 'd0,
    C1 = 'd1, 
    C2 = 'd2, 
    C3 = 'd3
} statetype;

statetype current_state, next_state;


// control FSM state table
always_comb begin
    case(current_state)
	C0: next_state = run? C1:C0;
        C1: next_state = done? C0:C2;
        C2: next_state = C3;
        C3: next_state = C0;
    endcase
end

// output logic i.e: datapath control signals
always_comb begin
    // by default, make all our signals 0
    R0in = 1'b0; R1in = 1'b0;
    Ain = 1'b0; Rin = 1'b0; IRin = 1'b0;
    select = 2'bxx; 
    ALUOP = 2'bxx;
    done = 1'b0;

    case(current_state)
        C0: IRin = 1'b1; // load instruction register
        C1: begin
            case (II)
                mv: begin
                    if (M) begin
                        select = 2'b11;
                        // write immediate to destination rX
                        if (rX == 1'b0) R0in = 1'b1; else R1in = 1'b1;
                    end else begin
                        if (rY == 1'b0)
                            select = 2'b01; // select r0
                        else 
                            select = 2'b10; // select r1
                        // write rY into rX
                        if (rX == 1'b0) R0in = 1'b1; else R1in = 1'b1;
                    end
                    done = 1'b1;
                end
                add: begin
                    Ain = 1'b1;
                    if (rX == 1'b0)
                        select = 2'b01; // select r0
                    else 
                        select = 2'b10; // select r1
                end
                sub: begin
                    Ain = 1'b1;
                    if (rX == 1'b0)
                        select = 2'b01; // select r0
                    else 
                        select = 2'b10; // select r1
                end
                mult: begin
                    Ain = 1'b1;
                    if (rX == 1'b0)
                        select = 2'b01; // select r0
                    else 
                        select = 2'b10; // select r1
                end
            endcase
        end
        C2: begin
            case (II)
                add: begin
                    Rin = 1'b1; // load result into rX
                    if (M)
                        select = 2'b11; // select immediate
                    else begin
                        if (rY == 1'b0)
                            select = 2'b01; // select r0
                        else 
                            select = 2'b10; // select r1
                    end
                    ALUOP = 2'b00; // add 
                end
                sub: begin
                    Rin = 1'b1; // load result into rX
                    if (M)
                        select = 2'b11; // select immediate
                    else begin
                        if (rY == 1'b0)
                            select = 2'b01; // select r0
                        else 
                            select = 2'b10; // select r1
                    end
                    ALUOP = 2'b01; // sub 
                end
                mult: begin
                    Rin = 1'b1; // load result into rX
                    if (M)
                        select = 2'b11; // select immediate
                    else begin
                        if (rY == 1'b0)
                            select = 2'b01; // select r0
                        else 
                            select = 2'b10; // select r1
                    end
                    ALUOP = 2'b10; // mult 
                end
            endcase
        end
        C3: begin
            case (II)
                add: begin
                    select = 2'b00;
                    if (rX == 1'b0)
                        R0in = 1'b1;
                    else 
                        R1in = 1'b1;
                    done = 1'b1;
                end
                sub: begin
                    select = 2'b00;
                    if (rX == 1'b0)
                        R0in = 1'b1;
                    else 
                        R1in = 1'b1;
                    done = 1'b1;
                end
                mult: begin
                    select = 2'b00;
                    if (rX == 1'b0)
                        R0in = 1'b1;
                    else 
                        R1in = 1'b1;
                    done = 1'b1;
                end
            endcase
        end
    endcase 
end


// control FSM FlipFlop
always_ff @(posedge clk) begin
    if(reset)
        current_state <= C0;
    else
       current_state <= next_state;
end

endmodule






/************************** Datapath **************************************************/
module datapath(
    input logic clk, 
    input logic reset,
    input logic [15:0] INSTRin,
    input logic IRin, R0in, R1in, Ain, Rin,
    input logic [1:0] select, ALUOP,
    output logic [15:0] r0, r1, a, r // for testing purposes these are outputs
);

// Instruction Register
logic [15:0] IR;
always_ff @(posedge clk) begin
    if (reset)
        IR <= 16'b0;
    else if (IRin)
        IR <= INSTRin;
end

// Registers
logic [15:0] R0_reg, R1_reg, A_reg, R_reg;
assign r0 = R0_reg;
assign r1 = R1_reg;
assign a  = A_reg;
assign r  = R_reg;

// Immediate (sign-extended)
logic [15:0] imm;
assign imm = {{4{IR[11]}}, IR[11:0]};

// MUX_out (
logic [15:0] mux_out;
always_comb begin
    case(select)
        2'b00: mux_out = R_reg;   // ALU result
        2'b01: mux_out = R0_reg;  // r0
        2'b10: mux_out = R1_reg;  // r1  <-- corrected literal (was 2'b02)
        2'b11: mux_out = imm;     // immediate
        default: mux_out = 16'b0;
    endcase
end

// Load into A register (always loads rX)
logic rX;
assign rX = IR[12]; 

always_ff @(posedge clk) begin
    if (reset)
        A_reg <= 16'b0;
    else if (Ain)
        A_reg <= (rX == 1'b0) ? R0_reg : R1_reg;
end

// ALU
logic [15:0] alu_out;
always_comb begin
    case (ALUOP)
        2'b00: alu_out = A_reg + mux_out; // add
        2'b01: alu_out = A_reg - mux_out; // sub
        2'b10: alu_out = A_reg * mux_out; // mult
        default: alu_out = mux_out;       // mv
    endcase
end

// R register holds ALU result
always_ff @(posedge clk) begin
    if (reset)
        R_reg <= 16'b0;
    else if (Rin)
        R_reg <= alu_out;
end

// Write back to destination register
always_ff @(posedge clk) begin
    if (reset)
        R0_reg <= 16'b0;
    else if (R0in)
        R0_reg <= mux_out;
end

always_ff @(posedge clk) begin
    if (reset)
        R1_reg <= 16'b0;
    else if (R1in)
        R1_reg <= mux_out;
end

endmodule


/************************** processor  **************************************************/
module part2(
    input logic [15:0] INSTRin,
    input logic reset, 
    input logic clk,
    input logic run,
    output logic done,
    output logic[15:0] r0_out,r1_out, a_out, r_out
);

// intermediate logic 
logic r0in, r1in, ain, rin, irin;
logic[1:0] select, aluop;

control_path control(
   .clk(clk),
   .reset(reset), 
   .run(run), 
   .INSTRin(INSTRin),
   .R0in(r0in), 
   .R1in(r1in), 
   .Ain(ain), 
   .Rin(rin), 
   .IRin(irin), 
   .select(select), 
   .ALUOP(aluop),
   .done(done)
);

datapath data(
    .clk(clk), 
    .reset(reset),
    .INSTRin(INSTRin),
    .IRin(irin), 
    .R0in(r0in),
    .R1in(r1in), 
    .Ain(ain),
    .Rin(rin),
    .select(select), 
    .ALUOP(aluop),
    .r0(r0_out), 
    .r1(r1_out),
    .a(a_out),
    .r(r_out)
);

endmodule
