// arbiter_priority.v - priority arbiter

module arbiter_priority(
    input clk,
    input rst,
    
    input [3:0] floor_requests, // normal floor requests
    input emergency_stop, // emergency stop signal
    input [1:0] priority_floor, // priority floor request 
    input priority_request, // priority request active
    
    output reg [3:0] arbiter_requests, // output requests to scheduler
    output reg emergency_override // emergency override signal
);

    reg emergency_stop_latched;
    reg [1:0] current_priority_floor;
    
    // emergency stop and priority handling
    always @(posedge clk or posedge rst) begin
        
        if (rst) begin
            emergency_stop_latched <= 1'b0;
            emergency_override <= 1'b0;
            current_priority_floor <= 2'b00;
            arbiter_requests <= 4'b0000;
        
        end else begin

            if (emergency_stop) begin
                // emergency situation
                emergency_stop_latched <= 1'b1;
                emergency_override <= 1'b1;
                arbiter_requests <= 4'b0000;
            
            end else if (emergency_stop_latched) begin
                // stay in emergency until system reset
                emergency_override <= 1'b1;
                arbiter_requests <= 4'b0000;
            
            end else if (priority_request) begin
                // priority mode - only serve priority floor
                emergency_override <= 1'b0;
                current_priority_floor <= priority_floor;
                arbiter_requests <= 4'b0000;
                case (priority_floor)
                    2'b00: arbiter_requests[0] <= 1'b1; // Floor G
                    2'b01: arbiter_requests[1] <= 1'b1; // Floor 1
                    2'b10: arbiter_requests[2] <= 1'b1; // Floor 2
                    2'b11: arbiter_requests[3] <= 1'b1; // Floor 3
                endcase
            
            end else begin
                // normal elevator operation
                emergency_override <= 1'b0;
                emergency_stop_latched <= 1'b0;
                arbiter_requests <= floor_requests;
            
            end
        end
    end

endmodule
