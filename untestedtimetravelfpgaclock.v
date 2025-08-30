`timescale 1ns / 1ps

// FPGA Clock module with an LCD interface and a time adjustment button.
// This module provides the BCD outputs for seconds, minutes, and hours,
// as well as a button debouncer for the "time travel" function.
module fpga_clock_lcd (
    input wire clk,             // System clock input (e.g., 50 MHz)
    input wire reset,           // Asynchronous reset input
    input wire time_travel_btn, // Button for time adjustment
    output wire [3:0] BCD_seconds_ones,  // BCD output for seconds ones digit
    output wire [3:0] BCD_seconds_tens,  // BCD output for seconds tens digit
    output wire [3:0] BCD_minutes_ones,  // BCD output for minutes ones digit
    output wire [3:0] BCD_minutes_tens,  // BCD output for minutes tens digit
    output wire [3:0] BCD_hours_ones,    // BCD output for hours ones digit
    output wire [3:0] BCD_hours_tens     // BCD output for hours tens digit
);

    // --- Parameters ---
    parameter CLOCK_FREQ = 50_000_000;    // System clock frequency in Hz
    parameter PRESET_MINUTES = 15;        // Minutes to add on button press
    parameter DEBOUNCE_TIME_MS = 20;      // Debounce time in milliseconds
    
    // Calculated debounce counter value based on clock frequency and time.
    localparam DEBOUNCE_COUNT_MAX = CLOCK_FREQ / (1000 / DEBOUNCE_TIME_MS);
    
    // --- Internal Registers ---
    reg [25:0] second_counter;    // Counter for 1-second pulse
    reg [25:0] debounce_counter;  // Counter for button debouncing
    reg seconds_reg, minutes_reg, hours_reg; // Carry flags for BCD conversion
    
    // BCD registers to hold the time digits
    reg [3:0] seconds_ones_reg, seconds_tens_reg;
    reg [3:0] minutes_ones_reg, minutes_tens_reg;
    reg [3:0] hours_ones_reg, hours_tens_reg;

    reg [3:0] current_seconds_ones, current_seconds_tens;
    reg [3:0] current_minutes_ones, current_minutes_tens;
    reg [3:0] current_hours_ones, current_hours_tens;
    
    // --- Internal Wires ---
    wire second_enable;         // Pulse for 1 second
    reg  debounced_btn_reg;     // Debounced button signal
    wire debounced_btn_pos_edge;// Positive edge of debounced button

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
    // Counts up to debounce_count_max to filter out button bounce.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            debounced_btn_reg <= 1'b0;
            debounce_counter <= 26'd0;
        end else begin
            if (time_travel_btn == 1'b1) begin
                if (debounce_counter < DEBOUNCE_COUNT_MAX) begin
                    debounce_counter <= debounce_counter + 1'b1;
                end else begin
                    debounced_btn_reg <= 1'b1; // Button is stable
                end
            end else begin
                debounce_counter <= 26'd0;
                debounced_btn_reg <= 1'b0;
            end
        end
    end
    
    // Detects a positive edge on the debounced signal
    reg debounced_btn_prev;
    always @(posedge clk or posedge reset) begin
      if (reset) begin
        debounced_btn_prev <= 1'b0;
      end else begin
        debounced_btn_prev <= debounced_btn_reg;
      end
    end
    assign debounced_btn_pos_edge = debounced_btn_reg & ~debounced_btn_prev;
    
    // --- Time Counter Logic ---
    // Manages the time count and applies the time travel logic.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            seconds_ones_reg <= 4'd0;
            seconds_tens_reg <= 4'd0;
            minutes_ones_reg <= 4'd0;
            minutes_tens_reg <= 4'd0;
            hours_ones_reg   <= 4'd0;
            hours_tens_reg   <= 4'd0;
        end else if (debounced_btn_pos_edge) begin
            // "Time Travel" button logic
            // Add the preset minutes to the current time.
            current_minutes_ones <= minutes_ones_reg;
            current_minutes_tens <= minutes_tens_reg;
            
            repeat (PRESET_MINUTES) begin
                if (current_minutes_ones == 4'd9) begin
                    current_minutes_ones <= 4'd0;
                    if (current_minutes_tens == 4'd5) begin
                        current_minutes_tens <= 4'd0;
                        if (current_hours_ones == 4'd9 && current_hours_tens == 4'd2) begin
                            current_hours_ones <= 4'd0;
                            current_hours_tens <= 4'd0;
                        end else if (current_hours_ones == 4'd9) begin
                            current_hours_ones <= 4'd0;
                            current_hours_tens <= current_hours_tens + 1'b1;
                        end else begin
                            current_hours_ones <= current_hours_ones + 1'b1;
                        end
                    end else begin
                        current_minutes_tens <= current_minutes_tens + 1'b1;
                    end
                end else begin
                    current_minutes_ones <= current_minutes_ones + 1'b1;
                end
            end
            
            minutes_ones_reg <= current_minutes_ones;
            minutes_tens_reg <= current_minutes_tens;

        end else if (second_enable) begin
            // Normal second-by-second increment
            if (seconds_ones_reg == 4'd9) begin
                seconds_ones_reg <= 4'd0;
                if (seconds_tens_reg == 4'd5) begin
                    seconds_tens_reg <= 4'd0;
                    if (minutes_ones_reg == 4'd9) begin
                        minutes_ones_reg <= 4'd0;
                        if (minutes_tens_reg == 4'd5) begin
                            minutes_tens_reg <= 4'd0;
                            if (hours_ones_reg == 4'd9 && hours_tens_reg == 4'd2) begin
                                hours_ones_reg <= 4'd0;
                                hours_tens_reg <= 4'd0;
                            end else if (hours_ones_reg == 4'd9) begin
                                hours_ones_reg <= 4'd0;
                                hours_tens_reg <= hours_tens_reg + 1'b1;
                            end else begin
                                hours_ones_reg <= hours_ones_reg + 1'b1;
                            end
                        end else begin
                            minutes_tens_reg <= minutes_tens_reg + 1'b1;
                        end
                    end else begin
                        minutes_ones_reg <= minutes_ones_reg + 1'b1;
                    end
                end else begin
                    seconds_tens_reg <= seconds_tens_reg + 1'b1;
                end
            end else begin
                seconds_ones_reg <= seconds_ones_reg + 1'b1;
            end
        end
    end

    // Assign outputs from the registers.
    assign BCD_seconds_ones = seconds_ones_reg;
    assign BCD_seconds_tens = seconds_tens_reg;
    assign BCD_minutes_ones = minutes_ones_reg;
    assign BCD_minutes_tens = minutes_tens_reg;
    assign BCD_hours_ones   = hours_ones_reg;
    assign BCD_hours_tens   = hours_tens_reg;
    
endmodule
