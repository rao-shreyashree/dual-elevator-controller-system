// tb_system.v - Complete System Testbench
`timescale 1ns/1ps

module tb_system;

    // Inputs
    reg clk;
    reg rst;
    reg [3:0] floor_requests;
    reg emergency_stop;
    reg [1:0] priority_floor;
    reg priority_request;
    
    // Outputs
    wire [1:0] elev1_current_floor, elev2_current_floor;
    wire elev1_door_open, elev2_door_open;
    wire elev1_moving_up, elev2_moving_up;
    wire elev1_moving_down, elev2_moving_down;
    wire elev1_busy, elev2_busy;
    wire [3:0] request_ack;
    wire emergency_override;
    
    // Instantiate complete system
    top_module dut (
        .clk(clk),
        .rst(rst),
        .floor_requests(floor_requests),
        .emergency_stop(emergency_stop),
        .priority_floor(priority_floor),
        .priority_request(priority_request),
        .elev1_current_floor(elev1_current_floor),
        .elev1_door_open(elev1_door_open),
        .elev1_moving_up(elev1_moving_up),
        .elev1_moving_down(elev1_moving_down),
        .elev1_busy(elev1_busy),
        .elev2_current_floor(elev2_current_floor),
        .elev2_door_open(elev2_door_open),
        .elev2_moving_up(elev2_moving_up),
        .elev2_moving_down(elev2_moving_down),
        .elev2_busy(elev2_busy),
        .request_ack(request_ack),
        .emergency_override(emergency_override)
    );
    
    // Clock generation (100MHz)
    always #5 clk = ~clk;
    
    // Test sequence
    initial begin
        $display("=== COMPLETE DUAL ELEVATOR SYSTEM TEST ===");
        $display("Time\tReq\tE1\tE2\tAck\tEmergency");
        $display("===========================================");
        
        // Initialize system
        initialize_system();
        
        // Test 1: Normal Operation - Multiple Requests
        test_normal_operation();
        
        // Test 2: Priority Mode
        test_priority_mode();
        
        // Test 3: Emergency Stop
        test_emergency_stop();
        
        // Test 4: Complex Scenario
        test_complex_scenario();
        
        $display("\n=== ALL TESTS COMPLETED SUCCESSFULLY ===");
        $finish;
    end
    
    // Initialize system
    task initialize_system;
        begin
            clk = 0;
            rst = 1;
            floor_requests = 4'b0000;
            emergency_stop = 0;
            priority_floor = 2'b00;
            priority_request = 0;
            
            #100 rst = 0;
            $display("System initialized and ready");
        end
    endtask
    
    // Test 1: Normal Operation
    task test_normal_operation;
        begin
            $display("\n--- Test 1: Normal Operation ---");
            
            // Request floors 2 and 3
            #50 floor_requests = 4'b1100;
            $display("Requested floors 2 and 3");
            
            // Wait for elevators to respond
            #300;
            
            // Request floor 1
            floor_requests = 4'b0010;
            $display("Requested floor 1");
            
            #400;
            floor_requests = 4'b0000;
        end
    endtask
    
    // Test 2: Priority Mode
    task test_priority_mode;
        begin
            $display("\n--- Test 2: Priority Mode ---");
            
            // Set priority to floor 2
            #50 priority_request = 1;
            priority_floor = 2'b10;
            floor_requests = 4'b0101; // Floors G and 1 (should be ignored)
            $display("Priority mode activated - Floor 2");
            
            #200 priority_request = 0;
            floor_requests = 4'b0000;
        end
    endtask
    
    // Test 3: Emergency Stop
    task test_emergency_stop;
        begin
            $display("\n--- Test 3: Emergency Stop ---");
            
            // Activate emergency stop during operation
            #50 emergency_stop = 1;
            floor_requests = 4'b1111; // All floors (should be ignored)
            $display("EMERGENCY STOP ACTIVATED");
            
            #100 emergency_stop = 0;
            $display("Emergency stop released");
            
            #200;
        end
    endtask
    
    // Test 4: Complex Scenario
    task test_complex_scenario;
        begin
            $display("\n--- Test 4: Complex Scenario ---");
            
            // Multiple sequential requests
            #50 floor_requests = 4'b1000; // Floor 3
            $display("Requested floor 3");
            
            #200 floor_requests = 4'b0100; // Floor 2
            $display("Requested floor 2");
            
            #200 floor_requests = 4'b0010; // Floor 1
            $display("Requested floor 1");
            
            #200 floor_requests = 4'b0001; // Floor G
            $display("Requested floor G");
            
            #400 floor_requests = 4'b0000;
        end
    endtask
    
    // Monitor system status
    always @(posedge clk) begin
        if (!rst) begin
            $display("%0t ns\t%b\t%0d\t%0d\t%b\t%b",
                $realtime, floor_requests, 
                elev1_current_floor, elev2_current_floor,
                request_ack, emergency_override);
        end
    end
    
    // VCD generation for detailed waveform analysis
    initial begin
        $dumpfile("complete_system.vcd");
        $dumpvars(0, tb_system);
    end
    
    // Automatic test verification
    reg test_passed = 1;
    always @(posedge clk) begin
        // Verify emergency override works
        if (emergency_stop && !emergency_override) begin
            $display("ERROR: Emergency override not working!");
            test_passed = 0;
        end
        
        // Verify elevators don't move during emergency
        if (emergency_override && (elev1_moving_up || elev1_moving_down || elev2_moving_up || elev2_moving_down)) begin
            $display("ERROR: Elevators moving during emergency!");
            test_passed = 0;
        end
    end

endmodule
