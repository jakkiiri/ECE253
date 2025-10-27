module part3 (
    input  logic        Clock, Reset, Go,
    input  logic [3:0]  Divisor, Dividend,
    output logic [3:0]  Quotient, Remainder,
    output logic        ResultValid
);

    logic [4:0] A;
    logic [3:0] Q;
    logic [4:0] M;
    logic [1:0] count;

    typedef enum logic [1:0] {IDLE, RUN, DONE} state_t;
    state_t state, next_state;

    assign Quotient    = Q;
    assign Remainder   = A[3:0];
    assign ResultValid = (state == DONE);

    always_ff @(posedge Clock) begin
        if (Reset)                     M <= 5'b0;
        else if (Go && (state == IDLE || state == DONE))  M <= {1'b0, Divisor};
    end

    always_ff @(posedge Clock) begin
        if (Reset)  state <= IDLE;
        else        state <= next_state;
    end

    always_comb begin
        next_state = state;
        case (state)
            IDLE: if (Go)               next_state = RUN;
            RUN : if (count == 2'd3)    next_state = DONE;
            DONE: if (Go)               next_state = RUN;
                  else                  next_state = DONE;
        endcase
    end

    always_ff @(posedge Clock) begin
        logic [8:0] AQ_shifted;
        logic [4:0] A_temp;

        if (Reset) begin
            A        <= 5'b0;
            Q        <= 4'b0;
            count    <= 2'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (Go) begin
                        A        <= 5'b0;
                        Q        <= Dividend;
                        count    <= 2'b0;
                    end
                end

                RUN: begin
                    AQ_shifted = {A, Q} << 1;
                    A_temp     = AQ_shifted[8:4] - M;

                    if (A_temp[4]) begin
                        A <= AQ_shifted[8:4];
                        Q <= {AQ_shifted[3:1], 1'b0};
                    end else begin
                        A <= A_temp;
                        Q <= {AQ_shifted[3:1], 1'b1};
                    end
                    count <= count + 1'b1;
                end

                DONE: begin
                    if (Go) begin
                        A        <= 5'b0;
                        Q        <= Dividend;
                        count    <= 2'b0;
                    end
                end
            endcase
        end
    end

endmodule
