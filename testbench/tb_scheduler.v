// tb_scheduler.v - testbench for scheduler and arbiter
`timescale 1ns/1ps

module tb_scheduler;

    reg clk, rst;
    reg [3:0] floor_requests;
    reg emergency_stop;
    reg [1:0] priority_floor;
    reg priority_request;
    
    // Elevator 1 signals
    wire [1:0] elev1_target, elev1_floor;
    wire elev1_move_enable, elev1_busy;
    wire elev1_moving_up, elev1_moving_down, elev1_door_open;
    
    // Elevator 2 signals  
    wire [1:0] elev2_target, elev2_floor;
    wire elev2_move_enable, elev2_busy;
    wire elev2_moving_up, elev2_moving_down, elev2_door_open;
    
    wire [3:0] request_ack;
    wire [3:0] arbiter_requests;
    wire emergency_override;

    // instantiating arbiter
    arbiter_priority arbiter (
        .clk(clk),
        .rst(rst),
        .floor_requests(floor_requests),
        .emergency_stop(emergency_stop),
        .priority_floor(priority_floor),
        .priority_request(priority_request),
        .arbiter_requests(arbiter_requests),
        .emergency_override(emergency_override)
    );

    // instantiating scheduler
    scheduler dut (
        .clk(clk),
        .rst(rst),
        .floor_requests(arbiter_requests),
        .elev1_floor(elev1_floor), // FROM elevator 1
        .elev1_busy(elev1_busy), // FROM elevator 1
        .elev1_moving_up(elev1_moving_up), // FROM elevator 1
        .elev1_moving_down(elev1_moving_down), // FROM elevator 1
        .elev2_floor(elev2_floor), // FROM elevator 2
        .elev2_busy(elev2_busy), // FROM elevator 2
        .elev2_moving_up(elev2_moving_up), // FROM elevator 2
        .elev2_moving_down(elev2_moving_down), // FROM elevator 2
        .elev1_target(elev1_target), // TO elevator 1
        .elev1_move_enable(elev1_move_enable), // TO elevator 1
        .elev2_target(elev2_target), // TO elevator 2
        .elev2_move_enable(elev2_move_enable), // TO elevator 2
        .request_ack(request_ack)
    );

    // instantiating elevators 
    elevator elev1 (
        .clk(clk),
        .rst(rst),
        .target_floor(elev1_target), // FROM scheduler
        .move_enable(elev1_move_enable), // FROM scheduler
        .current_floor(elev1_floor), // TO scheduler
        .door_open(elev1_door_open),
        .moving_up(elev1_moving_up), // TO scheduler
        .moving_down(elev1_moving_down), // TO scheduler
        .elevator_busy(elev1_busy) // TO scheduler
    );

    elevator elev2 (
        .clk(clk),
        .rst(rst),
        .target_floor(elev2_target), // FROM scheduler
        .move_enable(elev2_move_enable), // FROM scheduler
        .current_floor(elev2_floor), // TO scheduler
        .door_open(elev2_door_open),
        .moving_up(elev2_moving_up), // TO scheduler
        .moving_down(elev2_moving_down), // TO scheduler
        .elevator_busy(elev2_busy) // TO scheduler
    );

    // clock
    always #5 clk = ~clk;

initial begin

    $display("Dual Elevator System Testbench\n");
    $display("Time\t\tReq\tE1 flr\tE2 flr\tTarget1\tTarget2\tAck");
    
    // initialising
    clk = 0;
    rst = 1;
    floor_requests = 4'b0000;
    emergency_stop = 0;
    priority_floor = 2'b00;
    priority_request = 0;
    #20 rst = 0;
    
    // Test 1: simple request - Floor 2 pressed
    #30 floor_requests = 4'b0100; // Floor 2 request
    #100 floor_requests = 4'b0000; // clear request after elevators respond
    
    #300;
    
    // Test 2: multiple requests
    #30 floor_requests = 4'b1010; // Floors 1 and 3
    #100 floor_requests = 4'b0000;
    
    #400;
    
    // Test 3: priority request
    #30 priority_request = 1;
    priority_floor = 2'b10; // Priority to floor 2
    floor_requests = 4'b0001; // Should be ignored
    #100 priority_request = 0;
    floor_requests = 4'b0000;
    
    #300;
    
    // Test 4: emergency stop
    #30 emergency_stop = 1;
    floor_requests = 4'b1111; // all floors - should be ignored
    #100 emergency_stop = 0;
    floor_requests = 4'b0000;
    
    #300;
    
    $display("\nScheduler Test Complete\n");
    $finish;
end

    // monitor
    always @(posedge clk) begin
        $display("%0t ns\t%b\t%0d\t%0d\t%0d\t%0d\t%b", 
            $realtime, floor_requests, elev1_floor, elev2_floor, 
            elev1_target, elev2_target, request_ack);
    end

    // VCD generation
    initial begin
        $dumpfile("scheduler_system.vcd");
        $dumpvars(0, tb_scheduler);
    end

endmodule
