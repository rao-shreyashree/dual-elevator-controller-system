// top_module.v - Complete Dual Elevator System
module top_module(
  
    input clk,
    input rst,
    input [3:0] floor_requests,    // External floor buttons
    input emergency_stop,          // Emergency stop signal
    input [1:0] priority_floor,    // Priority floor selection
    input priority_request,        // Priority request active
    
    // Elevator 1 status outputs
    output [1:0] elev1_current_floor,
    output elev1_door_open,
    output elev1_moving_up,
    output elev1_moving_down,
    output elev1_busy,
    
    // Elevator 2 status outputs
    output [1:0] elev2_current_floor,
    output elev2_door_open,
    output elev2_moving_up,
    output elev2_moving_down,
    output elev2_busy,
    
    // System status outputs
    output [3:0] request_ack,
    output emergency_override
);

    // Internal wires
    wire [3:0] arbiter_requests;
    wire [1:0] elev1_target, elev2_target;
    wire elev1_move_enable, elev2_move_enable;
    
    // Instantiate Arbiter
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
    
    // Instantiate Scheduler
    scheduler elevator_scheduler (
        .clk(clk),
        .rst(rst),
        .floor_requests(arbiter_requests),
        .elev1_floor(elev1_current_floor),
        .elev1_busy(elev1_busy),
        .elev1_moving_up(elev1_moving_up),
        .elev1_moving_down(elev1_moving_down),
        .elev2_floor(elev2_current_floor),
        .elev2_busy(elev2_busy),
        .elev2_moving_up(elev2_moving_up),
        .elev2_moving_down(elev2_moving_down),
        .elev1_target(elev1_target),
        .elev1_move_enable(elev1_move_enable),
        .elev2_target(elev2_target),
        .elev2_move_enable(elev2_move_enable),
        .request_ack(request_ack)
    );
    
    // Instantiate Elevator 1
    elevator elevator1 (
        .clk(clk),
        .rst(rst),
        .target_floor(elev1_target),
        .move_enable(elev1_move_enable),
        .current_floor(elev1_current_floor),
        .door_open(elev1_door_open),
        .moving_up(elev1_moving_up),
        .moving_down(elev1_moving_down),
        .elevator_busy(elev1_busy)
    );
    
    // Instantiate Elevator 2
    elevator elevator2 (
        .clk(clk),
        .rst(rst),
        .target_floor(elev2_target),
        .move_enable(elev2_move_enable),
        .current_floor(elev2_current_floor),
        .door_open(elev2_door_open),
        .moving_up(elev2_moving_up),
        .moving_down(elev2_moving_down),
        .elevator_busy(elev2_busy)
    );

endmodule
