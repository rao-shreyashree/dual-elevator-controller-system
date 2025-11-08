`timescale 1ns/1ps

module tb_elevator;
    reg clk;
    reg rst;
    reg [1:0] target_floor;
    reg move_enable;
    
    wire [1:0] current_floor;
    wire door_open;
    wire moving_up;
    wire moving_down;
    wire elevator_busy;

    // Instantiate Elevator module
    elevator dut (
        .clk(clk),
        .rst(rst),
        .target_floor(target_floor),
        .move_enable(move_enable),
        .current_floor(current_floor),
        .door_open(door_open),
        .moving_up(moving_up),
        .moving_down(moving_down),
        .elevator_busy(elevator_busy)
    );

    // Clock generation (10ns period = 100MHz)
    always #5 clk = ~clk;

    // Test sequence
    initial begin
        $display("=== Single Elevator Testbench ===");
        $display("Time(ns) Floor Door Up Down Busy Target");
        $display("----------------------------------------");

        // Initialize
        clk = 0;
        rst = 1;
        target_floor = 2'b00;
        move_enable = 0;

        // Release reset
        #20 rst = 0;

        // Test 1: Move from G -> 2
        #30 move_enable = 1;
        target_floor = 2'b10;
        #300;

        // Test 2: Move from 2 -> 1
        move_enable = 0;
        #40 move_enable = 1;
        target_floor = 2'b01;
        #300;

        // Test 3: Stay on same floor
        move_enable = 0;
        #40 move_enable = 1;
        target_floor = 2'b01;
        #200;

        $display("\n=== Test Complete ===");
        $finish;
    end

    // Proper display formatting every clock
    always @(posedge clk) begin
        $display("%8t   %0d     %0b    %0b   %0b    %0b     %0d", 
    $time,

            current_floor, 
            door_open, 
            moving_up, 
            moving_down, 
            elevator_busy, 
            target_floor);
    end

    // Dump waveform for GTKWave
    initial begin
        $dumpfile("elevator.vcd");
        $dumpvars(0, tb_elevator);
    end
endmodule

