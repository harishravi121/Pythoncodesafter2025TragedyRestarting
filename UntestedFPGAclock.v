`timescale 1ns / 1ps

// A digital clock module that counts seconds, minutes, and hours.
// This design is synchronous and includes a reset signal.
module digital_clock (
    input wire clk,       // System clock input
    input wire reset,     // Synchronous reset input
    output reg [5:0] seconds,  // 6-bit counter for seconds (0-59)
    output reg [5:0] minutes,  // 6-bit counter for minutes (0-59)
    output reg [4:0] hours     // 5-bit counter for hours (0-23)
);

    // Parameter for the clock frequency in Hz.
    // The default value of 50_000_000 corresponds to a 50 MHz clock.
    parameter CLOCK_FREQ = 50_000_000; 

    // Counter to generate a 1-second enable pulse.
    reg [25:0] second_counter;
    
    // Enable signal for the second counter, pulses once per second.
    wire second_enable;
    
    // --- Clock Divider Logic ---
    // The clock divider counts up to CLOCK_FREQ - 1 and then generates a 
    // second_enable pulse. This effectively divides the high-frequency clock
    // down to a 1 Hz signal.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            second_counter <= 26'd0;
        end else if (second_counter == CLOCK_FREQ - 1) begin
            second_counter <= 26'd0;
        end else begin
            second_counter <= second_counter + 1'b1;
        end
    end
    
    // Assign the second enable signal based on the counter reaching its limit.
    assign second_enable = (second_counter == CLOCK_FREQ - 1);
    
    // --- Clock Counter Logic ---
    // This block handles the counting for seconds, minutes, and hours.
    // It is triggered by the positive edge of the main clock or the reset signal.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all clock counters to zero.
            seconds <= 6'd0;
            minutes <= 6'd0;
            hours   <= 5'd0;
        end else begin
            // The counting logic is triggered by the 1-second enable pulse.
            if (second_enable) begin
                if (seconds == 6'd59) begin
                    seconds <= 6'd0; // Reset seconds to 0
                    if (minutes == 6'd59) begin
                        minutes <= 6'd0; // Reset minutes to 0
                        if (hours == 5'd23) begin
                            hours <= 5'd0;   // Reset hours to 0
                        end else begin
                            hours <= hours + 1'b1; // Increment hours
                        end
                    end else begin
                        minutes <= minutes + 1'b1; // Increment minutes
                    end
                end else begin
                    seconds <= seconds + 1'b1; // Increment seconds
                end
            end
        end
    end

endmodule
