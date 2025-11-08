# Dual Elevator Controller System

## Project Overview
The **Dual Elevator Controller System** is a Verilog-based digital design that manages two elevators operating within the same building.  
It handles multiple simultaneous floor requests, optimizes elevator allocation, and includes **priority handling**, **emergency stops**, and **efficient dispatch scheduling** - ensuring smooth and conflict-free operation. This is our DDCO - Digital Design and Computer Organisation - mini project

---

## Team members & responsibilities  

### Shriya - elevator core design
- designed **FSM (Finite State Machine)** for elevator movement, door control, and idle logic  
- implemented `elevator.v` for local elevator operation and request processing  
- created `tb_elevator.v` for **unit testing** and validation of elevator FSM  
- verified proper movement, door response, and request acknowledgment  

### Shreyashree - scheduler & arbiter
- implemented `scheduler.v` for intelligent **multi-elevator dispatching**  
- built `arbiter_priority.v` to handle **priority overrides** and **emergency conditions**  
- designed `tb_scheduler.v` for system-level verification with real elevator modules  
- validated coordination between both elevators under mixed request conditions  

### Shravani - System Integration & Documentation
- integrated all modules into `top_module.v` for full system functionality  
- created `tb_system.v` to simulate the entire dual-elevator environment  
- analysed **GTKWave** outputs for timing and performance analysis  

---

## Features of our elevator
- **automatic door & idle control** - FSM handles open/close timing  
- **dynamic scheduling** - scheduler assigns requests based on availability and proximity  
- **dual elevator coordination** - prevents both elevators from targeting the same floor  
- **priority & emergency handling** - managed via Arbiter for VIP or safety modes  
- **waveform verification** - thoroughly tested with GTKWave and Verilog testbenches  

---

## Simulation & testing
- simulations executed using **Icarus Verilog**  
- testbenches generate `.vcd` waveform files for visualization using **GTKWave**   

---

## How to use
1. Compiling the codes
```bash
iverilog -o system src/*.v testbench/tb_system.v
```
2. VVP output
```bash
vvp system
```
3. GTKWave for visualisation
```bash
gtkwave system_waveform.vcd
```


