
// scheduler.v - elevator scheduler

module scheduler(
    input clk,
    input rst,

    input [3:0] floor_requests, // ==> Bitmask: [3]floor3, [2]floor2, [1]floor1, [0]floorG
    input [1:0] elev1_floor, // ==> Elevator 1 current floor
    input elev1_busy, // ==> Elevator 1 busy status
    input elev1_moving_up, // ==> Elevator 1 direction
    input elev1_moving_down, // ==> Elevator 1 direction
    input [1:0] elev2_floor, // ==> Elevator 2 current floor
    input elev2_busy, // ==> Elevator 2 busy status  
    input elev2_moving_up, // ==> Elevator 2 direction
    input elev2_moving_down, // ==> Elevator 2 direction
    
    output reg [1:0] elev1_target, // ==> target floor for elevator 1
    output reg elev1_move_enable,  // ==> move enable for elevator 1
    output reg [1:0] elev2_target, // ==> target floor for elevator 2
    output reg elev2_move_enable,  // ==> move enable for elevator 2
    output reg [3:0] request_ack   // ==> acknowledged requests
);

    reg [3:0] pending_requests;
    reg [1:0] elev1_next_target, elev2_next_target;
    reg elev1_next_enable, elev2_next_enable;
    reg [3:0] next_request_ack;
    
    parameter FLOOR_G = 2'b00;
    parameter FLOOR_1 = 2'b01;
    parameter FLOOR_2 = 2'b10; 
    parameter FLOOR_3 = 2'b11;

    // combinational logic for scheduling
    always @(*) begin
        // default values
        elev1_next_target = elev1_floor;
        elev2_next_target = elev2_floor;
        elev1_next_enable = 1'b0;
        elev2_next_enable = 1'b0;
        next_request_ack = 4'b0000;

        // check each floor
        if (pending_requests[0]) begin // floor G
            if (!elev1_busy) begin
                elev1_next_target = FLOOR_G;
                elev1_next_enable = 1'b1;
                next_request_ack[0] = 1'b1;
            end else if (!elev2_busy) begin
                elev2_next_target = FLOOR_G;
                elev2_next_enable = 1'b1;
                next_request_ack[0] = 1'b1;
            end
        end
        
        if (pending_requests[1]) begin // floor 1
            if (!elev1_busy) begin
                elev1_next_target = FLOOR_1;
                elev1_next_enable = 1'b1;
                next_request_ack[1] = 1'b1;
            end else if (!elev2_busy) begin
                elev2_next_target = FLOOR_1;
                elev2_next_enable = 1'b1;
                next_request_ack[1] = 1'b1;
            end
        end
        
        if (pending_requests[2]) begin // floor 2
            if (!elev1_busy) begin
                elev1_next_target = FLOOR_2;
                elev1_next_enable = 1'b1;
                next_request_ack[2] = 1'b1;
            end else if (!elev2_busy) begin
                elev2_next_target = FLOOR_2;
                elev2_next_enable = 1'b1;
                next_request_ack[2] = 1'b1;
            end
        end
        
        if (pending_requests[3]) begin // floor 3
            if (!elev1_busy) begin
                elev1_next_target = FLOOR_3;
                elev1_next_enable = 1'b1;
                next_request_ack[3] = 1'b1;
            end else if (!elev2_busy) begin
                elev2_next_target = FLOOR_3;
                elev2_next_enable = 1'b1;
                next_request_ack[3] = 1'b1;
            end
        end
    end

    // sequential logic
    always @(posedge clk or posedge rst) begin

        if (rst) begin
            pending_requests <= 4'b0000;
            elev1_target <= FLOOR_G;
            elev2_target <= FLOOR_G;
            elev1_move_enable <= 1'b0;
            elev2_move_enable <= 1'b0;
            request_ack <= 4'b0000;

        end else begin
            pending_requests <= (pending_requests | floor_requests) & ~request_ack;
            elev1_target <= elev1_next_target;
            elev2_target <= elev2_next_target;
            elev1_move_enable <= elev1_next_enable;
            elev2_move_enable <= elev2_next_enable;
            request_ack <= next_request_ack;
        end
    end

endmodule
