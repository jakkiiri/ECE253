module ff (
    input logic clk,
    input logic rst_n,
    input logic d,
    input logic loadn,
    input logic LoadLeft,
    input logic right,
    input logic left,
    output logic q
);
    logic shift_in;
    always_comb begin
        if (!loadn) begin
            shift_in = d;
        end else if (LoadLeft) begin
            shift_in = left;
        end else begin
            shift_in = right;
        end
    end
    always_ff @(posedge clk) begin
        if (rst_n)
            q <= 1'b0;
        else
            q <= shift_in;
    end
endmodule

module ff_0 (
    input logic clk,
    input logic rst_n,
    input logic d,
    input logic loadn,
    input logic LoadLeft,
    input logic right,
    input logic left,
    input logic asr,
    output logic q
);
    logic shift_in;
    always_comb begin
        if (!loadn) begin
            shift_in = d;
        end else if (LoadLeft) begin
            if (asr) begin
                shift_in = q; // Arithmetic shift right
            end else begin
                shift_in = left;
            end
        end else begin
            shift_in = right;
        end
    end
    always_ff @(posedge clk) begin
        if (rst_n)
            q <= 1'b0;
        else
            q <= shift_in;
    end
endmodule

module part1 (input logic clock, reset, ParallelLoadn, RotateRight, ASRight,
                input logic [3:0] Data_IN, 
                output logic [3:0] Q);
            // ASR only affects the first FF
    ff_0 ff0 (.clk(clock), .rst_n(reset), .d(Data_IN[3]), .loadn(ParallelLoadn), .LoadLeft(RotateRight), .right(Q[2]), .left(Q[0]), .asr(ASRight), .q(Q[3]));
    ff ff1 (.clk(clock), .rst_n(reset), .d(Data_IN[2]), .loadn(ParallelLoadn), .LoadLeft(RotateRight), .right(Q[1]), .left(Q[3]), .q(Q[2]));
    ff ff2 (.clk(clock), .rst_n(reset), .d(Data_IN[1]), .loadn(ParallelLoadn), .LoadLeft(RotateRight), .right(Q[0]), .left(Q[2]), .q(Q[1]));
    ff ff3 (.clk(clock), .rst_n(reset), .d(Data_IN[0]), .loadn(ParallelLoadn), .LoadLeft(RotateRight), .right(Q[3]), .left(Q[1]), .q(Q[0]));
endmodule
