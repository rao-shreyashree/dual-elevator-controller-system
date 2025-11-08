// elevator.v - Individual Elevator FSM
  
module elevator(
    input clk,
    input rst,
    input [1:0] target_floor,    // 2-bit floor target (00=G, 01=1, 10=2, 11=3)
    input move_enable,           // Controller permission to move
    output reg [1:0] current_floor,  // Current floor position
    output reg door_open,        // Door status
    output reg moving_up,        // Movement direction
    output reg moving_down,      // Movement direction
    output reg elevator_busy     // Status indicator
);

    // Floor encoding
    parameter FLOOR_G  = 2'b00;  // Ground floor
    parameter FLOOR_1  = 2'b01;  // First floor  
    parameter FLOOR_2  = 2'b10;  // Second floor
    parameter FLOOR_3  = 2'b11;  // Third floor

    // State encoding
    parameter STATE_IDLE      = 2'b00;
    parameter STATE_MOVING_UP = 2'b01;
    parameter STATE_MOVING_DOWN = 2'b10;
    parameter STATE_DOOR_OPEN = 2'b11;

    reg [1:0] state;
    reg [1:0] next_state;
    reg [2:0] move_timer;      // Timer for floor-to-floor movement
    reg [2:0] door_timer;      // Timer for door operations

    // State transition logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= STATE_IDLE;
            current_floor <= FLOOR_G;
            door_open <= 1'b1;     // Doors open at start
            moving_up <= 1'b0;
            moving_down <= 1'b0;
            elevator_busy <= 1'b0;
            move_timer <= 3'b0;
            door_timer <= 3'b0;
        end else begin
            case (state)
                STATE_IDLE: begin
                    door_open <= 1'b1;
                    moving_up <= 1'b0;
                    moving_down <= 1'b0;
                    elevator_busy <= 1'b0;
                    door_timer <= door_timer + 1;
                    
                    if (door_timer >= 3'd3) begin // Door open for 3 cycles
                        if (move_enable && (target_floor != current_floor)) begin
                            state <= (target_floor > current_floor) ? STATE_MOVING_UP : STATE_MOVING_DOWN;
                            move_timer <= 3'b0;
                            elevator_busy <= 1'b1;
                        end
                    end
                end
                
                STATE_MOVING_UP: begin
                    door_open <= 1'b0;
                    moving_up <= 1'b1;
                    moving_down <= 1'b0;
                    elevator_busy <= 1'b1;
                    move_timer <= move_timer + 1;
                    
                    if (move_timer >= 3'd2) begin // Movement takes 2 cycles
                        current_floor <= current_floor + 1; // Move up one floor
                        state <= STATE_DOOR_OPEN;
                        door_timer <= 3'b0;
                    end
                end
                
                STATE_MOVING_DOWN: begin
                    door_open <= 1'b0;
                    moving_up <= 1'b0;
                    moving_down <= 1'b1;
                    elevator_busy <= 1'b1;
                    move_timer <= move_timer + 1;
                    
                    if (move_timer >= 3'd2) begin // Movement takes 2 cycles
                        current_floor <= current_floor - 1; // Move down one floor
                        state <= STATE_DOOR_OPEN;
                        door_timer <= 3'b0;
                    end
                end
                
                STATE_DOOR_OPEN: begin
                    door_open <= 1'b1;
                    moving_up <= 1'b0;
                    moving_down <= 1'b0;
                    elevator_busy <= 1'b1;
                    door_timer <= door_timer + 1;
                    
                    if (door_timer >= 3'd3) begin // Door open for 3 cycles
                        state <= STATE_IDLE;
                        door_timer <= 3'b0;
                    end
                end
            endcase
        end
    end

    // Next state logic (combinational)
    always @(*) begin
        next_state = state;
        case (state)
            STATE_IDLE: begin
                if (move_enable && (target_floor != current_floor)) begin
                    next_state = (target_floor > current_floor) ? STATE_MOVING_UP : STATE_MOVING_DOWN;
                end
            end
            STATE_MOVING_UP: begin
                if (move_timer >= 3'd2) begin
                    next_state = STATE_DOOR_OPEN;
                end
            end
            STATE_MOVING_DOWN: begin
                if (move_timer >= 3'd2) begin
                    next_state = STATE_DOOR_OPEN;
                end
            end
            STATE_DOOR_OPEN: begin
                if (door_timer >= 3'd3) begin
                    next_state = STATE_IDLE;
                end
            end
        endcase
    end

endmodule
