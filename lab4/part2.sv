// Rate_divider: generates an Enable pulse every CYCLES clocks.
// NOTE: Reset is treated as active LOW in this design (if (!Reset) ...)
module Rate_divider #(parameter CLOCK_FREQUENCY=500) (
    input  logic clk,
    input  logic Reset,         // active low
    input  logic [1:0] Speed,
    output logic Enable
);

    localparam WIDTH = $clog2(CLOCK_FREQUENCY*4);
    logic [WIDTH-1:0] CYCLES;
    // determine the number of cycles that need to be counted
    always_comb 
    begin
        case (Speed)
            2'b00: CYCLES = 1; // same as clock
            2'b01: CYCLES = CLOCK_FREQUENCY; // 1 Hz
            2'b10: CYCLES = CLOCK_FREQUENCY*2; // 0.5 Hz
            2'b11: CYCLES = CLOCK_FREQUENCY*4; // 0.25 Hz
            default: CYCLES = 1;
    endcase
    end
    logic [WIDTH-1:0] Q_reg, Q_next;

    always_comb begin
        Enable = 1'b0;
        // handles cycle at one
        if (CYCLES == 1) begin
            Q_next = 0;
            Enable = 1'b1;
        end
        else if (Q_reg == 0) begin
            Q_next = CYCLES - 1;
            Enable = 1'b1;
        end
        else begin
            Q_next = Q_reg - 1;
        end
    end

    always_ff @(posedge clk) begin
        if (!Reset)
            Q_reg <= CYCLES - 1;
        else
            Q_reg <= Q_next;
    end
endmodule

module DisplayCounter (
    input logic clk, Reset, EnableDC,
    output logic [3:0] CounterValue
);
    always_ff @(posedge clk) begin
        if (!Reset) begin
            CounterValue <= 4'b0000;
        end
        else if (EnableDC) begin
            CounterValue <= CounterValue + 1;
        end
    end
endmodule

module part2 #(parameter CLOCK_FREQUENCY=500) (
    input logic ClockIn,
    input logic Reset,
    input logic [1:0] Speed,
    output logic [3:0] CounterValue
);
    logic EnableDC;
    Rate_divider #(CLOCK_FREQUENCY) RD (
        .clk(ClockIn),
        .Reset(Reset),
        .Speed(Speed),
        .Enable(EnableDC)
    );

    DisplayCounter DC (
        .clk(ClockIn),
        .Reset(Reset),
        .EnableDC(EnableDC),
        .CounterValue(CounterValue)
    );

endmodule