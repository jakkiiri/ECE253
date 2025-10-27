module part3(
    input  logic        Clock, Reset, Go,
    input  logic [3:0]  Divisor, Dividend,
    output logic [3:0]  Quotient, Remainder,
    output logic        ResultValid
);

    // Internal Registers
    logic [4:0] A;                 
    logic [3:0] Q;
    logic [4:0] M;
    logic [2:0] count;
    logic q0;
    logic sub;

    typedef enum logic [1:0] {IDLE, RUN, DONE} state_t;
    state_t state, next_state;

    assign Quotient = Q;
    assign Remainder = A[3:0];
    assign ResultValid = (state == DONE);

    // Extend divisor to 5 bits: (0 m3 m2 m1 m0)
    always_ff @(posedge Clock or posedge Reset) begin
        if (Reset)
            M <= 5'b0;
        else if (Go && state == IDLE)
            M <= {1'b0, Divisor};
    end

    // FSM State Register
    always_ff @(posedge Clock or posedge Reset) begin
        if (Reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // FSM Next State Logic
    always_comb begin
        next_state = state;
        case(state)
            IDLE: if (Go) next_state = RUN;
            RUN:  if (count == 3'd4) next_state = DONE;
            DONE: if (!Go) next_state = IDLE;
        endcase
    end

    // Registers + Main Algorithm
    always_ff @(posedge Clock or posedge Reset) begin
        if (Reset) begin
            A <= 5'b0;
            Q <= 4'b0;
            count <= 3'd0;
        end else begin
            case(state)

                IDLE: begin
                    A <= 5'b0;
                    Q <= Dividend;
                    count <= 3'd0;
                end

                RUN: begin
                    // (A,Q) = left shift {A,Q}
                    {A, Q} <= {A, Q} << 1;

                    // Substract M from A
                    A <= A - M;

                    // Check sign
                    if (A[4] == 1) begin
                        // Negative --> restore A and set q0 = 0
                        A <= A + M;
                        Q[0] <= 1'b0;
                    end else begin
                        // Positive --> keep subtraction, q0 = 1
                        Q[0] <= 1'b1;
                    end

                    count <= count + 1;
                end

                DONE: begin
                    // Hold results
                end

            endcase
        end
    end

endmodule
