`timescale 1ns / 1ps

// This module implements a digital roulette wheel with BCD outputs
// for displaying the winning number on an external display like an LCD.
// It includes a state machine, a button debouncer, and a pseudo-random
// number generator (LFSR).
module roulette_wheel (
    input wire clk,              // System clock input (e.g., 50 MHz)
    input wire reset,            // Asynchronous reset input
    input wire spin_button,      // Push button to start a new spin
    output wire [3:0] bcd_tens,  // BCD output for the tens digit (0-3)
    output wire [3:0] bcd_ones,  // BCD output for the ones digit (0-9)
    output wire [1:0] display_mode // 00: IDLE, 01: SPINNING, 10: SHOW_RESULT
);

    // --- Parameters ---
    parameter CLOCK_FREQ = 50_000_000;    // System clock frequency in Hz
    parameter SPIN_TIME_SEC = 5;          // Duration of the spin in seconds
    parameter DEBOUNCE_TIME_MS = 20;      // Debounce time for the button in milliseconds
    
    // Calculated debounce count based on frequency
    localparam DEBOUNCE_COUNT_MAX = (CLOCK_FREQ / 1000) * DEBOUNCE_TIME_MS;
    
    // --- State Machine Definition ---
    typedef enum logic [1:0] {IDLE, SPINNING, SHOW_RESULT} roulette_state_t;
    reg roulette_state;

    // --- Internal Registers & Wires ---
    
    // Clock divider and timer for the spin duration
    reg [25:0] second_counter;
    reg [3:0] spin_timer;
    wire second_enable;

    // Button debouncer
    reg [25:0] debounce_counter;
    reg spin_button_debounced;
    reg spin_button_prev_state;
    wire spin_button_pos_edge;

    // Pseudo-random number generator (LFSR)
    reg [5:0] lfsr; // 6 bits for numbers 0-36
    
    // Winning number register
    reg [5:0] winning_number;
    
    // BCD conversion registers
    reg [3:0] bcd_tens_reg, bcd_ones_reg;

    // --- Clock Divider (generates a 1 Hz pulse) ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            second_counter <= 26'd0;
        end else if (second_counter == CLOCK_FREQ - 1) begin
            second_counter <= 26'd0;
        end else begin
            second_counter <= second_counter + 1'b1;
        end
    end
    assign second_enable = (second_counter == CLOCK_FREQ - 1);

    // --- Button Debouncer ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            spin_button_prev_state <= 1'b0;
            spin_button_debounced <= 1'b0;
            debounce_counter <= 26'd0;
        end else begin
            if (spin_button) begin
                if (debounce_counter < DEBOUNCE_COUNT_MAX) begin
                    debounce_counter <= debounce_counter + 1'b1;
                end else begin
                    spin_button_debounced <= 1'b1;
                end
            end else begin
                spin_button_debounced <= 1'b0;
                debounce_counter <= 26'd0;
            end
            spin_button_prev_state <= spin_button_debounced;
        end
    end
    assign spin_button_pos_edge = spin_button_debounced & ~spin_button_prev_state;

    // --- Pseudo-Random Number Generator (LFSR) ---
    // A 6-bit LFSR for numbers up to 63. We will constrain the result to 0-36.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 6'h01; // Initial seed
        end else if (second_enable) begin
            // Tap points for a 6-bit LFSR: {lfsr[5], lfsr[4], lfsr[3], lfsr[2] ^ lfsr[5], lfsr[1] ^ lfsr[5], lfsr[0] ^ lfsr[5]}
            lfsr <= {lfsr[4], lfsr[3], lfsr[2], lfsr[1], lfsr[0], lfsr[5] ^ lfsr[4]};
        end
    end

    // --- State Machine Logic ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            roulette_state <= IDLE;
            spin_timer <= 4'd0;
            winning_number <= 6'd0;
        end else begin
            case (roulette_state)
                IDLE: begin
                    if (spin_button_pos_edge) begin
                        roulette_state <= SPINNING;
                        spin_timer <= 4'd0;
                    end
                end
                
                SPINNING: begin
                    if (second_enable) begin
                        spin_timer <= spin_timer + 1'b1;
                        if (spin_timer == SPIN_TIME_SEC - 1) begin
                            roulette_state <= SHOW_RESULT;
                            // Capture the winning number. Ensure it's in the 0-36 range.
                            // The `lfsr % 37` is for simulation and can be replaced with a more
                            // robust hardware implementation of modulo for synthesis.
                            winning_number <= lfsr % 37;
                        end
                    end
                end
                
                SHOW_RESULT: begin
                    if (spin_button_pos_edge) begin
                        roulette_state <= IDLE;
                    end
                end
                
                default: roulette_state <= IDLE;
            endcase
        end
    end
    
    // --- BCD Conversion & Output Logic ---
    // Converts the winning number (0-36) into two BCD digits.
    always @(*) begin
        case (roulette_state)
            SHOW_RESULT: begin
                bcd_tens_reg = winning_number / 10;
                bcd_ones_reg = winning_number % 10;
            end
            default: begin
                // In IDLE or SPINNING, you could display a spinning symbol or a placeholder
                bcd_tens_reg = 4'b1111; // Example of a placeholder, e.g., a blank on the display
                bcd_ones_reg = 4'b1111;
            end
        endcase
    end
    
    // Assign outputs
    assign bcd_tens = bcd_tens_reg;
    assign bcd_ones = bcd_ones_reg;
    assign display_mode = roulette_state; // 00: IDLE, 01: SPINNING, 10: SHOW_RESULT

endmodule
